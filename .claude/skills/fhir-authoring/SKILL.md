---
name: fhir-authoring
description: Author and run the FHIR Racket #langs — resources (#lang fhir/r6, /r4), profiles (/sd), FHIR Shorthand (/fsh), CQL (/cql), ViewDefinitions (/viewdef), VCL (/vcl), StructureMaps (/fml), capability apps (/capability), OMOP (/omop). Use when writing or running any .fhir6/.fsh/.cql/.rkt FHIR-lang file in this repo.
---

# Authoring the FHIR `#lang`s

Every language validates at **compile time** and builds a typed node that serializes to JSON. A
`.rkt`/`.fhir6` file with a `#lang fhir/…` header is a normal Racket module — run it with
`racket <file>`, compile-check it with `raco make <file>`.

## `#lang fhir/r6` · `#lang fhir/r4` — author a resource

```racket
#lang fhir/r6
(Patient
 (id "example") (active #t) (gender "male") (birthDate "1974-12-25")
 (name (HumanName (family "Chalmers") (given "Peter" "James")))
 (maritalStatus (CodeableConcept (coding (Coding (code "M") (display "Married")))))
 (deceasedBoolean #f))
```

Run: `racket examples/patient.fhir6` (prints FHIR JSON). The form macros reject at **compile time**:
unknown/duplicate/missing fields, cardinality, choice `[x]` min/max, wrong nested type heads, bad
primitive literals, and **out-of-set required-binding codes** — `(Patient (gender "florp"))` is a
syntax error that lists the valid codes.

## `#lang fhir/sd` — profiles

```racket
#lang fhir/sd
(profile MyPatient #:base Patient
  (name 1 1)          ; narrow cardinality (loosening is a compile error)
  (gender 0 0))
```

`raco make examples/us-core.sd`. Profiles narrow a base type's cardinality (checked at phase 1) and
compile to a **delegating** form macro; `#:base` may be another profile (multi-level delegation).

## `#lang fhir/fsh` — FHIR Shorthand (bidirectional)

A `.fsh` file is a module providing `document`/`compiled`/`resources`; `main` prints JSON.
- `racket examples/patient.fsh` — compile one file.
- `raco fhir fsh <dir>` — SUSHI-style batch compile a folder into `fsh-generated/`.
- `raco fhir gofsh <file.json>` — **reverse** (FHIR → FSH text).

Supports Profiles, Extensions (auto-scaffolded), ValueSets, CodeSystems (concept hierarchy),
Instances, Invariants, Aliases, slicing (incl. reslicing + multi-discriminator), Logical models &
custom Resources, Mappings, and RuleSets (incl. parameterized). Targets R5; emits differentials by
default, full snapshots opt-in.

## `#lang fhir/cql` — Clinical Quality Language → ELM

CQL compiles to **ELM** and the ELM is run (never CQL directly). A `.cql` file provides the CQL AST,
the ELM AST, the ELM JSON, and each define's interpreted value; `main` prints ELM JSON.
- `racket examples/demo.cql`
- `raco fhir cql <file.cql>` — print ELM JSON.

## `#lang fhir/viewdef` — SQL-on-FHIR ViewDefinition

Compile-time-validated ViewDefinition authoring (a generated IG tower over the R6 base). The schema
doubles as the validator (strict `from-json` rejects invalid views). Evaluate views over resources
with `viewdef/eval.rkt`; serve `$sql-run`/`$sql-export` via `make-store-app #:sof? #t`.

## `#lang fhir/vcl` — ValueSet Compose Language

One expression per file; a parse error is a compile error. Provides `compose`/`valueset`.
`raco fhir vcl '(http://loinc.org)(a;b)'` prints the ValueSet. Implicit
`http://fhir.org/VCL?v1=…` URLs expand directly in `$expand`/`%terminologies`.

## `#lang fhir/fml` — FHIR Mapping Language

Prints the compiled StructureMap. `fml->structuremap` is the compiler; `run-map` executes
groups/rules over typed resources (JSON-only — CDA/XML tests are out of scope).

## `#lang fhir/capability` — declare an app

Declares `server`/`resource`/`operation` forms and DERIVES the CapabilityStatement + one
OperationDefinition per operation. `racket examples/patient-app.rkt` prints `/metadata`. See the
**fhir-serving** skill to expose it over HTTP.

## `#lang fhir/omop` — OMOP CDM types

The 25 OMOP tables as types named like OMOP DDL: `(person (person_id 1) …)`. See the
**fhir-analytics** skill for the FHIR→OMOP ETL.

## Standalone checked literals

`(lit date "1974-12-25")` (`primitives/literals.rkt`) — a compile-time-checked primitive outside any
resource form.
