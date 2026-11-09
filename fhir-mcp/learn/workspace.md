# The FHIR workspace

You work in a directory of source files. Each file is a program in one of the FHIR languages, or a FHIR
resource as JSON. The tools check them, run them against FHIR data, and explain the answers. Every
problem is one line, at its file, line and column: `Gap.cql:4:1 error: in define "Gap": unknown identifier 'Nope'`.

To start a new workspace from a shell: `fhir-mcp init [dir]` writes `workspace.yaml`, `data/`, a
`.mcp.json` that registers this server, and a `CLAUDE.md` that points here. It never overwrites a file.

| File | Language | `run` gives | Guide |
|---|---|---|---|
| `*.fsh` | FHIR Shorthand: profiles, extensions, value sets, code systems, example instances | the resources the file defines, each example validated | `learn://fsh` |
| `*.cql` | Clinical Quality Language: patient logic, cohorts, measures | every define's value for every patient | `learn://cql` |
| `*.fhirpath` | one FHIRPath expression | its value over each resource it reads | `learn://fhirpath` |
| `*.vcl` | one ValueSet Compose Language expression | the value set's expansion | `learn://vcl` |
| `*.map`, `*.fml` | FHIR Mapping Language | each source resource transformed, the result validated | `learn://fml` |
| `*.view.json` | a SQL on FHIR ViewDefinition | its rows | `learn://sql-on-fhir` |
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
  search (`Observation?code=http://loinc.org|4548-4`), or a VCL expression.
- `explain(ref, subject)` (`ref` a result such as `result://r1`, or a file) says why the answer for
  one subject is what it is: CQL define by define down to the retrieves, FHIRPath part by part, a
  view's `where` clauses, a map's rules, an FSH instance's problems.
- `describe(ref)` reads anything by reference: `result://r1` (paged with offset/limit, or compared
  with `against`), `Patient/123`, a canonical url, a type or element (`Observation.component`), an
  operation (`$expand`), or a fragment of a definition's name. `describe(ref, as: "fsh")` answers a
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

## Which language for which question
- A value inside one resource: FHIRPath.
- A fact about a patient, or a cohort: CQL.
- A table or a count across a population: a ViewDefinition.
- A set of codes: VCL.
- What valid data looks like (a profile, an example): FSH.
- Converting data from one structure to another: FML.

## workspace.yaml
```yaml
fhirVersion: 4.0.1                 # or 5.0.0; every language follows it (CQL's model is 4.0.1)
canonical: http://example.org/fhir # the base of what the workspace defines
packages:                          # FHIR packages in context, by file or name
  - hl7.fhir.us.core-6.1.0
data: data/                        # a directory, a JSON file, or a FHIR server's base url
parameters:                        # CQL parameters, as CQL expressions
  Measurement Period: Interval[@2025-01-01T00:00:00.000, @2025-12-31T23:59:59.999]
allowRemoteWrites: false           # commit may write to the server only when true
models:                            # data models made from the workspace's FSH logical models
  Clinic: http://example.org/fhir patient=Member birthDate=born version=1.0
```
`models` lets CQL query a model you design here: `using Clinic version '1.0'`. learn://cql explains it.
A server that needs a token reads it from the environment variable `FHIR_AUTHORIZATION`, which holds
the whole header value (`Bearer …`). It is never kept in a file.

## The loop
Write a file, read its problems, fix them at their lines, then run it. When an answer surprises you,
explain it for one subject before you change anything.
