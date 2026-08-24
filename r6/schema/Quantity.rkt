#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Quantity (fhir-spec 'Quantity "https://build.fhir.org/datatypes.html#Quantity" 'type)
  #:schema (type-schema 'Quantity #f 'DataType "https://build.fhir.org/datatypes.html#Quantity"
             (list
    (schema-field 'value 0 1 (vector 'prim "decimal") #f "https://build.fhir.org/datatypes.html#Quantity.value" #f)
    (schema-field 'comparator 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Quantity.comparator" #f)
    (schema-field 'unit 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Quantity.unit" #f)
    (schema-field 'system 0 1 (vector 'prim "uri") #f "https://build.fhir.org/datatypes.html#Quantity.system" #f)
    (schema-field 'code 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Quantity.code" #f)
             ) #f #f))
(register-element! "Quantity.value" (fhir-spec (string->symbol "Quantity.value") "https://build.fhir.org/datatypes.html#Quantity.value" 'element))
(register-element! "Quantity.comparator" (fhir-spec (string->symbol "Quantity.comparator") "https://build.fhir.org/datatypes.html#Quantity.comparator" 'element))
(register-element! "Quantity.unit" (fhir-spec (string->symbol "Quantity.unit") "https://build.fhir.org/datatypes.html#Quantity.unit" 'element))
(register-element! "Quantity.system" (fhir-spec (string->symbol "Quantity.system") "https://build.fhir.org/datatypes.html#Quantity.system" 'element))
(register-element! "Quantity.code" (fhir-spec (string->symbol "Quantity.code") "https://build.fhir.org/datatypes.html#Quantity.code" 'element))

