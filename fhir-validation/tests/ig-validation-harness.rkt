#lang racket/base

;;; ig-validation-harness.rkt — validate every example an IG ships against the profiles it claims.
;;;
;;; A published IG's examples are, by publication, valid against the profiles named in their
;;; meta.profile. So every ERROR our validator reports on them is a false positive — a validator
;;; bug, an unsupported construct we failed to fail-open on, or (rarely, and then worth recording)
;;; a genuine defect in the IG's own example. This is the never-over-report gate run against
;;; real-world authored content instead of the core spec's examples.
;;;
;;; The caller registers the matching tower (R4 IGs need fhir/r4/schemas). The profiles resolve
;;; through the SD index parameterised with (list ig-package core-package) — IG first, so its
;;; profiles shadow nothing in core but are found before it.
;;;
;;; Data definitions
;;;   A Verdict is one of: 'clean | 'errors | 'skipped
;;;     'skipped — the example's type is outside the registered tower, or it claims no profile from
;;;                this IG (it is then only a base-type check, covered elsewhere)
;;;   An IgValidationReport is (ig-validation-report clean dirty skipped issues)
;;;     issues : (listof (list example-name code path message)) — every error issue reported

(require racket/contract racket/list racket/string
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/model/registry type-registered?)
         (only-in "../conformance/validate.rkt" validate-issues issue-severity issue-code issue-path issue-msg)
         (only-in "ig-fhirpath-harness.rkt" package-resources))

(provide
 (struct-out ig-validation-report)
 (contract-out
  [check-ig-validation (->* (path-string? path-string?) (#:invariants? boolean?) ig-validation-report?)]
  [issue-histogram (-> ig-validation-report? (listof (cons/c string? exact-nonnegative-integer?)))]))

(struct ig-validation-report (clean dirty skipped issues) #:transparent)

(define (canonical-url u) (car (string-split u "|")))

;; check-ig-validation : ig.tgz core.tgz -> report
(define (check-ig-validation ig-tgz core-tgz #:invariants? [inv? #t])
  (define resources (package-resources ig-tgz))
  (define ig-profiles
    (for/hash ([r (in-list resources)]
               #:when (and (equal? (hash-ref (cdr r) 'resourceType #f) "StructureDefinition")
                           (equal? (hash-ref (cdr r) 'derivation #f) "constraint")))
      (values (hash-ref (cdr r) 'url) #t)))
  (define (claims-ig-profile? js)
    (define m (hash-ref js 'meta #f))
    (define ps (and (hash? m) (hash-ref m 'profile '())))
    (and (list? ps) (for/or ([p (in-list ps)]) (and (string? p) (hash-ref ig-profiles (canonical-url p) #f)))))
  (parameterize ([current-sd-packages (list ig-tgz core-tgz)])
    (for/fold ([clean 0] [dirty 0] [skipped 0] [issues '()]
               #:result (ig-validation-report clean dirty skipped (reverse issues)))
              ([r (in-list resources)])
      (define js (cdr r))
      (define rt (hash-ref js 'resourceType #f))
      (cond
        [(or (not (string? rt)) (not (type-registered? (string->symbol rt))) (not (claims-ig-profile? js)))
         (values clean dirty (add1 skipped) issues)]
        [else
         (define errs (filter (lambda (i) (member (issue-severity i) '("error" "fatal")))
                              (validate-issues js #:invariants? inv?)))
         (if (null? errs)
             (values (add1 clean) dirty skipped issues)
             (values clean (add1 dirty) skipped
                     (append (reverse (for/list ([i (in-list errs)])
                                        (list (car r) (issue-code i) (issue-path i) (issue-msg i))))
                             issues)))]))))

;; issue-histogram : report -> (listof (cons "code: message-shape" count)), most frequent first
(define (issue-histogram rep)
  (define h (make-hash))
  (for ([i (in-list (ig-validation-report-issues rep))])
    ;; message shape: digits and quoted values collapsed so the same defect groups together
    (define shape (regexp-replace* #px"'[^']*'|\"[^\"]*\"|[0-9]+" (or (list-ref i 3) "") "_"))
    (hash-update! h (format "~a: ~a" (list-ref i 1) shape) add1 0))
  (sort (hash->list h) > #:key cdr))
