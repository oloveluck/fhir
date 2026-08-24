#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Account (fhir-spec 'Account "https://hl7.org/fhir/R5/account.html#Account" 'type)
  #:schema (type-schema 'Account #f 'DomainResource "https://hl7.org/fhir/R5/account.html#Account"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/account.html#Account.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/account.html#Account.status" #f)
    (schema-field 'billingStatus 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.billingStatus" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/account.html#Account.name" #f)
    (schema-field 'subject 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/account.html#Account.subject" #f)
    (schema-field 'servicePeriod 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/account.html#Account.servicePeriod" #f)
    (schema-field 'coverage 0 '* (vector 'type 'AccountCoverage) #f "https://hl7.org/fhir/R5/account.html#Account.coverage" #f)
    (schema-field 'owner 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/account.html#Account.owner" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/account.html#Account.description" #f)
    (schema-field 'guarantor 0 '* (vector 'type 'AccountGuarantor) #f "https://hl7.org/fhir/R5/account.html#Account.guarantor" #f)
    (schema-field 'diagnosis 0 '* (vector 'type 'AccountDiagnosis) #f "https://hl7.org/fhir/R5/account.html#Account.diagnosis" #f)
    (schema-field 'procedure 0 '* (vector 'type 'AccountProcedure) #f "https://hl7.org/fhir/R5/account.html#Account.procedure" #f)
    (schema-field 'relatedAccount 0 '* (vector 'type 'AccountRelatedAccount) #f "https://hl7.org/fhir/R5/account.html#Account.relatedAccount" #f)
    (schema-field 'currency 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.currency" #f)
    (schema-field 'balance 0 '* (vector 'type 'AccountBalance) #f "https://hl7.org/fhir/R5/account.html#Account.balance" #f)
    (schema-field 'calculatedAt 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/account.html#Account.calculatedAt" #f)
             ) #f #f))
(register-element! "Account.identifier" (fhir-spec (string->symbol "Account.identifier") "https://hl7.org/fhir/R5/account.html#Account.identifier" 'element))
(register-element! "Account.status" (fhir-spec (string->symbol "Account.status") "https://hl7.org/fhir/R5/account.html#Account.status" 'element))
(register-element! "Account.billingStatus" (fhir-spec (string->symbol "Account.billingStatus") "https://hl7.org/fhir/R5/account.html#Account.billingStatus" 'element))
(register-element! "Account.type" (fhir-spec (string->symbol "Account.type") "https://hl7.org/fhir/R5/account.html#Account.type" 'element))
(register-element! "Account.name" (fhir-spec (string->symbol "Account.name") "https://hl7.org/fhir/R5/account.html#Account.name" 'element))
(register-element! "Account.subject" (fhir-spec (string->symbol "Account.subject") "https://hl7.org/fhir/R5/account.html#Account.subject" 'element))
(register-element! "Account.servicePeriod" (fhir-spec (string->symbol "Account.servicePeriod") "https://hl7.org/fhir/R5/account.html#Account.servicePeriod" 'element))
(register-element! "Account.coverage" (fhir-spec (string->symbol "Account.coverage") "https://hl7.org/fhir/R5/account.html#Account.coverage" 'element))
(register-element! "Account.owner" (fhir-spec (string->symbol "Account.owner") "https://hl7.org/fhir/R5/account.html#Account.owner" 'element))
(register-element! "Account.description" (fhir-spec (string->symbol "Account.description") "https://hl7.org/fhir/R5/account.html#Account.description" 'element))
(register-element! "Account.guarantor" (fhir-spec (string->symbol "Account.guarantor") "https://hl7.org/fhir/R5/account.html#Account.guarantor" 'element))
(register-element! "Account.diagnosis" (fhir-spec (string->symbol "Account.diagnosis") "https://hl7.org/fhir/R5/account.html#Account.diagnosis" 'element))
(register-element! "Account.procedure" (fhir-spec (string->symbol "Account.procedure") "https://hl7.org/fhir/R5/account.html#Account.procedure" 'element))
(register-element! "Account.relatedAccount" (fhir-spec (string->symbol "Account.relatedAccount") "https://hl7.org/fhir/R5/account.html#Account.relatedAccount" 'element))
(register-element! "Account.currency" (fhir-spec (string->symbol "Account.currency") "https://hl7.org/fhir/R5/account.html#Account.currency" 'element))
(register-element! "Account.balance" (fhir-spec (string->symbol "Account.balance") "https://hl7.org/fhir/R5/account.html#Account.balance" 'element))
(register-element! "Account.calculatedAt" (fhir-spec (string->symbol "Account.calculatedAt") "https://hl7.org/fhir/R5/account.html#Account.calculatedAt" 'element))

(register-type! 'AccountCoverage (fhir-spec 'AccountCoverage "https://hl7.org/fhir/R5/account.html#Account.coverage" 'type)
  #:schema (type-schema 'AccountCoverage #f 'BackboneElement "https://hl7.org/fhir/R5/account.html#Account.coverage"
             (list
    (schema-field 'coverage 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/account.html#Account.coverage.coverage" #f)
    (schema-field 'priority 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R5/account.html#Account.coverage.priority" #f)
             ) #f #f))
(register-element! "Account.coverage.coverage" (fhir-spec (string->symbol "Account.coverage.coverage") "https://hl7.org/fhir/R5/account.html#Account.coverage.coverage" 'element))
(register-element! "Account.coverage.priority" (fhir-spec (string->symbol "Account.coverage.priority") "https://hl7.org/fhir/R5/account.html#Account.coverage.priority" 'element))

(register-type! 'AccountGuarantor (fhir-spec 'AccountGuarantor "https://hl7.org/fhir/R5/account.html#Account.guarantor" 'type)
  #:schema (type-schema 'AccountGuarantor #f 'BackboneElement "https://hl7.org/fhir/R5/account.html#Account.guarantor"
             (list
    (schema-field 'party 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/account.html#Account.guarantor.party" #f)
    (schema-field 'onHold 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/account.html#Account.guarantor.onHold" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/account.html#Account.guarantor.period" #f)
             ) #f #f))
(register-element! "Account.guarantor.party" (fhir-spec (string->symbol "Account.guarantor.party") "https://hl7.org/fhir/R5/account.html#Account.guarantor.party" 'element))
(register-element! "Account.guarantor.onHold" (fhir-spec (string->symbol "Account.guarantor.onHold") "https://hl7.org/fhir/R5/account.html#Account.guarantor.onHold" 'element))
(register-element! "Account.guarantor.period" (fhir-spec (string->symbol "Account.guarantor.period") "https://hl7.org/fhir/R5/account.html#Account.guarantor.period" 'element))

(register-type! 'AccountDiagnosis (fhir-spec 'AccountDiagnosis "https://hl7.org/fhir/R5/account.html#Account.diagnosis" 'type)
  #:schema (type-schema 'AccountDiagnosis #f 'BackboneElement "https://hl7.org/fhir/R5/account.html#Account.diagnosis"
             (list
    (schema-field 'sequence 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R5/account.html#Account.diagnosis.sequence" #f)
    (schema-field 'condition 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/account.html#Account.diagnosis.condition" #f)
    (schema-field 'dateOfDiagnosis 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/account.html#Account.diagnosis.dateOfDiagnosis" #f)
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.diagnosis.type" #f)
    (schema-field 'onAdmission 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/account.html#Account.diagnosis.onAdmission" #f)
    (schema-field 'packageCode 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.diagnosis.packageCode" #f)
             ) #f #f))
(register-element! "Account.diagnosis.sequence" (fhir-spec (string->symbol "Account.diagnosis.sequence") "https://hl7.org/fhir/R5/account.html#Account.diagnosis.sequence" 'element))
(register-element! "Account.diagnosis.condition" (fhir-spec (string->symbol "Account.diagnosis.condition") "https://hl7.org/fhir/R5/account.html#Account.diagnosis.condition" 'element))
(register-element! "Account.diagnosis.dateOfDiagnosis" (fhir-spec (string->symbol "Account.diagnosis.dateOfDiagnosis") "https://hl7.org/fhir/R5/account.html#Account.diagnosis.dateOfDiagnosis" 'element))
(register-element! "Account.diagnosis.type" (fhir-spec (string->symbol "Account.diagnosis.type") "https://hl7.org/fhir/R5/account.html#Account.diagnosis.type" 'element))
(register-element! "Account.diagnosis.onAdmission" (fhir-spec (string->symbol "Account.diagnosis.onAdmission") "https://hl7.org/fhir/R5/account.html#Account.diagnosis.onAdmission" 'element))
(register-element! "Account.diagnosis.packageCode" (fhir-spec (string->symbol "Account.diagnosis.packageCode") "https://hl7.org/fhir/R5/account.html#Account.diagnosis.packageCode" 'element))

(register-type! 'AccountProcedure (fhir-spec 'AccountProcedure "https://hl7.org/fhir/R5/account.html#Account.procedure" 'type)
  #:schema (type-schema 'AccountProcedure #f 'BackboneElement "https://hl7.org/fhir/R5/account.html#Account.procedure"
             (list
    (schema-field 'sequence 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R5/account.html#Account.procedure.sequence" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/account.html#Account.procedure.code" #f)
    (schema-field 'dateOfService 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/account.html#Account.procedure.dateOfService" #f)
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.procedure.type" #f)
    (schema-field 'packageCode 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.procedure.packageCode" #f)
    (schema-field 'device 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/account.html#Account.procedure.device" #f)
             ) #f #f))
(register-element! "Account.procedure.sequence" (fhir-spec (string->symbol "Account.procedure.sequence") "https://hl7.org/fhir/R5/account.html#Account.procedure.sequence" 'element))
(register-element! "Account.procedure.code" (fhir-spec (string->symbol "Account.procedure.code") "https://hl7.org/fhir/R5/account.html#Account.procedure.code" 'element))
(register-element! "Account.procedure.dateOfService" (fhir-spec (string->symbol "Account.procedure.dateOfService") "https://hl7.org/fhir/R5/account.html#Account.procedure.dateOfService" 'element))
(register-element! "Account.procedure.type" (fhir-spec (string->symbol "Account.procedure.type") "https://hl7.org/fhir/R5/account.html#Account.procedure.type" 'element))
(register-element! "Account.procedure.packageCode" (fhir-spec (string->symbol "Account.procedure.packageCode") "https://hl7.org/fhir/R5/account.html#Account.procedure.packageCode" 'element))
(register-element! "Account.procedure.device" (fhir-spec (string->symbol "Account.procedure.device") "https://hl7.org/fhir/R5/account.html#Account.procedure.device" 'element))

(register-type! 'AccountRelatedAccount (fhir-spec 'AccountRelatedAccount "https://hl7.org/fhir/R5/account.html#Account.relatedAccount" 'type)
  #:schema (type-schema 'AccountRelatedAccount #f 'BackboneElement "https://hl7.org/fhir/R5/account.html#Account.relatedAccount"
             (list
    (schema-field 'relationship 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.relatedAccount.relationship" #f)
    (schema-field 'account 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/account.html#Account.relatedAccount.account" #f)
             ) #f #f))
(register-element! "Account.relatedAccount.relationship" (fhir-spec (string->symbol "Account.relatedAccount.relationship") "https://hl7.org/fhir/R5/account.html#Account.relatedAccount.relationship" 'element))
(register-element! "Account.relatedAccount.account" (fhir-spec (string->symbol "Account.relatedAccount.account") "https://hl7.org/fhir/R5/account.html#Account.relatedAccount.account" 'element))

(register-type! 'AccountBalance (fhir-spec 'AccountBalance "https://hl7.org/fhir/R5/account.html#Account.balance" 'type)
  #:schema (type-schema 'AccountBalance #f 'BackboneElement "https://hl7.org/fhir/R5/account.html#Account.balance"
             (list
    (schema-field 'aggregate 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.balance.aggregate" #f)
    (schema-field 'term 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/account.html#Account.balance.term" #f)
    (schema-field 'estimate 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/account.html#Account.balance.estimate" #f)
    (schema-field 'amount 1 1 (vector 'type 'Money) #f "https://hl7.org/fhir/R5/account.html#Account.balance.amount" #f)
             ) #f #f))
(register-element! "Account.balance.aggregate" (fhir-spec (string->symbol "Account.balance.aggregate") "https://hl7.org/fhir/R5/account.html#Account.balance.aggregate" 'element))
(register-element! "Account.balance.term" (fhir-spec (string->symbol "Account.balance.term") "https://hl7.org/fhir/R5/account.html#Account.balance.term" 'element))
(register-element! "Account.balance.estimate" (fhir-spec (string->symbol "Account.balance.estimate") "https://hl7.org/fhir/R5/account.html#Account.balance.estimate" 'element))
(register-element! "Account.balance.amount" (fhir-spec (string->symbol "Account.balance.amount") "https://hl7.org/fhir/R5/account.html#Account.balance.amount" 'element))

