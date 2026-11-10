#lang racket/base

;;; operations-http-test.rkt — operations (fhir/operation) over HTTP: served directly
;;; (`operations-app`), and exposed from a #lang fhir/capability app (tests/ops-app.rkt). In both, the
;;; CapabilityStatement is derived from what is routed — every operation under its own canonical — and
;;; a request reaches the same operation a pipeline applies. Driven through the router (http/router's
;;; `handle`, what the socket server calls).

(require rackunit racket/list json
         (only-in fhir/r6/types)
         fhir/http/router
         (only-in fhir/capability/operations operations-app)
         (only-in fhir/operation apply-operation)
         (only-in fhir/conformance/operations $validate)
         (only-in fhir/terminology/operations $expand))

(define gender "http://hl7.org/fhir/ValueSet/administrative-gender")
(define (get a path [query '()]) (let-values ([(st js) (handle a "GET" path query "")]) (values st js)))
(define (post a path js) (let-values ([(st out) (handle a "POST" path '() (jsexpr->string js))]) (values st out)))
(define (definitions-in cs)
  (define rest (car (hash-ref cs 'rest)))
  (append (for/list ([o (in-list (hash-ref rest 'operation '()))]) (hash-ref o 'definition))
          (for*/list ([r (in-list (hash-ref rest 'resource '()))] [o (in-list (hash-ref r 'operation '()))])
            (string-append (hash-ref r 'type) " " (hash-ref o 'definition)))))
(define patient (hasheq 'resourceType "Patient" 'gender "male"))
(define (params . kvs) (hasheq 'resourceType "Parameters"
                               'parameter (let loop ([kvs kvs]) (if (null? kvs) '() (cons (car kvs) (loop (cdr kvs)))))))

;; ---- operations served directly ----------------------------------------------------------------
(define a (operations-app (list $validate $expand)))
(let-values ([(st cs) (get a "/metadata")])
  (check-equal? st 200)
  ;; Resource-wide $validate at rest.operation (no declared types), $expand under ValueSet
  (check-not-false (member "http://hl7.org/fhir/OperationDefinition/Resource-validate" (definitions-in cs)))
  (check-not-false (member "ValueSet http://hl7.org/fhir/OperationDefinition/ValueSet-expand" (definitions-in cs))))
(let-values ([(st oo) (post a "/Patient/$validate" (params (hasheq 'name "resource" 'resource patient)))])
  (check-equal? st 200)
  (check-equal? (hash-ref (car (hash-ref oo 'issue)) 'severity) "information"))
;; a GET query's count arrives as a string and is converted to the integer parameter
(let-values ([(st vs) (get a "/ValueSet/$expand" (list (cons 'url gender) (cons 'count "1")))])
  (check-equal? st 200)
  (check-equal? (length (hash-ref (hash-ref vs 'expansion) 'contains)) 1))
(let-values ([(st oo) (get a "/ValueSet/$expand" (list (cons 'url gender) (cons 'cuont "1")))])
  (check-equal? st 400)
  (check-regexp-match #rx"'cuont' is not an input of [$]expand [(]did you mean `count`[?][)]" (hash-ref (car (hash-ref oo 'issue)) 'diagnostics)))

;; ---- exposed from a #lang fhir/capability app -------------------------------------------------
(define app (dynamic-require (collection-file-path "ops-app.rkt" "fhir" "tests") 'app))
(let-values ([(st cs) (get app "/metadata")])
  (check-not-false (member "Patient http://hl7.org/fhir/OperationDefinition/Resource-validate" (definitions-in cs)))
  (check-not-false (member "ValueSet http://hl7.org/fhir/OperationDefinition/ValueSet-expand" (definitions-in cs))))
;; instance level: the subject is the app's stored Patient (its repository)
(define-values (st created) (post app "/Patient" patient))
(check-equal? st 201)
(let-values ([(st oo) (post app (format "/Patient/~a/$validate" (hash-ref created 'id)) (params))])
  (check-equal? st 200)
  (check-equal? (hash-ref oo 'resourceType) "OperationOutcome"))
(let-values ([(st oo) (post app "/Patient/nope/$validate" (params))])
  (check-regexp-match #rx"Patient/nope is not on this server" (hash-ref (car (hash-ref oo 'issue)) 'diagnostics)))
;; what a new user did: `{}` at instance level is no body (it was a 400, "at most 1 'resource'")
(let-values ([(st oo) (post app (format "/Patient/~a/$validate" (hash-ref created 'id)) (hasheq))])
  (check-equal? st 200)
  (check-equal? (hash-ref (car (hash-ref oo 'issue)) 'severity) "information"))
;; a resource given at instance level is the one checked (an update of the stored one)
(let-values ([(st oo) (post app (format "/Patient/~a/$validate" (hash-ref created 'id))
                            (hash-set patient 'gender "femme"))])
  (check-equal? st 200)
  (check-regexp-match #rx"femme|gender" (hash-ref (car (hash-ref oo 'issue)) 'diagnostics)))
;; an Observation POSTed to Patient/$validate was "All OK": the endpoint names the type it takes
(define obs (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")))
(let-values ([(st oo) (post app "/Patient/$validate" obs)])
  (check-equal? st 400)
  (check-regexp-match #rx"the resource is an Observation, but Patient/[$]validate takes a Patient [(]POST it to /Observation/[$]validate[)]"
                      (hash-ref (car (hash-ref oo 'issue)) 'diagnostics)))
(let-values ([(st oo) (post app "/Patient/$validate" (params (hasheq 'name "resource" 'resource obs)))])
  (check-equal? st 400))
;; an inline declaration is an operation value too: served, and applied in-process by the same handler
(define $echo (dynamic-require (collection-file-path "ops-app.rkt" "fhir" "tests") '$echo))
(define (result-of p) (hash-ref (car (hash-ref p 'parameter)) 'valueString))
(check-equal? (result-of ($echo #:message "hi")) "hi")
(check-equal? (result-of (apply-operation "$echo" #:message "there")) "there")
(check-equal? (result-of (apply-operation "urn:fhir-capability:operation:echo")) "pong")
(let-values ([(st p) (post app "/$echo" (params (hasheq 'name "message" 'valueString "over http")))])
  (check-equal? st 200)
  (check-equal? (result-of p) "over http"))
