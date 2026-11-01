#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'HumanName (fhir-spec 'HumanName "https://build.fhir.org/datatypes.html#HumanName" 'type)
  #:schema (type-schema 'HumanName #f 'DataType "https://build.fhir.org/datatypes.html#HumanName"
             (list
    (schema-field 'use 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#HumanName.use" #f)
    (schema-field 'text 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#HumanName.text" #f)
    (schema-field 'family 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#HumanName.family" #f)
    (schema-field 'given 0 '* (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#HumanName.given" #f)
    (schema-field 'prefix 0 '* (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#HumanName.prefix" #f)
    (schema-field 'suffix 0 '* (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#HumanName.suffix" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/datatypes.html#HumanName.period" #f)
             ) #f #f))
(register-element! "HumanName.use" (fhir-spec (string->symbol "HumanName.use") "https://build.fhir.org/datatypes.html#HumanName.use" 'element))
(register-element! "HumanName.text" (fhir-spec (string->symbol "HumanName.text") "https://build.fhir.org/datatypes.html#HumanName.text" 'element))
(register-element! "HumanName.family" (fhir-spec (string->symbol "HumanName.family") "https://build.fhir.org/datatypes.html#HumanName.family" 'element))
(register-element! "HumanName.given" (fhir-spec (string->symbol "HumanName.given") "https://build.fhir.org/datatypes.html#HumanName.given" 'element))
(register-element! "HumanName.prefix" (fhir-spec (string->symbol "HumanName.prefix") "https://build.fhir.org/datatypes.html#HumanName.prefix" 'element))
(register-element! "HumanName.suffix" (fhir-spec (string->symbol "HumanName.suffix") "https://build.fhir.org/datatypes.html#HumanName.suffix" 'element))
(register-element! "HumanName.period" (fhir-spec (string->symbol "HumanName.period") "https://build.fhir.org/datatypes.html#HumanName.period" 'element))

