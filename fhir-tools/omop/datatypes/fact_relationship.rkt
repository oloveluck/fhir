#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide fact_relationship)
(define-syntax (fact_relationship stx)
  (build-fhir-form stx 'fact_relationship
    '(#s(field-spec domain_concept_id_1 1 1 #(prim "code") #f)
      #s(field-spec fact_id_1 1 1 #(prim "string") #f)
      #s(field-spec domain_concept_id_2 1 1 #(prim "code") #f)
      #s(field-spec fact_id_2 1 1 #(prim "string") #f)
      #s(field-spec relationship_concept_id 1 1 #(prim "code") #f)
      )
    #:parent 'Base))
