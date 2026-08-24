#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ExtendedContactDetail (fhir-spec 'ExtendedContactDetail "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail" 'type)
  #:schema (type-schema 'ExtendedContactDetail #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail"
             (list
    (schema-field 'purpose 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.purpose" #f)
    (schema-field 'name 0 '* (vector 'type 'HumanName) #f "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.telecom" #f)
    (schema-field 'address 0 1 (vector 'type 'Address) #f "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.address" #f)
    (schema-field 'organization 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.organization" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.period" #f)
             ) #f #f))
(register-element! "ExtendedContactDetail.purpose" (fhir-spec (string->symbol "ExtendedContactDetail.purpose") "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.purpose" 'element))
(register-element! "ExtendedContactDetail.name" (fhir-spec (string->symbol "ExtendedContactDetail.name") "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.name" 'element))
(register-element! "ExtendedContactDetail.telecom" (fhir-spec (string->symbol "ExtendedContactDetail.telecom") "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.telecom" 'element))
(register-element! "ExtendedContactDetail.address" (fhir-spec (string->symbol "ExtendedContactDetail.address") "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.address" 'element))
(register-element! "ExtendedContactDetail.organization" (fhir-spec (string->symbol "ExtendedContactDetail.organization") "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.organization" 'element))
(register-element! "ExtendedContactDetail.period" (fhir-spec (string->symbol "ExtendedContactDetail.period") "https://hl7.org/fhir/R5/datatypes.html#ExtendedContactDetail.period" 'element))

