#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicinalProductIndication (fhir-spec 'MedicinalProductIndication "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication" 'type)
  #:schema (type-schema 'MedicinalProductIndication #f 'DomainResource "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication"
             (list
    (schema-field 'subject 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.subject" #f)
    (schema-field 'diseaseSymptomProcedure 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.diseaseSymptomProcedure" #f)
    (schema-field 'diseaseStatus 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.diseaseStatus" #f)
    (schema-field 'comorbidity 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.comorbidity" #f)
    (schema-field 'intendedEffect 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.intendedEffect" #f)
    (schema-field 'duration 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.duration" #f)
    (schema-field 'otherTherapy 0 '* (vector 'type 'MedicinalProductIndicationOtherTherapy) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy" #f)
    (schema-field 'undesirableEffect 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.undesirableEffect" #f)
    (schema-field 'population 0 '* (vector 'type 'Population) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.population" #f)
             ) #f #f))
(register-element! "MedicinalProductIndication.subject" (fhir-spec (string->symbol "MedicinalProductIndication.subject") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.subject" 'element))
(register-element! "MedicinalProductIndication.diseaseSymptomProcedure" (fhir-spec (string->symbol "MedicinalProductIndication.diseaseSymptomProcedure") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.diseaseSymptomProcedure" 'element))
(register-element! "MedicinalProductIndication.diseaseStatus" (fhir-spec (string->symbol "MedicinalProductIndication.diseaseStatus") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.diseaseStatus" 'element))
(register-element! "MedicinalProductIndication.comorbidity" (fhir-spec (string->symbol "MedicinalProductIndication.comorbidity") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.comorbidity" 'element))
(register-element! "MedicinalProductIndication.intendedEffect" (fhir-spec (string->symbol "MedicinalProductIndication.intendedEffect") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.intendedEffect" 'element))
(register-element! "MedicinalProductIndication.duration" (fhir-spec (string->symbol "MedicinalProductIndication.duration") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.duration" 'element))
(register-element! "MedicinalProductIndication.otherTherapy" (fhir-spec (string->symbol "MedicinalProductIndication.otherTherapy") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy" 'element))
(register-element! "MedicinalProductIndication.undesirableEffect" (fhir-spec (string->symbol "MedicinalProductIndication.undesirableEffect") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.undesirableEffect" 'element))
(register-element! "MedicinalProductIndication.population" (fhir-spec (string->symbol "MedicinalProductIndication.population") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.population" 'element))

(register-type! 'MedicinalProductIndicationOtherTherapy (fhir-spec 'MedicinalProductIndicationOtherTherapy "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy" 'type)
  #:schema (type-schema 'MedicinalProductIndicationOtherTherapy #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy"
             (list
    (schema-field 'therapyRelationshipType 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy.therapyRelationshipType" #f)
    (schema-field 'medicationCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'medication "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy.medication[x]" #f)
    (schema-field 'medicationReference 0 1 (vector 'type 'Reference) 'medication "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy.medication[x]" #f)
             ) #f #f))
(register-element! "MedicinalProductIndication.otherTherapy.therapyRelationshipType" (fhir-spec (string->symbol "MedicinalProductIndication.otherTherapy.therapyRelationshipType") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy.therapyRelationshipType" 'element))
(register-element! "MedicinalProductIndication.otherTherapy.medication[x]" (fhir-spec (string->symbol "MedicinalProductIndication.otherTherapy.medication[x]") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy.medication[x]" 'element))
(register-element! "MedicinalProductIndication.otherTherapy.medication[x]" (fhir-spec (string->symbol "MedicinalProductIndication.otherTherapy.medication[x]") "https://hl7.org/fhir/R4/medicinalproductindication.html#MedicinalProductIndication.otherTherapy.medication[x]" 'element))

