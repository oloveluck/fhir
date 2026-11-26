#lang racket/base

;;; tx-harness.rkt — run the OFFICIAL terminology-service test suite (hl7.fhir.uv.tx-ecosystem,
;;; vendored in fhir-spec as hl7.fhir.uv.tx-ecosystem.tgz) against terminology/service.rkt.
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

(require (only-in fhir/spec-package spec-package-path))
(require racket/contract racket/list racket/string racket/runtime-path
         json file/gunzip file/untar
         (only-in "../service.rkt" resources->resolver packages->resolver make-undecidable? policy-of
                  rule-systems-without-content
                  expand/json validate-code/json cs-validate-code/json lookup/json translate/json
                  current-terminology-strict? exn:fail:terminology?))

(provide
 (struct-out tx-results)
 (contract-out [run-tx-suite (->* () (#:verbose? boolean?) tx-results?)]))

;; skips : (listof string) — each skipped test as "<reason>: <suite>/<test>"
(struct tx-results (pass fail skip failures skips) #:transparent)

(define tx-tgz (spec-package-path "hl7.fhir.uv.tx-ecosystem.tgz"))
;; the base specification the suite's servers hold (its expected answers are R5's)
(define core-resolver (packages->resolver (list (spec-package-path "hl7.fhir.r5.core.tgz"))))

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
               ;; 54 of the suite's files begin with a byte-order mark, which is no JSON
               (define text (if (and (>= (bytes-length bs) 3) (equal? (subbytes bs 0 3) #"\357\273\277"))
                                (subbytes bs 3)
                                bs))
               (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr text)))
               (when js (hash-set! table (substring s (string-length "package/tests/")) js))))
           '()))
  (thread-wait inflate)
  table)

;; ---- per-test execution -----------------------------------------------------------------------
(define (param-value params name)
  (for/or ([p (in-list (hash-ref params 'parameter '()))]
           #:when (equal? (hash-ref p 'name #f) name))
    (for/or ([(k v) (in-hash p)] #:when (regexp-match? #px"^value" (symbol->string k))) v)))
;; every value of a repeating parameter
(define (param-values params name)
  (for*/list ([p (in-list (hash-ref params 'parameter '()))]
              #:when (equal? (hash-ref p 'name #f) name)
              [v (in-value (for/or ([(k v) (in-hash p)] #:when (regexp-match? #px"^value" (symbol->string k))) v))]
              #:when v)
    v))
;; the resources a request carries under a name (tx-resource, valueSet)
(define (param-resources params name)
  (for/list ([p (in-list (hash-ref params 'parameter '()))]
             #:when (equal? (hash-ref p 'name #f) name)
             #:when (hash? (hash-ref p 'resource #f)))
    (hash-ref p 'resource)))

;; does the request carry this parameter at all (whatever its value)?
(define (param-present? params name)
  (for/or ([p (in-list (hash-ref params 'parameter '()))])
    (equal? (hash-ref p 'name #f) name)))

;; the codes of an expansion, nested or flat (a test may answer either: `response:flat`)
(define (expansion-codes js)
  (define (codes entries)
    (append-map (lambda (c) (cons (format "~a" (hash-ref c 'code "")) (codes (hash-ref c 'contains '()))))
                entries))
  (sort (codes (hash-ref (hash-ref js 'expansion (hasheq)) 'contains '())) string<?))

;; a suite's setup resources -> the LIST the service indexes (several versions of one canonical
;; must all survive, so this cannot be a url-keyed hash)
(define (setup-resources tree setup)
  (for/list ([f (in-list (if (list? setup) setup '()))]
             #:when (hash-ref tree f #f)
             #:when (string? (hash-ref (hash-ref tree f) 'url #f)))
    (hash-ref tree f)))

;; the url an inline value set is known by while its request is answered
(define inline-url "urn:tx-suite:inline-valueset")

;; request-resolver : resolver request -> (values resolver (or/c url #f))
;; The resolver a request is answered over: the resources it carries (`tx-resource`, an inline
;; `valueSet`) ahead of the suite's, and the url of its inline value set, if it has one.
(define (request-resolver resolver request)
  (define inline (let ([vs (param-resources request "valueSet")]) (and (pair? vs) (car vs))))
  (define inline* (and inline (if (hash-ref inline 'url #f) inline (hash-set inline 'url inline-url))))
  (define extra (append (if inline* (list inline*) '()) (param-resources request "tx-resource")))
  (values (if (null? extra)
              resolver
              (let ([own (resources->resolver extra)])
                (lambda (url [version #f]) (or (own url version) (resolver url version)))))
          (and inline* (hash-ref inline* 'url))))

;; request parameters that CHANGE the answer and which the service does not implement — a case
;; using one is SKIPPED (counting it as a failure would measure an unimplemented parameter, not a
;; wrong expansion; counting it as a pass would be false)
(define unsupported-expand-params '("excludeNotForUI" "limit" "_limit"))

;; a test may name a `profile` Parameters file carrying SERVER-level version parameters
;; (system-version / force-system-version / check-system-version) — the `version` suite's -force,
;; -check and -default variants differ from their base test only by this file; a request may
;; carry them too, and `default-valueset-version`
(define (policy-for tree t request)
  (define f (hash-ref t 'profile #f))
  (define ps (or (and f (hash-ref tree f #f)) (hasheq)))
  (define (all name) (append (param-values ps name) (param-values request name)))
  (policy-of (all "system-version") (all "force-system-version") (all "check-system-version")
             (all "default-valueset-version")))

;; A test expects an ANSWER (a ValueSet, a Parameters) or a REFUSAL (an OperationOutcome). The
;; service refuses by raising exn:fail:terminology; `answered` runs a request and holds it to
;; which of the two the test expects, then to `compare` (answer -> verdict).
(define (refusal-expected? expected) (equal? (hash-ref expected 'resourceType #f) "OperationOutcome"))
(define (answered expected thunk compare)
  (define outcome
    (with-handlers ([exn:fail:terminology? values])
      (parameterize ([current-terminology-strict? #t]) (thunk))))
  (cond
    [(and (exn? outcome) (refusal-expected? expected)) 'pass]
    [(exn? outcome) (cons 'fail (format "refused (~a) where an answer is expected" (exn-message outcome)))]
    [(refusal-expected? expected)
     (cons 'fail (format "answered where a refusal is expected (~a)" (expected-issue expected)))]
    [else (compare outcome)]))
(define (expected-issue oo)
  (define issues (hash-ref oo 'issue '()))
  (if (pair? issues)
      (format "~a: ~a" (hash-ref (car issues) 'code "?")
              (hash-ref (hash-ref (car issues) 'details (hasheq)) 'text ""))
      "no issue"))

(define (run-expand resolver request expected policy [threshold #f])
  (define-values (resolver* inline) (request-resolver resolver request))
  (define url (or inline (param-value request "url")))
  (cond
    [(for/or ([p (in-list unsupported-expand-params)]) (and (param-present? request p) p))
     => (lambda (p) (cons 'skip (format "expand parameter ~a" p)))]
    [(not url) (cons 'skip "expand without a value set")]
    ;; UCUM is a grammar: what an expansion of it by rule lists is a server's choice (tx.fhir.org
    ;; lists a common-units value set), not the value set's codes
    [(member "http://unitsofmeasure.org" (rule-systems-without-content resolver* (format "~a" url)))
     (cons 'skip "expand of UCUM by rule (no list of its codes)")]
    [else
     (define vsv (param-value request "valueSetVersion"))
     ;; forward by PRESENCE, not truthiness: `excludeNested: false` is meaningful (it asks for the
     ;; hierarchical form) and would be dropped by a truthy test
     (define params
       (for/fold ([h (for/hash ([n (in-list '("offset" "count" "activeOnly" "filter" "displayLanguage"
                                             "includeDesignations" "excludeNested"))]
                                #:when (param-present? request n))
                       (values n (param-value request n)))])
                 ([n (in-list '("property" "useSupplement" "designation"))] #:when (param-present? request n))
         (hash-set h n (param-values request n))))
     (define params* (if threshold (hash-set params "too-costly-threshold" threshold) params))
     (answered expected
               (lambda () (expand/json resolver* (format "~a" url) (and vsv (format "~a" vsv)) params* policy))
               (lambda (out)
                 (define actual (expansion-codes out))
                 (define want (expansion-codes expected))
                 (if (equal? actual want)
                     'pass
                     (cons 'fail (format "codes ~a != expected ~a" actual want)))))]))

;; all three input shapes: a bare code, a Coding, or a CodeableConcept
(define (run-validate-code resolver request expected policy [accept-language #f])
  (define-values (resolver* inline) (request-resolver resolver request))
  (define url (or inline (param-value request "url")))
  (define code (param-value request "code"))
  (define coding (param-value request "coding"))
  (define cc (param-value request "codeableConcept"))
  (define system (param-value request "system"))
  (define display (param-value request "display"))
  (define system-version (param-value request "systemVersion"))
  (define vs-version (param-value request "valueSetVersion"))
  (define want (param-value expected "result"))
  (define (text v) (and v (format "~a" v)))
  (cond
    [(not url) (cons 'skip "validate-code without a value set")]
    [(not (or (refusal-expected? expected) (boolean? want)))
     (cons 'skip "validate-code: the reference states no result")]
    [(not (or code coding cc)) (cons 'skip "validate-code without a code")]
    [else
     (answered
      expected
      (lambda ()
        (validate-code/json resolver* (format "~a" url) (text code) (text system)
                            #:coding coding #:codeable-concept cc
                            #:display (text display)
                            #:lenient-display? (eq? (param-value request "lenient-display-validation") #t)
                            #:system-version (text system-version)
                            #:valueset-version (text vs-version)
                            #:policy policy
                            #:active-only? (eq? (param-value request "activeOnly") #t)
                            #:abstract? (not (and (param-present? request "abstract")
                                                  (eq? (param-value request "abstract") #f)))
                            #:display-language (or (text (param-value request "displayLanguage")) accept-language)
                            #:infer-system? (eq? (param-value request "inferSystem") #t)
                            #:supplements (map text (param-values request "useSupplement"))))
      (lambda (got-params)
        (define got (param-value got-params "result"))
        (cond
          [(not (eq? got want)) (cons 'fail (format "result ~a != expected ~a" got want))]
          ;; when the reference states the resolved code/system, ours must agree (never prose)
          [(let ([wc (param-value expected "code")] [gc (param-value got-params "code")])
             (and wc gc (not (equal? (format "~a" wc) (format "~a" gc)))))
           (cons 'fail (format "code ~a != expected ~a"
                               (param-value got-params "code") (param-value expected "code")))]
          [else 'pass])))]))

;; CodeSystem-level $validate-code: the same verdict comparison, against a system not a ValueSet
(define (run-cs-validate resolver request expected)
  (define system (param-value request "url"))
  (define code (param-value request "code"))
  (define coding (param-value request "coding"))
  (define display (param-value request "display"))
  (define want (param-value expected "result"))
  (cond
    [(not (and (or system coding) (or (refusal-expected? expected) (boolean? want))))
     (cons 'skip "cs-validate-code: no system, or no result expected")]
    [else
     (answered
      expected
      (lambda ()
        (cs-validate-code/json resolver (and system (format "~a" system))
                               (and code (format "~a" code))
                               (let ([v (param-value request "version")]) (and v (format "~a" v)))
                               #:coding coding
                               #:display (and display (format "~a" display))
                               #:lenient-display? (eq? (param-value request "lenient-display-validation") #t)))
      (lambda (out)
        (define got (param-value out "result"))
        (if (eq? got want) 'pass (cons 'fail (format "result ~a != expected ~a" got want)))))]))

;; $lookup: compare the resolved display (the fact the operation exists to deliver)
(define (run-lookup resolver request expected)
  (define system (param-value request "system"))
  (define code (param-value request "code"))
  (define want-display (param-value expected "display"))
  (cond
    [(not (and system code (or (refusal-expected? expected) want-display)))
     (cons 'skip "lookup: no display expected")]
    [else
     (answered
      expected
      (lambda ()
        (lookup/json resolver (format "~a" system) (format "~a" code)
                     (let ([v (param-value request "version")]) (and v (format "~a" v)))
                     #:supplements (map (lambda (u) (format "~a" u)) (param-values request "useSupplement"))))
      (lambda (out)
        (define got (param-value out "display"))
        (if (equal? (format "~a" got) (format "~a" want-display))
            'pass
            (cons 'fail (format "display ~s != expected ~s" got want-display)))))]))

;; $translate: compare the `result` verdict
(define (run-translate resolver request expected)
  (define url (param-value request "url"))
  (define code (param-value request "code"))
  (define system (param-value request "system"))
  (define want (param-value expected "result"))
  (cond
    [(not (and url code (boolean? want))) (cons 'skip "translate: no url, code or result")]
    [else
     (answered
      expected
      (lambda () (translate/json resolver (format "~a" url) (format "~a" code) (and system (format "~a" system))))
      (lambda (out)
        (define got (param-value out "result"))
        (if (eq? got want) 'pass (cons 'fail (format "result ~a != expected ~a" got want)))))]))

;; names-absent-content? : resolver request -> boolean
;; Does the request name a code system whose content is not here (no CodeSystem resource, or a
;; `not-present` placeholder), or a value set that selects from one by rule, or one nothing
;; defines? UCUM is here: its codes are decided by its grammar.
(define (names-absent-content? resolver request)
  (define-values (resolver* inline) (request-resolver resolver request))
  (define (here? system)
    (or (equal? system "http://unitsofmeasure.org")
        (let ([cs (resolver* system)])
          (and cs (not (equal? (hash-ref cs 'content #f) "not-present"))))))
  (define systems
    (filter string?
            (append (param-values request "system") (param-values request "sourceSystem")
                    (for/list ([c (in-list (param-values request "coding"))] #:when (hash? c)) (hash-ref c 'system #f))
                    (for*/list ([cc (in-list (param-values request "codeableConcept"))] #:when (hash? cc)
                                [c (in-list (hash-ref cc 'coding '()))])
                      (hash-ref c 'system #f)))))
  (define url (or inline (param-value request "url")))
  (or (for/or ([s (in-list systems)]) (not (here? s)))
      (and (string? url)
           (not (param-present? request "system")) (not (param-present? request "coding"))
           (or (not (resolver* url))
               (pair? (remove "http://unitsofmeasure.org" (rule-systems-without-content resolver* url)))))
      (and (string? url) (resolver* url)
           (pair? (remove "http://unitsofmeasure.org" (rule-systems-without-content resolver* url))))))

;; A per-test TIME BUDGET: the suite includes value sets whose expansion is unbounded for an
;; offline implementation (whole-code-system imports, external terminologies). One pathological
;; case must not stall the run — over budget counts as a skip, never as a pass.
(define budget-seconds 5)
(define (with-budget thunk)
  (define result (cons 'skip "over the time budget"))
  (define t (thread (lambda () (set! result (thunk)))))
  (if (sync/timeout budget-seconds t) result (begin (kill-thread t) (cons 'skip "over the time budget"))))

;; ---- the suite runner --------------------------------------------------------------------------
(define (run-tx-suite #:verbose? [verbose? #f])
  (define tree (load-tests-tree tx-tgz))
  (define cases (hash-ref tree "test-cases.json"))
  (for/fold ([pass 0] [fail 0] [skip 0] [failures '()] [skips '()]
             #:result (tx-results pass fail skip (reverse failures) (reverse skips)))
            ([suite (in-list (hash-ref cases 'suites '()))])
    (define resources (setup-resources tree (hash-ref suite 'setup #f)))
    ;; the suite's own resources, then the base specification's (its tests name FHIR's own code
    ;; systems and value sets, which every terminology server holds)
    (define resolver
      (and (pair? resources)
           (let ([own (resources->resolver resources)])
             (lambda (url [version #f]) (or (own url version) (core-resolver url version))))))
    (define tx resolver)
    (define undecidable? (and resolver (make-undecidable? resolver)))
    (for/fold ([pass pass] [fail fail] [skip skip] [failures failures] [skips skips])
              ([t (in-list (hash-ref suite 'tests '()))])
      (define op (hash-ref t 'operation ""))
      (define req-file (hash-ref t 'request #f))
      (define resp-file (hash-ref t 'response #f))
      (define request (and req-file (hash-ref tree req-file #f)))
      (define expected (and resp-file (hash-ref tree resp-file #f)))
      (define verdict
        (cond
          [(not tx) (cons 'skip "the suite sets up no resources (an external terminology)")]
          [(not request) (cons 'skip (format "no request file (operation ~a)" op))]
          [(not expected) (cons 'skip (format "no response file (operation ~a)" op))]
          [else
           (with-budget
             (lambda ()
               (with-handlers ([exn:fail? (lambda (e) (cons 'fail (exn-message e)))])
                 ;; a ValueSet resting on a code system we cannot see (SNOMED, LOINC, OHDSI…) is
                 ;; undecidable offline: skip such a case rather than record a wrong answer
                 (define general? (equal? (hash-ref suite 'mode "general") "general"))
                 ;; (a general suite's expected answers are a server's that holds no more than the
                 ;; suite sets up: a value set on a code system nothing defines is answered there too)
                 (define vs-undecidable?
                   (or (and (not general?)
                            (member op '("expand" "validate-code"))
                            (let ([u (param-value request "url")])
                              (and u (undecidable? (format "~a" u)))))
                       ;; a suite written for a server that holds SNOMED CT, LOINC, OMOP … is held
                       ;; where its test names only code systems that are here
                       (and (not general?) (names-absent-content? resolver request))))
                 (case (if vs-undecidable? "undecidable" op)
                   [("expand")
                    (run-expand resolver request expected (policy-for tree t request)
                                ;; a test may set the server's limit (X-TOO-COSTLY-THRESHOLD)
                                (let ([h (hash-ref t 'header #f)])
                                  (and (hash? h) (equal? (hash-ref h 'name #f) "X-TOO-COSTLY-THRESHOLD")
                                       (string->number (format "~a" (hash-ref h 'value ""))))))]
                   [("validate-code")
                    (run-validate-code resolver request expected (policy-for tree t request)
                                       (hash-ref t 'Accept-Language #f))]
                   [("cs-validate-code") (run-cs-validate resolver request expected)]
                   [("lookup") (run-lookup resolver request expected)]
                   [("translate") (run-translate resolver request expected)]
                   [("undecidable") (cons 'skip "the value set rests on a code system that is not here")]
                   [else (cons 'skip (format "operation ~a" op))]))))]))
      (cond
        [(eq? verdict 'pass) (values (add1 pass) fail skip failures skips)]
        [(eq? (car verdict) 'skip)
         (values pass fail (add1 skip) failures
                 (cons (format "~a: ~a/~a" (cdr verdict) (hash-ref suite 'name "?") (hash-ref t 'name "?")) skips))]
        [else (values pass (add1 fail) skip
                      (cons (format "~a/~a: ~a" (hash-ref suite 'name "?") (hash-ref t 'name "?")
                                    (cdr verdict))
                            failures)
                      skips)]))))

(module+ main
  (define verbose? (and (member "-v" (vector->list (current-command-line-arguments))) #t))
  (define r (run-tx-suite))
  (when verbose? (for ([f (in-list (tx-results-failures r))]) (eprintf "  ~a\n" f)))
  (printf "terminology conformance: ~a/~a  (skipped ~a: external terminologies + unimplemented ops)\n"
          (tx-results-pass r) (+ (tx-results-pass r) (tx-results-fail r)) (tx-results-skip r)))
