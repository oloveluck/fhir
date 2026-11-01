#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'UsageContext (fhir-spec 'UsageContext "https://hl7.org/fhir/R4/datatypes.html#UsageContext" 'type)
  #:schema (type-schema 'UsageContext #f 'Element "https://hl7.org/fhir/R4/datatypes.html#UsageContext"
             (list
    (schema-field 'code 1 1 (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/datatypes.html#UsageContext.code" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://hl7.org/fhir/R4/datatypes.html#UsageContext.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R4/datatypes.html#UsageContext.value[x]" #f)
    (schema-field 'valueRange 0 1 (vector 'type 'Range) 'value "https://hl7.org/fhir/R4/datatypes.html#UsageContext.value[x]" #f)
    (schema-field 'valueReference 0 1 (vector 'type 'Reference) 'value "https://hl7.org/fhir/R4/datatypes.html#UsageContext.value[x]" #f)
             ) #f #f))
(register-element! "UsageContext.code" (fhir-spec (string->symbol "UsageContext.code") "https://hl7.org/fhir/R4/datatypes.html#UsageContext.code" 'element))
(register-element! "UsageContext.value[x]" (fhir-spec (string->symbol "UsageContext.value[x]") "https://hl7.org/fhir/R4/datatypes.html#UsageContext.value[x]" 'element))
(register-element! "UsageContext.value[x]" (fhir-spec (string->symbol "UsageContext.value[x]") "https://hl7.org/fhir/R4/datatypes.html#UsageContext.value[x]" 'element))
(register-element! "UsageContext.value[x]" (fhir-spec (string->symbol "UsageContext.value[x]") "https://hl7.org/fhir/R4/datatypes.html#UsageContext.value[x]" 'element))
(register-element! "UsageContext.value[x]" (fhir-spec (string->symbol "UsageContext.value[x]") "https://hl7.org/fhir/R4/datatypes.html#UsageContext.value[x]" 'element))

