#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'BiologicallyDerivedProduct (fhir-spec 'BiologicallyDerivedProduct "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct" 'type)
  #:schema (type-schema 'BiologicallyDerivedProduct #f 'DomainResource "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.identifier" #f)
    (schema-field 'productCategory 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.productCategory" #f)
    (schema-field 'productCode 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.productCode" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.status" #f)
    (schema-field 'request 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.request" #f)
    (schema-field 'quantity 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.quantity" #f)
    (schema-field 'parent 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.parent" #f)
    (schema-field 'collection 0 1 (vector 'type 'BiologicallyDerivedProductCollection) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection" #f)
    (schema-field 'processing 0 '* (vector 'type 'BiologicallyDerivedProductProcessing) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing" #f)
    (schema-field 'manipulation 0 1 (vector 'type 'BiologicallyDerivedProductManipulation) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation" #f)
    (schema-field 'storage 0 '* (vector 'type 'BiologicallyDerivedProductStorage) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage" #f)
             ) #f #f))
(register-element! "BiologicallyDerivedProduct.identifier" (fhir-spec (string->symbol "BiologicallyDerivedProduct.identifier") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.identifier" 'element))
(register-element! "BiologicallyDerivedProduct.productCategory" (fhir-spec (string->symbol "BiologicallyDerivedProduct.productCategory") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.productCategory" 'element))
(register-element! "BiologicallyDerivedProduct.productCode" (fhir-spec (string->symbol "BiologicallyDerivedProduct.productCode") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.productCode" 'element))
(register-element! "BiologicallyDerivedProduct.status" (fhir-spec (string->symbol "BiologicallyDerivedProduct.status") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.status" 'element))
(register-element! "BiologicallyDerivedProduct.request" (fhir-spec (string->symbol "BiologicallyDerivedProduct.request") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.request" 'element))
(register-element! "BiologicallyDerivedProduct.quantity" (fhir-spec (string->symbol "BiologicallyDerivedProduct.quantity") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.quantity" 'element))
(register-element! "BiologicallyDerivedProduct.parent" (fhir-spec (string->symbol "BiologicallyDerivedProduct.parent") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.parent" 'element))
(register-element! "BiologicallyDerivedProduct.collection" (fhir-spec (string->symbol "BiologicallyDerivedProduct.collection") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection" 'element))
(register-element! "BiologicallyDerivedProduct.processing" (fhir-spec (string->symbol "BiologicallyDerivedProduct.processing") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing" 'element))
(register-element! "BiologicallyDerivedProduct.manipulation" (fhir-spec (string->symbol "BiologicallyDerivedProduct.manipulation") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation" 'element))
(register-element! "BiologicallyDerivedProduct.storage" (fhir-spec (string->symbol "BiologicallyDerivedProduct.storage") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage" 'element))

(register-type! 'BiologicallyDerivedProductCollection (fhir-spec 'BiologicallyDerivedProductCollection "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection" 'type)
  #:schema (type-schema 'BiologicallyDerivedProductCollection #f 'BackboneElement "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection"
             (list
    (schema-field 'collector 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection.collector" #f)
    (schema-field 'source 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection.source" #f)
    (schema-field 'collectedDateTime 0 1 (vector 'prim "dateTime") 'collected "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection.collected[x]" #f)
    (schema-field 'collectedPeriod 0 1 (vector 'type 'Period) 'collected "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection.collected[x]" #f)
             ) #f #f))
(register-element! "BiologicallyDerivedProduct.collection.collector" (fhir-spec (string->symbol "BiologicallyDerivedProduct.collection.collector") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection.collector" 'element))
(register-element! "BiologicallyDerivedProduct.collection.source" (fhir-spec (string->symbol "BiologicallyDerivedProduct.collection.source") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection.source" 'element))
(register-element! "BiologicallyDerivedProduct.collection.collected[x]" (fhir-spec (string->symbol "BiologicallyDerivedProduct.collection.collected[x]") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection.collected[x]" 'element))
(register-element! "BiologicallyDerivedProduct.collection.collected[x]" (fhir-spec (string->symbol "BiologicallyDerivedProduct.collection.collected[x]") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.collection.collected[x]" 'element))

(register-type! 'BiologicallyDerivedProductProcessing (fhir-spec 'BiologicallyDerivedProductProcessing "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing" 'type)
  #:schema (type-schema 'BiologicallyDerivedProductProcessing #f 'BackboneElement "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing"
             (list
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.description" #f)
    (schema-field 'procedure 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.procedure" #f)
    (schema-field 'additive 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.additive" #f)
    (schema-field 'timeDateTime 0 1 (vector 'prim "dateTime") 'time "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.time[x]" #f)
    (schema-field 'timePeriod 0 1 (vector 'type 'Period) 'time "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.time[x]" #f)
             ) #f #f))
(register-element! "BiologicallyDerivedProduct.processing.description" (fhir-spec (string->symbol "BiologicallyDerivedProduct.processing.description") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.description" 'element))
(register-element! "BiologicallyDerivedProduct.processing.procedure" (fhir-spec (string->symbol "BiologicallyDerivedProduct.processing.procedure") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.procedure" 'element))
(register-element! "BiologicallyDerivedProduct.processing.additive" (fhir-spec (string->symbol "BiologicallyDerivedProduct.processing.additive") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.additive" 'element))
(register-element! "BiologicallyDerivedProduct.processing.time[x]" (fhir-spec (string->symbol "BiologicallyDerivedProduct.processing.time[x]") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.time[x]" 'element))
(register-element! "BiologicallyDerivedProduct.processing.time[x]" (fhir-spec (string->symbol "BiologicallyDerivedProduct.processing.time[x]") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.processing.time[x]" 'element))

(register-type! 'BiologicallyDerivedProductManipulation (fhir-spec 'BiologicallyDerivedProductManipulation "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation" 'type)
  #:schema (type-schema 'BiologicallyDerivedProductManipulation #f 'BackboneElement "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation"
             (list
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation.description" #f)
    (schema-field 'timeDateTime 0 1 (vector 'prim "dateTime") 'time "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation.time[x]" #f)
    (schema-field 'timePeriod 0 1 (vector 'type 'Period) 'time "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation.time[x]" #f)
             ) #f #f))
(register-element! "BiologicallyDerivedProduct.manipulation.description" (fhir-spec (string->symbol "BiologicallyDerivedProduct.manipulation.description") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation.description" 'element))
(register-element! "BiologicallyDerivedProduct.manipulation.time[x]" (fhir-spec (string->symbol "BiologicallyDerivedProduct.manipulation.time[x]") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation.time[x]" 'element))
(register-element! "BiologicallyDerivedProduct.manipulation.time[x]" (fhir-spec (string->symbol "BiologicallyDerivedProduct.manipulation.time[x]") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.manipulation.time[x]" 'element))

(register-type! 'BiologicallyDerivedProductStorage (fhir-spec 'BiologicallyDerivedProductStorage "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage" 'type)
  #:schema (type-schema 'BiologicallyDerivedProductStorage #f 'BackboneElement "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage"
             (list
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage.description" #f)
    (schema-field 'temperature 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage.temperature" #f)
    (schema-field 'scale 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage.scale" #f)
    (schema-field 'duration 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage.duration" #f)
             ) #f #f))
(register-element! "BiologicallyDerivedProduct.storage.description" (fhir-spec (string->symbol "BiologicallyDerivedProduct.storage.description") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage.description" 'element))
(register-element! "BiologicallyDerivedProduct.storage.temperature" (fhir-spec (string->symbol "BiologicallyDerivedProduct.storage.temperature") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage.temperature" 'element))
(register-element! "BiologicallyDerivedProduct.storage.scale" (fhir-spec (string->symbol "BiologicallyDerivedProduct.storage.scale") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage.scale" 'element))
(register-element! "BiologicallyDerivedProduct.storage.duration" (fhir-spec (string->symbol "BiologicallyDerivedProduct.storage.duration") "https://hl7.org/fhir/R4/biologicallyderivedproduct.html#BiologicallyDerivedProduct.storage.duration" 'element))

