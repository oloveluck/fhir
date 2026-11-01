#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide observation_period)
(define-syntax (observation_period stx)
  (build-fhir-form stx 'observation_period
    '(#s(field-spec observation_period_id 1 1 #(prim "integer") #f)
      #s(field-spec person_id 1 1 #(prim "integer") #f)
      #s(field-spec observation_period_start_date 1 1 #(prim "date") #f)
      #s(field-spec observation_period_end_date 1 1 #(prim "date") #f)
      #s(field-spec period_type_concept_id 1 1 #(prim "code") #f)
      )
    #:parent 'Base))
