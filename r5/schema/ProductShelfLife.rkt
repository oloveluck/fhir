#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ProductShelfLife (fhir-spec 'ProductShelfLife "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife" 'type)
  #:schema (type-schema 'ProductShelfLife #f 'BackboneType "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife.type" #f)
    (schema-field 'specialPrecautionsForStorage 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife.specialPrecautionsForStorage" #f)
    (schema-field 'periodDuration 0 1 (vector 'type 'Duration) 'period "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife.period[x]" #f)
    (schema-field 'periodString 0 1 (vector 'prim "string") 'period "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife.period[x]" #f)
             ) #f #f))
(register-element! "ProductShelfLife.type" (fhir-spec (string->symbol "ProductShelfLife.type") "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife.type" 'element))
(register-element! "ProductShelfLife.specialPrecautionsForStorage" (fhir-spec (string->symbol "ProductShelfLife.specialPrecautionsForStorage") "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife.specialPrecautionsForStorage" 'element))
(register-element! "ProductShelfLife.period[x]" (fhir-spec (string->symbol "ProductShelfLife.period[x]") "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife.period[x]" 'element))
(register-element! "ProductShelfLife.period[x]" (fhir-spec (string->symbol "ProductShelfLife.period[x]") "https://hl7.org/fhir/R5/datatypes.html#ProductShelfLife.period[x]" 'element))

