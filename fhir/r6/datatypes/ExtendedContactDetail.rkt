#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide ExtendedContactDetail)
(define-syntax (ExtendedContactDetail stx)
  (build-fhir-form stx 'ExtendedContactDetail
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec purpose 0 1 #(type CodeableConcept) #f)
      #s(field-spec name 0 * #(type HumanName) #f)
      #s(field-spec telecom 0 * #(type ContactPoint) #f)
      #s(field-spec address 0 1 #(type Address) #f)
      #s(field-spec organization 0 1 #(type Reference) #f)
      #s(field-spec period 0 1 #(type Period) #f)
      )
    #:parent 'DataType))
