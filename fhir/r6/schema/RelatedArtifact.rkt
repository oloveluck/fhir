#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'RelatedArtifact (fhir-spec 'RelatedArtifact "https://build.fhir.org/datatypes.html#RelatedArtifact" 'type)
  #:schema (type-schema 'RelatedArtifact #f 'DataType "https://build.fhir.org/datatypes.html#RelatedArtifact"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#RelatedArtifact.type" #f)
    (schema-field 'label 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#RelatedArtifact.label" #f)
    (schema-field 'display 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#RelatedArtifact.display" #f)
    (schema-field 'citation 0 1 (vector 'prim "markdown") #f "https://build.fhir.org/datatypes.html#RelatedArtifact.citation" #f)
    (schema-field 'document 0 1 (vector 'type 'Attachment) #f "https://build.fhir.org/datatypes.html#RelatedArtifact.document" #f)
    (schema-field 'resource 0 1 (vector 'prim "canonical") #f "https://build.fhir.org/datatypes.html#RelatedArtifact.resource" #f)
    (schema-field 'resourceReference 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/datatypes.html#RelatedArtifact.resourceReference" #f)
    (schema-field 'artifactMarkdown 0 1 (vector 'prim "markdown") 'artifact "https://build.fhir.org/datatypes.html#RelatedArtifact.artifact[x]" #f)
    (schema-field 'artifactAttachment 0 1 (vector 'type 'Attachment) 'artifact "https://build.fhir.org/datatypes.html#RelatedArtifact.artifact[x]" #f)
    (schema-field 'artifactCanonical 0 1 (vector 'prim "canonical") 'artifact "https://build.fhir.org/datatypes.html#RelatedArtifact.artifact[x]" #f)
    (schema-field 'artifactReference 0 1 (vector 'type 'Reference) 'artifact "https://build.fhir.org/datatypes.html#RelatedArtifact.artifact[x]" #f)
             ) #f #f))
(register-element! "RelatedArtifact.type" (fhir-spec (string->symbol "RelatedArtifact.type") "https://build.fhir.org/datatypes.html#RelatedArtifact.type" 'element))
(register-element! "RelatedArtifact.label" (fhir-spec (string->symbol "RelatedArtifact.label") "https://build.fhir.org/datatypes.html#RelatedArtifact.label" 'element))
(register-element! "RelatedArtifact.display" (fhir-spec (string->symbol "RelatedArtifact.display") "https://build.fhir.org/datatypes.html#RelatedArtifact.display" 'element))
(register-element! "RelatedArtifact.citation" (fhir-spec (string->symbol "RelatedArtifact.citation") "https://build.fhir.org/datatypes.html#RelatedArtifact.citation" 'element))
(register-element! "RelatedArtifact.document" (fhir-spec (string->symbol "RelatedArtifact.document") "https://build.fhir.org/datatypes.html#RelatedArtifact.document" 'element))
(register-element! "RelatedArtifact.resource" (fhir-spec (string->symbol "RelatedArtifact.resource") "https://build.fhir.org/datatypes.html#RelatedArtifact.resource" 'element))
(register-element! "RelatedArtifact.resourceReference" (fhir-spec (string->symbol "RelatedArtifact.resourceReference") "https://build.fhir.org/datatypes.html#RelatedArtifact.resourceReference" 'element))
(register-element! "RelatedArtifact.artifact[x]" (fhir-spec (string->symbol "RelatedArtifact.artifact[x]") "https://build.fhir.org/datatypes.html#RelatedArtifact.artifact[x]" 'element))
(register-element! "RelatedArtifact.artifact[x]" (fhir-spec (string->symbol "RelatedArtifact.artifact[x]") "https://build.fhir.org/datatypes.html#RelatedArtifact.artifact[x]" 'element))
(register-element! "RelatedArtifact.artifact[x]" (fhir-spec (string->symbol "RelatedArtifact.artifact[x]") "https://build.fhir.org/datatypes.html#RelatedArtifact.artifact[x]" 'element))
(register-element! "RelatedArtifact.artifact[x]" (fhir-spec (string->symbol "RelatedArtifact.artifact[x]") "https://build.fhir.org/datatypes.html#RelatedArtifact.artifact[x]" 'element))

