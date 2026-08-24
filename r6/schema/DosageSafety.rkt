#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DosageSafety (fhir-spec 'DosageSafety "https://build.fhir.org/datatypes.html#DosageSafety" 'type)
  #:schema (type-schema 'DosageSafety #f 'BackboneType "https://build.fhir.org/datatypes.html#DosageSafety"
             (list
    (schema-field 'doseLimit 0 '* (vector 'type 'DosageSafetyDoseLimit) #f "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit" #f)
    (schema-field 'ifExceeded 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DosageSafety.ifExceeded" #f)
             ) #f #f))
(register-element! "DosageSafety.doseLimit" (fhir-spec (string->symbol "DosageSafety.doseLimit") "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit" 'element))
(register-element! "DosageSafety.ifExceeded" (fhir-spec (string->symbol "DosageSafety.ifExceeded") "https://build.fhir.org/datatypes.html#DosageSafety.ifExceeded" 'element))

(register-type! 'DosageSafetyDoseLimit (fhir-spec 'DosageSafetyDoseLimit "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit" 'type)
  #:schema (type-schema 'DosageSafetyDoseLimit #f 'BackboneElement "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit"
             (list
    (schema-field 'scope 1 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.scope" #f)
    (schema-field 'period 0 1 (vector 'type 'Duration) #f "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.period" #f)
    (schema-field 'text 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.text" #f)
    (schema-field 'valueInteger 0 1 (vector 'prim "integer") 'value "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.value[x]" #f)
    (schema-field 'valueExpression 0 1 (vector 'type 'Expression) 'value "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.value[x]" #f)
             ) #f #f))
(register-element! "DosageSafety.doseLimit.scope" (fhir-spec (string->symbol "DosageSafety.doseLimit.scope") "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.scope" 'element))
(register-element! "DosageSafety.doseLimit.period" (fhir-spec (string->symbol "DosageSafety.doseLimit.period") "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.period" 'element))
(register-element! "DosageSafety.doseLimit.text" (fhir-spec (string->symbol "DosageSafety.doseLimit.text") "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.text" 'element))
(register-element! "DosageSafety.doseLimit.value[x]" (fhir-spec (string->symbol "DosageSafety.doseLimit.value[x]") "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.value[x]" 'element))
(register-element! "DosageSafety.doseLimit.value[x]" (fhir-spec (string->symbol "DosageSafety.doseLimit.value[x]") "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.value[x]" 'element))
(register-element! "DosageSafety.doseLimit.value[x]" (fhir-spec (string->symbol "DosageSafety.doseLimit.value[x]") "https://build.fhir.org/datatypes.html#DosageSafety.doseLimit.value[x]" 'element))

