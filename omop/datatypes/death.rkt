#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide death)
(define-syntax (death stx)
  (build-fhir-form stx 'death
    '(#s(field-spec person_id 1 1 #(prim "integer") #f)
      #s(field-spec death_date 1 1 #(prim "date") #f)
      #s(field-spec death_datetime 0 1 #(prim "dateTime") #f)
      #s(field-spec death_type_concept_id 0 1 #(prim "code") #f)
      #s(field-spec cause_concept_id 0 1 #(prim "code") #f)
      #s(field-spec cause_source_value 0 1 #(prim "string") #f)
      #s(field-spec cause_source_concept_id 0 1 #(prim "code") #f)
      )
    #:parent 'Base))
