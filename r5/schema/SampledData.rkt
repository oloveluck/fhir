#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SampledData (fhir-spec 'SampledData "https://hl7.org/fhir/R5/datatypes.html#SampledData" 'type)
  #:schema (type-schema 'SampledData #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#SampledData"
             (list
    (schema-field 'origin 1 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.origin" #f)
    (schema-field 'interval 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.interval" #f)
    (schema-field 'intervalUnit 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.intervalUnit" #f)
    (schema-field 'factor 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.factor" #f)
    (schema-field 'lowerLimit 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.lowerLimit" #f)
    (schema-field 'upperLimit 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.upperLimit" #f)
    (schema-field 'dimensions 1 1 (vector 'prim "positiveInt") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.dimensions" #f)
    (schema-field 'codeMap 0 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.codeMap" #f)
    (schema-field 'offsets 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.offsets" #f)
    (schema-field 'data 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#SampledData.data" #f)
             ) #f #f))
(register-element! "SampledData.origin" (fhir-spec (string->symbol "SampledData.origin") "https://hl7.org/fhir/R5/datatypes.html#SampledData.origin" 'element))
(register-element! "SampledData.interval" (fhir-spec (string->symbol "SampledData.interval") "https://hl7.org/fhir/R5/datatypes.html#SampledData.interval" 'element))
(register-element! "SampledData.intervalUnit" (fhir-spec (string->symbol "SampledData.intervalUnit") "https://hl7.org/fhir/R5/datatypes.html#SampledData.intervalUnit" 'element))
(register-element! "SampledData.factor" (fhir-spec (string->symbol "SampledData.factor") "https://hl7.org/fhir/R5/datatypes.html#SampledData.factor" 'element))
(register-element! "SampledData.lowerLimit" (fhir-spec (string->symbol "SampledData.lowerLimit") "https://hl7.org/fhir/R5/datatypes.html#SampledData.lowerLimit" 'element))
(register-element! "SampledData.upperLimit" (fhir-spec (string->symbol "SampledData.upperLimit") "https://hl7.org/fhir/R5/datatypes.html#SampledData.upperLimit" 'element))
(register-element! "SampledData.dimensions" (fhir-spec (string->symbol "SampledData.dimensions") "https://hl7.org/fhir/R5/datatypes.html#SampledData.dimensions" 'element))
(register-element! "SampledData.codeMap" (fhir-spec (string->symbol "SampledData.codeMap") "https://hl7.org/fhir/R5/datatypes.html#SampledData.codeMap" 'element))
(register-element! "SampledData.offsets" (fhir-spec (string->symbol "SampledData.offsets") "https://hl7.org/fhir/R5/datatypes.html#SampledData.offsets" 'element))
(register-element! "SampledData.data" (fhir-spec (string->symbol "SampledData.data") "https://hl7.org/fhir/R5/datatypes.html#SampledData.data" 'element))

