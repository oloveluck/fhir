# FHIR servers you declare (`#lang fhir/capability`)

A capability app is a FHIR server written as declarations: which resources it serves, with which
interactions and search parameters, and which operations. The CapabilityStatement (`/metadata`)
and one OperationDefinition per operation are derived from them, so what the server says it does
is what it does. Resources live in a SQLite FHIR store (each resource as JSONB, with its version
history and search indexes). In a workspace the file is `<name>.capability.rkt`: `write` checks it,
`run` serves it over the workspace's own store (`data: fhir.db`), and `apply` calls its operations.

## Official references
- CapabilityStatement: https://hl7.org/fhir/R4/capabilitystatement.html
- The RESTful API (interactions, levels): https://hl7.org/fhir/R4/http.html
- Operations and OperationDefinition: https://hl7.org/fhir/R4/operations.html
- Search parameters: https://hl7.org/fhir/R4/search.html

## Cheat sheet
```
(server #:url "http://example.org/clinic" #:store "fhir.db")     ; one per app
(resource Patient #:interactions (read create update delete search-type history-instance)
          #:search-params ([gender token] [family string "name.family"]))
(operation "StructureMap/$transform")       ; an existing operation, by reference
(operation $validate)                       ; an existing operation value in scope (required first)
(operation $bmi #:system                    ; a new one: #:system, #:on Type, or #:on Type #:instance
  #:in ([weight decimal 1 1] [height decimal 1 1])
  #:out ([bmi decimal 1 1])
  #:handler bmi-handler)                    ; (lambda (in req) …) -> a resource, usually Parameters
```
- Interactions: `read vread update patch delete history-instance history-type create search-type`.
- A search parameter is `[name type]` (the definition FHIR gives that name) or
  `[name type "FHIRPath"]` (your own). Types: `token string reference date number quantity uri`.
- A resource without `#:repository` is kept in the store: the workspace's when the workspace serves
  it, else `#:store`'s file beside the module, else (no store anywhere) in memory.
- A handler receives `in`, a hash from each input's name to its list of values, typed by the
  declaration and the same over GET (`?weight=80.5`) and POST (a Parameters body): `integer` an exact
  integer, `decimal` a Racket real, `boolean` `#t`/`#f`, `string`/`code`/`uri`/`date`/`dateTime` the
  text as sent, a resource a typed node. A value that is not of its type is answered 400 before the
  handler runs. The handler returns a resource built with the R6 forms
  (`(Parameters (parameter (ParametersParameter (name "x") (valueString "…"))))`). An exception becomes
  an OperationOutcome.
- Existing operations by reference: `"Resource/$validate"`, `"ValueSet/$expand"`,
  `"CodeSystem/$lookup"`, `"ValueSet/$validate-code"`, `"ConceptMap/$translate"`,
  `"StructureMap/$transform"` (FML maps: transformations), `"Measure/$evaluate-measure"` (CQL),
  each from the module that implements it (`require` it: `fhir/conformance/operations`,
  `fhir/terminology/operations`, `fml/operations`, `cql/measure`).

## Worked example
A clinic server: patients and observations in the store, FML transformations, validation, and an
operation of its own.

```racket
#lang fhir/capability
(require (only-in fhir/conformance/operations $validate) (only-in fml/operations))

(server #:url "http://example.org/clinic")

(resource Patient #:interactions (read create update search-type)
          #:search-params ([gender token] [family string "name.family"]))
(resource Observation #:interactions (read create search-type)
          #:search-params ([code token] [subject reference]))

(operation $validate)                       ; POST /Patient/$validate
(operation "StructureMap/$transform")       ; POST /StructureMap/$transform with srcMap (FML) and content

(define (bmi-handler in req)
  (define (input k) (car (hash-ref in k)))           ; declared decimal: a Racket real, GET or POST
  (define m (/ (input "height") 100))
  (define bmi (/ (input "weight") (* m m)))
  (Parameters (parameter (ParametersParameter (name "bmi") (valueDecimal (real->decimal-string bmi 1))))))
(operation $bmi #:system
  #:in ([weight decimal 1 1] [height decimal 1 1])
  #:out ([bmi decimal 1 1])
  #:handler bmi-handler)
```

In a workspace, as `clinic.capability.rkt`:
- `write` answers its problems: with `Observaton` for `Observation`,
  `clinic.capability.rkt:8:11 error: resource: unknown resource type Observaton`.
- `run` serves it and answers its url and what it serves; the server reads and writes the
  workspace's `fhir.db`, so `stage`/`commit`, search, CQL and SQL see the same data.
- `apply("$bmi", {"weight": 80, "height": 180})` calls the running app: `{"bmi": 24.7}` in a
  Parameters resource. Any HTTP client works too: `curl <url>/metadata`, `POST <url>/Patient`.
- `explain(ref: "clinic.capability.rkt", subject: "Patient")` shows what it declares for a type.

On the command line: `racket clinic.capability.rkt` prints the CapabilityStatement;
`raco fhir-server serve clinic.capability.rkt 8080 --store fhir.db` serves it.

## The languages inside a server
A handler is Racket, and every language of the workspace is a library in it:
- FML: `(apply-operation "StructureMap/$transform" source #:srcMap map-text)`, or a `#lang fml`
  module's `transform`.
- CQL: a `#lang cql` module's `(evaluate resources)`; `$evaluate-measure` for a Measure.
- FHIRPath: `(eval-fhirpath (parse-fhirpath "…") (list resource))` (`fhirpath/eval`).
- Validation and terminology: `$validate`, `$expand`, `$validate-code`, `$lookup` as operations.
- FSH profiles and VCL value sets: a required `#lang fsh` or `#lang vcl` module registers them, so
  `$validate` and `$expand` find them by canonical.

## Common problems
- The capability language types resources with FHIR R6; data in an R4 store is read leniently, so an
  element R6 renamed or dropped is not served.
- One app per file; one `(server …)`. Declarations may come in any order; a handler must not use `app`.
- The store indexes a resource when it is written, by the writer's search parameters: a parameter
  only the app declares (with its own FHIRPath) finds what the app wrote, not what the workspace
  committed. Parameters FHIR defines (`gender`, `family`, `code`, …) find both.
- An operation handler that returns a Racket value that is not a resource answers an error.
