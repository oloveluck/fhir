#lang racket/base

;;; A search parameter's expression is evaluated one `|` branch at a time. R6's own `date`
;;; carries a branch written for another type without naming it (`(start | requestedPeriod.start)
;;; .first()`, Appointment's); evaluated whole, that branch failed on an Observation and nothing
;;; was indexed, so a server declaring `[date date]` on Observation answered every date search
;;; with nothing.

(require rackunit json
         (only-in fhir/r6/types)
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/store/fhir-engine index-rows/text search-param-name search-param-kind search-param-path)
         (only-in fhir/store/ig-params search-params-from-package))

(define core (spec-package-path "hl7.fhir.r6.core.tgz" #:optional? #t))
(when core
  (define date (findf (lambda (sp) (equal? (search-param-name sp) "date"))
                      (hash-ref (search-params-from-package core) 'Observation)))
  (check-regexp-match #rx"requestedPeriod" (search-param-path date) "the unrooted branch is in the expression")
  (define observation
    (hasheq 'resourceType "Observation" 'id "o1" 'status "final"
            'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "4548-4")))
            'effectiveDateTime "2024-03-01T10:00:00Z"))
  (define rows (index-rows/text (list (jsexpr->string observation)
                                      (list (list "date" (search-param-kind date) (search-param-path date))))))
  (check-equal? (length rows) 1)
  (check-equal? (car (car rows)) "date"))
