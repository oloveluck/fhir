#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Substance (fhir-spec 'Substance "https://build.fhir.org/substance.html#Substance" 'type)
  #:schema (type-schema 'Substance #f 'DomainResource "https://build.fhir.org/substance.html#Substance"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/substance.html#Substance.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://build.fhir.org/substance.html#Substance.status" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/substance.html#Substance.category" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/substance.html#Substance.code" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://build.fhir.org/substance.html#Substance.description" #f)
    (schema-field 'expiry 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/substance.html#Substance.expiry" #f)
    (schema-field 'quantity 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/substance.html#Substance.quantity" #f)
             ) #f #f))
(register-element! "Substance.identifier" (fhir-spec (string->symbol "Substance.identifier") "https://build.fhir.org/substance.html#Substance.identifier" 'element))
(register-element! "Substance.status" (fhir-spec (string->symbol "Substance.status") "https://build.fhir.org/substance.html#Substance.status" 'element))
(register-element! "Substance.category" (fhir-spec (string->symbol "Substance.category") "https://build.fhir.org/substance.html#Substance.category" 'element))
(register-element! "Substance.code" (fhir-spec (string->symbol "Substance.code") "https://build.fhir.org/substance.html#Substance.code" 'element))
(register-element! "Substance.description" (fhir-spec (string->symbol "Substance.description") "https://build.fhir.org/substance.html#Substance.description" 'element))
(register-element! "Substance.expiry" (fhir-spec (string->symbol "Substance.expiry") "https://build.fhir.org/substance.html#Substance.expiry" 'element))
(register-element! "Substance.quantity" (fhir-spec (string->symbol "Substance.quantity") "https://build.fhir.org/substance.html#Substance.quantity" 'element))

