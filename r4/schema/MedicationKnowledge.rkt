#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicationKnowledge (fhir-spec 'MedicationKnowledge "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge" 'type)
  #:schema (type-schema 'MedicationKnowledge #f 'DomainResource "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge"
             (list
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.code" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.status" #f)
    (schema-field 'manufacturer 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.manufacturer" #f)
    (schema-field 'doseForm 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.doseForm" #f)
    (schema-field 'amount 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.amount" #f)
    (schema-field 'synonym 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.synonym" #f)
    (schema-field 'relatedMedicationKnowledge 0 '* (vector 'type 'MedicationKnowledgeRelatedMedicationKnowledge) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge" #f)
    (schema-field 'associatedMedication 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.associatedMedication" #f)
    (schema-field 'productType 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.productType" #f)
    (schema-field 'monograph 0 '* (vector 'type 'MedicationKnowledgeMonograph) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monograph" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'MedicationKnowledgeIngredient) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient" #f)
    (schema-field 'preparationInstruction 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.preparationInstruction" #f)
    (schema-field 'intendedRoute 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.intendedRoute" #f)
    (schema-field 'cost 0 '* (vector 'type 'MedicationKnowledgeCost) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost" #f)
    (schema-field 'monitoringProgram 0 '* (vector 'type 'MedicationKnowledgeMonitoringProgram) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monitoringProgram" #f)
    (schema-field 'administrationGuidelines 0 '* (vector 'type 'MedicationKnowledgeAdministrationGuidelines) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines" #f)
    (schema-field 'medicineClassification 0 '* (vector 'type 'MedicationKnowledgeMedicineClassification) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.medicineClassification" #f)
    (schema-field 'packaging 0 1 (vector 'type 'MedicationKnowledgePackaging) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.packaging" #f)
    (schema-field 'drugCharacteristic 0 '* (vector 'type 'MedicationKnowledgeDrugCharacteristic) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic" #f)
    (schema-field 'contraindication 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.contraindication" #f)
    (schema-field 'regulatory 0 '* (vector 'type 'MedicationKnowledgeRegulatory) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory" #f)
    (schema-field 'kinetics 0 '* (vector 'type 'MedicationKnowledgeKinetics) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.code" (fhir-spec (string->symbol "MedicationKnowledge.code") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.code" 'element))
(register-element! "MedicationKnowledge.status" (fhir-spec (string->symbol "MedicationKnowledge.status") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.status" 'element))
(register-element! "MedicationKnowledge.manufacturer" (fhir-spec (string->symbol "MedicationKnowledge.manufacturer") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.manufacturer" 'element))
(register-element! "MedicationKnowledge.doseForm" (fhir-spec (string->symbol "MedicationKnowledge.doseForm") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.doseForm" 'element))
(register-element! "MedicationKnowledge.amount" (fhir-spec (string->symbol "MedicationKnowledge.amount") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.amount" 'element))
(register-element! "MedicationKnowledge.synonym" (fhir-spec (string->symbol "MedicationKnowledge.synonym") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.synonym" 'element))
(register-element! "MedicationKnowledge.relatedMedicationKnowledge" (fhir-spec (string->symbol "MedicationKnowledge.relatedMedicationKnowledge") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge" 'element))
(register-element! "MedicationKnowledge.associatedMedication" (fhir-spec (string->symbol "MedicationKnowledge.associatedMedication") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.associatedMedication" 'element))
(register-element! "MedicationKnowledge.productType" (fhir-spec (string->symbol "MedicationKnowledge.productType") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.productType" 'element))
(register-element! "MedicationKnowledge.monograph" (fhir-spec (string->symbol "MedicationKnowledge.monograph") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monograph" 'element))
(register-element! "MedicationKnowledge.ingredient" (fhir-spec (string->symbol "MedicationKnowledge.ingredient") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient" 'element))
(register-element! "MedicationKnowledge.preparationInstruction" (fhir-spec (string->symbol "MedicationKnowledge.preparationInstruction") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.preparationInstruction" 'element))
(register-element! "MedicationKnowledge.intendedRoute" (fhir-spec (string->symbol "MedicationKnowledge.intendedRoute") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.intendedRoute" 'element))
(register-element! "MedicationKnowledge.cost" (fhir-spec (string->symbol "MedicationKnowledge.cost") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost" 'element))
(register-element! "MedicationKnowledge.monitoringProgram" (fhir-spec (string->symbol "MedicationKnowledge.monitoringProgram") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monitoringProgram" 'element))
(register-element! "MedicationKnowledge.administrationGuidelines" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines" 'element))
(register-element! "MedicationKnowledge.medicineClassification" (fhir-spec (string->symbol "MedicationKnowledge.medicineClassification") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.medicineClassification" 'element))
(register-element! "MedicationKnowledge.packaging" (fhir-spec (string->symbol "MedicationKnowledge.packaging") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.packaging" 'element))
(register-element! "MedicationKnowledge.drugCharacteristic" (fhir-spec (string->symbol "MedicationKnowledge.drugCharacteristic") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic" 'element))
(register-element! "MedicationKnowledge.contraindication" (fhir-spec (string->symbol "MedicationKnowledge.contraindication") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.contraindication" 'element))
(register-element! "MedicationKnowledge.regulatory" (fhir-spec (string->symbol "MedicationKnowledge.regulatory") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory" 'element))
(register-element! "MedicationKnowledge.kinetics" (fhir-spec (string->symbol "MedicationKnowledge.kinetics") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics" 'element))

(register-type! 'MedicationKnowledgeRelatedMedicationKnowledge (fhir-spec 'MedicationKnowledgeRelatedMedicationKnowledge "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge" 'type)
  #:schema (type-schema 'MedicationKnowledgeRelatedMedicationKnowledge #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge.type" #f)
    (schema-field 'reference 1 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge.reference" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.relatedMedicationKnowledge.type" (fhir-spec (string->symbol "MedicationKnowledge.relatedMedicationKnowledge.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge.type" 'element))
(register-element! "MedicationKnowledge.relatedMedicationKnowledge.reference" (fhir-spec (string->symbol "MedicationKnowledge.relatedMedicationKnowledge.reference") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge.reference" 'element))

(register-type! 'MedicationKnowledgeMonograph (fhir-spec 'MedicationKnowledgeMonograph "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monograph" 'type)
  #:schema (type-schema 'MedicationKnowledgeMonograph #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monograph"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monograph.type" #f)
    (schema-field 'source 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monograph.source" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.monograph.type" (fhir-spec (string->symbol "MedicationKnowledge.monograph.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monograph.type" 'element))
(register-element! "MedicationKnowledge.monograph.source" (fhir-spec (string->symbol "MedicationKnowledge.monograph.source") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monograph.source" 'element))

(register-type! 'MedicationKnowledgeIngredient (fhir-spec 'MedicationKnowledgeIngredient "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient" 'type)
  #:schema (type-schema 'MedicationKnowledgeIngredient #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient"
             (list
    (schema-field 'isActive 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient.isActive" #f)
    (schema-field 'strength 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient.strength" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient.item[x]" #f)
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient.item[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.ingredient.isActive" (fhir-spec (string->symbol "MedicationKnowledge.ingredient.isActive") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient.isActive" 'element))
(register-element! "MedicationKnowledge.ingredient.strength" (fhir-spec (string->symbol "MedicationKnowledge.ingredient.strength") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient.strength" 'element))
(register-element! "MedicationKnowledge.ingredient.item[x]" (fhir-spec (string->symbol "MedicationKnowledge.ingredient.item[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient.item[x]" 'element))
(register-element! "MedicationKnowledge.ingredient.item[x]" (fhir-spec (string->symbol "MedicationKnowledge.ingredient.item[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.ingredient.item[x]" 'element))

(register-type! 'MedicationKnowledgeCost (fhir-spec 'MedicationKnowledgeCost "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost" 'type)
  #:schema (type-schema 'MedicationKnowledgeCost #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost.type" #f)
    (schema-field 'source 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost.source" #f)
    (schema-field 'cost 1 1 (vector 'type 'Money) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost.cost" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.cost.type" (fhir-spec (string->symbol "MedicationKnowledge.cost.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost.type" 'element))
(register-element! "MedicationKnowledge.cost.source" (fhir-spec (string->symbol "MedicationKnowledge.cost.source") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost.source" 'element))
(register-element! "MedicationKnowledge.cost.cost" (fhir-spec (string->symbol "MedicationKnowledge.cost.cost") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.cost.cost" 'element))

(register-type! 'MedicationKnowledgeMonitoringProgram (fhir-spec 'MedicationKnowledgeMonitoringProgram "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monitoringProgram" 'type)
  #:schema (type-schema 'MedicationKnowledgeMonitoringProgram #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monitoringProgram"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monitoringProgram.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monitoringProgram.name" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.monitoringProgram.type" (fhir-spec (string->symbol "MedicationKnowledge.monitoringProgram.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monitoringProgram.type" 'element))
(register-element! "MedicationKnowledge.monitoringProgram.name" (fhir-spec (string->symbol "MedicationKnowledge.monitoringProgram.name") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.monitoringProgram.name" 'element))

(register-type! 'MedicationKnowledgeAdministrationGuidelines (fhir-spec 'MedicationKnowledgeAdministrationGuidelines "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines" 'type)
  #:schema (type-schema 'MedicationKnowledgeAdministrationGuidelines #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines"
             (list
    (schema-field 'dosage 0 '* (vector 'type 'MedicationKnowledgeAdministrationGuidelinesDosage) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.dosage" #f)
    (schema-field 'patientCharacteristics 0 '* (vector 'type 'MedicationKnowledgeAdministrationGuidelinesPatientCharacteristics) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics" #f)
    (schema-field 'indicationCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'indication "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.indication[x]" #f)
    (schema-field 'indicationReference 0 1 (vector 'type 'Reference) 'indication "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.indication[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.administrationGuidelines.dosage" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.dosage") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.dosage" 'element))
(register-element! "MedicationKnowledge.administrationGuidelines.patientCharacteristics" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.patientCharacteristics") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics" 'element))
(register-element! "MedicationKnowledge.administrationGuidelines.indication[x]" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.indication[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.indication[x]" 'element))
(register-element! "MedicationKnowledge.administrationGuidelines.indication[x]" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.indication[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.indication[x]" 'element))

(register-type! 'MedicationKnowledgeAdministrationGuidelinesDosage (fhir-spec 'MedicationKnowledgeAdministrationGuidelinesDosage "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.dosage" 'type)
  #:schema (type-schema 'MedicationKnowledgeAdministrationGuidelinesDosage #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.dosage"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.dosage.type" #f)
    (schema-field 'dosage 1 '* (vector 'type 'Dosage) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.dosage.dosage" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.administrationGuidelines.dosage.type" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.dosage.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.dosage.type" 'element))
(register-element! "MedicationKnowledge.administrationGuidelines.dosage.dosage" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.dosage.dosage") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.dosage.dosage" 'element))

(register-type! 'MedicationKnowledgeAdministrationGuidelinesPatientCharacteristics (fhir-spec 'MedicationKnowledgeAdministrationGuidelinesPatientCharacteristics "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics" 'type)
  #:schema (type-schema 'MedicationKnowledgeAdministrationGuidelinesPatientCharacteristics #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics"
             (list
    (schema-field 'value 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics.value" #f)
    (schema-field 'characteristicCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'characteristic "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics.characteristic[x]" #f)
    (schema-field 'characteristicQuantity 0 1 (vector 'type 'Quantity) 'characteristic "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics.characteristic[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.administrationGuidelines.patientCharacteristics.value" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.patientCharacteristics.value") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics.value" 'element))
(register-element! "MedicationKnowledge.administrationGuidelines.patientCharacteristics.characteristic[x]" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.patientCharacteristics.characteristic[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics.characteristic[x]" 'element))
(register-element! "MedicationKnowledge.administrationGuidelines.patientCharacteristics.characteristic[x]" (fhir-spec (string->symbol "MedicationKnowledge.administrationGuidelines.patientCharacteristics.characteristic[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.administrationGuidelines.patientCharacteristics.characteristic[x]" 'element))

(register-type! 'MedicationKnowledgeMedicineClassification (fhir-spec 'MedicationKnowledgeMedicineClassification "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.medicineClassification" 'type)
  #:schema (type-schema 'MedicationKnowledgeMedicineClassification #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.medicineClassification"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.medicineClassification.type" #f)
    (schema-field 'classification 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.medicineClassification.classification" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.medicineClassification.type" (fhir-spec (string->symbol "MedicationKnowledge.medicineClassification.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.medicineClassification.type" 'element))
(register-element! "MedicationKnowledge.medicineClassification.classification" (fhir-spec (string->symbol "MedicationKnowledge.medicineClassification.classification") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.medicineClassification.classification" 'element))

(register-type! 'MedicationKnowledgePackaging (fhir-spec 'MedicationKnowledgePackaging "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.packaging" 'type)
  #:schema (type-schema 'MedicationKnowledgePackaging #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.packaging"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.packaging.type" #f)
    (schema-field 'quantity 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.packaging.quantity" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.packaging.type" (fhir-spec (string->symbol "MedicationKnowledge.packaging.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.packaging.type" 'element))
(register-element! "MedicationKnowledge.packaging.quantity" (fhir-spec (string->symbol "MedicationKnowledge.packaging.quantity") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.packaging.quantity" 'element))

(register-type! 'MedicationKnowledgeDrugCharacteristic (fhir-spec 'MedicationKnowledgeDrugCharacteristic "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic" 'type)
  #:schema (type-schema 'MedicationKnowledgeDrugCharacteristic #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.type" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.value[x]" #f)
    (schema-field 'valueString 0 1 (vector 'prim "string") 'value "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.value[x]" #f)
    (schema-field 'valueBase64Binary 0 1 (vector 'prim "base64Binary") 'value "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.value[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.drugCharacteristic.type" (fhir-spec (string->symbol "MedicationKnowledge.drugCharacteristic.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.type" 'element))
(register-element! "MedicationKnowledge.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.drugCharacteristic.value[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.drugCharacteristic.value[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.drugCharacteristic.value[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.drugCharacteristic.value[x]") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.drugCharacteristic.value[x]" 'element))

(register-type! 'MedicationKnowledgeRegulatory (fhir-spec 'MedicationKnowledgeRegulatory "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory" 'type)
  #:schema (type-schema 'MedicationKnowledgeRegulatory #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory"
             (list
    (schema-field 'regulatoryAuthority 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.regulatoryAuthority" #f)
    (schema-field 'substitution 0 '* (vector 'type 'MedicationKnowledgeRegulatorySubstitution) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.substitution" #f)
    (schema-field 'schedule 0 '* (vector 'type 'MedicationKnowledgeRegulatorySchedule) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.schedule" #f)
    (schema-field 'maxDispense 0 1 (vector 'type 'MedicationKnowledgeRegulatoryMaxDispense) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.regulatory.regulatoryAuthority" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.regulatoryAuthority") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.regulatoryAuthority" 'element))
(register-element! "MedicationKnowledge.regulatory.substitution" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.substitution") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.substitution" 'element))
(register-element! "MedicationKnowledge.regulatory.schedule" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.schedule") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.schedule" 'element))
(register-element! "MedicationKnowledge.regulatory.maxDispense" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.maxDispense") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense" 'element))

(register-type! 'MedicationKnowledgeRegulatorySubstitution (fhir-spec 'MedicationKnowledgeRegulatorySubstitution "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.substitution" 'type)
  #:schema (type-schema 'MedicationKnowledgeRegulatorySubstitution #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.substitution"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.substitution.type" #f)
    (schema-field 'allowed 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.substitution.allowed" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.regulatory.substitution.type" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.substitution.type") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.substitution.type" 'element))
(register-element! "MedicationKnowledge.regulatory.substitution.allowed" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.substitution.allowed") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.substitution.allowed" 'element))

(register-type! 'MedicationKnowledgeRegulatorySchedule (fhir-spec 'MedicationKnowledgeRegulatorySchedule "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.schedule" 'type)
  #:schema (type-schema 'MedicationKnowledgeRegulatorySchedule #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.schedule"
             (list
    (schema-field 'schedule 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.schedule.schedule" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.regulatory.schedule.schedule" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.schedule.schedule") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.schedule.schedule" 'element))

(register-type! 'MedicationKnowledgeRegulatoryMaxDispense (fhir-spec 'MedicationKnowledgeRegulatoryMaxDispense "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense" 'type)
  #:schema (type-schema 'MedicationKnowledgeRegulatoryMaxDispense #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense"
             (list
    (schema-field 'quantity 1 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense.quantity" #f)
    (schema-field 'period 0 1 (vector 'type 'Duration) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense.period" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.regulatory.maxDispense.quantity" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.maxDispense.quantity") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense.quantity" 'element))
(register-element! "MedicationKnowledge.regulatory.maxDispense.period" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.maxDispense.period") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense.period" 'element))

(register-type! 'MedicationKnowledgeKinetics (fhir-spec 'MedicationKnowledgeKinetics "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics" 'type)
  #:schema (type-schema 'MedicationKnowledgeKinetics #f 'BackboneElement "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics"
             (list
    (schema-field 'areaUnderCurve 0 '* (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics.areaUnderCurve" #f)
    (schema-field 'lethalDose50 0 '* (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics.lethalDose50" #f)
    (schema-field 'halfLifePeriod 0 1 (vector 'type 'Duration) #f "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics.halfLifePeriod" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.kinetics.areaUnderCurve" (fhir-spec (string->symbol "MedicationKnowledge.kinetics.areaUnderCurve") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics.areaUnderCurve" 'element))
(register-element! "MedicationKnowledge.kinetics.lethalDose50" (fhir-spec (string->symbol "MedicationKnowledge.kinetics.lethalDose50") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics.lethalDose50" 'element))
(register-element! "MedicationKnowledge.kinetics.halfLifePeriod" (fhir-spec (string->symbol "MedicationKnowledge.kinetics.halfLifePeriod") "https://hl7.org/fhir/R4/medicationknowledge.html#MedicationKnowledge.kinetics.halfLifePeriod" 'element))

