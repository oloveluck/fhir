#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Slot (fhir-spec 'Slot "https://build.fhir.org/slot.html#Slot" 'type)
  #:schema (type-schema 'Slot #f 'DomainResource "https://build.fhir.org/slot.html#Slot"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/slot.html#Slot.identifier" #f)
    (schema-field 'serviceCategory 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/slot.html#Slot.serviceCategory" #f)
    (schema-field 'serviceType 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/slot.html#Slot.serviceType" #f)
    (schema-field 'specialty 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/slot.html#Slot.specialty" #f)
    (schema-field 'appointmentType 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/slot.html#Slot.appointmentType" #f)
    (schema-field 'schedule 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/slot.html#Slot.schedule" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/slot.html#Slot.status" #f)
    (schema-field 'start 1 1 (vector 'prim "instant") #f "https://build.fhir.org/slot.html#Slot.start" #f)
    (schema-field 'end 1 1 (vector 'prim "instant") #f "https://build.fhir.org/slot.html#Slot.end" #f)
    (schema-field 'overbooked 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/slot.html#Slot.overbooked" #f)
    (schema-field 'comment 0 1 (vector 'prim "string") #f "https://build.fhir.org/slot.html#Slot.comment" #f)
             ) #f #f))
(register-element! "Slot.identifier" (fhir-spec (string->symbol "Slot.identifier") "https://build.fhir.org/slot.html#Slot.identifier" 'element))
(register-element! "Slot.serviceCategory" (fhir-spec (string->symbol "Slot.serviceCategory") "https://build.fhir.org/slot.html#Slot.serviceCategory" 'element))
(register-element! "Slot.serviceType" (fhir-spec (string->symbol "Slot.serviceType") "https://build.fhir.org/slot.html#Slot.serviceType" 'element))
(register-element! "Slot.specialty" (fhir-spec (string->symbol "Slot.specialty") "https://build.fhir.org/slot.html#Slot.specialty" 'element))
(register-element! "Slot.appointmentType" (fhir-spec (string->symbol "Slot.appointmentType") "https://build.fhir.org/slot.html#Slot.appointmentType" 'element))
(register-element! "Slot.schedule" (fhir-spec (string->symbol "Slot.schedule") "https://build.fhir.org/slot.html#Slot.schedule" 'element))
(register-element! "Slot.status" (fhir-spec (string->symbol "Slot.status") "https://build.fhir.org/slot.html#Slot.status" 'element))
(register-element! "Slot.start" (fhir-spec (string->symbol "Slot.start") "https://build.fhir.org/slot.html#Slot.start" 'element))
(register-element! "Slot.end" (fhir-spec (string->symbol "Slot.end") "https://build.fhir.org/slot.html#Slot.end" 'element))
(register-element! "Slot.overbooked" (fhir-spec (string->symbol "Slot.overbooked") "https://build.fhir.org/slot.html#Slot.overbooked" 'element))
(register-element! "Slot.comment" (fhir-spec (string->symbol "Slot.comment") "https://build.fhir.org/slot.html#Slot.comment" 'element))

