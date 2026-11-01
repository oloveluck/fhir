#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Count (fhir-spec 'Count "https://build.fhir.org/datatypes.html#Count" 'type)
  #:schema (type-schema 'Count #f 'Quantity "https://build.fhir.org/datatypes.html#Count"
             (list
             ) #f #f))

