#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'CatalogEntry (fhir-spec 'CatalogEntry "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry" 'type)
  #:schema (type-schema 'CatalogEntry #f 'DomainResource "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.identifier" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.type" #f)
    (schema-field 'orderable 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.orderable" #f)
    (schema-field 'referencedItem 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.referencedItem" #f)
    (schema-field 'additionalIdentifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.additionalIdentifier" #f)
    (schema-field 'classification 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.classification" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.status" #f)
    (schema-field 'validityPeriod 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.validityPeriod" #f)
    (schema-field 'validTo 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.validTo" #f)
    (schema-field 'lastUpdated 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.lastUpdated" #f)
    (schema-field 'additionalCharacteristic 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.additionalCharacteristic" #f)
    (schema-field 'additionalClassification 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.additionalClassification" #f)
    (schema-field 'relatedEntry 0 '* (vector 'type 'CatalogEntryRelatedEntry) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.relatedEntry" #f)
             ) #f #f))
(register-element! "CatalogEntry.identifier" (fhir-spec (string->symbol "CatalogEntry.identifier") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.identifier" 'element))
(register-element! "CatalogEntry.type" (fhir-spec (string->symbol "CatalogEntry.type") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.type" 'element))
(register-element! "CatalogEntry.orderable" (fhir-spec (string->symbol "CatalogEntry.orderable") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.orderable" 'element))
(register-element! "CatalogEntry.referencedItem" (fhir-spec (string->symbol "CatalogEntry.referencedItem") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.referencedItem" 'element))
(register-element! "CatalogEntry.additionalIdentifier" (fhir-spec (string->symbol "CatalogEntry.additionalIdentifier") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.additionalIdentifier" 'element))
(register-element! "CatalogEntry.classification" (fhir-spec (string->symbol "CatalogEntry.classification") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.classification" 'element))
(register-element! "CatalogEntry.status" (fhir-spec (string->symbol "CatalogEntry.status") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.status" 'element))
(register-element! "CatalogEntry.validityPeriod" (fhir-spec (string->symbol "CatalogEntry.validityPeriod") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.validityPeriod" 'element))
(register-element! "CatalogEntry.validTo" (fhir-spec (string->symbol "CatalogEntry.validTo") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.validTo" 'element))
(register-element! "CatalogEntry.lastUpdated" (fhir-spec (string->symbol "CatalogEntry.lastUpdated") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.lastUpdated" 'element))
(register-element! "CatalogEntry.additionalCharacteristic" (fhir-spec (string->symbol "CatalogEntry.additionalCharacteristic") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.additionalCharacteristic" 'element))
(register-element! "CatalogEntry.additionalClassification" (fhir-spec (string->symbol "CatalogEntry.additionalClassification") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.additionalClassification" 'element))
(register-element! "CatalogEntry.relatedEntry" (fhir-spec (string->symbol "CatalogEntry.relatedEntry") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.relatedEntry" 'element))

(register-type! 'CatalogEntryRelatedEntry (fhir-spec 'CatalogEntryRelatedEntry "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.relatedEntry" 'type)
  #:schema (type-schema 'CatalogEntryRelatedEntry #f 'BackboneElement "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.relatedEntry"
             (list
    (schema-field 'relationtype 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.relatedEntry.relationtype" #f)
    (schema-field 'item 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.relatedEntry.item" #f)
             ) #f #f))
(register-element! "CatalogEntry.relatedEntry.relationtype" (fhir-spec (string->symbol "CatalogEntry.relatedEntry.relationtype") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.relatedEntry.relationtype" 'element))
(register-element! "CatalogEntry.relatedEntry.item" (fhir-spec (string->symbol "CatalogEntry.relatedEntry.item") "https://hl7.org/fhir/R4/catalogentry.html#CatalogEntry.relatedEntry.item" 'element))

