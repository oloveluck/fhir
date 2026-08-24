#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'RelativeTime (fhir-spec 'RelativeTime "https://build.fhir.org/datatypes.html#RelativeTime" 'type)
  #:schema (type-schema 'RelativeTime #f 'BackboneType "https://build.fhir.org/datatypes.html#RelativeTime"
             (list
    (schema-field 'contextReference 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/datatypes.html#RelativeTime.contextReference" #f)
    (schema-field 'contextDefinition 0 1 (vector 'prim "canonical") #f "https://build.fhir.org/datatypes.html#RelativeTime.contextDefinition" #f)
    (schema-field 'contextPath 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#RelativeTime.contextPath" #f)
    (schema-field 'contextCode 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/datatypes.html#RelativeTime.contextCode" #f)
    (schema-field 'text 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#RelativeTime.text" #f)
    (schema-field 'offsetDuration 0 1 (vector 'type 'Duration) 'offset "https://build.fhir.org/datatypes.html#RelativeTime.offset[x]" #f)
    (schema-field 'offsetRange 0 1 (vector 'type 'Range) 'offset "https://build.fhir.org/datatypes.html#RelativeTime.offset[x]" #f)
             ) #f #f))
(register-element! "RelativeTime.contextReference" (fhir-spec (string->symbol "RelativeTime.contextReference") "https://build.fhir.org/datatypes.html#RelativeTime.contextReference" 'element))
(register-element! "RelativeTime.contextDefinition" (fhir-spec (string->symbol "RelativeTime.contextDefinition") "https://build.fhir.org/datatypes.html#RelativeTime.contextDefinition" 'element))
(register-element! "RelativeTime.contextPath" (fhir-spec (string->symbol "RelativeTime.contextPath") "https://build.fhir.org/datatypes.html#RelativeTime.contextPath" 'element))
(register-element! "RelativeTime.contextCode" (fhir-spec (string->symbol "RelativeTime.contextCode") "https://build.fhir.org/datatypes.html#RelativeTime.contextCode" 'element))
(register-element! "RelativeTime.text" (fhir-spec (string->symbol "RelativeTime.text") "https://build.fhir.org/datatypes.html#RelativeTime.text" 'element))
(register-element! "RelativeTime.offset[x]" (fhir-spec (string->symbol "RelativeTime.offset[x]") "https://build.fhir.org/datatypes.html#RelativeTime.offset[x]" 'element))
(register-element! "RelativeTime.offset[x]" (fhir-spec (string->symbol "RelativeTime.offset[x]") "https://build.fhir.org/datatypes.html#RelativeTime.offset[x]" 'element))

