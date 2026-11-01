#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Practitioner (fhir-spec 'Practitioner "https://build.fhir.org/practitioner.html#Practitioner" 'type)
  #:schema (type-schema 'Practitioner #f 'DomainResource "https://build.fhir.org/practitioner.html#Practitioner"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/practitioner.html#Practitioner.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/practitioner.html#Practitioner.active" #f)
    (schema-field 'name 0 '* (vector 'type 'HumanName) #f "https://build.fhir.org/practitioner.html#Practitioner.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://build.fhir.org/practitioner.html#Practitioner.telecom" #f)
    (schema-field 'gender 0 1 (vector 'prim "code") #f "https://build.fhir.org/practitioner.html#Practitioner.gender" #f)
    (schema-field 'birthDate 0 1 (vector 'prim "date") #f "https://build.fhir.org/practitioner.html#Practitioner.birthDate" #f)
    (schema-field 'address 0 '* (vector 'type 'Address) #f "https://build.fhir.org/practitioner.html#Practitioner.address" #f)
    (schema-field 'photo 0 '* (vector 'type 'Attachment) #f "https://build.fhir.org/practitioner.html#Practitioner.photo" #f)
    (schema-field 'qualification 0 '* (vector 'type 'PractitionerQualification) #f "https://build.fhir.org/practitioner.html#Practitioner.qualification" #f)
    (schema-field 'communication 0 '* (vector 'type 'PractitionerCommunication) #f "https://build.fhir.org/practitioner.html#Practitioner.communication" #f)
    (schema-field 'deceasedBoolean 0 1 (vector 'prim "boolean") 'deceased "https://build.fhir.org/practitioner.html#Practitioner.deceased[x]" #f)
    (schema-field 'deceasedDateTime 0 1 (vector 'prim "dateTime") 'deceased "https://build.fhir.org/practitioner.html#Practitioner.deceased[x]" #f)
             ) #f #f))
(register-element! "Practitioner.identifier" (fhir-spec (string->symbol "Practitioner.identifier") "https://build.fhir.org/practitioner.html#Practitioner.identifier" 'element))
(register-element! "Practitioner.active" (fhir-spec (string->symbol "Practitioner.active") "https://build.fhir.org/practitioner.html#Practitioner.active" 'element))
(register-element! "Practitioner.name" (fhir-spec (string->symbol "Practitioner.name") "https://build.fhir.org/practitioner.html#Practitioner.name" 'element))
(register-element! "Practitioner.telecom" (fhir-spec (string->symbol "Practitioner.telecom") "https://build.fhir.org/practitioner.html#Practitioner.telecom" 'element))
(register-element! "Practitioner.gender" (fhir-spec (string->symbol "Practitioner.gender") "https://build.fhir.org/practitioner.html#Practitioner.gender" 'element))
(register-element! "Practitioner.birthDate" (fhir-spec (string->symbol "Practitioner.birthDate") "https://build.fhir.org/practitioner.html#Practitioner.birthDate" 'element))
(register-element! "Practitioner.address" (fhir-spec (string->symbol "Practitioner.address") "https://build.fhir.org/practitioner.html#Practitioner.address" 'element))
(register-element! "Practitioner.photo" (fhir-spec (string->symbol "Practitioner.photo") "https://build.fhir.org/practitioner.html#Practitioner.photo" 'element))
(register-element! "Practitioner.qualification" (fhir-spec (string->symbol "Practitioner.qualification") "https://build.fhir.org/practitioner.html#Practitioner.qualification" 'element))
(register-element! "Practitioner.communication" (fhir-spec (string->symbol "Practitioner.communication") "https://build.fhir.org/practitioner.html#Practitioner.communication" 'element))
(register-element! "Practitioner.deceased[x]" (fhir-spec (string->symbol "Practitioner.deceased[x]") "https://build.fhir.org/practitioner.html#Practitioner.deceased[x]" 'element))
(register-element! "Practitioner.deceased[x]" (fhir-spec (string->symbol "Practitioner.deceased[x]") "https://build.fhir.org/practitioner.html#Practitioner.deceased[x]" 'element))

(register-type! 'PractitionerQualification (fhir-spec 'PractitionerQualification "https://build.fhir.org/practitioner.html#Practitioner.qualification" 'type)
  #:schema (type-schema 'PractitionerQualification #f 'BackboneElement "https://build.fhir.org/practitioner.html#Practitioner.qualification"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/practitioner.html#Practitioner.qualification.identifier" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/practitioner.html#Practitioner.qualification.code" #f)
    (schema-field 'status 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/practitioner.html#Practitioner.qualification.status" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/practitioner.html#Practitioner.qualification.period" #f)
    (schema-field 'issuer 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/practitioner.html#Practitioner.qualification.issuer" #f)
             ) #f #f))
(register-element! "Practitioner.qualification.identifier" (fhir-spec (string->symbol "Practitioner.qualification.identifier") "https://build.fhir.org/practitioner.html#Practitioner.qualification.identifier" 'element))
(register-element! "Practitioner.qualification.code" (fhir-spec (string->symbol "Practitioner.qualification.code") "https://build.fhir.org/practitioner.html#Practitioner.qualification.code" 'element))
(register-element! "Practitioner.qualification.status" (fhir-spec (string->symbol "Practitioner.qualification.status") "https://build.fhir.org/practitioner.html#Practitioner.qualification.status" 'element))
(register-element! "Practitioner.qualification.period" (fhir-spec (string->symbol "Practitioner.qualification.period") "https://build.fhir.org/practitioner.html#Practitioner.qualification.period" 'element))
(register-element! "Practitioner.qualification.issuer" (fhir-spec (string->symbol "Practitioner.qualification.issuer") "https://build.fhir.org/practitioner.html#Practitioner.qualification.issuer" 'element))

(register-type! 'PractitionerCommunication (fhir-spec 'PractitionerCommunication "https://build.fhir.org/practitioner.html#Practitioner.communication" 'type)
  #:schema (type-schema 'PractitionerCommunication #f 'BackboneElement "https://build.fhir.org/practitioner.html#Practitioner.communication"
             (list
    (schema-field 'language 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/practitioner.html#Practitioner.communication.language" #f)
    (schema-field 'preferred 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/practitioner.html#Practitioner.communication.preferred" #f)
             ) #f #f))
(register-element! "Practitioner.communication.language" (fhir-spec (string->symbol "Practitioner.communication.language") "https://build.fhir.org/practitioner.html#Practitioner.communication.language" 'element))
(register-element! "Practitioner.communication.preferred" (fhir-spec (string->symbol "Practitioner.communication.preferred") "https://build.fhir.org/practitioner.html#Practitioner.communication.preferred" 'element))

