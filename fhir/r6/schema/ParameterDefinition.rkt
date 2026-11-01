#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ParameterDefinition (fhir-spec 'ParameterDefinition "https://build.fhir.org/datatypes.html#ParameterDefinition" 'type)
  #:schema (type-schema 'ParameterDefinition #f 'DataType "https://build.fhir.org/datatypes.html#ParameterDefinition"
             (list
    (schema-field 'name 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#ParameterDefinition.name" #f)
    (schema-field 'use 1 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#ParameterDefinition.use" #f)
    (schema-field 'min 0 1 (vector 'prim "integer") #f "https://build.fhir.org/datatypes.html#ParameterDefinition.min" #f)
    (schema-field 'max 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#ParameterDefinition.max" #f)
    (schema-field 'documentation 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#ParameterDefinition.documentation" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#ParameterDefinition.type" #f)
    (schema-field 'profile 0 1 (vector 'prim "canonical") #f "https://build.fhir.org/datatypes.html#ParameterDefinition.profile" #f)
             ) #f #f))
(register-element! "ParameterDefinition.name" (fhir-spec (string->symbol "ParameterDefinition.name") "https://build.fhir.org/datatypes.html#ParameterDefinition.name" 'element))
(register-element! "ParameterDefinition.use" (fhir-spec (string->symbol "ParameterDefinition.use") "https://build.fhir.org/datatypes.html#ParameterDefinition.use" 'element))
(register-element! "ParameterDefinition.min" (fhir-spec (string->symbol "ParameterDefinition.min") "https://build.fhir.org/datatypes.html#ParameterDefinition.min" 'element))
(register-element! "ParameterDefinition.max" (fhir-spec (string->symbol "ParameterDefinition.max") "https://build.fhir.org/datatypes.html#ParameterDefinition.max" 'element))
(register-element! "ParameterDefinition.documentation" (fhir-spec (string->symbol "ParameterDefinition.documentation") "https://build.fhir.org/datatypes.html#ParameterDefinition.documentation" 'element))
(register-element! "ParameterDefinition.type" (fhir-spec (string->symbol "ParameterDefinition.type") "https://build.fhir.org/datatypes.html#ParameterDefinition.type" 'element))
(register-element! "ParameterDefinition.profile" (fhir-spec (string->symbol "ParameterDefinition.profile") "https://build.fhir.org/datatypes.html#ParameterDefinition.profile" 'element))

