#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Period (fhir-spec 'Period "https://build.fhir.org/datatypes.html#Period" 'type)
  #:schema (type-schema 'Period #f 'DataType "https://build.fhir.org/datatypes.html#Period"
             (list
    (schema-field 'start 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/datatypes.html#Period.start" #f)
    (schema-field 'end 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/datatypes.html#Period.end" #f)
             ) #f #f))
(register-element! "Period.start" (fhir-spec (string->symbol "Period.start") "https://build.fhir.org/datatypes.html#Period.start" 'element))
(register-element! "Period.end" (fhir-spec (string->symbol "Period.end") "https://build.fhir.org/datatypes.html#Period.end" 'element))

