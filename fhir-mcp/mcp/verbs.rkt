#lang racket/base

;;; verbs.rkt — the workspace's tools: nine verbs, whatever the number of languages.
;;;
;;;   write    save a file, answer its problems          check    every problem in the workspace
;;;   run      a file against the data -> result://rN    query    an expression without a file
;;;   explain  why one subject's answer is what it is    describe anything by reference, results paged
;;;   apply    any FHIR operation                        stage / commit   validated, diffed writes to the data
;;;
;;; Each verb is a Tool (fhir/lang/support) over a Hub (workspace.rkt). A result is JSON text; a
;;; failure is {error, problem?} (a positioned diagnostic when there is one) or the OperationOutcome,
;;; with error? true. Nothing raises.

(require racket/contract racket/list racket/string json
         (only-in "tools.rkt" tool)
         (only-in fhir/serialize/fhir-json key-order fhir-json->string)
         (only-in fhir/diagnostic exn:fail:diagnostic? exn:fail:diagnostic-diagnostic diagnostic->jsexpr diagnostic-message)
         (only-in fhir/operation exn:fail:operation? exn:fail:operation-outcome)
         "workspace.rkt")

(provide (contract-out [workspace-tools (-> hub? list?)]))

;; answer : thunk -> (values text error?)
(define (answer thunk)
  (with-handlers ([exn:fail:diagnostic? (lambda (e) (values (jsexpr->string (hasheq 'error (diagnostic-message (exn:fail:diagnostic-diagnostic e))
                                                                                     'problem (diagnostic->jsexpr (exn:fail:diagnostic-diagnostic e))))
                                                            #t))]
                  [exn:fail:operation? (lambda (e) (values (jsexpr->string (exn:fail:operation-outcome e)) #t))]
                  [exn:fail? (lambda (e) (values (jsexpr->string (hasheq 'error (strip-who (exn-message e)))) #t))])
    (define v (thunk))
    (values (if (text-answer? v) (text-answer-text v) (answer-json v)) #f)))

;; answer-json : jsexpr -> string   JSON text in which a table's rows list their keys in the table's
;; column order (`rows` beside `columns`), as the CSV does: a hash's keys come out in no order, and a
;; reader of `{"mean_diastolic": …, "mean_systolic": …, "patient": …}` reads the columns backwards
(define (answer-json v)
  (let loop ([v v] [order #f])
    (cond
      ;; a resource (an operation's Parameters, a described Patient) in FHIR's element order, as the
      ;; server answers it (`apply` printed a Quantity's code, system, unit, value)
      [(and (hash? v) (string? (hash-ref v 'resourceType #f))) (fhir-json->string v)]
      [(hash? v)
       (define cols (let ([c (hash-ref v 'columns #f)]) (and (list? c) (andmap string? c) (map string->symbol c))))
       (define ks (hash-keys v))
       ;; a Quantity or Coding inside an answer (an explain's value) in FHIR's element order too
       (define datatype-order
         (cond [(and (hash-has-key? v 'value) (or (hash-has-key? v 'unit) (hash-has-key? v 'code))
                     (andmap (lambda (k) (memq k '(value comparator unit system code))) ks))
                '(value comparator unit system code)]
               [(and (hash-has-key? v 'code) (hash-has-key? v 'system)
                     (andmap (lambda (k) (memq k '(system version code display userSelected))) ks))
                '(system version code display userSelected)]
               [else #f]))
       (define keys (cond [order (append (filter (lambda (k) (hash-has-key? v k)) order)
                                         (sort (filter (lambda (k) (not (memq k order))) ks) symbol<?))]
                          [datatype-order (filter (lambda (k) (hash-has-key? v k)) datatype-order)]
                          [else (key-order ks)]))          ; resourceType, id, meta first, as FHIR writes them
       (string-append
        "{"
        (string-join (for/list ([k (in-list keys)])
                       (string-append (jsexpr->string (symbol->string k)) ":"
                                      (loop (hash-ref v k) (and (eq? k 'rows) cols))))
                     ",")
        "}")]
      [(list? v) (string-append "[" (string-join (for/list ([x (in-list v)]) (loop x order)) ",") "]")]
      [else (jsexpr->string v)])))
(define (strip-who m) (regexp-replace #px"^[a-z-]+: " m ""))

(define (str args k) (let ([v (hash-ref args k #f)]) (and (string? v) v)))
(define (need args k) (or (str args k) (error 'tool (format "the argument `~a` is required" k))))

(define (schema props required)
  (hasheq 'type "object" 'properties props 'required required))
(define (s desc) (hasheq 'type "string" 'description desc))
(define run-props
  (hasheq 'entry (s "CQL: one define to run (default: every define)")
          'over (s "what to run over: Patient/<id> for CQL; a type or Type/id for FHIRPath and FML (default: every patient, or the type the expression or map starts from)")
          'parameters (hasheq 'type "object" 'description "CQL parameters by name, each a CQL expression (\"Measurement Period\": \"Interval[@2025-01-01T00:00:00.000, @2025-12-31T23:59:59.999]\"); a Measure takes periodStart and periodEnd")
          'name (s "a name for the result, its table in SQL and result://<name> (default for run: the file's name, `diabetes` for diabetes.cql); the latest result of a name is the one read")
          'as (s "\"csv\": answer the result's rows as CSV (the result is kept and named all the same)")
          'columns (s "with as: \"csv\": the columns to keep, in order (\"patient,Latest Number,Latest Date\")")
          'sort (s "with as: \"csv\": the column to order rows by (\"Name\"; \"-Name\" descending)")))

;; as-csv : hub args answer-jsexpr -> answer   a run's or query's rows as CSV when asked (`run … as=csv
;; columns="Name,Latest Number"`: a CQL run's table in one call — it took a SQL query and a describe)
(define (as-csv h args a)
  (if (and (equal? (hash-ref args 'as #f) "csv") (hash? a) (string? (hash-ref a 'result #f)))
      (hub-describe h (hash-ref a 'result) (hasheq 'as "csv" 'columns (hash-ref args 'columns #f) 'sort (hash-ref args 'sort #f)))
      a))

(define (workspace-tools h)
  (list
   (tool "write"
         "Save a file in the workspace and get its problems back, each at its line and column: .fsh (FHIR Shorthand), .cql, .fhirpath, .vcl, .map/.fml, .view.json (a ViewDefinition), .json (any FHIR resource), sushi-config.yaml (the implementation guide), or workspace.yaml. Empty text deletes the file. With `ref` in place of `text`, the file is a stored definition as the text that states it, to edit: a profile or value set as FSH, a library as its CQL, the guide as sushi-config.yaml. Read learn://workspace first."
         (schema (hasheq 'path (s "the file's path, relative to the workspace") 'text (s "the whole file")
                         'ref (s "in place of text: a stored definition — its canonical (url, or url|version) or Type/id — written as the file that states it")
                         'enforce (hasheq 'type "boolean" 'description "FSH: list the file's profiles in workspace.yaml's `profiles`, so stage and check(data) hold data to them"))
                 '("path"))
         (lambda (args)
           (answer (lambda ()
                     (define ref (hash-ref args 'ref #f))
                     (if (and (string? ref) (not (string? (hash-ref args 'text #f))))
                         (hub-edit! h (need args 'path) ref)
                         (hub-write! h (need args 'path) (let ([t (hash-ref args 'text #f)]) (if (string? t) t (need args 'text)))
                                     #:enforce? (memq (hash-ref args 'enforce #f) '(#t "true"))
                                     #:from (let ([fs (hash-ref args 'files #f)]) (and (hash? fs) (let ([f (hash-ref fs 'text #f)]) (and (string? f) f))))))))))
   (tool "check"
         "Every problem in the workspace (or in the files named), each at its file, line and column, with the workspace's configuration: FHIR version, packages, data. With data: true, also every stored resource held to its base type and the workspace's profiles (workspace.yaml `profiles`), violations counted by rule."
         (schema (hasheq 'paths (hasheq 'type "array" 'items (hasheq 'type "string") 'description "files to check (default: all)")
                         'data (hasheq 'type "boolean" 'description "also validate the stored data against the workspace's constraints"))
                 '())
         (lambda (args) (answer (lambda () (hub-check h (let ([ps (hash-ref args 'paths '())]) (if (list? ps) (filter string? ps) '()))
                                                      #:data? (eq? (hash-ref args 'data #f) #t))))))
   (tool "run"
         "Run a workspace file against the data: CQL -> every define per patient; FHIRPath -> the value per resource; VCL -> the expansion; FML -> each source transformed and validated; a ViewDefinition -> its rows; FSH -> the resources it defines, examples validated; a Measure -> its populations. Answers a summary, the first rows and a handle (result://rN, and result://<name>: the file's name unless `name` says otherwise) for describe, explain and SQL."
         (schema (hash-set run-props 'path (s "the file, relative to the workspace")) '("path"))
         (lambda (args) (answer (lambda () (as-csv h args (hub-run h (need args 'path) args))))))
   (tool "query"
         "Ask once without saving a file. language: fhirpath (an expression; `over` a type or Type/id), cql (an expression, evaluated per patient, or a whole library), vcl (an expression, expanded), search (Type?name=value…, a FHIR search over the data, files included), view (a ViewDefinition as JSON), sql (one SELECT over the tables: each *.view.json by its file name or `name`, earlier results by their names — a run of diabetes.cql is `diabetes`, a query given `name` that name — and as r1, r2 …; group, join, count, average). Answers like run."
         (schema (hash-set* run-props 'language (hasheq 'type "string" 'enum '("fhirpath" "cql" "vcl" "search" "view" "sql"))
                            'text (s "the expression, library, search, view or SQL statement")
                            'strict (hasheq 'type "boolean" 'description "search: refuse a search with a parameter it cannot apply (by default the answer lists them as `ignored`)"))
                 '("language" "text"))
         (lambda (args) (answer (lambda () (as-csv h args (hub-query h (need args 'language) (need args 'text) args))))))
   (tool "explain"
         "Why one subject's answer is what it is, step by step and positioned in the source: a CQL define down through the defines it uses to the retrieves (how many resources of the type the patient has, which were kept); every part of a FHIRPath expression; which part of a VCL expression holds a code; a view's where clauses; a map's result and its problems traced to rules; an FSH entity's problems."
         (schema (hasheq 'ref (s "a result (result://rN) or a workspace file")
                         'subject (s "Patient/<id> (CQL), Type/id or id (FHIRPath, FML, views), system|code (VCL), an entity name (FSH)")
                         'entry (s "CQL: the define to explain (default: every define's value)"))
                 '("ref" "subject"))
         (lambda (args) (answer (lambda () (hub-explain h (need args 'ref) (need args 'subject) args)))))
   (tool "describe"
         "Read anything by reference: result://rN (paged with offset and limit; as CSV with as: \"csv\"; compared with another result by `against`), \"stages\" (the stages not committed), Type/id (data, then what the workspace defines), a canonical url, a type or element (Observation, Observation.component.code), an operation ($expand, ValueSet/$validate-code) and its inputs, or a fragment of a definition's name or url."
         (schema (hasheq 'ref (s "what to describe")
                         'offset (hasheq 'type "integer" 'description "results: the first row")
                         'limit (hasheq 'type "integer" 'description "results: at most this many rows (default 20)")
                         'against (s "results: an earlier result to compare with")
                         'columns (s "results as CSV: the columns to keep, in order (\"Name,Latest Number\")")
                         'sort (s "results as CSV: the column to order rows by (\"-Name\" descending)")
                         'as (s "\"fsh\": a resource (Type/id, a canonical) as an FSH Instance, shorter than JSON for coded data; \"csv\": a result's rows as CSV (default limit 1000), the compact form of a table; \"source\": the text a commit's Provenance (or a DocumentReference, a Binary) carries, decoded — on Type/id, the FSH Instance that wrote it; \"trail\" on a type (Observation): every stored one with who, when, why and the file and line it came from, as CSV"))
                 '("ref"))
         (lambda (args) (answer (lambda () (hub-describe h (need args 'ref) args)))))
   (tool "apply"
         "Apply a FHIR operation ($validate, $expand, $lookup, $validate-code, $translate, $subsumes, $snapshot, $transform, $evaluate-measure, $sql-run, …) in the workspace's context. describe(\"$code\") lists its inputs."
         (schema (hasheq 'operation (s "$code, Type/$code, or the OperationDefinition's url")
                         'inputs (hasheq 'type "object" 'description "the operation's input parameters by name")
                         'resource (hasheq 'type "object" 'description "the resource the operation applies to, as JSON")
                         'url (s "a FHIR server's base url to apply it on (a capability app served with raco fhir-server serve)"))
                 '("operation"))
         (lambda (args) (answer (lambda () (hub-apply h (need args 'operation)
                                                      (let ([i (hash-ref args 'inputs (hasheq))]) (if (hash? i) i (hasheq)))
                                                      (let ([r (hash-ref args 'resource #f)]) (and (hash? r) r))
                                                      (let ([u (hash-ref args 'url #f)]) (and (string? u) u)))))))
   (tool "stage"
         "Prepare a write to the data: resources given as JSON or as FSH Instances (`fsh`), the resources of a run (result://rN, an FML transform), an FSH file's example instances, or a JSON file — or the workspace's implementation guide (`path: sushi-config.yaml`): the guide, every definition its files make and their examples, as one. Each is validated and compared with the data's copy (create, update with what changed as `path: old → new`, unchanged); a resource with an id the data holds is an update. A definition takes its guide's version and status, is held to CRMI's Shareable profile, and once active does not change without a new version. Nothing is written until commit. `drop` discards a stage."
         (schema (hasheq 'resources (hasheq 'type "array" 'items (hasheq 'type "object") 'description "FHIR resources (or Bundles)")
                         'fsh (s "FSH Instances, as text: the compact way to write resources")
                         'result (s "a result whose rows hold resources")
                         'path (s "an FSH file (its instances), a JSON file, or sushi-config.yaml (the whole guide)")
                         'definitions (hasheq 'type "boolean" 'description "true: stage what an FSH text or file defines too (profiles, value sets), not its instances alone")
                         'drop (s "a stage id to discard instead, \"latest\", \"refused\" (every stage with errors) or \"all\" (describe(\"stages\") lists the stages not committed)")
                         'keep (hasheq 'type "boolean" 'description "false: check only — the same answer (changes, errors, warnings), and nothing kept to commit or drop"))
                 '())
         (lambda (args) (answer (lambda () (hub-stage! h args)))))
   (tool "commit"
         "Write a stage to the data: the workspace's SQLite store (one transaction), a directory, or a FHIR server when workspace.yaml allows writes. A stage with validation errors is refused. It leaves a Provenance (the versions written, the agent, the reason, the source text with its hash) and an AuditEvent in the data."
         (schema (hasheq 'stage (s "the stage id from stage, or latest")
                         'reason (s "why: recorded in the Provenance (Provenance.reason)")
                         'agent (s "who is writing, for the Provenance and AuditEvent (default: the MCP client, or FHIR_MCP_AGENT)"))
                 '("stage"))
         (lambda (args) (answer (lambda () (hub-commit! h (need args 'stage) (let ([r (hash-ref args 'reason #f)]) (and (string? r) r))
                                                       #:agent (let ([a (hash-ref args 'agent #f)]) (and (string? a) a)))))))))

(module+ test
  (require rackunit)
  ;; a Quantity inside an answer reads value, unit, system, code (an explain printed them alphabetically)
  (check-equal? (answer-json (hasheq 'value (hasheq 'code "%" 'system "http://unitsofmeasure.org" 'unit "%" 'value 8.9)))
                "{\"value\":{\"value\":8.9,\"unit\":\"%\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"%\"}}"))
