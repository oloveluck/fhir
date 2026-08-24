#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Distance (fhir-spec 'Distance "https://build.fhir.org/datatypes.html#Distance" 'type)
  #:schema (type-schema 'Distance #f 'Quantity "https://build.fhir.org/datatypes.html#Distance"
             (list
             ) #f #f))

