#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Signature)
(define-syntax (Signature stx)
  (build-fhir-form stx 'Signature
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec type 0 * #(type Coding) #f)
      #s(field-spec when 0 1 #(prim "instant") #f)
      #s(field-spec who 0 1 #(type Reference) #f)
      #s(field-spec onBehalfOf 0 1 #(type Reference) #f)
      #s(field-spec targetFormat 0 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/mimetypes"))
      #s(field-spec sigFormat 0 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/mimetypes"))
      #s(field-spec data 0 1 #(prim "base64Binary") #f)
      )
    #:parent 'DataType))
