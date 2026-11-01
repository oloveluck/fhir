#lang racket/base

;;; ig-validation-r4-test.rkt — the never-over-report gate on real IGs: every US Core 9.0.0 and IPS
;;; 2.0.1 example that claims one of its IG's profiles must validate with ZERO errors against it
;;; (see ig-validation-harness.rkt). Profiles resolve through the SD index over
;;; (list ig-package r4-core). RATCHETED: dirty stays 0, clean never drops.

(require (only-in fhir/spec-package spec-package-path))
(require rackunit
         (only-in fhir/r4/schemas)
         "ig-validation-harness.rkt")

(define core (spec-package-path "hl7.fhir.r4.core.tgz"))

(define (check-ig! label tgz #:clean floor)
  (define r (check-ig-validation tgz core))
  (printf "  ~a: ~a clean, ~a with errors, ~a skipped (no profile from this IG / type outside R4)\n"
          label (ig-validation-report-clean r) (ig-validation-report-dirty r) (ig-validation-report-skipped r))
  (for ([i (in-list (ig-validation-report-issues r))]) (eprintf "     ~a\n" i))
  (check-equal? (ig-validation-report-dirty r) 0 (format "~a: a published example failed validation" label))
  (check-true (>= (ig-validation-report-clean r) floor) (format "~a: fewer examples validated" label)))

(check-ig! "US Core 9.0.0" (spec-package-path "hl7.fhir.us.core.tgz") #:clean 216)
(check-ig! "IPS 2.0.1" (spec-package-path "hl7.fhir.uv.ips.tgz") #:clean 44)
