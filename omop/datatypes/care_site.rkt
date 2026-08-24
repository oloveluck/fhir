#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide care_site)
(define-syntax (care_site stx)
  (build-fhir-form stx 'care_site
    '(#s(field-spec care_site_id 1 1 #(prim "integer") #f)
      #s(field-spec care_site_name 0 1 #(prim "string") #f)
      #s(field-spec place_of_service_concept_id 0 1 #(prim "code") #f)
      #s(field-spec location_id 0 1 #(prim "integer") #f)
      #s(field-spec care_site_source_value 0 1 #(prim "string") #f)
      #s(field-spec place_of_service_source_value 0 1 #(prim "string") #f)
      )
    #:parent 'Base))
