#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicinalProductPharmaceutical (fhir-spec 'MedicinalProductPharmaceutical "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical" 'type)
  #:schema (type-schema 'MedicinalProductPharmaceutical #f 'DomainResource "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.identifier" #f)
    (schema-field 'administrableDoseForm 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.administrableDoseForm" #f)
    (schema-field 'unitOfPresentation 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.unitOfPresentation" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.ingredient" #f)
    (schema-field 'device 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.device" #f)
    (schema-field 'characteristics 0 '* (vector 'type 'MedicinalProductPharmaceuticalCharacteristics) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.characteristics" #f)
    (schema-field 'routeOfAdministration 1 '* (vector 'type 'MedicinalProductPharmaceuticalRouteOfAdministration) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration" #f)
             ) #f #f))
(register-element! "MedicinalProductPharmaceutical.identifier" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.identifier") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.identifier" 'element))
(register-element! "MedicinalProductPharmaceutical.administrableDoseForm" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.administrableDoseForm") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.administrableDoseForm" 'element))
(register-element! "MedicinalProductPharmaceutical.unitOfPresentation" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.unitOfPresentation") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.unitOfPresentation" 'element))
(register-element! "MedicinalProductPharmaceutical.ingredient" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.ingredient") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.ingredient" 'element))
(register-element! "MedicinalProductPharmaceutical.device" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.device") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.device" 'element))
(register-element! "MedicinalProductPharmaceutical.characteristics" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.characteristics") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.characteristics" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration" 'element))

(register-type! 'MedicinalProductPharmaceuticalCharacteristics (fhir-spec 'MedicinalProductPharmaceuticalCharacteristics "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.characteristics" 'type)
  #:schema (type-schema 'MedicinalProductPharmaceuticalCharacteristics #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.characteristics"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.characteristics.code" #f)
    (schema-field 'status 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.characteristics.status" #f)
             ) #f #f))
(register-element! "MedicinalProductPharmaceutical.characteristics.code" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.characteristics.code") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.characteristics.code" 'element))
(register-element! "MedicinalProductPharmaceutical.characteristics.status" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.characteristics.status") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.characteristics.status" 'element))

(register-type! 'MedicinalProductPharmaceuticalRouteOfAdministration (fhir-spec 'MedicinalProductPharmaceuticalRouteOfAdministration "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration" 'type)
  #:schema (type-schema 'MedicinalProductPharmaceuticalRouteOfAdministration #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.code" #f)
    (schema-field 'firstDose 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.firstDose" #f)
    (schema-field 'maxSingleDose 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.maxSingleDose" #f)
    (schema-field 'maxDosePerDay 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.maxDosePerDay" #f)
    (schema-field 'maxDosePerTreatmentPeriod 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.maxDosePerTreatmentPeriod" #f)
    (schema-field 'maxTreatmentPeriod 0 1 (vector 'type 'Duration) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.maxTreatmentPeriod" #f)
    (schema-field 'targetSpecies 0 '* (vector 'type 'MedicinalProductPharmaceuticalRouteOfAdministrationTargetSpecies) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies" #f)
             ) #f #f))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.code" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.code") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.code" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.firstDose" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.firstDose") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.firstDose" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.maxSingleDose" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.maxSingleDose") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.maxSingleDose" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.maxDosePerDay" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.maxDosePerDay") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.maxDosePerDay" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.maxDosePerTreatmentPeriod" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.maxDosePerTreatmentPeriod") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.maxDosePerTreatmentPeriod" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.maxTreatmentPeriod" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.maxTreatmentPeriod") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.maxTreatmentPeriod" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies" 'element))

(register-type! 'MedicinalProductPharmaceuticalRouteOfAdministrationTargetSpecies (fhir-spec 'MedicinalProductPharmaceuticalRouteOfAdministrationTargetSpecies "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies" 'type)
  #:schema (type-schema 'MedicinalProductPharmaceuticalRouteOfAdministrationTargetSpecies #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.code" #f)
    (schema-field 'withdrawalPeriod 0 '* (vector 'type 'MedicinalProductPharmaceuticalRouteOfAdministrationTargetSpeciesWithdrawalPeriod) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod" #f)
             ) #f #f))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.code" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.code") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.code" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod" 'element))

(register-type! 'MedicinalProductPharmaceuticalRouteOfAdministrationTargetSpeciesWithdrawalPeriod (fhir-spec 'MedicinalProductPharmaceuticalRouteOfAdministrationTargetSpeciesWithdrawalPeriod "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod" 'type)
  #:schema (type-schema 'MedicinalProductPharmaceuticalRouteOfAdministrationTargetSpeciesWithdrawalPeriod #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod"
             (list
    (schema-field 'tissue 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.tissue" #f)
    (schema-field 'value 1 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.value" #f)
    (schema-field 'supportingInformation 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.supportingInformation" #f)
             ) #f #f))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.tissue" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.tissue") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.tissue" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.value" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.value") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.value" 'element))
(register-element! "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.supportingInformation" (fhir-spec (string->symbol "MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.supportingInformation") "https://hl7.org/fhir/R4/medicinalproductpharmaceutical.html#MedicinalProductPharmaceutical.routeOfAdministration.targetSpecies.withdrawalPeriod.supportingInformation" 'element))

