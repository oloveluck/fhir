#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'TriggerDefinition (fhir-spec 'TriggerDefinition "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition" 'type)
  #:schema (type-schema 'TriggerDefinition #f 'Element "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.type" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.name" #f)
    (schema-field 'data 0 '* (vector 'type 'DataRequirement) #f "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.data" #f)
    (schema-field 'condition 0 1 (vector 'type 'Expression) #f "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.condition" #f)
    (schema-field 'timingTiming 0 1 (vector 'type 'Timing) 'timing "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.timing[x]" #f)
    (schema-field 'timingReference 0 1 (vector 'type 'Reference) 'timing "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.timing[x]" #f)
    (schema-field 'timingDate 0 1 (vector 'prim "date") 'timing "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.timing[x]" #f)
    (schema-field 'timingDateTime 0 1 (vector 'prim "dateTime") 'timing "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.timing[x]" #f)
             ) #f #f))
(register-element! "TriggerDefinition.type" (fhir-spec (string->symbol "TriggerDefinition.type") "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.type" 'element))
(register-element! "TriggerDefinition.name" (fhir-spec (string->symbol "TriggerDefinition.name") "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.name" 'element))
(register-element! "TriggerDefinition.data" (fhir-spec (string->symbol "TriggerDefinition.data") "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.data" 'element))
(register-element! "TriggerDefinition.condition" (fhir-spec (string->symbol "TriggerDefinition.condition") "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.condition" 'element))
(register-element! "TriggerDefinition.timing[x]" (fhir-spec (string->symbol "TriggerDefinition.timing[x]") "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.timing[x]" 'element))
(register-element! "TriggerDefinition.timing[x]" (fhir-spec (string->symbol "TriggerDefinition.timing[x]") "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.timing[x]" 'element))
(register-element! "TriggerDefinition.timing[x]" (fhir-spec (string->symbol "TriggerDefinition.timing[x]") "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.timing[x]" 'element))
(register-element! "TriggerDefinition.timing[x]" (fhir-spec (string->symbol "TriggerDefinition.timing[x]") "https://hl7.org/fhir/R4/datatypes.html#TriggerDefinition.timing[x]" 'element))

