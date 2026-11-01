#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide RelativeTime)
(define-syntax (RelativeTime stx)
  (build-fhir-form stx 'RelativeTime
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec modifierExtension 0 * #(type Extension) #f)
      #s(field-spec contextReference 0 1 #(type Reference) #f)
      #s(field-spec contextDefinition 0 1 #(prim "canonical") #f)
      #s(field-spec contextPath 0 1 #(prim "string") #f)
      #s(field-spec contextCode 0 1 #(type CodeableConcept) #f)
      #s(field-spec text 0 1 #(prim "string") #f)
      #s(field-spec offsetDuration 0 1 #(type Duration) #f)
      #s(field-spec offsetRange 0 1 #(type Range) #f)
      #s(choice-group 0 1 (offsetDuration offsetRange))
      )
    #:parent 'BackboneType))
