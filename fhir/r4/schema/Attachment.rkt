#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Attachment (fhir-spec 'Attachment "https://hl7.org/fhir/R4/datatypes.html#Attachment" 'type)
  #:schema (type-schema 'Attachment #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Attachment"
             (list
    (schema-field 'contentType 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/datatypes.html#Attachment.contentType" #f)
    (schema-field 'language 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/datatypes.html#Attachment.language" #f)
    (schema-field 'data 0 1 (vector 'prim "base64Binary") #f "https://hl7.org/fhir/R4/datatypes.html#Attachment.data" #f)
    (schema-field 'url 0 1 (vector 'prim "url") #f "https://hl7.org/fhir/R4/datatypes.html#Attachment.url" #f)
    (schema-field 'size 0 1 (vector 'prim "unsignedInt") #f "https://hl7.org/fhir/R4/datatypes.html#Attachment.size" #f)
    (schema-field 'hash 0 1 (vector 'prim "base64Binary") #f "https://hl7.org/fhir/R4/datatypes.html#Attachment.hash" #f)
    (schema-field 'title 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#Attachment.title" #f)
    (schema-field 'creation 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/datatypes.html#Attachment.creation" #f)
             ) #f #f))
(register-element! "Attachment.contentType" (fhir-spec (string->symbol "Attachment.contentType") "https://hl7.org/fhir/R4/datatypes.html#Attachment.contentType" 'element))
(register-element! "Attachment.language" (fhir-spec (string->symbol "Attachment.language") "https://hl7.org/fhir/R4/datatypes.html#Attachment.language" 'element))
(register-element! "Attachment.data" (fhir-spec (string->symbol "Attachment.data") "https://hl7.org/fhir/R4/datatypes.html#Attachment.data" 'element))
(register-element! "Attachment.url" (fhir-spec (string->symbol "Attachment.url") "https://hl7.org/fhir/R4/datatypes.html#Attachment.url" 'element))
(register-element! "Attachment.size" (fhir-spec (string->symbol "Attachment.size") "https://hl7.org/fhir/R4/datatypes.html#Attachment.size" 'element))
(register-element! "Attachment.hash" (fhir-spec (string->symbol "Attachment.hash") "https://hl7.org/fhir/R4/datatypes.html#Attachment.hash" 'element))
(register-element! "Attachment.title" (fhir-spec (string->symbol "Attachment.title") "https://hl7.org/fhir/R4/datatypes.html#Attachment.title" 'element))
(register-element! "Attachment.creation" (fhir-spec (string->symbol "Attachment.creation") "https://hl7.org/fhir/R4/datatypes.html#Attachment.creation" 'element))

