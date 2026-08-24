#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MessageHeader (fhir-spec 'MessageHeader "https://build.fhir.org/messageheader.html#MessageHeader" 'type)
  #:schema (type-schema 'MessageHeader #f 'DomainResource "https://build.fhir.org/messageheader.html#MessageHeader"
             (list
    (schema-field 'destination 0 '* (vector 'type 'MessageHeaderDestination) #f "https://build.fhir.org/messageheader.html#MessageHeader.destination" #f)
    (schema-field 'source 1 1 (vector 'type 'MessageHeaderSource) #f "https://build.fhir.org/messageheader.html#MessageHeader.source" #f)
    (schema-field 'reason 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/messageheader.html#MessageHeader.reason" #f)
    (schema-field 'response 0 1 (vector 'type 'MessageHeaderResponse) #f "https://build.fhir.org/messageheader.html#MessageHeader.response" #f)
    (schema-field 'focus 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/messageheader.html#MessageHeader.focus" #f)
    (schema-field 'definition 0 1 (vector 'prim "canonical") #f "https://build.fhir.org/messageheader.html#MessageHeader.definition" #f)
    (schema-field 'eventCoding 0 1 (vector 'type 'Coding) 'event "https://build.fhir.org/messageheader.html#MessageHeader.event[x]" #f)
    (schema-field 'eventUri 0 1 (vector 'prim "uri") 'event "https://build.fhir.org/messageheader.html#MessageHeader.event[x]" #f)
    (schema-field 'eventCanonical 0 1 (vector 'prim "canonical") 'event "https://build.fhir.org/messageheader.html#MessageHeader.event[x]" #f)
             ) #f #f))
(register-element! "MessageHeader.destination" (fhir-spec (string->symbol "MessageHeader.destination") "https://build.fhir.org/messageheader.html#MessageHeader.destination" 'element))
(register-element! "MessageHeader.source" (fhir-spec (string->symbol "MessageHeader.source") "https://build.fhir.org/messageheader.html#MessageHeader.source" 'element))
(register-element! "MessageHeader.reason" (fhir-spec (string->symbol "MessageHeader.reason") "https://build.fhir.org/messageheader.html#MessageHeader.reason" 'element))
(register-element! "MessageHeader.response" (fhir-spec (string->symbol "MessageHeader.response") "https://build.fhir.org/messageheader.html#MessageHeader.response" 'element))
(register-element! "MessageHeader.focus" (fhir-spec (string->symbol "MessageHeader.focus") "https://build.fhir.org/messageheader.html#MessageHeader.focus" 'element))
(register-element! "MessageHeader.definition" (fhir-spec (string->symbol "MessageHeader.definition") "https://build.fhir.org/messageheader.html#MessageHeader.definition" 'element))
(register-element! "MessageHeader.event[x]" (fhir-spec (string->symbol "MessageHeader.event[x]") "https://build.fhir.org/messageheader.html#MessageHeader.event[x]" 'element))
(register-element! "MessageHeader.event[x]" (fhir-spec (string->symbol "MessageHeader.event[x]") "https://build.fhir.org/messageheader.html#MessageHeader.event[x]" 'element))
(register-element! "MessageHeader.event[x]" (fhir-spec (string->symbol "MessageHeader.event[x]") "https://build.fhir.org/messageheader.html#MessageHeader.event[x]" 'element))

(register-type! 'MessageHeaderDestination (fhir-spec 'MessageHeaderDestination "https://build.fhir.org/messageheader.html#MessageHeader.destination" 'type)
  #:schema (type-schema 'MessageHeaderDestination #f 'BackboneElement "https://build.fhir.org/messageheader.html#MessageHeader.destination"
             (list
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://build.fhir.org/messageheader.html#MessageHeader.destination.name" #f)
    (schema-field 'receiver 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/messageheader.html#MessageHeader.destination.receiver" #f)
    (schema-field 'endpointUrl 0 1 (vector 'prim "url") 'endpoint "https://build.fhir.org/messageheader.html#MessageHeader.destination.endpoint[x]" #f)
    (schema-field 'endpointReference 0 1 (vector 'type 'Reference) 'endpoint "https://build.fhir.org/messageheader.html#MessageHeader.destination.endpoint[x]" #f)
             ) #f #f))
(register-element! "MessageHeader.destination.name" (fhir-spec (string->symbol "MessageHeader.destination.name") "https://build.fhir.org/messageheader.html#MessageHeader.destination.name" 'element))
(register-element! "MessageHeader.destination.receiver" (fhir-spec (string->symbol "MessageHeader.destination.receiver") "https://build.fhir.org/messageheader.html#MessageHeader.destination.receiver" 'element))
(register-element! "MessageHeader.destination.endpoint[x]" (fhir-spec (string->symbol "MessageHeader.destination.endpoint[x]") "https://build.fhir.org/messageheader.html#MessageHeader.destination.endpoint[x]" 'element))
(register-element! "MessageHeader.destination.endpoint[x]" (fhir-spec (string->symbol "MessageHeader.destination.endpoint[x]") "https://build.fhir.org/messageheader.html#MessageHeader.destination.endpoint[x]" 'element))

(register-type! 'MessageHeaderSource (fhir-spec 'MessageHeaderSource "https://build.fhir.org/messageheader.html#MessageHeader.source" 'type)
  #:schema (type-schema 'MessageHeaderSource #f 'BackboneElement "https://build.fhir.org/messageheader.html#MessageHeader.source"
             (list
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://build.fhir.org/messageheader.html#MessageHeader.source.name" #f)
    (schema-field 'software 0 1 (vector 'prim "string") #f "https://build.fhir.org/messageheader.html#MessageHeader.source.software" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://build.fhir.org/messageheader.html#MessageHeader.source.version" #f)
    (schema-field 'contact 0 1 (vector 'type 'ContactPoint) #f "https://build.fhir.org/messageheader.html#MessageHeader.source.contact" #f)
    (schema-field 'sender 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/messageheader.html#MessageHeader.source.sender" #f)
    (schema-field 'endpointUrl 0 1 (vector 'prim "url") 'endpoint "https://build.fhir.org/messageheader.html#MessageHeader.source.endpoint[x]" #f)
    (schema-field 'endpointReference 0 1 (vector 'type 'Reference) 'endpoint "https://build.fhir.org/messageheader.html#MessageHeader.source.endpoint[x]" #f)
             ) #f #f))
(register-element! "MessageHeader.source.name" (fhir-spec (string->symbol "MessageHeader.source.name") "https://build.fhir.org/messageheader.html#MessageHeader.source.name" 'element))
(register-element! "MessageHeader.source.software" (fhir-spec (string->symbol "MessageHeader.source.software") "https://build.fhir.org/messageheader.html#MessageHeader.source.software" 'element))
(register-element! "MessageHeader.source.version" (fhir-spec (string->symbol "MessageHeader.source.version") "https://build.fhir.org/messageheader.html#MessageHeader.source.version" 'element))
(register-element! "MessageHeader.source.contact" (fhir-spec (string->symbol "MessageHeader.source.contact") "https://build.fhir.org/messageheader.html#MessageHeader.source.contact" 'element))
(register-element! "MessageHeader.source.sender" (fhir-spec (string->symbol "MessageHeader.source.sender") "https://build.fhir.org/messageheader.html#MessageHeader.source.sender" 'element))
(register-element! "MessageHeader.source.endpoint[x]" (fhir-spec (string->symbol "MessageHeader.source.endpoint[x]") "https://build.fhir.org/messageheader.html#MessageHeader.source.endpoint[x]" 'element))
(register-element! "MessageHeader.source.endpoint[x]" (fhir-spec (string->symbol "MessageHeader.source.endpoint[x]") "https://build.fhir.org/messageheader.html#MessageHeader.source.endpoint[x]" 'element))

(register-type! 'MessageHeaderResponse (fhir-spec 'MessageHeaderResponse "https://build.fhir.org/messageheader.html#MessageHeader.response" 'type)
  #:schema (type-schema 'MessageHeaderResponse #f 'BackboneElement "https://build.fhir.org/messageheader.html#MessageHeader.response"
             (list
    (schema-field 'identifier 1 1 (vector 'type 'Identifier) #f "https://build.fhir.org/messageheader.html#MessageHeader.response.identifier" #f)
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://build.fhir.org/messageheader.html#MessageHeader.response.code" #f)
    (schema-field 'details 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/messageheader.html#MessageHeader.response.details" #f)
             ) #f #f))
(register-element! "MessageHeader.response.identifier" (fhir-spec (string->symbol "MessageHeader.response.identifier") "https://build.fhir.org/messageheader.html#MessageHeader.response.identifier" 'element))
(register-element! "MessageHeader.response.code" (fhir-spec (string->symbol "MessageHeader.response.code") "https://build.fhir.org/messageheader.html#MessageHeader.response.code" 'element))
(register-element! "MessageHeader.response.details" (fhir-spec (string->symbol "MessageHeader.response.details") "https://build.fhir.org/messageheader.html#MessageHeader.response.details" 'element))

