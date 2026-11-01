#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Reference)
(define-syntax (Reference stx)
  (build-fhir-form stx 'Reference
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec reference 0 1 #(prim "string") #f)
      #s(field-spec type 0 1 #(prim "uri") #f)
      #s(field-spec identifier 0 1 #(type Identifier) #f)
      #s(field-spec display 0 1 #(prim "string") #f)
      )
    #:parent 'DataType))
