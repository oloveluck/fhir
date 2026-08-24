#lang racket/base

;;; capability-lang-test.rkt — end-to-end tests for #lang fhir/capability.
;;; Exercises the real example app, the derived /metadata, dispatch, and compile-time validation.

(require rackunit
         racket/list
         (only-in fhir/r6/types)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/result/result ok-value)
         (only-in fhir/model/node fhir? fhir-type)
         ;; dispatch / app? / request constructors are library functions, not re-exported by the app
         (only-in fhir/capability/runtime
                  app? dispatch read-request create-request delete-request search-request
                  invoke-request)
         (prefix-in ex: (file "../examples/patient-app.rkt")))

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
