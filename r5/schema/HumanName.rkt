#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'HumanName (fhir-spec 'HumanName "https://hl7.org/fhir/R5/datatypes.html#HumanName" 'type)
  #:schema (type-schema 'HumanName #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#HumanName"
             (list
    (schema-field 'use 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#HumanName.use" #f)
    (schema-field 'text 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#HumanName.text" #f)
    (schema-field 'family 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#HumanName.family" #f)
    (schema-field 'given 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#HumanName.given" #f)
    (schema-field 'prefix 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#HumanName.prefix" #f)
    (schema-field 'suffix 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#HumanName.suffix" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/datatypes.html#HumanName.period" #f)
             ) #f #f))
(register-element! "HumanName.use" (fhir-spec (string->symbol "HumanName.use") "https://hl7.org/fhir/R5/datatypes.html#HumanName.use" 'element))
(register-element! "HumanName.text" (fhir-spec (string->symbol "HumanName.text") "https://hl7.org/fhir/R5/datatypes.html#HumanName.text" 'element))
(register-element! "HumanName.family" (fhir-spec (string->symbol "HumanName.family") "https://hl7.org/fhir/R5/datatypes.html#HumanName.family" 'element))
(register-element! "HumanName.given" (fhir-spec (string->symbol "HumanName.given") "https://hl7.org/fhir/R5/datatypes.html#HumanName.given" 'element))
(register-element! "HumanName.prefix" (fhir-spec (string->symbol "HumanName.prefix") "https://hl7.org/fhir/R5/datatypes.html#HumanName.prefix" 'element))
(register-element! "HumanName.suffix" (fhir-spec (string->symbol "HumanName.suffix") "https://hl7.org/fhir/R5/datatypes.html#HumanName.suffix" 'element))
(register-element! "HumanName.period" (fhir-spec (string->symbol "HumanName.period") "https://hl7.org/fhir/R5/datatypes.html#HumanName.period" 'element))

