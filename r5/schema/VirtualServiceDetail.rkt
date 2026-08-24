#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'VirtualServiceDetail (fhir-spec 'VirtualServiceDetail "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail" 'type)
  #:schema (type-schema 'VirtualServiceDetail #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail"
             (list
    (schema-field 'channelType 0 1 (vector 'type 'Coding) #f "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.channelType" #f)
    (schema-field 'additionalInfo 0 '* (vector 'prim "url") #f "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.additionalInfo" #f)
    (schema-field 'maxParticipants 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.maxParticipants" #f)
    (schema-field 'sessionKey 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.sessionKey" #f)
    (schema-field 'addressUrl 0 1 (vector 'prim "url") 'address "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.address[x]" #f)
    (schema-field 'addressString 0 1 (vector 'prim "string") 'address "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.address[x]" #f)
    (schema-field 'addressContactPoint 0 1 (vector 'type 'ContactPoint) 'address "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.address[x]" #f)
    (schema-field 'addressExtendedContactDetail 0 1 (vector 'type 'ExtendedContactDetail) 'address "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.address[x]" #f)
             ) #f #f))
(register-element! "VirtualServiceDetail.channelType" (fhir-spec (string->symbol "VirtualServiceDetail.channelType") "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.channelType" 'element))
(register-element! "VirtualServiceDetail.additionalInfo" (fhir-spec (string->symbol "VirtualServiceDetail.additionalInfo") "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.additionalInfo" 'element))
(register-element! "VirtualServiceDetail.maxParticipants" (fhir-spec (string->symbol "VirtualServiceDetail.maxParticipants") "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.maxParticipants" 'element))
(register-element! "VirtualServiceDetail.sessionKey" (fhir-spec (string->symbol "VirtualServiceDetail.sessionKey") "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.sessionKey" 'element))
(register-element! "VirtualServiceDetail.address[x]" (fhir-spec (string->symbol "VirtualServiceDetail.address[x]") "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.address[x]" 'element))
(register-element! "VirtualServiceDetail.address[x]" (fhir-spec (string->symbol "VirtualServiceDetail.address[x]") "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.address[x]" 'element))
(register-element! "VirtualServiceDetail.address[x]" (fhir-spec (string->symbol "VirtualServiceDetail.address[x]") "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.address[x]" 'element))
(register-element! "VirtualServiceDetail.address[x]" (fhir-spec (string->symbol "VirtualServiceDetail.address[x]") "https://hl7.org/fhir/R5/datatypes.html#VirtualServiceDetail.address[x]" 'element))

