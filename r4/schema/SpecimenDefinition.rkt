#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SpecimenDefinition (fhir-spec 'SpecimenDefinition "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition" 'type)
  #:schema (type-schema 'SpecimenDefinition #f 'DomainResource "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.identifier" #f)
    (schema-field 'typeCollected 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeCollected" #f)
    (schema-field 'patientPreparation 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.patientPreparation" #f)
    (schema-field 'timeAspect 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.timeAspect" #f)
    (schema-field 'collection 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.collection" #f)
    (schema-field 'typeTested 0 '* (vector 'type 'SpecimenDefinitionTypeTested) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested" #f)
             ) #f #f))
(register-element! "SpecimenDefinition.identifier" (fhir-spec (string->symbol "SpecimenDefinition.identifier") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.identifier" 'element))
(register-element! "SpecimenDefinition.typeCollected" (fhir-spec (string->symbol "SpecimenDefinition.typeCollected") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeCollected" 'element))
(register-element! "SpecimenDefinition.patientPreparation" (fhir-spec (string->symbol "SpecimenDefinition.patientPreparation") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.patientPreparation" 'element))
(register-element! "SpecimenDefinition.timeAspect" (fhir-spec (string->symbol "SpecimenDefinition.timeAspect") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.timeAspect" 'element))
(register-element! "SpecimenDefinition.collection" (fhir-spec (string->symbol "SpecimenDefinition.collection") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.collection" 'element))
(register-element! "SpecimenDefinition.typeTested" (fhir-spec (string->symbol "SpecimenDefinition.typeTested") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested" 'element))

(register-type! 'SpecimenDefinitionTypeTested (fhir-spec 'SpecimenDefinitionTypeTested "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested" 'type)
  #:schema (type-schema 'SpecimenDefinitionTypeTested #f 'BackboneElement "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested"
             (list
    (schema-field 'isDerived 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.isDerived" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.type" #f)
    (schema-field 'preference 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.preference" #f)
    (schema-field 'container 0 1 (vector 'type 'SpecimenDefinitionTypeTestedContainer) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container" #f)
    (schema-field 'requirement 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.requirement" #f)
    (schema-field 'retentionTime 0 1 (vector 'type 'Duration) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.retentionTime" #f)
    (schema-field 'rejectionCriterion 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.rejectionCriterion" #f)
    (schema-field 'handling 0 '* (vector 'type 'SpecimenDefinitionTypeTestedHandling) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling" #f)
             ) #f #f))
(register-element! "SpecimenDefinition.typeTested.isDerived" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.isDerived") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.isDerived" 'element))
(register-element! "SpecimenDefinition.typeTested.type" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.type") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.type" 'element))
(register-element! "SpecimenDefinition.typeTested.preference" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.preference") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.preference" 'element))
(register-element! "SpecimenDefinition.typeTested.container" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container" 'element))
(register-element! "SpecimenDefinition.typeTested.requirement" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.requirement") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.requirement" 'element))
(register-element! "SpecimenDefinition.typeTested.retentionTime" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.retentionTime") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.retentionTime" 'element))
(register-element! "SpecimenDefinition.typeTested.rejectionCriterion" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.rejectionCriterion") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.rejectionCriterion" 'element))
(register-element! "SpecimenDefinition.typeTested.handling" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.handling") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling" 'element))

(register-type! 'SpecimenDefinitionTypeTestedContainer (fhir-spec 'SpecimenDefinitionTypeTestedContainer "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container" 'type)
  #:schema (type-schema 'SpecimenDefinitionTypeTestedContainer #f 'BackboneElement "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container"
             (list
    (schema-field 'material 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.material" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.type" #f)
    (schema-field 'cap 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.cap" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.description" #f)
    (schema-field 'capacity 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.capacity" #f)
    (schema-field 'additive 0 '* (vector 'type 'SpecimenDefinitionTypeTestedContainerAdditive) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.additive" #f)
    (schema-field 'preparation 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.preparation" #f)
    (schema-field 'minimumVolumeQuantity 0 1 (vector 'type 'Quantity) 'minimumVolume "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.minimumVolume[x]" #f)
    (schema-field 'minimumVolumeString 0 1 (vector 'prim "string") 'minimumVolume "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.minimumVolume[x]" #f)
             ) #f #f))
(register-element! "SpecimenDefinition.typeTested.container.material" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.material") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.material" 'element))
(register-element! "SpecimenDefinition.typeTested.container.type" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.type") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.type" 'element))
(register-element! "SpecimenDefinition.typeTested.container.cap" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.cap") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.cap" 'element))
(register-element! "SpecimenDefinition.typeTested.container.description" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.description") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.description" 'element))
(register-element! "SpecimenDefinition.typeTested.container.capacity" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.capacity") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.capacity" 'element))
(register-element! "SpecimenDefinition.typeTested.container.additive" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.additive") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.additive" 'element))
(register-element! "SpecimenDefinition.typeTested.container.preparation" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.preparation") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.preparation" 'element))
(register-element! "SpecimenDefinition.typeTested.container.minimumVolume[x]" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.minimumVolume[x]") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.minimumVolume[x]" 'element))
(register-element! "SpecimenDefinition.typeTested.container.minimumVolume[x]" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.minimumVolume[x]") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.minimumVolume[x]" 'element))

(register-type! 'SpecimenDefinitionTypeTestedContainerAdditive (fhir-spec 'SpecimenDefinitionTypeTestedContainerAdditive "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.additive" 'type)
  #:schema (type-schema 'SpecimenDefinitionTypeTestedContainerAdditive #f 'BackboneElement "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.additive"
             (list
    (schema-field 'additiveCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'additive "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.additive.additive[x]" #f)
    (schema-field 'additiveReference 0 1 (vector 'type 'Reference) 'additive "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.additive.additive[x]" #f)
             ) #f #f))
(register-element! "SpecimenDefinition.typeTested.container.additive.additive[x]" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.additive.additive[x]") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.additive.additive[x]" 'element))
(register-element! "SpecimenDefinition.typeTested.container.additive.additive[x]" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.container.additive.additive[x]") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.container.additive.additive[x]" 'element))

(register-type! 'SpecimenDefinitionTypeTestedHandling (fhir-spec 'SpecimenDefinitionTypeTestedHandling "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling" 'type)
  #:schema (type-schema 'SpecimenDefinitionTypeTestedHandling #f 'BackboneElement "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling"
             (list
    (schema-field 'temperatureQualifier 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling.temperatureQualifier" #f)
    (schema-field 'temperatureRange 0 1 (vector 'type 'Range) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling.temperatureRange" #f)
    (schema-field 'maxDuration 0 1 (vector 'type 'Duration) #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling.maxDuration" #f)
    (schema-field 'instruction 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling.instruction" #f)
             ) #f #f))
(register-element! "SpecimenDefinition.typeTested.handling.temperatureQualifier" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.handling.temperatureQualifier") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling.temperatureQualifier" 'element))
(register-element! "SpecimenDefinition.typeTested.handling.temperatureRange" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.handling.temperatureRange") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling.temperatureRange" 'element))
(register-element! "SpecimenDefinition.typeTested.handling.maxDuration" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.handling.maxDuration") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling.maxDuration" 'element))
(register-element! "SpecimenDefinition.typeTested.handling.instruction" (fhir-spec (string->symbol "SpecimenDefinition.typeTested.handling.instruction") "https://hl7.org/fhir/R4/specimendefinition.html#SpecimenDefinition.typeTested.handling.instruction" 'element))

