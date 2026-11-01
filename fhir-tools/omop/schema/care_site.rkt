#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'care_site (fhir-spec 'care_site "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site" 'type)
  #:schema (type-schema 'care_site #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site"
             (list
    (schema-field 'care_site_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.care_site_id" #f)
    (schema-field 'care_site_name 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.care_site_name" #f)
    (schema-field 'place_of_service_concept_id 0 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.place_of_service_concept_id" #f)
    (schema-field 'location_id 0 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.location_id" #f)
    (schema-field 'care_site_source_value 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.care_site_source_value" #f)
    (schema-field 'place_of_service_source_value 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.place_of_service_source_value" #f)
             ) #f #f))
(register-element! "care_site.care_site_id" (fhir-spec (string->symbol "care_site.care_site_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.care_site_id" 'element))
(register-element! "care_site.care_site_name" (fhir-spec (string->symbol "care_site.care_site_name") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.care_site_name" 'element))
(register-element! "care_site.place_of_service_concept_id" (fhir-spec (string->symbol "care_site.place_of_service_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.place_of_service_concept_id" 'element))
(register-element! "care_site.location_id" (fhir-spec (string->symbol "care_site.location_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.location_id" 'element))
(register-element! "care_site.care_site_source_value" (fhir-spec (string->symbol "care_site.care_site_source_value") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.care_site_source_value" 'element))
(register-element! "care_site.place_of_service_source_value" (fhir-spec (string->symbol "care_site.place_of_service_source_value") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#care_site.place_of_service_source_value" 'element))

