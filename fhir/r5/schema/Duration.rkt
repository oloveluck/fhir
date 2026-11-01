#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Duration (fhir-spec 'Duration "https://hl7.org/fhir/R5/datatypes.html#Duration" 'type)
  #:schema (type-schema 'Duration #f 'Quantity "https://hl7.org/fhir/R5/datatypes.html#Duration"
             (list
             ) #f #f))

