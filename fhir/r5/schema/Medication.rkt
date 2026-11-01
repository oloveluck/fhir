#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Medication (fhir-spec 'Medication "https://hl7.org/fhir/R5/medication.html#Medication" 'type)
  #:schema (type-schema 'Medication #f 'DomainResource "https://hl7.org/fhir/R5/medication.html#Medication"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/medication.html#Medication.identifier" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medication.html#Medication.code" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/medication.html#Medication.status" #f)
    (schema-field 'marketingAuthorizationHolder 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medication.html#Medication.marketingAuthorizationHolder" #f)
    (schema-field 'doseForm 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medication.html#Medication.doseForm" #f)
    (schema-field 'totalVolume 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/medication.html#Medication.totalVolume" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'MedicationIngredient) #f "https://hl7.org/fhir/R5/medication.html#Medication.ingredient" #f)
    (schema-field 'batch 0 1 (vector 'type 'MedicationBatch) #f "https://hl7.org/fhir/R5/medication.html#Medication.batch" #f)
    (schema-field 'definition 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medication.html#Medication.definition" #f)
             ) #f #f))
(register-element! "Medication.identifier" (fhir-spec (string->symbol "Medication.identifier") "https://hl7.org/fhir/R5/medication.html#Medication.identifier" 'element))
(register-element! "Medication.code" (fhir-spec (string->symbol "Medication.code") "https://hl7.org/fhir/R5/medication.html#Medication.code" 'element))
(register-element! "Medication.status" (fhir-spec (string->symbol "Medication.status") "https://hl7.org/fhir/R5/medication.html#Medication.status" 'element))
(register-element! "Medication.marketingAuthorizationHolder" (fhir-spec (string->symbol "Medication.marketingAuthorizationHolder") "https://hl7.org/fhir/R5/medication.html#Medication.marketingAuthorizationHolder" 'element))
(register-element! "Medication.doseForm" (fhir-spec (string->symbol "Medication.doseForm") "https://hl7.org/fhir/R5/medication.html#Medication.doseForm" 'element))
(register-element! "Medication.totalVolume" (fhir-spec (string->symbol "Medication.totalVolume") "https://hl7.org/fhir/R5/medication.html#Medication.totalVolume" 'element))
(register-element! "Medication.ingredient" (fhir-spec (string->symbol "Medication.ingredient") "https://hl7.org/fhir/R5/medication.html#Medication.ingredient" 'element))
(register-element! "Medication.batch" (fhir-spec (string->symbol "Medication.batch") "https://hl7.org/fhir/R5/medication.html#Medication.batch" 'element))
(register-element! "Medication.definition" (fhir-spec (string->symbol "Medication.definition") "https://hl7.org/fhir/R5/medication.html#Medication.definition" 'element))

(register-type! 'MedicationIngredient (fhir-spec 'MedicationIngredient "https://hl7.org/fhir/R5/medication.html#Medication.ingredient" 'type)
  #:schema (type-schema 'MedicationIngredient #f 'BackboneElement "https://hl7.org/fhir/R5/medication.html#Medication.ingredient"
             (list
    (schema-field 'item 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.item" #f)
    (schema-field 'isActive 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.isActive" #f)
    (schema-field 'strengthRatio 0 1 (vector 'type 'Ratio) 'strength "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.strength[x]" #f)
    (schema-field 'strengthCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'strength "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.strength[x]" #f)
    (schema-field 'strengthQuantity 0 1 (vector 'type 'Quantity) 'strength "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.strength[x]" #f)
             ) #f #f))
(register-element! "Medication.ingredient.item" (fhir-spec (string->symbol "Medication.ingredient.item") "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.item" 'element))
(register-element! "Medication.ingredient.isActive" (fhir-spec (string->symbol "Medication.ingredient.isActive") "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.isActive" 'element))
(register-element! "Medication.ingredient.strength[x]" (fhir-spec (string->symbol "Medication.ingredient.strength[x]") "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.strength[x]" 'element))
(register-element! "Medication.ingredient.strength[x]" (fhir-spec (string->symbol "Medication.ingredient.strength[x]") "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.strength[x]" 'element))
(register-element! "Medication.ingredient.strength[x]" (fhir-spec (string->symbol "Medication.ingredient.strength[x]") "https://hl7.org/fhir/R5/medication.html#Medication.ingredient.strength[x]" 'element))

(register-type! 'MedicationBatch (fhir-spec 'MedicationBatch "https://hl7.org/fhir/R5/medication.html#Medication.batch" 'type)
  #:schema (type-schema 'MedicationBatch #f 'BackboneElement "https://hl7.org/fhir/R5/medication.html#Medication.batch"
             (list
    (schema-field 'lotNumber 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/medication.html#Medication.batch.lotNumber" #f)
    (schema-field 'expirationDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/medication.html#Medication.batch.expirationDate" #f)
             ) #f #f))
(register-element! "Medication.batch.lotNumber" (fhir-spec (string->symbol "Medication.batch.lotNumber") "https://hl7.org/fhir/R5/medication.html#Medication.batch.lotNumber" 'element))
(register-element! "Medication.batch.expirationDate" (fhir-spec (string->symbol "Medication.batch.expirationDate") "https://hl7.org/fhir/R5/medication.html#Medication.batch.expirationDate" 'element))

