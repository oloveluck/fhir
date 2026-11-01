#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SubstanceAmount (fhir-spec 'SubstanceAmount "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount" 'type)
  #:schema (type-schema 'SubstanceAmount #f 'BackboneElement "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount"
             (list
    (schema-field 'amountType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amountType" #f)
    (schema-field 'amountText 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amountText" #f)
    (schema-field 'referenceRange 0 1 (vector 'type 'SubstanceAmountReferenceRange) #f "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.referenceRange" #f)
    (schema-field 'amountQuantity 0 1 (vector 'type 'Quantity) 'amount "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amount[x]" #f)
    (schema-field 'amountRange 0 1 (vector 'type 'Range) 'amount "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amount[x]" #f)
    (schema-field 'amountString 0 1 (vector 'prim "string") 'amount "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amount[x]" #f)
             ) #f #f))
(register-element! "SubstanceAmount.amountType" (fhir-spec (string->symbol "SubstanceAmount.amountType") "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amountType" 'element))
(register-element! "SubstanceAmount.amountText" (fhir-spec (string->symbol "SubstanceAmount.amountText") "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amountText" 'element))
(register-element! "SubstanceAmount.referenceRange" (fhir-spec (string->symbol "SubstanceAmount.referenceRange") "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.referenceRange" 'element))
(register-element! "SubstanceAmount.amount[x]" (fhir-spec (string->symbol "SubstanceAmount.amount[x]") "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amount[x]" 'element))
(register-element! "SubstanceAmount.amount[x]" (fhir-spec (string->symbol "SubstanceAmount.amount[x]") "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amount[x]" 'element))
(register-element! "SubstanceAmount.amount[x]" (fhir-spec (string->symbol "SubstanceAmount.amount[x]") "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.amount[x]" 'element))

(register-type! 'SubstanceAmountReferenceRange (fhir-spec 'SubstanceAmountReferenceRange "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.referenceRange" 'type)
  #:schema (type-schema 'SubstanceAmountReferenceRange #f 'BackboneElement "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.referenceRange"
             (list
    (schema-field 'lowLimit 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.referenceRange.lowLimit" #f)
    (schema-field 'highLimit 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.referenceRange.highLimit" #f)
             ) #f #f))
(register-element! "SubstanceAmount.referenceRange.lowLimit" (fhir-spec (string->symbol "SubstanceAmount.referenceRange.lowLimit") "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.referenceRange.lowLimit" 'element))
(register-element! "SubstanceAmount.referenceRange.highLimit" (fhir-spec (string->symbol "SubstanceAmount.referenceRange.highLimit") "https://hl7.org/fhir/R4/datatypes.html#SubstanceAmount.referenceRange.highLimit" 'element))

