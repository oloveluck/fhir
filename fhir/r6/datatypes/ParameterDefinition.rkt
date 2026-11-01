#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide ParameterDefinition)
(define-syntax (ParameterDefinition stx)
  (build-fhir-form stx 'ParameterDefinition
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec name 0 1 #(prim "code") #f)
      #s(field-spec use 1 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/operation-parameter-use"))
      #s(field-spec min 0 1 #(prim "integer") #f)
      #s(field-spec max 0 1 #(prim "string") #f)
      #s(field-spec documentation 0 1 #(prim "string") #f)
      #s(field-spec type 1 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/fhir-types"))
      #s(field-spec profile 0 1 #(prim "canonical") #f)
      )
    #:parent 'DataType))
