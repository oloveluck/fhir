#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Endpoint (fhir-spec 'Endpoint "https://build.fhir.org/endpoint.html#Endpoint" 'type)
  #:schema (type-schema 'Endpoint #f 'DomainResource "https://build.fhir.org/endpoint.html#Endpoint"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/endpoint.html#Endpoint.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/endpoint.html#Endpoint.status" #f)
    (schema-field 'connectionType 1 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/endpoint.html#Endpoint.connectionType" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://build.fhir.org/endpoint.html#Endpoint.name" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://build.fhir.org/endpoint.html#Endpoint.description" #f)
    (schema-field 'environmentType 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/endpoint.html#Endpoint.environmentType" #f)
    (schema-field 'managingOrganization 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/endpoint.html#Endpoint.managingOrganization" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactPoint) #f "https://build.fhir.org/endpoint.html#Endpoint.contact" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/endpoint.html#Endpoint.period" #f)
    (schema-field 'availability 0 1 (vector 'type 'Availability) #f "https://build.fhir.org/endpoint.html#Endpoint.availability" #f)
    (schema-field 'payload 0 '* (vector 'type 'EndpointPayload) #f "https://build.fhir.org/endpoint.html#Endpoint.payload" #f)
    (schema-field 'address 1 1 (vector 'prim "url") #f "https://build.fhir.org/endpoint.html#Endpoint.address" #f)
    (schema-field 'header 0 '* (vector 'prim "string") #f "https://build.fhir.org/endpoint.html#Endpoint.header" #f)
             ) #f #f))
(register-element! "Endpoint.identifier" (fhir-spec (string->symbol "Endpoint.identifier") "https://build.fhir.org/endpoint.html#Endpoint.identifier" 'element))
(register-element! "Endpoint.status" (fhir-spec (string->symbol "Endpoint.status") "https://build.fhir.org/endpoint.html#Endpoint.status" 'element))
(register-element! "Endpoint.connectionType" (fhir-spec (string->symbol "Endpoint.connectionType") "https://build.fhir.org/endpoint.html#Endpoint.connectionType" 'element))
(register-element! "Endpoint.name" (fhir-spec (string->symbol "Endpoint.name") "https://build.fhir.org/endpoint.html#Endpoint.name" 'element))
(register-element! "Endpoint.description" (fhir-spec (string->symbol "Endpoint.description") "https://build.fhir.org/endpoint.html#Endpoint.description" 'element))
(register-element! "Endpoint.environmentType" (fhir-spec (string->symbol "Endpoint.environmentType") "https://build.fhir.org/endpoint.html#Endpoint.environmentType" 'element))
(register-element! "Endpoint.managingOrganization" (fhir-spec (string->symbol "Endpoint.managingOrganization") "https://build.fhir.org/endpoint.html#Endpoint.managingOrganization" 'element))
(register-element! "Endpoint.contact" (fhir-spec (string->symbol "Endpoint.contact") "https://build.fhir.org/endpoint.html#Endpoint.contact" 'element))
(register-element! "Endpoint.period" (fhir-spec (string->symbol "Endpoint.period") "https://build.fhir.org/endpoint.html#Endpoint.period" 'element))
(register-element! "Endpoint.availability" (fhir-spec (string->symbol "Endpoint.availability") "https://build.fhir.org/endpoint.html#Endpoint.availability" 'element))
(register-element! "Endpoint.payload" (fhir-spec (string->symbol "Endpoint.payload") "https://build.fhir.org/endpoint.html#Endpoint.payload" 'element))
(register-element! "Endpoint.address" (fhir-spec (string->symbol "Endpoint.address") "https://build.fhir.org/endpoint.html#Endpoint.address" 'element))
(register-element! "Endpoint.header" (fhir-spec (string->symbol "Endpoint.header") "https://build.fhir.org/endpoint.html#Endpoint.header" 'element))

(register-type! 'EndpointPayload (fhir-spec 'EndpointPayload "https://build.fhir.org/endpoint.html#Endpoint.payload" 'type)
  #:schema (type-schema 'EndpointPayload #f 'BackboneElement "https://build.fhir.org/endpoint.html#Endpoint.payload"
             (list
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/endpoint.html#Endpoint.payload.type" #f)
    (schema-field 'mimeType 0 '* (vector 'prim "code") #f "https://build.fhir.org/endpoint.html#Endpoint.payload.mimeType" #f)
    (schema-field 'profileCanonical 0 '* (vector 'prim "canonical") #f "https://build.fhir.org/endpoint.html#Endpoint.payload.profileCanonical" #f)
    (schema-field 'profileUri 0 '* (vector 'prim "uri") #f "https://build.fhir.org/endpoint.html#Endpoint.payload.profileUri" #f)
             ) #f #f))
(register-element! "Endpoint.payload.type" (fhir-spec (string->symbol "Endpoint.payload.type") "https://build.fhir.org/endpoint.html#Endpoint.payload.type" 'element))
(register-element! "Endpoint.payload.mimeType" (fhir-spec (string->symbol "Endpoint.payload.mimeType") "https://build.fhir.org/endpoint.html#Endpoint.payload.mimeType" 'element))
(register-element! "Endpoint.payload.profileCanonical" (fhir-spec (string->symbol "Endpoint.payload.profileCanonical") "https://build.fhir.org/endpoint.html#Endpoint.payload.profileCanonical" 'element))
(register-element! "Endpoint.payload.profileUri" (fhir-spec (string->symbol "Endpoint.payload.profileUri") "https://build.fhir.org/endpoint.html#Endpoint.payload.profileUri" 'element))

