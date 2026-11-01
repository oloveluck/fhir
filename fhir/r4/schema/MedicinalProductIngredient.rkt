#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicinalProductIngredient (fhir-spec 'MedicinalProductIngredient "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient" 'type)
  #:schema (type-schema 'MedicinalProductIngredient #f 'DomainResource "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.identifier" #f)
    (schema-field 'role 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.role" #f)
    (schema-field 'allergenicIndicator 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.allergenicIndicator" #f)
    (schema-field 'manufacturer 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.manufacturer" #f)
    (schema-field 'specifiedSubstance 0 '* (vector 'type 'MedicinalProductIngredientSpecifiedSubstance) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance" #f)
    (schema-field 'substance 0 1 (vector 'type 'MedicinalProductIngredientSubstance) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.substance" #f)
             ) #f #f))
(register-element! "MedicinalProductIngredient.identifier" (fhir-spec (string->symbol "MedicinalProductIngredient.identifier") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.identifier" 'element))
(register-element! "MedicinalProductIngredient.role" (fhir-spec (string->symbol "MedicinalProductIngredient.role") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.role" 'element))
(register-element! "MedicinalProductIngredient.allergenicIndicator" (fhir-spec (string->symbol "MedicinalProductIngredient.allergenicIndicator") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.allergenicIndicator" 'element))
(register-element! "MedicinalProductIngredient.manufacturer" (fhir-spec (string->symbol "MedicinalProductIngredient.manufacturer") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.manufacturer" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance" 'element))
(register-element! "MedicinalProductIngredient.substance" (fhir-spec (string->symbol "MedicinalProductIngredient.substance") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.substance" 'element))

(register-type! 'MedicinalProductIngredientSpecifiedSubstance (fhir-spec 'MedicinalProductIngredientSpecifiedSubstance "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance" 'type)
  #:schema (type-schema 'MedicinalProductIngredientSpecifiedSubstance #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.code" #f)
    (schema-field 'group 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.group" #f)
    (schema-field 'confidentiality 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.confidentiality" #f)
    (schema-field 'strength 0 '* (vector 'type 'MedicinalProductIngredientSpecifiedSubstanceStrength) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength" #f)
             ) #f #f))
(register-element! "MedicinalProductIngredient.specifiedSubstance.code" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.code") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.code" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.group" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.group") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.group" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.confidentiality" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.confidentiality") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.confidentiality" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength" 'element))

(register-type! 'MedicinalProductIngredientSpecifiedSubstanceStrength (fhir-spec 'MedicinalProductIngredientSpecifiedSubstanceStrength "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength" 'type)
  #:schema (type-schema 'MedicinalProductIngredientSpecifiedSubstanceStrength #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength"
             (list
    (schema-field 'presentation 1 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.presentation" #f)
    (schema-field 'presentationLowLimit 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.presentationLowLimit" #f)
    (schema-field 'concentration 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.concentration" #f)
    (schema-field 'concentrationLowLimit 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.concentrationLowLimit" #f)
    (schema-field 'measurementPoint 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.measurementPoint" #f)
    (schema-field 'country 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.country" #f)
    (schema-field 'referenceStrength 0 '* (vector 'type 'MedicinalProductIngredientSpecifiedSubstanceStrengthReferenceStrength) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength" #f)
             ) #f #f))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.presentation" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.presentation") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.presentation" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.presentationLowLimit" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.presentationLowLimit") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.presentationLowLimit" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.concentration" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.concentration") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.concentration" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.concentrationLowLimit" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.concentrationLowLimit") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.concentrationLowLimit" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.measurementPoint" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.measurementPoint") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.measurementPoint" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.country" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.country") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.country" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength" 'element))

(register-type! 'MedicinalProductIngredientSpecifiedSubstanceStrengthReferenceStrength (fhir-spec 'MedicinalProductIngredientSpecifiedSubstanceStrengthReferenceStrength "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength" 'type)
  #:schema (type-schema 'MedicinalProductIngredientSpecifiedSubstanceStrengthReferenceStrength #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength"
             (list
    (schema-field 'substance 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.substance" #f)
    (schema-field 'strength 1 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.strength" #f)
    (schema-field 'strengthLowLimit 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.strengthLowLimit" #f)
    (schema-field 'measurementPoint 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.measurementPoint" #f)
    (schema-field 'country 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.country" #f)
             ) #f #f))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.substance" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.substance") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.substance" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.strength" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.strength") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.strength" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.strengthLowLimit" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.strengthLowLimit") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.strengthLowLimit" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.measurementPoint" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.measurementPoint") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.measurementPoint" 'element))
(register-element! "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.country" (fhir-spec (string->symbol "MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.country") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength.country" 'element))

(register-type! 'MedicinalProductIngredientSubstance (fhir-spec 'MedicinalProductIngredientSubstance "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.substance" 'type)
  #:schema (type-schema 'MedicinalProductIngredientSubstance #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.substance"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.substance.code" #f)
    (schema-field 'strength 0 '* (vector 'type 'MedicinalProductIngredientSpecifiedSubstanceStrength) #f "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.substance.strength" #f)
             ) #f #f))
(register-element! "MedicinalProductIngredient.substance.code" (fhir-spec (string->symbol "MedicinalProductIngredient.substance.code") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.substance.code" 'element))
(register-element! "MedicinalProductIngredient.substance.strength" (fhir-spec (string->symbol "MedicinalProductIngredient.substance.strength") "https://hl7.org/fhir/R4/medicinalproductingredient.html#MedicinalProductIngredient.substance.strength" 'element))

