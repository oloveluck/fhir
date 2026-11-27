# fhir-toolkit

[FHIR](https://hl7.org/fhir/) is the standard for health data, and it comes with small languages:
one for what valid data looks like (FSH), one for clinical logic (CQL), one for questions of a
record (FHIRPath), one for converting data (the mapping language), one for sets of codes (VCL),
one for tables (SQL on FHIR). This package is all of them from Python: compile, check, run and
validate, with every problem reported at its line.

It is not on the Python Package Index yet. A wheel is built by the repository's `wheels`
workflow (its artifacts), and it carries the toolkit itself, so nothing else has to be installed:

```sh
pip install fhir_toolkit-0.1.0-py3-none-<your platform>.whl
```

Calls go to one process of the toolkit. It starts in the background when you make a `Toolkit`
(making one does not wait for it) and answers each call in well under a millisecond of overhead.
While your program does something else, it loads what your first calls will need, so that they do
not wait for it.

## A first example

```python
from fhir_toolkit import Toolkit

fhir = Toolkit()

patient = {
    "resourceType": "Patient", "id": "ann", "gender": "female", "birthDate": "1980-02-28",
    "name": [{"family": "Lee", "given": ["Ann"]}],
}

print(fhir.fhirpath("name.given.first() + ' ' + name.family.first()", patient))
print(fhir.validate(patient).ok)
print(fhir.validate({"resourceType": "Patient", "gender": "florp"}).messages())
```

```text
['Ann Lee']
True
['Patient.gender: error: code `florp` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown']
```

## Say what valid means, then hold data to it

A profile written in FSH is a project: a dict of file name to text. Give it to `validate` and
name the profile.

```python
profile = """
Profile: AdultPatient
Parent: Patient
* birthDate 1..1
"""

outcome = fhir.validate({"resourceType": "Patient", "gender": "female"}, "AdultPatient", project={"rules.fsh": profile})
print(outcome.ok)
print(outcome.messages())
```

```text
False
['Patient.birthDate: error: minimum required = 1, but found 0']
```

A mistake in the FSH itself is an exception that knows its line:

```python
from fhir_toolkit import FhirError

try:
    fhir.fsh("Profile: P\nParent: Patient\n* nmae 1..1\n")
except FhirError as error:
    print(error.diagnostics[0])
```

```text
input.fsh:3:3: error: profile: P: `nmae` is not an element of Patient (did you mean `name`?)
```

## Tables from FHIR, as a DataFrame

A view is a `SELECT` whose columns are FHIRPath. `to_pandas()` needs pandas.

```python
observation = {
    "resourceType": "Observation", "id": "a1", "status": "final",
    "code": {"coding": [{"system": "http://loinc.org", "code": "4548-4"}]},
    "subject": {"reference": "Patient/ann"}, "effectiveDateTime": "2025-03-01",
    "valueQuantity": {"value": 9.4, "unit": "%", "system": "http://unitsofmeasure.org", "code": "%"},
}
data = [patient, observation]

frame = fhir.view("SELECT id, name.family.first() AS family, birthDate FROM Patient", data).to_pandas()
print(frame.to_string())
```

```text
    id family   birthDate
0  ann    Lee  1980-02-28
```

Several views are tables you can join in SQL:

```python
views = {
    "patients.sof": "CREATE VIEW patients WITH (status = 'active') AS "
                    "SELECT getResourceKey() AS id, name.family.first() AS family FROM Patient",
    "results.sof": "CREATE VIEW results WITH (status = 'active') AS "
                   "SELECT subject.getReferenceKey(Patient) AS patient, value.ofType(Quantity).value AS value FROM Observation",
}
table = fhir.sql("SELECT p.family, r.value FROM results r JOIN patients p ON p.id = r.patient", project=views, data=data)
print(table.columns, table.rows)
```

```text
['family', 'value'] [{'family': 'Lee', 'value': 9.4}]
```

`data` is resources as here, or the path of a directory of FHIR JSON, a JSON file, a SQLite FHIR
store, or the base url of a FHIR server.

## Clinical logic in CQL

```python
library = """
library A1c version '1.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'
context Patient
define "Latest": Last([Observation] O sort by (effective as dateTime))
define "Above 9": (Latest.value as Quantity) > 9 '%'
"""

print(fhir.cql(library, data).rows)
print(fhir.translate(library)["library"]["identifier"])
```

```text
[{'Above 9': True, 'Latest': 'Observation/a1', 'patient': 'ann'}]
{'id': 'A1c', 'version': '1.0'}
```

`cql` answers one row per patient and one column per define; `translate` gives the library's ELM.

## The other languages

```python
print(fhir.expand("(http://hl7.org/fhir/administrative-gender)(female;male)"))

mapping = """
/// url = "http://example.org/StructureMap/copy"
/// name = "copy"
uses "http://hl7.org/fhir/StructureDefinition/Patient" as source
uses "http://hl7.org/fhir/StructureDefinition/Patient" as target
group main(source src : Patient, target tgt : Patient) {
  src.birthDate as b -> tgt.birthDate = b;
}
"""
print(fhir.transform(mapping, patient))
print(fhir.decompile(patient))
```

```text
[{'code': 'female', 'display': 'Female', 'system': 'http://hl7.org/fhir/administrative-gender'}, {'code': 'male', 'display': 'Male', 'system': 'http://hl7.org/fhir/administrative-gender'}]
{'birthDate': '1980-02-28', 'resourceType': 'Patient'}
Instance: ann
InstanceOf: Patient
Usage: #example
* birthDate = "1980-02-28"
* gender = #female
* name[0].family = "Lee"
* name[0].given[0] = "Ann"
```

`fhir.guide("cql")` (or `fsh`, `fhirpath`, `fml`, `vcl`, `sql-on-fhir`, `fhir`) prints a guide
to each language, written for an AI agent and useful to a person.

## Write data, with a record of who and why

`write` puts resources into a store: a SQLite file, made the first time. Each resource is
validated first, and one error means nothing is written. What is written leaves a trail in the
store: who wrote which version, when and why.

```python
import os
import tempfile

from fhir_toolkit import FhirError

store = os.path.join(tempfile.mkdtemp(), "clinic.db")
a1c = {
    "resourceType": "Observation", "id": "a1c-1", "status": "final",
    "code": {"coding": [{"system": "http://loinc.org", "code": "4548-4"}]},
    "subject": {"reference": "Patient/ann"}, "effectiveDateTime": "2025-03-01",
    "valueQuantity": {"value": 9.4, "unit": "%", "system": "http://unitsofmeasure.org", "code": "%"},
}

written = fhir.write([patient, a1c], data=store, reason="first load", agent="intake desk")
print(written.versions)

try:
    fhir.write(dict(a1c, id="a1c-2", status="finl"), data=store)
except FhirError as refused:
    print(refused)
```

```text
['Patient/ann/_history/1', 'Observation/a1c-1/_history/1']
Observation/a1c-2: Observation.status: code `finl` not in required value set http://hl7.org/fhir/ValueSet/observation-status (did you mean `final`?); it holds amended, cancelled, corrected, entered-in-error, final, preliminary, registered, unknown
```

`stage` is the first half alone: it says what would change and writes nothing until you
`commit`. A correction can be said as the FSH rules that change, laid over the stored resource.
The trail is a table SQL reads.

```python
change = fhir.stage(fsh="""
Instance: Observation/a1c-1
* status = #amended
* valueQuantity = 9.1 '%'
""", data=store)
print(change.changes)
print(change.commit("corrected against the lab's report").versions)

trail = fhir.sql("SELECT type, id, versionId, agent, reason FROM trail ORDER BY type, id, versionId", data=store)
for row in trail:
    print(row["type"], row["id"], row["versionId"], row["agent"], "-", row["reason"])
```

```text
[{'action': 'update', 'changed': ['status: "final" → "amended"', 'valueQuantity.value: 9.4 → 9.1'], 'resource': 'Observation/a1c-1'}]
['Observation/a1c-1/_history/2']
Observation a1c-1 1 intake desk - first load
Observation a1c-1 2 fhir-api - corrected against the lab's report
Patient ann 1 intake desk - first load
```

With a `project`, what is written is held to the project's profiles too: an FSH instance to the
profile it is `InstanceOf`, any resource to the profiles it claims.

## With pydantic, and other model libraries

Values are FHIR JSON, and you can give objects instead. Anything that writes itself as JSON goes
in as it is: a pydantic model (so `fhir.resources`, and models of your own), a dataclass,
`fhirclient`'s models. `model=` gives an answer back as objects.

```python
from fhir.resources.R4B.humanname import HumanName
from fhir.resources.R4B.patient import Patient

ann = Patient(id="ann", gender="female", birthDate="1980-02-28", name=[{"family": "Lee", "given": ["Ann"]}])
print(fhir.fhirpath("name.given", ann))
print(fhir.validate(ann).ok)
print(fhir.fhirpath("name", ann, model=HumanName)[0].family)

made = fhir.fsh("""
Instance: bo
InstanceOf: Patient
* birthDate = "1990-01-01"
""", model=Patient)
print(type(made[0]).__name__, made[0].birthDate.year)
```

```text
['Ann']
True
Lee
Patient 1990
```

`fhirpath`, `fhirpath_each`, `transform`, `operation` and `fsh` take `model=`. A table's rows
become objects of a model whose fields are its columns, and a search's rows the resources
behind them:

```python
import datetime
from typing import Optional
from pydantic import BaseModel

class Born(BaseModel):
    id: str
    born: Optional[datetime.date] = None

print(fhir.view("SELECT id, birthDate AS born FROM Patient", [patient]).to_models(Born))
print(fhir.search("Patient?gender=female", [patient]).resources(model=Born)[0].id)
```

```text
[Born(id='ann', born=datetime.date(1980, 2, 28))]
ann
```

pydantic checks the shape a model declares. FHIR asks more: a code its value set holds, the
rules of the base specification, whatever a profile adds. `fhir_toolkit.pydantic` runs the
toolkit's validation, and FHIRPath, where pydantic runs its own, and what is wrong is a pydantic
`ValidationError` whose `loc` is the element:

```python
from typing import Annotated
from fhir.resources.R4B.patient import Patient
from pydantic import ValidationError
from fhir_toolkit.pydantic import Holds, Valid, checked, use

use(fhir)                                   # the Toolkit these ask

class Intake(BaseModel):
    patient: Annotated[Patient, Valid(), Holds("birthDate.exists()", "a birth date is required")]
    note: str = ""

for given in ({"resourceType": "Patient", "gender": "florp", "birthDate": "1980-02-28"},
              {"resourceType": "Patient", "gender": "female"}):
    try:
        Intake(patient=given)
    except ValidationError as e:
        print([(error["loc"], error["type"]) for error in e.errors()])

# a class every object of which is held to a profile: here one written in FHIR Shorthand
Adult = checked(Patient, "Adult", project={"adult.fsh": "Profile: Adult\nParent: Patient\n* birthDate 1..1\n* name 1..*\n"})
try:
    Adult(id="cy", gender="female")
except ValidationError as e:
    print(sorted((error["loc"], error["msg"]) for error in e.errors()))
print(Adult(id="cy", birthDate="1990-01-01", name=[{"family": "Ito"}]).name[0].family)
```

```text
[(('patient', 'gender'), 'fhir_code_invalid')]
[(('patient',), 'fhir_invariant')]
[(('birthDate',), 'minimum required = 1, but found 0'), (('name',), 'minimum required = 1, but found 0')]
Ito
```

`Valid(profile)` and `checked(Model, profile)` take a canonical too, with the guide's package in
context (`Toolkit(packages=[...])`). Each check is one call of the toolkit, so in a loop over
thousands of objects use `validate_each`. An error's `loc` is where it is in the resource, inside a
datatype too (`Patient.name[0].given[1]` is `("name", 0, "given", 1)`).
`fhir_toolkit.plain(obj)` and `fhir_toolkit.typed(Model, resource)` are the two conversions.

## Many resources, and data you use more than once

A call crosses to the toolkit's process and back, so ask one question of many resources in one
call, not in a loop:

```python
patients = [patient, dict(patient, id="bo", gender="florp", name=[{"family": "Ng"}])]

print(fhir.fhirpath_each("name.family", patients))
for outcome in fhir.validate_each(patients):
    print(outcome)
```

```text
[['Lee'], ['Ng']]
valid
Patient.gender: error: code `florp` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown
```

On a machine with several cores, `Toolkit(workers=4)` answers such a list with four processes at
once, each taking a part, and puts the answers back in order: about three times quicker for
validation, for four times the memory (some 150 MB a process).

Data that several calls read is given once. `load` sends the resources (or reads the directory,
or opens the store) and answers a handle that any call takes as its `data`. Nothing is sent or
read again, and a view over it is computed once for all the SQL you ask of it.

```python
clinic = fhir.load(data)
print(clinic)
print(fhir.view("SELECT id, birthDate FROM Patient", clinic).rows)
print(fhir.sql("SELECT count(*) AS results, max(value) AS highest FROM results", project=views, data=clinic).rows)
print(fhir.search("Observation?code=4548-4", clinic).column("resource"))
clinic.close()
```

```text
Data(2 resources)
[{'birthDate': '1980-02-28', 'id': 'ann'}]
[{'highest': 9.4, 'results': 1}]
['Observation/a1']
```

## Files, warnings, and calls that take too long

A resource may be given as a dict, as JSON text, or as the path of a file that holds it:

```python
import json, pathlib, tempfile

folder = pathlib.Path(tempfile.mkdtemp())
(folder / "ann.json").write_text(json.dumps(patient))
print(fhir.fhirpath("name.family", folder / "ann.json"))
print(fhir.validate('{"resourceType": "Patient", "gender": "florp"}'))
```

```text
['Lee']
Patient.gender: error: code `florp` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown
```

When an answer was made without something in the data, the call says so with a `FhirWarning`,
raised at your line like any Python warning. Here a time has no time zone, which FHIR requires,
so the view has no value for it; the table keeps the sentence as its `notes`. A map says the same
of a value in its source that it could not read.

```python
import warnings
from fhir_toolkit import FhirWarning

reading = {"resourceType": "Observation", "id": "w1", "status": "final", "code": {"text": "weight"},
           "effectiveDateTime": "2025-03-01T08:00:00"}
with warnings.catch_warnings(record=True) as said:
    warnings.simplefilter("always")
    table = fhir.view("SELECT id, effective.ofType(dateTime) AS at FROM Observation", [reading])
print(table.rows)
print(said[0].category.__name__ + ":", said[0].message)
print(table.notes == [str(said[0].message)])
```

```text
[{'at': None, 'id': 'w1'}]
FhirWarning: 1 of 1 Observation resources holds a value at `effectiveDateTime` that is not valid FHIR and was not read (the first: Observation/w1: "2025-03-01T08:00:00" — a time needs a time zone, such as Z or +01:00)
True
```

`warnings.simplefilter("error", FhirWarning)` makes such data an error, for a program that
wants none of it.

A table goes where tables go: `to_pandas()`, `to_polars()`, or CSV as text (or to a file, given
a path):

```python
print(fhir.view("SELECT id, name.given AS given, birthDate AS born FROM Patient", [patient]).to_csv(), end="")
```

```text
id,given,born
ann,Ann,1980-02-28
```

`Toolkit(timeout=30)` gives every call 30 seconds. A call that takes longer, or that you
interrupt (Ctrl-C, a notebook's stop button), stops the toolkit's process: the call raises, the
next call starts a new process, and data you loaded is loaded again by itself. Nothing an
interrupted call was computing is ever taken for a later call's answer.

## Beside other FHIR libraries for Python

Most Python libraries for FHIR do one thing: `fhirpathpy` evaluates FHIRPath, `fhir.resources`
gives each resource a class and checks its shape. The other standard tools are programs in other
runtimes that a Python program starts as a process: HL7's validator (Java), SUSHI and GoFSH for
FHIR Shorthand (Node), the CQL translator and engines (Java, JavaScript), the mapping engine
(Java). This package is one install, and each row below is a method on one object:

| | fhir-toolkit | fhirpathpy | fhir.resources |
|---|---|---|---|
| FHIRPath | yes | yes | — |
| check a resource against the base specification | yes: shape, codes, rules | — | shape |
| check it against the profiles of an implementation guide | yes | — | — |
| value sets: expand, check a code, look one up | yes | — | — |
| FHIR Shorthand: profiles and data from text, and back | yes | — | — |
| CQL: translate to ELM, and run over patients | yes | — | — |
| mapping language: convert one shape to another | yes | — | — |
| SQL on FHIR views, and SQL over them | yes | — | — |
| FHIR search over data in memory, a folder or a store | yes | — | — |
| a store that records who wrote what, and why | yes | — | — |
| a class for each resource type | no: values are JSON; it takes theirs | — | yes |

**How much of FHIRPath.** HL7 publishes a test suite for FHIRPath: 934 expressions over
resources, each with the answer it must give. This toolkit gives 932 of them, compared with their
types. `fhirpathpy` 2.2.4, asked the same expressions and counted right whenever its values equal
the expected ones whatever their type, gives 788; of the rest, 102 raise an error (`lowBoundary`,
`highBoundary`, `sort`, `matchesFull`, `precision` are not implemented there).
`racket bench/fhirpath-suite.rkt` is that count as a program.

**What a check catches.** One published US Core example, changed in one way, eight ways
(`python bench/validation.py`):

| one published example, with | fhir-toolkit | fhir.resources | HL7's validator (Java) |
|---|---|---|---|
| a code its required value set does not hold (`gender: florp`) | refused | accepted | refused |
| a day the calendar lacks (`birthDate: 1980-02-30`) | refused | refused | refused |
| an element the type does not have (`nmae`) | refused | refused | refused |
| a value of another type (`active: "yes"`) | refused | accepted | refused |
| an element the base type requires, left out (an Observation's `status`) | refused | refused | refused |
| a rule of the base specification broken (a contact with no name, address or telecom) | refused | accepted | refused |
| an element the profile requires, left out (a US Core Patient's `name`) | refused | accepted | refused |
| a code the profile fixes, changed (a blood pressure's `code`) | refused | accepted | refused |

The toolkit decides as HL7's validator does on all eight. On a larger set — 741 changed copies of
US Core examples, each judged by HL7's validator — the two agree on 740, and the toolkit refuses
nothing that HL7's passes.

**What a check costs.** The 230 examples US Core 9.0.0 publishes, each held to the profiles it
claims, from nothing to an answer for every one:

| checked by | against | the whole run | a resource, once running | passed |
|---|---|---|---|---|
| fhir-toolkit | the base specification and US Core's profiles | 2.1 s | 1.2 ms | 230 of 230 |
| HL7's validator (Java), as a process | the same | 49 s | 35 ms | 230 of 230 |
| fhir.resources | the base specification's shape | 0.4 s | 1.8 ms | 230 of 230 |

(HL7's validator spends most of its run loading the guide; the time for a resource is its own
account of validating. Its first run on a machine, which fills its package cache, took 79 s
here. Versions: fhirpathpy 2.2.4, fhir.resources 8.3.0, HL7's validator_cli as downloaded in
November 2026, with its terminology server off, as the toolkit's checks are offline.)

## How fast it is

The toolkit is a compiled program in a process of its own. Work done inside one call is quick;
each call also pays for crossing to that process and back (about 0.1 ms). So one call over many
resources beats a loop of calls, and data you use twice is worth loading once.

`python bench/compare.py` times it beside two pure-Python libraries. On the machine this was
written on (medians; 5,000 resources where it says many):

| task | fhir-toolkit | fhirpathpy | fhir.resources |
|---|---|---|---|
| making a `Toolkit`; then its first answer | 4 ms; 0.72 s | no start | no start |
| a new `Toolkit`'s first validation | 1.1 s | no start | no start |
| one FHIRPath expression, one Patient | 0.15 ms | 0.050 ms | — |
| the same expression over 5,000 Patients | 68 ms (one call) | 227 ms (a loop) | — |
| validate one Patient | 0.22 ms | — | 0.034 ms |
| validate 5,000 Patients | 417 ms (one call) | — | 195 ms (a loop) |
| …with `Toolkit(workers=4)` | 100 ms (one call) | — | — |
| …the Patients given as `fhir.resources` objects | 673 ms (one call) | — | 266 ms (writing them as JSON) |
| one value from each of 5,000 Observations | 152 ms (a view) | 54 ms (a loop) | 343 ms (a loop) |
| the same, the data loaded once | 85 ms (a view) | — | — |
| that view asked again | 7 ms | — | — |
| a SQL aggregate over that view, data loaded | 1.4 ms | — | — |

Read a row as what the task costs each way, not as one engine against another: they do not do
the same work. `fhirpathpy` is timed with its expression compiled once, walking Python dicts.
`fhir.resources` checks that the data has the right shape; the toolkit's validation also checks
codes against their value sets and the rules of profiles (it refuses `"gender": "florp"`, which
`fhir.resources` accepts). An object costs what its library takes to write it as JSON: about
0.05 ms each for `fhir.resources`, which is most of that row; a plain pydantic model writes
itself in a thousandth of a millisecond, and its text goes into the call as it is. The machine
these were taken on varies by about a fifth from run to run.

The first call of each kind loads what only it needs. Counted from the start of a new process,
a first FHIRPath answer comes after about 0.7 s, a first validation after 0.9 s, a first view
after 1.3 s and a first CQL run after 2 s. The process does that loading by itself whenever
nobody is asking, so after a few idle seconds (a notebook between cells, a program reading its
input) each first call takes milliseconds.

Those starting times are from a source checkout. The executable a wheel carries reads all of
its code when it starts, which adds about 0.6 s: built on the same machine it gave a first
FHIRPath answer after 1.2 s and a first validation after 1.5 s. Everything after the start is
the same.

Validation reads FHIR's own definitions from the core package. The first time that happens on a
machine the toolkit unpacks them into your cache directory (27 MB for FHIR R4, about a second
more, once); later processes read from there. `FHIR_CACHE_DIR` names another directory, and
`FHIR_PACKAGE_CACHE=0` keeps the definitions in memory and writes nothing.

The real cost of validating is the resource, not the call: a small Patient takes 0.05 ms inside
the toolkit, a US Core example with its narrative and profile about 0.6 ms.

## In a notebook

`%load_ext fhir_toolkit.jupyter` adds a cell magic for each language. What a cell defines stays
for the cells after it, so a profile written in one cell is what a later cell validates against,
and a view written in one is a table the next joins.

```ipython
%load_ext fhir_toolkit.jupyter
people = [patient, a1c]
```

```ipython
%%fsh
Profile: AdultPatient
Parent: Patient
* birthDate 1..1

Instance: cy
InstanceOf: AdultPatient
* gender = #male
```

```text
AdultPatient.fsh:5:1: error: instance cy: Patient.birthDate: minimum required = 1, but found 0 (no rule of cy writes `birthDate`) (constrained by profile AdultPatient at line 3)
```

The mistake is said at its line in the cell (the cell is kept under the name of the first thing
it defines). A view's rows come back as a DataFrame:

```ipython
%%sof -d people
CREATE VIEW a1c WITH (status = 'active') AS
SELECT subject.getReferenceKey(Patient) AS patient, value.ofType(Quantity).value AS percent
FROM Observation
```

```text
  patient  percent
0     ann      9.4
```

| cell | what it does |
|---|---|
| `%%fsh` | compiles FHIR Shorthand and validates its examples |
| `%%cql -d data` | runs a CQL library over the data: a row a patient, a column a define |
| `%%sof -d data` | a view's rows; `CREATE VIEW name …` keeps it as a table |
| `%%fhir_sql -d data` | SQL over the views the notebook has defined |
| `%%fhirpath -d resource` | FHIRPath over one resource, an expression a line |
| `%%vcl` | a value set's codes; `-n name` keeps it for CQL and bindings |
| `%%fml -d resource` | applies a map |
| `%fhir` | lists what the notebook has defined; `%fhir reset` forgets it |

`-o name` keeps a cell's answer in a variable, and `-d` takes loaded data as well
(`clinic = notebook.toolkit.load(resources)`). From Python cells the same state is
`fhir_toolkit.jupyter.notebook` (`.toolkit`, `.project`). A `Table` and a validation's `Outcome`
show themselves as HTML in a notebook, with or without pandas.

## What is where

| you have | call |
|---|---|
| one resource and a question | `fhirpath(expression, resource)` |
| many resources and a question | `fhirpath_each(expression, resources)`, or a view |
| a resource to check | `validate(resource, profile=None, project=None)` |
| many resources to check | `validate_each(resources, profile=None, project=None)` |
| data several calls read | `clinic = load(resources_or_place)`, then `data=clinic` |
| FSH | `fsh(text)` gives resources; `decompile(resource)` gives FSH back |
| a CQL library | `cql(text, data)` runs it; `translate(text)` gives ELM |
| a view | `view(text, data)`; `sql(statement, project=views, data=data)` |
| a map | `transform(map, source)` |
| a value set | `expand(url_or_vcl)` |
| a FHIR search | `search("Observation?code=4548-4", data)` |
| any FHIR operation | `operation("$expand", inputs={...})` |
| resources to store | `write(resources, data=store, reason=…)`; `stage(…)` then `.commit(reason)` |
| pydantic models | give them as resources; `model=` for answers; `Valid`, `Holds`, `checked` from `fhir_toolkit.pydantic` |
| several files in several languages | `compile(project)`, `check(project)`, `run(path, project=…, data=…)`, `explain(…)` |

A resource is a dict, an object of a model library, JSON text, or the path of a JSON file.
A `Table` has `.rows`, `.columns`, `.notes`, `.column(name)`, `.to_pandas()`, `.to_polars()`,
`.to_csv()`, `.to_models(Model)` and, for a search, `.resources(model=None)`.

`fhir.raw` has every function exactly as the toolkit defines it, answering plain JSON.

## Limits

- The toolkit has no resource classes of its own: values are JSON, and objects of a model
  library are converted at the edge (above). It does not generate pydantic classes from a
  profile: a profile is enforced when an object is checked (`fhir_toolkit.pydantic`).
- `write` and `stage` write to a SQLite store or a directory of FHIR JSON, not to a FHIR
  server.
- A `Toolkit` reads one version of FHIR: `Toolkit("5.0.0")` is a second process for R5. R4
  (4.0.1) is the default.
- Numbers pass through JSON, so a decimal written `1.50` arrives as `1.5`.
- A wheel carries the FHIR R4 and R5 core packages. An implementation guide is given by its
  package file: `Toolkit(packages=["hl7.fhir.us.core-6.1.0.tgz"])`.

## From a source checkout

Without a wheel, the package starts the toolkit it finds: the `FHIR_API_COMMAND` environment
variable, `fhir-api` on the PATH, or `raco fhir-api` when Racket and the toolkit's packages are
installed ([how](https://github.com/oloveluck/fhir#install-from-source)).

The toolkit is [oloveluck/fhir](https://github.com/oloveluck/fhir); this package is its
`clients/python`.
