# fhir — FHIR as a family of Racket `#lang`s

A language-oriented-programming implementation of [FHIR](https://build.fhir.org/). FHIR's type
system is treated as a *collection of languages*: a foundation type framework plus one generated
`#lang` per version tower (`#lang fhir/r6`, `#lang fhir/r4`) whose type macros validate resources at
**compile time** and build a typed value that serializes to JSON. This is the **foundation vertical
slice** — one coherent end-to-end path proving the architecture, not breadth.

> **This repo is now much more targeted.** It holds only the FHIR-specific parts: the foundation
> (`fhir/`: typed model, primitives, JSON, codegen, the R4/R5/R6 towers, `#lang fhir/sd`), the vendored
> HL7 packages (`fhir-spec/`) and the application layer (`fhir-tools/`: capability lang, HTTP server,
> terminology, validator, SQL-on-FHIR, OMOP, store, `raco fhir`). The stand-alone languages moved to
> their own repos: [fhirpath](https://github.com/oloveluck/fhirpath), [cql](https://github.com/oloveluck/cql),
> [fsh](https://github.com/oloveluck/fsh), [vcl](https://github.com/oloveluck/vcl) and
> [fml](https://github.com/oloveluck/fml).

> **Scope.** Built for FHIR **spec development and conformance testing, not production use.**
> Persistence is an embedded **SQLite** store (WAL, versioned history, FHIRPath-extracted search
> indexes) with **DuckDB** attached over the same file for SQL-on-FHIR / OMOP **analytics**.

## The languages at a glance

| `#lang` | what you author | run it |
|---|---|---|
| `fhir/r6` · `fhir/r4` | FHIR resources (compile-time-validated) | `racket examples/patient.fhir6` |
| `fhir/sd` | profiles that narrow a base type | `raco make examples/us-core.sd` |
| `fsh` | FHIR Shorthand (bidirectional ↔ GoFSH) | `racket examples/patient.fsh` |
| `cql` | Clinical Quality Language → ELM | `racket examples/demo.cql` |
| `fhir/viewdef` | SQL-on-FHIR ViewDefinitions | `raco fhir sof-tck` |
| `vcl` | ValueSet Compose Language | `raco vcl '(http://loinc.org)(a;b)'` |
| `fml` | FHIR Mapping Language → StructureMap | `raco fml --tck` |
| `fhir/capability` | an app → CapabilityStatement + ops | `racket examples/patient-app.rkt` |
| `fhir/omop` | OMOP CDM tables + FHIR→OMOP ETL | `raco fhir omop <store.db>` |

Shared engines under the langs: a from-scratch **FHIRPath** engine (full UCUM, precision-aware
decimals/temporals), a version-neutral **terminology service** (`$expand`/`$validate-code`/
`$translate`, backing `%terminologies`), snapshot generation + **resource validation** (fail-open),
and a small from-scratch **HTTP/1.1 server**.

**How to use each lang and the CLI** lives in `.claude/skills/` (`fhir-authoring`, `fhir-cli`,
`fhir-serving`, `fhir-analytics`). **Architecture and design notes** live in `CLAUDE.md`.

## Conformance corpora

Every suite is vendored verbatim with a `SOURCE.txt` (source URL, retrieval date, and exactly what
is skipped and why) and gated by a floor that only rises:

| suite | source | current |
|---|---|---|
| FHIRPath | HL7 R4/R5 official suites | **1044/1044** (R5), 932/934 (R4) |
| CQL | cqframework/cql-tests | **1819/1823** |
| UCUM | the official UCUM functional tests | **573/573** (every section) |
| SQL-on-FHIR | FHIR/sql-on-fhir.js shared suite | **133/133** |
| terminology | hl7.fhir.uv.tx-ecosystem | **463/553** |
| snapshot generation | fhir-test-cases rX/snapshot-generation | **80/80 paths**, 143/148 cardinality |
| validator differential | fhir-test-cases + recorded Java outcomes | **0 false positives**, 17/26 caught (67 cases) |
| FML | fhir-test-cases structure-mapping | 6/6 exec, 15/15 parse |
| VCL | the spec page's own examples | 60/60 parse + print∘parse fixpoint |
| FSH | the SUSHI golden corpus | 22/22 forward + round-trip |
| round-trip | HL7 examples + R4/R5 core packages | ~7,700 resources |
| IG examples | US Core 9.0.0 + IPS 2.0.1 | **274/274** parse *and* round-trip |

## Try it

```sh
cd fhir-tools
racket examples/patient.fhir6                  # author a Patient in #lang fhir/r6, print FHIR JSON
raco fhir serve examples/server-app.rkt 8080   # serve a capability app (GET /metadata, CRUD, search)
racket examples/patient.fsh                    # #lang fsh — compile FSH to FHIR JSON
racket examples/demo.cql                        # #lang cql — compile CQL to ELM, print ELM JSON
raco fhirpath --tck r5                          # run the official FHIRPath R5 conformance suite
raco fhir check all                             # verify the committed towers match a fresh regen
```

Example (`examples/patient.fhir6`):

```racket
#lang fhir/r6
(Patient
 (id "example") (active #t) (gender "male") (birthDate "1974-12-25")
 (name (HumanName (family "Chalmers") (given "Peter" "James")))
 (maritalStatus (CodeableConcept (coding (Coding (code "M") (display "Married")))))
 (deceasedBoolean #f))
```

`(birthDate "1974-13-40")`, `(notAField "x")`, or `(name (Coding …))` all fail to **compile**.

## Layout — a family of packages

Eight Racket packages in six repos. The foundation keeps the `fhir` collection; each language is its own
collection, so `raco pkg install cql` gives you `#lang cql` and `raco cql` and nothing else.

| package | where | contents |
|---|---|---|
| `fhir` | this repo, `fhir/` | the foundation: Result type, typed-node model, primitives, compile-time form macros, JSON (de)serializer, `#lang fhir/sd` + snapshot generation, `codegen/`, the generated towers `r4/ r5/ r6/` (`#lang fhir/r6`, `#lang fhir/r4`) |
| `fhir-spec` | this repo, `fhir-spec/` | the vendored HL7 NPM packages (50 MB of `.tgz`) read by codegen, snapshots, terminology and the suites — install only when you need them |
| [`fhirpath`](https://github.com/oloveluck/fhirpath) | own repo | the FHIRPath engine (with UCUM); `raco fhirpath` |
| [`vcl`](https://github.com/oloveluck/vcl) | own repo | `#lang vcl` (ValueSet Compose Language); `raco vcl` |
| [`cql`](https://github.com/oloveluck/cql) | own repo | `#lang cql` (CQL → ELM + interpreter); `raco cql` |
| [`fml`](https://github.com/oloveluck/fml) | own repo | `#lang fml` (FHIR Mapping Language); `raco fml` |
| [`fsh`](https://github.com/oloveluck/fsh) | own repo | `#lang fsh` (FHIR Shorthand, bidirectional); `raco fsh` |
| `fhir-tools` | this repo, `fhir-tools/` | the application layer: `#lang fhir/capability` + HTTP, terminology service, validator, `#lang fhir/viewdef` (SQL-on-FHIR), `#lang fhir/omop`, SQLite/DuckDB store, the `raco fhir` CLI, integration tests and the examples |

Install from source with the repos side by side (dependency order):

```sh
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl cql fml fsh fhir/fhir-tools
```

See `CLAUDE.md` (Package map) for the dependency graph and the seams the split introduced.
