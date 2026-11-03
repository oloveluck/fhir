#lang racket/base

;;; ig-fhirpath-r4-test.rkt — the R4 IGs (US Core 9.0.0, IPS 2.0.1) as a FHIRPath corpus
;;; (see ig-fhirpath-harness.rkt): every error-severity invariant of every profile holds on every
;;; example claiming it, and every SearchParameter expression parses and evaluates.
;;;
;;; RATCHETED — floors only rise. The 2 allowed invariant errors are a documented SPEC CONFLICT, not
;;; an engine bug: core FHIR's dom-3 calls `descendants().as(canonical)` on a multi-item collection,
;;; which the FHIRPath spec (and its TCK, testFHIRPathAsFunction21) defines as an execution error;
;;; the Java validator is lenient there. Keeping the engine spec-conformant is the deliberate choice.
;;; Constraints on sliced elements are skipped (slice discrimination is out of this harness's scope).

(require (only-in fhir/spec-package spec-package-path))
(require rackunit
         (only-in fhir/r4/schemas)                        ; both IGs are FHIR 4.0.1
         "ig-fhirpath-harness.rkt")

(define (count r o) (cdr (assoc o (summarize r))))

(define (check-ig! label tgz #:invariant-pass floor-pass #:invariant-errors max-errors
                   #:search-pass search-floor)
  (define inv (check-ig-invariants tgz))
  (define sp (check-ig-search-params tgz))
  (printf "  ~a invariants ~a\n  ~a search    ~a\n" label (summarize inv) label (summarize sp))
  (for ([f (in-list (ig-fhirpath-report-findings inv))] #:when (memq (finding-outcome f) '(fail error)))
    (eprintf "     ~a ~a @ ~a: ~a ~a\n" (finding-key f) (finding-example f) (finding-element f)
             (finding-outcome f) (finding-detail f)))
  (check-equal? (count inv "fail") 0 (format "~a: an error-severity invariant failed on a published example" label))
  (check-true (<= (count inv "error") max-errors) (format "~a: invariant evaluation errors rose" label))
  (check-true (>= (count inv "pass") floor-pass) (format "~a: invariant passes fell" label))
  (check-equal? (count sp "error") 0 (format "~a: a SearchParameter expression failed" label))
  (check-true (>= (count sp "pass") search-floor) (format "~a: search-parameter passes fell" label)))

(check-ig! "US Core 9.0.0" (spec-package-path "hl7.fhir.us.core.tgz")
           #:invariant-pass 4925 #:invariant-errors 2 #:search-pass 1330)
(check-ig! "IPS 2.0.1" (spec-package-path "hl7.fhir.uv.ips.tgz")
           #:invariant-pass 1157 #:invariant-errors 0 #:search-pass 0)
