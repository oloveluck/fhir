#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Coding (fhir-spec 'Coding "https://hl7.org/fhir/R5/datatypes.html#Coding" 'type)
  #:schema (type-schema 'Coding #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#Coding"
             (list
    (schema-field 'system 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/datatypes.html#Coding.system" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Coding.version" #f)
    (schema-field 'code 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Coding.code" #f)
    (schema-field 'display 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Coding.display" #f)
    (schema-field 'userSelected 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/datatypes.html#Coding.userSelected" #f)
             ) #f #f))
(register-element! "Coding.system" (fhir-spec (string->symbol "Coding.system") "https://hl7.org/fhir/R5/datatypes.html#Coding.system" 'element))
(register-element! "Coding.version" (fhir-spec (string->symbol "Coding.version") "https://hl7.org/fhir/R5/datatypes.html#Coding.version" 'element))
(register-element! "Coding.code" (fhir-spec (string->symbol "Coding.code") "https://hl7.org/fhir/R5/datatypes.html#Coding.code" 'element))
(register-element! "Coding.display" (fhir-spec (string->symbol "Coding.display") "https://hl7.org/fhir/R5/datatypes.html#Coding.display" 'element))
(register-element! "Coding.userSelected" (fhir-spec (string->symbol "Coding.userSelected") "https://hl7.org/fhir/R5/datatypes.html#Coding.userSelected" 'element))

