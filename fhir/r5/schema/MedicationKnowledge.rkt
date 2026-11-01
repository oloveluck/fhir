#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicationKnowledge (fhir-spec 'MedicationKnowledge "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge" 'type)
  #:schema (type-schema 'MedicationKnowledge #f 'DomainResource "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.identifier" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.code" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.status" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.author" #f)
    (schema-field 'intendedJurisdiction 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.intendedJurisdiction" #f)
    (schema-field 'name 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.name" #f)
    (schema-field 'relatedMedicationKnowledge 0 '* (vector 'type 'MedicationKnowledgeRelatedMedicationKnowledge) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge" #f)
    (schema-field 'associatedMedication 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.associatedMedication" #f)
    (schema-field 'productType 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.productType" #f)
    (schema-field 'monograph 0 '* (vector 'type 'MedicationKnowledgeMonograph) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monograph" #f)
    (schema-field 'preparationInstruction 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.preparationInstruction" #f)
    (schema-field 'cost 0 '* (vector 'type 'MedicationKnowledgeCost) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost" #f)
    (schema-field 'monitoringProgram 0 '* (vector 'type 'MedicationKnowledgeMonitoringProgram) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monitoringProgram" #f)
    (schema-field 'indicationGuideline 0 '* (vector 'type 'MedicationKnowledgeIndicationGuideline) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline" #f)
    (schema-field 'medicineClassification 0 '* (vector 'type 'MedicationKnowledgeMedicineClassification) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification" #f)
    (schema-field 'packaging 0 '* (vector 'type 'MedicationKnowledgePackaging) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.packaging" #f)
    (schema-field 'clinicalUseIssue 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.clinicalUseIssue" #f)
    (schema-field 'storageGuideline 0 '* (vector 'type 'MedicationKnowledgeStorageGuideline) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline" #f)
    (schema-field 'regulatory 0 '* (vector 'type 'MedicationKnowledgeRegulatory) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory" #f)
    (schema-field 'definitional 0 1 (vector 'type 'MedicationKnowledgeDefinitional) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.identifier" (fhir-spec (string->symbol "MedicationKnowledge.identifier") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.identifier" 'element))
(register-element! "MedicationKnowledge.code" (fhir-spec (string->symbol "MedicationKnowledge.code") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.code" 'element))
(register-element! "MedicationKnowledge.status" (fhir-spec (string->symbol "MedicationKnowledge.status") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.status" 'element))
(register-element! "MedicationKnowledge.author" (fhir-spec (string->symbol "MedicationKnowledge.author") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.author" 'element))
(register-element! "MedicationKnowledge.intendedJurisdiction" (fhir-spec (string->symbol "MedicationKnowledge.intendedJurisdiction") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.intendedJurisdiction" 'element))
(register-element! "MedicationKnowledge.name" (fhir-spec (string->symbol "MedicationKnowledge.name") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.name" 'element))
(register-element! "MedicationKnowledge.relatedMedicationKnowledge" (fhir-spec (string->symbol "MedicationKnowledge.relatedMedicationKnowledge") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge" 'element))
(register-element! "MedicationKnowledge.associatedMedication" (fhir-spec (string->symbol "MedicationKnowledge.associatedMedication") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.associatedMedication" 'element))
(register-element! "MedicationKnowledge.productType" (fhir-spec (string->symbol "MedicationKnowledge.productType") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.productType" 'element))
(register-element! "MedicationKnowledge.monograph" (fhir-spec (string->symbol "MedicationKnowledge.monograph") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monograph" 'element))
(register-element! "MedicationKnowledge.preparationInstruction" (fhir-spec (string->symbol "MedicationKnowledge.preparationInstruction") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.preparationInstruction" 'element))
(register-element! "MedicationKnowledge.cost" (fhir-spec (string->symbol "MedicationKnowledge.cost") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost" 'element))
(register-element! "MedicationKnowledge.monitoringProgram" (fhir-spec (string->symbol "MedicationKnowledge.monitoringProgram") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monitoringProgram" 'element))
(register-element! "MedicationKnowledge.indicationGuideline" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline" 'element))
(register-element! "MedicationKnowledge.medicineClassification" (fhir-spec (string->symbol "MedicationKnowledge.medicineClassification") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification" 'element))
(register-element! "MedicationKnowledge.packaging" (fhir-spec (string->symbol "MedicationKnowledge.packaging") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.packaging" 'element))
(register-element! "MedicationKnowledge.clinicalUseIssue" (fhir-spec (string->symbol "MedicationKnowledge.clinicalUseIssue") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.clinicalUseIssue" 'element))
(register-element! "MedicationKnowledge.storageGuideline" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline" 'element))
(register-element! "MedicationKnowledge.regulatory" (fhir-spec (string->symbol "MedicationKnowledge.regulatory") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory" 'element))
(register-element! "MedicationKnowledge.definitional" (fhir-spec (string->symbol "MedicationKnowledge.definitional") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional" 'element))

(register-type! 'MedicationKnowledgeRelatedMedicationKnowledge (fhir-spec 'MedicationKnowledgeRelatedMedicationKnowledge "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge" 'type)
  #:schema (type-schema 'MedicationKnowledgeRelatedMedicationKnowledge #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge.type" #f)
    (schema-field 'reference 1 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge.reference" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.relatedMedicationKnowledge.type" (fhir-spec (string->symbol "MedicationKnowledge.relatedMedicationKnowledge.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge.type" 'element))
(register-element! "MedicationKnowledge.relatedMedicationKnowledge.reference" (fhir-spec (string->symbol "MedicationKnowledge.relatedMedicationKnowledge.reference") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.relatedMedicationKnowledge.reference" 'element))

(register-type! 'MedicationKnowledgeMonograph (fhir-spec 'MedicationKnowledgeMonograph "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monograph" 'type)
  #:schema (type-schema 'MedicationKnowledgeMonograph #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monograph"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monograph.type" #f)
    (schema-field 'source 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monograph.source" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.monograph.type" (fhir-spec (string->symbol "MedicationKnowledge.monograph.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monograph.type" 'element))
(register-element! "MedicationKnowledge.monograph.source" (fhir-spec (string->symbol "MedicationKnowledge.monograph.source") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monograph.source" 'element))

(register-type! 'MedicationKnowledgeCost (fhir-spec 'MedicationKnowledgeCost "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost" 'type)
  #:schema (type-schema 'MedicationKnowledgeCost #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost"
             (list
    (schema-field 'effectiveDate 0 '* (vector 'type 'Period) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.effectiveDate" #f)
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.type" #f)
    (schema-field 'source 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.source" #f)
    (schema-field 'costMoney 0 1 (vector 'type 'Money) 'cost "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.cost[x]" #f)
    (schema-field 'costCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'cost "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.cost[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.cost.effectiveDate" (fhir-spec (string->symbol "MedicationKnowledge.cost.effectiveDate") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.effectiveDate" 'element))
(register-element! "MedicationKnowledge.cost.type" (fhir-spec (string->symbol "MedicationKnowledge.cost.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.type" 'element))
(register-element! "MedicationKnowledge.cost.source" (fhir-spec (string->symbol "MedicationKnowledge.cost.source") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.source" 'element))
(register-element! "MedicationKnowledge.cost.cost[x]" (fhir-spec (string->symbol "MedicationKnowledge.cost.cost[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.cost[x]" 'element))
(register-element! "MedicationKnowledge.cost.cost[x]" (fhir-spec (string->symbol "MedicationKnowledge.cost.cost[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.cost.cost[x]" 'element))

(register-type! 'MedicationKnowledgeMonitoringProgram (fhir-spec 'MedicationKnowledgeMonitoringProgram "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monitoringProgram" 'type)
  #:schema (type-schema 'MedicationKnowledgeMonitoringProgram #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monitoringProgram"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monitoringProgram.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monitoringProgram.name" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.monitoringProgram.type" (fhir-spec (string->symbol "MedicationKnowledge.monitoringProgram.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monitoringProgram.type" 'element))
(register-element! "MedicationKnowledge.monitoringProgram.name" (fhir-spec (string->symbol "MedicationKnowledge.monitoringProgram.name") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.monitoringProgram.name" 'element))

(register-type! 'MedicationKnowledgeIndicationGuideline (fhir-spec 'MedicationKnowledgeIndicationGuideline "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline" 'type)
  #:schema (type-schema 'MedicationKnowledgeIndicationGuideline #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline"
             (list
    (schema-field 'indication 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.indication" #f)
    (schema-field 'dosingGuideline 0 '* (vector 'type 'MedicationKnowledgeIndicationGuidelineDosingGuideline) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.indicationGuideline.indication" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.indication") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.indication" 'element))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline" 'element))

(register-type! 'MedicationKnowledgeIndicationGuidelineDosingGuideline (fhir-spec 'MedicationKnowledgeIndicationGuidelineDosingGuideline "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline" 'type)
  #:schema (type-schema 'MedicationKnowledgeIndicationGuidelineDosingGuideline #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline"
             (list
    (schema-field 'treatmentIntent 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.treatmentIntent" #f)
    (schema-field 'dosage 0 '* (vector 'type 'MedicationKnowledgeIndicationGuidelineDosingGuidelineDosage) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.dosage" #f)
    (schema-field 'administrationTreatment 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.administrationTreatment" #f)
    (schema-field 'patientCharacteristic 0 '* (vector 'type 'MedicationKnowledgeIndicationGuidelineDosingGuidelinePatientCharacteristic) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.treatmentIntent" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.treatmentIntent") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.treatmentIntent" 'element))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.dosage" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.dosage") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.dosage" 'element))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.administrationTreatment" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.administrationTreatment") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.administrationTreatment" 'element))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic" 'element))

(register-type! 'MedicationKnowledgeIndicationGuidelineDosingGuidelineDosage (fhir-spec 'MedicationKnowledgeIndicationGuidelineDosingGuidelineDosage "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.dosage" 'type)
  #:schema (type-schema 'MedicationKnowledgeIndicationGuidelineDosingGuidelineDosage #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.dosage"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.dosage.type" #f)
    (schema-field 'dosage 1 '* (vector 'type 'Dosage) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.dosage.dosage" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.dosage.type" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.dosage.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.dosage.type" 'element))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.dosage.dosage" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.dosage.dosage") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.dosage.dosage" 'element))

(register-type! 'MedicationKnowledgeIndicationGuidelineDosingGuidelinePatientCharacteristic (fhir-spec 'MedicationKnowledgeIndicationGuidelineDosingGuidelinePatientCharacteristic "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic" 'type)
  #:schema (type-schema 'MedicationKnowledgeIndicationGuidelineDosingGuidelinePatientCharacteristic #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.type" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" #f)
    (schema-field 'valueRange 0 1 (vector 'type 'Range) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.type" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.type" 'element))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.indicationGuideline.dosingGuideline.patientCharacteristic.value[x]" 'element))

(register-type! 'MedicationKnowledgeMedicineClassification (fhir-spec 'MedicationKnowledgeMedicineClassification "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification" 'type)
  #:schema (type-schema 'MedicationKnowledgeMedicineClassification #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification.type" #f)
    (schema-field 'classification 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification.classification" #f)
    (schema-field 'sourceString 0 1 (vector 'prim "string") 'source "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification.source[x]" #f)
    (schema-field 'sourceUri 0 1 (vector 'prim "uri") 'source "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification.source[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.medicineClassification.type" (fhir-spec (string->symbol "MedicationKnowledge.medicineClassification.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification.type" 'element))
(register-element! "MedicationKnowledge.medicineClassification.classification" (fhir-spec (string->symbol "MedicationKnowledge.medicineClassification.classification") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification.classification" 'element))
(register-element! "MedicationKnowledge.medicineClassification.source[x]" (fhir-spec (string->symbol "MedicationKnowledge.medicineClassification.source[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification.source[x]" 'element))
(register-element! "MedicationKnowledge.medicineClassification.source[x]" (fhir-spec (string->symbol "MedicationKnowledge.medicineClassification.source[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.medicineClassification.source[x]" 'element))

(register-type! 'MedicationKnowledgePackaging (fhir-spec 'MedicationKnowledgePackaging "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.packaging" 'type)
  #:schema (type-schema 'MedicationKnowledgePackaging #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.packaging"
             (list
    (schema-field 'cost 0 '* (vector 'type 'MedicationKnowledgeCost) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.packaging.cost" #f)
    (schema-field 'packagedProduct 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.packaging.packagedProduct" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.packaging.cost" (fhir-spec (string->symbol "MedicationKnowledge.packaging.cost") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.packaging.cost" 'element))
(register-element! "MedicationKnowledge.packaging.packagedProduct" (fhir-spec (string->symbol "MedicationKnowledge.packaging.packagedProduct") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.packaging.packagedProduct" 'element))

(register-type! 'MedicationKnowledgeStorageGuideline (fhir-spec 'MedicationKnowledgeStorageGuideline "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline" 'type)
  #:schema (type-schema 'MedicationKnowledgeStorageGuideline #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline"
             (list
    (schema-field 'reference 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.reference" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.note" #f)
    (schema-field 'stabilityDuration 0 1 (vector 'type 'Duration) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.stabilityDuration" #f)
    (schema-field 'environmentalSetting 0 '* (vector 'type 'MedicationKnowledgeStorageGuidelineEnvironmentalSetting) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.storageGuideline.reference" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline.reference") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.reference" 'element))
(register-element! "MedicationKnowledge.storageGuideline.note" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline.note") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.note" 'element))
(register-element! "MedicationKnowledge.storageGuideline.stabilityDuration" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline.stabilityDuration") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.stabilityDuration" 'element))
(register-element! "MedicationKnowledge.storageGuideline.environmentalSetting" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline.environmentalSetting") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting" 'element))

(register-type! 'MedicationKnowledgeStorageGuidelineEnvironmentalSetting (fhir-spec 'MedicationKnowledgeStorageGuidelineEnvironmentalSetting "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting" 'type)
  #:schema (type-schema 'MedicationKnowledgeStorageGuidelineEnvironmentalSetting #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting.type" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" #f)
    (schema-field 'valueRange 0 1 (vector 'type 'Range) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.storageGuideline.environmentalSetting.type" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline.environmentalSetting.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting.type" 'element))
(register-element! "MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline.environmentalSetting.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" 'element))
(register-element! "MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline.environmentalSetting.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" 'element))
(register-element! "MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.storageGuideline.environmentalSetting.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.storageGuideline.environmentalSetting.value[x]" 'element))

(register-type! 'MedicationKnowledgeRegulatory (fhir-spec 'MedicationKnowledgeRegulatory "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory" 'type)
  #:schema (type-schema 'MedicationKnowledgeRegulatory #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory"
             (list
    (schema-field 'regulatoryAuthority 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.regulatoryAuthority" #f)
    (schema-field 'substitution 0 '* (vector 'type 'MedicationKnowledgeRegulatorySubstitution) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.substitution" #f)
    (schema-field 'schedule 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.schedule" #f)
    (schema-field 'maxDispense 0 1 (vector 'type 'MedicationKnowledgeRegulatoryMaxDispense) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.regulatory.regulatoryAuthority" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.regulatoryAuthority") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.regulatoryAuthority" 'element))
(register-element! "MedicationKnowledge.regulatory.substitution" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.substitution") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.substitution" 'element))
(register-element! "MedicationKnowledge.regulatory.schedule" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.schedule") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.schedule" 'element))
(register-element! "MedicationKnowledge.regulatory.maxDispense" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.maxDispense") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense" 'element))

(register-type! 'MedicationKnowledgeRegulatorySubstitution (fhir-spec 'MedicationKnowledgeRegulatorySubstitution "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.substitution" 'type)
  #:schema (type-schema 'MedicationKnowledgeRegulatorySubstitution #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.substitution"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.substitution.type" #f)
    (schema-field 'allowed 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.substitution.allowed" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.regulatory.substitution.type" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.substitution.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.substitution.type" 'element))
(register-element! "MedicationKnowledge.regulatory.substitution.allowed" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.substitution.allowed") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.substitution.allowed" 'element))

(register-type! 'MedicationKnowledgeRegulatoryMaxDispense (fhir-spec 'MedicationKnowledgeRegulatoryMaxDispense "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense" 'type)
  #:schema (type-schema 'MedicationKnowledgeRegulatoryMaxDispense #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense"
             (list
    (schema-field 'quantity 1 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense.quantity" #f)
    (schema-field 'period 0 1 (vector 'type 'Duration) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense.period" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.regulatory.maxDispense.quantity" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.maxDispense.quantity") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense.quantity" 'element))
(register-element! "MedicationKnowledge.regulatory.maxDispense.period" (fhir-spec (string->symbol "MedicationKnowledge.regulatory.maxDispense.period") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.regulatory.maxDispense.period" 'element))

(register-type! 'MedicationKnowledgeDefinitional (fhir-spec 'MedicationKnowledgeDefinitional "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional" 'type)
  #:schema (type-schema 'MedicationKnowledgeDefinitional #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional"
             (list
    (schema-field 'definition 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.definition" #f)
    (schema-field 'doseForm 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.doseForm" #f)
    (schema-field 'intendedRoute 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.intendedRoute" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'MedicationKnowledgeDefinitionalIngredient) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient" #f)
    (schema-field 'drugCharacteristic 0 '* (vector 'type 'MedicationKnowledgeDefinitionalDrugCharacteristic) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.definitional.definition" (fhir-spec (string->symbol "MedicationKnowledge.definitional.definition") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.definition" 'element))
(register-element! "MedicationKnowledge.definitional.doseForm" (fhir-spec (string->symbol "MedicationKnowledge.definitional.doseForm") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.doseForm" 'element))
(register-element! "MedicationKnowledge.definitional.intendedRoute" (fhir-spec (string->symbol "MedicationKnowledge.definitional.intendedRoute") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.intendedRoute" 'element))
(register-element! "MedicationKnowledge.definitional.ingredient" (fhir-spec (string->symbol "MedicationKnowledge.definitional.ingredient") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient" 'element))
(register-element! "MedicationKnowledge.definitional.drugCharacteristic" (fhir-spec (string->symbol "MedicationKnowledge.definitional.drugCharacteristic") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic" 'element))

(register-type! 'MedicationKnowledgeDefinitionalIngredient (fhir-spec 'MedicationKnowledgeDefinitionalIngredient "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient" 'type)
  #:schema (type-schema 'MedicationKnowledgeDefinitionalIngredient #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient"
             (list
    (schema-field 'item 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.item" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.type" #f)
    (schema-field 'strengthRatio 0 1 (vector 'type 'Ratio) 'strength "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.strength[x]" #f)
    (schema-field 'strengthCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'strength "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.strength[x]" #f)
    (schema-field 'strengthQuantity 0 1 (vector 'type 'Quantity) 'strength "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.strength[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.definitional.ingredient.item" (fhir-spec (string->symbol "MedicationKnowledge.definitional.ingredient.item") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.item" 'element))
(register-element! "MedicationKnowledge.definitional.ingredient.type" (fhir-spec (string->symbol "MedicationKnowledge.definitional.ingredient.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.type" 'element))
(register-element! "MedicationKnowledge.definitional.ingredient.strength[x]" (fhir-spec (string->symbol "MedicationKnowledge.definitional.ingredient.strength[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.strength[x]" 'element))
(register-element! "MedicationKnowledge.definitional.ingredient.strength[x]" (fhir-spec (string->symbol "MedicationKnowledge.definitional.ingredient.strength[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.strength[x]" 'element))
(register-element! "MedicationKnowledge.definitional.ingredient.strength[x]" (fhir-spec (string->symbol "MedicationKnowledge.definitional.ingredient.strength[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.ingredient.strength[x]" 'element))

(register-type! 'MedicationKnowledgeDefinitionalDrugCharacteristic (fhir-spec 'MedicationKnowledgeDefinitionalDrugCharacteristic "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic" 'type)
  #:schema (type-schema 'MedicationKnowledgeDefinitionalDrugCharacteristic #f 'BackboneElement "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.type" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" #f)
    (schema-field 'valueString 0 1 (vector 'prim "string") 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" #f)
    (schema-field 'valueBase64Binary 0 1 (vector 'prim "base64Binary") 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" #f)
    (schema-field 'valueAttachment 0 1 (vector 'type 'Attachment) 'value "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" #f)
             ) #f #f))
(register-element! "MedicationKnowledge.definitional.drugCharacteristic.type" (fhir-spec (string->symbol "MedicationKnowledge.definitional.drugCharacteristic.type") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.type" 'element))
(register-element! "MedicationKnowledge.definitional.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.definitional.drugCharacteristic.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.definitional.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.definitional.drugCharacteristic.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.definitional.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.definitional.drugCharacteristic.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.definitional.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.definitional.drugCharacteristic.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" 'element))
(register-element! "MedicationKnowledge.definitional.drugCharacteristic.value[x]" (fhir-spec (string->symbol "MedicationKnowledge.definitional.drugCharacteristic.value[x]") "https://hl7.org/fhir/R5/medicationknowledge.html#MedicationKnowledge.definitional.drugCharacteristic.value[x]" 'element))

