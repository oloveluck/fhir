#lang racket/base

;;; example-roundtrip-r5.rkt — round-trip the vendored R5 example corpus + the R5 core package
;;; against the R5 tower. `racket tests/example-roundtrip-r5.rkt` prints a report; run under `raco test`
;;; it asserts every example round-trips.

(require rackunit
         racket/runtime-path
         (only-in fhir/r5/schemas)                       ; register the R5 tower
         (only-in fhir/tests/example-harness run-dir run-package))

(define-runtime-path examples-dir "vendor/fhir-examples/r5")
(define-runtime-path r5-tgz "../spec/hl7.fhir.r5.core.tgz")

(define (report)
  (define-values (ep ef) (run-dir examples-dir))
  (printf "R5 examples : ~a/~a round-trip\n" ep (+ ep (length ef)))
  (for ([f (in-list ef)]) (printf "  FAIL ~a (~a)\n" (car f) (cdr f)))
  (define-values (pp pf) (run-package r5-tgz))
  (printf "R5 core pkg : ~a/~a round-trip\n" pp (+ pp (length pf)))
  (for ([f (in-list (if (> (length pf) 20) (take pf 20) pf))]) (printf "  FAIL ~a (~a)\n" (car f) (cdr f)))
  (values ep ef pp pf))

(module+ main (report))

(module+ test
  (define-values (ep ef pp pf) (report))
  (check-equal? (length ef) 0 "R5 example round-trip failures")
  (check-equal? (length pf) 0 "R5 core-package round-trip failures"))

(require (only-in racket/list take))
