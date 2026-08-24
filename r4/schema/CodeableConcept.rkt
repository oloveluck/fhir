#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'CodeableConcept (fhir-spec 'CodeableConcept "https://hl7.org/fhir/R4/datatypes.html#CodeableConcept" 'type)
  #:schema (type-schema 'CodeableConcept #f 'Element "https://hl7.org/fhir/R4/datatypes.html#CodeableConcept"
             (list
    (schema-field 'coding 0 '* (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/datatypes.html#CodeableConcept.coding" #f)
    (schema-field 'text 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#CodeableConcept.text" #f)
             ) #f #f))
(register-element! "CodeableConcept.coding" (fhir-spec (string->symbol "CodeableConcept.coding") "https://hl7.org/fhir/R4/datatypes.html#CodeableConcept.coding" 'element))
(register-element! "CodeableConcept.text" (fhir-spec (string->symbol "CodeableConcept.text") "https://hl7.org/fhir/R4/datatypes.html#CodeableConcept.text" 'element))

