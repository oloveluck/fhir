#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Identifier)
(define-syntax (Identifier stx)
  (build-fhir-form stx 'Identifier
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec use 0 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/identifier-use"))
      #s(field-spec type 0 1 #(type CodeableConcept) #f)
      #s(field-spec system 0 1 #(prim "uri") #f)
      #s(field-spec value 0 1 #(prim "string") #f)
      #s(field-spec period 0 1 #(type Period) #f)
      #s(field-spec assigner 0 1 #(type Reference) #f)
      )
    #:parent 'DataType))
