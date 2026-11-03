#lang racket/base

;;; interaction-codes.rkt — the R6 code sets a capability declaration is validated against.
;;;
;;; These stand in for the FHIR ValueSets `restful-interaction` and `search-param-type`. We hardcode
;;; the R6 code lists rather than depend on a ValueSet-expansion engine at compile time; this is the
;;; single maintenance point if the R6 codes change. Shared by declare.rkt (compile-time validation)
;;; and available at runtime.

(require racket/contract)

(provide
 (contract-out
  [type-interaction?   (-> symbol? boolean?)]     ; a [type]/instance-level restful interaction
  [system-interaction? (-> symbol? boolean?)]     ; a system-level restful interaction
  [restful-interaction? (-> symbol? boolean?)]    ; either of the above
  [search-param-type?  (-> symbol? boolean?)]     ; a SearchParameter.type code
  [type-level-interactions   (listof symbol?)]
  [system-level-interactions (listof symbol?)]
  [search-param-types        (listof symbol?)]))

;; CapabilityStatement.rest.resource.interaction.code (type/instance level)
(define type-level-interactions
  '(read vread update patch delete history-instance history-type create search-type))

;; CapabilityStatement.rest.interaction.code (system level)
(define system-level-interactions
  '(transaction batch search-system history-system))

;; SearchParameter.type
(define search-param-types
  '(number date string token reference composite quantity uri special))

(define (type-interaction? s)   (and (memq s type-level-interactions) #t))
(define (system-interaction? s) (and (memq s system-level-interactions) #t))
(define (restful-interaction? s) (or (type-interaction? s) (system-interaction? s)))
(define (search-param-type? s)  (and (memq s search-param-types) #t))

(module+ test
  (require rackunit)
  (check-true  (type-interaction? 'read))
  (check-true  (type-interaction? 'search-type))
  (check-false (type-interaction? 'transaction))
  (check-true  (system-interaction? 'batch))
  (check-true  (search-param-type? 'token))
  (check-false (search-param-type? 'frobnicate)))
