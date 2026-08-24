#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Medication (fhir-spec 'Medication "https://hl7.org/fhir/R4/medication.html#Medication" 'type)
  #:schema (type-schema 'Medication #f 'DomainResource "https://hl7.org/fhir/R4/medication.html#Medication"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/medication.html#Medication.identifier" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medication.html#Medication.code" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/medication.html#Medication.status" #f)
    (schema-field 'manufacturer 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medication.html#Medication.manufacturer" #f)
    (schema-field 'form 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medication.html#Medication.form" #f)
    (schema-field 'amount 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medication.html#Medication.amount" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'MedicationIngredient) #f "https://hl7.org/fhir/R4/medication.html#Medication.ingredient" #f)
    (schema-field 'batch 0 1 (vector 'type 'MedicationBatch) #f "https://hl7.org/fhir/R4/medication.html#Medication.batch" #f)
             ) #f #f))
(register-element! "Medication.identifier" (fhir-spec (string->symbol "Medication.identifier") "https://hl7.org/fhir/R4/medication.html#Medication.identifier" 'element))
(register-element! "Medication.code" (fhir-spec (string->symbol "Medication.code") "https://hl7.org/fhir/R4/medication.html#Medication.code" 'element))
(register-element! "Medication.status" (fhir-spec (string->symbol "Medication.status") "https://hl7.org/fhir/R4/medication.html#Medication.status" 'element))
(register-element! "Medication.manufacturer" (fhir-spec (string->symbol "Medication.manufacturer") "https://hl7.org/fhir/R4/medication.html#Medication.manufacturer" 'element))
(register-element! "Medication.form" (fhir-spec (string->symbol "Medication.form") "https://hl7.org/fhir/R4/medication.html#Medication.form" 'element))
(register-element! "Medication.amount" (fhir-spec (string->symbol "Medication.amount") "https://hl7.org/fhir/R4/medication.html#Medication.amount" 'element))
(register-element! "Medication.ingredient" (fhir-spec (string->symbol "Medication.ingredient") "https://hl7.org/fhir/R4/medication.html#Medication.ingredient" 'element))
(register-element! "Medication.batch" (fhir-spec (string->symbol "Medication.batch") "https://hl7.org/fhir/R4/medication.html#Medication.batch" 'element))

(register-type! 'MedicationIngredient (fhir-spec 'MedicationIngredient "https://hl7.org/fhir/R4/medication.html#Medication.ingredient" 'type)
  #:schema (type-schema 'MedicationIngredient #f 'BackboneElement "https://hl7.org/fhir/R4/medication.html#Medication.ingredient"
             (list
    (schema-field 'isActive 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/medication.html#Medication.ingredient.isActive" #f)
    (schema-field 'strength 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medication.html#Medication.ingredient.strength" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R4/medication.html#Medication.ingredient.item[x]" #f)
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R4/medication.html#Medication.ingredient.item[x]" #f)
             ) #f #f))
(register-element! "Medication.ingredient.isActive" (fhir-spec (string->symbol "Medication.ingredient.isActive") "https://hl7.org/fhir/R4/medication.html#Medication.ingredient.isActive" 'element))
(register-element! "Medication.ingredient.strength" (fhir-spec (string->symbol "Medication.ingredient.strength") "https://hl7.org/fhir/R4/medication.html#Medication.ingredient.strength" 'element))
(register-element! "Medication.ingredient.item[x]" (fhir-spec (string->symbol "Medication.ingredient.item[x]") "https://hl7.org/fhir/R4/medication.html#Medication.ingredient.item[x]" 'element))
(register-element! "Medication.ingredient.item[x]" (fhir-spec (string->symbol "Medication.ingredient.item[x]") "https://hl7.org/fhir/R4/medication.html#Medication.ingredient.item[x]" 'element))

(register-type! 'MedicationBatch (fhir-spec 'MedicationBatch "https://hl7.org/fhir/R4/medication.html#Medication.batch" 'type)
  #:schema (type-schema 'MedicationBatch #f 'BackboneElement "https://hl7.org/fhir/R4/medication.html#Medication.batch"
             (list
    (schema-field 'lotNumber 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/medication.html#Medication.batch.lotNumber" #f)
    (schema-field 'expirationDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/medication.html#Medication.batch.expirationDate" #f)
             ) #f #f))
(register-element! "Medication.batch.lotNumber" (fhir-spec (string->symbol "Medication.batch.lotNumber") "https://hl7.org/fhir/R4/medication.html#Medication.batch.lotNumber" 'element))
(register-element! "Medication.batch.expirationDate" (fhir-spec (string->symbol "Medication.batch.expirationDate") "https://hl7.org/fhir/R4/medication.html#Medication.batch.expirationDate" 'element))

