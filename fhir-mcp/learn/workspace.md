# The FHIR workspace

You work in a directory of source files. Each file is a program in one of the FHIR languages, or a FHIR
resource as JSON. The tools check them, run them against FHIR data, and explain the answers. Every
problem is one line, at its file, line and column: `Gap.cql:4:1 error: in define "Gap": unknown identifier 'Nope'`.

To start a new workspace from a shell: `raco fhir-mcp init [dir]` writes `workspace.yaml` (with
`data: fhir.db`, a SQLite FHIR store created on first use), a `.mcp.json` that registers this
server, a `CLAUDE.md` that points here and a `.gitignore`. It never overwrites a file.

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
  answers a result's rows as CSV, the compact form of a table. `describe(ref, as: "fsh")` answers a
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
by its file name or `name`, and each earlier result by its handle (`r1`, `r2`, …), so a CQL run's
answer per patient joins with a view's columns. One reading statement; a column holding a list or
an object (a CQL Quantity, a Coding) is its JSON text — `json_each` walks a list, `->>` reads a value
(`r3."Latest Value" ->> '$.value'`); a boolean is 1/0 in SQL (a CQL result's own CSV says
true/false); a name with a space is quoted (`r3."Poor Control"`); null is NULL.

```
SELECT p.gender, count(*) AS n, round(avg(b.systolic), 1) AS mean_systolic
FROM bp b JOIN patients p ON p.id = b.patient GROUP BY p.gender
```

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
`json_each(resource, '$.name')`), beside the views and earlier results. Import FHIR JSON with
`raco fhir-server load fhir.db <dir|bundle.json>`.

## Constraints
A rule about the data is a FHIR profile: write it in FSH (cardinalities, fixed codes, bindings,
FHIRPath invariants for the complex ones) and name it in workspace.yaml:

```yaml
profiles:
  Observation: http://example.org/fhir/StructureDefinition/a1c
```

Every staged resource of that type is validated against it and claims it in `meta.profile`; a
stage that breaks it lists the broken rule per resource and cannot be committed. `check` holds the
workspace's FSH examples to it too, and `check(data: true)` everything already stored: how many
resources, how many break a rule, the rules by how often they are broken, the first problems as lines.

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
Expression: "code.coding.where(system = 'http://loinc.org' and code = '85354-9').exists() implies component.where(code.coding.where(system = 'http://loinc.org' and code = '8480-6').exists()).value.ofType(Quantity).where(system = 'http://unitsofmeasure.org' and code = 'mm[Hg]').exists()"

Invariant: bp-diastolic
Description: "A blood pressure (LOINC 85354-9) has a diastolic component (LOINC 8462-4) in mm[Hg]"
Severity: #error
Expression: "code.coding.where(system = 'http://loinc.org' and code = '85354-9').exists() implies component.where(code.coding.where(system = 'http://loinc.org' and code = '8462-4').exists()).value.ofType(Quantity).where(system = 'http://unitsofmeasure.org' and code = 'mm[Hg]').exists()"
```

Named for `Observation` in `profiles`, it holds every blood pressure to the rule and lets every other
Observation through. A refusal quotes the rule's `Description` (`bp-systolic: A blood pressure …`),
not the value it found: write the description as the fix the author needs.

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
commit writes version 2 with its reason:
```
raco fhir-mcp call describe ref=Observation/bp-a1 as=fsh > bp-a1.fsh     # edit it
raco fhir-mcp call stage fsh=@bp-a1.fsh
raco fhir-mcp call commit stage=stage-4 reason="typo: systolic 150 was 140"
```

## The trail
Every commit writes, into the data itself, a Provenance — the versions it wrote
(`Observation/a1/_history/2`), when, the agent (the MCP client), the `reason` given to commit, and
the source the data came from (the FSH, the file, or the run, with its text and SHA-1) — and an
AuditEvent of the transaction. With `audit: all`, every run, query and apply leaves an AuditEvent
too (its outcome, its text). The trail is data like any other:
- `describe("Observation/a1/_history")`: every version, newest first, what changed since the one
  before (`valueQuantity.value: 8.0 → 8.4`), and who wrote it, why, from what — the file and the line
  its Instance begins at (`"at": "patients.fsh:33"`);
- `describe("Provenance/<id>", as: "source")`: the text the data was made from (the FSH, the file),
  decoded;
- `query("search", "Provenance?target=Observation/a1")`;
- SQL: `history` (every version of every resource), `Provenance`, `AuditEvent`, e.g. each version
  with the reason it was written:

```
SELECT h.versionId, p.resource ->> '$.reason[0].text' AS reason
FROM history h JOIN Provenance p ON EXISTS (SELECT 1 FROM json_each(p.resource, '$.target') t
  WHERE t.value ->> '$.reference' = h.type || '/' || h.id || '/_history/' || h.versionId)
WHERE h.type = 'Observation' AND h.id = 'a1'
```

A Provenance written by a commit, for SQL (`p.resource ->> '$.<path>'`): `target[n].reference`
(`Type/id/_history/v`), `recorded`, `agent[0].who.display` (the client: `claude-code … via fhir-mcp`,
`raco fhir-mcp call`, or `FHIR_MCP_AGENT`), `reason[0].text` (commit's `reason`),
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
