#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Basic (fhir-spec 'Basic "https://build.fhir.org/basic.html#Basic" 'type)
  #:schema (type-schema 'Basic #f 'DomainResource "https://build.fhir.org/basic.html#Basic"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/basic.html#Basic.identifier" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/basic.html#Basic.code" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/basic.html#Basic.subject" #f)
    (schema-field 'created 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/basic.html#Basic.created" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/basic.html#Basic.author" #f)
             ) #f #f))
(register-element! "Basic.identifier" (fhir-spec (string->symbol "Basic.identifier") "https://build.fhir.org/basic.html#Basic.identifier" 'element))
(register-element! "Basic.code" (fhir-spec (string->symbol "Basic.code") "https://build.fhir.org/basic.html#Basic.code" 'element))
(register-element! "Basic.subject" (fhir-spec (string->symbol "Basic.subject") "https://build.fhir.org/basic.html#Basic.subject" 'element))
(register-element! "Basic.created" (fhir-spec (string->symbol "Basic.created") "https://build.fhir.org/basic.html#Basic.created" 'element))
(register-element! "Basic.author" (fhir-spec (string->symbol "Basic.author") "https://build.fhir.org/basic.html#Basic.author" 'element))

