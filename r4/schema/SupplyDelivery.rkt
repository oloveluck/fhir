#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SupplyDelivery (fhir-spec 'SupplyDelivery "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery" 'type)
  #:schema (type-schema 'SupplyDelivery #f 'DomainResource "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.identifier" #f)
    (schema-field 'basedOn 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.basedOn" #f)
    (schema-field 'partOf 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.partOf" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.status" #f)
    (schema-field 'patient 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.patient" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.type" #f)
    (schema-field 'suppliedItem 0 1 (vector 'type 'SupplyDeliverySuppliedItem) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem" #f)
    (schema-field 'supplier 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.supplier" #f)
    (schema-field 'destination 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.destination" #f)
    (schema-field 'receiver 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.receiver" #f)
    (schema-field 'occurrenceDateTime 0 1 (vector 'prim "dateTime") 'occurrence "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.occurrence[x]" #f)
    (schema-field 'occurrencePeriod 0 1 (vector 'type 'Period) 'occurrence "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.occurrence[x]" #f)
    (schema-field 'occurrenceTiming 0 1 (vector 'type 'Timing) 'occurrence "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.occurrence[x]" #f)
             ) #f #f))
(register-element! "SupplyDelivery.identifier" (fhir-spec (string->symbol "SupplyDelivery.identifier") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.identifier" 'element))
(register-element! "SupplyDelivery.basedOn" (fhir-spec (string->symbol "SupplyDelivery.basedOn") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.basedOn" 'element))
(register-element! "SupplyDelivery.partOf" (fhir-spec (string->symbol "SupplyDelivery.partOf") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.partOf" 'element))
(register-element! "SupplyDelivery.status" (fhir-spec (string->symbol "SupplyDelivery.status") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.status" 'element))
(register-element! "SupplyDelivery.patient" (fhir-spec (string->symbol "SupplyDelivery.patient") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.patient" 'element))
(register-element! "SupplyDelivery.type" (fhir-spec (string->symbol "SupplyDelivery.type") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.type" 'element))
(register-element! "SupplyDelivery.suppliedItem" (fhir-spec (string->symbol "SupplyDelivery.suppliedItem") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem" 'element))
(register-element! "SupplyDelivery.supplier" (fhir-spec (string->symbol "SupplyDelivery.supplier") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.supplier" 'element))
(register-element! "SupplyDelivery.destination" (fhir-spec (string->symbol "SupplyDelivery.destination") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.destination" 'element))
(register-element! "SupplyDelivery.receiver" (fhir-spec (string->symbol "SupplyDelivery.receiver") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.receiver" 'element))
(register-element! "SupplyDelivery.occurrence[x]" (fhir-spec (string->symbol "SupplyDelivery.occurrence[x]") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.occurrence[x]" 'element))
(register-element! "SupplyDelivery.occurrence[x]" (fhir-spec (string->symbol "SupplyDelivery.occurrence[x]") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.occurrence[x]" 'element))
(register-element! "SupplyDelivery.occurrence[x]" (fhir-spec (string->symbol "SupplyDelivery.occurrence[x]") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.occurrence[x]" 'element))

(register-type! 'SupplyDeliverySuppliedItem (fhir-spec 'SupplyDeliverySuppliedItem "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem" 'type)
  #:schema (type-schema 'SupplyDeliverySuppliedItem #f 'BackboneElement "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem"
             (list
    (schema-field 'quantity 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem.quantity" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem.item[x]" #f)
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem.item[x]" #f)
             ) #f #f))
(register-element! "SupplyDelivery.suppliedItem.quantity" (fhir-spec (string->symbol "SupplyDelivery.suppliedItem.quantity") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem.quantity" 'element))
(register-element! "SupplyDelivery.suppliedItem.item[x]" (fhir-spec (string->symbol "SupplyDelivery.suppliedItem.item[x]") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem.item[x]" 'element))
(register-element! "SupplyDelivery.suppliedItem.item[x]" (fhir-spec (string->symbol "SupplyDelivery.suppliedItem.item[x]") "https://hl7.org/fhir/R4/supplydelivery.html#SupplyDelivery.suppliedItem.item[x]" 'element))

