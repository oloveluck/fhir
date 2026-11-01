#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Ratio (fhir-spec 'Ratio "https://build.fhir.org/datatypes.html#Ratio" 'type)
  #:schema (type-schema 'Ratio #f 'DataType "https://build.fhir.org/datatypes.html#Ratio"
             (list
    (schema-field 'numerator 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/datatypes.html#Ratio.numerator" #f)
    (schema-field 'denominator 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/datatypes.html#Ratio.denominator" #f)
             ) #f #f))
(register-element! "Ratio.numerator" (fhir-spec (string->symbol "Ratio.numerator") "https://build.fhir.org/datatypes.html#Ratio.numerator" 'element))
(register-element! "Ratio.denominator" (fhir-spec (string->symbol "Ratio.denominator") "https://build.fhir.org/datatypes.html#Ratio.denominator" 'element))

