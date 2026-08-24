#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ContactPoint (fhir-spec 'ContactPoint "https://hl7.org/fhir/R5/datatypes.html#ContactPoint" 'type)
  #:schema (type-schema 'ContactPoint #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#ContactPoint"
             (list
    (schema-field 'system 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.system" #f)
    (schema-field 'value 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.value" #f)
    (schema-field 'use 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.use" #f)
    (schema-field 'rank 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.rank" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.period" #f)
             ) #f #f))
(register-element! "ContactPoint.system" (fhir-spec (string->symbol "ContactPoint.system") "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.system" 'element))
(register-element! "ContactPoint.value" (fhir-spec (string->symbol "ContactPoint.value") "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.value" 'element))
(register-element! "ContactPoint.use" (fhir-spec (string->symbol "ContactPoint.use") "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.use" 'element))
(register-element! "ContactPoint.rank" (fhir-spec (string->symbol "ContactPoint.rank") "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.rank" 'element))
(register-element! "ContactPoint.period" (fhir-spec (string->symbol "ContactPoint.period") "https://hl7.org/fhir/R5/datatypes.html#ContactPoint.period" 'element))

