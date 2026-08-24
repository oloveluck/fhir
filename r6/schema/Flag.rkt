#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Flag (fhir-spec 'Flag "https://build.fhir.org/flag.html#Flag" 'type)
  #:schema (type-schema 'Flag #f 'DomainResource "https://build.fhir.org/flag.html#Flag"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/flag.html#Flag.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://build.fhir.org/flag.html#Flag.status" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/flag.html#Flag.category" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/flag.html#Flag.code" #f)
    (schema-field 'subject 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/flag.html#Flag.subject" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/flag.html#Flag.period" #f)
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/flag.html#Flag.encounter" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/flag.html#Flag.author" #f)
    (schema-field 'supportingInfo 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/flag.html#Flag.supportingInfo" #f)
             ) #f #f))
(register-element! "Flag.identifier" (fhir-spec (string->symbol "Flag.identifier") "https://build.fhir.org/flag.html#Flag.identifier" 'element))
(register-element! "Flag.status" (fhir-spec (string->symbol "Flag.status") "https://build.fhir.org/flag.html#Flag.status" 'element))
(register-element! "Flag.category" (fhir-spec (string->symbol "Flag.category") "https://build.fhir.org/flag.html#Flag.category" 'element))
(register-element! "Flag.code" (fhir-spec (string->symbol "Flag.code") "https://build.fhir.org/flag.html#Flag.code" 'element))
(register-element! "Flag.subject" (fhir-spec (string->symbol "Flag.subject") "https://build.fhir.org/flag.html#Flag.subject" 'element))
(register-element! "Flag.period" (fhir-spec (string->symbol "Flag.period") "https://build.fhir.org/flag.html#Flag.period" 'element))
(register-element! "Flag.encounter" (fhir-spec (string->symbol "Flag.encounter") "https://build.fhir.org/flag.html#Flag.encounter" 'element))
(register-element! "Flag.author" (fhir-spec (string->symbol "Flag.author") "https://build.fhir.org/flag.html#Flag.author" 'element))
(register-element! "Flag.supportingInfo" (fhir-spec (string->symbol "Flag.supportingInfo") "https://build.fhir.org/flag.html#Flag.supportingInfo" 'element))

