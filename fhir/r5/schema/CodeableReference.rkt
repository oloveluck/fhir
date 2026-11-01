#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'CodeableReference (fhir-spec 'CodeableReference "https://hl7.org/fhir/R5/datatypes.html#CodeableReference" 'type)
  #:schema (type-schema 'CodeableReference #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#CodeableReference"
             (list
    (schema-field 'concept 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#CodeableReference.concept" #f)
    (schema-field 'reference 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/datatypes.html#CodeableReference.reference" #f)
             ) #f #f))
(register-element! "CodeableReference.concept" (fhir-spec (string->symbol "CodeableReference.concept") "https://hl7.org/fhir/R5/datatypes.html#CodeableReference.concept" 'element))
(register-element! "CodeableReference.reference" (fhir-spec (string->symbol "CodeableReference.reference") "https://hl7.org/fhir/R5/datatypes.html#CodeableReference.reference" 'element))

