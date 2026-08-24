#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide condition_era)
(define-syntax (condition_era stx)
  (build-fhir-form stx 'condition_era
    '(#s(field-spec condition_era_id 1 1 #(prim "code") #f)
      #s(field-spec person_id 1 1 #(prim "integer") #f)
      #s(field-spec condition_concept_id 1 1 #(prim "code") #f)
      #s(field-spec condition_era_start_date 1 1 #(prim "date") #f)
      #s(field-spec condition_era_end_date 1 1 #(prim "code") #f)
      #s(field-spec condition_occurrence_count 0 1 #(prim "integer") #f)
      )
    #:parent 'Base))
