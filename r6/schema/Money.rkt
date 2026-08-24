#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Money (fhir-spec 'Money "https://build.fhir.org/datatypes.html#Money" 'type)
  #:schema (type-schema 'Money #f 'DataType "https://build.fhir.org/datatypes.html#Money"
             (list
    (schema-field 'value 0 1 (vector 'prim "decimal") #f "https://build.fhir.org/datatypes.html#Money.value" #f)
    (schema-field 'currency 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Money.currency" #f)
             ) #f #f))
(register-element! "Money.value" (fhir-spec (string->symbol "Money.value") "https://build.fhir.org/datatypes.html#Money.value" 'element))
(register-element! "Money.currency" (fhir-spec (string->symbol "Money.currency") "https://build.fhir.org/datatypes.html#Money.currency" 'element))

