#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Provenance (fhir-spec 'Provenance "https://build.fhir.org/provenance.html#Provenance" 'type)
  #:schema (type-schema 'Provenance #f 'DomainResource "https://build.fhir.org/provenance.html#Provenance"
             (list
    (schema-field 'target 1 '* (vector 'type 'Reference) #f "https://build.fhir.org/provenance.html#Provenance.target" #f)
    (schema-field 'recorded 0 1 (vector 'prim "instant") #f "https://build.fhir.org/provenance.html#Provenance.recorded" #f)
    (schema-field 'policy 0 '* (vector 'prim "uri") #f "https://build.fhir.org/provenance.html#Provenance.policy" #f)
    (schema-field 'location 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/provenance.html#Provenance.location" #f)
    (schema-field 'authorization 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/provenance.html#Provenance.authorization" #f)
    (schema-field 'why 0 1 (vector 'prim "markdown") #f "https://build.fhir.org/provenance.html#Provenance.why" #f)
    (schema-field 'activity 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/provenance.html#Provenance.activity" #f)
    (schema-field 'basedOn 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/provenance.html#Provenance.basedOn" #f)
    (schema-field 'patient 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/provenance.html#Provenance.patient" #f)
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/provenance.html#Provenance.encounter" #f)
    (schema-field 'agent 1 '* (vector 'type 'ProvenanceAgent) #f "https://build.fhir.org/provenance.html#Provenance.agent" #f)
    (schema-field 'entity 0 '* (vector 'type 'ProvenanceEntity) #f "https://build.fhir.org/provenance.html#Provenance.entity" #f)
    (schema-field 'signature 0 '* (vector 'type 'Signature) #f "https://build.fhir.org/provenance.html#Provenance.signature" #f)
    (schema-field 'occurredPeriod 0 1 (vector 'type 'Period) 'occurred "https://build.fhir.org/provenance.html#Provenance.occurred[x]" #f)
    (schema-field 'occurredDateTime 0 1 (vector 'prim "dateTime") 'occurred "https://build.fhir.org/provenance.html#Provenance.occurred[x]" #f)
             ) #f #f))
(register-element! "Provenance.target" (fhir-spec (string->symbol "Provenance.target") "https://build.fhir.org/provenance.html#Provenance.target" 'element))
(register-element! "Provenance.recorded" (fhir-spec (string->symbol "Provenance.recorded") "https://build.fhir.org/provenance.html#Provenance.recorded" 'element))
(register-element! "Provenance.policy" (fhir-spec (string->symbol "Provenance.policy") "https://build.fhir.org/provenance.html#Provenance.policy" 'element))
(register-element! "Provenance.location" (fhir-spec (string->symbol "Provenance.location") "https://build.fhir.org/provenance.html#Provenance.location" 'element))
(register-element! "Provenance.authorization" (fhir-spec (string->symbol "Provenance.authorization") "https://build.fhir.org/provenance.html#Provenance.authorization" 'element))
(register-element! "Provenance.why" (fhir-spec (string->symbol "Provenance.why") "https://build.fhir.org/provenance.html#Provenance.why" 'element))
(register-element! "Provenance.activity" (fhir-spec (string->symbol "Provenance.activity") "https://build.fhir.org/provenance.html#Provenance.activity" 'element))
(register-element! "Provenance.basedOn" (fhir-spec (string->symbol "Provenance.basedOn") "https://build.fhir.org/provenance.html#Provenance.basedOn" 'element))
(register-element! "Provenance.patient" (fhir-spec (string->symbol "Provenance.patient") "https://build.fhir.org/provenance.html#Provenance.patient" 'element))
(register-element! "Provenance.encounter" (fhir-spec (string->symbol "Provenance.encounter") "https://build.fhir.org/provenance.html#Provenance.encounter" 'element))
(register-element! "Provenance.agent" (fhir-spec (string->symbol "Provenance.agent") "https://build.fhir.org/provenance.html#Provenance.agent" 'element))
(register-element! "Provenance.entity" (fhir-spec (string->symbol "Provenance.entity") "https://build.fhir.org/provenance.html#Provenance.entity" 'element))
(register-element! "Provenance.signature" (fhir-spec (string->symbol "Provenance.signature") "https://build.fhir.org/provenance.html#Provenance.signature" 'element))
(register-element! "Provenance.occurred[x]" (fhir-spec (string->symbol "Provenance.occurred[x]") "https://build.fhir.org/provenance.html#Provenance.occurred[x]" 'element))
(register-element! "Provenance.occurred[x]" (fhir-spec (string->symbol "Provenance.occurred[x]") "https://build.fhir.org/provenance.html#Provenance.occurred[x]" 'element))

(register-type! 'ProvenanceAgent (fhir-spec 'ProvenanceAgent "https://build.fhir.org/provenance.html#Provenance.agent" 'type)
  #:schema (type-schema 'ProvenanceAgent #f 'BackboneElement "https://build.fhir.org/provenance.html#Provenance.agent"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/provenance.html#Provenance.agent.type" #f)
    (schema-field 'role 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/provenance.html#Provenance.agent.role" #f)
    (schema-field 'who 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/provenance.html#Provenance.agent.who" #f)
    (schema-field 'onBehalfOf 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/provenance.html#Provenance.agent.onBehalfOf" #f)
             ) #f #f))
(register-element! "Provenance.agent.type" (fhir-spec (string->symbol "Provenance.agent.type") "https://build.fhir.org/provenance.html#Provenance.agent.type" 'element))
(register-element! "Provenance.agent.role" (fhir-spec (string->symbol "Provenance.agent.role") "https://build.fhir.org/provenance.html#Provenance.agent.role" 'element))
(register-element! "Provenance.agent.who" (fhir-spec (string->symbol "Provenance.agent.who") "https://build.fhir.org/provenance.html#Provenance.agent.who" 'element))
(register-element! "Provenance.agent.onBehalfOf" (fhir-spec (string->symbol "Provenance.agent.onBehalfOf") "https://build.fhir.org/provenance.html#Provenance.agent.onBehalfOf" 'element))

(register-type! 'ProvenanceEntity (fhir-spec 'ProvenanceEntity "https://build.fhir.org/provenance.html#Provenance.entity" 'type)
  #:schema (type-schema 'ProvenanceEntity #f 'BackboneElement "https://build.fhir.org/provenance.html#Provenance.entity"
             (list
    (schema-field 'role 1 1 (vector 'prim "code") #f "https://build.fhir.org/provenance.html#Provenance.entity.role" #f)
    (schema-field 'what 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/provenance.html#Provenance.entity.what" #f)
    (schema-field 'agent 0 '* (vector 'type 'ProvenanceAgent) #f "https://build.fhir.org/provenance.html#Provenance.entity.agent" #f)
             ) #f #f))
(register-element! "Provenance.entity.role" (fhir-spec (string->symbol "Provenance.entity.role") "https://build.fhir.org/provenance.html#Provenance.entity.role" 'element))
(register-element! "Provenance.entity.what" (fhir-spec (string->symbol "Provenance.entity.what") "https://build.fhir.org/provenance.html#Provenance.entity.what" 'element))
(register-element! "Provenance.entity.agent" (fhir-spec (string->symbol "Provenance.entity.agent") "https://build.fhir.org/provenance.html#Provenance.entity.agent" 'element))

