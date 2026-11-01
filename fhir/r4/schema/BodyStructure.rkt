#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'BodyStructure (fhir-spec 'BodyStructure "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure" 'type)
  #:schema (type-schema 'BodyStructure #f 'DomainResource "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.active" #f)
    (schema-field 'morphology 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.morphology" #f)
    (schema-field 'location 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.location" #f)
    (schema-field 'locationQualifier 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.locationQualifier" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.description" #f)
    (schema-field 'image 0 '* (vector 'type 'Attachment) #f "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.image" #f)
    (schema-field 'patient 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.patient" #f)
             ) #f #f))
(register-element! "BodyStructure.identifier" (fhir-spec (string->symbol "BodyStructure.identifier") "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.identifier" 'element))
(register-element! "BodyStructure.active" (fhir-spec (string->symbol "BodyStructure.active") "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.active" 'element))
(register-element! "BodyStructure.morphology" (fhir-spec (string->symbol "BodyStructure.morphology") "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.morphology" 'element))
(register-element! "BodyStructure.location" (fhir-spec (string->symbol "BodyStructure.location") "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.location" 'element))
(register-element! "BodyStructure.locationQualifier" (fhir-spec (string->symbol "BodyStructure.locationQualifier") "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.locationQualifier" 'element))
(register-element! "BodyStructure.description" (fhir-spec (string->symbol "BodyStructure.description") "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.description" 'element))
(register-element! "BodyStructure.image" (fhir-spec (string->symbol "BodyStructure.image") "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.image" 'element))
(register-element! "BodyStructure.patient" (fhir-spec (string->symbol "BodyStructure.patient") "https://hl7.org/fhir/R4/bodystructure.html#BodyStructure.patient" 'element))

