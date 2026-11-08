#lang racket/base

;;; tools.rkt — the tools an MCP server offers, as a catalogue.
;;;
;;; A Tool is (tool name description input-schema run):
;;;   name         : ^[a-zA-Z0-9_-]{1,64}$ (the protocol's rule)
;;;   description  : for the model that calls it
;;;   input-schema : a JSON Schema object for the arguments
;;;   run          : arguments(hash) -> (values text error?)   the result as text (JSON for FHIR
;;;                  resources, the family's diagnostic text otherwise); error? when it failed
;;; Three kinds: every registered FHIR operation (fhir/operation) is a tool whose schema comes from its
;;; OperationDefinition — its `in` parameters as properties, those with min 1 required; each installed
;;; language's own tools (its `<id>/support`, fhir/lang/support: check / compile / evaluate), plus
;;; diagnose_file over any language; and the definition tools over the packages in context. The Tool
;;; struct is the contract's. A run never raises: a failure is its OperationOutcome or message, with
;;; error? true.

(require racket/contract racket/string racket/list racket/match json
         (only-in fhir/lang/support tool tool? tool-name tool-description tool-input-schema tool-run
                  installed-supports lang-support-tools language-support diagnostics-result text-schema string-arg missing)
         (only-in fhir/operation operation? operation-definition operation-code operation-subject operation-url
                  operation-resource-types registered-operations invoke exn:fail:operation? exn:fail:operation-outcome)
         (only-in fhir/lsp/languages language-of diagnose)
         (only-in fhir/sd/sd-index resolve-sd-raw resolve-canonical-raw sd-index-available? sd-context current-sd-packages)
         (only-in fhir/package read-package)
         (only-in fhir/data-source current-data-source data-source-all data-source-read))

(provide
 tool tool? tool-name tool-description tool-input-schema tool-run
 (contract-out
  [operation->tool   (-> operation? (listof operation?) tool?)]
  [operation-tools   (-> (listof tool?))]
  [language-tools    (-> (listof tool?))]
  [definition-tools  (-> (listof tool?))]
  [all-tools         (-> (listof tool?))]
  [tool->jsexpr      (-> tool? hash?)]
  [call-tool         (-> tool? hash? (values string? boolean?))]
  [load-operations!  (-> (listof symbol?))]
  ;; find-definitions : fragment resourceType|#f limit -> summaries   over the packages in context
  [find-definitions  (-> string? (or/c string? #f) exact-positive-integer? list?)]))

(define (tool->jsexpr t)
  (hasheq 'name (tool-name t) 'description (tool-description t) 'inputSchema (tool-input-schema t)))

;; call-tool : tool arguments -> (values text error?)   never raises
(define (call-tool t args)
  (with-handlers ([exn:fail:operation? (lambda (e) (values (jsexpr->string (exn:fail:operation-outcome e)) #t))]
                  [exn:fail? (lambda (e) (values (exn-message e) #t))])
    ((tool-run t) args)))

;; ---- FHIR operations as tools ----------------------------------------------------------------
;; the modules that register operations, each loaded when its package is installed
(define operation-modules
  '(fhir/sd/operations fhir/conformance/operations fhir/terminology/operations
    fml/operations cql/measure sql-on-fhir/operations))
;; load-operations! : -> the modules loaded
(define (load-operations!)
  (for/list ([m (in-list operation-modules)]
             #:when (with-handlers ([exn:fail? (lambda (_) #f)]) (dynamic-require m #f) #t))
    m))

;; the JSON Schema type of a FHIR parameter type
(define (schema-type t)
  (cond [(not t) (hasheq)]
        [(member t '("integer" "positiveInt" "unsignedInt" "integer64")) (hasheq 'type "integer")]
        [(equal? t "decimal") (hasheq 'type "number")]
        [(equal? t "boolean") (hasheq 'type "boolean")]
        [(member t '("string" "code" "uri" "url" "canonical" "id" "oid" "uuid" "date" "dateTime" "instant"
                     "time" "markdown" "base64Binary")) (hasheq 'type "string")]
        [else (hasheq 'type "object" 'description (format "a FHIR ~a, as JSON" t))]))

;; operation->tool : operation all-operations -> tool   the name is fhir_<code>, qualified by the
;; resource type when several operations share the code
(define (operation->tool o all)
  (define code (operation-code o))
  (define shared? (> (length (filter (lambda (x) (equal? (operation-code x) code)) all)) 1))
  (define name (tool-name* (if shared? (string-append (string-join (operation-resource-types o) "_") "_" code) code)))
  (define od (operation-definition o))
  (define ins (for/list ([p (in-list (hash-ref od 'parameter '()))] #:when (equal? (hash-ref p 'use #f) "in")) p))
  (define subject (operation-subject o))
  (define properties
    (for/hash ([p (in-list ins)])
      (define doc (hash-ref p 'documentation #f))
      (define base (schema-type (hash-ref p 'type #f)))
      (define many? (not (equal? (hash-ref p 'max "1") "1")))
      (define typed (if many? (hasheq 'type "array" 'items base) base))
      (values (string->symbol (hash-ref p 'name))
              (if doc (hash-set typed 'description doc) typed))))
  ;; an operation applied to the subject itself (instance level) takes it as `resource`
  (define properties* (if subject properties
                          (hash-set properties 'resource (hasheq 'type "object" 'description "the resource the operation applies to, as JSON"))))
  (define required (for/list ([p (in-list ins)] #:when (let ([m (hash-ref p 'min 0)]) (and (number? m) (>= m 1)))) (hash-ref p 'name)))
  (define description
    (string-trim (string-append (or (hash-ref od 'title #f) (string-append "$" code)) ". "
                                (or (hash-ref od 'description #f) "")
                                (format " FHIR operation ~a~a." (operation-url o)
                                        (if (pair? (operation-resource-types o)) (format " on ~a" (string-join (operation-resource-types o) ", ")) "")))))
  (tool name description
        (let ([sch (hasheq 'type "object" 'properties properties*)]) (if (pair? required) (hash-set sch 'required required) sch))
        (lambda (args)
          (define inputs (for/hash ([(k v) (in-hash args)] #:unless (and (not subject) (eq? k 'resource)))
                           (values (symbol->string k) (if (list? v) v (list v)))))
          (define subj (and (not subject) (hash-ref args 'resource #f)))
          (values (jsexpr->string (invoke o subj inputs)) #f))))

(define (tool-name* s) (regexp-replace* #px"[^A-Za-z0-9_-]" (string-append "fhir_" s) "_"))

(define (operation-tools)
  (define all (registered-operations))
  (for/list ([o (in-list all)]) (operation->tool o all)))

;; ---- the languages ---------------------------------------------------------------------------
;; diagnose_file over any language, then what each installed language offers (fsh_check,
;; fsh_compile, fsh_decompile, cql_elm, cql_evaluate, vcl_valueset, fhirpath_evaluate, …)
(define (language-tools)
  (cons
   (tool "diagnose_file"
         "The problems in a file of one of the FHIR languages (.fsh, .cql, .fml/.map, .vcl, .fhirpath), as the family's diagnostics: file:line:col and a message. An FSH file is checked with its project."
         (text-schema 'path "the file's path")
         (lambda (args)
           (define p (string-arg args 'path))
           (cond [(not p) (missing 'path)]
                 [(not (file-exists? p)) (values (format "no such file: ~a" p) #t)]
                 [else (define l (language-of p))
                       (if l (diagnostics-result (diagnose l (call-with-input-file p (lambda (in) (read-string 100000000 in))) p))
                           (values (format "~a is not a file of a language served" p) #t))])))
   (append-map lang-support-tools (installed-supports))))

;; ---- the definitions: what an agent writing FHIR asks about ---------------------------------
(define (definition-tools)
  (list
   (tool "fhir_element"
         "Describe an element of a FHIR type or profile from the packages in context: path, cardinality, types, binding, short and definition. `type` is a resource or datatype name (Observation) or a profile url; `path` is dotted from the type (component.code, value[x]); without a path, the type's own elements one level down."
         (hasheq 'type "object"
                 'properties (hasheq 'type (hasheq 'type "string" 'description "a FHIR type name or a StructureDefinition url")
                                     'path (hasheq 'type "string" 'description "an element path below the type, dotted; omit for the top level"))
                 'required '("type"))
         (lambda (args)
           (define type (string-arg args 'type))
           (define path (string-arg args 'path))
           (cond
             [(not type) (missing 'type)]
             [(not (sd-index-available?)) (values "no FHIR packages are in context (install fhir-spec or pass --package)" #t)]
             [else
              (define sd (or (resolve-sd-raw type) (resolve-canonical-raw "StructureDefinition" type)))
              (define els (and (hash? sd) (hash-ref (hash-ref sd 'snapshot (hasheq)) 'element #f)))
              (cond
                [(not (list? els)) (values (format "no StructureDefinition with a snapshot for ~a" type) #t)]
                [else
                 (define root (hash-ref (car els) 'path type))
                 (define want (if path (string-append root "." path) root))
                 (define depth (length (string-split want ".")))
                 (define picked
                   (if path
                       (filter (lambda (e) (or (equal? (hash-ref e 'path "") want) (equal? (hash-ref e 'id "") want)
                                               (choice-of? (hash-ref e 'path "") want))) els)
                       (filter (lambda (e) (= (length (string-split (hash-ref e 'path "") ".")) (add1 depth))) els)))
                 (if (null? picked)
                     (values (format "~a has no element ~a" type path) #t)
                     (values (jsexpr->string (for/list ([e (in-list picked)]) (element-summary e))) #f))])])))
   (tool "fhir_find"
         "Find definitions in the FHIR packages in context by a fragment of their id, name or url: StructureDefinitions (profiles, extensions, types), ValueSets, CodeSystems, OperationDefinitions, SearchParameters. Answers resourceType, id, url, name, title, type and kind for each match."
         (hasheq 'type "object"
                 'properties (hasheq 'query (hasheq 'type "string" 'description "a case-insensitive fragment of the id, name or url")
                                     'resourceType (hasheq 'type "string" 'description "limit to one conformance resource type")
                                     'limit (hasheq 'type "integer" 'description "at most this many matches (default 50)"))
                 'required '("query"))
         (lambda (args)
           (define q (string-arg args 'query))
           (define rt (string-arg args 'resourceType))
           (define limit (let ([l (hash-ref args 'limit 50)]) (if (exact-positive-integer? l) l 50)))
           (cond
             [(not q) (missing 'query)]
             [(not (sd-index-available?)) (values "no FHIR packages are in context (install fhir-spec or pass --package)" #t)]
             [else (values (jsexpr->string (find-definitions q rt limit)) #f)])))
   (tool "data_resources"
         "What the data source in context holds (the --data directory): the ids of a type, or one resource by type and id."
         (hasheq 'type "object"
                 'properties (hasheq 'type (hasheq 'type "string" 'description "a resource type (Patient)")
                                     'id (hasheq 'type "string" 'description "an id; with it, the resource itself"))
                 'required '("type"))
         (lambda (args)
           (define type (string-arg args 'type))
           (define id (string-arg args 'id))
           (define ds (current-data-source))
           (cond [(not type) (missing 'type)]
                 [id (define r ((data-source-read ds) type id))
                     (if r (values (jsexpr->string r) #f) (values (format "no ~a/~a in the data source" type id) #t))]
                 [else (values (jsexpr->string (for/list ([r (in-list ((data-source-all ds) type))]) (hash-ref r 'id 'null))) #f)])))))

;; element-summary : ElementDefinition -> jsexpr   the parts an author needs
(define (element-summary e)
  (for/hasheq ([k '(id path min max type short definition binding sliceName fixedUri patternCodeableConcept)]
               #:when (hash-has-key? e k))
    (values k (hash-ref e k))))
;; choice-of? : element-path wanted -> boolean   "Observation.value[x]" answers for "Observation.valueQuantity"
(define (choice-of? el-path want)
  (and (regexp-match? #rx"\\[x\\]$" el-path)
       (let ([stem (substring el-path 0 (- (string-length el-path) 3))])
         (and (string-prefix? want stem) (> (string-length want) (string-length stem))
              (char-upper-case? (string-ref want (string-length stem)))))))
;; find-definitions : query type|#f limit -> (listof summary)   over every package in context, by the
;; resource file name (Type-id.json), then the resource's name, title and url
(define (find-definitions q rt limit)
  (define rx (regexp (regexp-quote (string-downcase q))))
  (define (hit? s) (and (string? s) (regexp-match? rx (string-downcase s))))
  (define kinds '("StructureDefinition" "ValueSet" "CodeSystem" "OperationDefinition" "SearchParameter" "CapabilityStatement" "ConceptMap"))
  (let/ec done
    (define found '())
    (for ([pkg (in-list (sd-context))])
      (define-values (_m rs _ex)
        (read-package pkg #:select (lambda (name)
                                     (define t (car (string-split name "-")))
                                     (and (member t kinds) (or (not rt) (equal? t rt)) (hit? name)))))
      (for ([fr (in-list rs)] #:when (and (pair? fr) (hash? (cdr fr))))     ; read-package gives (file . resource)
        (define r (cdr fr))
        (set! found (cons (for/hasheq ([k '(resourceType id url name title type kind derivation status)] #:when (hash-has-key? r k)) (values k (hash-ref r k))) found))
        (when (>= (length found) limit) (done (reverse found)))))
    (reverse found)))

(define (all-tools) (append (operation-tools) (language-tools) (definition-tools)))

(module+ test
  (require rackunit (only-in fhir/operation make-operation register-operation!))
  ;; an operation becomes a tool: its `in` parameters are the schema, min 1 required, the result JSON
  (define od (hasheq 'resourceType "OperationDefinition" 'url "http://example.org/OperationDefinition/greet" 'code "greet"
                     'title "Greet" 'description "Says hello."
                     'system #t 'type #f 'instance #f
                     'parameter (list (hasheq 'name "name" 'use "in" 'min 1 'max "1" 'type "string" 'documentation "whom to greet")
                                      (hasheq 'name "times" 'use "in" 'min 0 'max "*" 'type "integer")
                                      (hasheq 'name "return" 'use "out" 'min 1 'max "1" 'type "Parameters"))))
  (define $greet (make-operation od (lambda (in subject)
                                      (hasheq 'resourceType "Parameters"
                                              'parameter (list (hasheq 'name "result" 'valueString (format "hello ~a" (car (hash-ref in "name")))))))))
  (define t (operation->tool $greet (list $greet)))
  (check-equal? (tool-name t) "fhir_greet")
  (check-equal? (hash-ref (tool-input-schema t) 'required) '("name"))
  (check-equal? (hash-ref (hash-ref (tool-input-schema t) 'properties) 'times) (hasheq 'type "array" 'items (hasheq 'type "integer")))
  (check-regexp-match #rx"Says hello" (tool-description t))
  (define-values (text err?) (call-tool t (hasheq 'name "Ann")))
  (check-false err?)
  (check-regexp-match #rx"hello Ann" text)
  ;; a missing required input is the operation's outcome, flagged as an error, never an exception
  (define-values (text2 err2?) (call-tool t (hasheq)))
  (check-true err2?)
  (check-regexp-match #rx"OperationOutcome" text2)
  ;; two operations sharing a code are told apart by resource type
  (define od2 (hash-set* od 'url "http://example.org/OperationDefinition/Patient-greet" 'system #f 'type #t 'resource '("Patient")))
  (define $greet2 (make-operation od2 (lambda (in s) (hasheq 'resourceType "Parameters"))))
  (check-equal? (tool-name (operation->tool $greet2 (list $greet $greet2))) "fhir_Patient_greet")
  ;; language tools: diagnose_file always; each installed language's own; a missing file is an error
  (define by-name (for/hash ([x (in-list (language-tools))]) (values (tool-name x) x)))
  (check-true (hash-has-key? by-name "diagnose_file"))
  (when (language-support "fsh") (check-true (hash-has-key? by-name "fsh_compile")))
  (when (language-support "cql") (check-true (hash-has-key? by-name "cql_elm")))
  (define-values (t4 e4) (call-tool (hash-ref by-name "diagnose_file") (hasheq 'path "/nonexistent/x.fsh")))
  (check-true e4)
  (check-true (jsexpr? (tool->jsexpr t)))
  ;; the definition tools, over the R5 core when fhir-spec is installed
  (define defs (for/hash ([x (in-list (definition-tools))]) (values (tool-name x) x)))
  (check-equal? (sort (hash-keys defs) string<?) '("data_resources" "fhir_element" "fhir_find"))
  (when (sd-index-available?)
    (define-values (t5 e5) (call-tool (hash-ref defs "fhir_element") (hasheq 'type "Observation" 'path "component.code")))
    (check-false e5 t5)
    (check-equal? (hash-ref (car (string->jsexpr t5)) 'path) "Observation.component.code")
    (define-values (t6 e6) (call-tool (hash-ref defs "fhir_element") (hasheq 'type "Observation" 'path "valueQuantity")))
    (check-equal? (hash-ref (car (string->jsexpr t6)) 'path) "Observation.value[x]")
    (define-values (t7 e7) (call-tool (hash-ref defs "fhir_element") (hasheq 'type "Observation")))
    (check-true (> (length (string->jsexpr t7)) 10))
    (define-values (t8 e8) (call-tool (hash-ref defs "fhir_find") (hasheq 'query "administrative-gender" 'resourceType "ValueSet")))
    (check-false e8 t8)
    (check-true (ormap (lambda (r) (equal? (hash-ref r 'id #f) "administrative-gender")) (string->jsexpr t8))))
  (define-values (t9 e9) (call-tool (hash-ref defs "data_resources") (hasheq 'type "Patient")))
  (check-false e9) (check-equal? (string->jsexpr t9) '())
  (define-values (t10 e10) (call-tool (hash-ref defs "fhir_element") (hasheq)))
  (check-true e10))
