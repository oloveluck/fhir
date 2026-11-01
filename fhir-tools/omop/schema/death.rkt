#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'death (fhir-spec 'death "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death" 'type)
  #:schema (type-schema 'death #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death"
             (list
    (schema-field 'person_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.person_id" #f)
    (schema-field 'death_date 1 1 (vector 'prim "date") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.death_date" #f)
    (schema-field 'death_datetime 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.death_datetime" #f)
    (schema-field 'death_type_concept_id 0 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.death_type_concept_id" #f)
    (schema-field 'cause_concept_id 0 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.cause_concept_id" #f)
    (schema-field 'cause_source_value 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.cause_source_value" #f)
    (schema-field 'cause_source_concept_id 0 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.cause_source_concept_id" #f)
             ) #f #f))
(register-element! "death.person_id" (fhir-spec (string->symbol "death.person_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.person_id" 'element))
(register-element! "death.death_date" (fhir-spec (string->symbol "death.death_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.death_date" 'element))
(register-element! "death.death_datetime" (fhir-spec (string->symbol "death.death_datetime") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.death_datetime" 'element))
(register-element! "death.death_type_concept_id" (fhir-spec (string->symbol "death.death_type_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.death_type_concept_id" 'element))
(register-element! "death.cause_concept_id" (fhir-spec (string->symbol "death.cause_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.cause_concept_id" 'element))
(register-element! "death.cause_source_value" (fhir-spec (string->symbol "death.cause_source_value") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.cause_source_value" 'element))
(register-element! "death.cause_source_concept_id" (fhir-spec (string->symbol "death.cause_source_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#death.cause_source_concept_id" 'element))

