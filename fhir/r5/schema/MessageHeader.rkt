#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MessageHeader (fhir-spec 'MessageHeader "https://hl7.org/fhir/R5/messageheader.html#MessageHeader" 'type)
  #:schema (type-schema 'MessageHeader #f 'DomainResource "https://hl7.org/fhir/R5/messageheader.html#MessageHeader"
             (list
    (schema-field 'destination 0 '* (vector 'type 'MessageHeaderDestination) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination" #f)
    (schema-field 'sender 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.sender" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.author" #f)
    (schema-field 'source 1 1 (vector 'type 'MessageHeaderSource) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source" #f)
    (schema-field 'responsible 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.responsible" #f)
    (schema-field 'reason 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.reason" #f)
    (schema-field 'response 0 1 (vector 'type 'MessageHeaderResponse) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response" #f)
    (schema-field 'focus 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.focus" #f)
    (schema-field 'definition 0 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.definition" #f)
    (schema-field 'eventCoding 0 1 (vector 'type 'Coding) 'event "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.event[x]" #f)
    (schema-field 'eventCanonical 0 1 (vector 'prim "canonical") 'event "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.event[x]" #f)
             ) #f #f))
(register-element! "MessageHeader.destination" (fhir-spec (string->symbol "MessageHeader.destination") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination" 'element))
(register-element! "MessageHeader.sender" (fhir-spec (string->symbol "MessageHeader.sender") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.sender" 'element))
(register-element! "MessageHeader.author" (fhir-spec (string->symbol "MessageHeader.author") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.author" 'element))
(register-element! "MessageHeader.source" (fhir-spec (string->symbol "MessageHeader.source") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source" 'element))
(register-element! "MessageHeader.responsible" (fhir-spec (string->symbol "MessageHeader.responsible") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.responsible" 'element))
(register-element! "MessageHeader.reason" (fhir-spec (string->symbol "MessageHeader.reason") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.reason" 'element))
(register-element! "MessageHeader.response" (fhir-spec (string->symbol "MessageHeader.response") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response" 'element))
(register-element! "MessageHeader.focus" (fhir-spec (string->symbol "MessageHeader.focus") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.focus" 'element))
(register-element! "MessageHeader.definition" (fhir-spec (string->symbol "MessageHeader.definition") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.definition" 'element))
(register-element! "MessageHeader.event[x]" (fhir-spec (string->symbol "MessageHeader.event[x]") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.event[x]" 'element))
(register-element! "MessageHeader.event[x]" (fhir-spec (string->symbol "MessageHeader.event[x]") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.event[x]" 'element))

(register-type! 'MessageHeaderDestination (fhir-spec 'MessageHeaderDestination "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination" 'type)
  #:schema (type-schema 'MessageHeaderDestination #f 'BackboneElement "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination"
             (list
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.name" #f)
    (schema-field 'target 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.target" #f)
    (schema-field 'receiver 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.receiver" #f)
    (schema-field 'endpointUrl 0 1 (vector 'prim "url") 'endpoint "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.endpoint[x]" #f)
    (schema-field 'endpointReference 0 1 (vector 'type 'Reference) 'endpoint "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.endpoint[x]" #f)
             ) #f #f))
(register-element! "MessageHeader.destination.name" (fhir-spec (string->symbol "MessageHeader.destination.name") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.name" 'element))
(register-element! "MessageHeader.destination.target" (fhir-spec (string->symbol "MessageHeader.destination.target") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.target" 'element))
(register-element! "MessageHeader.destination.receiver" (fhir-spec (string->symbol "MessageHeader.destination.receiver") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.receiver" 'element))
(register-element! "MessageHeader.destination.endpoint[x]" (fhir-spec (string->symbol "MessageHeader.destination.endpoint[x]") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.endpoint[x]" 'element))
(register-element! "MessageHeader.destination.endpoint[x]" (fhir-spec (string->symbol "MessageHeader.destination.endpoint[x]") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.destination.endpoint[x]" 'element))

(register-type! 'MessageHeaderSource (fhir-spec 'MessageHeaderSource "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source" 'type)
  #:schema (type-schema 'MessageHeaderSource #f 'BackboneElement "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source"
             (list
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.name" #f)
    (schema-field 'software 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.software" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.version" #f)
    (schema-field 'contact 0 1 (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.contact" #f)
    (schema-field 'endpointUrl 0 1 (vector 'prim "url") 'endpoint "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.endpoint[x]" #f)
    (schema-field 'endpointReference 0 1 (vector 'type 'Reference) 'endpoint "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.endpoint[x]" #f)
             ) #f #f))
(register-element! "MessageHeader.source.name" (fhir-spec (string->symbol "MessageHeader.source.name") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.name" 'element))
(register-element! "MessageHeader.source.software" (fhir-spec (string->symbol "MessageHeader.source.software") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.software" 'element))
(register-element! "MessageHeader.source.version" (fhir-spec (string->symbol "MessageHeader.source.version") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.version" 'element))
(register-element! "MessageHeader.source.contact" (fhir-spec (string->symbol "MessageHeader.source.contact") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.contact" 'element))
(register-element! "MessageHeader.source.endpoint[x]" (fhir-spec (string->symbol "MessageHeader.source.endpoint[x]") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.endpoint[x]" 'element))
(register-element! "MessageHeader.source.endpoint[x]" (fhir-spec (string->symbol "MessageHeader.source.endpoint[x]") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.source.endpoint[x]" 'element))

(register-type! 'MessageHeaderResponse (fhir-spec 'MessageHeaderResponse "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response" 'type)
  #:schema (type-schema 'MessageHeaderResponse #f 'BackboneElement "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response"
             (list
    (schema-field 'identifier 1 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response.identifier" #f)
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response.code" #f)
    (schema-field 'details 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response.details" #f)
             ) #f #f))
(register-element! "MessageHeader.response.identifier" (fhir-spec (string->symbol "MessageHeader.response.identifier") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response.identifier" 'element))
(register-element! "MessageHeader.response.code" (fhir-spec (string->symbol "MessageHeader.response.code") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response.code" 'element))
(register-element! "MessageHeader.response.details" (fhir-spec (string->symbol "MessageHeader.response.details") "https://hl7.org/fhir/R5/messageheader.html#MessageHeader.response.details" 'element))

