#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DocumentManifest (fhir-spec 'DocumentManifest "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest" 'type)
  #:schema (type-schema 'DocumentManifest #f 'DomainResource "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest"
             (list
    (schema-field 'masterIdentifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.masterIdentifier" #f)
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.status" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.type" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.subject" #f)
    (schema-field 'created 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.created" #f)
    (schema-field 'author 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.author" #f)
    (schema-field 'recipient 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.recipient" #f)
    (schema-field 'source 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.source" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.description" #f)
    (schema-field 'content 1 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.content" #f)
    (schema-field 'related 0 '* (vector 'type 'DocumentManifestRelated) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.related" #f)
             ) #f #f))
(register-element! "DocumentManifest.masterIdentifier" (fhir-spec (string->symbol "DocumentManifest.masterIdentifier") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.masterIdentifier" 'element))
(register-element! "DocumentManifest.identifier" (fhir-spec (string->symbol "DocumentManifest.identifier") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.identifier" 'element))
(register-element! "DocumentManifest.status" (fhir-spec (string->symbol "DocumentManifest.status") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.status" 'element))
(register-element! "DocumentManifest.type" (fhir-spec (string->symbol "DocumentManifest.type") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.type" 'element))
(register-element! "DocumentManifest.subject" (fhir-spec (string->symbol "DocumentManifest.subject") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.subject" 'element))
(register-element! "DocumentManifest.created" (fhir-spec (string->symbol "DocumentManifest.created") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.created" 'element))
(register-element! "DocumentManifest.author" (fhir-spec (string->symbol "DocumentManifest.author") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.author" 'element))
(register-element! "DocumentManifest.recipient" (fhir-spec (string->symbol "DocumentManifest.recipient") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.recipient" 'element))
(register-element! "DocumentManifest.source" (fhir-spec (string->symbol "DocumentManifest.source") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.source" 'element))
(register-element! "DocumentManifest.description" (fhir-spec (string->symbol "DocumentManifest.description") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.description" 'element))
(register-element! "DocumentManifest.content" (fhir-spec (string->symbol "DocumentManifest.content") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.content" 'element))
(register-element! "DocumentManifest.related" (fhir-spec (string->symbol "DocumentManifest.related") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.related" 'element))

(register-type! 'DocumentManifestRelated (fhir-spec 'DocumentManifestRelated "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.related" 'type)
  #:schema (type-schema 'DocumentManifestRelated #f 'BackboneElement "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.related"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.related.identifier" #f)
    (schema-field 'ref 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.related.ref" #f)
             ) #f #f))
(register-element! "DocumentManifest.related.identifier" (fhir-spec (string->symbol "DocumentManifest.related.identifier") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.related.identifier" 'element))
(register-element! "DocumentManifest.related.ref" (fhir-spec (string->symbol "DocumentManifest.related.ref") "https://hl7.org/fhir/R4/documentmanifest.html#DocumentManifest.related.ref" 'element))

