#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Age (fhir-spec 'Age "https://hl7.org/fhir/R4/datatypes.html#Age" 'type)
  #:schema (type-schema 'Age #f 'Quantity "https://hl7.org/fhir/R4/datatypes.html#Age"
             (list
             ) #f #f))

