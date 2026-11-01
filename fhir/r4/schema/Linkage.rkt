#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Linkage (fhir-spec 'Linkage "https://hl7.org/fhir/R4/linkage.html#Linkage" 'type)
  #:schema (type-schema 'Linkage #f 'DomainResource "https://hl7.org/fhir/R4/linkage.html#Linkage"
             (list
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/linkage.html#Linkage.active" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/linkage.html#Linkage.author" #f)
    (schema-field 'item 1 '* (vector 'type 'LinkageItem) #f "https://hl7.org/fhir/R4/linkage.html#Linkage.item" #f)
             ) #f #f))
(register-element! "Linkage.active" (fhir-spec (string->symbol "Linkage.active") "https://hl7.org/fhir/R4/linkage.html#Linkage.active" 'element))
(register-element! "Linkage.author" (fhir-spec (string->symbol "Linkage.author") "https://hl7.org/fhir/R4/linkage.html#Linkage.author" 'element))
(register-element! "Linkage.item" (fhir-spec (string->symbol "Linkage.item") "https://hl7.org/fhir/R4/linkage.html#Linkage.item" 'element))

(register-type! 'LinkageItem (fhir-spec 'LinkageItem "https://hl7.org/fhir/R4/linkage.html#Linkage.item" 'type)
  #:schema (type-schema 'LinkageItem #f 'BackboneElement "https://hl7.org/fhir/R4/linkage.html#Linkage.item"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/linkage.html#Linkage.item.type" #f)
    (schema-field 'resource 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/linkage.html#Linkage.item.resource" #f)
             ) #f #f))
(register-element! "Linkage.item.type" (fhir-spec (string->symbol "Linkage.item.type") "https://hl7.org/fhir/R4/linkage.html#Linkage.item.type" 'element))
(register-element! "Linkage.item.resource" (fhir-spec (string->symbol "Linkage.item.resource") "https://hl7.org/fhir/R4/linkage.html#Linkage.item.resource" 'element))

