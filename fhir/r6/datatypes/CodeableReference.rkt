#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide CodeableReference)
(define-syntax (CodeableReference stx)
  (build-fhir-form stx 'CodeableReference
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec concept 0 1 #(type CodeableConcept) #f)
      #s(field-spec reference 0 1 #(type Reference) #f)
      )
    #:parent 'DataType))
