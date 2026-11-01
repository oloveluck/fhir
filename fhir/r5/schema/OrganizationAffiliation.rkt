#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'OrganizationAffiliation (fhir-spec 'OrganizationAffiliation "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation" 'type)
  #:schema (type-schema 'OrganizationAffiliation #f 'DomainResource "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.active" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.period" #f)
    (schema-field 'organization 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.organization" #f)
    (schema-field 'participatingOrganization 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.participatingOrganization" #f)
    (schema-field 'network 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.network" #f)
    (schema-field 'code 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.code" #f)
    (schema-field 'specialty 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.specialty" #f)
    (schema-field 'location 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.location" #f)
    (schema-field 'healthcareService 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.healthcareService" #f)
    (schema-field 'contact 0 '* (vector 'type 'ExtendedContactDetail) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.contact" #f)
    (schema-field 'endpoint 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.endpoint" #f)
             ) #f #f))
(register-element! "OrganizationAffiliation.identifier" (fhir-spec (string->symbol "OrganizationAffiliation.identifier") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.identifier" 'element))
(register-element! "OrganizationAffiliation.active" (fhir-spec (string->symbol "OrganizationAffiliation.active") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.active" 'element))
(register-element! "OrganizationAffiliation.period" (fhir-spec (string->symbol "OrganizationAffiliation.period") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.period" 'element))
(register-element! "OrganizationAffiliation.organization" (fhir-spec (string->symbol "OrganizationAffiliation.organization") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.organization" 'element))
(register-element! "OrganizationAffiliation.participatingOrganization" (fhir-spec (string->symbol "OrganizationAffiliation.participatingOrganization") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.participatingOrganization" 'element))
(register-element! "OrganizationAffiliation.network" (fhir-spec (string->symbol "OrganizationAffiliation.network") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.network" 'element))
(register-element! "OrganizationAffiliation.code" (fhir-spec (string->symbol "OrganizationAffiliation.code") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.code" 'element))
(register-element! "OrganizationAffiliation.specialty" (fhir-spec (string->symbol "OrganizationAffiliation.specialty") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.specialty" 'element))
(register-element! "OrganizationAffiliation.location" (fhir-spec (string->symbol "OrganizationAffiliation.location") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.location" 'element))
(register-element! "OrganizationAffiliation.healthcareService" (fhir-spec (string->symbol "OrganizationAffiliation.healthcareService") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.healthcareService" 'element))
(register-element! "OrganizationAffiliation.contact" (fhir-spec (string->symbol "OrganizationAffiliation.contact") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.contact" 'element))
(register-element! "OrganizationAffiliation.endpoint" (fhir-spec (string->symbol "OrganizationAffiliation.endpoint") "https://hl7.org/fhir/R5/organizationaffiliation.html#OrganizationAffiliation.endpoint" 'element))

