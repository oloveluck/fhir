#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide episode_event)
(define-syntax (episode_event stx)
  (build-fhir-form stx 'episode_event
    '(#s(field-spec episode_id 1 1 #(prim "integer") #f)
      #s(field-spec event_id 1 1 #(prim "code") #f)
      #s(field-spec episode_event_field_concept_id 1 1 #(prim "code") #f)
      )
    #:parent 'Base))
