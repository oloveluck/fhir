#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ClinicalUseDefinition (fhir-spec 'ClinicalUseDefinition "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition" 'type)
  #:schema (type-schema 'ClinicalUseDefinition #f 'DomainResource "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.identifier" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.type" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.category" #f)
    (schema-field 'subject 1 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.subject" #f)
    (schema-field 'status 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.status" #f)
    (schema-field 'undesirableEffect 0 1 (vector 'type 'ClinicalUseDefinitionUndesirableEffect) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect" #f)
    (schema-field 'indication 0 1 (vector 'type 'ClinicalUseDefinitionIndication) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication" #f)
    (schema-field 'contraindication 0 1 (vector 'type 'ClinicalUseDefinitionContraindication) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication" #f)
    (schema-field 'interaction 0 1 (vector 'type 'ClinicalUseDefinitionInteraction) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction" #f)
    (schema-field 'population 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.population" #f)
    (schema-field 'library 0 '* (vector 'prim "canonical") #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.library" #f)
    (schema-field 'warning 0 1 (vector 'type 'ClinicalUseDefinitionWarning) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.warning" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.identifier" (fhir-spec (string->symbol "ClinicalUseDefinition.identifier") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.identifier" 'element))
(register-element! "ClinicalUseDefinition.type" (fhir-spec (string->symbol "ClinicalUseDefinition.type") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.type" 'element))
(register-element! "ClinicalUseDefinition.category" (fhir-spec (string->symbol "ClinicalUseDefinition.category") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.category" 'element))
(register-element! "ClinicalUseDefinition.subject" (fhir-spec (string->symbol "ClinicalUseDefinition.subject") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.subject" 'element))
(register-element! "ClinicalUseDefinition.status" (fhir-spec (string->symbol "ClinicalUseDefinition.status") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.status" 'element))
(register-element! "ClinicalUseDefinition.undesirableEffect" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect" 'element))
(register-element! "ClinicalUseDefinition.indication" (fhir-spec (string->symbol "ClinicalUseDefinition.indication") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication" 'element))
(register-element! "ClinicalUseDefinition.contraindication" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication" 'element))
(register-element! "ClinicalUseDefinition.interaction" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction" 'element))
(register-element! "ClinicalUseDefinition.population" (fhir-spec (string->symbol "ClinicalUseDefinition.population") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.population" 'element))
(register-element! "ClinicalUseDefinition.library" (fhir-spec (string->symbol "ClinicalUseDefinition.library") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.library" 'element))
(register-element! "ClinicalUseDefinition.warning" (fhir-spec (string->symbol "ClinicalUseDefinition.warning") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.warning" 'element))

(register-type! 'ClinicalUseDefinitionUndesirableEffect (fhir-spec 'ClinicalUseDefinitionUndesirableEffect "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionUndesirableEffect #f 'BackboneElement "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect"
             (list
    (schema-field 'symptomConditionEffect 0 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.symptomConditionEffect" #f)
    (schema-field 'classification 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.classification" #f)
    (schema-field 'frequencyOfOccurrence 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.frequencyOfOccurrence" #f)
    (schema-field 'management 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.management" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.undesirableEffect.symptomConditionEffect" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect.symptomConditionEffect") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.symptomConditionEffect" 'element))
(register-element! "ClinicalUseDefinition.undesirableEffect.classification" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect.classification") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.classification" 'element))
(register-element! "ClinicalUseDefinition.undesirableEffect.frequencyOfOccurrence" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect.frequencyOfOccurrence") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.frequencyOfOccurrence" 'element))
(register-element! "ClinicalUseDefinition.undesirableEffect.management" (fhir-spec (string->symbol "ClinicalUseDefinition.undesirableEffect.management") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.undesirableEffect.management" 'element))

(register-type! 'ClinicalUseDefinitionIndication (fhir-spec 'ClinicalUseDefinitionIndication "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionIndication #f 'BackboneElement "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication"
             (list
    (schema-field 'diseaseSymptomProcedure 0 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.diseaseSymptomProcedure" #f)
    (schema-field 'diseaseStatus 0 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.diseaseStatus" #f)
    (schema-field 'comorbidity 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.comorbidity" #f)
    (schema-field 'intendedEffect 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.intendedEffect" #f)
    (schema-field 'undesirableEffect 0 '* (vector 'type 'ClinicalUseDefinitionUndesirableEffect) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.undesirableEffect" #f)
    (schema-field 'applicability 0 1 (vector 'type 'Expression) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.applicability" #f)
    (schema-field 'otherTherapy 0 '* (vector 'type 'ClinicalUseDefinitionIndicationOtherTherapy) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy" #f)
    (schema-field 'durationRange 0 1 (vector 'type 'Range) 'duration "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.duration[x]" #f)
    (schema-field 'durationString 0 1 (vector 'prim "string") 'duration "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.duration[x]" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.indication.diseaseSymptomProcedure" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.diseaseSymptomProcedure") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.diseaseSymptomProcedure" 'element))
(register-element! "ClinicalUseDefinition.indication.diseaseStatus" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.diseaseStatus") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.diseaseStatus" 'element))
(register-element! "ClinicalUseDefinition.indication.comorbidity" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.comorbidity") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.comorbidity" 'element))
(register-element! "ClinicalUseDefinition.indication.intendedEffect" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.intendedEffect") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.intendedEffect" 'element))
(register-element! "ClinicalUseDefinition.indication.undesirableEffect" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.undesirableEffect") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.undesirableEffect" 'element))
(register-element! "ClinicalUseDefinition.indication.applicability" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.applicability") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.applicability" 'element))
(register-element! "ClinicalUseDefinition.indication.otherTherapy" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.otherTherapy") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy" 'element))
(register-element! "ClinicalUseDefinition.indication.duration[x]" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.duration[x]") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.duration[x]" 'element))
(register-element! "ClinicalUseDefinition.indication.duration[x]" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.duration[x]") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.duration[x]" 'element))

(register-type! 'ClinicalUseDefinitionIndicationOtherTherapy (fhir-spec 'ClinicalUseDefinitionIndicationOtherTherapy "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionIndicationOtherTherapy #f 'BackboneElement "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy"
             (list
    (schema-field 'relationshipType 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy.relationshipType" #f)
    (schema-field 'treatment 1 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy.treatment" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.indication.otherTherapy.relationshipType" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.otherTherapy.relationshipType") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy.relationshipType" 'element))
(register-element! "ClinicalUseDefinition.indication.otherTherapy.treatment" (fhir-spec (string->symbol "ClinicalUseDefinition.indication.otherTherapy.treatment") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.indication.otherTherapy.treatment" 'element))

(register-type! 'ClinicalUseDefinitionContraindication (fhir-spec 'ClinicalUseDefinitionContraindication "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionContraindication #f 'BackboneElement "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication"
             (list
    (schema-field 'diseaseSymptomProcedure 0 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.diseaseSymptomProcedure" #f)
    (schema-field 'diseaseStatus 0 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.diseaseStatus" #f)
    (schema-field 'comorbidity 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.comorbidity" #f)
    (schema-field 'indication 0 '* (vector 'type 'ClinicalUseDefinitionIndication) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.indication" #f)
    (schema-field 'applicability 0 1 (vector 'type 'Expression) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.applicability" #f)
    (schema-field 'management 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.management" #f)
    (schema-field 'otherTherapy 0 '* (vector 'type 'ClinicalUseDefinitionIndicationOtherTherapy) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.contraindication.diseaseSymptomProcedure" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.diseaseSymptomProcedure") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.diseaseSymptomProcedure" 'element))
(register-element! "ClinicalUseDefinition.contraindication.diseaseStatus" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.diseaseStatus") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.diseaseStatus" 'element))
(register-element! "ClinicalUseDefinition.contraindication.comorbidity" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.comorbidity") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.comorbidity" 'element))
(register-element! "ClinicalUseDefinition.contraindication.indication" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.indication") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.indication" 'element))
(register-element! "ClinicalUseDefinition.contraindication.applicability" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.applicability") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.applicability" 'element))
(register-element! "ClinicalUseDefinition.contraindication.management" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.management") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.management" 'element))
(register-element! "ClinicalUseDefinition.contraindication.otherTherapy" (fhir-spec (string->symbol "ClinicalUseDefinition.contraindication.otherTherapy") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.contraindication.otherTherapy" 'element))

(register-type! 'ClinicalUseDefinitionInteraction (fhir-spec 'ClinicalUseDefinitionInteraction "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionInteraction #f 'BackboneElement "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction"
             (list
    (schema-field 'interactant 0 '* (vector 'type 'ClinicalUseDefinitionInteractionInteractant) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.type" #f)
    (schema-field 'effect 0 1 (vector 'type 'CodeableReference) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.effect" #f)
    (schema-field 'incidence 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.incidence" #f)
    (schema-field 'management 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.management" #f)
    (schema-field 'severity 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.severity" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.interaction.interactant" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.interactant") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant" 'element))
(register-element! "ClinicalUseDefinition.interaction.type" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.type") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.type" 'element))
(register-element! "ClinicalUseDefinition.interaction.effect" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.effect") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.effect" 'element))
(register-element! "ClinicalUseDefinition.interaction.incidence" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.incidence") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.incidence" 'element))
(register-element! "ClinicalUseDefinition.interaction.management" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.management") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.management" 'element))
(register-element! "ClinicalUseDefinition.interaction.severity" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.severity") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.severity" 'element))

(register-type! 'ClinicalUseDefinitionInteractionInteractant (fhir-spec 'ClinicalUseDefinitionInteractionInteractant "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionInteractionInteractant #f 'BackboneElement "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant"
             (list
    (schema-field 'route 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.route" #f)
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.item[x]" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.item[x]" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.interaction.interactant.route" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.interactant.route") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.route" 'element))
(register-element! "ClinicalUseDefinition.interaction.interactant.item[x]" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.interactant.item[x]") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.item[x]" 'element))
(register-element! "ClinicalUseDefinition.interaction.interactant.item[x]" (fhir-spec (string->symbol "ClinicalUseDefinition.interaction.interactant.item[x]") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.interaction.interactant.item[x]" 'element))

(register-type! 'ClinicalUseDefinitionWarning (fhir-spec 'ClinicalUseDefinitionWarning "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.warning" 'type)
  #:schema (type-schema 'ClinicalUseDefinitionWarning #f 'BackboneElement "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.warning"
             (list
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.warning.description" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.warning.code" #f)
             ) #f #f))
(register-element! "ClinicalUseDefinition.warning.description" (fhir-spec (string->symbol "ClinicalUseDefinition.warning.description") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.warning.description" 'element))
(register-element! "ClinicalUseDefinition.warning.code" (fhir-spec (string->symbol "ClinicalUseDefinition.warning.code") "https://build.fhir.org/clinicalusedefinition.html#ClinicalUseDefinition.warning.code" 'element))

