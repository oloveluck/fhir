#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DocumentReference (fhir-spec 'DocumentReference "https://build.fhir.org/documentreference.html#DocumentReference" 'type)
  #:schema (type-schema 'DocumentReference #f 'DomainResource "https://build.fhir.org/documentreference.html#DocumentReference"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/documentreference.html#DocumentReference.identifier" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://build.fhir.org/documentreference.html#DocumentReference.version" #f)
    (schema-field 'basedOn 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/documentreference.html#DocumentReference.basedOn" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/documentreference.html#DocumentReference.status" #f)
    (schema-field 'docStatus 0 1 (vector 'prim "code") #f "https://build.fhir.org/documentreference.html#DocumentReference.docStatus" #f)
    (schema-field 'modality 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.modality" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.type" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.category" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/documentreference.html#DocumentReference.subject" #f)
    (schema-field 'context 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/documentreference.html#DocumentReference.context" #f)
    (schema-field 'event 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/documentreference.html#DocumentReference.event" #f)
    (schema-field 'related 0 '* (vector 'type 'DocumentReferenceRelated) #f "https://build.fhir.org/documentreference.html#DocumentReference.related" #f)
    (schema-field 'bodyStructure 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/documentreference.html#DocumentReference.bodyStructure" #f)
    (schema-field 'facilityType 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.facilityType" #f)
    (schema-field 'practiceSetting 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.practiceSetting" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/documentreference.html#DocumentReference.period" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/documentreference.html#DocumentReference.date" #f)
    (schema-field 'author 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/documentreference.html#DocumentReference.author" #f)
    (schema-field 'attester 0 '* (vector 'type 'DocumentReferenceAttester) #f "https://build.fhir.org/documentreference.html#DocumentReference.attester" #f)
    (schema-field 'custodian 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/documentreference.html#DocumentReference.custodian" #f)
    (schema-field 'relatesTo 0 '* (vector 'type 'DocumentReferenceRelatesTo) #f "https://build.fhir.org/documentreference.html#DocumentReference.relatesTo" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://build.fhir.org/documentreference.html#DocumentReference.description" #f)
    (schema-field 'securityLabel 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.securityLabel" #f)
    (schema-field 'content 1 '* (vector 'type 'DocumentReferenceContent) #f "https://build.fhir.org/documentreference.html#DocumentReference.content" #f)
             ) #f #f))
(register-element! "DocumentReference.identifier" (fhir-spec (string->symbol "DocumentReference.identifier") "https://build.fhir.org/documentreference.html#DocumentReference.identifier" 'element))
(register-element! "DocumentReference.version" (fhir-spec (string->symbol "DocumentReference.version") "https://build.fhir.org/documentreference.html#DocumentReference.version" 'element))
(register-element! "DocumentReference.basedOn" (fhir-spec (string->symbol "DocumentReference.basedOn") "https://build.fhir.org/documentreference.html#DocumentReference.basedOn" 'element))
(register-element! "DocumentReference.status" (fhir-spec (string->symbol "DocumentReference.status") "https://build.fhir.org/documentreference.html#DocumentReference.status" 'element))
(register-element! "DocumentReference.docStatus" (fhir-spec (string->symbol "DocumentReference.docStatus") "https://build.fhir.org/documentreference.html#DocumentReference.docStatus" 'element))
(register-element! "DocumentReference.modality" (fhir-spec (string->symbol "DocumentReference.modality") "https://build.fhir.org/documentreference.html#DocumentReference.modality" 'element))
(register-element! "DocumentReference.type" (fhir-spec (string->symbol "DocumentReference.type") "https://build.fhir.org/documentreference.html#DocumentReference.type" 'element))
(register-element! "DocumentReference.category" (fhir-spec (string->symbol "DocumentReference.category") "https://build.fhir.org/documentreference.html#DocumentReference.category" 'element))
(register-element! "DocumentReference.subject" (fhir-spec (string->symbol "DocumentReference.subject") "https://build.fhir.org/documentreference.html#DocumentReference.subject" 'element))
(register-element! "DocumentReference.context" (fhir-spec (string->symbol "DocumentReference.context") "https://build.fhir.org/documentreference.html#DocumentReference.context" 'element))
(register-element! "DocumentReference.event" (fhir-spec (string->symbol "DocumentReference.event") "https://build.fhir.org/documentreference.html#DocumentReference.event" 'element))
(register-element! "DocumentReference.related" (fhir-spec (string->symbol "DocumentReference.related") "https://build.fhir.org/documentreference.html#DocumentReference.related" 'element))
(register-element! "DocumentReference.bodyStructure" (fhir-spec (string->symbol "DocumentReference.bodyStructure") "https://build.fhir.org/documentreference.html#DocumentReference.bodyStructure" 'element))
(register-element! "DocumentReference.facilityType" (fhir-spec (string->symbol "DocumentReference.facilityType") "https://build.fhir.org/documentreference.html#DocumentReference.facilityType" 'element))
(register-element! "DocumentReference.practiceSetting" (fhir-spec (string->symbol "DocumentReference.practiceSetting") "https://build.fhir.org/documentreference.html#DocumentReference.practiceSetting" 'element))
(register-element! "DocumentReference.period" (fhir-spec (string->symbol "DocumentReference.period") "https://build.fhir.org/documentreference.html#DocumentReference.period" 'element))
(register-element! "DocumentReference.date" (fhir-spec (string->symbol "DocumentReference.date") "https://build.fhir.org/documentreference.html#DocumentReference.date" 'element))
(register-element! "DocumentReference.author" (fhir-spec (string->symbol "DocumentReference.author") "https://build.fhir.org/documentreference.html#DocumentReference.author" 'element))
(register-element! "DocumentReference.attester" (fhir-spec (string->symbol "DocumentReference.attester") "https://build.fhir.org/documentreference.html#DocumentReference.attester" 'element))
(register-element! "DocumentReference.custodian" (fhir-spec (string->symbol "DocumentReference.custodian") "https://build.fhir.org/documentreference.html#DocumentReference.custodian" 'element))
(register-element! "DocumentReference.relatesTo" (fhir-spec (string->symbol "DocumentReference.relatesTo") "https://build.fhir.org/documentreference.html#DocumentReference.relatesTo" 'element))
(register-element! "DocumentReference.description" (fhir-spec (string->symbol "DocumentReference.description") "https://build.fhir.org/documentreference.html#DocumentReference.description" 'element))
(register-element! "DocumentReference.securityLabel" (fhir-spec (string->symbol "DocumentReference.securityLabel") "https://build.fhir.org/documentreference.html#DocumentReference.securityLabel" 'element))
(register-element! "DocumentReference.content" (fhir-spec (string->symbol "DocumentReference.content") "https://build.fhir.org/documentreference.html#DocumentReference.content" 'element))

(register-type! 'DocumentReferenceRelated (fhir-spec 'DocumentReferenceRelated "https://build.fhir.org/documentreference.html#DocumentReference.related" 'type)
  #:schema (type-schema 'DocumentReferenceRelated #f 'BackboneElement "https://build.fhir.org/documentreference.html#DocumentReference.related"
             (list
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.related.code" #f)
    (schema-field 'target 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/documentreference.html#DocumentReference.related.target" #f)
             ) #f #f))
(register-element! "DocumentReference.related.code" (fhir-spec (string->symbol "DocumentReference.related.code") "https://build.fhir.org/documentreference.html#DocumentReference.related.code" 'element))
(register-element! "DocumentReference.related.target" (fhir-spec (string->symbol "DocumentReference.related.target") "https://build.fhir.org/documentreference.html#DocumentReference.related.target" 'element))

(register-type! 'DocumentReferenceAttester (fhir-spec 'DocumentReferenceAttester "https://build.fhir.org/documentreference.html#DocumentReference.attester" 'type)
  #:schema (type-schema 'DocumentReferenceAttester #f 'BackboneElement "https://build.fhir.org/documentreference.html#DocumentReference.attester"
             (list
    (schema-field 'mode 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.attester.mode" #f)
    (schema-field 'time 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/documentreference.html#DocumentReference.attester.time" #f)
    (schema-field 'party 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/documentreference.html#DocumentReference.attester.party" #f)
             ) #f #f))
(register-element! "DocumentReference.attester.mode" (fhir-spec (string->symbol "DocumentReference.attester.mode") "https://build.fhir.org/documentreference.html#DocumentReference.attester.mode" 'element))
(register-element! "DocumentReference.attester.time" (fhir-spec (string->symbol "DocumentReference.attester.time") "https://build.fhir.org/documentreference.html#DocumentReference.attester.time" 'element))
(register-element! "DocumentReference.attester.party" (fhir-spec (string->symbol "DocumentReference.attester.party") "https://build.fhir.org/documentreference.html#DocumentReference.attester.party" 'element))

(register-type! 'DocumentReferenceRelatesTo (fhir-spec 'DocumentReferenceRelatesTo "https://build.fhir.org/documentreference.html#DocumentReference.relatesTo" 'type)
  #:schema (type-schema 'DocumentReferenceRelatesTo #f 'BackboneElement "https://build.fhir.org/documentreference.html#DocumentReference.relatesTo"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/documentreference.html#DocumentReference.relatesTo.code" #f)
    (schema-field 'target 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/documentreference.html#DocumentReference.relatesTo.target" #f)
             ) #f #f))
(register-element! "DocumentReference.relatesTo.code" (fhir-spec (string->symbol "DocumentReference.relatesTo.code") "https://build.fhir.org/documentreference.html#DocumentReference.relatesTo.code" 'element))
(register-element! "DocumentReference.relatesTo.target" (fhir-spec (string->symbol "DocumentReference.relatesTo.target") "https://build.fhir.org/documentreference.html#DocumentReference.relatesTo.target" 'element))

(register-type! 'DocumentReferenceContent (fhir-spec 'DocumentReferenceContent "https://build.fhir.org/documentreference.html#DocumentReference.content" 'type)
  #:schema (type-schema 'DocumentReferenceContent #f 'BackboneElement "https://build.fhir.org/documentreference.html#DocumentReference.content"
             (list
    (schema-field 'attachment 1 1 (vector 'type 'Attachment) #f "https://build.fhir.org/documentreference.html#DocumentReference.content.attachment" #f)
    (schema-field 'profile 0 '* (vector 'type 'DocumentReferenceContentProfile) #f "https://build.fhir.org/documentreference.html#DocumentReference.content.profile" #f)
             ) #f #f))
(register-element! "DocumentReference.content.attachment" (fhir-spec (string->symbol "DocumentReference.content.attachment") "https://build.fhir.org/documentreference.html#DocumentReference.content.attachment" 'element))
(register-element! "DocumentReference.content.profile" (fhir-spec (string->symbol "DocumentReference.content.profile") "https://build.fhir.org/documentreference.html#DocumentReference.content.profile" 'element))

(register-type! 'DocumentReferenceContentProfile (fhir-spec 'DocumentReferenceContentProfile "https://build.fhir.org/documentreference.html#DocumentReference.content.profile" 'type)
  #:schema (type-schema 'DocumentReferenceContentProfile #f 'BackboneElement "https://build.fhir.org/documentreference.html#DocumentReference.content.profile"
             (list
    (schema-field 'valueCoding 0 1 (vector 'type 'Coding) 'value "https://build.fhir.org/documentreference.html#DocumentReference.content.profile.value[x]" #f)
    (schema-field 'valueUri 0 1 (vector 'prim "uri") 'value "https://build.fhir.org/documentreference.html#DocumentReference.content.profile.value[x]" #f)
    (schema-field 'valueCanonical 0 1 (vector 'prim "canonical") 'value "https://build.fhir.org/documentreference.html#DocumentReference.content.profile.value[x]" #f)
             ) #f #f))
(register-element! "DocumentReference.content.profile.value[x]" (fhir-spec (string->symbol "DocumentReference.content.profile.value[x]") "https://build.fhir.org/documentreference.html#DocumentReference.content.profile.value[x]" 'element))
(register-element! "DocumentReference.content.profile.value[x]" (fhir-spec (string->symbol "DocumentReference.content.profile.value[x]") "https://build.fhir.org/documentreference.html#DocumentReference.content.profile.value[x]" 'element))
(register-element! "DocumentReference.content.profile.value[x]" (fhir-spec (string->symbol "DocumentReference.content.profile.value[x]") "https://build.fhir.org/documentreference.html#DocumentReference.content.profile.value[x]" 'element))

