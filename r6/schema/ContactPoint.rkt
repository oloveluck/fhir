#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ContactPoint (fhir-spec 'ContactPoint "https://build.fhir.org/datatypes.html#ContactPoint" 'type)
  #:schema (type-schema 'ContactPoint #f 'DataType "https://build.fhir.org/datatypes.html#ContactPoint"
             (list
    (schema-field 'system 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#ContactPoint.system" #f)
    (schema-field 'value 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#ContactPoint.value" #f)
    (schema-field 'use 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#ContactPoint.use" #f)
    (schema-field 'rank 0 1 (vector 'prim "positiveInt") #f "https://build.fhir.org/datatypes.html#ContactPoint.rank" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/datatypes.html#ContactPoint.period" #f)
             ) #f #f))
(register-element! "ContactPoint.system" (fhir-spec (string->symbol "ContactPoint.system") "https://build.fhir.org/datatypes.html#ContactPoint.system" 'element))
(register-element! "ContactPoint.value" (fhir-spec (string->symbol "ContactPoint.value") "https://build.fhir.org/datatypes.html#ContactPoint.value" 'element))
(register-element! "ContactPoint.use" (fhir-spec (string->symbol "ContactPoint.use") "https://build.fhir.org/datatypes.html#ContactPoint.use" 'element))
(register-element! "ContactPoint.rank" (fhir-spec (string->symbol "ContactPoint.rank") "https://build.fhir.org/datatypes.html#ContactPoint.rank" 'element))
(register-element! "ContactPoint.period" (fhir-spec (string->symbol "ContactPoint.period") "https://build.fhir.org/datatypes.html#ContactPoint.period" 'element))

