#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide ProductShelfLife)
(define-syntax (ProductShelfLife stx)
  (build-fhir-form stx 'ProductShelfLife
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec modifierExtension 0 * #(type Extension) #f)
      #s(field-spec type 0 1 #(type CodeableConcept) #f)
      #s(field-spec specialPrecautionsForStorage 0 * #(type CodeableConcept) #f)
      #s(field-spec periodDuration 0 1 #(type Duration) #f)
      #s(field-spec periodString 0 1 #(prim "string") #f)
      #s(choice-group 0 1 (periodDuration periodString))
      )
    #:parent 'BackboneType))
