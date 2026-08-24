#lang racket/base

;;; node.rkt — the canonical in-memory FHIR value: a single generic typed node.
;;;
;;; The pivotal design decision (see the plan): rather than stroma's "JSON jsexpr is the only
;;; value" or a per-type struct explosion, every FHIR value is ONE generic tagged record:
;;;
;;;   (struct fhir (type fields))   type   : symbol       — the FHIR type name (e.g. 'Patient)
;;;                                 fields : hasheq        — name(symbol) -> value | (listof value)
;;;
;;; A leaf value is a primitive newtype instance (fhir-date, fhir-string, …) or a raw string (for
;;; base `id`/`language`-style fields); a nested value is another `fhir` node. So every value
;;; carries its FHIR type tag — exactly what FHIRPath/CQL type operators (is/as/ofType), choice
;;; discrimination, and polymorphic navigation will need — while jsexpr becomes a *derived* view
;;; produced by the schema-driven serializer (serialize/to-json.rkt).

(require racket/contract)

(provide (struct-out fhir)
         (contract-out
          [fhir-ref     (->* (fhir? symbol?) (any/c) any/c)]     ; a field value (or default)
          [fhir-has?    (-> fhir? symbol? boolean?)]
          [fhir-field-names (-> fhir? (listof symbol?))]))

;; type   : symbol   the FHIR type name
;; fields : hasheq   present fields only (absent fields are simply not keys), each value either a
;;                   single value or a (listof value) for list-cardinality fields.
(struct fhir (type fields) #:transparent)

(define (fhir-ref n name [default #f])
  (hash-ref (fhir-fields n) name default))

(define (fhir-has? n name)
  (hash-has-key? (fhir-fields n) name))

(define (fhir-field-names n)
  (hash-keys (fhir-fields n)))

(module+ test
  (require rackunit)
  (define n (fhir 'HumanName (hasheq 'family "Chalmers" 'given '("Eve" "A"))))
  (check-equal? (fhir-type n) 'HumanName)
  (check-equal? (fhir-ref n 'family) "Chalmers")
  (check-equal? (fhir-ref n 'given) '("Eve" "A"))
  (check-equal? (fhir-ref n 'use 'none) 'none)
  (check-true   (fhir-has? n 'family))
  (check-false  (fhir-has? n 'use)))
