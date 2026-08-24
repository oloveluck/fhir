#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'UsageContext (fhir-spec 'UsageContext "https://build.fhir.org/datatypes.html#UsageContext" 'type)
  #:schema (type-schema 'UsageContext #f 'DataType "https://build.fhir.org/datatypes.html#UsageContext"
             (list
    (schema-field 'code 1 1 (vector 'type 'Coding) #f "https://build.fhir.org/datatypes.html#UsageContext.code" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://build.fhir.org/datatypes.html#UsageContext.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://build.fhir.org/datatypes.html#UsageContext.value[x]" #f)
    (schema-field 'valueRange 0 1 (vector 'type 'Range) 'value "https://build.fhir.org/datatypes.html#UsageContext.value[x]" #f)
    (schema-field 'valueReference 0 1 (vector 'type 'Reference) 'value "https://build.fhir.org/datatypes.html#UsageContext.value[x]" #f)
             ) #f #f))
(register-element! "UsageContext.code" (fhir-spec (string->symbol "UsageContext.code") "https://build.fhir.org/datatypes.html#UsageContext.code" 'element))
(register-element! "UsageContext.value[x]" (fhir-spec (string->symbol "UsageContext.value[x]") "https://build.fhir.org/datatypes.html#UsageContext.value[x]" 'element))
(register-element! "UsageContext.value[x]" (fhir-spec (string->symbol "UsageContext.value[x]") "https://build.fhir.org/datatypes.html#UsageContext.value[x]" 'element))
(register-element! "UsageContext.value[x]" (fhir-spec (string->symbol "UsageContext.value[x]") "https://build.fhir.org/datatypes.html#UsageContext.value[x]" 'element))
(register-element! "UsageContext.value[x]" (fhir-spec (string->symbol "UsageContext.value[x]") "https://build.fhir.org/datatypes.html#UsageContext.value[x]" 'element))

