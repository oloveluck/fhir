#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Consent (fhir-spec 'Consent "https://hl7.org/fhir/R4/consent.html#Consent" 'type)
  #:schema (type-schema 'Consent #f 'DomainResource "https://hl7.org/fhir/R4/consent.html#Consent"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/consent.html#Consent.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/consent.html#Consent.status" #f)
    (schema-field 'scope 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/consent.html#Consent.scope" #f)
    (schema-field 'category 1 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/consent.html#Consent.category" #f)
    (schema-field 'patient 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/consent.html#Consent.patient" #f)
    (schema-field 'dateTime 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/consent.html#Consent.dateTime" #f)
    (schema-field 'performer 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/consent.html#Consent.performer" #f)
    (schema-field 'organization 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/consent.html#Consent.organization" #f)
    (schema-field 'policy 0 '* (vector 'type 'ConsentPolicy) #f "https://hl7.org/fhir/R4/consent.html#Consent.policy" #f)
    (schema-field 'policyRule 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/consent.html#Consent.policyRule" #f)
    (schema-field 'verification 0 '* (vector 'type 'ConsentVerification) #f "https://hl7.org/fhir/R4/consent.html#Consent.verification" #f)
    (schema-field 'provision 0 1 (vector 'type 'ConsentProvision) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision" #f)
    (schema-field 'sourceAttachment 0 1 (vector 'type 'Attachment) 'source "https://hl7.org/fhir/R4/consent.html#Consent.source[x]" #f)
    (schema-field 'sourceReference 0 1 (vector 'type 'Reference) 'source "https://hl7.org/fhir/R4/consent.html#Consent.source[x]" #f)
             ) #f #f))
(register-element! "Consent.identifier" (fhir-spec (string->symbol "Consent.identifier") "https://hl7.org/fhir/R4/consent.html#Consent.identifier" 'element))
(register-element! "Consent.status" (fhir-spec (string->symbol "Consent.status") "https://hl7.org/fhir/R4/consent.html#Consent.status" 'element))
(register-element! "Consent.scope" (fhir-spec (string->symbol "Consent.scope") "https://hl7.org/fhir/R4/consent.html#Consent.scope" 'element))
(register-element! "Consent.category" (fhir-spec (string->symbol "Consent.category") "https://hl7.org/fhir/R4/consent.html#Consent.category" 'element))
(register-element! "Consent.patient" (fhir-spec (string->symbol "Consent.patient") "https://hl7.org/fhir/R4/consent.html#Consent.patient" 'element))
(register-element! "Consent.dateTime" (fhir-spec (string->symbol "Consent.dateTime") "https://hl7.org/fhir/R4/consent.html#Consent.dateTime" 'element))
(register-element! "Consent.performer" (fhir-spec (string->symbol "Consent.performer") "https://hl7.org/fhir/R4/consent.html#Consent.performer" 'element))
(register-element! "Consent.organization" (fhir-spec (string->symbol "Consent.organization") "https://hl7.org/fhir/R4/consent.html#Consent.organization" 'element))
(register-element! "Consent.policy" (fhir-spec (string->symbol "Consent.policy") "https://hl7.org/fhir/R4/consent.html#Consent.policy" 'element))
(register-element! "Consent.policyRule" (fhir-spec (string->symbol "Consent.policyRule") "https://hl7.org/fhir/R4/consent.html#Consent.policyRule" 'element))
(register-element! "Consent.verification" (fhir-spec (string->symbol "Consent.verification") "https://hl7.org/fhir/R4/consent.html#Consent.verification" 'element))
(register-element! "Consent.provision" (fhir-spec (string->symbol "Consent.provision") "https://hl7.org/fhir/R4/consent.html#Consent.provision" 'element))
(register-element! "Consent.source[x]" (fhir-spec (string->symbol "Consent.source[x]") "https://hl7.org/fhir/R4/consent.html#Consent.source[x]" 'element))
(register-element! "Consent.source[x]" (fhir-spec (string->symbol "Consent.source[x]") "https://hl7.org/fhir/R4/consent.html#Consent.source[x]" 'element))

(register-type! 'ConsentPolicy (fhir-spec 'ConsentPolicy "https://hl7.org/fhir/R4/consent.html#Consent.policy" 'type)
  #:schema (type-schema 'ConsentPolicy #f 'BackboneElement "https://hl7.org/fhir/R4/consent.html#Consent.policy"
             (list
    (schema-field 'authority 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/consent.html#Consent.policy.authority" #f)
    (schema-field 'uri 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/consent.html#Consent.policy.uri" #f)
             ) #f #f))
(register-element! "Consent.policy.authority" (fhir-spec (string->symbol "Consent.policy.authority") "https://hl7.org/fhir/R4/consent.html#Consent.policy.authority" 'element))
(register-element! "Consent.policy.uri" (fhir-spec (string->symbol "Consent.policy.uri") "https://hl7.org/fhir/R4/consent.html#Consent.policy.uri" 'element))

(register-type! 'ConsentVerification (fhir-spec 'ConsentVerification "https://hl7.org/fhir/R4/consent.html#Consent.verification" 'type)
  #:schema (type-schema 'ConsentVerification #f 'BackboneElement "https://hl7.org/fhir/R4/consent.html#Consent.verification"
             (list
    (schema-field 'verified 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/consent.html#Consent.verification.verified" #f)
    (schema-field 'verifiedWith 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/consent.html#Consent.verification.verifiedWith" #f)
    (schema-field 'verificationDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/consent.html#Consent.verification.verificationDate" #f)
             ) #f #f))
(register-element! "Consent.verification.verified" (fhir-spec (string->symbol "Consent.verification.verified") "https://hl7.org/fhir/R4/consent.html#Consent.verification.verified" 'element))
(register-element! "Consent.verification.verifiedWith" (fhir-spec (string->symbol "Consent.verification.verifiedWith") "https://hl7.org/fhir/R4/consent.html#Consent.verification.verifiedWith" 'element))
(register-element! "Consent.verification.verificationDate" (fhir-spec (string->symbol "Consent.verification.verificationDate") "https://hl7.org/fhir/R4/consent.html#Consent.verification.verificationDate" 'element))

(register-type! 'ConsentProvision (fhir-spec 'ConsentProvision "https://hl7.org/fhir/R4/consent.html#Consent.provision" 'type)
  #:schema (type-schema 'ConsentProvision #f 'BackboneElement "https://hl7.org/fhir/R4/consent.html#Consent.provision"
             (list
    (schema-field 'type 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.type" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.period" #f)
    (schema-field 'actor 0 '* (vector 'type 'ConsentProvisionActor) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.actor" #f)
    (schema-field 'action 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.action" #f)
    (schema-field 'securityLabel 0 '* (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.securityLabel" #f)
    (schema-field 'purpose 0 '* (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.purpose" #f)
    (schema-field 'class 0 '* (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.class" #f)
    (schema-field 'code 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.code" #f)
    (schema-field 'dataPeriod 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.dataPeriod" #f)
    (schema-field 'data 0 '* (vector 'type 'ConsentProvisionData) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.data" #f)
    (schema-field 'provision 0 '* (vector 'type 'ConsentProvision) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.provision" #f)
             ) #f #f))
(register-element! "Consent.provision.type" (fhir-spec (string->symbol "Consent.provision.type") "https://hl7.org/fhir/R4/consent.html#Consent.provision.type" 'element))
(register-element! "Consent.provision.period" (fhir-spec (string->symbol "Consent.provision.period") "https://hl7.org/fhir/R4/consent.html#Consent.provision.period" 'element))
(register-element! "Consent.provision.actor" (fhir-spec (string->symbol "Consent.provision.actor") "https://hl7.org/fhir/R4/consent.html#Consent.provision.actor" 'element))
(register-element! "Consent.provision.action" (fhir-spec (string->symbol "Consent.provision.action") "https://hl7.org/fhir/R4/consent.html#Consent.provision.action" 'element))
(register-element! "Consent.provision.securityLabel" (fhir-spec (string->symbol "Consent.provision.securityLabel") "https://hl7.org/fhir/R4/consent.html#Consent.provision.securityLabel" 'element))
(register-element! "Consent.provision.purpose" (fhir-spec (string->symbol "Consent.provision.purpose") "https://hl7.org/fhir/R4/consent.html#Consent.provision.purpose" 'element))
(register-element! "Consent.provision.class" (fhir-spec (string->symbol "Consent.provision.class") "https://hl7.org/fhir/R4/consent.html#Consent.provision.class" 'element))
(register-element! "Consent.provision.code" (fhir-spec (string->symbol "Consent.provision.code") "https://hl7.org/fhir/R4/consent.html#Consent.provision.code" 'element))
(register-element! "Consent.provision.dataPeriod" (fhir-spec (string->symbol "Consent.provision.dataPeriod") "https://hl7.org/fhir/R4/consent.html#Consent.provision.dataPeriod" 'element))
(register-element! "Consent.provision.data" (fhir-spec (string->symbol "Consent.provision.data") "https://hl7.org/fhir/R4/consent.html#Consent.provision.data" 'element))
(register-element! "Consent.provision.provision" (fhir-spec (string->symbol "Consent.provision.provision") "https://hl7.org/fhir/R4/consent.html#Consent.provision.provision" 'element))

(register-type! 'ConsentProvisionActor (fhir-spec 'ConsentProvisionActor "https://hl7.org/fhir/R4/consent.html#Consent.provision.actor" 'type)
  #:schema (type-schema 'ConsentProvisionActor #f 'BackboneElement "https://hl7.org/fhir/R4/consent.html#Consent.provision.actor"
             (list
    (schema-field 'role 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.actor.role" #f)
    (schema-field 'reference 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.actor.reference" #f)
             ) #f #f))
(register-element! "Consent.provision.actor.role" (fhir-spec (string->symbol "Consent.provision.actor.role") "https://hl7.org/fhir/R4/consent.html#Consent.provision.actor.role" 'element))
(register-element! "Consent.provision.actor.reference" (fhir-spec (string->symbol "Consent.provision.actor.reference") "https://hl7.org/fhir/R4/consent.html#Consent.provision.actor.reference" 'element))

(register-type! 'ConsentProvisionData (fhir-spec 'ConsentProvisionData "https://hl7.org/fhir/R4/consent.html#Consent.provision.data" 'type)
  #:schema (type-schema 'ConsentProvisionData #f 'BackboneElement "https://hl7.org/fhir/R4/consent.html#Consent.provision.data"
             (list
    (schema-field 'meaning 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.data.meaning" #f)
    (schema-field 'reference 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/consent.html#Consent.provision.data.reference" #f)
             ) #f #f))
(register-element! "Consent.provision.data.meaning" (fhir-spec (string->symbol "Consent.provision.data.meaning") "https://hl7.org/fhir/R4/consent.html#Consent.provision.data.meaning" 'element))
(register-element! "Consent.provision.data.reference" (fhir-spec (string->symbol "Consent.provision.data.reference") "https://hl7.org/fhir/R4/consent.html#Consent.provision.data.reference" 'element))

