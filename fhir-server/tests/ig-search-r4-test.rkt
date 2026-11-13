#lang racket/base

;;; ig-search-r4-test.rkt — the search self-retrieval oracle (ig-search-harness.rkt) over US Core
;;; 9.0.0's examples, with the catalog = R4 core SearchParameters overlaid by US Core's: every
;;; example must be found by every indexed parameter of its type, queried with its own values.
;;; RATCHETED: misses stay 0, probes never drop.

(require (only-in fhir/spec-package spec-package-path))
(require rackunit
         (only-in fhir/r4/schemas)
         "ig-search-harness.rkt")

(define r (check-ig-search (spec-package-path "hl7.fhir.us.core.tgz") (spec-package-path "hl7.fhir.r4.core.tgz")))
(printf "  US Core 9.0.0 search oracle: ~a/~a probes found their example\n"
        (ig-search-report-hits r) (ig-search-report-probes r))
(for ([m (in-list (ig-search-report-misses r))]) (eprintf "     MISS ~s\n" m))
(for ([e (in-list (ig-search-report-errors r))]) (eprintf "     EXPRESSION ERROR ~s\n" e))
(check-equal? (ig-search-report-errors r) '() "a search parameter's expression errors on an example")
(check-equal? (ig-search-report-misses r) '())
(check-true (>= (ig-search-report-probes r) 2468) "fewer search probes than the floor")
