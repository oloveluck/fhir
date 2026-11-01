#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Provenance (fhir-spec 'Provenance "https://hl7.org/fhir/R5/provenance.html#Provenance" 'type)
  #:schema (type-schema 'Provenance #f 'DomainResource "https://hl7.org/fhir/R5/provenance.html#Provenance"
             (list
    (schema-field 'target 1 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.target" #f)
    (schema-field 'recorded 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/provenance.html#Provenance.recorded" #f)
    (schema-field 'policy 0 '* (vector 'prim "uri") #f "https://hl7.org/fhir/R5/provenance.html#Provenance.policy" #f)
    (schema-field 'location 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.location" #f)
    (schema-field 'authorization 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.authorization" #f)
    (schema-field 'activity 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.activity" #f)
    (schema-field 'basedOn 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.basedOn" #f)
    (schema-field 'patient 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.patient" #f)
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.encounter" #f)
    (schema-field 'agent 1 '* (vector 'type 'ProvenanceAgent) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.agent" #f)
    (schema-field 'entity 0 '* (vector 'type 'ProvenanceEntity) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.entity" #f)
    (schema-field 'signature 0 '* (vector 'type 'Signature) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.signature" #f)
    (schema-field 'occurredPeriod 0 1 (vector 'type 'Period) 'occurred "https://hl7.org/fhir/R5/provenance.html#Provenance.occurred[x]" #f)
    (schema-field 'occurredDateTime 0 1 (vector 'prim "dateTime") 'occurred "https://hl7.org/fhir/R5/provenance.html#Provenance.occurred[x]" #f)
             ) #f #f))
(register-element! "Provenance.target" (fhir-spec (string->symbol "Provenance.target") "https://hl7.org/fhir/R5/provenance.html#Provenance.target" 'element))
(register-element! "Provenance.recorded" (fhir-spec (string->symbol "Provenance.recorded") "https://hl7.org/fhir/R5/provenance.html#Provenance.recorded" 'element))
(register-element! "Provenance.policy" (fhir-spec (string->symbol "Provenance.policy") "https://hl7.org/fhir/R5/provenance.html#Provenance.policy" 'element))
(register-element! "Provenance.location" (fhir-spec (string->symbol "Provenance.location") "https://hl7.org/fhir/R5/provenance.html#Provenance.location" 'element))
(register-element! "Provenance.authorization" (fhir-spec (string->symbol "Provenance.authorization") "https://hl7.org/fhir/R5/provenance.html#Provenance.authorization" 'element))
(register-element! "Provenance.activity" (fhir-spec (string->symbol "Provenance.activity") "https://hl7.org/fhir/R5/provenance.html#Provenance.activity" 'element))
(register-element! "Provenance.basedOn" (fhir-spec (string->symbol "Provenance.basedOn") "https://hl7.org/fhir/R5/provenance.html#Provenance.basedOn" 'element))
(register-element! "Provenance.patient" (fhir-spec (string->symbol "Provenance.patient") "https://hl7.org/fhir/R5/provenance.html#Provenance.patient" 'element))
(register-element! "Provenance.encounter" (fhir-spec (string->symbol "Provenance.encounter") "https://hl7.org/fhir/R5/provenance.html#Provenance.encounter" 'element))
(register-element! "Provenance.agent" (fhir-spec (string->symbol "Provenance.agent") "https://hl7.org/fhir/R5/provenance.html#Provenance.agent" 'element))
(register-element! "Provenance.entity" (fhir-spec (string->symbol "Provenance.entity") "https://hl7.org/fhir/R5/provenance.html#Provenance.entity" 'element))
(register-element! "Provenance.signature" (fhir-spec (string->symbol "Provenance.signature") "https://hl7.org/fhir/R5/provenance.html#Provenance.signature" 'element))
(register-element! "Provenance.occurred[x]" (fhir-spec (string->symbol "Provenance.occurred[x]") "https://hl7.org/fhir/R5/provenance.html#Provenance.occurred[x]" 'element))
(register-element! "Provenance.occurred[x]" (fhir-spec (string->symbol "Provenance.occurred[x]") "https://hl7.org/fhir/R5/provenance.html#Provenance.occurred[x]" 'element))

(register-type! 'ProvenanceAgent (fhir-spec 'ProvenanceAgent "https://hl7.org/fhir/R5/provenance.html#Provenance.agent" 'type)
  #:schema (type-schema 'ProvenanceAgent #f 'BackboneElement "https://hl7.org/fhir/R5/provenance.html#Provenance.agent"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.agent.type" #f)
    (schema-field 'role 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.agent.role" #f)
    (schema-field 'who 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.agent.who" #f)
    (schema-field 'onBehalfOf 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.agent.onBehalfOf" #f)
             ) #f #f))
(register-element! "Provenance.agent.type" (fhir-spec (string->symbol "Provenance.agent.type") "https://hl7.org/fhir/R5/provenance.html#Provenance.agent.type" 'element))
(register-element! "Provenance.agent.role" (fhir-spec (string->symbol "Provenance.agent.role") "https://hl7.org/fhir/R5/provenance.html#Provenance.agent.role" 'element))
(register-element! "Provenance.agent.who" (fhir-spec (string->symbol "Provenance.agent.who") "https://hl7.org/fhir/R5/provenance.html#Provenance.agent.who" 'element))
(register-element! "Provenance.agent.onBehalfOf" (fhir-spec (string->symbol "Provenance.agent.onBehalfOf") "https://hl7.org/fhir/R5/provenance.html#Provenance.agent.onBehalfOf" 'element))

(register-type! 'ProvenanceEntity (fhir-spec 'ProvenanceEntity "https://hl7.org/fhir/R5/provenance.html#Provenance.entity" 'type)
  #:schema (type-schema 'ProvenanceEntity #f 'BackboneElement "https://hl7.org/fhir/R5/provenance.html#Provenance.entity"
             (list
    (schema-field 'role 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/provenance.html#Provenance.entity.role" #f)
    (schema-field 'what 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.entity.what" #f)
    (schema-field 'agent 0 '* (vector 'type 'ProvenanceAgent) #f "https://hl7.org/fhir/R5/provenance.html#Provenance.entity.agent" #f)
             ) #f #f))
(register-element! "Provenance.entity.role" (fhir-spec (string->symbol "Provenance.entity.role") "https://hl7.org/fhir/R5/provenance.html#Provenance.entity.role" 'element))
(register-element! "Provenance.entity.what" (fhir-spec (string->symbol "Provenance.entity.what") "https://hl7.org/fhir/R5/provenance.html#Provenance.entity.what" 'element))
(register-element! "Provenance.entity.agent" (fhir-spec (string->symbol "Provenance.entity.agent") "https://hl7.org/fhir/R5/provenance.html#Provenance.entity.agent" 'element))

