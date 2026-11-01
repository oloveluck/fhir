#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ClinicalUseDefinition (fhir-spec 'ClinicalUseDefinition "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition" 'type)
  #:schema (type-schema 'ClinicalUseDefinition #f 'DomainResource "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.identifier" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.type" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.category" #f)
    (schema-field 'subject 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.subject" #f)
    (schema-field 'status 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.status" #f)
    (schema-field 'contraindication 0 1 (vector 'type 'ClinicalUseDefinitionContraindication) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication" #f)
    (schema-field 'indication 0 1 (vector 'type 'ClinicalUseDefinitionIndication) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication" #f)
    (schema-field 'interaction 0 1 (vector 'type 'ClinicalUseDefinitionInteraction) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction" #f)
    (schema-field 'population 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.population" #f)
    (schema-field 'library 0 '* (vector 'prim "canonical") #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.library" #f)
    (schema-field 'undesirableEffect 0 1 (vector 'type 'ClinicalUseDefinitionUndesirableEffect) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect" #f)
    (schema-field 'warning 0 1 (vector 'type 'ClinicalUseDefinitionWarning) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.warning" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.identifier" (fhir-spec (string->symbol "ClinicalUseDefinition.identifier") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.identifier" 'element))
(register-element! "ClinicalUseDefinition.type" (fhir-spec (string->symbol "ClinicalUseDefinition.type") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.type" 'element))
(register-element! "ClinicalUseDefinition.category" (fhir-spec (string->symbol "ClinicalUseDefinition.category") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.category" 'element))
(register-element! "ClinicalUseDefinition.subject" (fhir-spec (string->symbol "ClinicalUseDefinition.subject") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.subject" 'element))
(register-element! "ClinicalUseDefinition.status" (fhir-spec (string->symbol "ClinicalUseDefinition.status") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.status" 'element))
(register-element! "ClinicalUseDefinition.contraindication" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication" 'element))
(register-element! "ClinicalUseDefinition.indication" (fhir-spec (string->symbol "ClinicalUseDefinition.indication") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication" 'element))
(register-element! "ClinicalUseDefinition.interaction" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction" 'element))
(register-element! "ClinicalUseDefinition.population" (fhir-spec (string->symbol "ClinicalUseDefinition.population") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.population" 'element))
(register-element! "ClinicalUseDefinition.library" (fhir-spec (string->symbol "ClinicalUseDefinition.library") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.library" 'element))
(register-element! "ClinicalUseDefinition.undesirableEffect" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect" 'element))
(register-element! "ClinicalUseDefinition.warning" (fhir-spec (string->symbol "ClinicalUseDefinition.warning") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.warning" 'element))

(register-type! 'ClinicalUseDefinitionContraindication (fhir-spec 'ClinicalUseDefinitionContraindication "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionContraindication #f 'BackboneElement "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication"
             (list
    (schema-field 'diseaseSymptomProcedure 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.diseaseSymptomProcedure" #f)
    (schema-field 'diseaseStatus 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.diseaseStatus" #f)
    (schema-field 'comorbidity 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.comorbidity" #f)
    (schema-field 'indication 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.indication" #f)
    (schema-field 'applicability 0 1 (vector 'type 'Expression) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.applicability" #f)
    (schema-field 'otherTherapy 0 '* (vector 'type 'ClinicalUseDefinitionContraindicationOtherTherapy) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.contraindication.diseaseSymptomProcedure" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.diseaseSymptomProcedure") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.diseaseSymptomProcedure" 'element))
(register-element! "ClinicalUseDefinition.contraindication.diseaseStatus" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.diseaseStatus") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.diseaseStatus" 'element))
(register-element! "ClinicalUseDefinition.contraindication.comorbidity" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.comorbidity") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.comorbidity" 'element))
(register-element! "ClinicalUseDefinition.contraindication.indication" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.indication") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.indication" 'element))
(register-element! "ClinicalUseDefinition.contraindication.applicability" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.applicability") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.applicability" 'element))
(register-element! "ClinicalUseDefinition.contraindication.otherTherapy" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.otherTherapy") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy" 'element))

(register-type! 'ClinicalUseDefinitionContraindicationOtherTherapy (fhir-spec 'ClinicalUseDefinitionContraindicationOtherTherapy "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionContraindicationOtherTherapy #f 'BackboneElement "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy"
             (list
    (schema-field 'relationshipType 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy.relationshipType" #f)
    (schema-field 'treatment 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy.treatment" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.contraindication.otherTherapy.relationshipType" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.otherTherapy.relationshipType") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy.relationshipType" 'element))
(register-element! "ClinicalUseDefinition.contraindication.otherTherapy.treatment" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.otherTherapy.treatment") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy.treatment" 'element))

(register-type! 'ClinicalUseDefinitionIndication (fhir-spec 'ClinicalUseDefinitionIndication "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionIndication #f 'BackboneElement "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication"
             (list
    (schema-field 'diseaseSymptomProcedure 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.diseaseSymptomProcedure" #f)
    (schema-field 'diseaseStatus 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.diseaseStatus" #f)
    (schema-field 'comorbidity 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.comorbidity" #f)
    (schema-field 'intendedEffect 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.intendedEffect" #f)
    (schema-field 'undesirableEffect 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.undesirableEffect" #f)
    (schema-field 'applicability 0 1 (vector 'type 'Expression) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.applicability" #f)
    (schema-field 'otherTherapy 0 '* (vector 'type 'ClinicalUseDefinitionContraindicationOtherTherapy) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy" #f)
    (schema-field 'durationRange 0 1 (vector 'type 'Range) 'duration "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.duration[x]" #f)
    (schema-field 'durationString 0 1 (vector 'prim "string") 'duration "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.duration[x]" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.indication.diseaseSymptomProcedure" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.diseaseSymptomProcedure") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.diseaseSymptomProcedure" 'element))
(register-element! "ClinicalUseDefinition.indication.diseaseStatus" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.diseaseStatus") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.diseaseStatus" 'element))
(register-element! "ClinicalUseDefinition.indication.comorbidity" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.comorbidity") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.comorbidity" 'element))
(register-element! "ClinicalUseDefinition.indication.intendedEffect" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.intendedEffect") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.intendedEffect" 'element))
(register-element! "ClinicalUseDefinition.indication.undesirableEffect" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.undesirableEffect") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.undesirableEffect" 'element))
(register-element! "ClinicalUseDefinition.indication.applicability" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.applicability") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.applicability" 'element))
(register-element! "ClinicalUseDefinition.indication.otherTherapy" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.otherTherapy") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy" 'element))
(register-element! "ClinicalUseDefinition.indication.duration[x]" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.duration[x]") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.duration[x]" 'element))
(register-element! "ClinicalUseDefinition.indication.duration[x]" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.duration[x]") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.indication.duration[x]" 'element))

(register-type! 'ClinicalUseDefinitionInteraction (fhir-spec 'ClinicalUseDefinitionInteraction "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionInteraction #f 'BackboneElement "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction"
             (list
    (schema-field 'interactant 0 '* (vector 'type 'ClinicalUseDefinitionInteractionInteractant) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.type" #f)
    (schema-field 'effect 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.effect" #f)
    (schema-field 'incidence 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.incidence" #f)
    (schema-field 'management 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.management" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.interaction.interactant" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.interactant") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant" 'element))
(register-element! "ClinicalUseDefinition.interaction.type" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.type") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.type" 'element))
(register-element! "ClinicalUseDefinition.interaction.effect" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.effect") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.effect" 'element))
(register-element! "ClinicalUseDefinition.interaction.incidence" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.incidence") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.incidence" 'element))
(register-element! "ClinicalUseDefinition.interaction.management" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.management") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.management" 'element))

(register-type! 'ClinicalUseDefinitionInteractionInteractant (fhir-spec 'ClinicalUseDefinitionInteractionInteractant "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionInteractionInteractant #f 'BackboneElement "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant"
             (list
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.item[x]" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.item[x]" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.interaction.interactant.item[x]" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.interactant.item[x]") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.item[x]" 'element))
(register-element! "ClinicalUseDefinition.interaction.interactant.item[x]" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.interactant.item[x]") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.item[x]" 'element))

(register-type! 'ClinicalUseDefinitionUndesirableEffect (fhir-spec 'ClinicalUseDefinitionUndesirableEffect "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionUndesirableEffect #f 'BackboneElement "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect"
             (list
    (schema-field 'symptomConditionEffect 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.symptomConditionEffect" #f)
    (schema-field 'classification 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.classification" #f)
    (schema-field 'frequencyOfOccurrence 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.frequencyOfOccurrence" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.undesirableEffect.symptomConditionEffect" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect.symptomConditionEffect") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.symptomConditionEffect" 'element))
(register-element! "ClinicalUseDefinition.undesirableEffect.classification" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect.classification") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.classification" 'element))
(register-element! "ClinicalUseDefinition.undesirableEffect.frequencyOfOccurrence" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect.frequencyOfOccurrence") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.frequencyOfOccurrence" 'element))

(register-type! 'ClinicalUseDefinitionWarning (fhir-spec 'ClinicalUseDefinitionWarning "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.warning" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionWarning #f 'BackboneElement "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.warning"
             (list
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.warning.description" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.warning.code" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.warning.description" (fhir-spec (string->symbol "ClinicalUseDefinition.warning.description") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.warning.description" 'element))
(register-element! "ClinicalUseDefinition.warning.code" (fhir-spec (string->symbol "ClinicalUseDefinition.warning.code") "https://hl7.org/fhir/R5/clinicalusedefinition.html#ClinicalUseDefinition.warning.code" 'element))

