# The FHIR workspace

You work in a directory of source files. Each file is a program in one of the FHIR languages, or a FHIR
resource as JSON. The tools check them, run them against FHIR data, and explain the answers. Every
problem is one line, at its file, line and column: `Gap.cql:4:1 error: in define "Gap": unknown identifier 'Nope'`.

To start a new workspace from a shell: `raco fhir-mcp init [dir]` writes `workspace.yaml` (with
`data: fhir.db`, a SQLite FHIR store created on first use), a `.mcp.json` that registers this
server, a `CLAUDE.md` that points here and a `.gitignore`. It never overwrites a file.

**Find your task** (each a section below, with a tested recipe):
- store data, with who and why: "The data", then "The trail" (`stage` → `commit reason=… agent=…`)
- a rule the data must keep, and its refusal: "Constraints" ("Rules cookbook"; the blood-pressure rule)
- a table: "Analysis" — a CQL run in one call, `run path=X.cql as=csv columns="Name,Latest Number"`;
  a view and SQL for anything grouped or joined
- fix a stored value and show its history: "Correcting a stored resource", then "The trail"
- where each stored value came from: `describe ref=Observation as=trail` ("The trail")
- from a shell, many steps: `raco fhir-mcp batch -` (one process; "The tools")

| File | Language | `run` gives | Guide |
|---|---|---|---|
| `*.fsh` | FHIR Shorthand: profiles, extensions, value sets, code systems, example instances | the resources the file defines, each example validated | `learn://fsh` |
| `*.cql` | Clinical Quality Language: patient logic, cohorts, measures | every define's value for every patient | `learn://cql` |
| `*.fhirpath` | one FHIRPath expression | its value over each resource it reads | `learn://fhirpath` |
| `*.vcl` | one ValueSet Compose Language expression | the value set's expansion | `learn://vcl` |
| `*.map`, `*.fml` | FHIR Mapping Language | each source resource transformed, the result validated | `learn://fml` |
| `*.view.json` | a SQL on FHIR ViewDefinition | its rows | `learn://sql-on-fhir` |
| `*.capability.rkt` | a FHIR server (`#lang fhir/capability`): resources, interactions, search parameters, operations | the server, started over the workspace's store; its url | `learn://capability` |
| `*.json` | any FHIR resource | a Measure is evaluated; anything else validated | — |

What one file defines, every other file sees by canonical. A VCL file `hba1c.vcl` is the ValueSet
`<canonical>/ValueSet/hba1c`, and a CQL library uses it as `valueset "HbA1c": '<that url>'`.
Examples validate against the profiles the FSH defines.

## The tools
- `write(path, text)` saves a file and answers its problems in the same call.
- `check()` checks every file. `check(paths)` checks the files you name.
- `run(path)` runs a file against the data. It answers a summary, the first rows and a handle
  (`result://r1`). Narrow it with `entry` (one CQL define), `over` (`Patient/123`, or a type) and
  `parameters` (CQL expressions by name).
- `query(language, text)` asks once without saving a file: a FHIRPath or CQL expression, a FHIR
  search (`Observation?code=http://loinc.org|4548-4`, over files too: `learn://search`), a VCL
  expression, a ViewDefinition, or SQL (below).
- `explain(ref, subject)` (`ref` a result such as `result://r1`, or a file) says why the answer for
  one subject is what it is: CQL define by define down to the retrieves, FHIRPath part by part, a
  view's `where` clauses, a map's rules, an FSH instance's problems.
- `describe(ref)` reads anything by reference: `result://r1` (paged with offset/limit, or compared
  with `against`), `Patient/123`, a canonical url, a type or element (`Observation.component`), an
  operation (`$expand`), or a fragment of a definition's name. `describe("result://r1", as: "csv")`
  answers a result's rows as CSV, the compact form of a table (`columns: "Name,Latest Number"` keeps
  those, in that order); `run` and `query` take the same `as: "csv"` and `columns`, so a CQL run's
  table is one call. `describe(ref, as: "fsh")` answers a
  resource as an FSH Instance: a line per coding, quantity or reference, a third shorter than its JSON
  for coded data (compact JSON is as short for a small resource of plain values).
- `apply(operation, inputs)` applies any FHIR operation the server implements. `describe("$code")`
  lists its inputs.
- `stage(...)` and `commit(stage)` write to the data. Staged resources are validated and shown as a
  diff first. A stage with errors is not committed. A FHIR server is written only when
  `workspace.yaml` allows it. Stage `resources` (JSON), a file (`path`), a run's output (`result`), or
  FSH Instances written in the call (`fsh`). FSH is the compact way to state data: one line per
  coding, quantity or reference.

```fsh
Instance: a1c-ann
InstanceOf: Observation
* status = #final
* code = http://loinc.org#4548-4 "Hemoglobin A1c"
* subject = Reference(Patient/ann)
* effectiveDateTime = "2025-07-01"
* valueQuantity = 6.2 '%'
```

  FSH that does not compile is refused, each error at its line in the text: an `InstanceOf: Observaton`
  answers `fsh:1:1 error: … InstanceOf … not found … (did you mean …?)`, naming both.
  A resource whose type FHIR does not define is an error, not an unknown.

## Analysis: views, then SQL
A ViewDefinition (`*.view.json`) turns resources into a table, one row per resource (or per
repetition, with `forEach`). `query("sql", "SELECT …")` then asks SQLite over those tables: each view
by its file name or `name`, and each earlier result by its name and its number, so a CQL run's
answer per patient joins with a view's columns. A run is named by its file (`diabetes.cql` ->
`diabetes`), a query by the `name` it is given; a name is the LATEST result of that name, so SQL
kept in a file (`FROM diabetes`) reads the newest run, where `r3` is always the same result
(`describe("result://diabetes")` reads it too). A view's name wins over a result's. A view is
computed when a statement names it (no `run` first), from the current data; `<view>_history` (`bp_history`)
is the same view over EVERY stored version, so a corrected value is a row of its own — give the view a
`{"name": "version", "path": "meta.versionId"}` column to tell them apart. One reading statement; a column holding a list or
an object (a CQL Quantity, a Coding) is its JSON text — `json_each` walks a list, `->>` reads a value
(`r3."Latest Value" ->> '$.value'`); a boolean is 1/0 in SQL (a CQL result's own CSV says
true/false); a name with a space is quoted (`r3."Poor Control"`); null is NULL.

With two views — `bp.view.json`, one row per blood pressure, and `patients.view.json` (`id`,
`gender`) —

```json
{"resourceType": "ViewDefinition", "name": "bp", "status": "active", "resource": "Observation",
 "where": [{"path": "code.coding.exists(system = 'http://loinc.org' and code = '85354-9')"}],
 "select": [{"column": [
   {"name": "id", "path": "id"},
   {"name": "version", "path": "meta.versionId"},
   {"name": "patient", "path": "subject.getReferenceKey(Patient)"},
   {"name": "date", "path": "effective.ofType(dateTime)"},
   {"name": "systolic", "path": "component.where(code.coding.exists(code = '8480-6')).value.ofType(Quantity).value.first()"},
   {"name": "diastolic", "path": "component.where(code.coding.exists(code = '8462-4')).value.ofType(Quantity).value.first()"}]}]}
```
a summary per patient — readings, means, and whether the mean is at or above 140/90 — is

```
SELECT patient, count(*) AS readings, printf('%.1f', avg(systolic)) AS mean_systolic,
       printf('%.1f', avg(diastolic)) AS mean_diastolic,
       CASE WHEN avg(systolic) >= 140 OR avg(diastolic) >= 90 THEN 'yes' ELSE 'no' END AS at_or_above_140_90
FROM bp GROUP BY patient ORDER BY patient
```
(`printf('%.1f', …)` writes a mean as a person reads it, `140.0`, where `round(…, 1)` gives a number
that may print as `140` or `139.66666666666666`; `bp_history` is the same view over every stored
version, for a reading's corrections), and the mean
systolic by gender is

```
SELECT p.gender, count(*) AS n, printf('%.1f', avg(b.systolic)) AS mean_systolic
FROM bp b JOIN patients p ON p.id = b.patient GROUP BY p.gender
```
and a classification by a patient's mean (`HAVING avg(b.systolic) >= 140` keeps those whose mean is
high, not those with one high reading). "At or above 140/90" is read clinically as systolic ≥ 140
OR diastolic ≥ 90 (`CASE WHEN avg(b.systolic) >= 140 OR avg(b.diastolic) >= 90 THEN 'yes' ELSE
'no' END`). The view's `.first()` makes each column one value: a column whose path finds two
(two systolic components) is an error when the view runs, and `.first()` says which to keep.

## Which language for which question
- A value inside one resource: FHIRPath.
- A fact about a patient, or a cohort: CQL.
- A table or a count across a population: a ViewDefinition, then SQL.
- A set of codes: VCL.
- What valid data looks like (a profile, an example): FSH.
- Converting data from one structure to another: FML.
- A FHIR server with your own operations: a capability app.

## workspace.yaml
```yaml
fhirVersion: 4.0.1                 # or 5.0.0; every language follows it (CQL's model is 4.0.1)
canonical: http://example.org/fhir # the base of what the workspace defines
packages:                          # FHIR packages in context, by file or name
  - hl7.fhir.us.core-6.1.0
data: fhir.db                      # a SQLite FHIR store (resources as JSONB); or a directory, a JSON file, a FHIR server's url
parameters:                        # CQL parameters, as CQL expressions
  Measurement Period: Interval[@2025-01-01T00:00:00.000, @2025-12-31T23:59:59.999]
allowRemoteWrites: false           # commit may write to the server only when true
models:                            # data models made from the workspace's FSH logical models
  Clinic: http://example.org/fhir patient=Member birthDate=born version=1.0
```
`models` lets CQL query a model you design here: `using Clinic version '1.0'`. learn://cql explains it.
A server that needs a token reads it from the environment variable `FHIR_AUTHORIZATION`, which holds
the whole header value (`Bearer …`). It is never kept in a file.

## The data
`data: fhir.db` (what `fhir-mcp init` writes) is a SQLite FHIR store, created on first use: every
resource as JSONB with its versions and the search indexes FHIR's search parameters define. Only
`commit` writes it (one transaction per stage; a resource with an id keeps it); every language,
FHIR search and SQL read it; a capability app the workspace runs serves it. In SQL each stored type
is a table of `id`, `versionId`, `lastUpdated` and `resource` (JSONB: `resource ->> '$.birthDate'`,
`json_each(resource, '$.name')`), beside the views and earlier results; `resources` is every type at
once (`type, id, versionId, lastUpdated, resource`), `history` every version (the same columns), and
`trail` the commits (below). A column SQLite does not know is answered with the nearest and each
named table's columns. Import FHIR JSON with
`raco fhir-server load fhir.db <dir|bundle.json>`.

## Constraints
A rule about the data is a FHIR profile: write it in FSH (cardinalities, fixed codes, bindings,
FHIRPath invariants for the complex ones) and name it in workspace.yaml — `write(path, text,
enforce: true)` (shell: `enforce:=true`) adds the file's profiles there for you:

```yaml
profiles:
  Observation: http://example.org/fhir/StructureDefinition/a1c
```

Every staged resource of that type is validated against it and claims it in `meta.profile`; a
stage that breaks it lists the broken rule per resource and cannot be committed. `check` holds the
workspace's FSH examples to it too, and `check(data: true)` everything already stored: how many
resources (`byType`, the trail's own Provenances and AuditEvents among them), how many break a rule, the rules by how often they are broken, the first problems as lines.

A stage is all or nothing: one invalid resource refuses the whole stage, so nothing is half-written.
To keep the valid ones, drop the stage, take the refused resources out of the text (each problem
names its line) and stage again; stage a batch apart when some of it may be refused.

Many readings of one shape are one parameterized RuleSet and one line each (the commit's source
keeps every line, and each version's `at` names the line that wrote it):

```fsh
RuleSet: Reading(id, patient, date, sys, dia)
* code = http://loinc.org#85354-9 "Blood pressure panel"
* status = #final
* subject = Reference(Patient/{patient})
* effectiveDateTime = "{date}"
* component[0].code = http://loinc.org#8480-6
* component[0].valueQuantity = {sys} 'mm[Hg]'
* component[1].code = http://loinc.org#8462-4
* component[1].valueQuantity = {dia} 'mm[Hg]'
```
with, per reading, `Instance: bp-a1` / `InstanceOf: Observation` / `* insert Reading(bp-a1, a,
2025-01-10, 142, 91)`.

Keep DATA out of the workspace's `.fsh` files: they are the project (profiles, value sets, a few
examples), and every one of them is compiled and checked together, so a patient written there twice
is a duplicate id. Data goes in through `stage(fsh: "…")`, the text in the call (from the shell,
`raco fhir-mcp call stage fsh=@../batch.fsh` reads a file kept outside the workspace), then `commit`.

A rule for SOME resources of a type — blood pressures among all Observations — is an invariant that
applies only to them, written with `implies`; one invariant per requirement, so a refusal says which
one a reading broke:

```fsh
Profile: BloodPressureRule
Parent: Observation
Id: bp-rule
* obeys bp-subject and bp-systolic and bp-diastolic

Invariant: bp-subject
Description: "A blood pressure (LOINC 85354-9) has a subject"
Severity: #error
Expression: "code.coding.where(system = 'http://loinc.org' and code = '85354-9').exists() implies subject.exists()"

Invariant: bp-systolic
Description: "A blood pressure (LOINC 85354-9) has a systolic component (LOINC 8480-6) in mm[Hg]"
Severity: #error
Expression: "code.coding.where(system = 'http://loinc.org' and code = '85354-9').exists() implies (component.where(code.coding.where(system = 'http://loinc.org' and code = '8480-6').exists()).exists() and component.where(code.coding.where(system = 'http://loinc.org' and code = '8480-6').exists()).all(value.ofType(Quantity).where(system = 'http://unitsofmeasure.org' and code = 'mm[Hg]').exists()))"

Invariant: bp-diastolic
Description: "A blood pressure (LOINC 85354-9) has a diastolic component (LOINC 8462-4) in mm[Hg]"
Severity: #error
Expression: "code.coding.where(system = 'http://loinc.org' and code = '85354-9').exists() implies (component.where(code.coding.where(system = 'http://loinc.org' and code = '8462-4').exists()).exists() and component.where(code.coding.where(system = 'http://loinc.org' and code = '8462-4').exists()).all(value.ofType(Quantity).where(system = 'http://unitsofmeasure.org' and code = 'mm[Hg]').exists()))"
```

Named for `Observation` in `profiles`, it holds every blood pressure to the rule and lets every other
Observation through. `X.exists() and X.all(…)` says "there is one, and EVERY one is in mm[Hg]": with
`X.where(…).exists()` alone, a second systolic in kPa beside one in mm[Hg] would pass. A refusal quotes the rule's `Description` and what the rule found, at the rule that wrote it:
`fsh:7: Observation: hr-range: A heart rate (LOINC 8867-4) is between 20 and 250 /min (found
valueQuantity = 300 '/min')` — line 7 is the instance's `* valueQuantity = 300 '/min'`. "Found"
follows the rule: what the part after `implies` tests, the item of an `all(…)` that fails it by
its index (`found component[0].valueQuantity = 20 'kPa'`), or what is missing (`found no
component matching '8462-4'`, at the instance's first line);
write the description as the fix the author needs.

### Rules cookbook
Each rule is an invariant on a profile named in `profiles`; `X implies Y` keeps it to the resources
it is about. Write the FHIRPath in FSH's `Expression:`, the fix in `Description:`.

```fsh
Profile: VitalsRules
Parent: Observation
Id: vitals-rules
* obeys hr-range and hr-unit and not-future

Invariant: hr-range
Description: "A heart rate (LOINC 8867-4) is between 20 and 250 /min"
Severity: #error
Expression: "code.coding.where(system = 'http://loinc.org' and code = '8867-4').exists() implies value.ofType(Quantity).where(value >= 20 and value <= 250).exists()"

Invariant: hr-unit
Description: "A heart rate (LOINC 8867-4) is in /min (UCUM)"
Severity: #error
Expression: "code.coding.where(system = 'http://loinc.org' and code = '8867-4').exists() implies value.ofType(Quantity).where(system = 'http://unitsofmeasure.org' and code = '/min').exists()"

Invariant: not-future
Description: "An observation is not dated in the future"
Severity: #error
Expression: "effective.ofType(dateTime).exists() implies effective.ofType(dateTime) <= now()"
```

- a value in a range: `value.ofType(Quantity).where(value >= lo and value <= hi).exists()`;
- a unit: `value.ofType(Quantity).where(system = 'http://unitsofmeasure.org' and code = 'u').exists()`;
- a required part: `component.where(code.coding.where(system = … and code = …).exists()).exists()`
  (the blood-pressure rule above);
- not in the future: `effective.ofType(dateTime) <= now()`;
- a code from a value set: no invariant — bind it in FSH, `* code from <ValueSet> (required)`;
- required elements and fixed values: no invariant either — `* subject 1..1`, `* status = #final`.

Check an expression on stored data before making it a rule: `query("fhirpath", "<expression>", over:
"Observation")` answers it per resource.

### Correcting a stored resource
`describe("Observation/bp-a1", as: "fsh")` answers the resource as an FSH Instance; change the line
that is wrong and stage the whole text again — the stage shows the change (`… 150 → 140`) and the
commit writes version 2 with its reason. The file goes beside the workspace, as data files do (a
`.fsh` file in the workspace is part of its project, checked with the rules). The Instance is
written from the stored JSON, so its rules come in element-name order with explicit indexes
(`category[0]`), not as first written: find the line by its path before editing.
`describe("Observation/bp-a1", as: "source")` gives the Instance as it was written, if you would
rather edit that:
```
raco fhir-mcp call describe ref=Observation/bp-a1 as=fsh > ../bp-a1.fsh     # edit it
raco fhir-mcp call stage fsh=@../bp-a1.fsh
raco fhir-mcp call commit stage=latest reason="typo: systolic 150 should have been 140"
```

## The trail
Every commit writes, into the data itself, a Provenance — the versions it wrote
(`Observation/a1/_history/2`, also in commit's answer), when, the agent (the MCP client, or
commit's `agent`), the `reason` given to commit, and
the source the data came from (the FSH, the file, or the run, with its text and SHA-1) — and an
AuditEvent of the transaction. With `audit: all`, every run, query and apply leaves an AuditEvent
too (its outcome, its text). The trail is data like any other:
- `describe("Observation", as: "trail")`: every stored Observation at its current version, with
  `id, subject, name` (the patient's), `value` (a value[x], else the components in order: `142 mm[Hg] /
  91 mm[Hg]`), `date`, then `versionId, recorded, agent, reason, source, at, provenance`, as CSV —
  "where did each value come from" in one call; `columns="id,name,value,at"` and `sort="-date"` as for
  any table; `describe("Observation/a1/_history", as: "trail")` (or `as: "csv"`) is the same for every
  version of one resource, newest first (the SQL below is the same join, for anything more);
- `describe("Observation/a1/_history")`: every version, newest first, what changed since the one
  before (`valueQuantity.value: 8.0 → 8.4`), and who wrote it (`agent`), when (`recorded`), why
  (`reason`), from what (`source`, `sha1`) and where (`at`) — the same names as SQL's `trail`. `at` is
  the line that made the version: for a create, the line its Instance begins at
  (`"at": "patients.fsh:33"`); for a correction, the rule it changed (`"at": "../bp-a1.fsh:6"`);
- `describe("Observation/a1", as: "source")`: the FSH Instance that wrote the resource's newest version,
  alone; `describe("Provenance/<id>", as: "source")`: the whole text the commit was made from (the
  FSH file), decoded;
- `query("search", "Provenance?target=Observation/a1")`;
- SQL: `trail` — one row per version a commit wrote (`type, id, versionId, recorded, agent, reason,
  source, sha1, at, provenance`; `versionId` an integer, the rest text; `recorded` is when the commit
  wrote it, not when the fact happened; `source` the file and `sha1` its text's SHA-1 (all 40 hex digits, as `sha1sum` prints it); `at` the file and line the version
  was written from, `../src/a1c.fsh:12`, file names relative to the workspace), so "where did every
  lab value come from" is
  `SELECT * FROM trail WHERE type = 'Observation'`; and `history` (every version of every resource),
  `Provenance`, `AuditEvent` for anything else. `trail` holds no values: join it with `history` on
  type, id and version for them, e.g. each version of a1 with its value and why it was written:

```
SELECT t.versionId, h.resource ->> '$.valueQuantity.value' AS value, t.reason, t.agent, t.recorded
FROM trail t JOIN history h ON h.type = t.type AND h.id = t.id AND h.versionId = t.versionId
WHERE t.type = 'Observation' AND t.id = 'a1' ORDER BY t.versionId
```

Each stored value with where it came from — the question an audit asks — is the type's table joined
to `trail` on its current version:

```
SELECT o.id, o.resource ->> '$.valueQuantity.value' AS value, o.resource ->> '$.effectiveDateTime' AS taken,
       t.recorded, t.agent, t.reason, t.source
FROM Observation o JOIN trail t ON t.type = 'Observation' AND t.id = o.id AND t.versionId = o.versionId
ORDER BY o.id
```

A view's history (`<view>_history`) joins the trail the same way; a view column read from
`meta.versionId` is text, so cast it (`trail.versionId` is an integer) — every version of each
reading with its value and why it was written:

```
SELECT v.id, CAST(v.version AS INTEGER) AS version, v.value, t.reason, t.at
FROM a1c_history v JOIN trail t ON t.type = 'Observation' AND t.id = v.id AND t.versionId = CAST(v.version AS INTEGER)
ORDER BY v.id, version
```

The trail says when and by whom the DATA was written, not the clinical facts: a lab value's own time
is its `effectiveDateTime` (and `issued`), and who produced it is its own `performer` — write them
in the FSH (`* performer = Reference(Organization/city-lab)`, `* issued = "2025-06-02T10:00:00Z"`),
where search, CQL and views see them. The trail's `source` is the file the data was written from
(named relative to the workspace, or in full when outside it).

A Provenance written by a commit, for SQL (`p.resource ->> '$.<path>'`): `target[n].reference`
(`Type/id/_history/v`), `recorded`, `agent[0].who.display` (the client: `claude-code … via fhir-mcp`,
`raco fhir-mcp call`, `FHIR_MCP_AGENT`, or commit's `agent`; an agent written as a reference —
`agent="Practitioner/dr-ng"` — is `agent[0].who.reference`, and `trail.agent` reads either), `reason[0].text` (commit's `reason`),
`activity.coding[0].code` (`CREATE` or `UPDATE` when all are one), `entity[0].what.display` (the source
in one line, with its SHA-1) and `contained[0]` (a DocumentReference holding the source text:
`content[0].attachment.data`, base64, and `.hash`). An AuditEvent: `action` (`C`, `U`, `E`),
`recorded`, `outcome` (`0` success, `8` failure; R5 `outcome.code.code`), `agent[0].who.display`,
`entity[n].what`.

`describe(result)` names where a result came from: the file or query (`text=@table.sql` keeps the
file's name), its SHA-1, the options, the earlier results a SQL query read (`reads: ["result://r1"]`)
and the data as of its latest write.

A stage warns (without refusing) about a reference to a resource that is neither in the data nor in
the stage (`subject: Patient/pat-a is neither in the data nor in this stage`): a typo in an id, or
data that comes in a later stage. A commit answers the `agent` its Provenance names.

## The loop
Write a file, read its problems, fix them at their lines, then run it. When an answer surprises you,
explain it for one subject before you change anything.
