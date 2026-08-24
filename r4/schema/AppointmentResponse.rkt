#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'AppointmentResponse (fhir-spec 'AppointmentResponse "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse" 'type)
  #:schema (type-schema 'AppointmentResponse #f 'DomainResource "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.identifier" #f)
    (schema-field 'appointment 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.appointment" #f)
    (schema-field 'start 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.start" #f)
    (schema-field 'end 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.end" #f)
    (schema-field 'participantType 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.participantType" #f)
    (schema-field 'actor 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.actor" #f)
    (schema-field 'participantStatus 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.participantStatus" #f)
    (schema-field 'comment 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.comment" #f)
             ) #f #f))
(register-element! "AppointmentResponse.identifier" (fhir-spec (string->symbol "AppointmentResponse.identifier") "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.identifier" 'element))
(register-element! "AppointmentResponse.appointment" (fhir-spec (string->symbol "AppointmentResponse.appointment") "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.appointment" 'element))
(register-element! "AppointmentResponse.start" (fhir-spec (string->symbol "AppointmentResponse.start") "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.start" 'element))
(register-element! "AppointmentResponse.end" (fhir-spec (string->symbol "AppointmentResponse.end") "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.end" 'element))
(register-element! "AppointmentResponse.participantType" (fhir-spec (string->symbol "AppointmentResponse.participantType") "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.participantType" 'element))
(register-element! "AppointmentResponse.actor" (fhir-spec (string->symbol "AppointmentResponse.actor") "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.actor" 'element))
(register-element! "AppointmentResponse.participantStatus" (fhir-spec (string->symbol "AppointmentResponse.participantStatus") "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.participantStatus" 'element))
(register-element! "AppointmentResponse.comment" (fhir-spec (string->symbol "AppointmentResponse.comment") "https://hl7.org/fhir/R4/appointmentresponse.html#AppointmentResponse.comment" 'element))

