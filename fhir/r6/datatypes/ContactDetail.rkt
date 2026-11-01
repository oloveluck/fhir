#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide ContactDetail)
(define-syntax (ContactDetail stx)
  (build-fhir-form stx 'ContactDetail
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec name 0 1 #(prim "string") #f)
      #s(field-spec telecom 0 * #(type ContactPoint) #f)
      )
    #:parent 'DataType))
