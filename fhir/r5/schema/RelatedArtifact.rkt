#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'RelatedArtifact (fhir-spec 'RelatedArtifact "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact" 'type)
  #:schema (type-schema 'RelatedArtifact #f 'DataType "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.type" #f)
    (schema-field 'classifier 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.classifier" #f)
    (schema-field 'label 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.label" #f)
    (schema-field 'display 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.display" #f)
    (schema-field 'citation 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.citation" #f)
    (schema-field 'document 0 1 (vector 'type 'Attachment) #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.document" #f)
    (schema-field 'resource 0 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.resource" #f)
    (schema-field 'resourceReference 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.resourceReference" #f)
    (schema-field 'publicationStatus 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.publicationStatus" #f)
    (schema-field 'publicationDate 0 1 (vector 'prim "date") #f "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.publicationDate" #f)
             ) #f #f))
(register-element! "RelatedArtifact.type" (fhir-spec (string->symbol "RelatedArtifact.type") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.type" 'element))
(register-element! "RelatedArtifact.classifier" (fhir-spec (string->symbol "RelatedArtifact.classifier") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.classifier" 'element))
(register-element! "RelatedArtifact.label" (fhir-spec (string->symbol "RelatedArtifact.label") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.label" 'element))
(register-element! "RelatedArtifact.display" (fhir-spec (string->symbol "RelatedArtifact.display") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.display" 'element))
(register-element! "RelatedArtifact.citation" (fhir-spec (string->symbol "RelatedArtifact.citation") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.citation" 'element))
(register-element! "RelatedArtifact.document" (fhir-spec (string->symbol "RelatedArtifact.document") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.document" 'element))
(register-element! "RelatedArtifact.resource" (fhir-spec (string->symbol "RelatedArtifact.resource") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.resource" 'element))
(register-element! "RelatedArtifact.resourceReference" (fhir-spec (string->symbol "RelatedArtifact.resourceReference") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.resourceReference" 'element))
(register-element! "RelatedArtifact.publicationStatus" (fhir-spec (string->symbol "RelatedArtifact.publicationStatus") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.publicationStatus" 'element))
(register-element! "RelatedArtifact.publicationDate" (fhir-spec (string->symbol "RelatedArtifact.publicationDate") "https://hl7.org/fhir/R5/datatypes.html#RelatedArtifact.publicationDate" 'element))

