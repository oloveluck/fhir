#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Narrative (fhir-spec 'Narrative "https://build.fhir.org/datatypes.html#Narrative" 'type)
  #:schema (type-schema 'Narrative #f 'DataType "https://build.fhir.org/datatypes.html#Narrative"
             (list
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Narrative.status" #f)
    (schema-field 'div 1 1 (vector 'prim "xhtml") #f "https://build.fhir.org/datatypes.html#Narrative.div" #f)
             ) #f #f))
(register-element! "Narrative.status" (fhir-spec (string->symbol "Narrative.status") "https://build.fhir.org/datatypes.html#Narrative.status" 'element))
(register-element! "Narrative.div" (fhir-spec (string->symbol "Narrative.div") "https://build.fhir.org/datatypes.html#Narrative.div" 'element))

