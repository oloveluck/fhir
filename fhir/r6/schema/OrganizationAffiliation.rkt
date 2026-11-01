#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'OrganizationAffiliation (fhir-spec 'OrganizationAffiliation "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation" 'type)
  #:schema (type-schema 'OrganizationAffiliation #f 'DomainResource "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.active" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.period" #f)
    (schema-field 'organization 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.organization" #f)
    (schema-field 'participatingOrganization 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.participatingOrganization" #f)
    (schema-field 'network 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.network" #f)
    (schema-field 'code 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.code" #f)
    (schema-field 'specialty 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.specialty" #f)
    (schema-field 'location 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.location" #f)
    (schema-field 'healthcareService 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.healthcareService" #f)
    (schema-field 'contact 0 '* (vector 'type 'ExtendedContactDetail) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.contact" #f)
    (schema-field 'endpoint 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.endpoint" #f)
             ) #f #f))
(register-element! "OrganizationAffiliation.identifier" (fhir-spec (string->symbol "OrganizationAffiliation.identifier") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.identifier" 'element))
(register-element! "OrganizationAffiliation.active" (fhir-spec (string->symbol "OrganizationAffiliation.active") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.active" 'element))
(register-element! "OrganizationAffiliation.period" (fhir-spec (string->symbol "OrganizationAffiliation.period") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.period" 'element))
(register-element! "OrganizationAffiliation.organization" (fhir-spec (string->symbol "OrganizationAffiliation.organization") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.organization" 'element))
(register-element! "OrganizationAffiliation.participatingOrganization" (fhir-spec (string->symbol "OrganizationAffiliation.participatingOrganization") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.participatingOrganization" 'element))
(register-element! "OrganizationAffiliation.network" (fhir-spec (string->symbol "OrganizationAffiliation.network") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.network" 'element))
(register-element! "OrganizationAffiliation.code" (fhir-spec (string->symbol "OrganizationAffiliation.code") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.code" 'element))
(register-element! "OrganizationAffiliation.specialty" (fhir-spec (string->symbol "OrganizationAffiliation.specialty") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.specialty" 'element))
(register-element! "OrganizationAffiliation.location" (fhir-spec (string->symbol "OrganizationAffiliation.location") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.location" 'element))
(register-element! "OrganizationAffiliation.healthcareService" (fhir-spec (string->symbol "OrganizationAffiliation.healthcareService") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.healthcareService" 'element))
(register-element! "OrganizationAffiliation.contact" (fhir-spec (string->symbol "OrganizationAffiliation.contact") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.contact" 'element))
(register-element! "OrganizationAffiliation.endpoint" (fhir-spec (string->symbol "OrganizationAffiliation.endpoint") "https://build.fhir.org/organizationaffiliation.html#OrganizationAffiliation.endpoint" 'element))

