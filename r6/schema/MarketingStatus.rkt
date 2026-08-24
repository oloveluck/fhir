#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MarketingStatus (fhir-spec 'MarketingStatus "https://build.fhir.org/datatypes.html#MarketingStatus" 'type)
  #:schema (type-schema 'MarketingStatus #f 'BackboneType "https://build.fhir.org/datatypes.html#MarketingStatus"
             (list
    (schema-field 'country 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/datatypes.html#MarketingStatus.country" #f)
    (schema-field 'jurisdiction 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/datatypes.html#MarketingStatus.jurisdiction" #f)
    (schema-field 'status 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/datatypes.html#MarketingStatus.status" #f)
    (schema-field 'dateRange 0 1 (vector 'type 'Period) #f "https://build.fhir.org/datatypes.html#MarketingStatus.dateRange" #f)
    (schema-field 'restoreDate 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/datatypes.html#MarketingStatus.restoreDate" #f)
             ) #f #f))
(register-element! "MarketingStatus.country" (fhir-spec (string->symbol "MarketingStatus.country") "https://build.fhir.org/datatypes.html#MarketingStatus.country" 'element))
(register-element! "MarketingStatus.jurisdiction" (fhir-spec (string->symbol "MarketingStatus.jurisdiction") "https://build.fhir.org/datatypes.html#MarketingStatus.jurisdiction" 'element))
(register-element! "MarketingStatus.status" (fhir-spec (string->symbol "MarketingStatus.status") "https://build.fhir.org/datatypes.html#MarketingStatus.status" 'element))
(register-element! "MarketingStatus.dateRange" (fhir-spec (string->symbol "MarketingStatus.dateRange") "https://build.fhir.org/datatypes.html#MarketingStatus.dateRange" 'element))
(register-element! "MarketingStatus.restoreDate" (fhir-spec (string->symbol "MarketingStatus.restoreDate") "https://build.fhir.org/datatypes.html#MarketingStatus.restoreDate" 'element))

