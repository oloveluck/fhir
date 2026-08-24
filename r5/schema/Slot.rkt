#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Slot (fhir-spec 'Slot "https://hl7.org/fhir/R5/slot.html#Slot" 'type)
  #:schema (type-schema 'Slot #f 'DomainResource "https://hl7.org/fhir/R5/slot.html#Slot"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/slot.html#Slot.identifier" #f)
    (schema-field 'serviceCategory 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/slot.html#Slot.serviceCategory" #f)
    (schema-field 'serviceType 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/slot.html#Slot.serviceType" #f)
    (schema-field 'specialty 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/slot.html#Slot.specialty" #f)
    (schema-field 'appointmentType 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/slot.html#Slot.appointmentType" #f)
    (schema-field 'schedule 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/slot.html#Slot.schedule" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/slot.html#Slot.status" #f)
    (schema-field 'start 1 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/slot.html#Slot.start" #f)
    (schema-field 'end 1 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/slot.html#Slot.end" #f)
    (schema-field 'overbooked 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/slot.html#Slot.overbooked" #f)
    (schema-field 'comment 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/slot.html#Slot.comment" #f)
             ) #f #f))
(register-element! "Slot.identifier" (fhir-spec (string->symbol "Slot.identifier") "https://hl7.org/fhir/R5/slot.html#Slot.identifier" 'element))
(register-element! "Slot.serviceCategory" (fhir-spec (string->symbol "Slot.serviceCategory") "https://hl7.org/fhir/R5/slot.html#Slot.serviceCategory" 'element))
(register-element! "Slot.serviceType" (fhir-spec (string->symbol "Slot.serviceType") "https://hl7.org/fhir/R5/slot.html#Slot.serviceType" 'element))
(register-element! "Slot.specialty" (fhir-spec (string->symbol "Slot.specialty") "https://hl7.org/fhir/R5/slot.html#Slot.specialty" 'element))
(register-element! "Slot.appointmentType" (fhir-spec (string->symbol "Slot.appointmentType") "https://hl7.org/fhir/R5/slot.html#Slot.appointmentType" 'element))
(register-element! "Slot.schedule" (fhir-spec (string->symbol "Slot.schedule") "https://hl7.org/fhir/R5/slot.html#Slot.schedule" 'element))
(register-element! "Slot.status" (fhir-spec (string->symbol "Slot.status") "https://hl7.org/fhir/R5/slot.html#Slot.status" 'element))
(register-element! "Slot.start" (fhir-spec (string->symbol "Slot.start") "https://hl7.org/fhir/R5/slot.html#Slot.start" 'element))
(register-element! "Slot.end" (fhir-spec (string->symbol "Slot.end") "https://hl7.org/fhir/R5/slot.html#Slot.end" 'element))
(register-element! "Slot.overbooked" (fhir-spec (string->symbol "Slot.overbooked") "https://hl7.org/fhir/R5/slot.html#Slot.overbooked" 'element))
(register-element! "Slot.comment" (fhir-spec (string->symbol "Slot.comment") "https://hl7.org/fhir/R5/slot.html#Slot.comment" 'element))

