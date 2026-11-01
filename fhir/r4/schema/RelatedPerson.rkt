#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'RelatedPerson (fhir-spec 'RelatedPerson "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson" 'type)
  #:schema (type-schema 'RelatedPerson #f 'DomainResource "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.active" #f)
    (schema-field 'patient 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.patient" #f)
    (schema-field 'relationship 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.relationship" #f)
    (schema-field 'name 0 '* (vector 'type 'HumanName) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.telecom" #f)
    (schema-field 'gender 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.gender" #f)
    (schema-field 'birthDate 0 1 (vector 'prim "date") #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.birthDate" #f)
    (schema-field 'address 0 '* (vector 'type 'Address) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.address" #f)
    (schema-field 'photo 0 '* (vector 'type 'Attachment) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.photo" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.period" #f)
    (schema-field 'communication 0 '* (vector 'type 'RelatedPersonCommunication) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.communication" #f)
             ) #f #f))
(register-element! "RelatedPerson.identifier" (fhir-spec (string->symbol "RelatedPerson.identifier") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.identifier" 'element))
(register-element! "RelatedPerson.active" (fhir-spec (string->symbol "RelatedPerson.active") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.active" 'element))
(register-element! "RelatedPerson.patient" (fhir-spec (string->symbol "RelatedPerson.patient") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.patient" 'element))
(register-element! "RelatedPerson.relationship" (fhir-spec (string->symbol "RelatedPerson.relationship") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.relationship" 'element))
(register-element! "RelatedPerson.name" (fhir-spec (string->symbol "RelatedPerson.name") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.name" 'element))
(register-element! "RelatedPerson.telecom" (fhir-spec (string->symbol "RelatedPerson.telecom") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.telecom" 'element))
(register-element! "RelatedPerson.gender" (fhir-spec (string->symbol "RelatedPerson.gender") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.gender" 'element))
(register-element! "RelatedPerson.birthDate" (fhir-spec (string->symbol "RelatedPerson.birthDate") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.birthDate" 'element))
(register-element! "RelatedPerson.address" (fhir-spec (string->symbol "RelatedPerson.address") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.address" 'element))
(register-element! "RelatedPerson.photo" (fhir-spec (string->symbol "RelatedPerson.photo") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.photo" 'element))
(register-element! "RelatedPerson.period" (fhir-spec (string->symbol "RelatedPerson.period") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.period" 'element))
(register-element! "RelatedPerson.communication" (fhir-spec (string->symbol "RelatedPerson.communication") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.communication" 'element))

(register-type! 'RelatedPersonCommunication (fhir-spec 'RelatedPersonCommunication "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.communication" 'type)
  #:schema (type-schema 'RelatedPersonCommunication #f 'BackboneElement "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.communication"
             (list
    (schema-field 'language 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.communication.language" #f)
    (schema-field 'preferred 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.communication.preferred" #f)
             ) #f #f))
(register-element! "RelatedPerson.communication.language" (fhir-spec (string->symbol "RelatedPerson.communication.language") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.communication.language" 'element))
(register-element! "RelatedPerson.communication.preferred" (fhir-spec (string->symbol "RelatedPerson.communication.preferred") "https://hl7.org/fhir/R4/relatedperson.html#RelatedPerson.communication.preferred" 'element))

