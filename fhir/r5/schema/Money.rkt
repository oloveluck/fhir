#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Money (fhir-spec 'Money "https://hl7.org/fhir/R5/datatypes.html#Money" 'type)
  #:schema (type-schema 'Money #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#Money"
             (list
    (schema-field 'value 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/datatypes.html#Money.value" #f)
    (schema-field 'currency 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Money.currency" #f)
             ) #f #f))
(register-element! "Money.value" (fhir-spec (string->symbol "Money.value") "https://hl7.org/fhir/R5/datatypes.html#Money.value" 'element))
(register-element! "Money.currency" (fhir-spec (string->symbol "Money.currency") "https://hl7.org/fhir/R5/datatypes.html#Money.currency" 'element))

