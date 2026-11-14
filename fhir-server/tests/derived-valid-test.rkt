#lang racket/base

;;; derived-valid-test.rkt — what a capability app derives about itself is valid FHIR: its
;;; CapabilityStatement (/metadata) and each OperationDefinition (GET /OperationDefinition/<code>),
;;; held to the base types and their invariants by the validator. A new user ran them through
;;; `raco fhir-validate` and found `type`/`instance` missing (false was dropped), a lowercase `name`
;;; (cnl-0), and an instance statement with no implementation (cpb-2, cpb-14).
;;; The validator reads R5; the app speaks R6, so `fhirVersion` (an R6 code) is the one issue left out.

(require rackunit racket/list
         (only-in fhir/r6/types)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/capability/runtime app-capability-statement app-operation-definitions)
         (only-in fhir/conformance/validate validate-issues issue-severity issue-path issue-msg issue-code))

(define app (dynamic-require (collection-file-path "ops-app.rkt" "fhir" "tests") 'app))

;; problems : jsexpr -> (listof string)   errors and warnings, fhirVersion aside
(define (problems js)
  (for/list ([i (in-list (validate-issues js))]
             #:when (member (issue-severity i) '("error" "warning"))
             #:unless (regexp-match? #rx"fhirVersion" (or (issue-path i) "")))
    (format "~a ~a: ~a" (issue-severity i) (issue-path i) (issue-msg i))))

(define cs (node->jsexpr (app-capability-statement app)))
(check-equal? (problems cs) '())
(check-equal? (hash-ref (hash-ref cs 'implementation) 'url) "http://example.org/fhir")
(for ([od (in-list (app-operation-definitions app))])
  (define js (node->jsexpr od))
  (check-equal? (problems js) '() (hash-ref js 'code))
  (check-true (boolean? (hash-ref js 'type #f)) "type is said, false included")
  (check-true (boolean? (hash-ref js 'instance #f)))
  (check-regexp-match #px"^[A-Z][A-Za-z0-9]*$" (hash-ref js 'name)))

;; the command line takes it as it comes off /metadata: the statement names R6, and that is what it
;; is validated in (`raco fhir-validate` read R5 and refused `6.0.0-ballot4`)
(require racket/system racket/file racket/port json compiler/find-exe)
(define f (make-temporary-file "cs-~a.json"))
(call-with-output-file f #:exists 'truncate (lambda (o) (write-json cs o)))
(define out (open-output-string))
(check-equal? (parameterize ([current-output-port out] [current-error-port out])
                (system*/exit-code (find-exe) "-l-" "raco" "fhir-validate" (path->string f) "--format" "text"))
              0 (get-output-string out))
(delete-file f)

;; a search answers a searchset Bundle FHIR accepts: each entry's fullUrl and a self link (bdl-15,
;; bdl-18 …), which only the server knows (the request's Host) — a new user validated one and found
;; neither. The router's Bundle plus what http/server adds, an ignored parameter's outcome included.
(require (only-in fhir/http/router handle) (only-in fhir/http/server bundle-with-urls))
(define sdir (make-temporary-directory "search-app-~a"))
(define sapp-file (build-path sdir "study.rkt"))
(void (call-with-output-file sapp-file
  (lambda (o) (write-string "#lang fhir/capability\n(server #:url \"http://example.org/fhir\")\n(resource Patient #:interactions (read create search-type) #:search-params ([gender token]))\n" o))))
(define sapp (dynamic-require sapp-file 'app))
(define-values (cst _c) (handle sapp "POST" "/Patient" '() "{\"resourceType\":\"Patient\",\"gender\":\"female\"}"))
(check-equal? cst 201)
(define-values (sst sjs) (handle sapp "GET" "/Patient" '((gender . "female") (bogus . "1")) ""))
(check-equal? sst 200)
(define bundle (bundle-with-urls sjs "http://localhost:8080" "/Patient?gender=female&bogus=1"))
(check-equal? (problems bundle) '())
;; the outcome entry (the ignored `bogus`) comes first, with a urn:uuid; the match has its own url
(check-regexp-match #rx"^urn:uuid:" (hash-ref (car (hash-ref bundle 'entry)) 'fullUrl))
(check-regexp-match #rx"^http://localhost:8080/Patient/" (hash-ref (cadr (hash-ref bundle 'entry)) 'fullUrl))
(check-equal? (hash-ref (car (hash-ref bundle 'link)) 'url) "http://localhost:8080/Patient?gender=female&bogus=1")
;; the router's Bundle alone is what the validator refused
(check-not-equal? (problems sjs) '())
(delete-directory/files sdir)
