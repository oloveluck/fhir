#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Meta (fhir-spec 'Meta "https://hl7.org/fhir/R4/datatypes.html#Meta" 'type)
  #:schema (type-schema 'Meta #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Meta"
             (list
    (schema-field 'versionId 0 1 (vector 'prim "id") #f "https://hl7.org/fhir/R4/datatypes.html#Meta.versionId" #f)
    (schema-field 'lastUpdated 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R4/datatypes.html#Meta.lastUpdated" #f)
    (schema-field 'source 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/datatypes.html#Meta.source" #f)
    (schema-field 'profile 0 '* (vector 'prim "canonical") #f "https://hl7.org/fhir/R4/datatypes.html#Meta.profile" #f)
    (schema-field 'security 0 '* (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/datatypes.html#Meta.security" #f)
    (schema-field 'tag 0 '* (vector 'type 'Coding) #f "https://hl7.org/fhir/R4/datatypes.html#Meta.tag" #f)
             ) #f #f))
(register-element! "Meta.versionId" (fhir-spec (string->symbol "Meta.versionId") "https://hl7.org/fhir/R4/datatypes.html#Meta.versionId" 'element))
(register-element! "Meta.lastUpdated" (fhir-spec (string->symbol "Meta.lastUpdated") "https://hl7.org/fhir/R4/datatypes.html#Meta.lastUpdated" 'element))
(register-element! "Meta.source" (fhir-spec (string->symbol "Meta.source") "https://hl7.org/fhir/R4/datatypes.html#Meta.source" 'element))
(register-element! "Meta.profile" (fhir-spec (string->symbol "Meta.profile") "https://hl7.org/fhir/R4/datatypes.html#Meta.profile" 'element))
(register-element! "Meta.security" (fhir-spec (string->symbol "Meta.security") "https://hl7.org/fhir/R4/datatypes.html#Meta.security" 'element))
(register-element! "Meta.tag" (fhir-spec (string->symbol "Meta.tag") "https://hl7.org/fhir/R4/datatypes.html#Meta.tag" 'element))

