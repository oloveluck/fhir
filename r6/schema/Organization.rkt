#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Organization (fhir-spec 'Organization "https://build.fhir.org/organization.html#Organization" 'type)
  #:schema (type-schema 'Organization #f 'DomainResource "https://build.fhir.org/organization.html#Organization"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/organization.html#Organization.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/organization.html#Organization.active" #f)
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/organization.html#Organization.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://build.fhir.org/organization.html#Organization.name" #f)
    (schema-field 'alias 0 '* (vector 'prim "string") #f "https://build.fhir.org/organization.html#Organization.alias" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://build.fhir.org/organization.html#Organization.description" #f)
    (schema-field 'contact 0 '* (vector 'type 'ExtendedContactDetail) #f "https://build.fhir.org/organization.html#Organization.contact" #f)
    (schema-field 'partOf 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/organization.html#Organization.partOf" #f)
    (schema-field 'endpoint 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/organization.html#Organization.endpoint" #f)
    (schema-field 'qualification 0 '* (vector 'type 'OrganizationQualification) #f "https://build.fhir.org/organization.html#Organization.qualification" #f)
             ) #f #f))
(register-element! "Organization.identifier" (fhir-spec (string->symbol "Organization.identifier") "https://build.fhir.org/organization.html#Organization.identifier" 'element))
(register-element! "Organization.active" (fhir-spec (string->symbol "Organization.active") "https://build.fhir.org/organization.html#Organization.active" 'element))
(register-element! "Organization.type" (fhir-spec (string->symbol "Organization.type") "https://build.fhir.org/organization.html#Organization.type" 'element))
(register-element! "Organization.name" (fhir-spec (string->symbol "Organization.name") "https://build.fhir.org/organization.html#Organization.name" 'element))
(register-element! "Organization.alias" (fhir-spec (string->symbol "Organization.alias") "https://build.fhir.org/organization.html#Organization.alias" 'element))
(register-element! "Organization.description" (fhir-spec (string->symbol "Organization.description") "https://build.fhir.org/organization.html#Organization.description" 'element))
(register-element! "Organization.contact" (fhir-spec (string->symbol "Organization.contact") "https://build.fhir.org/organization.html#Organization.contact" 'element))
(register-element! "Organization.partOf" (fhir-spec (string->symbol "Organization.partOf") "https://build.fhir.org/organization.html#Organization.partOf" 'element))
(register-element! "Organization.endpoint" (fhir-spec (string->symbol "Organization.endpoint") "https://build.fhir.org/organization.html#Organization.endpoint" 'element))
(register-element! "Organization.qualification" (fhir-spec (string->symbol "Organization.qualification") "https://build.fhir.org/organization.html#Organization.qualification" 'element))

(register-type! 'OrganizationQualification (fhir-spec 'OrganizationQualification "https://build.fhir.org/organization.html#Organization.qualification" 'type)
  #:schema (type-schema 'OrganizationQualification #f 'BackboneElement "https://build.fhir.org/organization.html#Organization.qualification"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/organization.html#Organization.qualification.identifier" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/organization.html#Organization.qualification.code" #f)
    (schema-field 'status 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/organization.html#Organization.qualification.status" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/organization.html#Organization.qualification.period" #f)
    (schema-field 'issuer 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/organization.html#Organization.qualification.issuer" #f)
             ) #f #f))
(register-element! "Organization.qualification.identifier" (fhir-spec (string->symbol "Organization.qualification.identifier") "https://build.fhir.org/organization.html#Organization.qualification.identifier" 'element))
(register-element! "Organization.qualification.code" (fhir-spec (string->symbol "Organization.qualification.code") "https://build.fhir.org/organization.html#Organization.qualification.code" 'element))
(register-element! "Organization.qualification.status" (fhir-spec (string->symbol "Organization.qualification.status") "https://build.fhir.org/organization.html#Organization.qualification.status" 'element))
(register-element! "Organization.qualification.period" (fhir-spec (string->symbol "Organization.qualification.period") "https://build.fhir.org/organization.html#Organization.qualification.period" 'element))
(register-element! "Organization.qualification.issuer" (fhir-spec (string->symbol "Organization.qualification.issuer") "https://build.fhir.org/organization.html#Organization.qualification.issuer" 'element))

