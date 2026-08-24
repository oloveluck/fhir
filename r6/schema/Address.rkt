#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Address (fhir-spec 'Address "https://build.fhir.org/datatypes.html#Address" 'type)
  #:schema (type-schema 'Address #f 'DataType "https://build.fhir.org/datatypes.html#Address"
             (list
    (schema-field 'use 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Address.use" #f)
    (schema-field 'type 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Address.type" #f)
    (schema-field 'text 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Address.text" #f)
    (schema-field 'line 0 '* (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Address.line" #f)
    (schema-field 'city 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Address.city" #f)
    (schema-field 'district 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Address.district" #f)
    (schema-field 'state 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Address.state" #f)
    (schema-field 'postalCode 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Address.postalCode" #f)
    (schema-field 'country 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Address.country" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/datatypes.html#Address.period" #f)
             ) #f #f))
(register-element! "Address.use" (fhir-spec (string->symbol "Address.use") "https://build.fhir.org/datatypes.html#Address.use" 'element))
(register-element! "Address.type" (fhir-spec (string->symbol "Address.type") "https://build.fhir.org/datatypes.html#Address.type" 'element))
(register-element! "Address.text" (fhir-spec (string->symbol "Address.text") "https://build.fhir.org/datatypes.html#Address.text" 'element))
(register-element! "Address.line" (fhir-spec (string->symbol "Address.line") "https://build.fhir.org/datatypes.html#Address.line" 'element))
(register-element! "Address.city" (fhir-spec (string->symbol "Address.city") "https://build.fhir.org/datatypes.html#Address.city" 'element))
(register-element! "Address.district" (fhir-spec (string->symbol "Address.district") "https://build.fhir.org/datatypes.html#Address.district" 'element))
(register-element! "Address.state" (fhir-spec (string->symbol "Address.state") "https://build.fhir.org/datatypes.html#Address.state" 'element))
(register-element! "Address.postalCode" (fhir-spec (string->symbol "Address.postalCode") "https://build.fhir.org/datatypes.html#Address.postalCode" 'element))
(register-element! "Address.country" (fhir-spec (string->symbol "Address.country") "https://build.fhir.org/datatypes.html#Address.country" 'element))
(register-element! "Address.period" (fhir-spec (string->symbol "Address.period") "https://build.fhir.org/datatypes.html#Address.period" 'element))

