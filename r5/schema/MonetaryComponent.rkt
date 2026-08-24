#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MonetaryComponent (fhir-spec 'MonetaryComponent "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent" 'type)
  #:schema (type-schema 'MonetaryComponent #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent.type" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent.code" #f)
    (schema-field 'factor 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent.factor" #f)
    (schema-field 'amount 0 1 (vector 'type 'Money) #f "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent.amount" #f)
             ) #f #f))
(register-element! "MonetaryComponent.type" (fhir-spec (string->symbol "MonetaryComponent.type") "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent.type" 'element))
(register-element! "MonetaryComponent.code" (fhir-spec (string->symbol "MonetaryComponent.code") "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent.code" 'element))
(register-element! "MonetaryComponent.factor" (fhir-spec (string->symbol "MonetaryComponent.factor") "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent.factor" 'element))
(register-element! "MonetaryComponent.amount" (fhir-spec (string->symbol "MonetaryComponent.amount") "https://hl7.org/fhir/R5/datatypes.html#MonetaryComponent.amount" 'element))

