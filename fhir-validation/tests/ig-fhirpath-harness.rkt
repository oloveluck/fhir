#lang racket/base

;;; ig-fhirpath-harness.rkt — real Implementation Guides as a FHIRPath conformance corpus.
;;;
;;; A published IG carries two oracles for a FHIRPath engine, at no authoring cost:
;;;   invariants  — every `constraint` in the IG's own profiles must HOLD on the IG's own examples
;;;                 (an example that claims a profile in meta.profile is, by publication, valid
;;;                 against it). Each constraint is evaluated at its element path, once per focus
;;;                 item, with %resource/%rootResource = the example and %context = the focus.
;;;   search      — every SearchParameter expression must PARSE, and must EVALUATE without error on
;;;                 every example whose resourceType is one of the parameter's bases.
;;;
;;; Both are version-agnostic: the CALLER registers the matching tower (an R4 IG needs
;;; fhir/r4/schemas). Constraints on sliced elements (element id containing `:`) are skipped — a
;;; slice's constraint applies only to that slice's members, which this harness does not
;;; discriminate — and counted as skipped, never as passes.
;;;
;;; Only error-severity constraints are obligations: a `warning` constraint (dom-6 "should have
;;; narrative", R4 con-3, …) may legitimately be broken by a valid example, so its failures are
;;; counted as 'warn, never as 'fail.
;;;
;;; Data definitions
;;;   An Outcome is one of: 'pass | 'fail | 'warn | 'empty | 'error
;;;     'warn  — a warning-severity constraint evaluated to false (allowed)
;;;     'empty — the expression produced {} (FHIR treats an empty invariant result as not violated;
;;;              reported separately so the count stays visible)
;;;   A Finding is (finding profile-url key element example-name outcome detail)
;;;   An IgFhirpathReport collects counts per outcome plus the non-pass findings.

(require racket/contract racket/list racket/string racket/match
         json
         (only-in fhir/package read-package)
         (only-in fhir/serialize/read-json string->fhir-jsexpr)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/result/result ok? ok-value)
         (only-in fhir/model/registry type-registered?)
         (only-in fhirpath/parser/parse parse-fhirpath)
         (only-in fhirpath/eval eval-fhirpath))

(provide
 (struct-out finding)
 (struct-out ig-fhirpath-report)
 (contract-out
  [package-resources (-> path-string? (listof (cons/c string? any/c)))]
  [check-ig-invariants (-> path-string? ig-fhirpath-report?)]
  [check-ig-search-params (-> path-string? ig-fhirpath-report?)]
  [summarize (-> ig-fhirpath-report? (listof (cons/c string? exact-nonnegative-integer?)))]))

(struct finding (profile key element example outcome detail) #:transparent)
;; counts : hash outcome -> count ; skipped : count ; findings : (listof finding) (non-pass only)
(struct ig-fhirpath-report (counts skipped findings) #:transparent)

;; ---- package reading ---------------------------------------------------------------------------

;; package-resources : tgz -> (listof (cons file-name jsexpr))
;; every JSON resource in package/ and package/example/, decimals exact, by file name
(define (package-resources tgz)
  (define-values (_m rs exs) (read-package tgz #:exact-decimals? #t))
  (sort (append rs exs) string<? #:key car))

(define (rtype js) (and (hash? js) (hash-ref js 'resourceType #f)))
(define (jstr v) (if (string? v) v #f))
(define (profiles-of js)
  (define meta (hash-ref js 'meta #f))
  (define ps (and (hash? meta) (hash-ref meta 'profile '())))
  (if (list? ps) (filter string? ps) '()))

;; strip a `|version` suffix from a canonical
(define (canonical-url u) (car (string-split u "|")))

;; ---- evaluation --------------------------------------------------------------------------------

;; parse-cached : string -> (or ast exn)
(define parse-cache (make-hash))
(define (parse-cached s)
  (hash-ref! parse-cache s (lambda () (with-handlers ([exn:fail? values]) (parse-fhirpath s)))))

;; outcome-of : (listof item) -> Outcome
(define (outcome-of r)
  (match r
    ['() 'empty]
    [(list #t) 'pass]
    [(list #f) 'fail]
    [(list _) 'pass]                         ; singleton evaluation: a non-Boolean singleton is true
    [_ 'error]))                             ; a multi-item result for a Boolean constraint

;; eval-on : ast (listof item) node -> (values Outcome detail)
(define (eval-on ast focus resource #:context [context focus])
  (with-handlers ([exn:fail? (lambda (e) (values 'error (exn-message e)))])
    (define r (eval-fhirpath ast focus
                             #:strict? #f
                             #:externals (hash "resource" (list resource)
                                               "rootResource" (list resource)
                                               "context" context)))
    (define o (outcome-of r))
    (values o (if (eq? o 'error) (format "result ~a items" (length r)) ""))))

;; element-path->expression : "Patient.contact.name" -> "contact.name" ("" for the root)
;; choice suffixes [x] are dropped (FHIRPath navigates choice elements by their base name)
(define (element-path->expression path)
  (define segs (cdr (string-split (regexp-replace* #rx"\\[x\\]" path "") ".")))
  (string-join segs "."))

;; ---- invariants --------------------------------------------------------------------------------

;; profile-constraints : SD jsexpr -> (listof (list key expression element-id element-path severity))
(define (profile-constraints sd)
  (define elems (let ([snap (hash-ref sd 'snapshot #f)])
                  (if (hash? snap) (hash-ref snap 'element '()) '())))
  (for*/list ([el (in-list (if (list? elems) elems '()))]
              [c (in-list (let ([cs (hash-ref el 'constraint '())]) (if (list? cs) cs '())))]
              #:when (string? (hash-ref c 'expression #f)))
    (list (hash-ref c 'key "?") (hash-ref c 'expression) (hash-ref el 'id "") (hash-ref el 'path "")
          (hash-ref c 'severity "error"))))

(define (check-ig-invariants tgz)
  (define resources (package-resources tgz))
  (define profiles                                   ; url -> SD (constraint profiles on a resource)
    (for/hash ([r (in-list resources)]
               #:when (and (equal? (rtype (cdr r)) "StructureDefinition")
                           (equal? (hash-ref (cdr r) 'derivation #f) "constraint")
                           (equal? (hash-ref (cdr r) 'kind #f) "resource")))
      (values (hash-ref (cdr r) 'url) (cdr r))))
  (define counts (make-hasheq))
  (define skipped 0)
  (define findings '())
  (for* ([ex (in-list resources)]
         #:when (let ([t (rtype (cdr ex))])
                  (and t (not (member t '("StructureDefinition" "SearchParameter" "ValueSet"
                                          "CodeSystem" "CapabilityStatement" "OperationDefinition"
                                          "ImplementationGuide" "ConceptMap")))
                       (type-registered? (string->symbol t))))
         [purl (in-list (map canonical-url (profiles-of (cdr ex))))]
         #:when (hash-ref profiles purl #f))
    (define node-r (from-json (cdr ex) #:lenient? #t))
    (when (ok? node-r)
      (define node (ok-value node-r))
      (for ([c (in-list (profile-constraints (hash-ref profiles purl)))])
        (match-define (list key expr id path severity) c)
        (define ast (parse-cached expr))
        (define (record! o detail)
          (hash-update! counts o add1 0)
          (unless (eq? o 'pass)
            (set! findings (cons (finding purl key id (car ex) o detail) findings))))
        (cond
          [(regexp-match? #rx":" id) (set! skipped (add1 skipped))]
          [(exn? ast) (record! 'error (format "parse: ~a" (exn-message ast)))]
          [else
           (define rel (element-path->expression path))
           (define foci
             (if (string=? rel "")
                 (list node)
                 (with-handlers ([exn:fail? (lambda (_) '())])
                   (eval-fhirpath (parse-cached rel) (list node) #:strict? #f))))
           (for ([f (in-list foci)])
             (define-values (o detail) (eval-on ast (list f) node))
             (record! (if (and (eq? o 'fail) (not (equal? severity "error"))) 'warn o) detail))]))))
  (ig-fhirpath-report counts skipped (reverse findings)))

;; ---- search parameters -------------------------------------------------------------------------

(define (check-ig-search-params tgz)
  (define resources (package-resources tgz))
  (define sps (filter (lambda (r) (equal? (rtype (cdr r)) "SearchParameter")) resources))
  (define examples
    (for/list ([r (in-list resources)]
               #:when (let ([t (rtype (cdr r))]) (and t (type-registered? (string->symbol t)))))
      (define nr (from-json (cdr r) #:lenient? #t))
      (list (car r) (rtype (cdr r)) (and (ok? nr) (ok-value nr)))))
  (define counts (make-hasheq))
  (define findings '())
  (define (record! o sp ex detail)
    (hash-update! counts o add1 0)
    (when (memq o '(fail error))
      (set! findings (cons (finding (hash-ref sp 'url "?") (hash-ref sp 'code "?") "" ex o detail)
                           findings))))
  (for ([r (in-list sps)])
    (define sp (cdr r))
    (define expr (jstr (hash-ref sp 'expression #f)))
    (define bases (let ([b (hash-ref sp 'base '())]) (if (list? b) b '())))
    (cond
      [(not expr) (void)]                                ; composite/special params may lack one
      [else
       (define ast (parse-cached expr))
       (cond
         [(exn? ast) (record! 'error sp "(parse)" (exn-message ast))]
         [else
          (record! 'pass sp "(parse)" "")
          (for ([ex (in-list examples)] #:when (and (member (cadr ex) bases) (caddr ex)))
            (define o
              (with-handlers ([exn:fail? (lambda (e) (record! 'error sp (car ex) (exn-message e)) #f)])
                (eval-fhirpath ast (list (caddr ex)) #:strict? #f
                               #:externals (hash "resource" (list (caddr ex))))
                'pass))
            (when o (record! 'pass sp (car ex) "")))])]))
  (ig-fhirpath-report counts 0 (reverse findings)))

;; summarize : report -> (listof (cons label count))
(define (summarize r)
  (define c (ig-fhirpath-report-counts r))
  (list (cons "pass" (hash-ref c 'pass 0)) (cons "empty" (hash-ref c 'empty 0))
        (cons "warn" (hash-ref c 'warn 0)) (cons "fail" (hash-ref c 'fail 0)) (cons "error" (hash-ref c 'error 0))
        (cons "skipped" (ig-fhirpath-report-skipped r))))
