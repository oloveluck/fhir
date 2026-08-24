#lang racket/base

;;; example-roundtrip-r4.rkt — round-trip the vendored R4 example corpus + the R4 core package against
;;; the R4 tower. (A separate process from R5 so the two towers don't double-register.)

(require rackunit
         racket/runtime-path
         racket/list
         (only-in fhir/r4/schemas)                       ; register the R4 tower
         (only-in fhir/tests/example-harness run-dir run-package))

(define-runtime-path examples-dir "vendor/fhir-examples/r4")
(define-runtime-path r4-tgz "../spec/hl7.fhir.r4.core.tgz")

(define (report)
  (define-values (ep ef) (run-dir examples-dir))
  (printf "R4 examples : ~a/~a round-trip\n" ep (+ ep (length ef)))
  (for ([f (in-list ef)]) (printf "  FAIL ~a (~a)\n" (car f) (cdr f)))
  (define-values (pp pf) (run-package r4-tgz))
  (printf "R4 core pkg : ~a/~a round-trip\n" pp (+ pp (length pf)))
  (for ([f (in-list (if (> (length pf) 20) (take pf 20) pf))]) (printf "  FAIL ~a (~a)\n" (car f) (cdr f)))
  (values ep ef pp pf))

(module+ main (report))

(module+ test
  (define-values (ep ef pp pf) (report))
  (check-equal? (length ef) 0 "R4 example round-trip failures")
  (check-equal? (length pf) 0 "R4 core-package round-trip failures"))
