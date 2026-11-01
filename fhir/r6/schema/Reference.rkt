#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Reference (fhir-spec 'Reference "https://build.fhir.org/datatypes.html#Reference" 'type)
  #:schema (type-schema 'Reference #f 'DataType "https://build.fhir.org/datatypes.html#Reference"
             (list
    (schema-field 'reference 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Reference.reference" #f)
    (schema-field 'type 0 1 (vector 'prim "uri") #f "https://build.fhir.org/datatypes.html#Reference.type" #f)
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://build.fhir.org/datatypes.html#Reference.identifier" #f)
    (schema-field 'display 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Reference.display" #f)
             ) #f #f))
(register-element! "Reference.reference" (fhir-spec (string->symbol "Reference.reference") "https://build.fhir.org/datatypes.html#Reference.reference" 'element))
(register-element! "Reference.type" (fhir-spec (string->symbol "Reference.type") "https://build.fhir.org/datatypes.html#Reference.type" 'element))
(register-element! "Reference.identifier" (fhir-spec (string->symbol "Reference.identifier") "https://build.fhir.org/datatypes.html#Reference.identifier" 'element))
(register-element! "Reference.display" (fhir-spec (string->symbol "Reference.display") "https://build.fhir.org/datatypes.html#Reference.display" 'element))

