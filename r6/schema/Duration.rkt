#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Duration (fhir-spec 'Duration "https://build.fhir.org/datatypes.html#Duration" 'type)
  #:schema (type-schema 'Duration #f 'Quantity "https://build.fhir.org/datatypes.html#Duration"
             (list
             ) #f #f))

