#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'CareTeam (fhir-spec 'CareTeam "https://hl7.org/fhir/R5/careteam.html#CareTeam" 'type)
  #:schema (type-schema 'CareTeam #f 'DomainResource "https://hl7.org/fhir/R5/careteam.html#CareTeam"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.status" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.category" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.name" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.subject" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.period" #f)
    (schema-field 'participant 0 '* (vector 'type 'CareTeamParticipant) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant" #f)
    (schema-field 'reason 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.reason" #f)
    (schema-field 'managingOrganization 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.managingOrganization" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.telecom" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.note" #f)
             ) #f #f))
(register-element! "CareTeam.identifier" (fhir-spec (string->symbol "CareTeam.identifier") "https://hl7.org/fhir/R5/careteam.html#CareTeam.identifier" 'element))
(register-element! "CareTeam.status" (fhir-spec (string->symbol "CareTeam.status") "https://hl7.org/fhir/R5/careteam.html#CareTeam.status" 'element))
(register-element! "CareTeam.category" (fhir-spec (string->symbol "CareTeam.category") "https://hl7.org/fhir/R5/careteam.html#CareTeam.category" 'element))
(register-element! "CareTeam.name" (fhir-spec (string->symbol "CareTeam.name") "https://hl7.org/fhir/R5/careteam.html#CareTeam.name" 'element))
(register-element! "CareTeam.subject" (fhir-spec (string->symbol "CareTeam.subject") "https://hl7.org/fhir/R5/careteam.html#CareTeam.subject" 'element))
(register-element! "CareTeam.period" (fhir-spec (string->symbol "CareTeam.period") "https://hl7.org/fhir/R5/careteam.html#CareTeam.period" 'element))
(register-element! "CareTeam.participant" (fhir-spec (string->symbol "CareTeam.participant") "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant" 'element))
(register-element! "CareTeam.reason" (fhir-spec (string->symbol "CareTeam.reason") "https://hl7.org/fhir/R5/careteam.html#CareTeam.reason" 'element))
(register-element! "CareTeam.managingOrganization" (fhir-spec (string->symbol "CareTeam.managingOrganization") "https://hl7.org/fhir/R5/careteam.html#CareTeam.managingOrganization" 'element))
(register-element! "CareTeam.telecom" (fhir-spec (string->symbol "CareTeam.telecom") "https://hl7.org/fhir/R5/careteam.html#CareTeam.telecom" 'element))
(register-element! "CareTeam.note" (fhir-spec (string->symbol "CareTeam.note") "https://hl7.org/fhir/R5/careteam.html#CareTeam.note" 'element))

(register-type! 'CareTeamParticipant (fhir-spec 'CareTeamParticipant "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant" 'type)
  #:schema (type-schema 'CareTeamParticipant #f 'BackboneElement "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant"
             (list
    (schema-field 'role 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.role" #f)
    (schema-field 'member 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.member" #f)
    (schema-field 'onBehalfOf 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.onBehalfOf" #f)
    (schema-field 'coveragePeriod 0 1 (vector 'type 'Period) 'coverage "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.coverage[x]" #f)
    (schema-field 'coverageTiming 0 1 (vector 'type 'Timing) 'coverage "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.coverage[x]" #f)
             ) #f #f))
(register-element! "CareTeam.participant.role" (fhir-spec (string->symbol "CareTeam.participant.role") "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.role" 'element))
(register-element! "CareTeam.participant.member" (fhir-spec (string->symbol "CareTeam.participant.member") "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.member" 'element))
(register-element! "CareTeam.participant.onBehalfOf" (fhir-spec (string->symbol "CareTeam.participant.onBehalfOf") "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.onBehalfOf" 'element))
(register-element! "CareTeam.participant.coverage[x]" (fhir-spec (string->symbol "CareTeam.participant.coverage[x]") "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.coverage[x]" 'element))
(register-element! "CareTeam.participant.coverage[x]" (fhir-spec (string->symbol "CareTeam.participant.coverage[x]") "https://hl7.org/fhir/R5/careteam.html#CareTeam.participant.coverage[x]" 'element))

