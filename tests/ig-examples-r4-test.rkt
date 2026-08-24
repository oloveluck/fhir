#lang racket/base

;;; ig-examples-r4-test.rkt — every example shipped by the vendored R4 IGs (US Core, IPS) must
;;; parse and round-trip. These are hundreds of REAL-WORLD authored resources — a much harsher
;;; corpus than the spec's own examples, and the reason to vendor whole IG packages.
;;;
;;; R4 in its own process (an R4 and an R5/R6 tower cannot both be registered — the type registry
;;; is keyed by symbol, so the second would shadow the first).

(require rackunit racket/runtime-path racket/list
         (only-in fhir/r4/schemas)                        ; the R4 tower (both IGs are 4.0.1)
         (only-in "ig-example-harness.rkt"
                  check-ig-examples ig-report-total ig-report-parsed ig-report-round-tripped
                  ig-report-skipped ig-report-failures))

(define-runtime-path us-core "../spec/hl7.fhir.us.core.tgz")
(define-runtime-path ips "../spec/hl7.fhir.uv.ips.tgz")

(define (report! label tgz #:min-parsed min-parsed)
  (define r (check-ig-examples tgz))
  (printf "  ~a: ~a/~a parsed, ~a round-tripped~a\n" label
          (ig-report-parsed r) (ig-report-total r) (ig-report-round-tripped r)
          (if (> (ig-report-skipped r) 0) (format ", ~a skipped" (ig-report-skipped r)) ""))
  (for ([f (in-list (take (ig-report-failures r) (min 8 (length (ig-report-failures r)))))])
    (eprintf "     ~a: ~a\n" (car f) (cdr f)))
  ;; RATCHETED: every example that parses must also round-trip, and the parsed count never drops
  (check-equal? (ig-report-round-tripped r) (ig-report-parsed r)
                (format "~a: a parsed example failed to round-trip" label))
  (check-true (>= (ig-report-parsed r) min-parsed)
              (format "~a: parsed ~a, floor ~a" label (ig-report-parsed r) min-parsed))
  r)

(report! "US Core" us-core #:min-parsed 224)
(report! "IPS" ips #:min-parsed 44)
