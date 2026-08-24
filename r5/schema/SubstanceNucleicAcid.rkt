#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SubstanceNucleicAcid (fhir-spec 'SubstanceNucleicAcid "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid" 'type)
  #:schema (type-schema 'SubstanceNucleicAcid #f 'DomainResource "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid"
             (list
    (schema-field 'sequenceType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.sequenceType" #f)
    (schema-field 'numberOfSubunits 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.numberOfSubunits" #f)
    (schema-field 'areaOfHybridisation 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.areaOfHybridisation" #f)
    (schema-field 'oligoNucleotideType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.oligoNucleotideType" #f)
    (schema-field 'subunit 0 '* (vector 'type 'SubstanceNucleicAcidSubunit) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit" #f)
             ) #f #f))
(register-element! "SubstanceNucleicAcid.sequenceType" (fhir-spec (string->symbol "SubstanceNucleicAcid.sequenceType") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.sequenceType" 'element))
(register-element! "SubstanceNucleicAcid.numberOfSubunits" (fhir-spec (string->symbol "SubstanceNucleicAcid.numberOfSubunits") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.numberOfSubunits" 'element))
(register-element! "SubstanceNucleicAcid.areaOfHybridisation" (fhir-spec (string->symbol "SubstanceNucleicAcid.areaOfHybridisation") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.areaOfHybridisation" 'element))
(register-element! "SubstanceNucleicAcid.oligoNucleotideType" (fhir-spec (string->symbol "SubstanceNucleicAcid.oligoNucleotideType") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.oligoNucleotideType" 'element))
(register-element! "SubstanceNucleicAcid.subunit" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit" 'element))

(register-type! 'SubstanceNucleicAcidSubunit (fhir-spec 'SubstanceNucleicAcidSubunit "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit" 'type)
  #:schema (type-schema 'SubstanceNucleicAcidSubunit #f 'BackboneElement "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit"
             (list
    (schema-field 'subunit 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.subunit" #f)
    (schema-field 'sequence 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sequence" #f)
    (schema-field 'length 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.length" #f)
    (schema-field 'sequenceAttachment 0 1 (vector 'type 'Attachment) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sequenceAttachment" #f)
    (schema-field 'fivePrime 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.fivePrime" #f)
    (schema-field 'threePrime 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.threePrime" #f)
    (schema-field 'linkage 0 '* (vector 'type 'SubstanceNucleicAcidSubunitLinkage) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage" #f)
    (schema-field 'sugar 0 '* (vector 'type 'SubstanceNucleicAcidSubunitSugar) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar" #f)
             ) #f #f))
(register-element! "SubstanceNucleicAcid.subunit.subunit" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.subunit") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.subunit" 'element))
(register-element! "SubstanceNucleicAcid.subunit.sequence" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.sequence") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sequence" 'element))
(register-element! "SubstanceNucleicAcid.subunit.length" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.length") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.length" 'element))
(register-element! "SubstanceNucleicAcid.subunit.sequenceAttachment" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.sequenceAttachment") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sequenceAttachment" 'element))
(register-element! "SubstanceNucleicAcid.subunit.fivePrime" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.fivePrime") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.fivePrime" 'element))
(register-element! "SubstanceNucleicAcid.subunit.threePrime" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.threePrime") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.threePrime" 'element))
(register-element! "SubstanceNucleicAcid.subunit.linkage" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.linkage") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage" 'element))
(register-element! "SubstanceNucleicAcid.subunit.sugar" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.sugar") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar" 'element))

(register-type! 'SubstanceNucleicAcidSubunitLinkage (fhir-spec 'SubstanceNucleicAcidSubunitLinkage "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage" 'type)
  #:schema (type-schema 'SubstanceNucleicAcidSubunitLinkage #f 'BackboneElement "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage"
             (list
    (schema-field 'connectivity 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage.connectivity" #f)
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage.identifier" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage.name" #f)
    (schema-field 'residueSite 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage.residueSite" #f)
             ) #f #f))
(register-element! "SubstanceNucleicAcid.subunit.linkage.connectivity" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.linkage.connectivity") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage.connectivity" 'element))
(register-element! "SubstanceNucleicAcid.subunit.linkage.identifier" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.linkage.identifier") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage.identifier" 'element))
(register-element! "SubstanceNucleicAcid.subunit.linkage.name" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.linkage.name") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage.name" 'element))
(register-element! "SubstanceNucleicAcid.subunit.linkage.residueSite" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.linkage.residueSite") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.linkage.residueSite" 'element))

(register-type! 'SubstanceNucleicAcidSubunitSugar (fhir-spec 'SubstanceNucleicAcidSubunitSugar "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar" 'type)
  #:schema (type-schema 'SubstanceNucleicAcidSubunitSugar #f 'BackboneElement "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar.identifier" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar.name" #f)
    (schema-field 'residueSite 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar.residueSite" #f)
             ) #f #f))
(register-element! "SubstanceNucleicAcid.subunit.sugar.identifier" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.sugar.identifier") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar.identifier" 'element))
(register-element! "SubstanceNucleicAcid.subunit.sugar.name" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.sugar.name") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar.name" 'element))
(register-element! "SubstanceNucleicAcid.subunit.sugar.residueSite" (fhir-spec (string->symbol "SubstanceNucleicAcid.subunit.sugar.residueSite") "https://hl7.org/fhir/R5/substancenucleicacid.html#SubstanceNucleicAcid.subunit.sugar.residueSite" 'element))

