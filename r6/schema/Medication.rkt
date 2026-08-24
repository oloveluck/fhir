#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Medication (fhir-spec 'Medication "https://build.fhir.org/medication.html#Medication" 'type)
  #:schema (type-schema 'Medication #f 'DomainResource "https://build.fhir.org/medication.html#Medication"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/medication.html#Medication.identifier" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/medication.html#Medication.code" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://build.fhir.org/medication.html#Medication.status" #f)
    (schema-field 'marketingAuthorizationHolder 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/medication.html#Medication.marketingAuthorizationHolder" #f)
    (schema-field 'doseForm 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/medication.html#Medication.doseForm" #f)
    (schema-field 'packageSize 0 1 (vector 'type 'MedicationPackageSize) #f "https://build.fhir.org/medication.html#Medication.packageSize" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'MedicationIngredient) #f "https://build.fhir.org/medication.html#Medication.ingredient" #f)
    (schema-field 'instance 0 1 (vector 'type 'MedicationInstance) #f "https://build.fhir.org/medication.html#Medication.instance" #f)
    (schema-field 'definition 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/medication.html#Medication.definition" #f)
             ) #f #f))
(register-element! "Medication.identifier" (fhir-spec (string->symbol "Medication.identifier") "https://build.fhir.org/medication.html#Medication.identifier" 'element))
(register-element! "Medication.code" (fhir-spec (string->symbol "Medication.code") "https://build.fhir.org/medication.html#Medication.code" 'element))
(register-element! "Medication.status" (fhir-spec (string->symbol "Medication.status") "https://build.fhir.org/medication.html#Medication.status" 'element))
(register-element! "Medication.marketingAuthorizationHolder" (fhir-spec (string->symbol "Medication.marketingAuthorizationHolder") "https://build.fhir.org/medication.html#Medication.marketingAuthorizationHolder" 'element))
(register-element! "Medication.doseForm" (fhir-spec (string->symbol "Medication.doseForm") "https://build.fhir.org/medication.html#Medication.doseForm" 'element))
(register-element! "Medication.packageSize" (fhir-spec (string->symbol "Medication.packageSize") "https://build.fhir.org/medication.html#Medication.packageSize" 'element))
(register-element! "Medication.ingredient" (fhir-spec (string->symbol "Medication.ingredient") "https://build.fhir.org/medication.html#Medication.ingredient" 'element))
(register-element! "Medication.instance" (fhir-spec (string->symbol "Medication.instance") "https://build.fhir.org/medication.html#Medication.instance" 'element))
(register-element! "Medication.definition" (fhir-spec (string->symbol "Medication.definition") "https://build.fhir.org/medication.html#Medication.definition" 'element))

(register-type! 'MedicationPackageSize (fhir-spec 'MedicationPackageSize "https://build.fhir.org/medication.html#Medication.packageSize" 'type)
  #:schema (type-schema 'MedicationPackageSize #f 'BackboneElement "https://build.fhir.org/medication.html#Medication.packageSize"
             (list
    (schema-field 'numberOfItems 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/medication.html#Medication.packageSize.numberOfItems" #f)
    (schema-field 'amountPerItem 0 1 (vector 'type 'Ratio) #f "https://build.fhir.org/medication.html#Medication.packageSize.amountPerItem" #f)
             ) #f #f))
(register-element! "Medication.packageSize.numberOfItems" (fhir-spec (string->symbol "Medication.packageSize.numberOfItems") "https://build.fhir.org/medication.html#Medication.packageSize.numberOfItems" 'element))
(register-element! "Medication.packageSize.amountPerItem" (fhir-spec (string->symbol "Medication.packageSize.amountPerItem") "https://build.fhir.org/medication.html#Medication.packageSize.amountPerItem" 'element))

(register-type! 'MedicationIngredient (fhir-spec 'MedicationIngredient "https://build.fhir.org/medication.html#Medication.ingredient" 'type)
  #:schema (type-schema 'MedicationIngredient #f 'BackboneElement "https://build.fhir.org/medication.html#Medication.ingredient"
             (list
    (schema-field 'item 1 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/medication.html#Medication.ingredient.item" #f)
    (schema-field 'isActive 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/medication.html#Medication.ingredient.isActive" #f)
    (schema-field 'role 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/medication.html#Medication.ingredient.role" #f)
    (schema-field 'strengthRatio 0 1 (vector 'type 'Ratio) 'strength "https://build.fhir.org/medication.html#Medication.ingredient.strength[x]" #f)
    (schema-field 'strengthCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'strength "https://build.fhir.org/medication.html#Medication.ingredient.strength[x]" #f)
    (schema-field 'strengthQuantity 0 1 (vector 'type 'Quantity) 'strength "https://build.fhir.org/medication.html#Medication.ingredient.strength[x]" #f)
             ) #f #f))
(register-element! "Medication.ingredient.item" (fhir-spec (string->symbol "Medication.ingredient.item") "https://build.fhir.org/medication.html#Medication.ingredient.item" 'element))
(register-element! "Medication.ingredient.isActive" (fhir-spec (string->symbol "Medication.ingredient.isActive") "https://build.fhir.org/medication.html#Medication.ingredient.isActive" 'element))
(register-element! "Medication.ingredient.role" (fhir-spec (string->symbol "Medication.ingredient.role") "https://build.fhir.org/medication.html#Medication.ingredient.role" 'element))
(register-element! "Medication.ingredient.strength[x]" (fhir-spec (string->symbol "Medication.ingredient.strength[x]") "https://build.fhir.org/medication.html#Medication.ingredient.strength[x]" 'element))
(register-element! "Medication.ingredient.strength[x]" (fhir-spec (string->symbol "Medication.ingredient.strength[x]") "https://build.fhir.org/medication.html#Medication.ingredient.strength[x]" 'element))
(register-element! "Medication.ingredient.strength[x]" (fhir-spec (string->symbol "Medication.ingredient.strength[x]") "https://build.fhir.org/medication.html#Medication.ingredient.strength[x]" 'element))

(register-type! 'MedicationInstance (fhir-spec 'MedicationInstance "https://build.fhir.org/medication.html#Medication.instance" 'type)
  #:schema (type-schema 'MedicationInstance #f 'BackboneElement "https://build.fhir.org/medication.html#Medication.instance"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/medication.html#Medication.instance.identifier" #f)
    (schema-field 'lotNumber 0 1 (vector 'prim "string") #f "https://build.fhir.org/medication.html#Medication.instance.lotNumber" #f)
    (schema-field 'expirationDate 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/medication.html#Medication.instance.expirationDate" #f)
             ) #f #f))
(register-element! "Medication.instance.identifier" (fhir-spec (string->symbol "Medication.instance.identifier") "https://build.fhir.org/medication.html#Medication.instance.identifier" 'element))
(register-element! "Medication.instance.lotNumber" (fhir-spec (string->symbol "Medication.instance.lotNumber") "https://build.fhir.org/medication.html#Medication.instance.lotNumber" 'element))
(register-element! "Medication.instance.expirationDate" (fhir-spec (string->symbol "Medication.instance.expirationDate") "https://build.fhir.org/medication.html#Medication.instance.expirationDate" 'element))

