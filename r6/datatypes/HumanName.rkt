#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide HumanName)
(define-syntax (HumanName stx)
  (build-fhir-form stx 'HumanName
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec use 0 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/name-use"))
      #s(field-spec text 0 1 #(prim "string") #f)
      #s(field-spec family 0 1 #(prim "string") #f)
      #s(field-spec given 0 * #(prim "string") #f)
      #s(field-spec prefix 0 * #(prim "string") #f)
      #s(field-spec suffix 0 * #(prim "string") #f)
      #s(field-spec period 0 1 #(type Period) #f)
      )
    #:parent 'DataType))
