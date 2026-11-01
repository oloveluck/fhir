#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Annotation (fhir-spec 'Annotation "https://build.fhir.org/datatypes.html#Annotation" 'type)
  #:schema (type-schema 'Annotation #f 'DataType "https://build.fhir.org/datatypes.html#Annotation"
             (list
    (schema-field 'time 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/datatypes.html#Annotation.time" #f)
    (schema-field 'text 1 1 (vector 'prim "markdown") #f "https://build.fhir.org/datatypes.html#Annotation.text" #f)
    (schema-field 'authorReference 0 1 (vector 'type 'Reference) 'author "https://build.fhir.org/datatypes.html#Annotation.author[x]" #f)
    (schema-field 'authorString 0 1 (vector 'prim "string") 'author "https://build.fhir.org/datatypes.html#Annotation.author[x]" #f)
             ) #f #f))
(register-element! "Annotation.time" (fhir-spec (string->symbol "Annotation.time") "https://build.fhir.org/datatypes.html#Annotation.time" 'element))
(register-element! "Annotation.text" (fhir-spec (string->symbol "Annotation.text") "https://build.fhir.org/datatypes.html#Annotation.text" 'element))
(register-element! "Annotation.author[x]" (fhir-spec (string->symbol "Annotation.author[x]") "https://build.fhir.org/datatypes.html#Annotation.author[x]" 'element))
(register-element! "Annotation.author[x]" (fhir-spec (string->symbol "Annotation.author[x]") "https://build.fhir.org/datatypes.html#Annotation.author[x]" 'element))

