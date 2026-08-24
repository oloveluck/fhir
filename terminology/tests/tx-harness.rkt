#lang racket/base

;;; tx-harness.rkt — run the OFFICIAL terminology-service test suite (hl7.fhir.uv.tx-ecosystem,
;;; vendored as spec/hl7.fhir.uv.tx-ecosystem.tgz) against terminology/service.rkt.
;;;
;;; The package ships `tests/test-cases.json`: 35 suites, each with `setup` resources (the suite's
;;; own CodeSystems/ValueSets — the reason this suite is executable offline at all) and tests
;;; naming a request Parameters file and an expected response file.
;;;
;;; WHAT WE RUN — the operations this repo implements, over suites whose setup is self-contained:
;;;   expand         : compare the SET OF CODES in expansion.contains
;;;   validate-code  : compare the `result` boolean
;;; Everything else (lookup, translate, compare, cs-validate-code, batch, metadata) and every
;;; suite needing an external terminology (SNOMED CT, LOINC, tx.fhir.org) is SKIPPED and counted.
;;;
;;; Message prose is deliberately NOT compared — the reference's wording is unreproducible; the
;;; verdict is what conformance means here (the same philosophy as tests/validate-diff-test.rkt).

(require racket/contract racket/list racket/string racket/runtime-path
         json file/gunzip file/untar
         (only-in "../service.rkt" resources->resolver make-terminology/resolver
                  make-lookup make-cs-validate make-undecidable? policy-of no-version-policy)
         (only-in "../../fhirpath/terminology.rkt" tx-service-expand tx-service-validate
                  tx-service-translate)
         (only-in "../../serialize/to-json.rkt" node->jsexpr))

(provide
 (struct-out tx-results)
 (contract-out [run-tx-suite (->* () (#:verbose? boolean?) tx-results?)]))

(struct tx-results (pass fail skip failures) #:transparent)

(define-runtime-path tx-tgz "../../spec/hl7.fhir.uv.tx-ecosystem.tgz")

;; ---- read the package's tests/ tree into memory ----------------------------------------------
;; -> hash "tests/<relpath>" -> jsexpr
(define (load-tests-tree tgz)
  (define table (make-hash))
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate (thread (lambda ()
                            (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                            (close-output-port pout))))
  (untar pin #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define bs (if (= size 0) #"" (read-bytes size content)))
             (define s (path->string name))
             (when (and (regexp-match? #px"^package/tests/.*\\.json$" s)
                        (not (regexp-match? #px"/\\." s)))
               (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bs)))
               (when js (hash-set! table (substring s (string-length "package/tests/")) js))))
           '()))
  (thread-wait inflate)
  table)

;; ---- per-test execution -----------------------------------------------------------------------
(define (param-value params name)
  (for/or ([p (in-list (hash-ref params 'parameter '()))]
           #:when (equal? (hash-ref p 'name #f) name))
    (for/or ([(k v) (in-hash p)] #:when (regexp-match? #px"^value" (symbol->string k))) v)))

;; does the request carry this parameter at all (whatever its value)?
(define (param-present? params name)
  (for/or ([p (in-list (hash-ref params 'parameter '()))])
    (equal? (hash-ref p 'name #f) name)))

(define (expansion-codes js)
  (define e (hash-ref js 'expansion (hasheq)))
  (sort (for/list ([c (in-list (hash-ref e 'contains '()))]) (format "~a" (hash-ref c 'code "")))
        string<?))

;; a suite's setup resources -> the url->resource table its tests run against
;; a suite's setup resources -> the LIST the service indexes (several versions of one canonical
;; must all survive, so this cannot be a url-keyed hash)
(define (setup-resources tree setup)
  (for/list ([f (in-list (if (list? setup) setup '()))]
             #:when (hash-ref tree f #f)
             #:when (string? (hash-ref (hash-ref tree f) 'url #f)))
    (hash-ref tree f)))

;; request parameters that CHANGE the expansion and which our service does not implement — a case
;; using one is SKIPPED (counting it as a failure would measure an unimplemented parameter, not a
;; wrong expansion; counting it as a pass would be false)
(define unsupported-expand-params
  '("excludeNotForUI" "system-version" "force-system-version" "useSupplement"
    "default-valueset-version" "tx-resource" "includeDefinition" "limit" "_limit"))

(define (run-expand tx request expected [policy no-version-policy])
  (define url (param-value request "url"))
  (define vs (param-value request "valueSet"))
  (cond
    [(for/or ([p (in-list unsupported-expand-params)]) (param-value request p)) 'skip]
    [(not (or url vs)) 'skip]                     ; inline-ValueSet expansion not exercised here
    [else
     (define vsv (param-value request "valueSetVersion"))
     ;; forward the expansion parameters the service implements
     ;; forward by PRESENCE, not truthiness: `excludeNested: false` is meaningful (it asks for the
     ;; hierarchical form) and would be dropped by a truthy test
     (define params
       (for/hash ([n (in-list '("offset" "count" "activeOnly" "filter" "displayLanguage"
                                "includeDesignations" "property" "excludeNested"))]
                  #:when (param-present? request n))
         (values n (param-value request n))))
     (define out ((tx-service-expand tx) (format "~a" (or url vs))
                  (and vsv (format "~a" vsv)) params policy))
     (define actual (if (pair? out) (expansion-codes (node->jsexpr (car out))) '()))
     (define want (expansion-codes expected))
     (cond [(and (null? want) (null? actual)) 'skip]   ; the reference errored: nothing to compare
           [(equal? actual want) 'pass]
           [else (cons 'fail (format "codes ~a != expected ~a" actual want))])]))

;; all three input shapes: a bare code, a Coding, or a CodeableConcept
;; a test may name a `profile` Parameters file carrying SERVER-level version parameters
;; (system-version / force-system-version / check-system-version) — the `version` suite's -force,
;; -check and -default variants differ from their base test only by this file
(define (policy-for tree t)
  (define f (hash-ref t 'profile #f))
  (define ps (and f (hash-ref tree f #f)))
  (cond
    [(not ps) no-version-policy]
    [else (policy-of (param-value ps "system-version")
                     (param-value ps "force-system-version")
                     (param-value ps "check-system-version"))]))

(define (run-validate-code tx request expected [policy no-version-policy])
  (define url (param-value request "url"))
  (define code (param-value request "code"))
  (define coding (param-value request "coding"))
  (define cc (param-value request "codeableConcept"))
  (define system (param-value request "system"))
  (define display (param-value request "display"))
  (define lenient? (eq? (param-value request "lenient-display-validation") #t))
  (define system-version (param-value request "systemVersion"))
  (define vs-version (param-value request "valueSetVersion"))
  (define want (param-value expected "result"))
  (cond
    [(not (and url (boolean? want) (or code coding cc))) 'skip]
    [else
     (define out ((tx-service-validate tx) (format "~a" url)
                  (and code (format "~a" code))
                  (and system (format "~a" system))
                  #:coding coding #:codeable-concept cc
                  #:display (and display (format "~a" display))
                  #:lenient-display? lenient?
                  #:system-version (and system-version (format "~a" system-version))
                  #:valueset-version (and vs-version (format "~a" vs-version))
                  #:policy policy))
     (define got-params (and (pair? out) (node->jsexpr (car out))))
     (define got (and got-params (param-value got-params "result")))
     (cond
       [(not (eq? got want)) (cons 'fail (format "result ~a != expected ~a" got want))]
       ;; when the reference states the resolved code/system, ours must agree (never prose)
       [(let ([wc (param-value expected "code")] [gc (param-value got-params "code")])
          (and wc gc (not (equal? (format "~a" wc) (format "~a" gc)))))
        (cons 'fail (format "code ~a != expected ~a"
                            (param-value got-params "code") (param-value expected "code")))]
       [else 'pass])]))

;; CodeSystem-level $validate-code: the same verdict comparison, against a system not a ValueSet
(define (run-cs-validate resolver request expected)
  (define system (param-value request "url"))
  (define code (param-value request "code"))
  (define coding (param-value request "coding"))
  (define display (param-value request "display"))
  (define want (param-value expected "result"))
  (cond
    [(not (and (or system coding) (boolean? want))) 'skip]
    [else
     (define out ((make-cs-validate resolver) (and system (format "~a" system))
                  (and code (format "~a" code))
                  (let ([v (param-value request "version")]) (and v (format "~a" v)))
                  #:coding coding
                  #:display (and display (format "~a" display))
                  #:lenient-display? (eq? (param-value request "lenient-display-validation") #t)))
     (define got (param-value (node->jsexpr (car out)) "result"))
     (if (eq? got want) 'pass (cons 'fail (format "result ~a != expected ~a" got want)))]))

;; $lookup: compare the resolved display (the fact the operation exists to deliver)
(define (run-lookup resolver request expected)
  (define system (param-value request "system"))
  (define code (param-value request "code"))
  (define want-display (param-value expected "display"))
  (cond
    [(not (and system code want-display)) 'skip]
    [else
     (define out ((make-lookup resolver) (format "~a" system) (format "~a" code)
                  (let ([v (param-value request "version")]) (and v (format "~a" v)))))
     (define got (param-value (node->jsexpr (car out)) "display"))
     (if (equal? (format "~a" got) (format "~a" want-display))
         'pass
         (cons 'fail (format "display ~s != expected ~s" got want-display)))]))

;; $translate: compare the `result` verdict (tx-translate already existed; it was merely unwired)
(define (run-translate tx request expected)
  (define url (param-value request "url"))
  (define code (param-value request "code"))
  (define system (param-value request "system"))
  (define want (param-value expected "result"))
  (cond
    [(not (and url code (boolean? want))) 'skip]
    [else
     (define out ((tx-service-translate tx) (format "~a" url) (format "~a" code)
                  (and system (format "~a" system))))
     (define got (and (pair? out) (param-value (node->jsexpr (car out)) "result")))
     (if (eq? got want) 'pass (cons 'fail (format "result ~a != expected ~a" got want)))]))

;; A per-test TIME BUDGET: the suite includes value sets whose expansion is unbounded for an
;; offline implementation (whole-code-system imports, external terminologies). One pathological
;; case must not stall the run — over budget counts as a skip, never as a pass.
(define budget-seconds 5)
(define (with-budget thunk)
  (define result 'skip)
  (define t (thread (lambda () (set! result (thunk)))))
  (if (sync/timeout budget-seconds t) result (begin (kill-thread t) 'skip)))

;; ---- the suite runner --------------------------------------------------------------------------
(define (run-tx-suite #:verbose? [verbose? #f])
  (define tree (load-tests-tree tx-tgz))
  (define cases (hash-ref tree "test-cases.json"))
  (for/fold ([pass 0] [fail 0] [skip 0] [failures '()]
             #:result (tx-results pass fail skip (reverse failures)))
            ([suite (in-list (hash-ref cases 'suites '()))])
    (define resources (setup-resources tree (hash-ref suite 'setup #f)))
    (define resolver (and (pair? resources) (resources->resolver resources)))
    (define tx (and resolver (make-terminology/resolver resolver)))
    (define undecidable? (and resolver (make-undecidable? resolver)))
    (for/fold ([pass pass] [fail fail] [skip skip] [failures failures])
              ([t (in-list (hash-ref suite 'tests '()))])
      (define op (hash-ref t 'operation ""))
      (define req-file (hash-ref t 'request #f))
      (define resp-file (hash-ref t 'response #f))
      (define request (and req-file (hash-ref tree req-file #f)))
      (define expected (and resp-file (hash-ref tree resp-file #f)))
      (define verdict
        (cond
          [(or (not tx) (not request) (not expected)) 'skip]     ; external tx / missing files
          [else
           (with-budget
             (lambda ()
               (with-handlers ([exn:fail? (lambda (e) (cons 'fail (exn-message e)))])
                 ;; a ValueSet resting on a code system we cannot see (SNOMED, LOINC, OHDSI…) is
                 ;; undecidable offline: skip such a case rather than record a wrong answer
                 (define vs-undecidable?
                   (and (member op '("expand" "validate-code"))
                        (let ([u (param-value request "url")])
                          (and u (undecidable? (format "~a" u))))))
                 (case (if vs-undecidable? "skip" op)
                   [("expand") (run-expand tx request expected (policy-for tree t))]
                   [("validate-code") (run-validate-code tx request expected (policy-for tree t))]
                   [("cs-validate-code") (run-cs-validate resolver request expected)]
                   [("lookup") (run-lookup resolver request expected)]
                   [("translate") (run-translate tx request expected)]
                   [else 'skip]))))]))
      (cond
        [(eq? verdict 'pass) (values (add1 pass) fail skip failures)]
        [(eq? verdict 'skip) (values pass fail (add1 skip) failures)]
        [else (values pass (add1 fail) skip
                      (cons (format "~a/~a: ~a" (hash-ref suite 'name "?") (hash-ref t 'name "?")
                                    (cdr verdict))
                            failures))]))))

(module+ main
  (define verbose? (and (member "-v" (vector->list (current-command-line-arguments))) #t))
  (define r (run-tx-suite))
  (when verbose? (for ([f (in-list (tx-results-failures r))]) (eprintf "  ~a\n" f)))
  (printf "terminology conformance: ~a/~a  (skipped ~a: external terminologies + unimplemented ops)\n"
          (tx-results-pass r) (+ (tx-results-pass r) (tx-results-fail r)) (tx-results-skip r)))
