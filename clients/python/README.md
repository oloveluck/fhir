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

Calls go to one process that starts at the first call (about a second) and answers the ones
after it in milliseconds.

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

## What is where

| you have | call |
|---|---|
| one resource and a question | `fhirpath(expression, resource)` |
| a resource to check | `validate(resource, profile=None, project=None)` |
| FSH | `fsh(text)` gives resources; `decompile(resource)` gives FSH back |
| a CQL library | `cql(text, data)` runs it; `translate(text)` gives ELM |
| a view | `view(text, data)`; `sql(statement, project=views, data=data)` |
| a map | `transform(map, source)` |
| a value set | `expand(url_or_vcl)` |
| a FHIR search | `search("Observation?code=4548-4", data)` |
| any FHIR operation | `operation("$expand", inputs={...})` |
| several files in several languages | `compile(project)`, `check(project)`, `run(path, project=…, data=…)`, `explain(…)` |

`fhir.raw` has every function exactly as the toolkit defines it, answering plain JSON.

## Limits

- Values are JSON: a resource is a `dict`, not a typed object. Use them with the models you
  already have (`fhir.resources`' `model_validate(...)` reads them).
- A `Toolkit` reads one version of FHIR: `Toolkit("5.0.0")` is a second process for R5. R4
  (4.0.1) is the default.
- Numbers pass through JSON, so a decimal written `1.50` arrives as `1.5`.
- A wheel carries the FHIR R4 and R5 core packages. An implementation guide is given by its
  package file: `Toolkit(packages=["hl7.fhir.us.core-6.1.0.tgz"])`.
- Writing to a store with a recorded trail (stage, commit, Provenance) is the toolkit's
  workspace, which this package does not wrap yet.

## From a source checkout

Without a wheel, the package starts the toolkit it finds: the `FHIR_API_COMMAND` environment
variable, `fhir-api` on the PATH, or `raco fhir-api` when Racket and the toolkit's packages are
installed ([how](https://github.com/oloveluck/fhir#install-from-source)).

The toolkit is [oloveluck/fhir](https://github.com/oloveluck/fhir); this package is its
`clients/python`.
