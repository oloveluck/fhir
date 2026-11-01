#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ContactDetail (fhir-spec 'ContactDetail "https://build.fhir.org/datatypes.html#ContactDetail" 'type)
  #:schema (type-schema 'ContactDetail #f 'DataType "https://build.fhir.org/datatypes.html#ContactDetail"
             (list
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#ContactDetail.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://build.fhir.org/datatypes.html#ContactDetail.telecom" #f)
             ) #f #f))
(register-element! "ContactDetail.name" (fhir-spec (string->symbol "ContactDetail.name") "https://build.fhir.org/datatypes.html#ContactDetail.name" 'element))
(register-element! "ContactDetail.telecom" (fhir-spec (string->symbol "ContactDetail.telecom") "https://build.fhir.org/datatypes.html#ContactDetail.telecom" 'element))

