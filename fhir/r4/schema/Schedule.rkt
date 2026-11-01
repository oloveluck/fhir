#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Schedule (fhir-spec 'Schedule "https://hl7.org/fhir/R4/schedule.html#Schedule" 'type)
  #:schema (type-schema 'Schedule #f 'DomainResource "https://hl7.org/fhir/R4/schedule.html#Schedule"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/schedule.html#Schedule.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/schedule.html#Schedule.active" #f)
    (schema-field 'serviceCategory 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/schedule.html#Schedule.serviceCategory" #f)
    (schema-field 'serviceType 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/schedule.html#Schedule.serviceType" #f)
    (schema-field 'specialty 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/schedule.html#Schedule.specialty" #f)
    (schema-field 'actor 1 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/schedule.html#Schedule.actor" #f)
    (schema-field 'planningHorizon 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/schedule.html#Schedule.planningHorizon" #f)
    (schema-field 'comment 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/schedule.html#Schedule.comment" #f)
             ) #f #f))
(register-element! "Schedule.identifier" (fhir-spec (string->symbol "Schedule.identifier") "https://hl7.org/fhir/R4/schedule.html#Schedule.identifier" 'element))
(register-element! "Schedule.active" (fhir-spec (string->symbol "Schedule.active") "https://hl7.org/fhir/R4/schedule.html#Schedule.active" 'element))
(register-element! "Schedule.serviceCategory" (fhir-spec (string->symbol "Schedule.serviceCategory") "https://hl7.org/fhir/R4/schedule.html#Schedule.serviceCategory" 'element))
(register-element! "Schedule.serviceType" (fhir-spec (string->symbol "Schedule.serviceType") "https://hl7.org/fhir/R4/schedule.html#Schedule.serviceType" 'element))
(register-element! "Schedule.specialty" (fhir-spec (string->symbol "Schedule.specialty") "https://hl7.org/fhir/R4/schedule.html#Schedule.specialty" 'element))
(register-element! "Schedule.actor" (fhir-spec (string->symbol "Schedule.actor") "https://hl7.org/fhir/R4/schedule.html#Schedule.actor" 'element))
(register-element! "Schedule.planningHorizon" (fhir-spec (string->symbol "Schedule.planningHorizon") "https://hl7.org/fhir/R4/schedule.html#Schedule.planningHorizon" 'element))
(register-element! "Schedule.comment" (fhir-spec (string->symbol "Schedule.comment") "https://hl7.org/fhir/R4/schedule.html#Schedule.comment" 'element))

