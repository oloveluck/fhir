#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Identifier (fhir-spec 'Identifier "https://hl7.org/fhir/R4/datatypes.html#Identifier" 'type)
  #:schema (type-schema 'Identifier #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Identifier"
             (list
    (schema-field 'use 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/datatypes.html#Identifier.use" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/datatypes.html#Identifier.type" #f)
    (schema-field 'system 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/datatypes.html#Identifier.system" #f)
    (schema-field 'value 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#Identifier.value" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/datatypes.html#Identifier.period" #f)
    (schema-field 'assigner 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/datatypes.html#Identifier.assigner" #f)
             ) #f #f))
(register-element! "Identifier.use" (fhir-spec (string->symbol "Identifier.use") "https://hl7.org/fhir/R4/datatypes.html#Identifier.use" 'element))
(register-element! "Identifier.type" (fhir-spec (string->symbol "Identifier.type") "https://hl7.org/fhir/R4/datatypes.html#Identifier.type" 'element))
(register-element! "Identifier.system" (fhir-spec (string->symbol "Identifier.system") "https://hl7.org/fhir/R4/datatypes.html#Identifier.system" 'element))
(register-element! "Identifier.value" (fhir-spec (string->symbol "Identifier.value") "https://hl7.org/fhir/R4/datatypes.html#Identifier.value" 'element))
(register-element! "Identifier.period" (fhir-spec (string->symbol "Identifier.period") "https://hl7.org/fhir/R4/datatypes.html#Identifier.period" 'element))
(register-element! "Identifier.assigner" (fhir-spec (string->symbol "Identifier.assigner") "https://hl7.org/fhir/R4/datatypes.html#Identifier.assigner" 'element))

