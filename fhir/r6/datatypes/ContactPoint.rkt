#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide ContactPoint)
(define-syntax (ContactPoint stx)
  (build-fhir-form stx 'ContactPoint
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec system 0 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/contact-point-system"))
      #s(field-spec value 0 1 #(prim "string") #f)
      #s(field-spec use 0 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/contact-point-use"))
      #s(field-spec rank 0 1 #(prim "positiveInt") #f)
      #s(field-spec period 0 1 #(type Period) #f)
      )
    #:parent 'DataType))
