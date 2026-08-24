#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Endpoint (fhir-spec 'Endpoint "https://hl7.org/fhir/R5/endpoint.html#Endpoint" 'type)
  #:schema (type-schema 'Endpoint #f 'DomainResource "https://hl7.org/fhir/R5/endpoint.html#Endpoint"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.status" #f)
    (schema-field 'connectionType 1 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.connectionType" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.name" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.description" #f)
    (schema-field 'environmentType 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.environmentType" #f)
    (schema-field 'managingOrganization 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.managingOrganization" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.contact" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.period" #f)
    (schema-field 'payload 0 '* (vector 'type 'EndpointPayload) #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.payload" #f)
    (schema-field 'address 1 1 (vector 'prim "url") #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.address" #f)
    (schema-field 'header 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.header" #f)
             ) #f #f))
(register-element! "Endpoint.identifier" (fhir-spec (string->symbol "Endpoint.identifier") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.identifier" 'element))
(register-element! "Endpoint.status" (fhir-spec (string->symbol "Endpoint.status") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.status" 'element))
(register-element! "Endpoint.connectionType" (fhir-spec (string->symbol "Endpoint.connectionType") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.connectionType" 'element))
(register-element! "Endpoint.name" (fhir-spec (string->symbol "Endpoint.name") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.name" 'element))
(register-element! "Endpoint.description" (fhir-spec (string->symbol "Endpoint.description") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.description" 'element))
(register-element! "Endpoint.environmentType" (fhir-spec (string->symbol "Endpoint.environmentType") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.environmentType" 'element))
(register-element! "Endpoint.managingOrganization" (fhir-spec (string->symbol "Endpoint.managingOrganization") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.managingOrganization" 'element))
(register-element! "Endpoint.contact" (fhir-spec (string->symbol "Endpoint.contact") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.contact" 'element))
(register-element! "Endpoint.period" (fhir-spec (string->symbol "Endpoint.period") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.period" 'element))
(register-element! "Endpoint.payload" (fhir-spec (string->symbol "Endpoint.payload") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.payload" 'element))
(register-element! "Endpoint.address" (fhir-spec (string->symbol "Endpoint.address") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.address" 'element))
(register-element! "Endpoint.header" (fhir-spec (string->symbol "Endpoint.header") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.header" 'element))

(register-type! 'EndpointPayload (fhir-spec 'EndpointPayload "https://hl7.org/fhir/R5/endpoint.html#Endpoint.payload" 'type)
  #:schema (type-schema 'EndpointPayload #f 'BackboneElement "https://hl7.org/fhir/R5/endpoint.html#Endpoint.payload"
             (list
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.payload.type" #f)
    (schema-field 'mimeType 0 '* (vector 'prim "code") #f "https://hl7.org/fhir/R5/endpoint.html#Endpoint.payload.mimeType" #f)
             ) #f #f))
(register-element! "Endpoint.payload.type" (fhir-spec (string->symbol "Endpoint.payload.type") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.payload.type" 'element))
(register-element! "Endpoint.payload.mimeType" (fhir-spec (string->symbol "Endpoint.payload.mimeType") "https://hl7.org/fhir/R5/endpoint.html#Endpoint.payload.mimeType" 'element))

