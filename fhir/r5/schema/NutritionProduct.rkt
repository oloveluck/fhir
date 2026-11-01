#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'NutritionProduct (fhir-spec 'NutritionProduct "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct" 'type)
  #:schema (type-schema 'NutritionProduct #f 'DomainResource "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct"
             (list
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.code" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.status" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.category" #f)
    (schema-field 'manufacturer 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.manufacturer" #f)
    (schema-field 'nutrient 0 '* (vector 'type 'NutritionProductNutrient) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.nutrient" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'NutritionProductIngredient) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.ingredient" #f)
    (schema-field 'knownAllergen 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.knownAllergen" #f)
    (schema-field 'characteristic 0 '* (vector 'type 'NutritionProductCharacteristic) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic" #f)
    (schema-field 'instance 0 '* (vector 'type 'NutritionProductInstance) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.note" #f)
             ) #f #f))
(register-element! "NutritionProduct.code" (fhir-spec (string->symbol "NutritionProduct.code") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.code" 'element))
(register-element! "NutritionProduct.status" (fhir-spec (string->symbol "NutritionProduct.status") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.status" 'element))
(register-element! "NutritionProduct.category" (fhir-spec (string->symbol "NutritionProduct.category") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.category" 'element))
(register-element! "NutritionProduct.manufacturer" (fhir-spec (string->symbol "NutritionProduct.manufacturer") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.manufacturer" 'element))
(register-element! "NutritionProduct.nutrient" (fhir-spec (string->symbol "NutritionProduct.nutrient") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.nutrient" 'element))
(register-element! "NutritionProduct.ingredient" (fhir-spec (string->symbol "NutritionProduct.ingredient") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.ingredient" 'element))
(register-element! "NutritionProduct.knownAllergen" (fhir-spec (string->symbol "NutritionProduct.knownAllergen") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.knownAllergen" 'element))
(register-element! "NutritionProduct.characteristic" (fhir-spec (string->symbol "NutritionProduct.characteristic") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic" 'element))
(register-element! "NutritionProduct.instance" (fhir-spec (string->symbol "NutritionProduct.instance") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance" 'element))
(register-element! "NutritionProduct.note" (fhir-spec (string->symbol "NutritionProduct.note") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.note" 'element))

(register-type! 'NutritionProductNutrient (fhir-spec 'NutritionProductNutrient "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.nutrient" 'type)
  #:schema (type-schema 'NutritionProductNutrient #f 'BackboneElement "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.nutrient"
             (list
    (schema-field 'item 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.nutrient.item" #f)
    (schema-field 'amount 0 '* (vector 'type 'Ratio) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.nutrient.amount" #f)
             ) #f #f))
(register-element! "NutritionProduct.nutrient.item" (fhir-spec (string->symbol "NutritionProduct.nutrient.item") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.nutrient.item" 'element))
(register-element! "NutritionProduct.nutrient.amount" (fhir-spec (string->symbol "NutritionProduct.nutrient.amount") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.nutrient.amount" 'element))

(register-type! 'NutritionProductIngredient (fhir-spec 'NutritionProductIngredient "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.ingredient" 'type)
  #:schema (type-schema 'NutritionProductIngredient #f 'BackboneElement "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.ingredient"
             (list
    (schema-field 'item 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.ingredient.item" #f)
    (schema-field 'amount 0 '* (vector 'type 'Ratio) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.ingredient.amount" #f)
             ) #f #f))
(register-element! "NutritionProduct.ingredient.item" (fhir-spec (string->symbol "NutritionProduct.ingredient.item") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.ingredient.item" 'element))
(register-element! "NutritionProduct.ingredient.amount" (fhir-spec (string->symbol "NutritionProduct.ingredient.amount") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.ingredient.amount" 'element))

(register-type! 'NutritionProductCharacteristic (fhir-spec 'NutritionProductCharacteristic "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic" 'type)
  #:schema (type-schema 'NutritionProductCharacteristic #f 'BackboneElement "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.type" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueString 0 1 (vector 'prim "string") 'value "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueBase64Binary 0 1 (vector 'prim "base64Binary") 'value "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueAttachment 0 1 (vector 'type 'Attachment) 'value "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
    (schema-field 'valueBoolean 0 1 (vector 'prim "boolean") 'value "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" #f)
             ) #f #f))
(register-element! "NutritionProduct.characteristic.type" (fhir-spec (string->symbol "NutritionProduct.characteristic.type") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.type" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))
(register-element! "NutritionProduct.characteristic.value[x]" (fhir-spec (string->symbol "NutritionProduct.characteristic.value[x]") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.characteristic.value[x]" 'element))

(register-type! 'NutritionProductInstance (fhir-spec 'NutritionProductInstance "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance" 'type)
  #:schema (type-schema 'NutritionProductInstance #f 'BackboneElement "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance"
             (list
    (schema-field 'quantity 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.quantity" #f)
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.identifier" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.name" #f)
    (schema-field 'lotNumber 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.lotNumber" #f)
    (schema-field 'expiry 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.expiry" #f)
    (schema-field 'useBy 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.useBy" #f)
    (schema-field 'biologicalSourceEvent 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.biologicalSourceEvent" #f)
             ) #f #f))
(register-element! "NutritionProduct.instance.quantity" (fhir-spec (string->symbol "NutritionProduct.instance.quantity") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.quantity" 'element))
(register-element! "NutritionProduct.instance.identifier" (fhir-spec (string->symbol "NutritionProduct.instance.identifier") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.identifier" 'element))
(register-element! "NutritionProduct.instance.name" (fhir-spec (string->symbol "NutritionProduct.instance.name") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.name" 'element))
(register-element! "NutritionProduct.instance.lotNumber" (fhir-spec (string->symbol "NutritionProduct.instance.lotNumber") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.lotNumber" 'element))
(register-element! "NutritionProduct.instance.expiry" (fhir-spec (string->symbol "NutritionProduct.instance.expiry") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.expiry" 'element))
(register-element! "NutritionProduct.instance.useBy" (fhir-spec (string->symbol "NutritionProduct.instance.useBy") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.useBy" 'element))
(register-element! "NutritionProduct.instance.biologicalSourceEvent" (fhir-spec (string->symbol "NutritionProduct.instance.biologicalSourceEvent") "https://hl7.org/fhir/R5/nutritionproduct.html#NutritionProduct.instance.biologicalSourceEvent" 'element))

