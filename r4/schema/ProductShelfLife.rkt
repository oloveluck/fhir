#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ProductShelfLife (fhir-spec 'ProductShelfLife "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife" 'type)
  #:schema (type-schema 'ProductShelfLife #f 'BackboneElement "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife.identifier" #f)
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife.type" #f)
    (schema-field 'period 1 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife.period" #f)
    (schema-field 'specialPrecautionsForStorage 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife.specialPrecautionsForStorage" #f)
             ) #f #f))
(register-element! "ProductShelfLife.identifier" (fhir-spec (string->symbol "ProductShelfLife.identifier") "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife.identifier" 'element))
(register-element! "ProductShelfLife.type" (fhir-spec (string->symbol "ProductShelfLife.type") "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife.type" 'element))
(register-element! "ProductShelfLife.period" (fhir-spec (string->symbol "ProductShelfLife.period") "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife.period" 'element))
(register-element! "ProductShelfLife.specialPrecautionsForStorage" (fhir-spec (string->symbol "ProductShelfLife.specialPrecautionsForStorage") "https://hl7.org/fhir/R4/datatypes.html#ProductShelfLife.specialPrecautionsForStorage" 'element))

