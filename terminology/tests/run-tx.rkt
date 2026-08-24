#lang racket/base

;;; run-tx.rkt — `raco fhir tx-tck`: the official terminology-service suite, ratcheted.

(require (only-in fhir/r5/schemas)                       ; result nodes build against R5
         (only-in "tx-harness.rkt" run-tx-suite tx-results-pass tx-results-fail
                  tx-results-skip tx-results-failures))

;; NEVER LOWER. Raise as $expand/$validate-code gain capability.
(define floor-pass 463)

(module+ main
  (define verbose? (and (member "-v" (vector->list (current-command-line-arguments))) #t))
  (define r (run-tx-suite))
  (when verbose? (for ([f (in-list (tx-results-failures r))]) (eprintf "  ~a\n" f)))
  (define pass (tx-results-pass r))
  (define total (+ pass (tx-results-fail r)))
  (printf "terminology conformance: ~a/~a  (skipped ~a — external terminologies, unimplemented\n"
          pass total (tx-results-skip r))
  (printf "  operations (lookup/translate/compare/cs-validate-code) and expansion parameters\n")
  (printf "  (offset/count/filter/displayLanguage) we do not implement)\n")
  (when (< pass floor-pass)
    (eprintf "REGRESSION: ~a < floor ~a\n" pass floor-pass)
    (exit 1)))
