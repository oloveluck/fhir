#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'fact_relationship (fhir-spec 'fact_relationship "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship" 'type)
  #:schema (type-schema 'fact_relationship #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship"
             (list
    (schema-field 'domain_concept_id_1 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.domain_concept_id_1" #f)
    (schema-field 'fact_id_1 1 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.fact_id_1" #f)
    (schema-field 'domain_concept_id_2 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.domain_concept_id_2" #f)
    (schema-field 'fact_id_2 1 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.fact_id_2" #f)
    (schema-field 'relationship_concept_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.relationship_concept_id" #f)
             ) #f #f))
(register-element! "fact_relationship.domain_concept_id_1" (fhir-spec (string->symbol "fact_relationship.domain_concept_id_1") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.domain_concept_id_1" 'element))
(register-element! "fact_relationship.fact_id_1" (fhir-spec (string->symbol "fact_relationship.fact_id_1") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.fact_id_1" 'element))
(register-element! "fact_relationship.domain_concept_id_2" (fhir-spec (string->symbol "fact_relationship.domain_concept_id_2") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.domain_concept_id_2" 'element))
(register-element! "fact_relationship.fact_id_2" (fhir-spec (string->symbol "fact_relationship.fact_id_2") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.fact_id_2" 'element))
(register-element! "fact_relationship.relationship_concept_id" (fhir-spec (string->symbol "fact_relationship.relationship_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#fact_relationship.relationship_concept_id" 'element))

