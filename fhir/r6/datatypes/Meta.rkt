#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Meta)
(define-syntax (Meta stx)
  (build-fhir-form stx 'Meta
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec versionId 0 1 #(prim "id") #f)
      #s(field-spec lastUpdated 0 1 #(prim "instant") #f)
      #s(field-spec source 0 1 #(prim "uri") #f)
      #s(field-spec profile 0 * #(prim "canonical") #f)
      #s(field-spec security 0 * #(type Coding) #f)
      #s(field-spec tag 0 * #(type Coding) #f)
      )
    #:parent 'DataType))
