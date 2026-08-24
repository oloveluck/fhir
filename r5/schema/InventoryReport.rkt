#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'InventoryReport (fhir-spec 'InventoryReport "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport" 'type)
  #:schema (type-schema 'InventoryReport #f 'DomainResource "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.status" #f)
    (schema-field 'countType 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.countType" #f)
    (schema-field 'operationType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.operationType" #f)
    (schema-field 'operationTypeReason 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.operationTypeReason" #f)
    (schema-field 'reportedDateTime 1 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.reportedDateTime" #f)
    (schema-field 'reporter 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.reporter" #f)
    (schema-field 'reportingPeriod 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.reportingPeriod" #f)
    (schema-field 'inventoryListing 0 '* (vector 'type 'InventoryReportInventoryListing) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.note" #f)
             ) #f #f))
(register-element! "InventoryReport.identifier" (fhir-spec (string->symbol "InventoryReport.identifier") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.identifier" 'element))
(register-element! "InventoryReport.status" (fhir-spec (string->symbol "InventoryReport.status") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.status" 'element))
(register-element! "InventoryReport.countType" (fhir-spec (string->symbol "InventoryReport.countType") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.countType" 'element))
(register-element! "InventoryReport.operationType" (fhir-spec (string->symbol "InventoryReport.operationType") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.operationType" 'element))
(register-element! "InventoryReport.operationTypeReason" (fhir-spec (string->symbol "InventoryReport.operationTypeReason") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.operationTypeReason" 'element))
(register-element! "InventoryReport.reportedDateTime" (fhir-spec (string->symbol "InventoryReport.reportedDateTime") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.reportedDateTime" 'element))
(register-element! "InventoryReport.reporter" (fhir-spec (string->symbol "InventoryReport.reporter") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.reporter" 'element))
(register-element! "InventoryReport.reportingPeriod" (fhir-spec (string->symbol "InventoryReport.reportingPeriod") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.reportingPeriod" 'element))
(register-element! "InventoryReport.inventoryListing" (fhir-spec (string->symbol "InventoryReport.inventoryListing") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing" 'element))
(register-element! "InventoryReport.note" (fhir-spec (string->symbol "InventoryReport.note") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.note" 'element))

(register-type! 'InventoryReportInventoryListing (fhir-spec 'InventoryReportInventoryListing "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing" 'type)
  #:schema (type-schema 'InventoryReportInventoryListing #f 'BackboneElement "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing"
             (list
    (schema-field 'location 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.location" #f)
    (schema-field 'itemStatus 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.itemStatus" #f)
    (schema-field 'countingDateTime 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.countingDateTime" #f)
    (schema-field 'item 0 '* (vector 'type 'InventoryReportInventoryListingItem) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item" #f)
             ) #f #f))
(register-element! "InventoryReport.inventoryListing.location" (fhir-spec (string->symbol "InventoryReport.inventoryListing.location") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.location" 'element))
(register-element! "InventoryReport.inventoryListing.itemStatus" (fhir-spec (string->symbol "InventoryReport.inventoryListing.itemStatus") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.itemStatus" 'element))
(register-element! "InventoryReport.inventoryListing.countingDateTime" (fhir-spec (string->symbol "InventoryReport.inventoryListing.countingDateTime") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.countingDateTime" 'element))
(register-element! "InventoryReport.inventoryListing.item" (fhir-spec (string->symbol "InventoryReport.inventoryListing.item") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item" 'element))

(register-type! 'InventoryReportInventoryListingItem (fhir-spec 'InventoryReportInventoryListingItem "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item" 'type)
  #:schema (type-schema 'InventoryReportInventoryListingItem #f 'BackboneElement "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item"
             (list
    (schema-field 'category 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item.category" #f)
    (schema-field 'quantity 1 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item.quantity" #f)
    (schema-field 'item 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item.item" #f)
             ) #f #f))
(register-element! "InventoryReport.inventoryListing.item.category" (fhir-spec (string->symbol "InventoryReport.inventoryListing.item.category") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item.category" 'element))
(register-element! "InventoryReport.inventoryListing.item.quantity" (fhir-spec (string->symbol "InventoryReport.inventoryListing.item.quantity") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item.quantity" 'element))
(register-element! "InventoryReport.inventoryListing.item.item" (fhir-spec (string->symbol "InventoryReport.inventoryListing.item.item") "https://hl7.org/fhir/R5/inventoryreport.html#InventoryReport.inventoryListing.item.item" 'element))

