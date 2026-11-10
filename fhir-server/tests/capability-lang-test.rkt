#lang racket/base

;;; capability-lang-test.rkt — end-to-end tests for #lang fhir/capability.
;;; Exercises the real example app, the derived /metadata, dispatch, and compile-time validation.

(require rackunit
         racket/list racket/file
         (only-in fhir/r6/types)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/result/result ok-value)
         (only-in fhir/model/node fhir? fhir-type)
         ;; dispatch / app? / request constructors are library functions, not re-exported by the app
         (only-in fhir/capability/runtime
                  app? dispatch read-request create-request delete-request search-request
                  invoke-request)
         (prefix-in ex: fhir/examples/patient-app))

;; ---- the lang produces an app + a derived CapabilityStatement -------------------------------
(check-true (app? ex:app))
(check-true (fhir? ex:capability-statement))
(check-eq? (fhir-type ex:capability-statement) 'CapabilityStatement)
(check-eq? (length ex:operation-definitions) 1)
(check-eq? (fhir-type (car ex:operation-definitions)) 'OperationDefinition)

;; ---- /metadata reflects the declarations (can't drift) --------------------------------------
(define md (node->jsexpr ex:capability-statement))
(define rest0 (car (hash-ref md 'rest)))
(define res0 (car (hash-ref rest0 'resource)))
(check-equal? (hash-ref res0 'type) "Patient")
(check-equal? (sort (map (lambda (i) (hash-ref i 'code)) (hash-ref res0 'interaction)) string<?)
              '("create" "read" "search-type"))
(check-equal? (sort (map (lambda (s) (hash-ref s 'name)) (hash-ref res0 'searchParam)) string<?)
              '("birthdate" "gender"))
;; the statement's operation.definition matches the derived OperationDefinition.url (the join key)
(define op0 (car (hash-ref rest0 'operation)))
(check-equal? (hash-ref op0 'definition) (hash-ref (node->jsexpr (car ex:operation-definitions)) 'url))

;; ---- dispatch: resource interactions --------------------------------------------------------
(define (patient id) (ok-value (from-json (hasheq 'resourceType "Patient" 'id id))))
(define created (dispatch ex:app (create-request 'Patient (patient "42"))))
(check-eq? (fhir-type created) 'Patient)
(check-eq? (fhir-type (dispatch ex:app (read-request 'Patient "1"))) 'Patient)  ; assigned id "1"
(check-eq? (fhir-type (dispatch ex:app (search-request 'Patient))) 'Bundle)

;; not-supported: unknown type, and an interaction the repo doesn't implement
(check-eq? (fhir-type (dispatch ex:app (read-request 'Observation "1"))) 'OperationOutcome)
(check-eq? (fhir-type (dispatch ex:app (delete-request 'Patient "1"))) 'OperationOutcome)

;; ---- dispatch: operations -------------------------------------------------------------------
(define ping-in (ok-value (from-json (hasheq 'resourceType "Parameters"
                                             'parameter (list (hasheq 'name "message"
                                                                      'valueString "hi"))))))
(define ping-out (dispatch ex:app (invoke-request #:code "ping" #:level 'system #:body ping-in)))
(check-eq? (fhir-type ping-out) 'Parameters)
;; a wrong-level invoke of a system op is not supported
(check-eq? (fhir-type (dispatch ex:app (invoke-request #:code "ping" #:level 'type #:type 'Patient)))
           'OperationOutcome)
;; an unknown op is not supported
(check-eq? (fhir-type (dispatch ex:app (invoke-request #:code "nope" #:level 'system)))
           'OperationOutcome)

;; ---- compile-time validation ----------------------------------------------------------------
;; evaluate a capability module form and expect a syntax error on bad declarations
(define (compile-capability . body)
  (parameterize ([current-namespace (make-base-namespace)])
    (eval `(module test-cap fhir/capability/base ,@body))))

;; a well-formed module compiles (r is a real repository defined in the module body)
(check-not-exn (lambda ()
  (compile-capability '(define r (make-repository #:read (lambda (id) #f)))
                      '(server)
                      '(resource Patient #:interactions (read) #:repository r))))
;; unknown resource type
(check-exn exn:fail:syntax?
  (lambda () (compile-capability '(server) '(resource Bogus #:interactions (read) #:repository r))))
;; unknown interaction code
(check-exn exn:fail:syntax?
  (lambda () (compile-capability '(server) '(resource Patient #:interactions (frob) #:repository r))))
;; unknown operation parameter type
(check-exn exn:fail:syntax?
  (lambda () (compile-capability '(server)
                                 '(operation $x #:system #:in ([p NoSuchType 1 1]) #:handler h))))
;; two server declarations
(check-exn exn:fail:syntax?
  (lambda () (compile-capability '(server) '(server))))
;; missing server
(check-exn exn:fail:syntax?
  (lambda () (compile-capability '(resource Patient #:interactions (read) #:repository r))))

(printf "capability-lang-test: all checks passed\n")

;; ---- (server #:store "fhir.db"): resources without a repository live in a SQLite store beside the
;; module, as JSONB; search goes through the store's indexes, with the declaration's own expressions
(let ()
  (define dir (make-temporary-directory "cap-store-~a"))
  (define src (build-path dir "clinic.rkt"))
  (call-with-output-file src
    (lambda (o)
      (write-string (string-append
                     "#lang fhir/capability\n"
                     "(server #:store \"fhir.db\")\n"
                     "(resource Patient #:interactions (read create search-type) #:search-params ([gender token] [family string \"name.family\"]))\n"
                     "(resource Observation #:interactions (read create search-type) #:search-params ([subject reference]))\n")
                    o)))
  (define app (dynamic-require src 'app))
  (define p (ok-value (from-json (hasheq 'resourceType "Patient" 'gender "female" 'name (list (hasheq 'family "Ng"))))))
  (define created (dispatch app (create-request 'Patient p)))
  (check-eq? (fhir-type created) 'Patient)
  ;; what the guide says of a store-backed type: _include over a declared reference parameter, and the
  ;; reference's type modifier (a rerun's agent saw `subject:Patient` reported as unknown)
  (define pid (hash-ref (node->jsexpr created) 'id))
  (dispatch app (create-request 'Observation (ok-value (from-json (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                                                                          'subject (hasheq 'reference (string-append "Patient/" pid)))))))
  (define inc (node->jsexpr (dispatch app (search-request 'Observation `((subject:Patient . ,pid) (_include . "Observation:subject"))))))
  (check-equal? (sort (map (lambda (e) (hash-ref (hash-ref e 'search) 'mode)) (hash-ref inc 'entry)) string<?) '("include" "match"))
  (define found (node->jsexpr (dispatch app (search-request 'Patient '((family . "ng"))))))
  (check-equal? (length (hash-ref found 'entry '())) 1)
  (check-true (file-exists? (build-path dir "fhir.db")))
  (define c ((dynamic-require 'db 'sqlite3-connect) #:database (build-path dir "fhir.db")))
  (check-equal? ((dynamic-require 'db 'query-value) c "SELECT resource ->> '$.name[0].family' FROM fhir_resources WHERE resource_type = 'Patient'") "Ng")
  (check-equal? ((dynamic-require 'db 'query-value) c "SELECT typeof(resource) FROM fhir_resources WHERE resource_type = 'Patient'") "blob")
  ((dynamic-require 'db 'disconnect) c)
  (delete-directory/files dir))

;; ---- what is sent is what is validated: a store-backed app refuses a write the lenient parse would
;; have trimmed (a misspelt element, a bad date), and its $validate sees them, as a bare resource body too
(let ()
  (define dir (make-temporary-directory "cap-valid-~a"))
  (define src (build-path dir "v.rkt"))
  (call-with-output-file src
    (lambda (o)
      (write-string (string-append
                     "#lang fhir/capability\n(require (only-in fhir/conformance/operations $validate))\n"
                     "(server #:store \"fhir.db\")\n"
                     "(resource Patient #:interactions (read create search-type) #:search-params ([gender token]))\n"
                     "(operation $validate)\n")
                    o)))
  (define app (dynamic-require src 'app))
  (define handle (dynamic-require 'fhir/http/router 'handle))
  (define bad "{\"resourceType\":\"Patient\",\"nmae\":[{\"family\":\"X\"}],\"birthDate\":\"1965-13-45\"}")
  (define-values (st out) (handle app "POST" "/Patient" '() bad))
  (check-equal? st 422)
  (define msgs (map (lambda (i) (hash-ref i 'diagnostics "")) (hash-ref out 'issue)))
  (check-true (for/or ([m msgs]) (regexp-match? #rx"nmae" m)) (format "~a" msgs))
  (check-true (for/or ([m msgs]) (regexp-match? #rx"1965-13-45" m)) (format "~a" msgs))
  (define-values (st2 _o2) (handle app "POST" "/Patient" '() "{\"resourceType\":\"Patient\",\"gender\":\"female\"}"))
  (check-equal? st2 201)
  ;; a create's id is the server's: the same id POSTed twice is two resources (the second was a 500
  ;; naming fhir-create!); PUT creates with a chosen id where `update` is declared
  (define-values (sd1 d1) (handle app "POST" "/Patient" '() "{\"resourceType\":\"Patient\",\"id\":\"dup\",\"gender\":\"male\"}"))
  (define-values (sd2 d2) (handle app "POST" "/Patient" '() "{\"resourceType\":\"Patient\",\"id\":\"dup\",\"gender\":\"male\"}"))
  (check-equal? (list sd1 sd2) '(201 201))
  (check-false (equal? (hash-ref d1 'id) (hash-ref d2 'id)))
  (check-false (member "dup" (list (hash-ref d1 'id) (hash-ref d2 'id))))
  ;; a body of another type than the endpoint's: 400, said plainly (it was a 500)
  (define-values (st5 o5) (handle app "POST" "/Patient" '() "{\"resourceType\":\"Observation\",\"status\":\"final\",\"code\":{\"text\":\"x\"}}"))
  (check-equal? st5 400)
  (check-regexp-match #rx"the body is a Observation, POSTed to /Patient" (hash-ref (car (hash-ref o5 'issue)) 'diagnostics))
  ;; $validate on the resource as sent: in Parameters, and as the bare body
  (define (errors-of out) (filter (lambda (i) (equal? (hash-ref i 'severity #f) "error")) (hash-ref out 'issue '())))
  (define-values (s3 v1) (handle app "POST" "/Patient/$validate" '()
                                  (string-append "{\"resourceType\":\"Parameters\",\"parameter\":[{\"name\":\"resource\",\"resource\":" bad "}]}")))
  (check-equal? (length (errors-of v1)) 2)
  (define-values (s4 v2) (handle app "POST" "/Patient/$validate" '() bad))
  (check-equal? (length (errors-of v2)) 2)
  ;; $validate answers what it found with 200 either way (its result IS an OperationOutcome)
  (check-equal? (list s3 s4) '(200 200))
  ;; an undeclared search parameter: ignored and reported by default; Prefer: handling=strict refuses it
  (define-values (s10 _b10) (handle app "GET" "/Patient" '((name . "x")) ""))
  (check-equal? s10 200)
  (define-values (s11 o11) (parameterize ([(dynamic-require 'fhir/capability/runtime 'current-search-strict?) #t])
                             (handle app "GET" "/Patient" '((name . "x")) "")))
  (check-equal? s11 400)
  (check-regexp-match #rx"search parameter `name` not supported here" (hash-ref (car (hash-ref o11 'issue)) 'diagnostics))
  (delete-directory/files dir))

;; ---- an operation's inputs are typed by its declaration, the same over GET and POST
(let ()
  (define dir (make-temporary-directory "cap-ops-~a"))
  (define src (build-path dir "o.rkt"))
  (call-with-output-file src
    (lambda (o)
      (write-string (string-append
                     "#lang fhir/capability\n(server)\n"
                     "(define (h in req)\n"
                     "  (define (input k) (car (hash-ref in k)))\n"
                     "  (Parameters (parameter (ParametersParameter (name \"out\") (valueString (format \"~a ~a ~a ~a\" (* 2 (input \"w\")) (+ 1 (input \"n\")) (input \"flag\") (input \"when\")))))))\n"
                     "(operation $t #:system #:in ([w decimal 1 1] [n integer 1 1] [flag boolean 1 1] [when date 1 1]) #:out ([out string 1 1]) #:handler h)\n"
                     "(define (g in req) (Parameters (parameter (ParametersParameter (name \"out\") (valueString (car (hash-ref in \"sex\")))))))\n"
                     "(operation $g #:system #:in ([sex code 1 1 #:binding \"http://hl7.org/fhir/ValueSet/administrative-gender\"]) #:out ([out string 1 1]) #:handler g)\n")
                    o)))
  (define app (dynamic-require src 'app))
  (define handle (dynamic-require 'fhir/http/router 'handle))
  (define (out-of o) (hash-ref (car (hash-ref o 'parameter)) 'valueString))
  (define-values (s1 o1) (handle app "GET" "/$t" '((w . "80.5") (n . "41") (flag . "true") (when . "2024-03-01")) ""))
  (check-equal? s1 200)
  (check-equal? (out-of o1) "161.0 42 #t 2024-03-01")
  (define-values (s2 o2) (handle app "POST" "/$t" '()
                                 "{\"resourceType\":\"Parameters\",\"parameter\":[{\"name\":\"w\",\"valueDecimal\":80.5},{\"name\":\"n\",\"valueInteger\":41},{\"name\":\"flag\",\"valueBoolean\":true},{\"name\":\"when\",\"valueDate\":\"2024-03-01\"}]}"))
  (check-equal? s2 200)
  (check-equal? (out-of o2) "161.0 42 #t 2024-03-01")
  (define-values (s3 o3) (handle app "GET" "/$t" '((w . "heavy") (n . "41") (flag . "true") (when . "2024-03-01")) ""))
  (check-equal? s3 400)
  (check-regexp-match #rx"parameter 'w' must be a decimal, got \"heavy\"" (hash-ref (car (hash-ref o3 'issue)) 'diagnostics))
  ;; an input the declaration does not name is refused, not dropped
  (define-values (s5 o5) (handle app "GET" "/$t" '((w . "80.5") (n . "41") (flag . "true") (when . "2024-03-01") (wehn . "x")) ""))
  (check-equal? s5 400)
  (check-regexp-match #rx"'wehn' is not an input of [$]t [(]did you mean `when`[?][)]" (hash-ref (car (hash-ref o5 'issue)) 'diagnostics))
  ;; a code input bound to a value set: a code outside it is refused before the handler runs
  (define-values (s8 o8) (handle app "GET" "/$g" '((sex . "female")) ""))
  (check-equal? s8 200)
  (define-values (s9 o9) (handle app "GET" "/$g" '((sex . "femme")) ""))
  (check-equal? s9 400)
  (check-regexp-match #rx"parameter 'sex' must be a code from http://hl7.org/fhir/ValueSet/administrative-gender [(]male, female, other, unknown[)], got \"femme\""
                      (hash-ref (car (hash-ref o9 'issue)) 'diagnostics))
  ;; the derived OperationDefinition is readable: a client sees what $t takes
  (define-values (s6 od) (handle app "GET" "/OperationDefinition/t" '() ""))
  (check-equal? s6 200)
  (check-equal? (map (lambda (p) (hash-ref p 'name)) (filter (lambda (p) (equal? (hash-ref p 'use) "in")) (hash-ref od 'parameter))) '("w" "n" "flag" "when"))
  (define-values (s7 _od) (handle app "GET" "/OperationDefinition/nope" '() ""))
  (check-equal? s7 404)
  (delete-directory/files dir))
