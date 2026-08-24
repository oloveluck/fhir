#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'InsuranceProduct (fhir-spec 'InsuranceProduct "https://build.fhir.org/insuranceproduct.html#InsuranceProduct" 'type)
  #:schema (type-schema 'InsuranceProduct #f 'DomainResource "https://build.fhir.org/insuranceproduct.html#InsuranceProduct"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.status" #f)
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.name" #f)
    (schema-field 'alias 0 '* (vector 'prim "string") #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.alias" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.period" #f)
    (schema-field 'ownedBy 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.ownedBy" #f)
    (schema-field 'administeredBy 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.administeredBy" #f)
    (schema-field 'coverageArea 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverageArea" #f)
    (schema-field 'contact 0 '* (vector 'type 'ExtendedContactDetail) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.contact" #f)
    (schema-field 'endpoint 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.endpoint" #f)
    (schema-field 'network 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.network" #f)
    (schema-field 'coverage 0 '* (vector 'type 'InsuranceProductCoverage) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage" #f)
    (schema-field 'related 0 '* (vector 'type 'InsuranceProductRelated) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related" #f)
             ) #f #f))
(register-element! "InsuranceProduct.identifier" (fhir-spec (string->symbol "InsuranceProduct.identifier") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.identifier" 'element))
(register-element! "InsuranceProduct.status" (fhir-spec (string->symbol "InsuranceProduct.status") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.status" 'element))
(register-element! "InsuranceProduct.type" (fhir-spec (string->symbol "InsuranceProduct.type") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.type" 'element))
(register-element! "InsuranceProduct.name" (fhir-spec (string->symbol "InsuranceProduct.name") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.name" 'element))
(register-element! "InsuranceProduct.alias" (fhir-spec (string->symbol "InsuranceProduct.alias") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.alias" 'element))
(register-element! "InsuranceProduct.period" (fhir-spec (string->symbol "InsuranceProduct.period") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.period" 'element))
(register-element! "InsuranceProduct.ownedBy" (fhir-spec (string->symbol "InsuranceProduct.ownedBy") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.ownedBy" 'element))
(register-element! "InsuranceProduct.administeredBy" (fhir-spec (string->symbol "InsuranceProduct.administeredBy") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.administeredBy" 'element))
(register-element! "InsuranceProduct.coverageArea" (fhir-spec (string->symbol "InsuranceProduct.coverageArea") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverageArea" 'element))
(register-element! "InsuranceProduct.contact" (fhir-spec (string->symbol "InsuranceProduct.contact") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.contact" 'element))
(register-element! "InsuranceProduct.endpoint" (fhir-spec (string->symbol "InsuranceProduct.endpoint") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.endpoint" 'element))
(register-element! "InsuranceProduct.network" (fhir-spec (string->symbol "InsuranceProduct.network") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.network" 'element))
(register-element! "InsuranceProduct.coverage" (fhir-spec (string->symbol "InsuranceProduct.coverage") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage" 'element))
(register-element! "InsuranceProduct.related" (fhir-spec (string->symbol "InsuranceProduct.related") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related" 'element))

(register-type! 'InsuranceProductCoverage (fhir-spec 'InsuranceProductCoverage "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage" 'type)
  #:schema (type-schema 'InsuranceProductCoverage #f 'BackboneElement "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.type" #f)
    (schema-field 'network 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.network" #f)
    (schema-field 'benefit 1 '* (vector 'type 'InsuranceProductCoverageBenefit) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit" #f)
             ) #f #f))
(register-element! "InsuranceProduct.coverage.type" (fhir-spec (string->symbol "InsuranceProduct.coverage.type") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.type" 'element))
(register-element! "InsuranceProduct.coverage.network" (fhir-spec (string->symbol "InsuranceProduct.coverage.network") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.network" 'element))
(register-element! "InsuranceProduct.coverage.benefit" (fhir-spec (string->symbol "InsuranceProduct.coverage.benefit") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit" 'element))

(register-type! 'InsuranceProductCoverageBenefit (fhir-spec 'InsuranceProductCoverageBenefit "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit" 'type)
  #:schema (type-schema 'InsuranceProductCoverageBenefit #f 'BackboneElement "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.type" #f)
    (schema-field 'requirement 0 1 (vector 'prim "string") #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.requirement" #f)
    (schema-field 'limit 0 '* (vector 'type 'InsuranceProductCoverageBenefitLimit) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.limit" #f)
             ) #f #f))
(register-element! "InsuranceProduct.coverage.benefit.type" (fhir-spec (string->symbol "InsuranceProduct.coverage.benefit.type") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.type" 'element))
(register-element! "InsuranceProduct.coverage.benefit.requirement" (fhir-spec (string->symbol "InsuranceProduct.coverage.benefit.requirement") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.requirement" 'element))
(register-element! "InsuranceProduct.coverage.benefit.limit" (fhir-spec (string->symbol "InsuranceProduct.coverage.benefit.limit") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.limit" 'element))

(register-type! 'InsuranceProductCoverageBenefitLimit (fhir-spec 'InsuranceProductCoverageBenefitLimit "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.limit" 'type)
  #:schema (type-schema 'InsuranceProductCoverageBenefitLimit #f 'BackboneElement "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.limit"
             (list
    (schema-field 'value 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.limit.value" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.limit.code" #f)
             ) #f #f))
(register-element! "InsuranceProduct.coverage.benefit.limit.value" (fhir-spec (string->symbol "InsuranceProduct.coverage.benefit.limit.value") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.limit.value" 'element))
(register-element! "InsuranceProduct.coverage.benefit.limit.code" (fhir-spec (string->symbol "InsuranceProduct.coverage.benefit.limit.code") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.coverage.benefit.limit.code" 'element))

(register-type! 'InsuranceProductRelated (fhir-spec 'InsuranceProductRelated "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related" 'type)
  #:schema (type-schema 'InsuranceProductRelated #f 'BackboneElement "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related"
             (list
    (schema-field 'product 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related.product" #f)
    (schema-field 'relationship 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related.relationship" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related.period" #f)
             ) #f #f))
(register-element! "InsuranceProduct.related.product" (fhir-spec (string->symbol "InsuranceProduct.related.product") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related.product" 'element))
(register-element! "InsuranceProduct.related.relationship" (fhir-spec (string->symbol "InsuranceProduct.related.relationship") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related.relationship" 'element))
(register-element! "InsuranceProduct.related.period" (fhir-spec (string->symbol "InsuranceProduct.related.period") "https://build.fhir.org/insuranceproduct.html#InsuranceProduct.related.period" 'element))

