#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Period (fhir-spec 'Period "https://hl7.org/fhir/R4/datatypes.html#Period" 'type)
  #:schema (type-schema 'Period #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Period"
             (list
    (schema-field 'start 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/datatypes.html#Period.start" #f)
    (schema-field 'end 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/datatypes.html#Period.end" #f)
             ) #f #f))
(register-element! "Period.start" (fhir-spec (string->symbol "Period.start") "https://hl7.org/fhir/R4/datatypes.html#Period.start" 'element))
(register-element! "Period.end" (fhir-spec (string->symbol "Period.end") "https://hl7.org/fhir/R4/datatypes.html#Period.end" 'element))

