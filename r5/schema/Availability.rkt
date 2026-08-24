#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Availability (fhir-spec 'Availability "https://hl7.org/fhir/R5/datatypes.html#Availability" 'type)
  #:schema (type-schema 'Availability #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#Availability"
             (list
    (schema-field 'availableTime 0 '* (vector 'type 'AvailabilityAvailableTime) #f "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime" #f)
    (schema-field 'notAvailableTime 0 '* (vector 'type 'AvailabilityNotAvailableTime) #f "https://hl7.org/fhir/R5/datatypes.html#Availability.notAvailableTime" #f)
             ) #f #f))
(register-element! "Availability.availableTime" (fhir-spec (string->symbol "Availability.availableTime") "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime" 'element))
(register-element! "Availability.notAvailableTime" (fhir-spec (string->symbol "Availability.notAvailableTime") "https://hl7.org/fhir/R5/datatypes.html#Availability.notAvailableTime" 'element))

(register-type! 'AvailabilityAvailableTime (fhir-spec 'AvailabilityAvailableTime "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime" 'type)
  #:schema (type-schema 'AvailabilityAvailableTime #f 'BackboneElement "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime"
             (list
    (schema-field 'daysOfWeek 0 '* (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime.daysOfWeek" #f)
    (schema-field 'allDay 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime.allDay" #f)
    (schema-field 'availableStartTime 0 1 (vector 'prim "time") #f "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime.availableStartTime" #f)
    (schema-field 'availableEndTime 0 1 (vector 'prim "time") #f "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime.availableEndTime" #f)
             ) #f #f))
(register-element! "Availability.availableTime.daysOfWeek" (fhir-spec (string->symbol "Availability.availableTime.daysOfWeek") "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime.daysOfWeek" 'element))
(register-element! "Availability.availableTime.allDay" (fhir-spec (string->symbol "Availability.availableTime.allDay") "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime.allDay" 'element))
(register-element! "Availability.availableTime.availableStartTime" (fhir-spec (string->symbol "Availability.availableTime.availableStartTime") "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime.availableStartTime" 'element))
(register-element! "Availability.availableTime.availableEndTime" (fhir-spec (string->symbol "Availability.availableTime.availableEndTime") "https://hl7.org/fhir/R5/datatypes.html#Availability.availableTime.availableEndTime" 'element))

(register-type! 'AvailabilityNotAvailableTime (fhir-spec 'AvailabilityNotAvailableTime "https://hl7.org/fhir/R5/datatypes.html#Availability.notAvailableTime" 'type)
  #:schema (type-schema 'AvailabilityNotAvailableTime #f 'BackboneElement "https://hl7.org/fhir/R5/datatypes.html#Availability.notAvailableTime"
             (list
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Availability.notAvailableTime.description" #f)
    (schema-field 'during 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/datatypes.html#Availability.notAvailableTime.during" #f)
             ) #f #f))
(register-element! "Availability.notAvailableTime.description" (fhir-spec (string->symbol "Availability.notAvailableTime.description") "https://hl7.org/fhir/R5/datatypes.html#Availability.notAvailableTime.description" 'element))
(register-element! "Availability.notAvailableTime.during" (fhir-spec (string->symbol "Availability.notAvailableTime.during") "https://hl7.org/fhir/R5/datatypes.html#Availability.notAvailableTime.during" 'element))

