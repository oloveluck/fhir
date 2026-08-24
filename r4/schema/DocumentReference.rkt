#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DocumentReference (fhir-spec 'DocumentReference "https://hl7.org/fhir/R4/documentreference.html#DocumentReference" 'type)
  #:schema (type-schema 'DocumentReference #f 'DomainResource "https://hl7.org/fhir/R4/documentreference.html#DocumentReference"
             (list
    (schema-field 'masterIdentifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.masterIdentifier" #f)
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.status" #f)
    (schema-field 'docStatus 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.docStatus" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.type" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.category" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.subject" #f)
    (schema-field 'date 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.date" #f)
    (schema-field 'author 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.author" #f)
    (schema-field 'authenticator 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.authenticator" #f)
    (schema-field 'custodian 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.custodian" #f)
    (schema-field 'relatesTo 0 '* (vector 'type 'DocumentReferenceRelatesTo) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.relatesTo" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.description" #f)
    (schema-field 'securityLabel 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.securityLabel" #f)
    (schema-field 'content 1 '* (vector 'type 'DocumentReferenceContent) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.content" #f)
    (schema-field 'context 0 1 (vector 'type 'DocumentReferenceContext) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context" #f)
             ) #f #f))
(register-element! "DocumentReference.masterIdentifier" (fhir-spec (string->symbol "DocumentReference.masterIdentifier") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.masterIdentifier" 'element))
(register-element! "DocumentReference.identifier" (fhir-spec (string->symbol "DocumentReference.identifier") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.identifier" 'element))
(register-element! "DocumentReference.status" (fhir-spec (string->symbol "DocumentReference.status") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.status" 'element))
(register-element! "DocumentReference.docStatus" (fhir-spec (string->symbol "DocumentReference.docStatus") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.docStatus" 'element))
(register-element! "DocumentReference.type" (fhir-spec (string->symbol "DocumentReference.type") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.type" 'element))
(register-element! "DocumentReference.category" (fhir-spec (string->symbol "DocumentReference.category") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.category" 'element))
(register-element! "DocumentReference.subject" (fhir-spec (string->symbol "DocumentReference.subject") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.subject" 'element))
(register-element! "DocumentReference.date" (fhir-spec (string->symbol "DocumentReference.date") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.date" 'element))
(register-element! "DocumentReference.author" (fhir-spec (string->symbol "DocumentReference.author") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.author" 'element))
(register-element! "DocumentReference.authenticator" (fhir-spec (string->symbol "DocumentReference.authenticator") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.authenticator" 'element))
(register-element! "DocumentReference.custodian" (fhir-spec (string->symbol "DocumentReference.custodian") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.custodian" 'element))
(register-element! "DocumentReference.relatesTo" (fhir-spec (string->symbol "DocumentReference.relatesTo") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.relatesTo" 'element))
(register-element! "DocumentReference.description" (fhir-spec (string->symbol "DocumentReference.description") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.description" 'element))
(register-element! "DocumentReference.securityLabel" (fhir-spec (string->symbol "DocumentReference.securityLabel") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.securityLabel" 'element))
(register-element! "DocumentReference.content" (fhir-spec (string->symbol "DocumentReference.content") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.content" 'element))
(register-element! "DocumentReference.context" (fhir-spec (string->symbol "DocumentReference.context") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context" 'element))

(register-type! 'DocumentReferenceRelatesTo (fhir-spec 'DocumentReferenceRelatesTo "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.relatesTo" 'type)
  #:schema (type-schema 'DocumentReferenceRelatesTo #f 'BackboneElement "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.relatesTo"
             (list
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.relatesTo.code" #f)
    (schema-field 'target 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.relatesTo.target" #f)
             ) #f #f))
(register-element! "DocumentReference.relatesTo.code" (fhir-spec (string->symbol "DocumentReference.relatesTo.code") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.relatesTo.code" 'element))
(register-element! "DocumentReference.relatesTo.target" (fhir-spec (string->symbol "DocumentReference.relatesTo.target") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.relatesTo.target" 'element))

(register-type! 'DocumentReferenceContent (fhir-spec 'DocumentReferenceContent "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.content" 'type)
  #:schema (type-schema 'DocumentReferenceContent #f 'BackboneElement "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.content"
             (list
    (schema-field 'attachment 1 1 (vector 'type 'Attachment) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.content.attachment" #f)
    (schema-field 'format 0 1 (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.content.format" #f)
             ) #f #f))
(register-element! "DocumentReference.content.attachment" (fhir-spec (string->symbol "DocumentReference.content.attachment") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.content.attachment" 'element))
(register-element! "DocumentReference.content.format" (fhir-spec (string->symbol "DocumentReference.content.format") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.content.format" 'element))

(register-type! 'DocumentReferenceContext (fhir-spec 'DocumentReferenceContext "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context" 'type)
  #:schema (type-schema 'DocumentReferenceContext #f 'BackboneElement "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context"
             (list
    (schema-field 'encounter 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.encounter" #f)
    (schema-field 'event 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.event" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.period" #f)
    (schema-field 'facilityType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.facilityType" #f)
    (schema-field 'practiceSetting 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.practiceSetting" #f)
    (schema-field 'sourcePatientInfo 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.sourcePatientInfo" #f)
    (schema-field 'related 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.related" #f)
             ) #f #f))
(register-element! "DocumentReference.context.encounter" (fhir-spec (string->symbol "DocumentReference.context.encounter") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.encounter" 'element))
(register-element! "DocumentReference.context.event" (fhir-spec (string->symbol "DocumentReference.context.event") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.event" 'element))
(register-element! "DocumentReference.context.period" (fhir-spec (string->symbol "DocumentReference.context.period") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.period" 'element))
(register-element! "DocumentReference.context.facilityType" (fhir-spec (string->symbol "DocumentReference.context.facilityType") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.facilityType" 'element))
(register-element! "DocumentReference.context.practiceSetting" (fhir-spec (string->symbol "DocumentReference.context.practiceSetting") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.practiceSetting" 'element))
(register-element! "DocumentReference.context.sourcePatientInfo" (fhir-spec (string->symbol "DocumentReference.context.sourcePatientInfo") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.sourcePatientInfo" 'element))
(register-element! "DocumentReference.context.related" (fhir-spec (string->symbol "DocumentReference.context.related") "https://hl7.org/fhir/R4/documentreference.html#DocumentReference.context.related" 'element))

