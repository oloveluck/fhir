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
  One the app does not declare answers 405 on a type it serves (404 for a type it does not).
- The language is FHIR **R6** (6.0.0-ballot): the CapabilityStatement says so, resources are typed
  by R6, and data written by an R4 workspace is read leniently. `(server #:date "2026-11-09")` sets
  the statement's date (else a fixed one, so the statement is the same every time it is derived).
- A search parameter is `[name type]` (the definition FHIR gives that name for the type: `birthdate`,
  `gender`, `patient`, `subject`, `code`, `date`, … — a name FHIR does not define, or a wrong type, is
  an error when the app loads, naming the nearest) or `[name type "FHIRPath"]` (your own). Types:
  `token string reference date number quantity uri`. The server searches with exactly what it
  declares (what `/metadata` advertises, plus `_id`, `_lastUpdated`, `_count`, `_sort`): a search with
  any other parameter — even one FHIR defines, like `name` when only `gender` is declared — answers its
  matches without it and says so: an OperationOutcome entry (`search.mode` outcome) in the Bundle.
- A resource without `#:repository` is kept in the store: the workspace's when the workspace serves
  it, else `#:store`'s file beside the module, else (no store anywhere) in memory. A store-backed
  create or update is validated as sent (its base type, the profiles it claims): an error refuses it
  with 422 and every issue, so nothing is stored with fields it could not read. A create answers 201
  with `Location: Type/id/_history/1`; a body of another type than the endpoint's is a 400.
- A handler receives `in`, a hash from each input's name to its list of values, typed by the
  declaration and the same over GET (`?weight=80.5`) and POST (a Parameters body): `integer` an exact
  integer, `decimal` a Racket real, `boolean` `#t`/`#f`, `string`/`code`/`uri`/`date`/`dateTime` the
  text as sent, a resource a typed node. A value that is not of its type, or an input the declaration
  does not name (`weigth`: "did you mean `weight`?"), is answered 400 before the handler runs. Each
  operation's derived OperationDefinition is served at `GET /OperationDefinition/<code>` (and all of
  them at `GET /OperationDefinition`), so a client can read what `$bmi` takes. The handler returns a resource built with the R6 forms
  (`(Parameters (parameter (ParametersParameter (name "x") (valueString "…"))))`). A repeating field
  takes all its values in ONE form — two outputs are
  `(Parameters (parameter (ParametersParameter (name "egfr") (valueDecimal "57.5")) (ParametersParameter (name "stage") (valueString "G3a"))))`,
  not two `(parameter …)` forms (that is a "duplicate field" error). To refuse a request
  (400), return an OperationOutcome whose issue code is `invalid`:
  `(OperationOutcome (issue (OperationOutcomeIssue (severity "error") (code "invalid") (diagnostics "…"))))`;
  `processing` answers 422, `not-found` 404. An exception becomes a 500 OperationOutcome.
- `$validate` takes the resource in a Parameters (`resource`) or as the bare POST body, and reads it
  as sent: a misspelt element or a bad date is reported, as `raco fhir-validate` reports it. It
  answers 200 either way, its findings in the OperationOutcome (its result IS an OperationOutcome).
- A create answers 201 with an absolute `Location` (`http://host:port/Patient/<id>/_history/1`).
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
`raco fhir-server serve clinic.capability.rkt 8080 --store fhir.db` serves it (it prints
`FHIR server on http://localhost:8080` when it is listening; a script waits for `GET /metadata`).
`raco fhir-server sql fhir.db "SELECT id, resource ->> '$.gender' AS gender FROM Patient"` reads the
store as CSV, read-only: a view per stored type (`id, versionId, lastUpdated, resource`), `resources`
(every type) and `history` (every version).

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
