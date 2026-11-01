#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Person (fhir-spec 'Person "https://hl7.org/fhir/R4/person.html#Person" 'type)
  #:schema (type-schema 'Person #f 'DomainResource "https://hl7.org/fhir/R4/person.html#Person"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/person.html#Person.identifier" #f)
    (schema-field 'name 0 '* (vector 'type 'HumanName) #f "https://hl7.org/fhir/R4/person.html#Person.name" #f)
    (schema-field 'telecom 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/person.html#Person.telecom" #f)
    (schema-field 'gender 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/person.html#Person.gender" #f)
    (schema-field 'birthDate 0 1 (vector 'prim "date") #f "https://hl7.org/fhir/R4/person.html#Person.birthDate" #f)
    (schema-field 'address 0 '* (vector 'type 'Address) #f "https://hl7.org/fhir/R4/person.html#Person.address" #f)
    (schema-field 'photo 0 1 (vector 'type 'Attachment) #f "https://hl7.org/fhir/R4/person.html#Person.photo" #f)
    (schema-field 'managingOrganization 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/person.html#Person.managingOrganization" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/person.html#Person.active" #f)
    (schema-field 'link 0 '* (vector 'type 'PersonLink) #f "https://hl7.org/fhir/R4/person.html#Person.link" #f)
             ) #f #f))
(register-element! "Person.identifier" (fhir-spec (string->symbol "Person.identifier") "https://hl7.org/fhir/R4/person.html#Person.identifier" 'element))
(register-element! "Person.name" (fhir-spec (string->symbol "Person.name") "https://hl7.org/fhir/R4/person.html#Person.name" 'element))
(register-element! "Person.telecom" (fhir-spec (string->symbol "Person.telecom") "https://hl7.org/fhir/R4/person.html#Person.telecom" 'element))
(register-element! "Person.gender" (fhir-spec (string->symbol "Person.gender") "https://hl7.org/fhir/R4/person.html#Person.gender" 'element))
(register-element! "Person.birthDate" (fhir-spec (string->symbol "Person.birthDate") "https://hl7.org/fhir/R4/person.html#Person.birthDate" 'element))
(register-element! "Person.address" (fhir-spec (string->symbol "Person.address") "https://hl7.org/fhir/R4/person.html#Person.address" 'element))
(register-element! "Person.photo" (fhir-spec (string->symbol "Person.photo") "https://hl7.org/fhir/R4/person.html#Person.photo" 'element))
(register-element! "Person.managingOrganization" (fhir-spec (string->symbol "Person.managingOrganization") "https://hl7.org/fhir/R4/person.html#Person.managingOrganization" 'element))
(register-element! "Person.active" (fhir-spec (string->symbol "Person.active") "https://hl7.org/fhir/R4/person.html#Person.active" 'element))
(register-element! "Person.link" (fhir-spec (string->symbol "Person.link") "https://hl7.org/fhir/R4/person.html#Person.link" 'element))

(register-type! 'PersonLink (fhir-spec 'PersonLink "https://hl7.org/fhir/R4/person.html#Person.link" 'type)
  #:schema (type-schema 'PersonLink #f 'BackboneElement "https://hl7.org/fhir/R4/person.html#Person.link"
             (list
    (schema-field 'target 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/person.html#Person.link.target" #f)
    (schema-field 'assurance 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/person.html#Person.link.assurance" #f)
             ) #f #f))
(register-element! "Person.link.target" (fhir-spec (string->symbol "Person.link.target") "https://hl7.org/fhir/R4/person.html#Person.link.target" 'element))
(register-element! "Person.link.assurance" (fhir-spec (string->symbol "Person.link.assurance") "https://hl7.org/fhir/R4/person.html#Person.link.assurance" 'element))

