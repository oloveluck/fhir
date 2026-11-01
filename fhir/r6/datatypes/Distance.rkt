#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Distance)
(define-syntax (Distance stx)
  (build-fhir-form stx 'Distance
    '()
    #:parent 'Quantity))
