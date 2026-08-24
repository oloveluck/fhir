#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'RelatedPerson (fhir-spec 'RelatedPerson "https://build.fhir.org/relatedperson.html#RelatedPerson" 'type)
  #:schema (type-schema 'RelatedPerson #f 'DomainResource "https://build.fhir.org/relatedperson.html#RelatedPerson"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/relatedperson.html#RelatedPerson.active" #f)
    (schema-field 'patient 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.patient" #f)
    (schema-field 'relationship 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.relationship" #f)
    (schema-field 'role 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.role" #f)
    (schema-field 'name 0 '* (vector 'type 'HumanName) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.telecom" #f)
    (schema-field 'gender 0 1 (vector 'prim "code") #f "https://build.fhir.org/relatedperson.html#RelatedPerson.gender" #f)
    (schema-field 'birthDate 0 1 (vector 'prim "date") #f "https://build.fhir.org/relatedperson.html#RelatedPerson.birthDate" #f)
    (schema-field 'address 0 '* (vector 'type 'Address) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.address" #f)
    (schema-field 'photo 0 '* (vector 'type 'Attachment) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.photo" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.period" #f)
    (schema-field 'communication 0 '* (vector 'type 'RelatedPersonCommunication) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.communication" #f)
             ) #f #f))
(register-element! "RelatedPerson.identifier" (fhir-spec (string->symbol "RelatedPerson.identifier") "https://build.fhir.org/relatedperson.html#RelatedPerson.identifier" 'element))
(register-element! "RelatedPerson.active" (fhir-spec (string->symbol "RelatedPerson.active") "https://build.fhir.org/relatedperson.html#RelatedPerson.active" 'element))
(register-element! "RelatedPerson.patient" (fhir-spec (string->symbol "RelatedPerson.patient") "https://build.fhir.org/relatedperson.html#RelatedPerson.patient" 'element))
(register-element! "RelatedPerson.relationship" (fhir-spec (string->symbol "RelatedPerson.relationship") "https://build.fhir.org/relatedperson.html#RelatedPerson.relationship" 'element))
(register-element! "RelatedPerson.role" (fhir-spec (string->symbol "RelatedPerson.role") "https://build.fhir.org/relatedperson.html#RelatedPerson.role" 'element))
(register-element! "RelatedPerson.name" (fhir-spec (string->symbol "RelatedPerson.name") "https://build.fhir.org/relatedperson.html#RelatedPerson.name" 'element))
(register-element! "RelatedPerson.telecom" (fhir-spec (string->symbol "RelatedPerson.telecom") "https://build.fhir.org/relatedperson.html#RelatedPerson.telecom" 'element))
(register-element! "RelatedPerson.gender" (fhir-spec (string->symbol "RelatedPerson.gender") "https://build.fhir.org/relatedperson.html#RelatedPerson.gender" 'element))
(register-element! "RelatedPerson.birthDate" (fhir-spec (string->symbol "RelatedPerson.birthDate") "https://build.fhir.org/relatedperson.html#RelatedPerson.birthDate" 'element))
(register-element! "RelatedPerson.address" (fhir-spec (string->symbol "RelatedPerson.address") "https://build.fhir.org/relatedperson.html#RelatedPerson.address" 'element))
(register-element! "RelatedPerson.photo" (fhir-spec (string->symbol "RelatedPerson.photo") "https://build.fhir.org/relatedperson.html#RelatedPerson.photo" 'element))
(register-element! "RelatedPerson.period" (fhir-spec (string->symbol "RelatedPerson.period") "https://build.fhir.org/relatedperson.html#RelatedPerson.period" 'element))
(register-element! "RelatedPerson.communication" (fhir-spec (string->symbol "RelatedPerson.communication") "https://build.fhir.org/relatedperson.html#RelatedPerson.communication" 'element))

(register-type! 'RelatedPersonCommunication (fhir-spec 'RelatedPersonCommunication "https://build.fhir.org/relatedperson.html#RelatedPerson.communication" 'type)
  #:schema (type-schema 'RelatedPersonCommunication #f 'BackboneElement "https://build.fhir.org/relatedperson.html#RelatedPerson.communication"
             (list
    (schema-field 'language 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/relatedperson.html#RelatedPerson.communication.language" #f)
    (schema-field 'preferred 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/relatedperson.html#RelatedPerson.communication.preferred" #f)
             ) #f #f))
(register-element! "RelatedPerson.communication.language" (fhir-spec (string->symbol "RelatedPerson.communication.language") "https://build.fhir.org/relatedperson.html#RelatedPerson.communication.language" 'element))
(register-element! "RelatedPerson.communication.preferred" (fhir-spec (string->symbol "RelatedPerson.communication.preferred") "https://build.fhir.org/relatedperson.html#RelatedPerson.communication.preferred" 'element))

