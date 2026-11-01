#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'condition_era (fhir-spec 'condition_era "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era" 'type)
  #:schema (type-schema 'condition_era #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era"
             (list
    (schema-field 'condition_era_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_era_id" #f)
    (schema-field 'person_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.person_id" #f)
    (schema-field 'condition_concept_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_concept_id" #f)
    (schema-field 'condition_era_start_date 1 1 (vector 'prim "date") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_era_start_date" #f)
    (schema-field 'condition_era_end_date 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_era_end_date" #f)
    (schema-field 'condition_occurrence_count 0 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_occurrence_count" #f)
             ) #f #f))
(register-element! "condition_era.condition_era_id" (fhir-spec (string->symbol "condition_era.condition_era_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_era_id" 'element))
(register-element! "condition_era.person_id" (fhir-spec (string->symbol "condition_era.person_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.person_id" 'element))
(register-element! "condition_era.condition_concept_id" (fhir-spec (string->symbol "condition_era.condition_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_concept_id" 'element))
(register-element! "condition_era.condition_era_start_date" (fhir-spec (string->symbol "condition_era.condition_era_start_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_era_start_date" 'element))
(register-element! "condition_era.condition_era_end_date" (fhir-spec (string->symbol "condition_era.condition_era_end_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_era_end_date" 'element))
(register-element! "condition_era.condition_occurrence_count" (fhir-spec (string->symbol "condition_era.condition_occurrence_count") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#condition_era.condition_occurrence_count" 'element))

