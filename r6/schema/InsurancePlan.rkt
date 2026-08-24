#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'InsurancePlan (fhir-spec 'InsurancePlan "https://build.fhir.org/insuranceplan.html#InsurancePlan" 'type)
  #:schema (type-schema 'InsurancePlan #f 'DomainResource "https://build.fhir.org/insuranceplan.html#InsurancePlan"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.identifier" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.type" #f)
    (schema-field 'product 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.product" #f)
    (schema-field 'coverageArea 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.coverageArea" #f)
    (schema-field 'network 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.network" #f)
    (schema-field 'generalCost 0 '* (vector 'type 'InsurancePlanGeneralCost) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost" #f)
    (schema-field 'specificCost 0 '* (vector 'type 'InsurancePlanSpecificCost) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost" #f)
             ) #f #f))
(register-element! "InsurancePlan.identifier" (fhir-spec (string->symbol "InsurancePlan.identifier") "https://build.fhir.org/insuranceplan.html#InsurancePlan.identifier" 'element))
(register-element! "InsurancePlan.type" (fhir-spec (string->symbol "InsurancePlan.type") "https://build.fhir.org/insuranceplan.html#InsurancePlan.type" 'element))
(register-element! "InsurancePlan.product" (fhir-spec (string->symbol "InsurancePlan.product") "https://build.fhir.org/insuranceplan.html#InsurancePlan.product" 'element))
(register-element! "InsurancePlan.coverageArea" (fhir-spec (string->symbol "InsurancePlan.coverageArea") "https://build.fhir.org/insuranceplan.html#InsurancePlan.coverageArea" 'element))
(register-element! "InsurancePlan.network" (fhir-spec (string->symbol "InsurancePlan.network") "https://build.fhir.org/insuranceplan.html#InsurancePlan.network" 'element))
(register-element! "InsurancePlan.generalCost" (fhir-spec (string->symbol "InsurancePlan.generalCost") "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost" 'element))
(register-element! "InsurancePlan.specificCost" (fhir-spec (string->symbol "InsurancePlan.specificCost") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost" 'element))

(register-type! 'InsurancePlanGeneralCost (fhir-spec 'InsurancePlanGeneralCost "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost" 'type)
  #:schema (type-schema 'InsurancePlanGeneralCost #f 'BackboneElement "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost.type" #f)
    (schema-field 'groupSize 0 1 (vector 'prim "positiveInt") #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost.groupSize" #f)
    (schema-field 'cost 0 1 (vector 'type 'Money) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost.cost" #f)
    (schema-field 'comment 0 1 (vector 'prim "string") #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost.comment" #f)
             ) #f #f))
(register-element! "InsurancePlan.generalCost.type" (fhir-spec (string->symbol "InsurancePlan.generalCost.type") "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost.type" 'element))
(register-element! "InsurancePlan.generalCost.groupSize" (fhir-spec (string->symbol "InsurancePlan.generalCost.groupSize") "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost.groupSize" 'element))
(register-element! "InsurancePlan.generalCost.cost" (fhir-spec (string->symbol "InsurancePlan.generalCost.cost") "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost.cost" 'element))
(register-element! "InsurancePlan.generalCost.comment" (fhir-spec (string->symbol "InsurancePlan.generalCost.comment") "https://build.fhir.org/insuranceplan.html#InsurancePlan.generalCost.comment" 'element))

(register-type! 'InsurancePlanSpecificCost (fhir-spec 'InsurancePlanSpecificCost "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost" 'type)
  #:schema (type-schema 'InsurancePlanSpecificCost #f 'BackboneElement "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost"
             (list
    (schema-field 'category 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.category" #f)
    (schema-field 'benefit 0 '* (vector 'type 'InsurancePlanSpecificCostBenefit) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit" #f)
             ) #f #f))
(register-element! "InsurancePlan.specificCost.category" (fhir-spec (string->symbol "InsurancePlan.specificCost.category") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.category" 'element))
(register-element! "InsurancePlan.specificCost.benefit" (fhir-spec (string->symbol "InsurancePlan.specificCost.benefit") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit" 'element))

(register-type! 'InsurancePlanSpecificCostBenefit (fhir-spec 'InsurancePlanSpecificCostBenefit "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit" 'type)
  #:schema (type-schema 'InsurancePlanSpecificCostBenefit #f 'BackboneElement "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.type" #f)
    (schema-field 'cost 0 '* (vector 'type 'InsurancePlanSpecificCostBenefitCost) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost" #f)
             ) #f #f))
(register-element! "InsurancePlan.specificCost.benefit.type" (fhir-spec (string->symbol "InsurancePlan.specificCost.benefit.type") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.type" 'element))
(register-element! "InsurancePlan.specificCost.benefit.cost" (fhir-spec (string->symbol "InsurancePlan.specificCost.benefit.cost") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost" 'element))

(register-type! 'InsurancePlanSpecificCostBenefitCost (fhir-spec 'InsurancePlanSpecificCostBenefitCost "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost" 'type)
  #:schema (type-schema 'InsurancePlanSpecificCostBenefitCost #f 'BackboneElement "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost.type" #f)
    (schema-field 'applicability 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost.applicability" #f)
    (schema-field 'qualifier 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost.qualifier" #f)
    (schema-field 'value 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost.value" #f)
             ) #f #f))
(register-element! "InsurancePlan.specificCost.benefit.cost.type" (fhir-spec (string->symbol "InsurancePlan.specificCost.benefit.cost.type") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost.type" 'element))
(register-element! "InsurancePlan.specificCost.benefit.cost.applicability" (fhir-spec (string->symbol "InsurancePlan.specificCost.benefit.cost.applicability") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost.applicability" 'element))
(register-element! "InsurancePlan.specificCost.benefit.cost.qualifier" (fhir-spec (string->symbol "InsurancePlan.specificCost.benefit.cost.qualifier") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost.qualifier" 'element))
(register-element! "InsurancePlan.specificCost.benefit.cost.value" (fhir-spec (string->symbol "InsurancePlan.specificCost.benefit.cost.value") "https://build.fhir.org/insuranceplan.html#InsurancePlan.specificCost.benefit.cost.value" 'element))

