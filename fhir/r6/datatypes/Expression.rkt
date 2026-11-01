#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Expression)
(define-syntax (Expression stx)
  (build-fhir-form stx 'Expression
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec description 0 1 #(prim "string") #f)
      #s(field-spec name 0 1 #(prim "code") #f)
      #s(field-spec language 0 1 #(prim "code") #f)
      #s(field-spec expression 0 1 #(prim "string") #f)
      #s(field-spec reference 0 1 #(prim "uri") #f)
      )
    #:parent 'DataType))
