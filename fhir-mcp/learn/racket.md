# FHIR in a Racket program (`#lang` files, no server)

Every language is a Racket `#lang`: a `.fsh`, `.map`, `.cql` or `.vcl` file that starts with its
`#lang` line is a module a program `require`s, compiled and checked in its own language by
`raco make`. No workspace, no MCP server. This page is the whole route; each language's own guide
(`raco fhir guide fsh|fml|cql|vcl`) has the language itself.

## Start from the template
```sh
raco fhir new pipeline my-pipeline          # a QuestionnaireResponse -> FML -> Patient -> FSH profile -> CQL
cd my-pipeline
raco test tests.rkt                         # the gate: profile clean, bad example caught, answers right
racket main.rkt qr.json                     # the Patient, then "65 or older: true"
```
The four files, each a module: `fsh/intake.fsh` (the profile and a valid example; `fsh-invalid/`
holds an example meant to fail), `qr2patient.map` (FML), `Intake.cql` (the question), `main.rkt`
(the program). Change them; `raco test tests.rkt` again.

## Check each piece, in the order the data flows
```sh
raco fsh check fsh                                               # profile + examples, problems at their rules
raco fml qr2patient.map --transform qr.json > patient.json        # what the map writes (--indent to read it)
raco fml check qr2patient.map --examples qr.json --profile fsh   # that, held to the profile, problems at map rules
raco cql Intake.cql --data patient.json --now 2026-01-01         # the library's answers for one patient
```

## The API `main.rkt` uses
| require | binding | what it is |
|---|---|---|
| `json` | `(call-with-input-file "qr.json" read-json)` | the input: FHIR JSON as a hash, what `transform` takes |
| `"fsh/intake.fsh"` | `(canonical-of "IntakePatient")` | a definition's url, by name or id |
| `"qr2patient.map"` | `(transform qr #:validate url)` | FHIR JSON (a hash, or a typed node) in, FHIR JSON out; invalid -> `exn:fail:operation` naming the map's rule |
| `"Intake.cql"` | `(evaluate (list patient) #:define "Is 65 Or Older" #:now "2026-01-01")` | the define's Racket value (`#t`, a number); without `#:define`, a hash of all; `#:now #f` (the default) is today |
| `cql/value` | `(render v)` | a value as text to print (`"true"`, JSON, `"null"`) |
| `fhir/serialize/fhir-json` | `(write-fhir-json js #:indent 2)` | FHIR JSON as FHIR writes it: `resourceType` first, then each element in its type's order |
| `fhir/operation` | `exn:fail:operation?` | the error `#:validate` and `ensure-valid` raise: one handler for both |
| `fhir/conformance/operations` | `(ensure-valid r #:profile url)` | any resource, validated; names the element |

In tests (the template's `tests.rkt` uses each):
| require | binding | what it is |
|---|---|---|
| `fsh/check` | `(check-fsh-project "fsh")`, `#:context (list "fsh")` | `raco fsh check` as a value: a report; `#:context` = another folder's definitions, its instances left out |
| `fsh/check` | `(check-report-diagnostics report)` | the report's problems, in source order |
| `fhir/diagnostic` | `diagnostic-message`, `diagnostic-severity` (`'error`, `'warning`) | one problem's text and level |
| `fhir/diagnostic` | `(loc-line (diagnostic-loc d))`, `loc-column`, `loc-source` | where it is: the line to assert in a test |

`racket <file>.fsh` (or `.map`, `.vcl`) prints what the file compiles to, as FHIR JSON.

## What checks what
- `raco make` (and `racket main.rkt`) compiles each `#lang` file in its language: an FSH rule on an
  element the type lacks, an FML rule writing an element the target lacks, a CQL name that does not
  resolve all fail the build at their line. It does NOT validate the FSH examples (that needs the
  whole project): an invalid example builds. `raco fsh check fsh` validates them, each problem at its
  line; keep an example meant to fail in its own folder (`raco fsh check fsh-invalid --context fsh`).
- The template's `tests.rkt` is all of it as one gate (`raco test tests.rkt`): copy it beside files
  you wrote yourself (`raco fhir new pipeline tmp`, take `tmp/tests.rkt`) and change its expectations.
  It drives `main.rkt` through what the template's provides, so a `main.rkt` of your own keeps that
  shape: `(provide intake)` with `(intake qr #:now [now #f])` answering two values, the Patient (FHIR
  JSON) and the answer's text, and the command line in a `(module+ main …)` (a plain script runs
  when `tests.rkt` requires it). A missing element is reported at its Instance's first line (no rule
  wrote it), so an expectation for it names that line.
- A run of `main.rkt` takes about 3 s after `raco make`: loading the FHIR types and the core
  package, not the work itself. A program that handles many inputs pays it once.

## When it fails
- `raco make` stops at the first failing module and shows its line and a caret:
  `qr2patient.map:14:25: fml check error: …` then the source line. The `compilation context…` lines
  under it are Racket's: the chain of files that required the failing one.
- A file without its `#lang` line: `default-load-handler: expected a 'module' declaration`. The
  command-line tools read files with or without the line.
- CQL: `AgeInYears()` needs nothing included; comparing a FHIR value with a literal
  (`Patient.gender = 'female'`) needs `include FHIRHelpers version '4.0.1' called FHIRHelpers`, and
  without it is a translation error naming that line.
- An answer of `null` from CQL is "unknown" (no birth date): decide it in the library
  (`Coalesce(AgeInYears() >= 65, false)`) or test `render`'s `"null"`.

## FHIR versions
FSH: the nearest `sushi-config.yaml`'s `fhirVersion`, else 5.0.0. FML: R5 types (R4 sources read
leniently, with a warning for what is dropped). Validation: R5 unless `current-sd-packages` names
another core package; its error says which. CQL: FHIR 4.0.1. A Patient or most Observations are
written alike in R4 and R5, so the defaults work for them.

More: the fhir-authoring skill (each `#lang` in detail), `fhir-examples/examples/intake-pipeline/`.
References: Racket modules and `#lang` (https://docs.racket-lang.org/guide/module-languages.html),
`raco make` (https://docs.racket-lang.org/raco/make.html), FHIR (https://hl7.org/fhir/R4/).
