#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ParameterDefinition (fhir-spec 'ParameterDefinition "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition" 'type)
  #:schema (type-schema 'ParameterDefinition #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition"
             (list
    (schema-field 'name 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.name" #f)
    (schema-field 'use 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.use" #f)
    (schema-field 'min 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.min" #f)
    (schema-field 'max 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.max" #f)
    (schema-field 'documentation 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.documentation" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.type" #f)
    (schema-field 'profile 0 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.profile" #f)
             ) #f #f))
(register-element! "ParameterDefinition.name" (fhir-spec (string->symbol "ParameterDefinition.name") "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.name" 'element))
(register-element! "ParameterDefinition.use" (fhir-spec (string->symbol "ParameterDefinition.use") "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.use" 'element))
(register-element! "ParameterDefinition.min" (fhir-spec (string->symbol "ParameterDefinition.min") "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.min" 'element))
(register-element! "ParameterDefinition.max" (fhir-spec (string->symbol "ParameterDefinition.max") "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.max" 'element))
(register-element! "ParameterDefinition.documentation" (fhir-spec (string->symbol "ParameterDefinition.documentation") "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.documentation" 'element))
(register-element! "ParameterDefinition.type" (fhir-spec (string->symbol "ParameterDefinition.type") "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.type" 'element))
(register-element! "ParameterDefinition.profile" (fhir-spec (string->symbol "ParameterDefinition.profile") "https://hl7.org/fhir/R5/datatypes.html#ParameterDefinition.profile" 'element))

