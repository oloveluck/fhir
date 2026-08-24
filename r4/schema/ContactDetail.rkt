#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ContactDetail (fhir-spec 'ContactDetail "https://hl7.org/fhir/R4/datatypes.html#ContactDetail" 'type)
  #:schema (type-schema 'ContactDetail #f 'Element "https://hl7.org/fhir/R4/datatypes.html#ContactDetail"
             (list
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#ContactDetail.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/datatypes.html#ContactDetail.telecom" #f)
             ) #f #f))
(register-element! "ContactDetail.name" (fhir-spec (string->symbol "ContactDetail.name") "https://hl7.org/fhir/R4/datatypes.html#ContactDetail.name" 'element))
(register-element! "ContactDetail.telecom" (fhir-spec (string->symbol "ContactDetail.telecom") "https://hl7.org/fhir/R4/datatypes.html#ContactDetail.telecom" 'element))

