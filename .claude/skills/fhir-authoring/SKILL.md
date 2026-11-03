---
name: fhir-authoring
description: Author and run the FHIR Racket #langs — resources (#lang fhir/r6, /r4), profiles (/sd), FHIR Shorthand (/fsh), CQL (/cql), VCL (/vcl), StructureMaps (/fml), capability apps (/capability). Use when writing or running any .fhir6/.fsh/.cql/.rkt FHIR-lang file in this repo.
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

## `#lang fsh` — FHIR Shorthand (bidirectional)

A `.fsh` file is a module providing `document`/`compiled`/`resources`; `main` prints JSON.
- `racket examples/patient.fsh` — compile one file.
- `raco fsh <dir>` — SUSHI-style batch compile a folder into `fsh-generated/` (reads the project's
  `sushi-config.yaml`: canonical, FHIR version, dependency packages from fhir-spec).
- `raco fsh <dir> --pack [out.tgz]` — also write a FHIR NPM package; serve it with
  `raco fhir-server serve-ig out.tgz --capability <CapabilityStatement id>`.
- Errors everywhere are `file:line:col` diagnostics with the source line; `--format json` or
  `--format outcome` (a FHIR OperationOutcome) prints them on stdout for tools and LLM agents. The
  same flag works on `raco cql`, `raco vcl`, `raco fml`, `raco fhirpath` and `raco fhir-validate`.
- `raco fsh check <dir> [--capability <id>]` — **the spec-author's loop**: compile, then validate
  every example against the project's own profiles (dependencies and core in context), and with a
  CapabilityStatement report what the generated server would not meet. Every problem is positioned
  IN THE FSH: at the instance rule that wrote the element (else the instance header), naming the
  profile rule that constrains it (`… (constrained by profile TumorSize at profiles.fsh:4:3)`).
  Exit 1 on any error; `--format json|outcome` for agents. `--capability` needs fhir-server.
- `raco spec-bench list|make|score|run` (the fhir-spec-driven repo) — prose → FSH, scored against a
  published IG.
- `raco fsh --decompile <file.json>` — **reverse** (FHIR → FSH text).

Supports Profiles, Extensions (auto-scaffolded), ValueSets, CodeSystems (concept hierarchy),
Instances, Invariants, Aliases, slicing (incl. reslicing + multi-discriminator), Logical models &
custom Resources, Mappings, and RuleSets (incl. parameterized). Targets R5; emits differentials by
default, full snapshots opt-in.

## FHIR operations as function calls (no server)

Apply an operation by reference to its OperationDefinition, with parameters (`fhir/operation`):

```racket
(require fhir/operation fhir/data-source
         (only-in fhir/conformance/operations validated)   ; loading a module registers its operations
         (only-in fhir/terminology/operations) (only-in fml/operations) (only-in cql/measure))

(call-operation "http://hl7.org/fhir/OperationDefinition/StructureMap-transform" qr "srcMap" fml-text)
(call-operation "ValueSet/$expand" #f "url" "http://hl7.org/fhir/ValueSet/administrative-gender")
(pipeline qr (step (lookup-operation "$transform") "srcMap" fml-text) (validated #:profile url))
(parameterize ([current-data-source (directory->data-source "patients/")])   ; or a Bundle, or the store
  (call-operation "$evaluate-measure" measure "periodStart" "2021-01-01" "periodEnd" "2021-12-31"))
```

References: the canonical, the OperationDefinition, `"$code"` or `"Type/$code"`. Parameters are
name/value pairs or a Parameters resource; unknown names are errors that list the valid ones.
Available: `$validate`, `$snapshot`, `$expand`, `ValueSet/$validate-code`, `$lookup`, `$translate`,
`$transform` (FML as `srcMap`), `$evaluate-measure`. A server generated from an IG serves the same
operation values over HTTP (fhir-serving). Example: `fhir-spec-driven/examples/pipeline.rkt`.

## `#lang cql` — Clinical Quality Language → ELM

CQL compiles to **ELM** and the ELM is run (never CQL directly). A `.cql` file provides the CQL AST,
the ELM AST, the ELM JSON, and each define's interpreted value; `main` prints ELM JSON.
- `racket examples/demo.cql`
- `raco cql <file.cql>` — print ELM JSON.

## `#lang vcl` — ValueSet Compose Language

One expression per file; a parse error is a compile error. Provides `compose`/`valueset`.
`raco vcl '(http://loinc.org)(a;b)'` prints the ValueSet. Implicit
`http://fhir.org/VCL?v1=…` URLs expand directly in `$expand`/`%terminologies`.

## `#lang fml` — FHIR Mapping Language

Prints the compiled StructureMap. `fml->structuremap` is the compiler; `run-map` executes
groups/rules over typed resources (JSON-only — CDA/XML tests are out of scope).

## `#lang fhir/capability` — declare an app

Declares `server`/`resource`/`operation` forms and DERIVES the CapabilityStatement + one
OperationDefinition per operation. `racket examples/patient-app.rkt` prints `/metadata`. See the
**fhir-serving** skill to expose it over HTTP.

## Standalone checked literals

`(lit date "1974-12-25")` (`primitives/literals.rkt`) — a compile-time-checked primitive outside any
resource form.
