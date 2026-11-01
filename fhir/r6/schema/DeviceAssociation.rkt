#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DeviceAssociation (fhir-spec 'DeviceAssociation "https://build.fhir.org/deviceassociation.html#DeviceAssociation" 'type)
  #:schema (type-schema 'DeviceAssociation #f 'DomainResource "https://build.fhir.org/deviceassociation.html#DeviceAssociation"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.identifier" #f)
    (schema-field 'device 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.device" #f)
    (schema-field 'relationship 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.relationship" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.status" #f)
    (schema-field 'statusReason 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.statusReason" #f)
    (schema-field 'associationStatus 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.associationStatus" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.subject" #f)
    (schema-field 'focus 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.focus" #f)
    (schema-field 'bodyStructure 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.bodyStructure" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/deviceassociation.html#DeviceAssociation.period" #f)
             ) #f #f))
(register-element! "DeviceAssociation.identifier" (fhir-spec (string->symbol "DeviceAssociation.identifier") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.identifier" 'element))
(register-element! "DeviceAssociation.device" (fhir-spec (string->symbol "DeviceAssociation.device") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.device" 'element))
(register-element! "DeviceAssociation.relationship" (fhir-spec (string->symbol "DeviceAssociation.relationship") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.relationship" 'element))
(register-element! "DeviceAssociation.status" (fhir-spec (string->symbol "DeviceAssociation.status") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.status" 'element))
(register-element! "DeviceAssociation.statusReason" (fhir-spec (string->symbol "DeviceAssociation.statusReason") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.statusReason" 'element))
(register-element! "DeviceAssociation.associationStatus" (fhir-spec (string->symbol "DeviceAssociation.associationStatus") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.associationStatus" 'element))
(register-element! "DeviceAssociation.subject" (fhir-spec (string->symbol "DeviceAssociation.subject") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.subject" 'element))
(register-element! "DeviceAssociation.focus" (fhir-spec (string->symbol "DeviceAssociation.focus") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.focus" 'element))
(register-element! "DeviceAssociation.bodyStructure" (fhir-spec (string->symbol "DeviceAssociation.bodyStructure") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.bodyStructure" 'element))
(register-element! "DeviceAssociation.period" (fhir-spec (string->symbol "DeviceAssociation.period") "https://build.fhir.org/deviceassociation.html#DeviceAssociation.period" 'element))

