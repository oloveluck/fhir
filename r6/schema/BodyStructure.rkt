#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'BodyStructure (fhir-spec 'BodyStructure "https://build.fhir.org/bodystructure.html#BodyStructure" 'type)
  #:schema (type-schema 'BodyStructure #f 'DomainResource "https://build.fhir.org/bodystructure.html#BodyStructure"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/bodystructure.html#BodyStructure.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://build.fhir.org/bodystructure.html#BodyStructure.active" #f)
    (schema-field 'includedStructure 1 '* (vector 'type 'BodyStructureIncludedStructure) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure" #f)
    (schema-field 'excludedStructure 0 '* (vector 'type 'BodyStructureIncludedStructure) #f "https://build.fhir.org/bodystructure.html#BodyStructure.excludedStructure" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://build.fhir.org/bodystructure.html#BodyStructure.description" #f)
    (schema-field 'image 0 '* (vector 'type 'Attachment) #f "https://build.fhir.org/bodystructure.html#BodyStructure.image" #f)
    (schema-field 'patient 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/bodystructure.html#BodyStructure.patient" #f)
             ) #f #f))
(register-element! "BodyStructure.identifier" (fhir-spec (string->symbol "BodyStructure.identifier") "https://build.fhir.org/bodystructure.html#BodyStructure.identifier" 'element))
(register-element! "BodyStructure.active" (fhir-spec (string->symbol "BodyStructure.active") "https://build.fhir.org/bodystructure.html#BodyStructure.active" 'element))
(register-element! "BodyStructure.includedStructure" (fhir-spec (string->symbol "BodyStructure.includedStructure") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure" 'element))
(register-element! "BodyStructure.excludedStructure" (fhir-spec (string->symbol "BodyStructure.excludedStructure") "https://build.fhir.org/bodystructure.html#BodyStructure.excludedStructure" 'element))
(register-element! "BodyStructure.description" (fhir-spec (string->symbol "BodyStructure.description") "https://build.fhir.org/bodystructure.html#BodyStructure.description" 'element))
(register-element! "BodyStructure.image" (fhir-spec (string->symbol "BodyStructure.image") "https://build.fhir.org/bodystructure.html#BodyStructure.image" 'element))
(register-element! "BodyStructure.patient" (fhir-spec (string->symbol "BodyStructure.patient") "https://build.fhir.org/bodystructure.html#BodyStructure.patient" 'element))

(register-type! 'BodyStructureIncludedStructure (fhir-spec 'BodyStructureIncludedStructure "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure" 'type)
  #:schema (type-schema 'BodyStructureIncludedStructure #f 'BackboneElement "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure"
             (list
    (schema-field 'structure 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.structure" #f)
    (schema-field 'laterality 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.laterality" #f)
    (schema-field 'bodyLandmarkOrientation 0 '* (vector 'type 'BodyStructureIncludedStructureBodyLandmarkOrientation) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation" #f)
    (schema-field 'spatialReference 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.spatialReference" #f)
    (schema-field 'image 0 '* (vector 'type 'Attachment) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.image" #f)
    (schema-field 'qualifier 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.qualifier" #f)
    (schema-field 'morphology 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.morphology" #f)
             ) #f #f))
(register-element! "BodyStructure.includedStructure.structure" (fhir-spec (string->symbol "BodyStructure.includedStructure.structure") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.structure" 'element))
(register-element! "BodyStructure.includedStructure.laterality" (fhir-spec (string->symbol "BodyStructure.includedStructure.laterality") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.laterality" 'element))
(register-element! "BodyStructure.includedStructure.bodyLandmarkOrientation" (fhir-spec (string->symbol "BodyStructure.includedStructure.bodyLandmarkOrientation") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation" 'element))
(register-element! "BodyStructure.includedStructure.spatialReference" (fhir-spec (string->symbol "BodyStructure.includedStructure.spatialReference") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.spatialReference" 'element))
(register-element! "BodyStructure.includedStructure.image" (fhir-spec (string->symbol "BodyStructure.includedStructure.image") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.image" 'element))
(register-element! "BodyStructure.includedStructure.qualifier" (fhir-spec (string->symbol "BodyStructure.includedStructure.qualifier") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.qualifier" 'element))
(register-element! "BodyStructure.includedStructure.morphology" (fhir-spec (string->symbol "BodyStructure.includedStructure.morphology") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.morphology" 'element))

(register-type! 'BodyStructureIncludedStructureBodyLandmarkOrientation (fhir-spec 'BodyStructureIncludedStructureBodyLandmarkOrientation "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation" 'type)
  #:schema (type-schema 'BodyStructureIncludedStructureBodyLandmarkOrientation #f 'BackboneElement "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation"
             (list
    (schema-field 'landmarkDescription 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.landmarkDescription" #f)
    (schema-field 'clockFacePosition 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.clockFacePosition" #f)
    (schema-field 'distanceFromLandmark 0 '* (vector 'type 'BodyStructureIncludedStructureBodyLandmarkOrientationDistanceFromLandmark) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark" #f)
    (schema-field 'surfaceOrientation 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.surfaceOrientation" #f)
             ) #f #f))
(register-element! "BodyStructure.includedStructure.bodyLandmarkOrientation.landmarkDescription" (fhir-spec (string->symbol "BodyStructure.includedStructure.bodyLandmarkOrientation.landmarkDescription") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.landmarkDescription" 'element))
(register-element! "BodyStructure.includedStructure.bodyLandmarkOrientation.clockFacePosition" (fhir-spec (string->symbol "BodyStructure.includedStructure.bodyLandmarkOrientation.clockFacePosition") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.clockFacePosition" 'element))
(register-element! "BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark" (fhir-spec (string->symbol "BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark" 'element))
(register-element! "BodyStructure.includedStructure.bodyLandmarkOrientation.surfaceOrientation" (fhir-spec (string->symbol "BodyStructure.includedStructure.bodyLandmarkOrientation.surfaceOrientation") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.surfaceOrientation" 'element))

(register-type! 'BodyStructureIncludedStructureBodyLandmarkOrientationDistanceFromLandmark (fhir-spec 'BodyStructureIncludedStructureBodyLandmarkOrientationDistanceFromLandmark "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark" 'type)
  #:schema (type-schema 'BodyStructureIncludedStructureBodyLandmarkOrientationDistanceFromLandmark #f 'BackboneElement "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark"
             (list
    (schema-field 'device 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark.device" #f)
    (schema-field 'value 0 '* (vector 'type 'Quantity) #f "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark.value" #f)
             ) #f #f))
(register-element! "BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark.device" (fhir-spec (string->symbol "BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark.device") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark.device" 'element))
(register-element! "BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark.value" (fhir-spec (string->symbol "BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark.value") "https://build.fhir.org/bodystructure.html#BodyStructure.includedStructure.bodyLandmarkOrientation.distanceFromLandmark.value" 'element))

