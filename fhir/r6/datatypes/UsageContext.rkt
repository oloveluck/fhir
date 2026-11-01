#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide UsageContext)
(define-syntax (UsageContext stx)
  (build-fhir-form stx 'UsageContext
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec code 1 1 #(type Coding) #f)
      #s(field-spec valueCodeableConcept 0 1 #(type CodeableConcept) #f)
      #s(field-spec valueQuantity 0 1 #(type Quantity) #f)
      #s(field-spec valueRange 0 1 #(type Range) #f)
      #s(field-spec valueReference 0 1 #(type Reference) #f)
      #s(choice-group 1 1 (valueCodeableConcept valueQuantity valueRange valueReference))
      )
    #:parent 'DataType))
