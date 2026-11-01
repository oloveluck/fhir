#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Contributor (fhir-spec 'Contributor "https://hl7.org/fhir/R4/datatypes.html#Contributor" 'type)
  #:schema (type-schema 'Contributor #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Contributor"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/datatypes.html#Contributor.type" #f)
    (schema-field 'name 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#Contributor.name" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactDetail) #f "https://hl7.org/fhir/R4/datatypes.html#Contributor.contact" #f)
             ) #f #f))
(register-element! "Contributor.type" (fhir-spec (string->symbol "Contributor.type") "https://hl7.org/fhir/R4/datatypes.html#Contributor.type" 'element))
(register-element! "Contributor.name" (fhir-spec (string->symbol "Contributor.name") "https://hl7.org/fhir/R4/datatypes.html#Contributor.name" 'element))
(register-element! "Contributor.contact" (fhir-spec (string->symbol "Contributor.contact") "https://hl7.org/fhir/R4/datatypes.html#Contributor.contact" 'element))

