#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Person (fhir-spec 'Person "https://build.fhir.org/person.html#Person" 'type)
  #:schema (type-schema 'Person #f 'DomainResource "https://build.fhir.org/person.html#Person"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/person.html#Person.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/person.html#Person.active" #f)
    (schema-field 'name 0 '* (vector 'type 'HumanName) #f "https://build.fhir.org/person.html#Person.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://build.fhir.org/person.html#Person.telecom" #f)
    (schema-field 'gender 0 1 (vector 'prim "code") #f "https://build.fhir.org/person.html#Person.gender" #f)
    (schema-field 'birthDate 0 1 (vector 'prim "date") #f "https://build.fhir.org/person.html#Person.birthDate" #f)
    (schema-field 'address 0 '* (vector 'type 'Address) #f "https://build.fhir.org/person.html#Person.address" #f)
    (schema-field 'maritalStatus 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/person.html#Person.maritalStatus" #f)
    (schema-field 'photo 0 '* (vector 'type 'Attachment) #f "https://build.fhir.org/person.html#Person.photo" #f)
    (schema-field 'communication 0 '* (vector 'type 'PersonCommunication) #f "https://build.fhir.org/person.html#Person.communication" #f)
    (schema-field 'managingOrganization 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/person.html#Person.managingOrganization" #f)
    (schema-field 'link 0 '* (vector 'type 'PersonLink) #f "https://build.fhir.org/person.html#Person.link" #f)
    (schema-field 'deceasedBoolean 0 1 (vector 'prim "boolean") 'deceased "https://build.fhir.org/person.html#Person.deceased[x]" #f)
    (schema-field 'deceasedDateTime 0 1 (vector 'prim "dateTime") 'deceased "https://build.fhir.org/person.html#Person.deceased[x]" #f)
             ) #f #f))
(register-element! "Person.identifier" (fhir-spec (string->symbol "Person.identifier") "https://build.fhir.org/person.html#Person.identifier" 'element))
(register-element! "Person.active" (fhir-spec (string->symbol "Person.active") "https://build.fhir.org/person.html#Person.active" 'element))
(register-element! "Person.name" (fhir-spec (string->symbol "Person.name") "https://build.fhir.org/person.html#Person.name" 'element))
(register-element! "Person.telecom" (fhir-spec (string->symbol "Person.telecom") "https://build.fhir.org/person.html#Person.telecom" 'element))
(register-element! "Person.gender" (fhir-spec (string->symbol "Person.gender") "https://build.fhir.org/person.html#Person.gender" 'element))
(register-element! "Person.birthDate" (fhir-spec (string->symbol "Person.birthDate") "https://build.fhir.org/person.html#Person.birthDate" 'element))
(register-element! "Person.address" (fhir-spec (string->symbol "Person.address") "https://build.fhir.org/person.html#Person.address" 'element))
(register-element! "Person.maritalStatus" (fhir-spec (string->symbol "Person.maritalStatus") "https://build.fhir.org/person.html#Person.maritalStatus" 'element))
(register-element! "Person.photo" (fhir-spec (string->symbol "Person.photo") "https://build.fhir.org/person.html#Person.photo" 'element))
(register-element! "Person.communication" (fhir-spec (string->symbol "Person.communication") "https://build.fhir.org/person.html#Person.communication" 'element))
(register-element! "Person.managingOrganization" (fhir-spec (string->symbol "Person.managingOrganization") "https://build.fhir.org/person.html#Person.managingOrganization" 'element))
(register-element! "Person.link" (fhir-spec (string->symbol "Person.link") "https://build.fhir.org/person.html#Person.link" 'element))
(register-element! "Person.deceased[x]" (fhir-spec (string->symbol "Person.deceased[x]") "https://build.fhir.org/person.html#Person.deceased[x]" 'element))
(register-element! "Person.deceased[x]" (fhir-spec (string->symbol "Person.deceased[x]") "https://build.fhir.org/person.html#Person.deceased[x]" 'element))

(register-type! 'PersonCommunication (fhir-spec 'PersonCommunication "https://build.fhir.org/person.html#Person.communication" 'type)
  #:schema (type-schema 'PersonCommunication #f 'BackboneElement "https://build.fhir.org/person.html#Person.communication"
             (list
    (schema-field 'language 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/person.html#Person.communication.language" #f)
    (schema-field 'preferred 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/person.html#Person.communication.preferred" #f)
             ) #f #f))
(register-element! "Person.communication.language" (fhir-spec (string->symbol "Person.communication.language") "https://build.fhir.org/person.html#Person.communication.language" 'element))
(register-element! "Person.communication.preferred" (fhir-spec (string->symbol "Person.communication.preferred") "https://build.fhir.org/person.html#Person.communication.preferred" 'element))

(register-type! 'PersonLink (fhir-spec 'PersonLink "https://build.fhir.org/person.html#Person.link" 'type)
  #:schema (type-schema 'PersonLink #f 'BackboneElement "https://build.fhir.org/person.html#Person.link"
             (list
    (schema-field 'target 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/person.html#Person.link.target" #f)
    (schema-field 'assurance 0 1 (vector 'prim "code") #f "https://build.fhir.org/person.html#Person.link.assurance" #f)
             ) #f #f))
(register-element! "Person.link.target" (fhir-spec (string->symbol "Person.link.target") "https://build.fhir.org/person.html#Person.link.target" 'element))
(register-element! "Person.link.assurance" (fhir-spec (string->symbol "Person.link.assurance") "https://build.fhir.org/person.html#Person.link.assurance" 'element))

