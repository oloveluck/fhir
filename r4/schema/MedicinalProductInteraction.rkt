#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MedicinalProductInteraction (fhir-spec 'MedicinalProductInteraction "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction" 'type)
  #:schema (type-schema 'MedicinalProductInteraction #f 'DomainResource "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction"
             (list
    (schema-field 'subject 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.subject" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.description" #f)
    (schema-field 'interactant 0 '* (vector 'type 'MedicinalProductInteractionInteractant) #f "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.interactant" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.type" #f)
    (schema-field 'effect 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.effect" #f)
    (schema-field 'incidence 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.incidence" #f)
    (schema-field 'management 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.management" #f)
             ) #f #f))
(register-element! "MedicinalProductInteraction.subject" (fhir-spec (string->symbol "MedicinalProductInteraction.subject") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.subject" 'element))
(register-element! "MedicinalProductInteraction.description" (fhir-spec (string->symbol "MedicinalProductInteraction.description") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.description" 'element))
(register-element! "MedicinalProductInteraction.interactant" (fhir-spec (string->symbol "MedicinalProductInteraction.interactant") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.interactant" 'element))
(register-element! "MedicinalProductInteraction.type" (fhir-spec (string->symbol "MedicinalProductInteraction.type") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.type" 'element))
(register-element! "MedicinalProductInteraction.effect" (fhir-spec (string->symbol "MedicinalProductInteraction.effect") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.effect" 'element))
(register-element! "MedicinalProductInteraction.incidence" (fhir-spec (string->symbol "MedicinalProductInteraction.incidence") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.incidence" 'element))
(register-element! "MedicinalProductInteraction.management" (fhir-spec (string->symbol "MedicinalProductInteraction.management") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.management" 'element))

(register-type! 'MedicinalProductInteractionInteractant (fhir-spec 'MedicinalProductInteractionInteractant "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.interactant" 'type)
  #:schema (type-schema 'MedicinalProductInteractionInteractant #f 'BackboneElement "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.interactant"
             (list
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.interactant.item[x]" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.interactant.item[x]" #f)
             ) #f #f))
(register-element! "MedicinalProductInteraction.interactant.item[x]" (fhir-spec (string->symbol "MedicinalProductInteraction.interactant.item[x]") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.interactant.item[x]" 'element))
(register-element! "MedicinalProductInteraction.interactant.item[x]" (fhir-spec (string->symbol "MedicinalProductInteraction.interactant.item[x]") "https://hl7.org/fhir/R4/medicinalproductinteraction.html#MedicinalProductInteraction.interactant.item[x]" 'element))

