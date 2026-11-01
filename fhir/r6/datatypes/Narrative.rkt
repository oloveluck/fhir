#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Narrative)
(define-syntax (Narrative stx)
  (build-fhir-form stx 'Narrative
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec status 1 1 #(prim "code") (required "http://hl7.org/fhir/ValueSet/narrative-status"))
      #s(field-spec div 1 1 #(prim "xhtml") #f)
      )
    #:parent 'DataType))
