#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Binary (fhir-spec 'Binary "https://build.fhir.org/binary.html#Binary" 'type)
  #:schema (type-schema 'Binary #f 'Resource "https://build.fhir.org/binary.html#Binary"
             (list
    (schema-field 'contentType 1 1 (vector 'prim "code") #f "https://build.fhir.org/binary.html#Binary.contentType" #f)
    (schema-field 'securityContext 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/binary.html#Binary.securityContext" #f)
    (schema-field 'data 0 1 (vector 'prim "base64Binary") #f "https://build.fhir.org/binary.html#Binary.data" #f)
             ) #f #f))
(register-element! "Binary.contentType" (fhir-spec (string->symbol "Binary.contentType") "https://build.fhir.org/binary.html#Binary.contentType" 'element))
(register-element! "Binary.securityContext" (fhir-spec (string->symbol "Binary.securityContext") "https://build.fhir.org/binary.html#Binary.securityContext" 'element))
(register-element! "Binary.data" (fhir-spec (string->symbol "Binary.data") "https://build.fhir.org/binary.html#Binary.data" 'element))

