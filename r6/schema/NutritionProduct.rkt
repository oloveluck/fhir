#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'NutritionProduct (fhir-spec 'NutritionProduct "https://build.fhir.org/nutritionproduct.html#NutritionProduct" 'type)
  #:schema (type-schema 'NutritionProduct #f 'DomainResource "https://build.fhir.org/nutritionproduct.html#NutritionProduct"
             (list
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.status" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.code" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.category" #f)
    (schema-field 'manufacturer 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.manufacturer" #f)
    (schema-field 'nutrient 0 '* (vector 'type 'NutritionProductNutrient) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient" #f)
    (schema-field 'ingredientSummary 0 1 (vector 'prim "markdown") #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredientSummary" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'NutritionProductIngredient) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient" #f)
    (schema-field 'energy 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.energy" #f)
    (schema-field 'characteristic 0 '* (vector 'type 'NutritionProductCharacteristic) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic" #f)
    (schema-field 'instance 0 '* (vector 'type 'NutritionProductInstance) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.note" #f)
             ) #f #f))
(register-element! "NutritionProduct.status" (fhir-spec (string->symbol "NutritionProduct.status") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.status" 'element))
(register-element! "NutritionProduct.code" (fhir-spec (string->symbol "NutritionProduct.code") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.code" 'element))
(register-element! "NutritionProduct.category" (fhir-spec (string->symbol "NutritionProduct.category") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.category" 'element))
(register-element! "NutritionProduct.manufacturer" (fhir-spec (string->symbol "NutritionProduct.manufacturer") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.manufacturer" 'element))
(register-element! "NutritionProduct.nutrient" (fhir-spec (string->symbol "NutritionProduct.nutrient") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient" 'element))
(register-element! "NutritionProduct.ingredientSummary" (fhir-spec (string->symbol "NutritionProduct.ingredientSummary") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredientSummary" 'element))
(register-element! "NutritionProduct.ingredient" (fhir-spec (string->symbol "NutritionProduct.ingredient") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient" 'element))
(register-element! "NutritionProduct.energy" (fhir-spec (string->symbol "NutritionProduct.energy") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.energy" 'element))
(register-element! "NutritionProduct.characteristic" (fhir-spec (string->symbol "NutritionProduct.characteristic") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic" 'element))
(register-element! "NutritionProduct.instance" (fhir-spec (string->symbol "NutritionProduct.instance") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance" 'element))
(register-element! "NutritionProduct.note" (fhir-spec (string->symbol "NutritionProduct.note") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.note" 'element))

(register-type! 'NutritionProductNutrient (fhir-spec 'NutritionProductNutrient "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient" 'type)
  #:schema (type-schema 'NutritionProductNutrient #f 'BackboneElement "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient"
             (list
    (schema-field 'item 1 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient.item" #f)
    (schema-field 'amountRatio 0 1 (vector 'type 'Ratio) 'amount "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient.amount[x]" #f)
    (schema-field 'amountQuantity 0 1 (vector 'type 'Quantity) 'amount "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient.amount[x]" #f)
             ) #f #f))
(register-element! "NutritionProduct.nutrient.item" (fhir-spec (string->symbol "NutritionProduct.nutrient.item") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient.item" 'element))
(register-element! "NutritionProduct.nutrient.amount[x]" (fhir-spec (string->symbol "NutritionProduct.nutrient.amount[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient.amount[x]" 'element))
(register-element! "NutritionProduct.nutrient.amount[x]" (fhir-spec (string->symbol "NutritionProduct.nutrient.amount[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.nutrient.amount[x]" 'element))

(register-type! 'NutritionProductIngredient (fhir-spec 'NutritionProductIngredient "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient" 'type)
  #:schema (type-schema 'NutritionProductIngredient #f 'BackboneElement "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient"
             (list
    (schema-field 'item 1 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient.item" #f)
    (schema-field 'allergen 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient.allergen" #f)
    (schema-field 'amountRatio 0 1 (vector 'type 'Ratio) 'amount "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient.amount[x]" #f)
    (schema-field 'amountQuantity 0 1 (vector 'type 'Quantity) 'amount "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient.amount[x]" #f)
             ) #f #f))
(register-element! "NutritionProduct.ingredient.item" (fhir-spec (string->symbol "NutritionProduct.ingredient.item") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient.item" 'element))
(register-element! "NutritionProduct.ingredient.allergen" (fhir-spec (string->symbol "NutritionProduct.ingredient.allergen") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient.allergen" 'element))
(register-element! "NutritionProduct.ingredient.amount[x]" (fhir-spec (string->symbol "NutritionProduct.ingredient.amount[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient.amount[x]" 'element))
(register-element! "NutritionProduct.ingredient.amount[x]" (fhir-spec (string->symbol "NutritionProduct.ingredient.amount[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.ingredient.amount[x]" 'element))

(register-type! 'NutritionProductCharacteristic (fhir-spec 'NutritionProductCharacteristic "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic" 'type)
  #:schema (type-schema 'NutritionProductCharacteristic #f 'BackboneElement "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.type" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueString 0 1 (vector 'prim "string") 'value "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueBase64Binary 0 1 (vector 'prim "base64Binary") 'value "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueAttachment 0 1 (vector 'type 'Attachment) 'value "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueBoolean 0 1 (vector 'prim "boolean") 'value "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
             ) #f #f))
(register-element! "NutritionProduct.characteristic.type" (fhir-spec (string->symbol "NutritionProduct.characteristic.type") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.type" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))

(register-type! 'NutritionProductInstance (fhir-spec 'NutritionProductInstance "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance" 'type)
  #:schema (type-schema 'NutritionProductInstance #f 'BackboneElement "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance"
             (list
    (schema-field 'quantity 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.quantity" #f)
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.identifier" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.name" #f)
    (schema-field 'lotNumber 0 1 (vector 'prim "string") #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.lotNumber" #f)
    (schema-field 'expiry 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.expiry" #f)
    (schema-field 'useBy 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.useBy" #f)
    (schema-field 'biologicalSourceEvent 0 1 (vector 'type 'Identifier) #f "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.biologicalSourceEvent" #f)
             ) #f #f))
(register-element! "NutritionProduct.instance.quantity" (fhir-spec (string->symbol "NutritionProduct.instance.quantity") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.quantity" 'element))
(register-element! "NutritionProduct.instance.identifier" (fhir-spec (string->symbol "NutritionProduct.instance.identifier") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.identifier" 'element))
(register-element! "NutritionProduct.instance.name" (fhir-spec (string->symbol "NutritionProduct.instance.name") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.name" 'element))
(register-element! "NutritionProduct.instance.lotNumber" (fhir-spec (string->symbol "NutritionProduct.instance.lotNumber") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.lotNumber" 'element))
(register-element! "NutritionProduct.instance.expiry" (fhir-spec (string->symbol "NutritionProduct.instance.expiry") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.expiry" 'element))
(register-element! "NutritionProduct.instance.useBy" (fhir-spec (string->symbol "NutritionProduct.instance.useBy") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.useBy" 'element))
(register-element! "NutritionProduct.instance.biologicalSourceEvent" (fhir-spec (string->symbol "NutritionProduct.instance.biologicalSourceEvent") "https://build.fhir.org/nutritionproduct.html#NutritionProduct.instance.biologicalSourceEvent" 'element))

