#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicinalProductUndesirableEffect (fhir-spec 'MedicinalProductUndesirableEffect "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect" 'type)
  #:schema (type-schema 'MedicinalProductUndesirableEffect #f 'DomainResource "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect"
             (list
    (schema-field 'subject 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.subject" #f)
    (schema-field 'symptomConditionEffect 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.symptomConditionEffect" #f)
    (schema-field 'classification 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.classification" #f)
    (schema-field 'frequencyOfOccurrence 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.frequencyOfOccurrence" #f)
    (schema-field 'population 0 '* (vector 'type 'Population) #f "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.population" #f)
             ) #f #f))
(register-element! "MedicinalProductUndesirableEffect.subject" (fhir-spec (string->symbol "MedicinalProductUndesirableEffect.subject") "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.subject" 'element))
(register-element! "MedicinalProductUndesirableEffect.symptomConditionEffect" (fhir-spec (string->symbol "MedicinalProductUndesirableEffect.symptomConditionEffect") "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.symptomConditionEffect" 'element))
(register-element! "MedicinalProductUndesirableEffect.classification" (fhir-spec (string->symbol "MedicinalProductUndesirableEffect.classification") "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.classification" 'element))
(register-element! "MedicinalProductUndesirableEffect.frequencyOfOccurrence" (fhir-spec (string->symbol "MedicinalProductUndesirableEffect.frequencyOfOccurrence") "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.frequencyOfOccurrence" 'element))
(register-element! "MedicinalProductUndesirableEffect.population" (fhir-spec (string->symbol "MedicinalProductUndesirableEffect.population") "https://hl7.org/fhir/R4/medicinalproductundesirableeffect.html#MedicinalProductUndesirableEffect.population" 'element))

