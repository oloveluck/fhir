#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Count (fhir-spec 'Count "https://hl7.org/fhir/R5/datatypes.html#Count" 'type)
  #:schema (type-schema 'Count #f 'Quantity "https://hl7.org/fhir/R5/datatypes.html#Count"
             (list
             ) #f #f))

