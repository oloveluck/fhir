#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Duration (fhir-spec 'Duration "https://hl7.org/fhir/R4/datatypes.html#Duration" 'type)
  #:schema (type-schema 'Duration #f 'Quantity "https://hl7.org/fhir/R4/datatypes.html#Duration"
             (list
             ) #f #f))

