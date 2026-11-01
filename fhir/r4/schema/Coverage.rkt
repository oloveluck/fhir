#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Coverage (fhir-spec 'Coverage "https://hl7.org/fhir/R4/coverage.html#Coverage" 'type)
  #:schema (type-schema 'Coverage #f 'DomainResource "https://hl7.org/fhir/R4/coverage.html#Coverage"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/coverage.html#Coverage.status" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.type" #f)
    (schema-field 'policyHolder 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.policyHolder" #f)
    (schema-field 'subscriber 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.subscriber" #f)
    (schema-field 'subscriberId 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/coverage.html#Coverage.subscriberId" #f)
    (schema-field 'beneficiary 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.beneficiary" #f)
    (schema-field 'dependent 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/coverage.html#Coverage.dependent" #f)
    (schema-field 'relationship 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.relationship" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.period" #f)
    (schema-field 'payor 1 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.payor" #f)
    (schema-field 'class 0 '* (vector 'type 'CoverageClass) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.class" #f)
    (schema-field 'order 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R4/coverage.html#Coverage.order" #f)
    (schema-field 'network 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/coverage.html#Coverage.network" #f)
    (schema-field 'costToBeneficiary 0 '* (vector 'type 'CoverageCostToBeneficiary) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary" #f)
    (schema-field 'subrogation 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/coverage.html#Coverage.subrogation" #f)
    (schema-field 'contract 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.contract" #f)
             ) #f #f))
(register-element! "Coverage.identifier" (fhir-spec (string->symbol "Coverage.identifier") "https://hl7.org/fhir/R4/coverage.html#Coverage.identifier" 'element))
(register-element! "Coverage.status" (fhir-spec (string->symbol "Coverage.status") "https://hl7.org/fhir/R4/coverage.html#Coverage.status" 'element))
(register-element! "Coverage.type" (fhir-spec (string->symbol "Coverage.type") "https://hl7.org/fhir/R4/coverage.html#Coverage.type" 'element))
(register-element! "Coverage.policyHolder" (fhir-spec (string->symbol "Coverage.policyHolder") "https://hl7.org/fhir/R4/coverage.html#Coverage.policyHolder" 'element))
(register-element! "Coverage.subscriber" (fhir-spec (string->symbol "Coverage.subscriber") "https://hl7.org/fhir/R4/coverage.html#Coverage.subscriber" 'element))
(register-element! "Coverage.subscriberId" (fhir-spec (string->symbol "Coverage.subscriberId") "https://hl7.org/fhir/R4/coverage.html#Coverage.subscriberId" 'element))
(register-element! "Coverage.beneficiary" (fhir-spec (string->symbol "Coverage.beneficiary") "https://hl7.org/fhir/R4/coverage.html#Coverage.beneficiary" 'element))
(register-element! "Coverage.dependent" (fhir-spec (string->symbol "Coverage.dependent") "https://hl7.org/fhir/R4/coverage.html#Coverage.dependent" 'element))
(register-element! "Coverage.relationship" (fhir-spec (string->symbol "Coverage.relationship") "https://hl7.org/fhir/R4/coverage.html#Coverage.relationship" 'element))
(register-element! "Coverage.period" (fhir-spec (string->symbol "Coverage.period") "https://hl7.org/fhir/R4/coverage.html#Coverage.period" 'element))
(register-element! "Coverage.payor" (fhir-spec (string->symbol "Coverage.payor") "https://hl7.org/fhir/R4/coverage.html#Coverage.payor" 'element))
(register-element! "Coverage.class" (fhir-spec (string->symbol "Coverage.class") "https://hl7.org/fhir/R4/coverage.html#Coverage.class" 'element))
(register-element! "Coverage.order" (fhir-spec (string->symbol "Coverage.order") "https://hl7.org/fhir/R4/coverage.html#Coverage.order" 'element))
(register-element! "Coverage.network" (fhir-spec (string->symbol "Coverage.network") "https://hl7.org/fhir/R4/coverage.html#Coverage.network" 'element))
(register-element! "Coverage.costToBeneficiary" (fhir-spec (string->symbol "Coverage.costToBeneficiary") "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary" 'element))
(register-element! "Coverage.subrogation" (fhir-spec (string->symbol "Coverage.subrogation") "https://hl7.org/fhir/R4/coverage.html#Coverage.subrogation" 'element))
(register-element! "Coverage.contract" (fhir-spec (string->symbol "Coverage.contract") "https://hl7.org/fhir/R4/coverage.html#Coverage.contract" 'element))

(register-type! 'CoverageClass (fhir-spec 'CoverageClass "https://hl7.org/fhir/R4/coverage.html#Coverage.class" 'type)
  #:schema (type-schema 'CoverageClass #f 'BackboneElement "https://hl7.org/fhir/R4/coverage.html#Coverage.class"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.class.type" #f)
    (schema-field 'value 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/coverage.html#Coverage.class.value" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/coverage.html#Coverage.class.name" #f)
             ) #f #f))
(register-element! "Coverage.class.type" (fhir-spec (string->symbol "Coverage.class.type") "https://hl7.org/fhir/R4/coverage.html#Coverage.class.type" 'element))
(register-element! "Coverage.class.value" (fhir-spec (string->symbol "Coverage.class.value") "https://hl7.org/fhir/R4/coverage.html#Coverage.class.value" 'element))
(register-element! "Coverage.class.name" (fhir-spec (string->symbol "Coverage.class.name") "https://hl7.org/fhir/R4/coverage.html#Coverage.class.name" 'element))

(register-type! 'CoverageCostToBeneficiary (fhir-spec 'CoverageCostToBeneficiary "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary" 'type)
  #:schema (type-schema 'CoverageCostToBeneficiary #f 'BackboneElement "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.type" #f)
    (schema-field 'exception 0 '* (vector 'type 'CoverageCostToBeneficiaryException) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.exception" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.value[x]" #f)
    (schema-field 'valueMoney 0 1 (vector 'type 'Money) 'value "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.value[x]" #f)
             ) #f #f))
(register-element! "Coverage.costToBeneficiary.type" (fhir-spec (string->symbol "Coverage.costToBeneficiary.type") "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.type" 'element))
(register-element! "Coverage.costToBeneficiary.exception" (fhir-spec (string->symbol "Coverage.costToBeneficiary.exception") "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.exception" 'element))
(register-element! "Coverage.costToBeneficiary.value[x]" (fhir-spec (string->symbol "Coverage.costToBeneficiary.value[x]") "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.value[x]" 'element))
(register-element! "Coverage.costToBeneficiary.value[x]" (fhir-spec (string->symbol "Coverage.costToBeneficiary.value[x]") "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.value[x]" 'element))

(register-type! 'CoverageCostToBeneficiaryException (fhir-spec 'CoverageCostToBeneficiaryException "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.exception" 'type)
  #:schema (type-schema 'CoverageCostToBeneficiaryException #f 'BackboneElement "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.exception"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.exception.type" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.exception.period" #f)
             ) #f #f))
(register-element! "Coverage.costToBeneficiary.exception.type" (fhir-spec (string->symbol "Coverage.costToBeneficiary.exception.type") "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.exception.type" 'element))
(register-element! "Coverage.costToBeneficiary.exception.period" (fhir-spec (string->symbol "Coverage.costToBeneficiary.exception.period") "https://hl7.org/fhir/R4/coverage.html#Coverage.costToBeneficiary.exception.period" 'element))

