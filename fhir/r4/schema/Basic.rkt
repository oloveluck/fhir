#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Basic (fhir-spec 'Basic "https://hl7.org/fhir/R4/basic.html#Basic" 'type)
  #:schema (type-schema 'Basic #f 'DomainResource "https://hl7.org/fhir/R4/basic.html#Basic"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/basic.html#Basic.identifier" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/basic.html#Basic.code" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/basic.html#Basic.subject" #f)
    (schema-field 'created 0 1 (vector 'prim "date") #f "https://hl7.org/fhir/R4/basic.html#Basic.created" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/basic.html#Basic.author" #f)
             ) #f #f))
(register-element! "Basic.identifier" (fhir-spec (string->symbol "Basic.identifier") "https://hl7.org/fhir/R4/basic.html#Basic.identifier" 'element))
(register-element! "Basic.code" (fhir-spec (string->symbol "Basic.code") "https://hl7.org/fhir/R4/basic.html#Basic.code" 'element))
(register-element! "Basic.subject" (fhir-spec (string->symbol "Basic.subject") "https://hl7.org/fhir/R4/basic.html#Basic.subject" 'element))
(register-element! "Basic.created" (fhir-spec (string->symbol "Basic.created") "https://hl7.org/fhir/R4/basic.html#Basic.created" 'element))
(register-element! "Basic.author" (fhir-spec (string->symbol "Basic.author") "https://hl7.org/fhir/R4/basic.html#Basic.author" 'element))

