#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Meta (fhir-spec 'Meta "https://build.fhir.org/datatypes.html#Meta" 'type)
  #:schema (type-schema 'Meta #f 'DataType "https://build.fhir.org/datatypes.html#Meta"
             (list
    (schema-field 'versionId 0 1 (vector 'prim "id") #f "https://build.fhir.org/datatypes.html#Meta.versionId" #f)
    (schema-field 'lastUpdated 0 1 (vector 'prim "instant") #f "https://build.fhir.org/datatypes.html#Meta.lastUpdated" #f)
    (schema-field 'source 0 1 (vector 'prim "uri") #f "https://build.fhir.org/datatypes.html#Meta.source" #f)
    (schema-field 'profile 0 '* (vector 'prim "canonical") #f "https://build.fhir.org/datatypes.html#Meta.profile" #f)
    (schema-field 'security 0 '* (vector 'type 'Coding) #f "https://build.fhir.org/datatypes.html#Meta.security" #f)
    (schema-field 'tag 0 '* (vector 'type 'Coding) #f "https://build.fhir.org/datatypes.html#Meta.tag" #f)
             ) #f #f))
(register-element! "Meta.versionId" (fhir-spec (string->symbol "Meta.versionId") "https://build.fhir.org/datatypes.html#Meta.versionId" 'element))
(register-element! "Meta.lastUpdated" (fhir-spec (string->symbol "Meta.lastUpdated") "https://build.fhir.org/datatypes.html#Meta.lastUpdated" 'element))
(register-element! "Meta.source" (fhir-spec (string->symbol "Meta.source") "https://build.fhir.org/datatypes.html#Meta.source" 'element))
(register-element! "Meta.profile" (fhir-spec (string->symbol "Meta.profile") "https://build.fhir.org/datatypes.html#Meta.profile" 'element))
(register-element! "Meta.security" (fhir-spec (string->symbol "Meta.security") "https://build.fhir.org/datatypes.html#Meta.security" 'element))
(register-element! "Meta.tag" (fhir-spec (string->symbol "Meta.tag") "https://build.fhir.org/datatypes.html#Meta.tag" 'element))

