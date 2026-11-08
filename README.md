# fhir

FHIR's languages and tools: FHIR Shorthand, CQL, the FHIR Mapping Language, VCL, FHIRPath and SQL on
FHIR, with a validator, a terminology service and FHIR servers generated from Implementation Guides.
Every tool reports problems at the line and column where they are. [TESTING.md](TESTING.md) has the
conformance results.

## Command-line tools

| Tool | What it does |
|---|---|
| [`fsh`](https://github.com/oloveluck/fsh) | compile FHIR Shorthand to FHIR JSON, check a project, decompile FHIR to FSH |
| [`cql`](https://github.com/oloveluck/cql) | compile CQL to ELM; run a library over a patient's data |
| [`fml`](https://github.com/oloveluck/fml) | compile, run and check a FHIR Mapping Language map |
| [`vcl`](https://github.com/oloveluck/vcl) | compile a VCL expression to a ValueSet, and back |
| [`fhirpath`](https://github.com/oloveluck/fhirpath) | evaluate a FHIRPath expression against a resource |
| [`sql-on-fhir`](https://github.com/oloveluck/sql-on-fhir) | run a ViewDefinition over FHIR data as CSV, NDJSON or JSON |
| `fhir-validate` | validate resources against their base type and profiles |
| `fhir-tx` | `$expand`, `$validate-code`, `$lookup`, `$translate` over FHIR packages, or serve them |
| `fhir-server` | serve a FHIR server generated from an IG package |
| `fhir` | round-trip FHIR JSON; generate a StructureDefinition's snapshot |
| `fhir-lsp` | a language server for FSH, CQL, FML, VCL and FHIRPath |
| `fhir-mcp` | a Model Context Protocol server: a FHIR workspace where an agent writes, checks, runs and explains FSH, CQL, FHIRPath, VCL, FML and SQL on FHIR views against FHIR data (a directory or a FHIR server) |

```sh
fsh patient.fsh -o out/
fhir-validate out/Patient-ExamplePatient.json out/StructureDefinition-my-patient.json --format text
fhir-tx expand http://hl7.org/fhir/ValueSet/administrative-gender
fhir-server serve-ig hl7.fhir.us.core --port 8080
```

```
$ fhir-validate bad-patient.json --format text
bad-patient.json: error code-invalid at Patient.gender: code not in required value set http://hl7.org/fhir/ValueSet/administrative-gender
bad-patient.json: error invalid at Patient.birthDate: '1974-13-40' is not a valid date
```

### Getting the tools

There are no prebuilt downloads yet. Build them once on a machine with
[Racket 9](https://racket-lang.org); the result runs without Racket on any machine of the same kind:

```sh
for r in fhir fhirpath vcl cql fml fsh sql-on-fhir; do git clone https://github.com/oloveluck/$r.git; done
raco pkg install --link --auto --batch --no-docs fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx \
  fhir/fhir-validation cql fml fsh fhir/fhir-server fhir/fhir-lsp fhir/fhir-mcp sql-on-fhir
fhir/build-tools.sh dist
export PATH="$PWD/dist/bin:$PATH"
```

`dist/` (about 380 MB) holds the tools and the HL7 packages they read. A tool also finds packages in
the directories named by `FHIR_PACKAGE_PATH`. `fhir-server` needs the system's SQLite library.

## In Racket

Each language is also a Racket `#lang`: a source file is a module, checked when it compiles, that
other modules require. Requiring one makes its profiles, value sets, maps and libraries resolvable by
canonical, so the languages compose into one program, as in
[fhir-examples/screening](https://github.com/oloveluck/fhir-examples/tree/main/screening).

```racket
#lang fhir/r6
(Patient (id "example") (gender "male") (birthDate "1974-12-25"))
```

`racket patient.fhir6` prints the FHIR JSON; `(gender "florp")` fails to compile, listing the valid
codes. FHIR operations are procedures: `(apply-operation "$validate" resource)`.

## This repository

| Package | What |
|---|---|
| `fhir/` | the typed FHIR model, JSON, `#lang fhir/r6`, snapshot generation, codegen, operations as procedures |
| `fhir-spec/` | the vendored HL7 packages |
| `fhir-tx/` | the terminology service |
| `fhir-validation/` | the validator |
| `fhir-server/` | FHIR servers over a SQLite store |
| `fhir-lsp/`, `fhir-mcp/` | the language server and the MCP server |

Reference: [oloveluck.github.io/fhir](https://oloveluck.github.io/fhir/). Architecture: `CLAUDE.md`.
License: MIT; the vendored HL7 packages are CC0-1.0.
