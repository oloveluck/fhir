#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide MonetaryComponent)
(define-syntax (MonetaryComponent stx)
  (build-fhir-form stx 'MonetaryComponent
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec type 1 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/price-component-type"))
      #s(field-spec code 0 1 #(type CodeableConcept) #f)
      #s(field-spec factor 0 1 #(prim "decimal") #f)
      #s(field-spec amount 0 1 #(type Money) #f)
      )
    #:parent 'DataType))
