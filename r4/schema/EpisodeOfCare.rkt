#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'EpisodeOfCare (fhir-spec 'EpisodeOfCare "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare" 'type)
  #:schema (type-schema 'EpisodeOfCare #f 'DomainResource "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.status" #f)
    (schema-field 'statusHistory 0 '* (vector 'type 'EpisodeOfCareStatusHistory) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.statusHistory" #f)
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.type" #f)
    (schema-field 'diagnosis 0 '* (vector 'type 'EpisodeOfCareDiagnosis) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis" #f)
    (schema-field 'patient 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.patient" #f)
    (schema-field 'managingOrganization 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.managingOrganization" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.period" #f)
    (schema-field 'referralRequest 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.referralRequest" #f)
    (schema-field 'careManager 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.careManager" #f)
    (schema-field 'team 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.team" #f)
    (schema-field 'account 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.account" #f)
             ) #f #f))
(register-element! "EpisodeOfCare.identifier" (fhir-spec (string->symbol "EpisodeOfCare.identifier") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.identifier" 'element))
(register-element! "EpisodeOfCare.status" (fhir-spec (string->symbol "EpisodeOfCare.status") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.status" 'element))
(register-element! "EpisodeOfCare.statusHistory" (fhir-spec (string->symbol "EpisodeOfCare.statusHistory") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.statusHistory" 'element))
(register-element! "EpisodeOfCare.type" (fhir-spec (string->symbol "EpisodeOfCare.type") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.type" 'element))
(register-element! "EpisodeOfCare.diagnosis" (fhir-spec (string->symbol "EpisodeOfCare.diagnosis") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis" 'element))
(register-element! "EpisodeOfCare.patient" (fhir-spec (string->symbol "EpisodeOfCare.patient") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.patient" 'element))
(register-element! "EpisodeOfCare.managingOrganization" (fhir-spec (string->symbol "EpisodeOfCare.managingOrganization") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.managingOrganization" 'element))
(register-element! "EpisodeOfCare.period" (fhir-spec (string->symbol "EpisodeOfCare.period") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.period" 'element))
(register-element! "EpisodeOfCare.referralRequest" (fhir-spec (string->symbol "EpisodeOfCare.referralRequest") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.referralRequest" 'element))
(register-element! "EpisodeOfCare.careManager" (fhir-spec (string->symbol "EpisodeOfCare.careManager") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.careManager" 'element))
(register-element! "EpisodeOfCare.team" (fhir-spec (string->symbol "EpisodeOfCare.team") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.team" 'element))
(register-element! "EpisodeOfCare.account" (fhir-spec (string->symbol "EpisodeOfCare.account") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.account" 'element))

(register-type! 'EpisodeOfCareStatusHistory (fhir-spec 'EpisodeOfCareStatusHistory "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.statusHistory" 'type)
  #:schema (type-schema 'EpisodeOfCareStatusHistory #f 'BackboneElement "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.statusHistory"
             (list
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.statusHistory.status" #f)
    (schema-field 'period 1 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.statusHistory.period" #f)
             ) #f #f))
(register-element! "EpisodeOfCare.statusHistory.status" (fhir-spec (string->symbol "EpisodeOfCare.statusHistory.status") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.statusHistory.status" 'element))
(register-element! "EpisodeOfCare.statusHistory.period" (fhir-spec (string->symbol "EpisodeOfCare.statusHistory.period") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.statusHistory.period" 'element))

(register-type! 'EpisodeOfCareDiagnosis (fhir-spec 'EpisodeOfCareDiagnosis "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis" 'type)
  #:schema (type-schema 'EpisodeOfCareDiagnosis #f 'BackboneElement "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis"
             (list
    (schema-field 'condition 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis.condition" #f)
    (schema-field 'role 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis.role" #f)
    (schema-field 'rank 0 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis.rank" #f)
             ) #f #f))
(register-element! "EpisodeOfCare.diagnosis.condition" (fhir-spec (string->symbol "EpisodeOfCare.diagnosis.condition") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis.condition" 'element))
(register-element! "EpisodeOfCare.diagnosis.role" (fhir-spec (string->symbol "EpisodeOfCare.diagnosis.role") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis.role" 'element))
(register-element! "EpisodeOfCare.diagnosis.rank" (fhir-spec (string->symbol "EpisodeOfCare.diagnosis.rank") "https://hl7.org/fhir/R4/episodeofcare.html#EpisodeOfCare.diagnosis.rank" 'element))

