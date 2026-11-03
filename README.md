# fhir — FHIR as a framework for spec-driven development

FHIR is a machine-readable specification language for healthcare software: profiles, value sets,
invariants, search parameters, operations and quality measures, all published as data in
Implementation Guides. This family of Racket packages treats those specs as **languages you write
and tools that check them**, so that a person or an LLM can go from a requirement to a working,
validated FHIR artifact with precise feedback at every step:

1. **Write the spec** in FHIR's own languages: FSH for profiles and examples, CQL for logic, FHIRPath
   for invariants, VCL for value sets, FML for maps.
2. **Check it**: `raco fsh check <project>` compiles the project, validates every example against the
   project's own profiles (dependencies and core in context), and puts every problem on the FSH line
   that caused it, naming the profile rule it breaks. Text for people; JSON or a FHIR
   OperationOutcome for agents.
3. **Run it**: `raco fhir-server serve-ig <package>` generates a server from the packed IG: its
   CapabilityStatement, search parameters, profile validation on every write, `$expand`, and CQF
   Measures' `$evaluate-measure` over CQL.

[fhir-examples](https://github.com/oloveluck/fhir-examples) holds worked examples and the demonstration: a model
reads what a published IG says about a profile, writes the FSH, gets `fsh check`'s diagnostics back,
and is scored against the profile HL7 actually published.

> **Scope.** Built for spec development and conformance testing, not production use. Persistence is
> an embedded SQLite store.

## Try it

```sh
racket fhir/examples/patient.fhir6               # #lang fhir/r6: a compile-time-validated Patient -> FHIR JSON
raco fsh check ../fsh/tests/vendor/mcode-4.0.0   # check a real IG's FSH: every example vs every profile
raco fhir-validate resource.json [profile.json…] # validate one resource (OperationOutcome on stdout)
raco fhir-server serve-ig hl7.fhir.us.core --port 8080   # a server GENERATED from US Core (try --gaps)
racket fhir/examples/demo.cql                    # #lang cql: CQL -> ELM JSON
raco fhirpath --tck r5                           # the official FHIRPath R5 suite
```

```racket
#lang fhir/r6
(Patient
 (id "example") (active #t) (gender "male") (birthDate "1974-12-25")
 (name (HumanName (family "Chalmers") (given "Peter" "James"))))
```

`(birthDate "1974-13-40")`, `(notAField "x")` or `(gender "florp")` fail to **compile**.

## The packages

Ten Racket packages in seven repos, plus the examples repo. The foundation keeps the `fhir` collection
(shared by `fhir-validation` and `fhir-server`, module-disjoint); each language is its own collection.

| package | where | what |
|---|---|---|
| `fhir` | this repo, `fhir/` | the foundation: typed-node model, primitives, JSON, compile-time form macros, `#lang fhir/sd` + snapshot generation, codegen and the R4/R5/R6 towers, the package reader, the shared diagnostics; `raco fhir` (regen, check, roundtrip, snapshot) |
| `fhir-spec` | this repo, `fhir-spec/` | the vendored HL7 packages (core R4/R5/R6, US Core, IPS, mCODE + its dependencies, CQF Measures, tx-ecosystem) |
| `fhir-validation` | this repo, `fhir-validation/` | the validator (fail-open: cardinality, types, slicing, bindings, invariants) and the terminology service; `raco fhir-validate` |
| `fhir-server` | this repo, `fhir-server/` | servers generated from IGs, `#lang fhir/capability`, HTTP, the SQLite store, `$evaluate-measure`; `raco fhir-server` |
| [`fhirpath`](https://github.com/oloveluck/fhirpath) | own repo | the FHIRPath engine with UCUM; `raco fhirpath` |
| [`vcl`](https://github.com/oloveluck/vcl) | own repo | `#lang vcl`; `raco vcl` |
| [`cql`](https://github.com/oloveluck/cql) | own repo | `#lang cql`: CQL -> ELM and an ELM engine over FHIR data; `raco cql` |
| [`fml`](https://github.com/oloveluck/fml) | own repo | `#lang fml`: FHIR Mapping Language; `raco fml` |
| [`fsh`](https://github.com/oloveluck/fsh) | own repo | `#lang fsh`, both directions, projects and packaging; `raco fsh`, `raco fsh check` |
| [`sql-on-fhir`](https://github.com/oloveluck/sql-on-fhir) | own repo | `#lang sql-on-fhir`: ViewDefinitions and the IG's operations, generated from HL7's package; `raco sql-on-fhir` |
| [`fhir-examples`](https://github.com/oloveluck/fhir-examples) | own repo | worked examples (operations as procedures) and the spec-driven benchmark; `raco spec-bench` |

Every tool reports errors the same way (`fhir/diagnostic`): `file:line:col` with the source line and a
caret, or `--format json` / `--format outcome` for programs, and every error, not just the first.

Install from source, repos side by side (dependency order):

```sh
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-validation cql fml fsh fhir/fhir-server fhir-examples
```

## Conformance

Every suite is vendored with a `SOURCE.txt` and gated by a floor that only rises.

| suite | current |
|---|---|
| FHIRPath, HL7 R5 / R4 suites | **1044/1044**, 932/934 |
| CQL, cqframework/cql-tests | **1820/1823**; 32/32 published libraries compile, 742/803 definitions ELM-equal to the reference translator |
| CQL execution, 4 eCQMs over 76 test patients | 71/76 (5 named corpus disagreements) |
| UCUM functional tests | **573/573** |
| SQL on FHIR shared suite (FHIR/sql-on-fhir.js) | **144/144** |
| terminology, hl7.fhir.uv.tx-ecosystem | 463/553 |
| snapshot generation, fhir-test-cases | 80/80 paths, 476/478 cardinality, 235/236 types |
| validator vs the Java validator's recorded outcomes | **0 false positives**, 17/26 caught |
| IG validation, US Core 9.0.0 + IPS 2.0.1 examples | 260/260 clean |
| FSH, real IGs compiled from their own sources | mCODE 206/349 identical to the published package, 282 complete; IPS 82/114, 97 |
| FSH -> package -> generated server (mCODE) | **283/283** examples validate against the profiles we compile |
| servers generated from IGs | US Core: 0 unmet requirements (auth aside); CQF Measures: 60/65 MeasureReports |
| FML, VCL, FSH golden | 6/6 + 15/15; 60/60; 22/22 |
| round-trip, HL7 examples + core packages | R5 2968 + 77, R4 4581 + 72 |

Architecture notes: `CLAUDE.md`. How to use each language and command: `.claude/skills/`.
