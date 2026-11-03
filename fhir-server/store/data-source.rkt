#lang racket/base

;;; data-source.rkt — the store as a fhir/data-source: what operations read when the server runs them
;;; (and what `raco fhir-server evaluate-measure` reads).
;;;
;;; store->data-source : store [#:search-params catalog] -> data-source
;;;   all / read   : the stored resources
;;;   of-patient   : per type, through its patient / subject / beneficiary search parameter; a full
;;;                  scan matched by reference when the type has none
;;;   search       : FHIR search over the store's indexes (fhir-engine)

(require racket/contract
         fhir/data-source
         "fhir-sqlite.rkt" "fhir-engine.rkt")

(provide (contract-out [store->data-source (->* (fhir-store?) (#:search-params hash?) data-source?)]))

(define (store->data-source store #:search-params [sps default-search-params])
  (define (all type) (fhir-search store type '() #:search-params sps))
  (define (read type id) (fhir-read store type id))
  (define (of-patient type pid)
    (define ref (string-append "Patient/" pid))
    (cond
      [(equal? type "Patient") (let ([p (read "Patient" pid)]) (if p (list p) '()))]
      [else
       (or (for/or ([param (in-list '("patient" "subject" "beneficiary"))])
             (define-values (rs ignored) (fhir-search/ignored store type (list (cons param ref)) #:search-params sps))
             (and (not (member param ignored)) rs))
           (filter (lambda (r) (member ref (patient-reference-of r))) (all type)))]))
  (data-source all read of-patient
               (lambda (type params) (fhir-search store type params #:search-params sps))))
