#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'RatioRange (fhir-spec 'RatioRange "https://build.fhir.org/datatypes.html#RatioRange" 'type)
  #:schema (type-schema 'RatioRange #f 'DataType "https://build.fhir.org/datatypes.html#RatioRange"
             (list
    (schema-field 'lowNumerator 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/datatypes.html#RatioRange.lowNumerator" #f)
    (schema-field 'highNumerator 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/datatypes.html#RatioRange.highNumerator" #f)
    (schema-field 'denominator 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/datatypes.html#RatioRange.denominator" #f)
             ) #f #f))
(register-element! "RatioRange.lowNumerator" (fhir-spec (string->symbol "RatioRange.lowNumerator") "https://build.fhir.org/datatypes.html#RatioRange.lowNumerator" 'element))
(register-element! "RatioRange.highNumerator" (fhir-spec (string->symbol "RatioRange.highNumerator") "https://build.fhir.org/datatypes.html#RatioRange.highNumerator" 'element))
(register-element! "RatioRange.denominator" (fhir-spec (string->symbol "RatioRange.denominator") "https://build.fhir.org/datatypes.html#RatioRange.denominator" 'element))

