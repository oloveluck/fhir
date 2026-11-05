#lang racket/base

;;; tools.rkt — the tools an MCP server offers, as a catalogue.
;;;
;;; A Tool is (tool name description input-schema run):
;;;   name         : ^[a-zA-Z0-9_-]{1,64}$ (the protocol's rule)
;;;   description  : for the model that calls it
;;;   input-schema : a JSON Schema object for the arguments
;;;   run          : arguments(hash) -> (values text error?)   the result as text (JSON for FHIR
;;;                  resources, the family's diagnostic text otherwise); error? when it failed
;;; Two kinds: every registered FHIR operation (fhir/operation) is a tool whose schema comes from its
;;; OperationDefinition — its `in` parameters as properties, those with min 1 required — and the
;;; languages give check / compile / evaluate tools, loaded on demand like the language server's
;;; adapters. A run never raises: a failure is its OperationOutcome or message, with error? true.

(require racket/contract racket/string racket/list racket/match json
         (only-in fhir/operation operation? operation-definition operation-code operation-subject operation-url
                  operation-resource-types registered-operations invoke exn:fail:operation? exn:fail:operation-outcome)
         (only-in fhir/diagnostic diagnostic? diagnostic->jsexpr diagnostic->string diagnostic-severity)
         (only-in fhir/lsp/languages language-of diagnose))

(provide
 (struct-out tool)
 (contract-out
  [operation->tool   (-> operation? (listof operation?) tool?)]
  [operation-tools   (-> (listof tool?))]
  [language-tools    (-> (listof tool?))]
  [all-tools         (-> (listof tool?))]
  [tool->jsexpr      (-> tool? hash?)]
  [call-tool         (-> tool? hash? (values string? boolean?))]
  [load-operations!  (-> (listof symbol?))]))

(struct tool (name description input-schema run) #:transparent)

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
(define (lang-ref mod name) (with-handlers ([exn:fail? (lambda (_) #f)]) (dynamic-require mod name)))
(define (string-arg args k) (let ([v (hash-ref args k #f)]) (and (string? v) v)))
(define (missing k) (values (format "the argument '~a' is required" k) #t))
;; diagnostics-text : diagnostics -> (values text error?)   the family's one-line form, plus JSON
(define (diagnostics-result ds)
  (values (jsexpr->string (hasheq 'diagnostics (map diagnostic->jsexpr ds)
                                  'text (string-join (map diagnostic->string ds) "\n")))
          (ormap (lambda (d) (eq? (diagnostic-severity d) 'error)) ds)))

(define text-schema
  (lambda (k what) (hasheq 'type "object" 'properties (hasheq k (hasheq 'type "string" 'description what)) 'required (list (symbol->string k)))))

(define (language-tools)
  (list
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
   (tool "fsh_check"
         "Check an FSH project (a directory with sushi-config.yaml and .fsh files): compile it and validate every example against its profiles. Returns the diagnostics, each positioned in the FSH."
         (text-schema 'directory "the project directory")
         (lambda (args)
           (define dir (string-arg args 'directory))
           (define check (lang-ref 'fsh/check 'check-fsh-project))
           (define diags (lang-ref 'fsh/check 'check-report-diagnostics))
           (cond [(not dir) (missing 'directory)]
                 [(not check) (values "the fsh package is not installed" #t)]
                 [else (diagnostics-result (diags (check dir)))])))
   (tool "fsh_compile"
         "Compile FSH text (profiles, extensions, instances, value sets, code systems) to FHIR JSON resources. R5 with the default canonical base."
         (text-schema 'fsh "the FSH source")
         (lambda (args)
           (define src (string-arg args 'fsh))
           (define fsh->fhir (lang-ref 'fsh/compile 'fsh->fhir))
           (cond [(not src) (missing 'fsh)]
                 [(not fsh->fhir) (values "the fsh package is not installed" #t)]
                 [else (values (jsexpr->string (fsh->fhir src)) #f)])))
   (tool "cql_elm"
         "Translate a CQL library to ELM JSON. Errors are positioned diagnostics."
         (text-schema 'cql "the CQL source")
         (lambda (args)
           (define src (string-arg args 'cql))
           (define parse-cql (lang-ref 'cql/parser/parse 'parse-cql))
           (define compile-library (lang-ref 'cql/compile 'compile-library))
           (define elm->json-string (lang-ref 'cql/elm/json 'elm->json-string))
           (define err? (lang-ref 'fhir/result/result 'err?))
           (define ok-value (lang-ref 'fhir/result/result 'ok-value))
           (define err-error (lang-ref 'fhir/result/result 'err-error))
           (define cql-error-string (lang-ref 'cql/error 'cql-error-string))
           (cond [(not src) (missing 'cql)]
                 [(not parse-cql) (values "the cql package is not installed" #t)]
                 [else (define r (parse-cql src))
                       (cond [(err? r) (values (cql-error-string (err-error r)) #t)]
                             [else (define c (compile-library (ok-value r)))
                                   (if (err? c) (values (cql-error-string (err-error c)) #t)
                                       (values (elm->json-string (ok-value c)) #f))])])))
   (tool "cql_evaluate"
         "Evaluate a CQL library over one patient's FHIR resources (FHIR R4 JSON, the Patient among them); every definition's value by name. parameters: name to value."
         (hasheq 'type "object"
                 'properties (hasheq 'cql (hasheq 'type "string" 'description "the CQL source")
                                     'resources (hasheq 'type "array" 'items (hasheq 'type "object") 'description "the patient's resources as FHIR JSON")
                                     'parameters (hasheq 'type "object" 'description "the library's parameters by name"))
                 'required '("cql" "resources"))
         (lambda (args)
           (define src (string-arg args 'cql))
           (define rs (hash-ref args 'resources #f))
           (define ps (hash-ref args 'parameters (hasheq)))
           (define parse-cql (lang-ref 'cql/parser/parse 'parse-cql))
           (define evaluate-library (lang-ref 'cql/run 'evaluate-library))
           (define render (lang-ref 'cql/value 'render))
           (define err? (lang-ref 'fhir/result/result 'err?))
           (define ok-value (lang-ref 'fhir/result/result 'ok-value))
           (define err-error (lang-ref 'fhir/result/result 'err-error))
           (define cql-error-string (lang-ref 'cql/error 'cql-error-string))
           (cond [(not src) (missing 'cql)] [(not (list? rs)) (missing 'resources)]
                 [(not parse-cql) (values "the cql package is not installed" #t)]
                 [else (define r (parse-cql src))
                       (cond [(err? r) (values (cql-error-string (err-error r)) #t)]
                             [else (define results (evaluate-library (ok-value r) rs #:parameters (for/hash ([(k v) (in-hash ps)]) (values (symbol->string k) v))))
                                   (values (jsexpr->string (for/hasheq ([(k v) (in-hash results)]) (values (string->symbol k) (render v)))) #f)])])))
   (tool "vcl_valueset"
         "Compile a VCL expression (the ValueSet Compose Language) to a ValueSet resource."
         (text-schema 'vcl "the VCL expression")
         (lambda (args)
           (define src (string-arg args 'vcl))
           (define vcl->valueset (lang-ref 'vcl/compile 'vcl->valueset))
           (define ok? (lang-ref 'fhir/result/result 'ok?))
           (define ok-value (lang-ref 'fhir/result/result 'ok-value))
           (define err-error (lang-ref 'fhir/result/result 'err-error))
           (define message (lang-ref 'fhir/result/result 'validation-error-message))
           (cond [(not src) (missing 'vcl)]
                 [(not vcl->valueset) (values "the vcl package is not installed" #t)]
                 [else (define r (vcl->valueset src))
                       (if (ok? r) (values (jsexpr->string (ok-value r)) #f) (values (message (err-error r)) #t))])))
   (tool "fhirpath_evaluate"
         "Evaluate a FHIRPath expression over a FHIR resource (R5 JSON); the result collection as JSON (primitives as their values, complex items as FHIR JSON)."
         (hasheq 'type "object"
                 'properties (hasheq 'expression (hasheq 'type "string") 'resource (hasheq 'type "object" 'description "a FHIR resource as JSON; omitted: the empty collection"))
                 'required '("expression"))
         (lambda (args)
           (define expr (string-arg args 'expression))
           (define res (hash-ref args 'resource #f))
           (define parse-fhirpath (lang-ref 'fhirpath/parser/parse 'parse-fhirpath))
           (define eval-fhirpath (lang-ref 'fhirpath/eval 'eval-fhirpath))
           (define item->system (lang-ref 'fhirpath/value 'item->system))
           (define from-json (lang-ref 'fhir/serialize/from-json 'from-json))
           (define node->jsexpr (lang-ref 'fhir/serialize/to-json 'node->jsexpr))
           (define fhir? (lang-ref 'fhir/model/node 'fhir?))
           (define ok-value (lang-ref 'fhir/result/result 'ok-value))
           (cond [(not expr) (missing 'expression)]
                 [(not parse-fhirpath) (values "the fhirpath package is not installed" #t)]
                 [else (dynamic-require 'fhir/r5/schemas #f)
                       (define root (if (hash? res) (list (ok-value (from-json res #:lenient? #t))) '()))
                       (define out (eval-fhirpath (parse-fhirpath expr) root))
                       (values (jsexpr->string (for/list ([v (in-list out)])
                                                 (cond [(fhir? v) (node->jsexpr v)]
                                                       [else (define s (item->system v))
                                                             (cond [(or (string? s) (boolean? s) (number? s)) s]
                                                                   [(fhir? s) (node->jsexpr s)]
                                                                   [else (format "~a" s)])])))
                               #f)])))))

(define (all-tools) (append (operation-tools) (language-tools)))

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
  ;; language tools: a missing argument and an uninstalled or unknown language are errors, not crashes
  (define by-name (for/hash ([x (in-list (language-tools))]) (values (tool-name x) x)))
  (check-equal? (sort (hash-keys by-name) string<?) '("cql_elm" "cql_evaluate" "diagnose_file" "fhirpath_evaluate" "fsh_check" "fsh_compile" "vcl_valueset"))
  (define-values (t3 e3) (call-tool (hash-ref by-name "fsh_compile") (hasheq)))
  (check-true e3)
  (define-values (t4 e4) (call-tool (hash-ref by-name "diagnose_file") (hasheq 'path "/nonexistent/x.fsh")))
  (check-true e4)
  (check-true (jsexpr? (tool->jsexpr t))))
