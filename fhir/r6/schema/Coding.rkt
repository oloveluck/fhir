#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Coding (fhir-spec 'Coding "https://build.fhir.org/datatypes.html#Coding" 'type)
  #:schema (type-schema 'Coding #f 'DataType "https://build.fhir.org/datatypes.html#Coding"
             (list
    (schema-field 'system 0 1 (vector 'prim "uri") #f "https://build.fhir.org/datatypes.html#Coding.system" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Coding.version" #f)
    (schema-field 'code 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Coding.code" #f)
    (schema-field 'display 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Coding.display" #f)
    (schema-field 'userSelected 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/datatypes.html#Coding.userSelected" #f)
             ) #f #f))
(register-element! "Coding.system" (fhir-spec (string->symbol "Coding.system") "https://build.fhir.org/datatypes.html#Coding.system" 'element))
(register-element! "Coding.version" (fhir-spec (string->symbol "Coding.version") "https://build.fhir.org/datatypes.html#Coding.version" 'element))
(register-element! "Coding.code" (fhir-spec (string->symbol "Coding.code") "https://build.fhir.org/datatypes.html#Coding.code" 'element))
(register-element! "Coding.display" (fhir-spec (string->symbol "Coding.display") "https://build.fhir.org/datatypes.html#Coding.display" 'element))
(register-element! "Coding.userSelected" (fhir-spec (string->symbol "Coding.userSelected") "https://build.fhir.org/datatypes.html#Coding.userSelected" 'element))

