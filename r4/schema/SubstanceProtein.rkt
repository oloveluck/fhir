#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SubstanceProtein (fhir-spec 'SubstanceProtein "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein" 'type)
  #:schema (type-schema 'SubstanceProtein #f 'DomainResource "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein"
             (list
    (schema-field 'sequenceType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.sequenceType" #f)
    (schema-field 'numberOfSubunits 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.numberOfSubunits" #f)
    (schema-field 'disulfideLinkage 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.disulfideLinkage" #f)
    (schema-field 'subunit 0 '* (vector 'type 'SubstanceProteinSubunit) #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit" #f)
             ) #f #f))
(register-element! "SubstanceProtein.sequenceType" (fhir-spec (string->symbol "SubstanceProtein.sequenceType") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.sequenceType" 'element))
(register-element! "SubstanceProtein.numberOfSubunits" (fhir-spec (string->symbol "SubstanceProtein.numberOfSubunits") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.numberOfSubunits" 'element))
(register-element! "SubstanceProtein.disulfideLinkage" (fhir-spec (string->symbol "SubstanceProtein.disulfideLinkage") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.disulfideLinkage" 'element))
(register-element! "SubstanceProtein.subunit" (fhir-spec (string->symbol "SubstanceProtein.subunit") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit" 'element))

(register-type! 'SubstanceProteinSubunit (fhir-spec 'SubstanceProteinSubunit "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit" 'type)
  #:schema (type-schema 'SubstanceProteinSubunit #f 'BackboneElement "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit"
             (list
    (schema-field 'subunit 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.subunit" #f)
    (schema-field 'sequence 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.sequence" #f)
    (schema-field 'length 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.length" #f)
    (schema-field 'sequenceAttachment 0 1 (vector 'type 'Attachment) #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.sequenceAttachment" #f)
    (schema-field 'nTerminalModificationId 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.nTerminalModificationId" #f)
    (schema-field 'nTerminalModification 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.nTerminalModification" #f)
    (schema-field 'cTerminalModificationId 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.cTerminalModificationId" #f)
    (schema-field 'cTerminalModification 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.cTerminalModification" #f)
             ) #f #f))
(register-element! "SubstanceProtein.subunit.subunit" (fhir-spec (string->symbol "SubstanceProtein.subunit.subunit") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.subunit" 'element))
(register-element! "SubstanceProtein.subunit.sequence" (fhir-spec (string->symbol "SubstanceProtein.subunit.sequence") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.sequence" 'element))
(register-element! "SubstanceProtein.subunit.length" (fhir-spec (string->symbol "SubstanceProtein.subunit.length") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.length" 'element))
(register-element! "SubstanceProtein.subunit.sequenceAttachment" (fhir-spec (string->symbol "SubstanceProtein.subunit.sequenceAttachment") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.sequenceAttachment" 'element))
(register-element! "SubstanceProtein.subunit.nTerminalModificationId" (fhir-spec (string->symbol "SubstanceProtein.subunit.nTerminalModificationId") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.nTerminalModificationId" 'element))
(register-element! "SubstanceProtein.subunit.nTerminalModification" (fhir-spec (string->symbol "SubstanceProtein.subunit.nTerminalModification") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.nTerminalModification" 'element))
(register-element! "SubstanceProtein.subunit.cTerminalModificationId" (fhir-spec (string->symbol "SubstanceProtein.subunit.cTerminalModificationId") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.cTerminalModificationId" 'element))
(register-element! "SubstanceProtein.subunit.cTerminalModification" (fhir-spec (string->symbol "SubstanceProtein.subunit.cTerminalModification") "https://hl7.org/fhir/R4/substanceprotein.html#SubstanceProtein.subunit.cTerminalModification" 'element))

