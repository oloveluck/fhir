#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Signature (fhir-spec 'Signature "https://hl7.org/fhir/R4/datatypes.html#Signature" 'type)
  #:schema (type-schema 'Signature #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Signature"
             (list
    (schema-field 'type 1 '* (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/datatypes.html#Signature.type" #f)
    (schema-field 'when 1 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R4/datatypes.html#Signature.when" #f)
    (schema-field 'who 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/datatypes.html#Signature.who" #f)
    (schema-field 'onBehalfOf 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/datatypes.html#Signature.onBehalfOf" #f)
    (schema-field 'targetFormat 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/datatypes.html#Signature.targetFormat" #f)
    (schema-field 'sigFormat 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/datatypes.html#Signature.sigFormat" #f)
    (schema-field 'data 0 1 (vector 'prim "base64Binary") #f "https://hl7.org/fhir/R4/datatypes.html#Signature.data" #f)
             ) #f #f))
(register-element! "Signature.type" (fhir-spec (string->symbol "Signature.type") "https://hl7.org/fhir/R4/datatypes.html#Signature.type" 'element))
(register-element! "Signature.when" (fhir-spec (string->symbol "Signature.when") "https://hl7.org/fhir/R4/datatypes.html#Signature.when" 'element))
(register-element! "Signature.who" (fhir-spec (string->symbol "Signature.who") "https://hl7.org/fhir/R4/datatypes.html#Signature.who" 'element))
(register-element! "Signature.onBehalfOf" (fhir-spec (string->symbol "Signature.onBehalfOf") "https://hl7.org/fhir/R4/datatypes.html#Signature.onBehalfOf" 'element))
(register-element! "Signature.targetFormat" (fhir-spec (string->symbol "Signature.targetFormat") "https://hl7.org/fhir/R4/datatypes.html#Signature.targetFormat" 'element))
(register-element! "Signature.sigFormat" (fhir-spec (string->symbol "Signature.sigFormat") "https://hl7.org/fhir/R4/datatypes.html#Signature.sigFormat" 'element))
(register-element! "Signature.data" (fhir-spec (string->symbol "Signature.data") "https://hl7.org/fhir/R4/datatypes.html#Signature.data" 'element))

