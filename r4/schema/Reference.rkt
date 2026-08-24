#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Reference (fhir-spec 'Reference "https://hl7.org/fhir/R4/datatypes.html#Reference" 'type)
  #:schema (type-schema 'Reference #f 'Element "https://hl7.org/fhir/R4/datatypes.html#Reference"
             (list
    (schema-field 'reference 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#Reference.reference" #f)
    (schema-field 'type 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/datatypes.html#Reference.type" #f)
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/datatypes.html#Reference.identifier" #f)
    (schema-field 'display 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#Reference.display" #f)
             ) #f #f))
(register-element! "Reference.reference" (fhir-spec (string->symbol "Reference.reference") "https://hl7.org/fhir/R4/datatypes.html#Reference.reference" 'element))
(register-element! "Reference.type" (fhir-spec (string->symbol "Reference.type") "https://hl7.org/fhir/R4/datatypes.html#Reference.type" 'element))
(register-element! "Reference.identifier" (fhir-spec (string->symbol "Reference.identifier") "https://hl7.org/fhir/R4/datatypes.html#Reference.identifier" 'element))
(register-element! "Reference.display" (fhir-spec (string->symbol "Reference.display") "https://hl7.org/fhir/R4/datatypes.html#Reference.display" 'element))

