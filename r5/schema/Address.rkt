#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Address (fhir-spec 'Address "https://hl7.org/fhir/R5/datatypes.html#Address" 'type)
  #:schema (type-schema 'Address #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#Address"
             (list
    (schema-field 'use 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Address.use" #f)
    (schema-field 'type 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Address.type" #f)
    (schema-field 'text 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Address.text" #f)
    (schema-field 'line 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Address.line" #f)
    (schema-field 'city 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Address.city" #f)
    (schema-field 'district 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Address.district" #f)
    (schema-field 'state 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Address.state" #f)
    (schema-field 'postalCode 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Address.postalCode" #f)
    (schema-field 'country 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Address.country" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/datatypes.html#Address.period" #f)
             ) #f #f))
(register-element! "Address.use" (fhir-spec (string->symbol "Address.use") "https://hl7.org/fhir/R5/datatypes.html#Address.use" 'element))
(register-element! "Address.type" (fhir-spec (string->symbol "Address.type") "https://hl7.org/fhir/R5/datatypes.html#Address.type" 'element))
(register-element! "Address.text" (fhir-spec (string->symbol "Address.text") "https://hl7.org/fhir/R5/datatypes.html#Address.text" 'element))
(register-element! "Address.line" (fhir-spec (string->symbol "Address.line") "https://hl7.org/fhir/R5/datatypes.html#Address.line" 'element))
(register-element! "Address.city" (fhir-spec (string->symbol "Address.city") "https://hl7.org/fhir/R5/datatypes.html#Address.city" 'element))
(register-element! "Address.district" (fhir-spec (string->symbol "Address.district") "https://hl7.org/fhir/R5/datatypes.html#Address.district" 'element))
(register-element! "Address.state" (fhir-spec (string->symbol "Address.state") "https://hl7.org/fhir/R5/datatypes.html#Address.state" 'element))
(register-element! "Address.postalCode" (fhir-spec (string->symbol "Address.postalCode") "https://hl7.org/fhir/R5/datatypes.html#Address.postalCode" 'element))
(register-element! "Address.country" (fhir-spec (string->symbol "Address.country") "https://hl7.org/fhir/R5/datatypes.html#Address.country" 'element))
(register-element! "Address.period" (fhir-spec (string->symbol "Address.period") "https://hl7.org/fhir/R5/datatypes.html#Address.period" 'element))

