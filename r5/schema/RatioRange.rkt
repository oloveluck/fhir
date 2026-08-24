#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'RatioRange (fhir-spec 'RatioRange "https://hl7.org/fhir/R5/datatypes.html#RatioRange" 'type)
  #:schema (type-schema 'RatioRange #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#RatioRange"
             (list
    (schema-field 'lowNumerator 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/datatypes.html#RatioRange.lowNumerator" #f)
    (schema-field 'highNumerator 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/datatypes.html#RatioRange.highNumerator" #f)
    (schema-field 'denominator 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/datatypes.html#RatioRange.denominator" #f)
             ) #f #f))
(register-element! "RatioRange.lowNumerator" (fhir-spec (string->symbol "RatioRange.lowNumerator") "https://hl7.org/fhir/R5/datatypes.html#RatioRange.lowNumerator" 'element))
(register-element! "RatioRange.highNumerator" (fhir-spec (string->symbol "RatioRange.highNumerator") "https://hl7.org/fhir/R5/datatypes.html#RatioRange.highNumerator" 'element))
(register-element! "RatioRange.denominator" (fhir-spec (string->symbol "RatioRange.denominator") "https://hl7.org/fhir/R5/datatypes.html#RatioRange.denominator" 'element))

