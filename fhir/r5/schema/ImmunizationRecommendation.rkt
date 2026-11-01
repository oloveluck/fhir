#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ImmunizationRecommendation (fhir-spec 'ImmunizationRecommendation "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation" 'type)
  #:schema (type-schema 'ImmunizationRecommendation #f 'DomainResource "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.identifier" #f)
    (schema-field 'patient 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.patient" #f)
    (schema-field 'date 1 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.date" #f)
    (schema-field 'authority 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.authority" #f)
    (schema-field 'recommendation 1 '* (vector 'type 'ImmunizationRecommendationRecommendation) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation" #f)
             ) #f #f))
(register-element! "ImmunizationRecommendation.identifier" (fhir-spec (string->symbol "ImmunizationRecommendation.identifier") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.identifier" 'element))
(register-element! "ImmunizationRecommendation.patient" (fhir-spec (string->symbol "ImmunizationRecommendation.patient") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.patient" 'element))
(register-element! "ImmunizationRecommendation.date" (fhir-spec (string->symbol "ImmunizationRecommendation.date") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.date" 'element))
(register-element! "ImmunizationRecommendation.authority" (fhir-spec (string->symbol "ImmunizationRecommendation.authority") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.authority" 'element))
(register-element! "ImmunizationRecommendation.recommendation" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation" 'element))

(register-type! 'ImmunizationRecommendationRecommendation (fhir-spec 'ImmunizationRecommendationRecommendation "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation" 'type)
  #:schema (type-schema 'ImmunizationRecommendationRecommendation #f 'BackboneElement "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation"
             (list
    (schema-field 'vaccineCode 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.vaccineCode" #f)
    (schema-field 'targetDisease 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.targetDisease" #f)
    (schema-field 'contraindicatedVaccineCode 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.contraindicatedVaccineCode" #f)
    (schema-field 'forecastStatus 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.forecastStatus" #f)
    (schema-field 'forecastReason 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.forecastReason" #f)
    (schema-field 'dateCriterion 0 '* (vector 'type 'ImmunizationRecommendationRecommendationDateCriterion) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.dateCriterion" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.description" #f)
    (schema-field 'series 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.series" #f)
    (schema-field 'doseNumber 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.doseNumber" #f)
    (schema-field 'seriesDoses 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.seriesDoses" #f)
    (schema-field 'supportingImmunization 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.supportingImmunization" #f)
    (schema-field 'supportingPatientInformation 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.supportingPatientInformation" #f)
             ) #f #f))
(register-element! "ImmunizationRecommendation.recommendation.vaccineCode" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.vaccineCode") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.vaccineCode" 'element))
(register-element! "ImmunizationRecommendation.recommendation.targetDisease" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.targetDisease") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.targetDisease" 'element))
(register-element! "ImmunizationRecommendation.recommendation.contraindicatedVaccineCode" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.contraindicatedVaccineCode") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.contraindicatedVaccineCode" 'element))
(register-element! "ImmunizationRecommendation.recommendation.forecastStatus" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.forecastStatus") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.forecastStatus" 'element))
(register-element! "ImmunizationRecommendation.recommendation.forecastReason" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.forecastReason") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.forecastReason" 'element))
(register-element! "ImmunizationRecommendation.recommendation.dateCriterion" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.dateCriterion") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.dateCriterion" 'element))
(register-element! "ImmunizationRecommendation.recommendation.description" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.description") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.description" 'element))
(register-element! "ImmunizationRecommendation.recommendation.series" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.series") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.series" 'element))
(register-element! "ImmunizationRecommendation.recommendation.doseNumber" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.doseNumber") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.doseNumber" 'element))
(register-element! "ImmunizationRecommendation.recommendation.seriesDoses" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.seriesDoses") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.seriesDoses" 'element))
(register-element! "ImmunizationRecommendation.recommendation.supportingImmunization" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.supportingImmunization") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.supportingImmunization" 'element))
(register-element! "ImmunizationRecommendation.recommendation.supportingPatientInformation" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.supportingPatientInformation") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.supportingPatientInformation" 'element))

(register-type! 'ImmunizationRecommendationRecommendationDateCriterion (fhir-spec 'ImmunizationRecommendationRecommendationDateCriterion "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.dateCriterion" 'type)
  #:schema (type-schema 'ImmunizationRecommendationRecommendationDateCriterion #f 'BackboneElement "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.dateCriterion"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.dateCriterion.code" #f)
    (schema-field 'value 1 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.dateCriterion.value" #f)
             ) #f #f))
(register-element! "ImmunizationRecommendation.recommendation.dateCriterion.code" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.dateCriterion.code") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.dateCriterion.code" 'element))
(register-element! "ImmunizationRecommendation.recommendation.dateCriterion.value" (fhir-spec (string->symbol "ImmunizationRecommendation.recommendation.dateCriterion.value") "https://hl7.org/fhir/R5/immunizationrecommendation.html#ImmunizationRecommendation.recommendation.dateCriterion.value" 'element))

