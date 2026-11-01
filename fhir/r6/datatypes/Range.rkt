#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Range)
(define-syntax (Range stx)
  (build-fhir-form stx 'Range
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec low 0 1 #(type Quantity) #f)
      #s(field-spec high 0 1 #(type Quantity) #f)
      )
    #:parent 'DataType))
