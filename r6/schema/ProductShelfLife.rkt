#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ProductShelfLife (fhir-spec 'ProductShelfLife "https://build.fhir.org/datatypes.html#ProductShelfLife" 'type)
  #:schema (type-schema 'ProductShelfLife #f 'BackboneType "https://build.fhir.org/datatypes.html#ProductShelfLife"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/datatypes.html#ProductShelfLife.type" #f)
    (schema-field 'specialPrecautionsForStorage 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/datatypes.html#ProductShelfLife.specialPrecautionsForStorage" #f)
    (schema-field 'periodDuration 0 1 (vector 'type 'Duration) 'period "https://build.fhir.org/datatypes.html#ProductShelfLife.period[x]" #f)
    (schema-field 'periodString 0 1 (vector 'prim "string") 'period "https://build.fhir.org/datatypes.html#ProductShelfLife.period[x]" #f)
             ) #f #f))
(register-element! "ProductShelfLife.type" (fhir-spec (string->symbol "ProductShelfLife.type") "https://build.fhir.org/datatypes.html#ProductShelfLife.type" 'element))
(register-element! "ProductShelfLife.specialPrecautionsForStorage" (fhir-spec (string->symbol "ProductShelfLife.specialPrecautionsForStorage") "https://build.fhir.org/datatypes.html#ProductShelfLife.specialPrecautionsForStorage" 'element))
(register-element! "ProductShelfLife.period[x]" (fhir-spec (string->symbol "ProductShelfLife.period[x]") "https://build.fhir.org/datatypes.html#ProductShelfLife.period[x]" 'element))
(register-element! "ProductShelfLife.period[x]" (fhir-spec (string->symbol "ProductShelfLife.period[x]") "https://build.fhir.org/datatypes.html#ProductShelfLife.period[x]" 'element))

