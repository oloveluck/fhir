#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Range (fhir-spec 'Range "https://build.fhir.org/datatypes.html#Range" 'type)
  #:schema (type-schema 'Range #f 'DataType "https://build.fhir.org/datatypes.html#Range"
             (list
    (schema-field 'low 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/datatypes.html#Range.low" #f)
    (schema-field 'high 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/datatypes.html#Range.high" #f)
             ) #f #f))
(register-element! "Range.low" (fhir-spec (string->symbol "Range.low") "https://build.fhir.org/datatypes.html#Range.low" 'element))
(register-element! "Range.high" (fhir-spec (string->symbol "Range.high") "https://build.fhir.org/datatypes.html#Range.high" 'element))

