#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Expression (fhir-spec 'Expression "https://hl7.org/fhir/R5/datatypes.html#Expression" 'type)
  #:schema (type-schema 'Expression #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#Expression"
             (list
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Expression.description" #f)
    (schema-field 'name 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Expression.name" #f)
    (schema-field 'language 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#Expression.language" #f)
    (schema-field 'expression 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#Expression.expression" #f)
    (schema-field 'reference 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/datatypes.html#Expression.reference" #f)
             ) #f #f))
(register-element! "Expression.description" (fhir-spec (string->symbol "Expression.description") "https://hl7.org/fhir/R5/datatypes.html#Expression.description" 'element))
(register-element! "Expression.name" (fhir-spec (string->symbol "Expression.name") "https://hl7.org/fhir/R5/datatypes.html#Expression.name" 'element))
(register-element! "Expression.language" (fhir-spec (string->symbol "Expression.language") "https://hl7.org/fhir/R5/datatypes.html#Expression.language" 'element))
(register-element! "Expression.expression" (fhir-spec (string->symbol "Expression.expression") "https://hl7.org/fhir/R5/datatypes.html#Expression.expression" 'element))
(register-element! "Expression.reference" (fhir-spec (string->symbol "Expression.reference") "https://hl7.org/fhir/R5/datatypes.html#Expression.reference" 'element))

