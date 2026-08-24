#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicinalProductManufactured (fhir-spec 'MedicinalProductManufactured "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured" 'type)
  #:schema (type-schema 'MedicinalProductManufactured #f 'DomainResource "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured"
             (list
    (schema-field 'manufacturedDoseForm 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.manufacturedDoseForm" #f)
    (schema-field 'unitOfPresentation 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.unitOfPresentation" #f)
    (schema-field 'quantity 1 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.quantity" #f)
    (schema-field 'manufacturer 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.manufacturer" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.ingredient" #f)
    (schema-field 'physicalCharacteristics 0 1 (vector 'type 'ProdCharacteristic) #f "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.physicalCharacteristics" #f)
    (schema-field 'otherCharacteristics 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.otherCharacteristics" #f)
             ) #f #f))
(register-element! "MedicinalProductManufactured.manufacturedDoseForm" (fhir-spec (string->symbol "MedicinalProductManufactured.manufacturedDoseForm") "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.manufacturedDoseForm" 'element))
(register-element! "MedicinalProductManufactured.unitOfPresentation" (fhir-spec (string->symbol "MedicinalProductManufactured.unitOfPresentation") "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.unitOfPresentation" 'element))
(register-element! "MedicinalProductManufactured.quantity" (fhir-spec (string->symbol "MedicinalProductManufactured.quantity") "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.quantity" 'element))
(register-element! "MedicinalProductManufactured.manufacturer" (fhir-spec (string->symbol "MedicinalProductManufactured.manufacturer") "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.manufacturer" 'element))
(register-element! "MedicinalProductManufactured.ingredient" (fhir-spec (string->symbol "MedicinalProductManufactured.ingredient") "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.ingredient" 'element))
(register-element! "MedicinalProductManufactured.physicalCharacteristics" (fhir-spec (string->symbol "MedicinalProductManufactured.physicalCharacteristics") "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.physicalCharacteristics" 'element))
(register-element! "MedicinalProductManufactured.otherCharacteristics" (fhir-spec (string->symbol "MedicinalProductManufactured.otherCharacteristics") "https://hl7.org/fhir/R4/medicinalproductmanufactured.html#MedicinalProductManufactured.otherCharacteristics" 'element))

