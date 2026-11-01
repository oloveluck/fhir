#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'CodeableConcept (fhir-spec 'CodeableConcept "https://build.fhir.org/datatypes.html#CodeableConcept" 'type)
  #:schema (type-schema 'CodeableConcept #f 'DataType "https://build.fhir.org/datatypes.html#CodeableConcept"
             (list
    (schema-field 'coding 0 '* (vector 'type 'Coding) #f "https://build.fhir.org/datatypes.html#CodeableConcept.coding" #f)
    (schema-field 'text 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#CodeableConcept.text" #f)
             ) #f #f))
(register-element! "CodeableConcept.coding" (fhir-spec (string->symbol "CodeableConcept.coding") "https://build.fhir.org/datatypes.html#CodeableConcept.coding" 'element))
(register-element! "CodeableConcept.text" (fhir-spec (string->symbol "CodeableConcept.text") "https://build.fhir.org/datatypes.html#CodeableConcept.text" 'element))

