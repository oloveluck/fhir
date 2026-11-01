#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Coding)
(define-syntax (Coding stx)
  (build-fhir-form stx 'Coding
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec system 0 1 #(prim "uri") #f)
      #s(field-spec version 0 1 #(prim "string") #f)
      #s(field-spec code 0 1 #(prim "code") #f)
      #s(field-spec display 0 1 #(prim "string") #f)
      #s(field-spec userSelected 0 1 #(prim "boolean") #f)
      )
    #:parent 'DataType))
