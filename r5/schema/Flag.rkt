#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Flag (fhir-spec 'Flag "https://hl7.org/fhir/R5/flag.html#Flag" 'type)
  #:schema (type-schema 'Flag #f 'DomainResource "https://hl7.org/fhir/R5/flag.html#Flag"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/flag.html#Flag.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/flag.html#Flag.status" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/flag.html#Flag.category" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/flag.html#Flag.code" #f)
    (schema-field 'subject 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/flag.html#Flag.subject" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/flag.html#Flag.period" #f)
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/flag.html#Flag.encounter" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/flag.html#Flag.author" #f)
             ) #f #f))
(register-element! "Flag.identifier" (fhir-spec (string->symbol "Flag.identifier") "https://hl7.org/fhir/R5/flag.html#Flag.identifier" 'element))
(register-element! "Flag.status" (fhir-spec (string->symbol "Flag.status") "https://hl7.org/fhir/R5/flag.html#Flag.status" 'element))
(register-element! "Flag.category" (fhir-spec (string->symbol "Flag.category") "https://hl7.org/fhir/R5/flag.html#Flag.category" 'element))
(register-element! "Flag.code" (fhir-spec (string->symbol "Flag.code") "https://hl7.org/fhir/R5/flag.html#Flag.code" 'element))
(register-element! "Flag.subject" (fhir-spec (string->symbol "Flag.subject") "https://hl7.org/fhir/R5/flag.html#Flag.subject" 'element))
(register-element! "Flag.period" (fhir-spec (string->symbol "Flag.period") "https://hl7.org/fhir/R5/flag.html#Flag.period" 'element))
(register-element! "Flag.encounter" (fhir-spec (string->symbol "Flag.encounter") "https://hl7.org/fhir/R5/flag.html#Flag.encounter" 'element))
(register-element! "Flag.author" (fhir-spec (string->symbol "Flag.author") "https://hl7.org/fhir/R5/flag.html#Flag.author" 'element))

