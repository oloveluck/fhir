#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'NutritionIntake (fhir-spec 'NutritionIntake "https://build.fhir.org/nutritionintake.html#NutritionIntake" 'type)
  #:schema (type-schema 'NutritionIntake #f 'DomainResource "https://build.fhir.org/nutritionintake.html#NutritionIntake"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.identifier" #f)
    (schema-field 'basedOn 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.basedOn" #f)
    (schema-field 'partOf 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.partOf" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.status" #f)
    (schema-field 'statusReason 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.statusReason" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.code" #f)
    (schema-field 'subject 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.subject" #f)
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.encounter" #f)
    (schema-field 'recorded 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.recorded" #f)
    (schema-field 'nutritionItem 0 '* (vector 'type 'NutritionIntakeNutritionItem) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem" #f)
    (schema-field 'performer 0 '* (vector 'type 'NutritionIntakePerformer) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.performer" #f)
    (schema-field 'location 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.location" #f)
    (schema-field 'derivedFrom 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.derivedFrom" #f)
    (schema-field 'reason 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.reason" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.note" #f)
    (schema-field 'occurrenceDateTime 0 1 (vector 'prim "dateTime") 'occurrence "https://build.fhir.org/nutritionintake.html#NutritionIntake.occurrence[x]" #f)
    (schema-field 'occurrencePeriod 0 1 (vector 'type 'Period) 'occurrence "https://build.fhir.org/nutritionintake.html#NutritionIntake.occurrence[x]" #f)
    (schema-field 'reportedBoolean 0 1 (vector 'prim "boolean") 'reported "https://build.fhir.org/nutritionintake.html#NutritionIntake.reported[x]" #f)
    (schema-field 'reportedReference 0 1 (vector 'type 'Reference) 'reported "https://build.fhir.org/nutritionintake.html#NutritionIntake.reported[x]" #f)
             ) #f #f))
(register-element! "NutritionIntake.identifier" (fhir-spec (string->symbol "NutritionIntake.identifier") "https://build.fhir.org/nutritionintake.html#NutritionIntake.identifier" 'element))
(register-element! "NutritionIntake.basedOn" (fhir-spec (string->symbol "NutritionIntake.basedOn") "https://build.fhir.org/nutritionintake.html#NutritionIntake.basedOn" 'element))
(register-element! "NutritionIntake.partOf" (fhir-spec (string->symbol "NutritionIntake.partOf") "https://build.fhir.org/nutritionintake.html#NutritionIntake.partOf" 'element))
(register-element! "NutritionIntake.status" (fhir-spec (string->symbol "NutritionIntake.status") "https://build.fhir.org/nutritionintake.html#NutritionIntake.status" 'element))
(register-element! "NutritionIntake.statusReason" (fhir-spec (string->symbol "NutritionIntake.statusReason") "https://build.fhir.org/nutritionintake.html#NutritionIntake.statusReason" 'element))
(register-element! "NutritionIntake.code" (fhir-spec (string->symbol "NutritionIntake.code") "https://build.fhir.org/nutritionintake.html#NutritionIntake.code" 'element))
(register-element! "NutritionIntake.subject" (fhir-spec (string->symbol "NutritionIntake.subject") "https://build.fhir.org/nutritionintake.html#NutritionIntake.subject" 'element))
(register-element! "NutritionIntake.encounter" (fhir-spec (string->symbol "NutritionIntake.encounter") "https://build.fhir.org/nutritionintake.html#NutritionIntake.encounter" 'element))
(register-element! "NutritionIntake.recorded" (fhir-spec (string->symbol "NutritionIntake.recorded") "https://build.fhir.org/nutritionintake.html#NutritionIntake.recorded" 'element))
(register-element! "NutritionIntake.nutritionItem" (fhir-spec (string->symbol "NutritionIntake.nutritionItem") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem" 'element))
(register-element! "NutritionIntake.performer" (fhir-spec (string->symbol "NutritionIntake.performer") "https://build.fhir.org/nutritionintake.html#NutritionIntake.performer" 'element))
(register-element! "NutritionIntake.location" (fhir-spec (string->symbol "NutritionIntake.location") "https://build.fhir.org/nutritionintake.html#NutritionIntake.location" 'element))
(register-element! "NutritionIntake.derivedFrom" (fhir-spec (string->symbol "NutritionIntake.derivedFrom") "https://build.fhir.org/nutritionintake.html#NutritionIntake.derivedFrom" 'element))
(register-element! "NutritionIntake.reason" (fhir-spec (string->symbol "NutritionIntake.reason") "https://build.fhir.org/nutritionintake.html#NutritionIntake.reason" 'element))
(register-element! "NutritionIntake.note" (fhir-spec (string->symbol "NutritionIntake.note") "https://build.fhir.org/nutritionintake.html#NutritionIntake.note" 'element))
(register-element! "NutritionIntake.occurrence[x]" (fhir-spec (string->symbol "NutritionIntake.occurrence[x]") "https://build.fhir.org/nutritionintake.html#NutritionIntake.occurrence[x]" 'element))
(register-element! "NutritionIntake.occurrence[x]" (fhir-spec (string->symbol "NutritionIntake.occurrence[x]") "https://build.fhir.org/nutritionintake.html#NutritionIntake.occurrence[x]" 'element))
(register-element! "NutritionIntake.reported[x]" (fhir-spec (string->symbol "NutritionIntake.reported[x]") "https://build.fhir.org/nutritionintake.html#NutritionIntake.reported[x]" 'element))
(register-element! "NutritionIntake.reported[x]" (fhir-spec (string->symbol "NutritionIntake.reported[x]") "https://build.fhir.org/nutritionintake.html#NutritionIntake.reported[x]" 'element))

(register-type! 'NutritionIntakeNutritionItem (fhir-spec 'NutritionIntakeNutritionItem "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem" 'type)
  #:schema (type-schema 'NutritionIntakeNutritionItem #f 'BackboneElement "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.type" #f)
    (schema-field 'nutritionProduct 0 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.nutritionProduct" #f)
    (schema-field 'consumedItem 0 '* (vector 'type 'NutritionIntakeNutritionItemConsumedItem) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem" #f)
    (schema-field 'notConsumedItem 0 '* (vector 'type 'NutritionIntakeNutritionItemNotConsumedItem) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem" #f)
             ) #f #f))
(register-element! "NutritionIntake.nutritionItem.type" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.type") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.type" 'element))
(register-element! "NutritionIntake.nutritionItem.nutritionProduct" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.nutritionProduct") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.nutritionProduct" 'element))
(register-element! "NutritionIntake.nutritionItem.consumedItem" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem" 'element))
(register-element! "NutritionIntake.nutritionItem.notConsumedItem" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.notConsumedItem") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem" 'element))

(register-type! 'NutritionIntakeNutritionItemConsumedItem (fhir-spec 'NutritionIntakeNutritionItemConsumedItem "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem" 'type)
  #:schema (type-schema 'NutritionIntakeNutritionItemConsumedItem #f 'BackboneElement "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem"
             (list
    (schema-field 'schedule 0 1 (vector 'type 'Timing) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.schedule" #f)
    (schema-field 'amount 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.amount" #f)
    (schema-field 'totalIntake 0 '* (vector 'type 'NutritionIntakeNutritionItemConsumedItemTotalIntake) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake" #f)
    (schema-field 'rateQuantity 0 1 (vector 'type 'Quantity) 'rate "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.rate[x]" #f)
    (schema-field 'rateRatio 0 1 (vector 'type 'Ratio) 'rate "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.rate[x]" #f)
             ) #f #f))
(register-element! "NutritionIntake.nutritionItem.consumedItem.schedule" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem.schedule") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.schedule" 'element))
(register-element! "NutritionIntake.nutritionItem.consumedItem.amount" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem.amount") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.amount" 'element))
(register-element! "NutritionIntake.nutritionItem.consumedItem.totalIntake" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem.totalIntake") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake" 'element))
(register-element! "NutritionIntake.nutritionItem.consumedItem.rate[x]" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem.rate[x]") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.rate[x]" 'element))
(register-element! "NutritionIntake.nutritionItem.consumedItem.rate[x]" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem.rate[x]") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.rate[x]" 'element))

(register-type! 'NutritionIntakeNutritionItemConsumedItemTotalIntake (fhir-spec 'NutritionIntakeNutritionItemConsumedItemTotalIntake "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake" 'type)
  #:schema (type-schema 'NutritionIntakeNutritionItemConsumedItemTotalIntake #f 'BackboneElement "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake"
             (list
    (schema-field 'nutrient 1 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake.nutrient" #f)
    (schema-field 'amount 1 1 (vector 'type 'Quantity) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake.amount" #f)
    (schema-field 'energy 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake.energy" #f)
             ) #f #f))
(register-element! "NutritionIntake.nutritionItem.consumedItem.totalIntake.nutrient" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem.totalIntake.nutrient") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake.nutrient" 'element))
(register-element! "NutritionIntake.nutritionItem.consumedItem.totalIntake.amount" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem.totalIntake.amount") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake.amount" 'element))
(register-element! "NutritionIntake.nutritionItem.consumedItem.totalIntake.energy" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.consumedItem.totalIntake.energy") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.consumedItem.totalIntake.energy" 'element))

(register-type! 'NutritionIntakeNutritionItemNotConsumedItem (fhir-spec 'NutritionIntakeNutritionItemNotConsumedItem "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem" 'type)
  #:schema (type-schema 'NutritionIntakeNutritionItemNotConsumedItem #f 'BackboneElement "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem"
             (list
    (schema-field 'reason 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem.reason" #f)
    (schema-field 'schedule 0 1 (vector 'type 'Timing) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem.schedule" #f)
    (schema-field 'amount 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem.amount" #f)
             ) #f #f))
(register-element! "NutritionIntake.nutritionItem.notConsumedItem.reason" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.notConsumedItem.reason") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem.reason" 'element))
(register-element! "NutritionIntake.nutritionItem.notConsumedItem.schedule" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.notConsumedItem.schedule") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem.schedule" 'element))
(register-element! "NutritionIntake.nutritionItem.notConsumedItem.amount" (fhir-spec (string->symbol "NutritionIntake.nutritionItem.notConsumedItem.amount") "https://build.fhir.org/nutritionintake.html#NutritionIntake.nutritionItem.notConsumedItem.amount" 'element))

(register-type! 'NutritionIntakePerformer (fhir-spec 'NutritionIntakePerformer "https://build.fhir.org/nutritionintake.html#NutritionIntake.performer" 'type)
  #:schema (type-schema 'NutritionIntakePerformer #f 'BackboneElement "https://build.fhir.org/nutritionintake.html#NutritionIntake.performer"
             (list
    (schema-field 'function 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.performer.function" #f)
    (schema-field 'actor 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/nutritionintake.html#NutritionIntake.performer.actor" #f)
             ) #f #f))
(register-element! "NutritionIntake.performer.function" (fhir-spec (string->symbol "NutritionIntake.performer.function") "https://build.fhir.org/nutritionintake.html#NutritionIntake.performer.function" 'element))
(register-element! "NutritionIntake.performer.actor" (fhir-spec (string->symbol "NutritionIntake.performer.actor") "https://build.fhir.org/nutritionintake.html#NutritionIntake.performer.actor" 'element))

