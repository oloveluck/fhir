# fhir

FHIR's languages and tools: FHIR Shorthand, CQL, the FHIR Mapping Language, VCL, FHIRPath and SQL on
FHIR, with a validator, a terminology service and FHIR servers generated from Implementation Guides.
Each language checks its sources and reports problems at the line and column where they are. Use
them as command-line tools, which need no Racket, or as Racket languages (`#lang fsh`, `#lang cql`, …)
that compose into one program.

## Command-line tools

| Tool | What it does | Repository |
|---|---|---|
| `fsh` | compile FHIR Shorthand to FHIR JSON (SUSHI-style), check a project, decompile FHIR to FSH | [fsh](https://github.com/oloveluck/fsh) |
| `cql` | compile CQL to ELM; run a library over a patient's FHIR data | [cql](https://github.com/oloveluck/cql) |
| `fml` | compile a FHIR Mapping Language map to a StructureMap; transform a resource; check a map | [fml](https://github.com/oloveluck/fml) |
| `vcl` | compile a VCL expression to a ValueSet; decompile a ValueSet to VCL | [vcl](https://github.com/oloveluck/vcl) |
| `fhirpath` | evaluate a FHIRPath expression against a resource (R4 or R5) | [fhirpath](https://github.com/oloveluck/fhirpath) |
| `sql-on-fhir` | run a SQL-on-FHIR ViewDefinition over FHIR data, as CSV, NDJSON or JSON | [sql-on-fhir](https://github.com/oloveluck/sql-on-fhir) |
| `fhir-validate` | validate resources against their base type and profiles | this repo |
| `fhir-tx` | `$expand`, `$validate-code`, `$lookup`, `$translate`, `$subsumes` over FHIR packages; serve them | this repo |
| `fhir-server` | serve a FHIR server generated from an IG package, over a SQLite store | this repo |
| `fhir` | round-trip FHIR JSON through the typed model; generate a StructureDefinition's snapshot | this repo |
| `fhir-lsp` | a language server for FSH, CQL, FML, VCL and FHIRPath (diagnostics, hover, go to definition), or `check` files | this repo |
| `fhir-mcp` | a Model Context Protocol server: the operations and the languages' checks as tools for an agent | this repo |

```sh
fsh patient.fsh -o out/                                   # FHIR JSON, one file per resource
fhir-validate out/Patient-ExamplePatient.json out/StructureDefinition-my-patient.json --format text
fhir-tx expand http://hl7.org/fhir/ValueSet/administrative-gender
cql adults.cql --data patient.json                        # each define's value for this patient
sql-on-fhir run view.json patients/ --format csv
fhir-server serve-ig hl7.fhir.us.core --port 8080         # a server generated from US Core
```

A problem is reported where it is, and the exit status is 1:

```
$ fhir-validate bad-patient.json --format text
bad-patient.json: error code-invalid at Patient.gender: code not in required value set http://hl7.org/fhir/ValueSet/administrative-gender
bad-patient.json: error invalid at Patient.birthDate: '1974-13-40' is not a valid date
```

Every tool takes `--help`. Each language's README shows its commands in full.

### Getting the tools

There are no prebuilt downloads yet. Build the tools once, on a machine with Racket, and the result
runs anywhere of the same kind (operating system and processor) without Racket:

```sh
# Racket 9 (https://racket-lang.org), then the family's repositories side by side
for r in fhir fhirpath vcl cql fml fsh sql-on-fhir; do git clone https://github.com/oloveluck/$r.git; done
raco pkg install --link --auto --batch --no-docs fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx \
  fhir/fhir-validation cql fml fsh fhir/fhir-server fhir/fhir-lsp fhir/fhir-mcp sql-on-fhir
fhir/build-tools.sh dist          # about two minutes
export PATH="$PWD/dist/bin:$PATH" # or copy dist/ anywhere and put its bin/ on PATH
```

`dist/` holds the twelve executables (`bin/`), the runtime they share (`lib/`), and the HL7 packages
the validator, terminology service, servers and snapshots read (`share/fhir-packages`, from
`fhir-spec`): about 380 MB in all. `build-tools.sh` builds only the tools whose packages are installed.

- **More FHIR packages.** A tool looks for packages (`.tgz`) in the directories named by
  `FHIR_PACKAGE_PATH`, then in `share/fhir-packages` beside it.
- **SQLite.** `fhir-server` (and `fsh check --capability`) store resources in SQLite through the
  system's `libsqlite3`, which most systems have.
- **What the executables leave out.** The conformance runners (`--tck`, `tck`) and the generators
  (`regen`, `check`, `fetch`) read the source checkout. Commands that load a `.rkt` file of yours, a
  `#lang sql-on-fhir` view or a `#lang fhir/capability` app, need Racket. With Racket installed, every
  command also runs as `raco <tool> …`, for example `raco fsh patient.fsh`.

## In Racket: language-oriented programming

Each language is also a Racket `#lang`, so a source file is a module: it is checked when it is
compiled, and other modules require what it defines. A misspelled element, a wrong type or a code
outside a required value set is a compile error, positioned in the source.

```racket
#lang fhir/r6
(Patient
 (id "example") (active #t) (gender "male") (birthDate "1974-12-25")
 (name (HumanName (family "Chalmers") (given "Peter" "James"))))
```

`racket patient.fhir6` prints the FHIR JSON; `(gender "florp")` fails to compile, listing the valid
codes. The same holds for the other languages: `racket patient.fsh` prints the FHIR JSON of a
`#lang fsh` file, and `(require "adults.cql")` gives a Racket program the CQL library's `evaluate`.
The module system is also the FHIR registry: requiring a module makes the profiles, value sets, maps
and libraries it defines resolvable by canonical, so the languages compose. The worked example is
[fhir-examples/screening](https://github.com/oloveluck/fhir-examples/tree/main/screening), one program
in seven `#lang`s.

FHIR operations are procedures here: `(apply-operation "$validate" resource)`,
`(apply-operation "StructureMap/$transform" qr #:srcMap fml)`, threaded with `~>`, and served over HTTP
from the same values (`fhir/operation`, `fhir/data-source`).

## Packages in this repository

| Package | What |
|---|---|
| `fhir/` | the model, primitives and JSON; `#lang fhir/r6` (R4 and R5 as schema-only towers); `#lang fhir/sd` and snapshot generation; codegen from StructureDefinitions; FHIR operations as procedures (`fhir/operation`); `raco fhir` |
| `fhir-spec/` | the vendored HL7 packages: core R4/R5/R6 and the IGs the tests use |
| `fhir-tx/` | the terminology service; `raco fhir-tx` |
| `fhir-validation/` | the validator (cardinality, types, slicing, bindings, invariants); `raco fhir-validate` |
| `fhir-server/` | FHIR REST servers, generated from an IG or declared in `#lang fhir/capability`, over SQLite; `raco fhir-server` |
| `fhir-lsp/` | the language server; `raco fhir-lsp` |
| `fhir-mcp/` | the Model Context Protocol server; `raco fhir-mcp` |

Reference documentation: [oloveluck.github.io/fhir](https://oloveluck.github.io/fhir/). Architecture
notes: `CLAUDE.md`. License: MIT; the vendored HL7 packages are CC0-1.0 (`fhir-spec/SOURCE-*.txt`).
