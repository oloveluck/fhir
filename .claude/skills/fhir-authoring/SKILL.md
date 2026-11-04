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
- `raco spec-bench list|make|score|run` (the fhir-examples repo) — prose → FSH, scored against a
  published IG.
- `raco fsh --decompile <file.json>` — **reverse** (FHIR → FSH text).

Supports Profiles, Extensions (auto-scaffolded), ValueSets, CodeSystems (concept hierarchy),
Instances, Invariants, Aliases, slicing (incl. reslicing + multi-discriminator), Logical models &
custom Resources, Mappings, and RuleSets (incl. parameterized). Targets R5; emits differentials by
default, full snapshots opt-in.

## The languages together in one program

Every `#lang` file is a Racket module, so a program `require`s them side by side and uses their values:
`"profile.fsh"` provides `compiled` (FHIR JSON), `"intake.fml"` `transform` (FHIR JSON -> FHIR JSON),
`"codes.vcl"` `valueset`, `"rules.cql"` `evaluate` (a library over a patient's resources, with
`#:parameters`), `#lang fhir/r6` and `#lang sql-on-fhir` files `->json`. Each is compiled and checked in
its own language by `raco make`. Worked example: `fhir-examples/screening/` (`racket screening/main.rkt`).

## FHIR operations as procedures (no server)

Apply an operation by reference to its OperationDefinition; its parameters are keyword arguments
(`fhir/operation`):

```racket
(require fhir/operation fhir/data-source
         (only-in fhir/conformance/operations ensure-valid)   ; loading a module registers its operations
         (only-in fhir/terminology/operations) (only-in fml/operations) (only-in cql/measure))

(apply-operation "http://hl7.org/fhir/OperationDefinition/StructureMap-transform" qr #:srcMap fml-text)
(apply-operation "ValueSet/$expand" #:url "http://hl7.org/fhir/ValueSet/administrative-gender")
(define transform (operation "StructureMap/$transform"))           ; resolve once, apply like a procedure
(~> qr (transform #:srcMap fml-text) (ensure-valid #:profile url))  ; thread a value through operations
(parameterize ([current-data-source (directory->data-source "patients/")])   ; or a Bundle, or the store
  (apply-operation "$evaluate-measure" measure #:periodStart "2021-01-01" #:periodEnd "2021-12-31"))
```

References: the canonical, the OperationDefinition, `"$code"` or `"Type/$code"`. Keywords are the
definition's parameter names; an unknown one is an error that lists the valid ones. A Parameters
resource after the subject supplies inputs known only at run time. Available: `$validate`,
`$snapshot`, `$expand`, `ValueSet/$validate-code`, `$lookup`, `$translate`, `$transform` (FML as
`#:srcMap`), `$evaluate-measure`. The same operations serve over HTTP — `serve-operations`, or
`(operation "ValueSet/$expand")` in `#lang fhir/capability` — with /metadata derived from them
(fhir-serving). Example: `fhir-examples/examples/pipeline.rkt`.

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

A `.map`/`.fml` file is one mapping: `uses` names the source and target structures by canonical
(a FHIR type, a profile, or a logical model from the project, a data source or a package), groups
of rules read source elements and write target elements. Prints the compiled StructureMap; the
module provides `transform` (FHIR JSON in, FHIR JSON out; `#:structures` gives logical models).

```sh
raco fml map.map                                   # the StructureMap JSON
raco fml map.map --transform src.json [--structures sds/]
raco fml check map.map [--structures sds/] [--examples ex/] [--profile sd.json]   # findings on their lines
```

`check` reports what the two StructureDefinitions decide — an element the type lacks, a value
whose type cannot go into the element, a bad group call, a required target element never assigned —
and with examples transforms each and validates the result, tracing issues to the rule that wrote
the element. A project of FSH structures checks its `.map` files the same way under `raco fsh check`
and packs their StructureMaps with the structures (`fhir-examples/examples/intake-maps`).

Maps are values (`fml/registry`): `(structure-map "http://…/StructureMap/x")` resolves by canonical
(maps registered in the process, `current-data-source`, the packages) into a typed procedure
(`smap-source`/`smap-target`; `compose-maps`); `$transform` takes `source` (canonical), `sourceMap`
(resource) or `srcMap` (text). A StructureMap resource runs without its FML
(`structuremap->fml`). Not run: `dateOp`, `escape`, `pointer`; JSON only (CDA/XML out of scope).

## `#lang fhir/capability` — declare an app

Declares `server`/`resource`/`operation` forms and DERIVES the CapabilityStatement + one
OperationDefinition per operation. `racket examples/patient-app.rkt` prints `/metadata`. See the
**fhir-serving** skill to expose it over HTTP. An inline `(operation $screen #:system #:in (...)
#:out (...) #:handler h)` is ALSO an operation value: `$screen` is defined, registered by its
canonical and provided, so a program applies it in-process (`($screen #:patient "ann")`,
`(apply-operation "$screen" …)`) and the server routes `POST /$screen` to the same handler —
declare a pipeline once (`fhir-examples/screening/app.rkt`).

## The module system is the FHIR registry (`fhir/registry`)

Requiring a module registers what it defines, by canonical: a `#lang fsh` module its profiles,
value sets and code systems; `#lang vcl` its value set; `#lang fml` its StructureMap. Every
resolver looks there after the data source and before the packages, so `ensure-valid #:profile`,
a map's `uses`, `$expand #:url` and `$transform #:source` find a required module's artifacts with no
`current-data-source` to set up — that parameter is for DATA (what a rule or a view runs over).
`register-resources!` does the same for resources a program builds itself.

## Standalone checked literals

`(lit date "1974-12-25")` (`primitives/literals.rkt`) — a compile-time-checked primitive outside any
resource form.
