#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide MarketingStatus)
(define-syntax (MarketingStatus stx)
  (build-fhir-form stx 'MarketingStatus
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec modifierExtension 0 * #(type Extension) #f)
      #s(field-spec country 0 1 #(type CodeableConcept) #f)
      #s(field-spec jurisdiction 0 1 #(type CodeableConcept) #f)
      #s(field-spec status 1 1 #(type CodeableConcept) #f)
      #s(field-spec dateRange 0 1 #(type Period) #f)
      #s(field-spec restoreDate 0 1 #(prim "dateTime") #f)
      )
    #:parent 'BackboneType))
