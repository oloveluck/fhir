#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ImagingSelection (fhir-spec 'ImagingSelection "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection" 'type)
  #:schema (type-schema 'ImagingSelection #f 'DomainResource "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.status" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.subject" #f)
    (schema-field 'issued 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.issued" #f)
    (schema-field 'performer 0 '* (vector 'type 'ImagingSelectionPerformer) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.performer" #f)
    (schema-field 'basedOn 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.basedOn" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.category" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.code" #f)
    (schema-field 'studyUid 0 1 (vector 'prim "id") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.studyUid" #f)
    (schema-field 'derivedFrom 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.derivedFrom" #f)
    (schema-field 'endpoint 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.endpoint" #f)
    (schema-field 'seriesUid 0 1 (vector 'prim "id") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.seriesUid" #f)
    (schema-field 'seriesNumber 0 1 (vector 'prim "unsignedInt") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.seriesNumber" #f)
    (schema-field 'frameOfReferenceUid 0 1 (vector 'prim "id") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.frameOfReferenceUid" #f)
    (schema-field 'bodySite 0 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.bodySite" #f)
    (schema-field 'focus 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.focus" #f)
    (schema-field 'instance 0 '* (vector 'type 'ImagingSelectionInstance) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance" #f)
             ) #f #f))
(register-element! "ImagingSelection.identifier" (fhir-spec (string->symbol "ImagingSelection.identifier") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.identifier" 'element))
(register-element! "ImagingSelection.status" (fhir-spec (string->symbol "ImagingSelection.status") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.status" 'element))
(register-element! "ImagingSelection.subject" (fhir-spec (string->symbol "ImagingSelection.subject") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.subject" 'element))
(register-element! "ImagingSelection.issued" (fhir-spec (string->symbol "ImagingSelection.issued") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.issued" 'element))
(register-element! "ImagingSelection.performer" (fhir-spec (string->symbol "ImagingSelection.performer") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.performer" 'element))
(register-element! "ImagingSelection.basedOn" (fhir-spec (string->symbol "ImagingSelection.basedOn") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.basedOn" 'element))
(register-element! "ImagingSelection.category" (fhir-spec (string->symbol "ImagingSelection.category") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.category" 'element))
(register-element! "ImagingSelection.code" (fhir-spec (string->symbol "ImagingSelection.code") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.code" 'element))
(register-element! "ImagingSelection.studyUid" (fhir-spec (string->symbol "ImagingSelection.studyUid") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.studyUid" 'element))
(register-element! "ImagingSelection.derivedFrom" (fhir-spec (string->symbol "ImagingSelection.derivedFrom") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.derivedFrom" 'element))
(register-element! "ImagingSelection.endpoint" (fhir-spec (string->symbol "ImagingSelection.endpoint") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.endpoint" 'element))
(register-element! "ImagingSelection.seriesUid" (fhir-spec (string->symbol "ImagingSelection.seriesUid") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.seriesUid" 'element))
(register-element! "ImagingSelection.seriesNumber" (fhir-spec (string->symbol "ImagingSelection.seriesNumber") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.seriesNumber" 'element))
(register-element! "ImagingSelection.frameOfReferenceUid" (fhir-spec (string->symbol "ImagingSelection.frameOfReferenceUid") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.frameOfReferenceUid" 'element))
(register-element! "ImagingSelection.bodySite" (fhir-spec (string->symbol "ImagingSelection.bodySite") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.bodySite" 'element))
(register-element! "ImagingSelection.focus" (fhir-spec (string->symbol "ImagingSelection.focus") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.focus" 'element))
(register-element! "ImagingSelection.instance" (fhir-spec (string->symbol "ImagingSelection.instance") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance" 'element))

(register-type! 'ImagingSelectionPerformer (fhir-spec 'ImagingSelectionPerformer "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.performer" 'type)
  #:schema (type-schema 'ImagingSelectionPerformer #f 'BackboneElement "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.performer"
             (list
    (schema-field 'function 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.performer.function" #f)
    (schema-field 'actor 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.performer.actor" #f)
             ) #f #f))
(register-element! "ImagingSelection.performer.function" (fhir-spec (string->symbol "ImagingSelection.performer.function") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.performer.function" 'element))
(register-element! "ImagingSelection.performer.actor" (fhir-spec (string->symbol "ImagingSelection.performer.actor") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.performer.actor" 'element))

(register-type! 'ImagingSelectionInstance (fhir-spec 'ImagingSelectionInstance "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance" 'type)
  #:schema (type-schema 'ImagingSelectionInstance #f 'BackboneElement "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance"
             (list
    (schema-field 'uid 1 1 (vector 'prim "id") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.uid" #f)
    (schema-field 'number 0 1 (vector 'prim "unsignedInt") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.number" #f)
    (schema-field 'sopClass 0 1 (vector 'type 'Coding) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.sopClass" #f)
    (schema-field 'subset 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.subset" #f)
    (schema-field 'imageRegion2D 0 '* (vector 'type 'ImagingSelectionInstanceImageRegion2D) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion2D" #f)
    (schema-field 'imageRegion3D 0 '* (vector 'type 'ImagingSelectionInstanceImageRegion3D) #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion3D" #f)
             ) #f #f))
(register-element! "ImagingSelection.instance.uid" (fhir-spec (string->symbol "ImagingSelection.instance.uid") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.uid" 'element))
(register-element! "ImagingSelection.instance.number" (fhir-spec (string->symbol "ImagingSelection.instance.number") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.number" 'element))
(register-element! "ImagingSelection.instance.sopClass" (fhir-spec (string->symbol "ImagingSelection.instance.sopClass") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.sopClass" 'element))
(register-element! "ImagingSelection.instance.subset" (fhir-spec (string->symbol "ImagingSelection.instance.subset") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.subset" 'element))
(register-element! "ImagingSelection.instance.imageRegion2D" (fhir-spec (string->symbol "ImagingSelection.instance.imageRegion2D") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion2D" 'element))
(register-element! "ImagingSelection.instance.imageRegion3D" (fhir-spec (string->symbol "ImagingSelection.instance.imageRegion3D") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion3D" 'element))

(register-type! 'ImagingSelectionInstanceImageRegion2D (fhir-spec 'ImagingSelectionInstanceImageRegion2D "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion2D" 'type)
  #:schema (type-schema 'ImagingSelectionInstanceImageRegion2D #f 'BackboneElement "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion2D"
             (list
    (schema-field 'regionType 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion2D.regionType" #f)
    (schema-field 'coordinate 1 '* (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion2D.coordinate" #f)
             ) #f #f))
(register-element! "ImagingSelection.instance.imageRegion2D.regionType" (fhir-spec (string->symbol "ImagingSelection.instance.imageRegion2D.regionType") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion2D.regionType" 'element))
(register-element! "ImagingSelection.instance.imageRegion2D.coordinate" (fhir-spec (string->symbol "ImagingSelection.instance.imageRegion2D.coordinate") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion2D.coordinate" 'element))

(register-type! 'ImagingSelectionInstanceImageRegion3D (fhir-spec 'ImagingSelectionInstanceImageRegion3D "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion3D" 'type)
  #:schema (type-schema 'ImagingSelectionInstanceImageRegion3D #f 'BackboneElement "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion3D"
             (list
    (schema-field 'regionType 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion3D.regionType" #f)
    (schema-field 'coordinate 1 '* (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion3D.coordinate" #f)
             ) #f #f))
(register-element! "ImagingSelection.instance.imageRegion3D.regionType" (fhir-spec (string->symbol "ImagingSelection.instance.imageRegion3D.regionType") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion3D.regionType" 'element))
(register-element! "ImagingSelection.instance.imageRegion3D.coordinate" (fhir-spec (string->symbol "ImagingSelection.instance.imageRegion3D.coordinate") "https://hl7.org/fhir/R5/imagingselection.html#ImagingSelection.instance.imageRegion3D.coordinate" 'element))

