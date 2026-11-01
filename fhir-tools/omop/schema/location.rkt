#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'location (fhir-spec 'location "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location" 'type)
  #:schema (type-schema 'location #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location"
             (list
    (schema-field 'location_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.location_id" #f)
    (schema-field 'address_1 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.address_1" #f)
    (schema-field 'address_2 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.address_2" #f)
    (schema-field 'city 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.city" #f)
    (schema-field 'state 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.state" #f)
    (schema-field 'zip 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.zip" #f)
    (schema-field 'county 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.county" #f)
    (schema-field 'location_source_value 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.location_source_value" #f)
    (schema-field 'country_concept_id 0 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.country_concept_id" #f)
    (schema-field 'country_source_value 0 1 (vector 'prim "string") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.country_source_value" #f)
    (schema-field 'latitude 0 1 (vector 'prim "decimal") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.latitude" #f)
    (schema-field 'longitude 0 1 (vector 'prim "decimal") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.longitude" #f)
             ) #f #f))
(register-element! "location.location_id" (fhir-spec (string->symbol "location.location_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.location_id" 'element))
(register-element! "location.address_1" (fhir-spec (string->symbol "location.address_1") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.address_1" 'element))
(register-element! "location.address_2" (fhir-spec (string->symbol "location.address_2") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.address_2" 'element))
(register-element! "location.city" (fhir-spec (string->symbol "location.city") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.city" 'element))
(register-element! "location.state" (fhir-spec (string->symbol "location.state") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.state" 'element))
(register-element! "location.zip" (fhir-spec (string->symbol "location.zip") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.zip" 'element))
(register-element! "location.county" (fhir-spec (string->symbol "location.county") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.county" 'element))
(register-element! "location.location_source_value" (fhir-spec (string->symbol "location.location_source_value") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.location_source_value" 'element))
(register-element! "location.country_concept_id" (fhir-spec (string->symbol "location.country_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.country_concept_id" 'element))
(register-element! "location.country_source_value" (fhir-spec (string->symbol "location.country_source_value") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.country_source_value" 'element))
(register-element! "location.latitude" (fhir-spec (string->symbol "location.latitude") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.latitude" 'element))
(register-element! "location.longitude" (fhir-spec (string->symbol "location.longitude") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#location.longitude" 'element))

