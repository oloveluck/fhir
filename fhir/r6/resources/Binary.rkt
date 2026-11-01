#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Binary)
(define-syntax (Binary stx)
  (build-fhir-form stx 'Binary
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec meta 0 1 #(type Meta) #f)
      #s(field-spec implicitRules 0 1 #(raw) #f)
      #s(field-spec language 0 1 #(raw) #f)
      #s(field-spec contentType 1 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/mimetypes"))
      #s(field-spec securityContext 0 1 #(type Reference) #f)
      #s(field-spec data 0 1 #(prim "base64Binary") #f)
      )
    #:parent 'Resource))
