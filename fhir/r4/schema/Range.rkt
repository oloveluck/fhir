#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Range (fhir-spec 'Range "https://hl7.org/fhir/R4/datatypes.html#Range" 'type)
  #:schema (type-schema 'Range #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Range"
             (list
    (schema-field 'low 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#Range.low" #f)
    (schema-field 'high 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#Range.high" #f)
             ) #f #f))
(register-element! "Range.low" (fhir-spec (string->symbol "Range.low") "https://hl7.org/fhir/R4/datatypes.html#Range.low" 'element))
(register-element! "Range.high" (fhir-spec (string->symbol "Range.high") "https://hl7.org/fhir/R4/datatypes.html#Range.high" 'element))

