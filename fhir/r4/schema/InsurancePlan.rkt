#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'InsurancePlan (fhir-spec 'InsurancePlan "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan" 'type)
  #:schema (type-schema 'InsurancePlan #f 'DomainResource "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.status" #f)
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.name" #f)
    (schema-field 'alias 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.alias" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.period" #f)
    (schema-field 'ownedBy 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.ownedBy" #f)
    (schema-field 'administeredBy 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.administeredBy" #f)
    (schema-field 'coverageArea 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverageArea" #f)
    (schema-field 'contact 0 '* (vector 'type 'InsurancePlanContact) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact" #f)
    (schema-field 'endpoint 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.endpoint" #f)
    (schema-field 'network 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.network" #f)
    (schema-field 'coverage 0 '* (vector 'type 'InsurancePlanCoverage) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage" #f)
    (schema-field 'plan 0 '* (vector 'type 'InsurancePlanPlan) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan" #f)
             ) #f #f))
(register-element! "InsurancePlan.identifier" (fhir-spec (string->symbol "InsurancePlan.identifier") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.identifier" 'element))
(register-element! "InsurancePlan.status" (fhir-spec (string->symbol "InsurancePlan.status") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.status" 'element))
(register-element! "InsurancePlan.type" (fhir-spec (string->symbol "InsurancePlan.type") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.type" 'element))
(register-element! "InsurancePlan.name" (fhir-spec (string->symbol "InsurancePlan.name") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.name" 'element))
(register-element! "InsurancePlan.alias" (fhir-spec (string->symbol "InsurancePlan.alias") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.alias" 'element))
(register-element! "InsurancePlan.period" (fhir-spec (string->symbol "InsurancePlan.period") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.period" 'element))
(register-element! "InsurancePlan.ownedBy" (fhir-spec (string->symbol "InsurancePlan.ownedBy") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.ownedBy" 'element))
(register-element! "InsurancePlan.administeredBy" (fhir-spec (string->symbol "InsurancePlan.administeredBy") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.administeredBy" 'element))
(register-element! "InsurancePlan.coverageArea" (fhir-spec (string->symbol "InsurancePlan.coverageArea") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverageArea" 'element))
(register-element! "InsurancePlan.contact" (fhir-spec (string->symbol "InsurancePlan.contact") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact" 'element))
(register-element! "InsurancePlan.endpoint" (fhir-spec (string->symbol "InsurancePlan.endpoint") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.endpoint" 'element))
(register-element! "InsurancePlan.network" (fhir-spec (string->symbol "InsurancePlan.network") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.network" 'element))
(register-element! "InsurancePlan.coverage" (fhir-spec (string->symbol "InsurancePlan.coverage") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage" 'element))
(register-element! "InsurancePlan.plan" (fhir-spec (string->symbol "InsurancePlan.plan") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan" 'element))

(register-type! 'InsurancePlanContact (fhir-spec 'InsurancePlanContact "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact" 'type)
  #:schema (type-schema 'InsurancePlanContact #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact"
             (list
    (schema-field 'purpose 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact.purpose" #f)
    (schema-field 'name 0 1 (vector 'type 'HumanName) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact.telecom" #f)
    (schema-field 'address 0 1 (vector 'type 'Address) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact.address" #f)
             ) #f #f))
(register-element! "InsurancePlan.contact.purpose" (fhir-spec (string->symbol "InsurancePlan.contact.purpose") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact.purpose" 'element))
(register-element! "InsurancePlan.contact.name" (fhir-spec (string->symbol "InsurancePlan.contact.name") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact.name" 'element))
(register-element! "InsurancePlan.contact.telecom" (fhir-spec (string->symbol "InsurancePlan.contact.telecom") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact.telecom" 'element))
(register-element! "InsurancePlan.contact.address" (fhir-spec (string->symbol "InsurancePlan.contact.address") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.contact.address" 'element))

(register-type! 'InsurancePlanCoverage (fhir-spec 'InsurancePlanCoverage "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage" 'type)
  #:schema (type-schema 'InsurancePlanCoverage #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.type" #f)
    (schema-field 'network 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.network" #f)
    (schema-field 'benefit 1 '* (vector 'type 'InsurancePlanCoverageBenefit) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit" #f)
             ) #f #f))
(register-element! "InsurancePlan.coverage.type" (fhir-spec (string->symbol "InsurancePlan.coverage.type") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.type" 'element))
(register-element! "InsurancePlan.coverage.network" (fhir-spec (string->symbol "InsurancePlan.coverage.network") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.network" 'element))
(register-element! "InsurancePlan.coverage.benefit" (fhir-spec (string->symbol "InsurancePlan.coverage.benefit") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit" 'element))

(register-type! 'InsurancePlanCoverageBenefit (fhir-spec 'InsurancePlanCoverageBenefit "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit" 'type)
  #:schema (type-schema 'InsurancePlanCoverageBenefit #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.type" #f)
    (schema-field 'requirement 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.requirement" #f)
    (schema-field 'limit 0 '* (vector 'type 'InsurancePlanCoverageBenefitLimit) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.limit" #f)
             ) #f #f))
(register-element! "InsurancePlan.coverage.benefit.type" (fhir-spec (string->symbol "InsurancePlan.coverage.benefit.type") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.type" 'element))
(register-element! "InsurancePlan.coverage.benefit.requirement" (fhir-spec (string->symbol "InsurancePlan.coverage.benefit.requirement") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.requirement" 'element))
(register-element! "InsurancePlan.coverage.benefit.limit" (fhir-spec (string->symbol "InsurancePlan.coverage.benefit.limit") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.limit" 'element))

(register-type! 'InsurancePlanCoverageBenefitLimit (fhir-spec 'InsurancePlanCoverageBenefitLimit "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.limit" 'type)
  #:schema (type-schema 'InsurancePlanCoverageBenefitLimit #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.limit"
             (list
    (schema-field 'value 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.limit.value" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.limit.code" #f)
             ) #f #f))
(register-element! "InsurancePlan.coverage.benefit.limit.value" (fhir-spec (string->symbol "InsurancePlan.coverage.benefit.limit.value") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.limit.value" 'element))
(register-element! "InsurancePlan.coverage.benefit.limit.code" (fhir-spec (string->symbol "InsurancePlan.coverage.benefit.limit.code") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.coverage.benefit.limit.code" 'element))

(register-type! 'InsurancePlanPlan (fhir-spec 'InsurancePlanPlan "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan" 'type)
  #:schema (type-schema 'InsurancePlanPlan #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.identifier" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.type" #f)
    (schema-field 'coverageArea 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.coverageArea" #f)
    (schema-field 'network 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.network" #f)
    (schema-field 'generalCost 0 '* (vector 'type 'InsurancePlanPlanGeneralCost) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost" #f)
    (schema-field 'specificCost 0 '* (vector 'type 'InsurancePlanPlanSpecificCost) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost" #f)
             ) #f #f))
(register-element! "InsurancePlan.plan.identifier" (fhir-spec (string->symbol "InsurancePlan.plan.identifier") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.identifier" 'element))
(register-element! "InsurancePlan.plan.type" (fhir-spec (string->symbol "InsurancePlan.plan.type") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.type" 'element))
(register-element! "InsurancePlan.plan.coverageArea" (fhir-spec (string->symbol "InsurancePlan.plan.coverageArea") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.coverageArea" 'element))
(register-element! "InsurancePlan.plan.network" (fhir-spec (string->symbol "InsurancePlan.plan.network") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.network" 'element))
(register-element! "InsurancePlan.plan.generalCost" (fhir-spec (string->symbol "InsurancePlan.plan.generalCost") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost" 'element))
(register-element! "InsurancePlan.plan.specificCost" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost" 'element))

(register-type! 'InsurancePlanPlanGeneralCost (fhir-spec 'InsurancePlanPlanGeneralCost "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost" 'type)
  #:schema (type-schema 'InsurancePlanPlanGeneralCost #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost.type" #f)
    (schema-field 'groupSize 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost.groupSize" #f)
    (schema-field 'cost 0 1 (vector 'type 'Money) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost.cost" #f)
    (schema-field 'comment 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost.comment" #f)
             ) #f #f))
(register-element! "InsurancePlan.plan.generalCost.type" (fhir-spec (string->symbol "InsurancePlan.plan.generalCost.type") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost.type" 'element))
(register-element! "InsurancePlan.plan.generalCost.groupSize" (fhir-spec (string->symbol "InsurancePlan.plan.generalCost.groupSize") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost.groupSize" 'element))
(register-element! "InsurancePlan.plan.generalCost.cost" (fhir-spec (string->symbol "InsurancePlan.plan.generalCost.cost") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost.cost" 'element))
(register-element! "InsurancePlan.plan.generalCost.comment" (fhir-spec (string->symbol "InsurancePlan.plan.generalCost.comment") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.generalCost.comment" 'element))

(register-type! 'InsurancePlanPlanSpecificCost (fhir-spec 'InsurancePlanPlanSpecificCost "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost" 'type)
  #:schema (type-schema 'InsurancePlanPlanSpecificCost #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost"
             (list
    (schema-field 'category 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.category" #f)
    (schema-field 'benefit 0 '* (vector 'type 'InsurancePlanPlanSpecificCostBenefit) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit" #f)
             ) #f #f))
(register-element! "InsurancePlan.plan.specificCost.category" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost.category") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.category" 'element))
(register-element! "InsurancePlan.plan.specificCost.benefit" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost.benefit") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit" 'element))

(register-type! 'InsurancePlanPlanSpecificCostBenefit (fhir-spec 'InsurancePlanPlanSpecificCostBenefit "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit" 'type)
  #:schema (type-schema 'InsurancePlanPlanSpecificCostBenefit #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.type" #f)
    (schema-field 'cost 0 '* (vector 'type 'InsurancePlanPlanSpecificCostBenefitCost) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost" #f)
             ) #f #f))
(register-element! "InsurancePlan.plan.specificCost.benefit.type" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost.benefit.type") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.type" 'element))
(register-element! "InsurancePlan.plan.specificCost.benefit.cost" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost.benefit.cost") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost" 'element))

(register-type! 'InsurancePlanPlanSpecificCostBenefitCost (fhir-spec 'InsurancePlanPlanSpecificCostBenefitCost "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost" 'type)
  #:schema (type-schema 'InsurancePlanPlanSpecificCostBenefitCost #f 'BackboneElement "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost.type" #f)
    (schema-field 'applicability 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost.applicability" #f)
    (schema-field 'qualifiers 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost.qualifiers" #f)
    (schema-field 'value 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost.value" #f)
             ) #f #f))
(register-element! "InsurancePlan.plan.specificCost.benefit.cost.type" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost.benefit.cost.type") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost.type" 'element))
(register-element! "InsurancePlan.plan.specificCost.benefit.cost.applicability" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost.benefit.cost.applicability") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost.applicability" 'element))
(register-element! "InsurancePlan.plan.specificCost.benefit.cost.qualifiers" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost.benefit.cost.qualifiers") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost.qualifiers" 'element))
(register-element! "InsurancePlan.plan.specificCost.benefit.cost.value" (fhir-spec (string->symbol "InsurancePlan.plan.specificCost.benefit.cost.value") "https://hl7.org/fhir/R4/insuranceplan.html#InsurancePlan.plan.specificCost.benefit.cost.value" 'element))

