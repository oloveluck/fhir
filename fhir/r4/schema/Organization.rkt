#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Organization (fhir-spec 'Organization "https://hl7.org/fhir/R4/organization.html#Organization" 'type)
  #:schema (type-schema 'Organization #f 'DomainResource "https://hl7.org/fhir/R4/organization.html#Organization"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/organization.html#Organization.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/organization.html#Organization.active" #f)
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/organization.html#Organization.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/organization.html#Organization.name" #f)
    (schema-field 'alias 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/organization.html#Organization.alias" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/organization.html#Organization.telecom" #f)
    (schema-field 'address 0 '* (vector 'type 'Address) #f "https://hl7.org/fhir/R4/organization.html#Organization.address" #f)
    (schema-field 'partOf 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/organization.html#Organization.partOf" #f)
    (schema-field 'contact 0 '* (vector 'type 'OrganizationContact) #f "https://hl7.org/fhir/R4/organization.html#Organization.contact" #f)
    (schema-field 'endpoint 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/organization.html#Organization.endpoint" #f)
             ) #f #f))
(register-element! "Organization.identifier" (fhir-spec (string->symbol "Organization.identifier") "https://hl7.org/fhir/R4/organization.html#Organization.identifier" 'element))
(register-element! "Organization.active" (fhir-spec (string->symbol "Organization.active") "https://hl7.org/fhir/R4/organization.html#Organization.active" 'element))
(register-element! "Organization.type" (fhir-spec (string->symbol "Organization.type") "https://hl7.org/fhir/R4/organization.html#Organization.type" 'element))
(register-element! "Organization.name" (fhir-spec (string->symbol "Organization.name") "https://hl7.org/fhir/R4/organization.html#Organization.name" 'element))
(register-element! "Organization.alias" (fhir-spec (string->symbol "Organization.alias") "https://hl7.org/fhir/R4/organization.html#Organization.alias" 'element))
(register-element! "Organization.telecom" (fhir-spec (string->symbol "Organization.telecom") "https://hl7.org/fhir/R4/organization.html#Organization.telecom" 'element))
(register-element! "Organization.address" (fhir-spec (string->symbol "Organization.address") "https://hl7.org/fhir/R4/organization.html#Organization.address" 'element))
(register-element! "Organization.partOf" (fhir-spec (string->symbol "Organization.partOf") "https://hl7.org/fhir/R4/organization.html#Organization.partOf" 'element))
(register-element! "Organization.contact" (fhir-spec (string->symbol "Organization.contact") "https://hl7.org/fhir/R4/organization.html#Organization.contact" 'element))
(register-element! "Organization.endpoint" (fhir-spec (string->symbol "Organization.endpoint") "https://hl7.org/fhir/R4/organization.html#Organization.endpoint" 'element))

(register-type! 'OrganizationContact (fhir-spec 'OrganizationContact "https://hl7.org/fhir/R4/organization.html#Organization.contact" 'type)
  #:schema (type-schema 'OrganizationContact #f 'BackboneElement "https://hl7.org/fhir/R4/organization.html#Organization.contact"
             (list
    (schema-field 'purpose 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/organization.html#Organization.contact.purpose" #f)
    (schema-field 'name 0 1 (vector 'type 'HumanName) #f "https://hl7.org/fhir/R4/organization.html#Organization.contact.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/organization.html#Organization.contact.telecom" #f)
    (schema-field 'address 0 1 (vector 'type 'Address) #f "https://hl7.org/fhir/R4/organization.html#Organization.contact.address" #f)
             ) #f #f))
(register-element! "Organization.contact.purpose" (fhir-spec (string->symbol "Organization.contact.purpose") "https://hl7.org/fhir/R4/organization.html#Organization.contact.purpose" 'element))
(register-element! "Organization.contact.name" (fhir-spec (string->symbol "Organization.contact.name") "https://hl7.org/fhir/R4/organization.html#Organization.contact.name" 'element))
(register-element! "Organization.contact.telecom" (fhir-spec (string->symbol "Organization.contact.telecom") "https://hl7.org/fhir/R4/organization.html#Organization.contact.telecom" 'element))
(register-element! "Organization.contact.address" (fhir-spec (string->symbol "Organization.contact.address") "https://hl7.org/fhir/R4/organization.html#Organization.contact.address" 'element))

