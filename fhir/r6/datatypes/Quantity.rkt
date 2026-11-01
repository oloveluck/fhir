#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Quantity)
(define-syntax (Quantity stx)
  (build-fhir-form stx 'Quantity
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec value 0 1 #(prim "decimal") #f)
      #s(field-spec comparator 0 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/quantity-comparator"))
      #s(field-spec unit 0 1 #(prim "string") #f)
      #s(field-spec system 0 1 #(prim "uri") #f)
      #s(field-spec code 0 1 #(prim "code") #f)
      )
    #:parent 'DataType))
