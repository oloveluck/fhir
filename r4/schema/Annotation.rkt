#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Annotation (fhir-spec 'Annotation "https://hl7.org/fhir/R4/datatypes.html#Annotation" 'type)
  #:schema (type-schema 'Annotation #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Annotation"
             (list
    (schema-field 'time 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/datatypes.html#Annotation.time" #f)
    (schema-field 'text 1 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/datatypes.html#Annotation.text" #f)
    (schema-field 'authorReference 0 1 (vector 'type 'Reference) 'author "https://hl7.org/fhir/R4/datatypes.html#Annotation.author[x]" #f)
    (schema-field 'authorString 0 1 (vector 'prim "string") 'author "https://hl7.org/fhir/R4/datatypes.html#Annotation.author[x]" #f)
             ) #f #f))
(register-element! "Annotation.time" (fhir-spec (string->symbol "Annotation.time") "https://hl7.org/fhir/R4/datatypes.html#Annotation.time" 'element))
(register-element! "Annotation.text" (fhir-spec (string->symbol "Annotation.text") "https://hl7.org/fhir/R4/datatypes.html#Annotation.text" 'element))
(register-element! "Annotation.author[x]" (fhir-spec (string->symbol "Annotation.author[x]") "https://hl7.org/fhir/R4/datatypes.html#Annotation.author[x]" 'element))
(register-element! "Annotation.author[x]" (fhir-spec (string->symbol "Annotation.author[x]") "https://hl7.org/fhir/R4/datatypes.html#Annotation.author[x]" 'element))

