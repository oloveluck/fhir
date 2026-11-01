#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'drug_era (fhir-spec 'drug_era "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era" 'type)
  #:schema (type-schema 'drug_era #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era"
             (list
    (schema-field 'drug_era_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_era_id" #f)
    (schema-field 'person_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.person_id" #f)
    (schema-field 'drug_concept_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_concept_id" #f)
    (schema-field 'drug_era_start_date 1 1 (vector 'prim "date") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_era_start_date" #f)
    (schema-field 'drug_era_end_date 1 1 (vector 'prim "date") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_era_end_date" #f)
    (schema-field 'drug_exposure_count 0 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_exposure_count" #f)
    (schema-field 'gap_days 0 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.gap_days" #f)
             ) #f #f))
(register-element! "drug_era.drug_era_id" (fhir-spec (string->symbol "drug_era.drug_era_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_era_id" 'element))
(register-element! "drug_era.person_id" (fhir-spec (string->symbol "drug_era.person_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.person_id" 'element))
(register-element! "drug_era.drug_concept_id" (fhir-spec (string->symbol "drug_era.drug_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_concept_id" 'element))
(register-element! "drug_era.drug_era_start_date" (fhir-spec (string->symbol "drug_era.drug_era_start_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_era_start_date" 'element))
(register-element! "drug_era.drug_era_end_date" (fhir-spec (string->symbol "drug_era.drug_era_end_date") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_era_end_date" 'element))
(register-element! "drug_era.drug_exposure_count" (fhir-spec (string->symbol "drug_era.drug_exposure_count") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.drug_exposure_count" 'element))
(register-element! "drug_era.gap_days" (fhir-spec (string->symbol "drug_era.gap_days") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#drug_era.gap_days" 'element))

