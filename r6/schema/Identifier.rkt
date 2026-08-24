#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Identifier (fhir-spec 'Identifier "https://build.fhir.org/datatypes.html#Identifier" 'type)
  #:schema (type-schema 'Identifier #f 'DataType "https://build.fhir.org/datatypes.html#Identifier"
             (list
    (schema-field 'use 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Identifier.use" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/datatypes.html#Identifier.type" #f)
    (schema-field 'system 0 1 (vector 'prim "uri") #f "https://build.fhir.org/datatypes.html#Identifier.system" #f)
    (schema-field 'value 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Identifier.value" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/datatypes.html#Identifier.period" #f)
    (schema-field 'assigner 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/datatypes.html#Identifier.assigner" #f)
             ) #f #f))
(register-element! "Identifier.use" (fhir-spec (string->symbol "Identifier.use") "https://build.fhir.org/datatypes.html#Identifier.use" 'element))
(register-element! "Identifier.type" (fhir-spec (string->symbol "Identifier.type") "https://build.fhir.org/datatypes.html#Identifier.type" 'element))
(register-element! "Identifier.system" (fhir-spec (string->symbol "Identifier.system") "https://build.fhir.org/datatypes.html#Identifier.system" 'element))
(register-element! "Identifier.value" (fhir-spec (string->symbol "Identifier.value") "https://build.fhir.org/datatypes.html#Identifier.value" 'element))
(register-element! "Identifier.period" (fhir-spec (string->symbol "Identifier.period") "https://build.fhir.org/datatypes.html#Identifier.period" 'element))
(register-element! "Identifier.assigner" (fhir-spec (string->symbol "Identifier.assigner") "https://build.fhir.org/datatypes.html#Identifier.assigner" 'element))

