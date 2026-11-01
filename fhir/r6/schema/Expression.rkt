#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Expression (fhir-spec 'Expression "https://build.fhir.org/datatypes.html#Expression" 'type)
  #:schema (type-schema 'Expression #f 'DataType "https://build.fhir.org/datatypes.html#Expression"
             (list
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Expression.description" #f)
    (schema-field 'name 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Expression.name" #f)
    (schema-field 'language 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#Expression.language" #f)
    (schema-field 'expression 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#Expression.expression" #f)
    (schema-field 'reference 0 1 (vector 'prim "uri") #f "https://build.fhir.org/datatypes.html#Expression.reference" #f)
             ) #f #f))
(register-element! "Expression.description" (fhir-spec (string->symbol "Expression.description") "https://build.fhir.org/datatypes.html#Expression.description" 'element))
(register-element! "Expression.name" (fhir-spec (string->symbol "Expression.name") "https://build.fhir.org/datatypes.html#Expression.name" 'element))
(register-element! "Expression.language" (fhir-spec (string->symbol "Expression.language") "https://build.fhir.org/datatypes.html#Expression.language" 'element))
(register-element! "Expression.expression" (fhir-spec (string->symbol "Expression.expression") "https://build.fhir.org/datatypes.html#Expression.expression" 'element))
(register-element! "Expression.reference" (fhir-spec (string->symbol "Expression.reference") "https://build.fhir.org/datatypes.html#Expression.reference" 'element))

