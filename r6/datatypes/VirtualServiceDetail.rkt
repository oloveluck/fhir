#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require (for-syntax racket/base fhir/lang-gen/form-syntax))
(provide VirtualServiceDetail)
(define-syntax (VirtualServiceDetail stx)
  (build-fhir-form stx 'VirtualServiceDetail
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec extension 0 * #(type Extension) #f)
      #s(field-spec channelType 0 1 #(type Coding) #f)
      #s(field-spec additionalInfo 0 * #(prim "url") #f)
      #s(field-spec maxParticipants 0 1 #(prim "positiveInt") #f)
      #s(field-spec sessionKey 0 1 #(prim "string") #f)
      #s(field-spec addressUrl 0 1 #(prim "url") #f)
      #s(field-spec addressString 0 1 #(prim "string") #f)
      #s(field-spec addressContactPoint 0 1 #(type ContactPoint) #f)
      #s(field-spec addressExtendedContactDetail 0 1 #(type ExtendedContactDetail) #f)
      #s(choice-group 0 1 (addressUrl addressString addressContactPoint addressExtendedContactDetail))
      )
    #:parent 'DataType))
