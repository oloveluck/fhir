#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'CodeableReference (fhir-spec 'CodeableReference "https://build.fhir.org/datatypes.html#CodeableReference" 'type)
  #:schema (type-schema 'CodeableReference #f 'DataType "https://build.fhir.org/datatypes.html#CodeableReference"
             (list
    (schema-field 'concept 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/datatypes.html#CodeableReference.concept" #f)
    (schema-field 'reference 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/datatypes.html#CodeableReference.reference" #f)
             ) #f #f))
(register-element! "CodeableReference.concept" (fhir-spec (string->symbol "CodeableReference.concept") "https://build.fhir.org/datatypes.html#CodeableReference.concept" 'element))
(register-element! "CodeableReference.reference" (fhir-spec (string->symbol "CodeableReference.reference") "https://build.fhir.org/datatypes.html#CodeableReference.reference" 'element))

