#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'RelatedArtifact (fhir-spec 'RelatedArtifact "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact" 'type)
  #:schema (type-schema 'RelatedArtifact #f 'Element "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.type" #f)
    (schema-field 'label 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.label" #f)
    (schema-field 'display 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.display" #f)
    (schema-field 'citation 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.citation" #f)
    (schema-field 'url 0 1 (vector 'prim "url") #f "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.url" #f)
    (schema-field 'document 0 1 (vector 'type 'Attachment) #f "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.document" #f)
    (schema-field 'resource 0 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.resource" #f)
             ) #f #f))
(register-element! "RelatedArtifact.type" (fhir-spec (string->symbol "RelatedArtifact.type") "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.type" 'element))
(register-element! "RelatedArtifact.label" (fhir-spec (string->symbol "RelatedArtifact.label") "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.label" 'element))
(register-element! "RelatedArtifact.display" (fhir-spec (string->symbol "RelatedArtifact.display") "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.display" 'element))
(register-element! "RelatedArtifact.citation" (fhir-spec (string->symbol "RelatedArtifact.citation") "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.citation" 'element))
(register-element! "RelatedArtifact.url" (fhir-spec (string->symbol "RelatedArtifact.url") "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.url" 'element))
(register-element! "RelatedArtifact.document" (fhir-spec (string->symbol "RelatedArtifact.document") "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.document" 'element))
(register-element! "RelatedArtifact.resource" (fhir-spec (string->symbol "RelatedArtifact.resource") "https://hl7.org/fhir/R4/datatypes.html#RelatedArtifact.resource" 'element))

