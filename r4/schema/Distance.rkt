#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Distance (fhir-spec 'Distance "https://hl7.org/fhir/R4/datatypes.html#Distance" 'type)
  #:schema (type-schema 'Distance #f 'Quantity "https://hl7.org/fhir/R4/datatypes.html#Distance"
             (list
             ) #f #f))

