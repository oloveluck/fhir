#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Account (fhir-spec 'Account "https://hl7.org/fhir/R4/account.html#Account" 'type)
  #:schema (type-schema 'Account #f 'DomainResource "https://hl7.org/fhir/R4/account.html#Account"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/account.html#Account.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/account.html#Account.status" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/account.html#Account.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/account.html#Account.name" #f)
    (schema-field 'subject 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/account.html#Account.subject" #f)
    (schema-field 'servicePeriod 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/account.html#Account.servicePeriod" #f)
    (schema-field 'coverage 0 '* (vector 'type 'AccountCoverage) #f "https://hl7.org/fhir/R4/account.html#Account.coverage" #f)
    (schema-field 'owner 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/account.html#Account.owner" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/account.html#Account.description" #f)
    (schema-field 'guarantor 0 '* (vector 'type 'AccountGuarantor) #f "https://hl7.org/fhir/R4/account.html#Account.guarantor" #f)
    (schema-field 'partOf 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/account.html#Account.partOf" #f)
             ) #f #f))
(register-element! "Account.identifier" (fhir-spec (string->symbol "Account.identifier") "https://hl7.org/fhir/R4/account.html#Account.identifier" 'element))
(register-element! "Account.status" (fhir-spec (string->symbol "Account.status") "https://hl7.org/fhir/R4/account.html#Account.status" 'element))
(register-element! "Account.type" (fhir-spec (string->symbol "Account.type") "https://hl7.org/fhir/R4/account.html#Account.type" 'element))
(register-element! "Account.name" (fhir-spec (string->symbol "Account.name") "https://hl7.org/fhir/R4/account.html#Account.name" 'element))
(register-element! "Account.subject" (fhir-spec (string->symbol "Account.subject") "https://hl7.org/fhir/R4/account.html#Account.subject" 'element))
(register-element! "Account.servicePeriod" (fhir-spec (string->symbol "Account.servicePeriod") "https://hl7.org/fhir/R4/account.html#Account.servicePeriod" 'element))
(register-element! "Account.coverage" (fhir-spec (string->symbol "Account.coverage") "https://hl7.org/fhir/R4/account.html#Account.coverage" 'element))
(register-element! "Account.owner" (fhir-spec (string->symbol "Account.owner") "https://hl7.org/fhir/R4/account.html#Account.owner" 'element))
(register-element! "Account.description" (fhir-spec (string->symbol "Account.description") "https://hl7.org/fhir/R4/account.html#Account.description" 'element))
(register-element! "Account.guarantor" (fhir-spec (string->symbol "Account.guarantor") "https://hl7.org/fhir/R4/account.html#Account.guarantor" 'element))
(register-element! "Account.partOf" (fhir-spec (string->symbol "Account.partOf") "https://hl7.org/fhir/R4/account.html#Account.partOf" 'element))

(register-type! 'AccountCoverage (fhir-spec 'AccountCoverage "https://hl7.org/fhir/R4/account.html#Account.coverage" 'type)
  #:schema (type-schema 'AccountCoverage #f 'BackboneElement "https://hl7.org/fhir/R4/account.html#Account.coverage"
             (list
    (schema-field 'coverage 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/account.html#Account.coverage.coverage" #f)
    (schema-field 'priority 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R4/account.html#Account.coverage.priority" #f)
             ) #f #f))
(register-element! "Account.coverage.coverage" (fhir-spec (string->symbol "Account.coverage.coverage") "https://hl7.org/fhir/R4/account.html#Account.coverage.coverage" 'element))
(register-element! "Account.coverage.priority" (fhir-spec (string->symbol "Account.coverage.priority") "https://hl7.org/fhir/R4/account.html#Account.coverage.priority" 'element))

(register-type! 'AccountGuarantor (fhir-spec 'AccountGuarantor "https://hl7.org/fhir/R4/account.html#Account.guarantor" 'type)
  #:schema (type-schema 'AccountGuarantor #f 'BackboneElement "https://hl7.org/fhir/R4/account.html#Account.guarantor"
             (list
    (schema-field 'party 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/account.html#Account.guarantor.party" #f)
    (schema-field 'onHold 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/account.html#Account.guarantor.onHold" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/account.html#Account.guarantor.period" #f)
             ) #f #f))
(register-element! "Account.guarantor.party" (fhir-spec (string->symbol "Account.guarantor.party") "https://hl7.org/fhir/R4/account.html#Account.guarantor.party" 'element))
(register-element! "Account.guarantor.onHold" (fhir-spec (string->symbol "Account.guarantor.onHold") "https://hl7.org/fhir/R4/account.html#Account.guarantor.onHold" 'element))
(register-element! "Account.guarantor.period" (fhir-spec (string->symbol "Account.guarantor.period") "https://hl7.org/fhir/R4/account.html#Account.guarantor.period" 'element))

