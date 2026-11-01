#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Period)
(define-syntax (Period stx)
  (build-fhir-form stx 'Period
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec start 0 1 #(prim "dateTime") #f)
      #s(field-spec end 0 1 #(prim "dateTime") #f)
      )
    #:parent 'DataType))
