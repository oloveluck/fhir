#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Quantity (fhir-spec 'Quantity "https://hl7.org/fhir/R5/datatypes.html#Quantity" 'type)
  #:schema (type-schema 'Quantity #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#Quantity"
             (list
    (schema-field 'value 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/datatypes.html#Quantity.value" #f)
    (schema-field 'comparator 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Quantity.comparator" #f)
    (schema-field 'unit 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Quantity.unit" #f)
    (schema-field 'system 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/datatypes.html#Quantity.system" #f)
    (schema-field 'code 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Quantity.code" #f)
             ) #f #f))
(register-element! "Quantity.value" (fhir-spec (string->symbol "Quantity.value") "https://hl7.org/fhir/R5/datatypes.html#Quantity.value" 'element))
(register-element! "Quantity.comparator" (fhir-spec (string->symbol "Quantity.comparator") "https://hl7.org/fhir/R5/datatypes.html#Quantity.comparator" 'element))
(register-element! "Quantity.unit" (fhir-spec (string->symbol "Quantity.unit") "https://hl7.org/fhir/R5/datatypes.html#Quantity.unit" 'element))
(register-element! "Quantity.system" (fhir-spec (string->symbol "Quantity.system") "https://hl7.org/fhir/R5/datatypes.html#Quantity.system" 'element))
(register-element! "Quantity.code" (fhir-spec (string->symbol "Quantity.code") "https://hl7.org/fhir/R5/datatypes.html#Quantity.code" 'element))

