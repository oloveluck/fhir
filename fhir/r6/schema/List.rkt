#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'List (fhir-spec 'List "https://build.fhir.org/list.html#List" 'type)
  #:schema (type-schema 'List #f 'DomainResource "https://build.fhir.org/list.html#List"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/list.html#List.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/list.html#List.status" #f)
    (schema-field 'mode 1 1 (vector 'prim "code") #f "https://build.fhir.org/list.html#List.mode" #f)
    (schema-field 'title 0 1 (vector 'prim "string") #f "https://build.fhir.org/list.html#List.title" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/list.html#List.code" #f)
    (schema-field 'subject 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/list.html#List.subject" #f)
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/list.html#List.encounter" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/list.html#List.date" #f)
    (schema-field 'source 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/list.html#List.source" #f)
    (schema-field 'orderedBy 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/list.html#List.orderedBy" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://build.fhir.org/list.html#List.note" #f)
    (schema-field 'entry 0 '* (vector 'type 'ListEntry) #f "https://build.fhir.org/list.html#List.entry" #f)
    (schema-field 'emptyReason 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/list.html#List.emptyReason" #f)
             ) #f #f))
(register-element! "List.identifier" (fhir-spec (string->symbol "List.identifier") "https://build.fhir.org/list.html#List.identifier" 'element))
(register-element! "List.status" (fhir-spec (string->symbol "List.status") "https://build.fhir.org/list.html#List.status" 'element))
(register-element! "List.mode" (fhir-spec (string->symbol "List.mode") "https://build.fhir.org/list.html#List.mode" 'element))
(register-element! "List.title" (fhir-spec (string->symbol "List.title") "https://build.fhir.org/list.html#List.title" 'element))
(register-element! "List.code" (fhir-spec (string->symbol "List.code") "https://build.fhir.org/list.html#List.code" 'element))
(register-element! "List.subject" (fhir-spec (string->symbol "List.subject") "https://build.fhir.org/list.html#List.subject" 'element))
(register-element! "List.encounter" (fhir-spec (string->symbol "List.encounter") "https://build.fhir.org/list.html#List.encounter" 'element))
(register-element! "List.date" (fhir-spec (string->symbol "List.date") "https://build.fhir.org/list.html#List.date" 'element))
(register-element! "List.source" (fhir-spec (string->symbol "List.source") "https://build.fhir.org/list.html#List.source" 'element))
(register-element! "List.orderedBy" (fhir-spec (string->symbol "List.orderedBy") "https://build.fhir.org/list.html#List.orderedBy" 'element))
(register-element! "List.note" (fhir-spec (string->symbol "List.note") "https://build.fhir.org/list.html#List.note" 'element))
(register-element! "List.entry" (fhir-spec (string->symbol "List.entry") "https://build.fhir.org/list.html#List.entry" 'element))
(register-element! "List.emptyReason" (fhir-spec (string->symbol "List.emptyReason") "https://build.fhir.org/list.html#List.emptyReason" 'element))

(register-type! 'ListEntry (fhir-spec 'ListEntry "https://build.fhir.org/list.html#List.entry" 'type)
  #:schema (type-schema 'ListEntry #f 'BackboneElement "https://build.fhir.org/list.html#List.entry"
             (list
    (schema-field 'flag 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/list.html#List.entry.flag" #f)
    (schema-field 'deleted 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/list.html#List.entry.deleted" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/list.html#List.entry.date" #f)
    (schema-field 'item 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/list.html#List.entry.item" #f)
             ) #f #f))
(register-element! "List.entry.flag" (fhir-spec (string->symbol "List.entry.flag") "https://build.fhir.org/list.html#List.entry.flag" 'element))
(register-element! "List.entry.deleted" (fhir-spec (string->symbol "List.entry.deleted") "https://build.fhir.org/list.html#List.entry.deleted" 'element))
(register-element! "List.entry.date" (fhir-spec (string->symbol "List.entry.date") "https://build.fhir.org/list.html#List.entry.date" 'element))
(register-element! "List.entry.item" (fhir-spec (string->symbol "List.entry.item") "https://build.fhir.org/list.html#List.entry.item" 'element))

