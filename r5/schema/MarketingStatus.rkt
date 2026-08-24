#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MarketingStatus (fhir-spec 'MarketingStatus "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus" 'type)
  #:schema (type-schema 'MarketingStatus #f 'BackboneType "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus"
             (list
    (schema-field 'country 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.country" #f)
    (schema-field 'jurisdiction 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.jurisdiction" #f)
    (schema-field 'status 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.status" #f)
    (schema-field 'dateRange 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.dateRange" #f)
    (schema-field 'restoreDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.restoreDate" #f)
             ) #f #f))
(register-element! "MarketingStatus.country" (fhir-spec (string->symbol "MarketingStatus.country") "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.country" 'element))
(register-element! "MarketingStatus.jurisdiction" (fhir-spec (string->symbol "MarketingStatus.jurisdiction") "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.jurisdiction" 'element))
(register-element! "MarketingStatus.status" (fhir-spec (string->symbol "MarketingStatus.status") "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.status" 'element))
(register-element! "MarketingStatus.dateRange" (fhir-spec (string->symbol "MarketingStatus.dateRange") "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.dateRange" 'element))
(register-element! "MarketingStatus.restoreDate" (fhir-spec (string->symbol "MarketingStatus.restoreDate") "https://hl7.org/fhir/R5/datatypes.html#MarketingStatus.restoreDate" 'element))

