#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'PractitionerRole (fhir-spec 'PractitionerRole "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole" 'type)
  #:schema (type-schema 'PractitionerRole #f 'DomainResource "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.active" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.period" #f)
    (schema-field 'practitioner 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.practitioner" #f)
    (schema-field 'organization 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.organization" #f)
    (schema-field 'code 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.code" #f)
    (schema-field 'specialty 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.specialty" #f)
    (schema-field 'location 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.location" #f)
    (schema-field 'healthcareService 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.healthcareService" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.telecom" #f)
    (schema-field 'availableTime 0 '* (vector 'type 'PractitionerRoleAvailableTime) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime" #f)
    (schema-field 'notAvailable 0 '* (vector 'type 'PractitionerRoleNotAvailable) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.notAvailable" #f)
    (schema-field 'availabilityExceptions 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availabilityExceptions" #f)
    (schema-field 'endpoint 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.endpoint" #f)
             ) #f #f))
(register-element! "PractitionerRole.identifier" (fhir-spec (string->symbol "PractitionerRole.identifier") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.identifier" 'element))
(register-element! "PractitionerRole.active" (fhir-spec (string->symbol "PractitionerRole.active") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.active" 'element))
(register-element! "PractitionerRole.period" (fhir-spec (string->symbol "PractitionerRole.period") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.period" 'element))
(register-element! "PractitionerRole.practitioner" (fhir-spec (string->symbol "PractitionerRole.practitioner") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.practitioner" 'element))
(register-element! "PractitionerRole.organization" (fhir-spec (string->symbol "PractitionerRole.organization") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.organization" 'element))
(register-element! "PractitionerRole.code" (fhir-spec (string->symbol "PractitionerRole.code") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.code" 'element))
(register-element! "PractitionerRole.specialty" (fhir-spec (string->symbol "PractitionerRole.specialty") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.specialty" 'element))
(register-element! "PractitionerRole.location" (fhir-spec (string->symbol "PractitionerRole.location") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.location" 'element))
(register-element! "PractitionerRole.healthcareService" (fhir-spec (string->symbol "PractitionerRole.healthcareService") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.healthcareService" 'element))
(register-element! "PractitionerRole.telecom" (fhir-spec (string->symbol "PractitionerRole.telecom") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.telecom" 'element))
(register-element! "PractitionerRole.availableTime" (fhir-spec (string->symbol "PractitionerRole.availableTime") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime" 'element))
(register-element! "PractitionerRole.notAvailable" (fhir-spec (string->symbol "PractitionerRole.notAvailable") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.notAvailable" 'element))
(register-element! "PractitionerRole.availabilityExceptions" (fhir-spec (string->symbol "PractitionerRole.availabilityExceptions") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availabilityExceptions" 'element))
(register-element! "PractitionerRole.endpoint" (fhir-spec (string->symbol "PractitionerRole.endpoint") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.endpoint" 'element))

(register-type! 'PractitionerRoleAvailableTime (fhir-spec 'PractitionerRoleAvailableTime "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime" 'type)
  #:schema (type-schema 'PractitionerRoleAvailableTime #f 'BackboneElement "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime"
             (list
    (schema-field 'daysOfWeek 0 '* (vector 'prim "code") #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime.daysOfWeek" #f)
    (schema-field 'allDay 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime.allDay" #f)
    (schema-field 'availableStartTime 0 1 (vector 'prim "time") #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime.availableStartTime" #f)
    (schema-field 'availableEndTime 0 1 (vector 'prim "time") #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime.availableEndTime" #f)
             ) #f #f))
(register-element! "PractitionerRole.availableTime.daysOfWeek" (fhir-spec (string->symbol "PractitionerRole.availableTime.daysOfWeek") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime.daysOfWeek" 'element))
(register-element! "PractitionerRole.availableTime.allDay" (fhir-spec (string->symbol "PractitionerRole.availableTime.allDay") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime.allDay" 'element))
(register-element! "PractitionerRole.availableTime.availableStartTime" (fhir-spec (string->symbol "PractitionerRole.availableTime.availableStartTime") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime.availableStartTime" 'element))
(register-element! "PractitionerRole.availableTime.availableEndTime" (fhir-spec (string->symbol "PractitionerRole.availableTime.availableEndTime") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.availableTime.availableEndTime" 'element))

(register-type! 'PractitionerRoleNotAvailable (fhir-spec 'PractitionerRoleNotAvailable "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.notAvailable" 'type)
  #:schema (type-schema 'PractitionerRoleNotAvailable #f 'BackboneElement "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.notAvailable"
             (list
    (schema-field 'description 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.notAvailable.description" #f)
    (schema-field 'during 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.notAvailable.during" #f)
             ) #f #f))
(register-element! "PractitionerRole.notAvailable.description" (fhir-spec (string->symbol "PractitionerRole.notAvailable.description") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.notAvailable.description" 'element))
(register-element! "PractitionerRole.notAvailable.during" (fhir-spec (string->symbol "PractitionerRole.notAvailable.during") "https://hl7.org/fhir/R4/practitionerrole.html#PractitionerRole.notAvailable.during" 'element))

