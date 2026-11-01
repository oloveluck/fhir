#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DeviceAssociation (fhir-spec 'DeviceAssociation "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation" 'type)
  #:schema (type-schema 'DeviceAssociation #f 'DomainResource "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.identifier" #f)
    (schema-field 'device 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.device" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.category" #f)
    (schema-field 'status 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.status" #f)
    (schema-field 'statusReason 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.statusReason" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.subject" #f)
    (schema-field 'bodyStructure 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.bodyStructure" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.period" #f)
    (schema-field 'operation 0 '* (vector 'type 'DeviceAssociationOperation) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation" #f)
             ) #f #f))
(register-element! "DeviceAssociation.identifier" (fhir-spec (string->symbol "DeviceAssociation.identifier") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.identifier" 'element))
(register-element! "DeviceAssociation.device" (fhir-spec (string->symbol "DeviceAssociation.device") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.device" 'element))
(register-element! "DeviceAssociation.category" (fhir-spec (string->symbol "DeviceAssociation.category") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.category" 'element))
(register-element! "DeviceAssociation.status" (fhir-spec (string->symbol "DeviceAssociation.status") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.status" 'element))
(register-element! "DeviceAssociation.statusReason" (fhir-spec (string->symbol "DeviceAssociation.statusReason") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.statusReason" 'element))
(register-element! "DeviceAssociation.subject" (fhir-spec (string->symbol "DeviceAssociation.subject") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.subject" 'element))
(register-element! "DeviceAssociation.bodyStructure" (fhir-spec (string->symbol "DeviceAssociation.bodyStructure") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.bodyStructure" 'element))
(register-element! "DeviceAssociation.period" (fhir-spec (string->symbol "DeviceAssociation.period") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.period" 'element))
(register-element! "DeviceAssociation.operation" (fhir-spec (string->symbol "DeviceAssociation.operation") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation" 'element))

(register-type! 'DeviceAssociationOperation (fhir-spec 'DeviceAssociationOperation "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation" 'type)
  #:schema (type-schema 'DeviceAssociationOperation #f 'BackboneElement "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation"
             (list
    (schema-field 'status 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation.status" #f)
    (schema-field 'operator 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation.operator" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation.period" #f)
             ) #f #f))
(register-element! "DeviceAssociation.operation.status" (fhir-spec (string->symbol "DeviceAssociation.operation.status") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation.status" 'element))
(register-element! "DeviceAssociation.operation.operator" (fhir-spec (string->symbol "DeviceAssociation.operation.operator") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation.operator" 'element))
(register-element! "DeviceAssociation.operation.period" (fhir-spec (string->symbol "DeviceAssociation.operation.period") "https://hl7.org/fhir/R5/deviceassociation.html#DeviceAssociation.operation.period" 'element))

