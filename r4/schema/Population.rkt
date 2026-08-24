#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Population (fhir-spec 'Population "https://hl7.org/fhir/R4/datatypes.html#Population" 'type)
  #:schema (type-schema 'Population #f 'BackboneElement "https://hl7.org/fhir/R4/datatypes.html#Population"
             (list
    (schema-field 'gender 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/datatypes.html#Population.gender" #f)
    (schema-field 'race 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/datatypes.html#Population.race" #f)
    (schema-field 'physiologicalCondition 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/datatypes.html#Population.physiologicalCondition" #f)
    (schema-field 'ageRange 0 1 (vector 'type 'Range) 'age "https://hl7.org/fhir/R4/datatypes.html#Population.age[x]" #f)
    (schema-field 'ageCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'age "https://hl7.org/fhir/R4/datatypes.html#Population.age[x]" #f)
             ) #f #f))
(register-element! "Population.gender" (fhir-spec (string->symbol "Population.gender") "https://hl7.org/fhir/R4/datatypes.html#Population.gender" 'element))
(register-element! "Population.race" (fhir-spec (string->symbol "Population.race") "https://hl7.org/fhir/R4/datatypes.html#Population.race" 'element))
(register-element! "Population.physiologicalCondition" (fhir-spec (string->symbol "Population.physiologicalCondition") "https://hl7.org/fhir/R4/datatypes.html#Population.physiologicalCondition" 'element))
(register-element! "Population.age[x]" (fhir-spec (string->symbol "Population.age[x]") "https://hl7.org/fhir/R4/datatypes.html#Population.age[x]" 'element))
(register-element! "Population.age[x]" (fhir-spec (string->symbol "Population.age[x]") "https://hl7.org/fhir/R4/datatypes.html#Population.age[x]" 'element))

