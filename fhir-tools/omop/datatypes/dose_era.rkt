#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide dose_era)
(define-syntax (dose_era stx)
  (build-fhir-form stx 'dose_era
    '(#s(field-spec dose_era_id 1 1 #(prim "code") #f)
      #s(field-spec person_id 1 1 #(prim "integer") #f)
      #s(field-spec drug_concept_id 1 1 #(prim "code") #f)
      #s(field-spec unit_concept_id 1 1 #(prim "code") #f)
      #s(field-spec dose_value 1 1 #(prim "integer") #f)
      #s(field-spec dose_era_start_date 1 1 #(prim "date") #f)
      #s(field-spec dose_era_end_date 1 1 #(prim "date") #f)
      )
    #:parent 'Base))
