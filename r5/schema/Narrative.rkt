#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Narrative (fhir-spec 'Narrative "https://hl7.org/fhir/R5/datatypes.html#Narrative" 'type)
  #:schema (type-schema 'Narrative #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#Narrative"
             (list
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Narrative.status" #f)
    (schema-field 'div 1 1 (vector 'prim "xhtml") #f "https://hl7.org/fhir/R5/datatypes.html#Narrative.div" #f)
             ) #f #f))
(register-element! "Narrative.status" (fhir-spec (string->symbol "Narrative.status") "https://hl7.org/fhir/R5/datatypes.html#Narrative.status" 'element))
(register-element! "Narrative.div" (fhir-spec (string->symbol "Narrative.div") "https://hl7.org/fhir/R5/datatypes.html#Narrative.div" 'element))

