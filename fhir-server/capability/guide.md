# FHIR servers you declare (`#lang fhir/capability`)

A capability app is a FHIR server written as declarations: which resources it serves, with which
interactions and search parameters, and which operations. The CapabilityStatement (`/metadata`)
and one OperationDefinition per operation are derived from them, so what the server says it does
is what it does. Resources live in a SQLite FHIR store (each resource as JSONB, with its version
history and search indexes). In a workspace the file is `<name>.capability.rkt`: `write` checks it,
`run` serves it over the workspace's own store (`data: fhir.db`), and `apply` calls its operations.

## The smallest server
One file: a SQLite store beside it, two resources, one operation of your own. The rest of this guide
is what each part can say.
```racket
#lang fhir/capability
(require (only-in fhir/conformance/operations $validate)) ; an existing operation: required, then served
(server #:store "study.db" #:search-handling "strict")   ; patient data: refuse a filter it cannot apply
(resource Patient #:interactions (read create search-type) #:search-params ([gender token] [birthdate date]))
(resource Observation #:interactions (read create search-type) #:search-params ([patient reference] [code token]))
(define (double-handler in req)                           ; `in`: each input's name -> its list of values
  (Parameters (parameter (ParametersParameter (name "doubled") (valueDecimal (* 2 (car (hash-ref in "x"))))))))
(operation $double #:system #:in ([x decimal 1 1]) #:out ([doubled decimal 1 1]) #:handler double-handler)
(operation $validate)                                     ; POST /Patient/$validate, /Observation/$validate
```
`racket study.capability.rkt` prints its CapabilityStatement; `raco fhir-server serve
study.capability.rkt --port 0` serves it (the first line printed is its url); `GET /$double?x=2.5`
answers `5.0`; `POST /Patient/$validate` with a Patient answers `All OK (FHIR R6 (6.0.0-ballot4))` or
its problems. The server speaks FHIR **R6** (`6.0.0-ballot4` in `/metadata`) whatever FHIR version a
workspace uses; its clients send JSON that R4 and R6 write alike for most resources. After editing the
file, stop the server (its pid is in the first line) and serve it again: the store keeps the data.

## Official references
- CapabilityStatement: https://hl7.org/fhir/R4/capabilitystatement.html
- The RESTful API (interactions, levels): https://hl7.org/fhir/R4/http.html
- Operations and OperationDefinition: https://hl7.org/fhir/R4/operations.html
- Search parameters: https://hl7.org/fhir/R4/search.html

## Cheat sheet
```
(server #:url "http://example.org/clinic" #:store "fhir.db"      ; one per app; also #:name, #:description,
        #:description "The clinic's FHIR server"                  ;   #:status, #:date, #:mode, #:format, #:fhir-version
        #:search-handling "strict")                               ; refuse a filter it cannot apply (default lenient)
(resource Patient #:interactions (read create update delete search-type history-instance)
          #:search-params ([gender token] [family string "name.family"]))
(operation "StructureMap/$transform")       ; an existing operation, by reference
(operation $validate)                       ; an existing operation value in scope (required first)
(operation $bmi #:system                    ; a new one: #:system, #:on Type, or #:on Type #:instance
  #:in ([weight decimal 1 1] [height decimal 1 1])
  #:out ([bmi decimal 1 1])
  #:handler bmi-handler)                    ; (lambda (in req) …) -> a resource, usually Parameters
```
A whole file — declarations, the handler and how to call it — is the worked example below.

### Resources and interactions
- Interactions: `read vread update patch delete history-instance history-type create search-type`.
  One the app does not declare answers 405 on a type it serves (404 for a type it does not).
- The language is FHIR **R6** (6.0.0-ballot): the CapabilityStatement says so, resources are typed
  by R6, and data written by an R4 workspace is read leniently. `(server #:date "2026-11-09")` sets
  the statement's date (else the time the server started).

### Search
- A search parameter is `[name type]` (the definition FHIR gives that name for the type: `birthdate`,
  `gender`, `patient`, `subject`, `code`, `date`, … — a name FHIR does not define, or a wrong type, is
  an error at its `(resource …)` form when the app loads, naming the nearest:
  `study.capability.rkt:3:0: resource Patient: search parameter `birthDate`: FHIR defines none of
  that name for Patient (did you mean `birthdate`?)`) or `[name type "FHIRPath"]` (your own). Every
  mistake in the declarations is reported at once, one line each at its form. Types:
  `token string reference date number quantity uri`. The server searches with exactly what it
  declares (what `/metadata` advertises, plus `_id`, `_lastUpdated`, `_count`, `_sort`): a search with
  any other parameter — even one FHIR defines, like `name` when only `gender` is declared — answers its
  matches without it and says so: an OperationOutcome entry (`search.mode` outcome) in the Bundle. A
  client that sends `Prefer: handling=strict` gets a 400 naming the parameter instead, and
  `(server #:search-handling "strict")` makes every search strict, whatever the client prefers — for
  a server where a misspelt or undeclared patient filter (`subject` where `patient` is declared) must
  never answer every patient's data. A searchset carries each entry's `fullUrl` and a `self` link
  (from the request's Host), so it validates as FHIR. A stored type also answers `_include=Observation:subject` (and `_revinclude`) over its declared reference
  parameters, the included resources marked `search.mode` include; the statement does not list them
  (`searchInclude`). A reference parameter takes FHIR's type modifier:
  `subject:Patient=123` is `subject=Patient/123`, and a bare id (`subject=123`) matches a
  reference to any type with that id.

### The store
- A resource without `#:repository` is kept in the store: the workspace's when the workspace serves
  it, else `#:store`'s file beside the module, else (no store anywhere) a temporary SQLite file
  removed when the server stops — searched, versioned and validated the same way. A
  create or update is validated as sent (its base type, the profiles it claims): an error refuses it
  with 422 and every issue, so nothing is stored with fields it could not read. A create answers 201
  with `Location: Type/id/_history/1`; a body of another type than the endpoint's is a 400.

### Operations: inputs and outputs
| an input's option | what it does |
|---|---|
| `[name type min max]` | the name, a FHIR type, the count (`1 1` required, `0 1` optional, `0 *` a list) |
| `#:binding "<ValueSet url or VCL>"` | a `code` input refused outside the value set |
| `#:min n` / `#:max n` | a number refused outside the range |
| `#:documentation "…"` | what the input means (its unit), in the OperationDefinition |

One operation using every option — the eGFR equation (CKD-EPI 2021), its inputs typed, documented,
bounded and bound, its output a Quantity:
```racket
(define (egfr-handler in req)
  (define (input k) (car (hash-ref in k)))          ; each declared input, already typed
  (define scr (input "creatinine")) (define age (input "age")) (define female? (equal? (input "sex") "female"))
  (define r (/ scr (if female? 0.7 0.9)))
  (define v (* 142 (expt (min r 1) (if female? -0.241 -0.302)) (expt (max r 1) -1.200)
               (expt 0.9938 age) (if female? 1.012 1)))
  (Parameters (parameter (ParametersParameter (name "egfr")
                           (valueQuantity (Quantity (value (/ (round (* v 10)) 10.0)) (unit "mL/min/1.73m2")
                                                    (system "http://unitsofmeasure.org") (code "mL/min/{1.73_m2}")))))))
(operation $egfr #:system
  #:in ([creatinine decimal 1 1 #:min 0.1 #:max 20 #:documentation "Serum creatinine, mg/dL"]
        [age integer 1 1 #:min 18 #:max 120 #:documentation "Age in years"]
        [sex code 1 1 #:binding "(http://hl7.org/fhir/administrative-gender)(female;male)"
             #:documentation "The equation's sex: female or male"])
  #:out ([egfr Quantity 1 1 #:documentation "Estimated GFR, mL/min/1.73m2"])
  #:handler egfr-handler)
```
`GET /$egfr?creatinine=1.1&age=60&sex=female` answers 57.5 mL/min/1.73m2; `creatinine=0&sex=other`
is a 400 with one issue per input (below its range; not in the binding), before the handler runs.

Values arrive converted to their declared type, from a GET query or a POSTed Parameters alike: a
whole decimal (`60.0`) is taken as an `integer` and a number as a `decimal`; text that does not read
as the type (`60.5` for an integer, `abc` for a decimal) is refused with a 400.

- An input or output is `[name type min max]`, `max` a number or `*`. Its type is a FHIR primitive —
  `integer`, `decimal`, `boolean`, `string`, `code`, `date`, `dateTime`, `uri` (also `positiveInt`,
  `unsignedInt`, `instant`, `time`, `id`, `markdown`, …) — or a datatype or resource: `Quantity`,
  `Coding`, `CodeableConcept`, `Reference`, `Period`, `Identifier`, `Patient`, `Observation`, `Bundle`, …
  A misspelt type is a declaration error naming the nearest (`int`: "did you mean `integer`?").
- A `code` input may be bound to a value set: `[sex code 1 1 #:binding
  "http://hl7.org/fhir/ValueSet/administrative-gender"]` refuses any other code with a 400 naming the
  codes it takes, before the handler runs (the value set is expanded from the packages or the
  registered ones; one that does not expand checks nothing). A subset is written inline as VCL:
  `#:binding "(http://hl7.org/fhir/administrative-gender)(female;male)"` takes `female` and `male`
  and refuses `other` (it is FHIR's implicit value set `http://fhir.org/VCL?v1=…`; learn://vcl).
  Otherwise check the value in the handler and return an `invalid` OperationOutcome. Any input or output may say what it means:
  `[creatinine decimal 1 1 #:documentation "Serum creatinine, mg/dL"]` is the parameter's
  `documentation` in the derived OperationDefinition (a client reads the unit there). A number may
  declare its range: `[creatinine decimal 1 1 #:min 0.1 #:max 20]` refuses `0` with a 400 before the
  handler runs (FHIR's minValue/maxValue extensions on the parameter). Every problem with a request's
  inputs is answered at once: an OperationOutcome issue each, its input named in `expression`
  (`["weight"]`); a handler that raises answers 500 naming the handler and
  how to refuse an input instead.
- A handler receives `in`, a hash from each input's name to its list of values, typed by the
  declaration and the same over GET (`?weight=80.5`) and POST (a Parameters body): `integer` an exact
  integer, `decimal` a Racket real, `boolean` `#t`/`#f`, `string`/`code`/`uri`/`date`/`dateTime` the
  text as sent, a resource a typed node. An output is built the same way round: `(valueDecimal 24.7)`
  takes the Racket real (round it yourself: `(/ (round (* bmi 10)) 10.0)`), `(valueInteger 3)`,
  `(valueString "…")`; a decimal STRING works too when it is FHIR's (`"24.7"`), but
  `(real->decimal-string v 0)` gives `"58."`, which FHIR does not read. A value that is not of its type, or an input the declaration
  does not name (`weigth`: "did you mean `weight`?"), is answered 400 before the handler runs. Each
  operation's derived OperationDefinition is served at `GET /OperationDefinition/<code>` (and all of
  them at `GET /OperationDefinition`), so a client can read what `$bmi` takes. Its url is
`urn:fhir-capability:operation:<code>` (the app's operations are found in-process by it), not under
the server's `#:url`. The handler returns a resource built with the R6 forms
  (`(Parameters (parameter (ParametersParameter (name "x") (valueString "…"))))`). A repeating field
  takes all its values in ONE form — two outputs are
  `(Parameters (parameter (ParametersParameter (name "egfr") (valueDecimal 57.5)) (ParametersParameter (name "stage") (valueString "G3a"))))`,
  not two `(parameter …)` forms (that is a "duplicate field" error). To refuse a request
  (400), return an OperationOutcome whose issue code is `invalid`:
  `(OperationOutcome (issue (OperationOutcomeIssue (severity "error") (code "invalid") (diagnostics "…"))))`;
  `processing` answers 422, `not-found` 404. An exception becomes a 500 OperationOutcome.

### $validate
- `(operation $validate)` serves `POST /<Type>/$validate` (and `/<Type>/<id>/$validate`) for every
  declared type, not `POST /$validate`: FHIR defines it on resources. The resource must be of the
  endpoint's type (an Observation POSTed to `/Patient/$validate` is a 400 saying where to send it).
  At instance level, a body (or Parameters `resource`) is the resource checked, as an update of the
  stored one; no body, or `{}`, checks the stored resource. `mode` is accepted and changes nothing:
  every mode (create, update, delete) checks the resource as just said.
- `$validate` takes the resource in a Parameters (`resource`) or as the bare POST body, and reads it
  as sent: a misspelt element or a bad date is reported, as `raco fhir-validate` reports it. It
  answers 200 either way, its findings in the OperationOutcome (its result IS an OperationOutcome).
- It validates in the server's own FHIR, R6 (`All OK (FHIR R6 (6.0.0-ballot4))`), as a create or
  update does before writing; `raco fhir-validate --fhir-version 6.0.0` gives the same answer offline.

### Creates and existing operations
- A create answers 201 with an absolute `Location` (`http://host:port/Patient/<id>/_history/1`). The
  id is the server's: one sent with `POST` is ignored, as FHIR says. To choose it, `PUT /Patient/ann`
  (with `update` declared) creates `Patient/ann`. From a script, the id is the `Location` header's
  path after the type: `curl -si -X POST … | sed -n 's|^Location: .*/Patient/\([^/]*\)/_history.*|\1|p'`.
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
(require (only-in fhir/conformance/operations $validate)
         (only-in fml/operations))                 ; loads StructureMap/$transform, served below

(server #:url "http://example.org/clinic" #:search-handling "strict")   ; patient data: refuse a filter it cannot apply

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
  (Parameters (parameter (ParametersParameter (name "bmi") (valueDecimal (/ (round (* bmi 10)) 10.0))))))
(operation $bmi #:system
  #:in ([weight decimal 1 1] [height decimal 1 1])
  #:out ([bmi decimal 1 1])
  #:handler bmi-handler)
```

In a workspace, as `clinic.capability.rkt`:
- `write` answers its problems: with `Observaton` for `Observation`,
  `clinic.capability.rkt:9:11 error: resource: unknown resource type Observaton`.
- `run` serves it and answers its url and what it serves; the server reads and writes the
  workspace's `fhir.db`, so `stage`/`commit`, search, CQL and SQL see the same data.
- `apply("$bmi", {"weight": 80, "height": 180})` calls the running app: `{"bmi": 24.7}` in a
  Parameters resource. Any HTTP client works too: `curl <url>/metadata`, `POST <url>/Patient`. From
  the shell (`raco fhir-mcp call`), each call is a process of its own and the app `run` served ends
  with it: serve the app with `raco fhir-server serve` and pass its url,
  `apply(operation: "$bmi", url: "http://localhost:8080", inputs: …)`.
- `explain(ref: "clinic.capability.rkt", subject: "Patient")` shows what it declares for a type.

On the command line: `racket clinic.capability.rkt` prints the CapabilityStatement (and creates no
store: the store file is made when a resource is first read or written);
`raco fhir-server serve clinic.capability.rkt --port 8080 --store fhir.db` serves it (`--port 0`
takes a free port; a bare `8080` after the file means the same). It prints
`FHIR server on http://localhost:8080  (Ctrl-C, or kill <pid>, to stop)` and `store: <file>` once it
is listening — that first line is the signal a script waits for, and it names the port when 0 was
asked; a port in use is one line saying so (exit 1); `--log` prints one
line per request (`GET /Patient?gender=female 200`) on stderr. `--store` wins over the module's own
`(server #:store …)`, which is beside the module; with neither, resources live in a temporary SQLite
file removed when the server stops.
`raco fhir-server sql fhir.db "SELECT id, resource ->> '$.gender' AS gender FROM Patient"` reads the
store as CSV, read-only: a view per stored type (`id, versionId, lastUpdated, resource`), `resources`
(every type: `type, id, versionId, lastUpdated, resource`) and `history` (every version, the same
columns); `resource` is the JSON (`resource ->> '$.birthDate'`). For tables of values you will ask
for again, make the store a workspace's data (`data: fhir.db` in workspace.yaml) and write SQL on FHIR
views: each `*.view.json` is a table, its columns FHIRPath (learn://sql-on-fhir).

A server needs no workspace: the file, `raco fhir-server serve`, and any HTTP client. A smoke test
on a free port — start it, wait for its first line, read the url from it:
```sh
raco fhir-server serve clinic.capability.rkt --port 0 --store fhir.db --log > serve.log 2>&1 &
until grep -q '^FHIR server on' serve.log; do sleep 0.5; done
BASE=$(sed -n 's/^FHIR server on \(http[^ ]*\).*/\1/p' serve.log)
curl -s $BASE/metadata | head -c 200
curl -s -X POST $BASE/Patient -H 'Content-Type: application/fhir+json' \
     -d '{"resourceType":"Patient","gender":"female","name":[{"family":"Ng"}]}'
curl -s "$BASE/Patient?gender=female"
curl -s "$BASE/\$bmi?weight=80&height=180"
kill $(sed -n 's/.*kill \([0-9]*\).*/\1/p' serve.log)     # the pid the banner names (works from any shell)
```
The banner's `search:` line says how a search with a parameter the app does not declare is answered
(strict here). The store is SQLite in WAL mode: `fhir.db-wal` and `fhir.db-shm` beside `fhir.db` after
a `kill` are normal — the next open (or `raco fhir-server sql`) reads them, and nothing is lost.

## An output with a unit
A clinical result is a Quantity, its unit in UCUM: declare the output `Quantity` and build one.
Here, serum creatinine in mg/dL converted to µmol/L (× 88.4):
```racket
(define (creatinine-si-handler in req)
  (define mg/dl (car (hash-ref in "creatinine")))     ; a decimal arrives as a Racket number (1.1)
  (Parameters (parameter (ParametersParameter (name "creatinine")
                           (valueQuantity (Quantity (value (/ (round (* 88.4 mg/dl 10)) 10.0))   ; 97.2
                                                    (unit "µmol/L")
                                                    (system "http://unitsofmeasure.org")
                                                    (code "umol/L")))))))
(operation $creatinine-si #:system
  #:in ([creatinine decimal 1 1 #:documentation "Serum creatinine, mg/dL"])
  #:out ([creatinine Quantity 1 1 #:documentation "The same value in µmol/L"])
  #:handler creatinine-si-handler)
```
Common UCUM codes for a result, each with a display for `unit` (learn://fhir lists more):

| result | `code` (UCUM) | `unit` (display) |
|---|---|---|
| eGFR | `mL/min/{1.73_m2}` | `mL/min/1.73m2` |
| creatinine | `mg/dL`, `umol/L` | `mg/dL`, `µmol/L` |
| glucose | `mg/dL`, `mmol/L` | `mg/dL`, `mmol/L` |
| HbA1c | `%` | `%` |
| BMI | `kg/m2` | `kg/m2` |
| blood pressure | `mm[Hg]` | `mmHg` |

A code that is not UCUM is a validation warning naming the nearest one; the `unit` is free text.
`GET /$creatinine-si?creatinine=1.1` answers `{"name": "creatinine", "valueQuantity": {"value": 97.2,
"unit": "µmol/L", "system": "http://unitsofmeasure.org", "code": "umol/L"}}` (the value is the
rounded Racket real; the unit is the display, the code is UCUM's; elements in FHIR's order).

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
