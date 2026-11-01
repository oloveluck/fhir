#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'dose_era (fhir-spec 'dose_era "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era" 'type)
  #:schema (type-schema 'dose_era #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era"
             (list
    (schema-field 'dose_era_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.dose_era_id" #f)
    (schema-field 'person_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.person_id" #f)
    (schema-field 'drug_concept_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.drug_concept_id" #f)
    (schema-field 'unit_concept_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.unit_concept_id" #f)
    (schema-field 'dose_value 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.dose_value" #f)
    (schema-field 'dose_era_start_date 1 1 (vector 'prim "date") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.dose_era_start_date" #f)
    (schema-field 'dose_era_end_date 1 1 (vector 'prim "date") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.dose_era_end_date" #f)
             ) #f #f))
(register-element! "dose_era.dose_era_id" (fhir-spec (string->symbol "dose_era.dose_era_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.dose_era_id" 'element))
(register-element! "dose_era.person_id" (fhir-spec (string->symbol "dose_era.person_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.person_id" 'element))
(register-element! "dose_era.drug_concept_id" (fhir-spec (string->symbol "dose_era.drug_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.drug_concept_id" 'element))
(register-element! "dose_era.unit_concept_id" (fhir-spec (string->symbol "dose_era.unit_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.unit_concept_id" 'element))
(register-element! "dose_era.dose_value" (fhir-spec (string->symbol "dose_era.dose_value") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.dose_value" 'element))
(register-element! "dose_era.dose_era_start_date" (fhir-spec (string->symbol "dose_era.dose_era_start_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.dose_era_start_date" 'element))
(register-element! "dose_era.dose_era_end_date" (fhir-spec (string->symbol "dose_era.dose_era_end_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#dose_era.dose_era_end_date" 'element))

