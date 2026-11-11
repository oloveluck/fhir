#lang racket/base

;;; capability-lang-test.rkt — end-to-end tests for #lang fhir/capability.
;;; Exercises the real example app, the derived /metadata, dispatch, and compile-time validation.

(require rackunit
         racket/list racket/file
         (only-in fhir/r6/types)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/capability/derive derive-capability-statement rc-server)
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
(check-exn exn:fail:user?
  (lambda () (compile-capability '(server) '(resource Bogus #:interactions (read) #:repository r))))
;; unknown interaction code
(check-exn exn:fail:user?
  (lambda () (compile-capability '(server) '(resource Patient #:interactions (frob) #:repository r))))
;; unknown operation parameter type
(check-exn exn:fail:user?
  (lambda () (compile-capability '(server)
                                 '(operation $x #:system #:in ([p NoSuchType 1 1]) #:handler h))))
;; two server declarations
(check-exn exn:fail:user?
  (lambda () (compile-capability '(server) '(server))))
;; missing server
(check-exn exn:fail:user?
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
  ;; the store is made when it is first used: requiring the module (as `racket clinic.rkt` does to print
  ;; the statement) leaves no fhir.db beside it
  (check-false (file-exists? (build-path dir "fhir.db")))
  (define p (ok-value (from-json (hasheq 'resourceType "Patient" 'gender "female" 'name (list (hasheq 'family "Ng"))))))
  (define created (dispatch app (create-request 'Patient p)))
  (check-eq? (fhir-type created) 'Patient)
  (check-true (file-exists? (build-path dir "fhir.db")))
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

;; ---- (server #:search-handling "strict"): every search is strict, whatever the client prefers — a
;; new user's research server answered `?subject=Patient/x` (only `patient` declared) with every
;; patient's Observations
(let ()
  (define dir (make-temporary-directory "cap-strict-~a"))
  (define src (build-path dir "s.rkt"))
  (void (call-with-output-file src
          (lambda (o)
            (write-string (string-append
                           "#lang fhir/capability\n"
                           "(server #:search-handling \"strict\")\n"
                           "(resource Observation #:interactions (read create search-type) #:search-params ([patient reference]))\n")
                          o))))
  (define app (dynamic-require src 'app))
  (define handle (dynamic-require 'fhir/http/router 'handle))
  (define-values (s1 o1) (handle app "GET" "/Observation" '((subject . "Patient/x")) ""))
  (check-equal? s1 400)
  (check-regexp-match #rx"search parameter `subject` not supported here" (hash-ref (car (hash-ref o1 'issue)) 'diagnostics))
  ;; … and says what the type does search on
  (check-regexp-match #rx"[(]Observation: patient; every type: _id, _lastUpdated, _count, _offset, _sort[)]" (hash-ref (car (hash-ref o1 'issue)) 'diagnostics))
  ;; no store declared: a temporary one, searched as a stored app is (the in-memory search matched
  ;; `patient=Patient/x` by string equality against a Reference, so every Observation or none)
  (for ([p '("x" "y")])
    (define-values (sc _b) (handle app "POST" "/Observation" '()
                                   (format "{\"resourceType\":\"Observation\",\"status\":\"final\",\"code\":{\"text\":\"c\"},\"subject\":{\"reference\":\"Patient/~a\"}}" p)))
    (check-equal? sc 201))
  (define-values (s2 b2) (handle app "GET" "/Observation" '((patient . "Patient/x")) ""))
  (check-equal? s2 200)
  (check-equal? (hash-ref b2 'total) 1)
  ;; only "strict" or "lenient"
  (check-exn #rx"#:search-handling must be \"strict\" or \"lenient\""
             (lambda () (compile-capability '(server #:search-handling "loose") '(define x 1))))
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
                     "(operation $g #:system #:in ([sex code 1 1 #:binding \"http://hl7.org/fhir/ValueSet/administrative-gender\"]) #:out ([out string 1 1]) #:handler g)\n"
                     "(operation $g2 #:system #:in ([sex code 1 1 #:binding \"(http://hl7.org/fhir/administrative-gender)(female;male)\"]) #:out ([out string 1 1]) #:handler g)\n"
                     "(define (crash in req) (expt (car (hash-ref in \"x\")) -0.241))\n"
                     "(operation $r #:system #:in ([x decimal 1 1 #:min 0 #:max 10] [n integer 0 1 #:max 120]) #:out ([out decimal 1 1]) #:handler crash)\n")
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
  (check-regexp-match #rx"parameter 'sex' must be one of male, female, other, unknown, got \"femme\" [(]value set http://hl7.org/fhir/ValueSet/administrative-gender[)]"
                      (hash-ref (car (hash-ref o9 'issue)) 'diagnostics))
  ;; a subset written inline as VCL: `other` is in administrative-gender but not in (female;male)
  ;; (a new user's $egfr had to refuse `other`/`unknown` in its handler)
  (define-values (s10 _o10) (handle app "GET" "/$g2" '((sex . "male")) ""))
  (check-equal? s10 200)
  (define-values (s11 o11) (handle app "GET" "/$g2" '((sex . "other")) ""))
  (check-equal? s11 400)
  (check-regexp-match #rx"must be female or male, got \"other\" [(]value set [(]http://hl7.org/fhir/administrative-gender[)][(]female;male[)][)]"
                      (hash-ref (car (hash-ref o11 'issue)) 'diagnostics))
  ;; the OperationDefinition carries the url percent-encoded, as the VCL specification requires
  (let-values ([(st od) (handle app "GET" "/OperationDefinition/g2" '() "")])
    (check-equal? (hash-ref (hash-ref (car (hash-ref od 'parameter)) 'binding) 'valueSet)
                  "http://fhir.org/VCL?v1=%28http%3A%2F%2Fhl7.org%2Ffhir%2Fadministrative-gender%29%28female%3Bmale%29"))
  ;; a declared range (#:min/#:max) refuses a number outside it before the handler runs, and the
  ;; OperationDefinition carries it (FHIR's minValue/maxValue extensions)
  (define-values (s12 o12) (handle app "GET" "/$r" '((x . "11")) ""))
  (check-equal? s12 400)
  (check-regexp-match #rx"parameter 'x' must be at most 10, got 11" (hash-ref (car (hash-ref o12 'issue)) 'diagnostics))
  (let-values ([(st od) (handle app "GET" "/OperationDefinition/r" '() "")])
    (check-equal? (hash-ref (car (hash-ref (car (hash-ref od 'parameter)) 'extension)) 'url) "http://hl7.org/fhir/StructureDefinition/minValue"))
  ;; every problem at once: two mistyped inputs are two lines (one was reported)
  (define-values (s13 o13) (handle app "GET" "/$r" '((x . "abc") (n . "60.5")) ""))
  (check-equal? s13 400)
  ;; one issue each, its input named in `expression`, so a client knows which field to fix
  (define is13 (hash-ref o13 'issue))
  (check-equal? (length is13) 2)
  (define (issue-of n) (findf (lambda (i) (equal? (hash-ref i 'expression #f) (list n))) is13))
  ;; in the order the inputs are declared, whatever order the request gave them
  (check-equal? (map (lambda (i) (car (hash-ref i 'expression))) is13)
                (let-values ([(_s od) (handle app "GET" "/OperationDefinition/r" '() "")])
                  (filter (lambda (n) (member n '("x" "n"))) (map (lambda (p) (hash-ref p 'name)) (hash-ref od 'parameter)))))
  (check-regexp-match #rx"parameter 'x' must be a decimal, got \"abc\"" (hash-ref (issue-of "x") 'diagnostics))
  (check-regexp-match #rx"parameter 'n' must be an integer, got \"60[.]5\"" (hash-ref (issue-of "n") 'diagnostics))
  ;; a whole number written as a decimal is that integer (a client sending 60.0 was refused)
  (define-values (s13b o13b) (handle app "GET" "/$r" '((x . "0") (n . "60.0")) ""))
  (check-equal? s13b 500 (format "~s" o13b))                ; past the inputs, to the handler (which raises)
  ;; a required input absent is "required", with the misspelt input given in its place
  (define-values (s13c o13c) (handle app "GET" "/$r" '((xx . "5")) ""))
  (check-equal? s13c 400)
  (check-true (for/or ([i (in-list (hash-ref o13c 'issue))])
                (regexp-match? #rx"^parameter 'x' is required [(]`xx` was given: a misspelling of it[?][)]$" (hash-ref i 'diagnostics)))
              (format "~s" o13c))
  ;; one unknown input and one required input missing, spelt far apart (`hr` for `heartRate`): linked
  (define-values (s13d o13d) (handle app "GET" "/$r" '((zz . "5")) ""))
  (check-true (for/or ([i (in-list (hash-ref o13d 'issue))])
                (regexp-match? #rx"^parameter 'x' is required [(]`zz` was given instead: is it this input[?][)]$" (hash-ref i 'diagnostics)))
              (format "~s" o13d))
  ;; a handler that raises: a 500 that says which handler and how to refuse instead
  (define-values (s14 o14) (handle app "GET" "/$r" '((x . "0")) ""))
  (check-equal? s14 500)
  (check-regexp-match #rx"the [$]r handler raised: .*return an OperationOutcome whose issue code is `invalid`" (hash-ref (car (hash-ref o14 'issue)) 'diagnostics))
  (check-exn #rx"#:min and #:max bound a number"
             (lambda () (compile-capability '(server) '(operation $x #:system #:in ([s string 1 1 #:min 0]) #:handler h))))
  ;; a binding that is neither a url nor VCL is an error at the declaration
  (check-exn #rx"#:binding \"[(]female;\" is neither a ValueSet url nor a VCL expression"
             (lambda () (compile-capability '(server) '(operation $x #:system #:in ([s code 1 1 #:binding "(female;"]) #:handler h))))
  ;; the derived OperationDefinition is readable: a client sees what $t takes
  (define-values (s6 od) (handle app "GET" "/OperationDefinition/t" '() ""))
  (check-equal? s6 200)
  (check-equal? (map (lambda (p) (hash-ref p 'name)) (filter (lambda (p) (equal? (hash-ref p 'use) "in")) (hash-ref od 'parameter))) '("w" "n" "flag" "when"))
  (define-values (s7 _od) (handle app "GET" "/OperationDefinition/nope" '() ""))
  (check-equal? s7 404)
  (delete-directory/files dir))

;; ---- declaration errors: every one at once, each a line at its form; a search parameter FHIR does
;; not define is said at its resource form when the app is built (it was a stack trace through the
;; store, and `serve` died without a word)
(let ()
  (define dir (make-temporary-directory "cap-errs-~a"))
  (define src (build-path dir "bad.capability.rkt"))
  (define (write-app! text) (call-with-output-file src #:exists 'truncate (lambda (o) (void (write-string text o)))))
  (define (load-error)
    (with-handlers ([exn:fail:user? exn-message])
      (parameterize ([current-namespace (make-base-namespace)]) (dynamic-require src 'app)) "no error"))
  (write-app! (string-append "#lang fhir/capability\n(server)\n"
                             "(resource Patient #:interactions (read create frob))\n"
                             "(define (h in req) (Parameters))\n"
                             "(operation $x #:system #:in ([p int 1 1]) #:handler h)\n"))
  (define both (load-error))
  (check-regexp-match #rx"bad[.]capability[.]rkt:3:[0-9]+: resource: unknown restful interaction frob" both)
  (check-regexp-match #rx"bad[.]capability[.]rkt:5:[0-9]+: operation: unknown parameter type int" both)
  (check-false (regexp-match? #rx"context[.][.][.]" both))
  (write-app! (string-append "#lang fhir/capability\n(server)\n"
                             "(resource Patient #:interactions (read search-type) #:search-params ([birthDate date] [gender string]))\n"))
  (define sp (load-error))
  (check-regexp-match #rx"^bad[.]capability[.]rkt:3:0: resource Patient: search parameter `birthDate`: FHIR defines none of that name for Patient [(]did you mean `birthdate`[?][)]" sp)
  (check-regexp-match #rx"search parameter `gender` is a token in FHIR, not a string" sp)
  ;; a misspelt type is said as a type (not as a range on a non-number), with the nearest, and in the
  ;; same answer as a search parameter FHIR does not define (it showed only after the type was fixed)
  (write-app! (string-append "#lang fhir/capability\n(server)\n"
                             "(resource Patient #:interactions (read search-type) #:search-params ([birthDate date]))\n"
                             "(define (h in req) (Parameters))\n"
                             "(operation $x #:system #:in ([age int 1 1 #:min 18 #:max 120]) #:handler h)\n"))
  (define mixed (load-error))
  (check-regexp-match #rx"operation: unknown parameter type int [(]did you mean `integer`" mixed)
  ;; two mistakes in ONE form are both said: a bad interaction and a misspelt search-parameter type in
  ;; one resource, two bad parameter types (an #:in and an #:out) in one operation (the second of each
  ;; showed only after the first was fixed)
  (write-app! (string-append "#lang fhir/capability\n(server)\n"
                             "(resource Observation #:interactions (read search) #:search-params ([code token] [subject refrence]))\n"
                             "(define (h in req) (Parameters))\n"
                             "(operation $x #:system #:in ([q float 1 1]) #:out ([o strng 1 1]) #:handler h)\n"))
  (define per-form (load-error))
  (check-regexp-match #rx"unknown restful interaction search" per-form)
  (check-regexp-match #rx"unknown search-param type refrence" per-form)
  (check-regexp-match #rx"unknown parameter type float" per-form)
  (check-regexp-match #rx"unknown parameter type strng [(]did you mean `string`[?][)]" per-form)
  ;; two outputs in two (parameter …) forms: the error says to put them in one
  (write-app! (string-append "#lang fhir/capability\n(server)\n"
                             "(define (h in req) (Parameters (parameter (ParametersParameter (name \"a\") (valueDecimal 1))) (parameter (ParametersParameter (name \"b\") (valueBoolean #t)))))\n"
                             "(operation $x #:system #:out ([a decimal 1 1] [b boolean 1 1]) #:handler h)\n"))
  (check-regexp-match #rx"duplicate field Parameters[.]parameter: a repeating field takes all its values in ONE form, [(]parameter A B …[)]"
                      (with-handlers ([exn:fail? exn-message]) (parameterize ([current-namespace (make-base-namespace)]) (dynamic-require src 'app)) "no error"))
  ;; an operation named as a value with no require says which module provides it (Racket said
  ;; `$validate: unbound identifier`, nothing more)
  (write-app! "#lang fhir/capability\n(server)\n(resource Patient #:interactions (read))\n(operation $validate)\n")
  (check-regexp-match #rx"bad[.]capability[.]rkt:4:11: operation: `[$]validate` is not bound: require it first, [(]require [(]only-in fhir/conformance/operations [$]validate[)][)]"
                      (load-error))
  (check-false (regexp-match? #rx"#:min and #:max" mixed))
  (check-regexp-match #rx"resource Patient: search parameter `birthDate`: FHIR defines none" mixed)
  ;; a misspelt search-parameter type: the nearest and the types there are, said once (it was said
  ;; twice, the second time as "a token in FHIR, not a tokn")
  (write-app! (string-append "#lang fhir/capability\n(server)\n"
                             "(resource Patient #:interactions (read search-type) #:search-params ([gender tokn]))\n"))
  (define tokn (load-error))
  (check-regexp-match #rx"bad[.]capability[.]rkt:3:[0-9]+: resource: unknown search-param type tokn [(]did you mean `token`[?][)]; one of number, date, string, token" tokn)
  (check-equal? (length (regexp-match* #rx"tokn" tokn)) 1 tokn)
  ;; a server option given a symbol: one line at the value (it was syntax-parse's "expected string"
  ;; and a stack trace)
  (write-app! "#lang fhir/capability\n(server #:mode server)\n")
  (check-regexp-match #rx"bad[.]capability[.]rkt:2:15: server: #:mode takes a string: \"server\"$" (load-error))
  (write-app! "#lang fhir/capability\n(server #:nmae \"x\")\n")
  (check-regexp-match #rx"server: unknown option #:nmae [(]did you mean `name`[?][)]" (load-error))
  (delete-directory/files dir))

;; an instance statement declared without #:date is dated when the server started, not 2025-01-01
(check-false (equal? (hash-ref (node->jsexpr (derive-capability-statement (rc-server "server" "active" #f "6.0.0" '("json") #f) '() '())) 'date)
                     "2025-01-01T00:00:00Z"))

;; a decimal output built from a computed number: a Racket number is a decimal (`(valueDecimal 57.5)`
;; was refused); a string FHIR does not read (`(real->decimal-string v 0)` = "58.") answers a 500 that
;; says the BUILT value is the problem, not an input (the hint said to refuse an input)
(let ()
  (define dir (make-temporary-directory "cap-dec-~a"))
  (define src (build-path dir "dec.capability.rkt"))
  (call-with-output-file src
    (lambda (o) (write-string (string-append
                               "#lang fhir/capability\n(server)\n"
                               "(define (good in req) (Parameters (parameter (ParametersParameter (name \"x\") (valueDecimal (* 1.0 (/ 115 2)))))))\n"
                               "(define (bad in req) (Parameters (parameter (ParametersParameter (name \"x\") (valueDecimal (real->decimal-string 57.5 0))))))\n"
                               "(operation $good #:system #:out ([x decimal 1 1]) #:handler good)\n"
                               "(operation $bad #:system #:out ([x decimal 1 1]) #:handler bad)\n")
                              o)))
  (define app (dynamic-require src 'app))
  (define handle (dynamic-require 'fhir/http/router 'handle))
  (define-values (gs gj) (handle app "GET" "/$good" '() ""))
  (check-equal? gs 200)
  (check-equal? (hash-ref (car (hash-ref gj 'parameter)) 'valueDecimal) 57.5)
  (define-values (bs bj) (handle app "GET" "/$bad" '() ""))
  (check-equal? bs 500)
  (define msg (hash-ref (car (hash-ref bj 'issue)) 'diagnostics))
  (check-regexp-match #rx"\"58[.]\" is not a valid value" msg)
  (check-regexp-match #rx"a value the handler built is not valid FHIR: give a decimal as a Racket number" msg)
  (check-false (regexp-match? #rx"to refuse an input" msg))
  (delete-directory/files dir))

;; ---- (server #:references "checked"): a create naming a resource the server does not hold is
;; refused (a study server stored an Observation of `Patient/nope` without a word); a type the server
;; does not serve is not decided
(let ()
  (define dir (make-temporary-directory "cap-refs-~a"))
  (define src (build-path dir "r.rkt"))
  (void (call-with-output-file src
          (lambda (o)
            (write-string (string-append
                           "#lang fhir/capability\n"
                           "(server #:references \"checked\")\n"
                           "(resource Patient #:interactions (read create))\n"
                           "(resource Observation #:interactions (read create))\n")
                          o))))
  (define app (dynamic-require src 'app))
  (define handle (dynamic-require 'fhir/http/router 'handle))
  (define (obs subject) (format "{\"resourceType\":\"Observation\",\"status\":\"final\",\"code\":{\"text\":\"QT\"},\"subject\":{\"reference\":\"~a\"},\"performer\":[{\"reference\":\"Practitioner/x\"}]}" subject))
  (define-values (s1 b1) (handle app "POST" "/Observation" '() (obs "Patient/nope")))
  (check-equal? s1 422)
  (check-regexp-match #rx"Observation refers to Patient/nope, which this server does not hold" (hash-ref (car (hash-ref b1 'issue)) 'diagnostics))
  (define-values (s2 p) (handle app "POST" "/Patient" '() "{\"resourceType\":\"Patient\",\"gender\":\"female\"}"))
  (define-values (s3 _b3) (handle app "POST" "/Observation" '() (obs (format "Patient/~a" (hash-ref p 'id)))))
  (check-equal? s3 201)
  (check-exn #rx"#:references must be \"checked\" or \"unchecked\""
             (lambda () (compile-capability '(server #:references "strict") '(define x 1))))
  (delete-directory/files dir))

;; ---- what an operation answers is what it declares: an undeclared output, a missing required one
;; and one of another type are a 500 naming each (a handler's extra `prolonged` was served 200, so the
;; OperationDefinition no longer said what the operation returns)
(let ()
  (define dir (make-temporary-directory "cap-out-~a"))
  (define src (build-path dir "o.rkt"))
  (void (call-with-output-file src
          (lambda (o)
            (write-string (string-append
                           "#lang fhir/capability\n(server)\n"
                           "(define (ok in req) (Parameters (parameter (ParametersParameter (name \"qtc\") (valueDecimal 447.2)))))\n"
                           "(define (extra in req) (Parameters (parameter (ParametersParameter (name \"qtc\") (valueDecimal 447.2)) (ParametersParameter (name \"prolonged\") (valueBoolean #f)))))\n"
                           "(define (wrong in req) (Parameters (parameter (ParametersParameter (name \"qtc\") (valueString \"447\")))))\n"
                           "(define (none in req) (Parameters (parameter (ParametersParameter (name \"qtcc\") (valueDecimal 1)))))\n"
                           "(operation $ok #:system #:out ([qtc decimal 1 1]) #:handler ok)\n"
                           "(operation $extra #:system #:out ([qtc decimal 1 1]) #:handler extra)\n"
                           "(operation $wrong #:system #:out ([qtc decimal 1 1]) #:handler wrong)\n"
                           "(operation $none #:system #:out ([qtc decimal 1 1]) #:handler none)\n")
                          o))))
  (define app (dynamic-require src 'app))
  (define handle (dynamic-require 'fhir/http/router 'handle))
  (define (call op) (let-values ([(s b) (handle app "GET" (string-append "/$" op) '() "")]) (values s (if (equal? (hash-ref b 'resourceType #f) "OperationOutcome") (hash-ref (car (hash-ref b 'issue)) 'diagnostics) b))))
  (let-values ([(s b) (call "ok")]) (check-equal? s 200))
  (let-values ([(s m) (call "extra")])
    (check-equal? s 500)
    (check-regexp-match #rx"the [$]extra handler's answer does not match its #:out: `prolonged` is not a declared output [(]it declares qtc[)]" m))
  (let-values ([(s m) (call "wrong")])
    (check-equal? s 500)
    (check-regexp-match #rx"`qtc` is declared decimal but given as valueString" m))
  (let-values ([(s m) (call "none")])
    (check-regexp-match #rx"`qtcc` is not a declared output [(]did you mean `qtc`[?][)]; the required output `qtc` is missing" m))
  (delete-directory/files dir))
