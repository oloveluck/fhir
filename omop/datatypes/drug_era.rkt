#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide drug_era)
(define-syntax (drug_era stx)
  (build-fhir-form stx 'drug_era
    '(#s(field-spec drug_era_id 1 1 #(prim "code") #f)
      #s(field-spec person_id 1 1 #(prim "integer") #f)
      #s(field-spec drug_concept_id 1 1 #(prim "code") #f)
      #s(field-spec drug_era_start_date 1 1 #(prim "date") #f)
      #s(field-spec drug_era_end_date 1 1 #(prim "date") #f)
      #s(field-spec drug_exposure_count 0 1 #(prim "integer") #f)
      #s(field-spec gap_days 0 1 #(prim "integer") #f)
      )
    #:parent 'Base))
