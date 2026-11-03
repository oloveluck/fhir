#lang racket/base

;;; measure.rkt — Measure evaluation over the store: cql/measure with the store as the data source
;;; (the evaluation itself — libraries, value sets, populations, the MeasureReport — is cql's).

(require racket/contract
         fhir/data-source
         (prefix-in cql: (only-in cql/measure evaluate-measure))
         "fhir-sqlite.rkt" "fhir-engine.rkt" "data-source.rkt")

(provide
 (contract-out
  [evaluate-measure (->* (fhir-store? hash? string? string?)
                         (#:subject (or/c string? #f) #:search-params hash? #:valuesets procedure?
                          #:offset (or/c exact-integer? #f))
                         hash?)]))

(define (evaluate-measure store measure start end #:subject [subject #f] #:search-params [sps default-search-params]
                          #:valuesets [extra-vs (lambda (u) #f)] #:offset [offset #f])
  (parameterize ([current-data-source (store->data-source store #:search-params sps)])
    (cql:evaluate-measure measure start end #:subject subject #:valuesets extra-vs #:offset offset)))
