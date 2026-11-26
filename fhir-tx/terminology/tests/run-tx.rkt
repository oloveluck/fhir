#lang racket/base

;;; run-tx.rkt — `raco fhir-tx --tck`: the official terminology-service suite, ratcheted.

(require (only-in fhir/r5/schemas)                       ; result nodes build against R5
         (only-in "tx-harness.rkt" run-tx-suite tx-results-pass tx-results-fail
                  tx-results-skip tx-results-failures tx-results-skips)
         racket/list)

;; NEVER LOWER. Raise as $expand/$validate-code gain capability.
(define floor-pass 600)

(module+ main
  (define verbose? (and (member "-v" (vector->list (current-command-line-arguments))) #t))
  (define r (run-tx-suite))
  (when verbose?
    (for ([f (in-list (tx-results-failures r))]) (eprintf "  ~a\n" f))
    ;; why each skipped test is skipped, the commonest reason first
    (define by-reason (group-by (lambda (s) (car (regexp-match #rx"^[^:]*" s))) (tx-results-skips r)))
    (for ([g (in-list (sort by-reason > #:key length))])
      (eprintf "  skipped ~a: ~a\n" (length g) (car (regexp-match #rx"^[^:]*" (car g))))))
  (define pass (tx-results-pass r))
  (define total (+ pass (tx-results-fail r)))
  (printf "terminology conformance: ~a/~a  (skipped ~a: suites for content not here, such as SNOMED CT,\n"
          pass total (tx-results-skip r))
  (printf "  LOINC and OMOP; candidate operations; -v says why each)\n")
  (when (< pass floor-pass)
    (eprintf "REGRESSION: ~a < floor ~a\n" pass floor-pass)
    (exit 1)))
