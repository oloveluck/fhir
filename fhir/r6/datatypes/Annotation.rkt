#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide Annotation)
(define-syntax (Annotation stx)
  (build-fhir-form stx 'Annotation
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec time 0 1 #(prim "dateTime") #f)
      #s(field-spec text 1 1 #(prim "markdown") #f)
      #s(field-spec authorReference 0 1 #(type Reference) #f)
      #s(field-spec authorString 0 1 #(prim "string") #f)
      #s(choice-group 0 1 (authorReference authorString))
      )
    #:parent 'DataType))
