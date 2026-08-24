#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'observation_period (fhir-spec 'observation_period "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period" 'type)
  #:schema (type-schema 'observation_period #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period"
             (list
    (schema-field 'observation_period_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.observation_period_id" #f)
    (schema-field 'person_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.person_id" #f)
    (schema-field 'observation_period_start_date 1 1 (vector 'prim "date") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.observation_period_start_date" #f)
    (schema-field 'observation_period_end_date 1 1 (vector 'prim "date") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.observation_period_end_date" #f)
    (schema-field 'period_type_concept_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.period_type_concept_id" #f)
             ) #f #f))
(register-element! "observation_period.observation_period_id" (fhir-spec (string->symbol "observation_period.observation_period_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.observation_period_id" 'element))
(register-element! "observation_period.person_id" (fhir-spec (string->symbol "observation_period.person_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.person_id" 'element))
(register-element! "observation_period.observation_period_start_date" (fhir-spec (string->symbol "observation_period.observation_period_start_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.observation_period_start_date" 'element))
(register-element! "observation_period.observation_period_end_date" (fhir-spec (string->symbol "observation_period.observation_period_end_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.observation_period_end_date" 'element))
(register-element! "observation_period.period_type_concept_id" (fhir-spec (string->symbol "observation_period.period_type_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#observation_period.period_type_concept_id" 'element))

