#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicinalProductContraindication (fhir-spec 'MedicinalProductContraindication "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication" 'type)
  #:schema (type-schema 'MedicinalProductContraindication #f 'DomainResource "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication"
             (list
    (schema-field 'subject 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.subject" #f)
    (schema-field 'disease 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.disease" #f)
    (schema-field 'diseaseStatus 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.diseaseStatus" #f)
    (schema-field 'comorbidity 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.comorbidity" #f)
    (schema-field 'therapeuticIndication 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.therapeuticIndication" #f)
    (schema-field 'otherTherapy 0 '* (vector 'type 'MedicinalProductContraindicationOtherTherapy) #f "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy" #f)
    (schema-field 'population 0 '* (vector 'type 'Population) #f "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.population" #f)
             ) #f #f))
(register-element! "MedicinalProductContraindication.subject" (fhir-spec (string->symbol "MedicinalProductContraindication.subject") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.subject" 'element))
(register-element! "MedicinalProductContraindication.disease" (fhir-spec (string->symbol "MedicinalProductContraindication.disease") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.disease" 'element))
(register-element! "MedicinalProductContraindication.diseaseStatus" (fhir-spec (string->symbol "MedicinalProductContraindication.diseaseStatus") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.diseaseStatus" 'element))
(register-element! "MedicinalProductContraindication.comorbidity" (fhir-spec (string->symbol "MedicinalProductContraindication.comorbidity") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.comorbidity" 'element))
(register-element! "MedicinalProductContraindication.therapeuticIndication" (fhir-spec (string->symbol "MedicinalProductContraindication.therapeuticIndication") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.therapeuticIndication" 'element))
(register-element! "MedicinalProductContraindication.otherTherapy" (fhir-spec (string->symbol "MedicinalProductContraindication.otherTherapy") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy" 'element))
(register-element! "MedicinalProductContraindication.population" (fhir-spec (string->symbol "MedicinalProductContraindication.population") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.population" 'element))

(register-type! 'MedicinalProductContraindicationOtherTherapy (fhir-spec 'MedicinalProductContraindicationOtherTherapy "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy" 'type)
  #:schema (type-schema 'MedicinalProductContraindicationOtherTherapy #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy"
             (list
    (schema-field 'therapyRelationshipType 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy.therapyRelationshipType" #f)
    (schema-field 'medicationCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'medication "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy.medication[x]" #f)
    (schema-field 'medicationReference 0 1 (vector 'type 'Reference) 'medication "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy.medication[x]" #f)
             ) #f #f))
(register-element! "MedicinalProductContraindication.otherTherapy.therapyRelationshipType" (fhir-spec (string->symbol "MedicinalProductContraindication.otherTherapy.therapyRelationshipType") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy.therapyRelationshipType" 'element))
(register-element! "MedicinalProductContraindication.otherTherapy.medication[x]" (fhir-spec (string->symbol "MedicinalProductContraindication.otherTherapy.medication[x]") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy.medication[x]" 'element))
(register-element! "MedicinalProductContraindication.otherTherapy.medication[x]" (fhir-spec (string->symbol "MedicinalProductContraindication.otherTherapy.medication[x]") "https://hl7.org/fhir/R4/medicinalproductcontraindication.html#MedicinalProductContraindication.otherTherapy.medication[x]" 'element))

