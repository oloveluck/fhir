---
name: fhir-authoring
description: "Write FHIR programs as Racket modules (the #langs) — resources (#lang fhir/r6, /r4), profiles (/sd), FHIR Shorthand (/fsh), CQL (/cql), VCL (/vcl), StructureMaps (/fml), capability apps (/capability). Use when writing or running any .fhir6/.fsh/.cql/.rkt FHIR-lang file in this repo."
---

# Authoring the FHIR `#lang`s

For using FHIR as a tool (create, search, compute, analyze data through the workspace), start with
the `fhir` skill; this one is about writing the languages as Racket modules.

Every language is checked when its module compiles (`raco make <file>`, or `racket <file>`), each
error at its line:
- `#lang fhir/r6`, `/r4`, `/sd`, `/capability`: the forms' fields, cardinalities, required codes.
- `#lang fml`: the map against its structures (`raco fml check`'s static findings: an element the
  type does not have, a value that cannot go there, an unknown group).
- `#lang cql`: every definition translated (an unknown identifier or function, a type error).
- `#lang fsh`: parsing and compiling; its EXAMPLES are validated by `raco fsh check <dir>` (validation
  needs the whole project and its packages), not by `raco make`.
A `#lang fsh` module compiles with the nearest `sushi-config.yaml` (canonical, FHIR version,
dependencies), as `raco fsh` does, and provides `canonical-of` (a profile's url by its name or id).
Which FHIR version each language uses: `raco fhir-mcp guide fhir`, "FHIR versions here".

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

**The fsh repository's own skill (`fsh/.claude/skills/fsh`) is the guide**, with the language
guide it points to (`fsh/guide.md`). In brief:

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
its own language by `raco make`. Worked examples: `fhir-examples/examples/intake-pipeline/` (below;
`tests/intake-pipeline-test.rkt` runs it) and `fhir-examples/screening/` (six languages).

The intake pipeline is a template — `fsh/` (the profile and a valid example), `fsh-invalid/` (an
example meant to fail), `qr2patient.map`, `Intake.cql`, `main.rkt`, `qr.json` — to copy and change:
```sh
cp -r "$(dirname "$(racket -e '(display (collection-file-path "main.rkt" "fhir-examples" "examples" "intake-pipeline"))')")" my-pipeline
rm -rf my-pipeline/compiled my-pipeline/*/compiled
cd my-pipeline && racket main.rkt qr.json      # the Patient, then "65 or older: true"
raco fsh check fsh && raco fsh check fsh-invalid --context fsh   # clean; then the bad example, at its line
```
To learn the pieces before putting them together, run each file alone, in the order the data
flows (each language's skill has the rest):
```sh
raco fsh check fsh                                         # the profile; its example validated
raco fml qr2patient.map --transform qr.json > patient.json   # the map alone: the Patient it writes
raco fml check qr2patient.map --examples qr.json --profile fsh   # its result held to the profile
raco cql Intake.cql --data patient.json --now 2026-01-01   # the library over that Patient
```
then `main.rkt` (below) is those three calls as functions.

```racket
#lang racket/base
;; a QuestionnaireResponse -> FML -> a Patient -> validated against an FSH profile -> CQL's answer
(require json
         (only-in cql/value render)
         (only-in "fsh/intake.fsh" canonical-of)                 ; the profile, registered by canonical
         (only-in "qr2patient.map" transform)                    ; FHIR JSON in, FHIR JSON out
         (only-in "Intake.cql" evaluate))                        ; define name -> value, over resources
(define (intake qr #:now [now #f])
  ;; #:validate holds the result to the profile; a problem names the map's rule that wrote the element
  (define patient (transform qr #:validate (canonical-of "IntakePatient")))
  ;; #:define answers one define; #:now fixes Today() (else the answer moves with the clock)
  (values patient (render (evaluate (list patient) #:define "Is 65 Or Older" #:now now))))
```
Without a birth date the map's Patient breaks the profile, and the error is at the map's rule:
`the map's Patient is invalid against IntakePatient (…) (FHIR R5 (5.0.0)): … qr2patient.map:14:25: fml validate error: Patient.birthDate: minimum
required = 1, but found 0 (the rule here wrote nothing: its source matched nothing in the input)` —
the birthDate rule is there, but the QuestionnaireResponse had no `birthDate` item for it to read. `(ensure-valid patient #:profile url)` (`fhir/conformance/operations`)
validates any resource the same way, naming the element but not the rule; it needs
`(require (only-in fhir/conformance/operations ensure-valid))` (loading that module registers
`$validate`, which `transform #:validate` loads by itself).
For a resource that R4 and R5 write alike (a Patient with name, gender and birthDate; most
Observations), the defaults just work and no `sushi-config.yaml` is needed. `render` (`cql/value`)
answers a string: `"true"`, or a FHIR value's JSON text — and `"null"` when CQL has no answer (a
Patient without a birthDate is neither 65 nor not): decide it in the library
(`Coalesce(AgeInYears() >= 65, false)`) or test for `"null"` in Racket.

Each step reads its own FHIR version, which matters when they meet:

| step | FHIR version | how to change it |
|---|---|---|
| FSH (`#lang fsh`, `raco fsh`) | the nearest `sushi-config.yaml`'s `fhirVersion`, else 5.0.0 | `fhirVersion: 4.0.1` in sushi-config.yaml |
| FML (`#lang fml`, `transform`) | R5 types; an R4 source is read leniently (`fml warning: … not read`) | — |
| `$validate`, `ensure-valid`, `#:validate` | the core package of `current-sd-packages`, else R5; the error names it | `(parameterize ([current-sd-packages …]) …)` |
| CQL (`#lang cql`) | FHIR 4.0.1 (`using FHIR version '4.0.1'`) | — |

The error names the version it validated in: `invalid Patient against … (FHIR R5 (5.0.0))`. For an R4 pipeline, give
FSH a `sushi-config.yaml` with `fhirVersion: 4.0.1`, require the R4 tower (`fhir/r4/schemas`: its
required bindings back the code checks) and validate with
`(parameterize ([current-sd-packages (list (spec-package-path "hl7.fhir.r4.core.tgz"))]) …)`
(`fhir/sd/sd-index`, `fhir/spec-package`): `invalid Patient (FHIR R4 (4.0.1)): … Patient.gender code
not in required value set …`.

`ensure-valid` returns the resource, or raises `exn:fail:operation` (`(require fhir/operation)` for
the predicate and `exn:fail:operation-outcome`) naming the profiles it was held to and listing every
error, one per line, with the OperationOutcome in `exn:fail:operation-outcome`. Uncaught, it prints
that message alone (no stack trace); to answer it yourself:
`(with-handlers ([exn:fail:operation? (lambda (e) (eprintf "~a\n" (exn-message e)) (exit 1))]) (intake qr))`
— `transform #:validate` raises the same `exn:fail:operation`, so this one handler catches an invalid
result from the map or from `ensure-valid`.
A `#lang fsh` profile that constrains an element its base lacks (`* birthdate 1..1`) fails `raco make`
at that rule, as a misspelt element does in `#lang fml` and `#lang cql`; the examples' validation
needs the whole project, so it is `raco fsh check` (or the fsh skill's `raco test` snippet). `(apply-operation "$validate" r
#:profile url)` returns the OperationOutcome itself: `issue` is a list of `{severity, code,
diagnostics, expression: [path]}`, one `information` "All OK" when clean. A CQL module's `evaluate`
raises an `exn:fail` (positioned at the define when it can) for a run-time error.

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

CQL compiles to **ELM** and the ELM is run. **The cql repository's own skill (`cql/.claude/skills/cql`)
is the guide**: the translate-run-narrow loop with `raco cql`, `#lang cql` modules, `cql/run`,
measures (FHIR and cqm-models), the data models (FHIR, QI-Core, US Core, QDM, your own), and the
language guide it points to (`cql/guide.md`). In brief:
- `raco cql <file.cql>` — the ELM JSON, or every translation error at its line.
- `raco cql <file.cql> --data patient/ [--valuesets vs/] [--parameter "name=<CQL>"] [--define name]`.

## `#lang vcl` — ValueSet Compose Language

**The vcl repository's own skill (`vcl/.claude/skills/vcl`) is the guide**, with `vcl/guide.md`.
One expression per file; a parse error is a compile error. Provides `compose`/`valueset`.
`raco vcl '(http://loinc.org)(a;b)'` prints the ValueSet. Implicit
`http://fhir.org/VCL?v1=…` URLs expand directly in `$expand`/`%terminologies`.

## `#lang fml` — FHIR Mapping Language

**The fml repository's own skill (`fml/.claude/skills/fml`) is the guide**, with `fml/guide.md`.
FHIRPath and SQL on FHIR have theirs too (`fhirpath/.claude/skills/fhirpath`,
`sql-on-fhir/.claude/skills/sql-on-fhir`). In brief:

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
