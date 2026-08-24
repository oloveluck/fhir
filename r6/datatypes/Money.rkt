#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Money)
(define-syntax (Money stx)
  (build-fhir-form stx 'Money
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec value 0 1 #(prim "decimal") #f)
      #s(field-spec currency 0 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/currencies"))
      )
    #:parent 'DataType))
