#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Ratio (fhir-spec 'Ratio "https://hl7.org/fhir/R5/datatypes.html#Ratio" 'type)
  #:schema (type-schema 'Ratio #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#Ratio"
             (list
    (schema-field 'numerator 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/datatypes.html#Ratio.numerator" #f)
    (schema-field 'denominator 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/datatypes.html#Ratio.denominator" #f)
             ) #f #f))
(register-element! "Ratio.numerator" (fhir-spec (string->symbol "Ratio.numerator") "https://hl7.org/fhir/R5/datatypes.html#Ratio.numerator" 'element))
(register-element! "Ratio.denominator" (fhir-spec (string->symbol "Ratio.denominator") "https://hl7.org/fhir/R5/datatypes.html#Ratio.denominator" 'element))

