#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SubstanceReferenceInformation (fhir-spec 'SubstanceReferenceInformation "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation" 'type)
  #:schema (type-schema 'SubstanceReferenceInformation #f 'DomainResource "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation"
             (list
    (schema-field 'comment 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.comment" #f)
    (schema-field 'gene 0 '* (vector 'type 'SubstanceReferenceInformationGene) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene" #f)
    (schema-field 'geneElement 0 '* (vector 'type 'SubstanceReferenceInformationGeneElement) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement" #f)
    (schema-field 'target 0 '* (vector 'type 'SubstanceReferenceInformationTarget) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target" #f)
             ) #f #f))
(register-element! "SubstanceReferenceInformation.comment" (fhir-spec (string->symbol "SubstanceReferenceInformation.comment") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.comment" 'element))
(register-element! "SubstanceReferenceInformation.gene" (fhir-spec (string->symbol "SubstanceReferenceInformation.gene") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene" 'element))
(register-element! "SubstanceReferenceInformation.geneElement" (fhir-spec (string->symbol "SubstanceReferenceInformation.geneElement") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement" 'element))
(register-element! "SubstanceReferenceInformation.target" (fhir-spec (string->symbol "SubstanceReferenceInformation.target") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target" 'element))

(register-type! 'SubstanceReferenceInformationGene (fhir-spec 'SubstanceReferenceInformationGene "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene" 'type)
  #:schema (type-schema 'SubstanceReferenceInformationGene #f 'BackboneElement "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene"
             (list
    (schema-field 'geneSequenceOrigin 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene.geneSequenceOrigin" #f)
    (schema-field 'gene 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene.gene" #f)
    (schema-field 'source 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene.source" #f)
             ) #f #f))
(register-element! "SubstanceReferenceInformation.gene.geneSequenceOrigin" (fhir-spec (string->symbol "SubstanceReferenceInformation.gene.geneSequenceOrigin") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene.geneSequenceOrigin" 'element))
(register-element! "SubstanceReferenceInformation.gene.gene" (fhir-spec (string->symbol "SubstanceReferenceInformation.gene.gene") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene.gene" 'element))
(register-element! "SubstanceReferenceInformation.gene.source" (fhir-spec (string->symbol "SubstanceReferenceInformation.gene.source") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.gene.source" 'element))

(register-type! 'SubstanceReferenceInformationGeneElement (fhir-spec 'SubstanceReferenceInformationGeneElement "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement" 'type)
  #:schema (type-schema 'SubstanceReferenceInformationGeneElement #f 'BackboneElement "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement.type" #f)
    (schema-field 'element 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement.element" #f)
    (schema-field 'source 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement.source" #f)
             ) #f #f))
(register-element! "SubstanceReferenceInformation.geneElement.type" (fhir-spec (string->symbol "SubstanceReferenceInformation.geneElement.type") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement.type" 'element))
(register-element! "SubstanceReferenceInformation.geneElement.element" (fhir-spec (string->symbol "SubstanceReferenceInformation.geneElement.element") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement.element" 'element))
(register-element! "SubstanceReferenceInformation.geneElement.source" (fhir-spec (string->symbol "SubstanceReferenceInformation.geneElement.source") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.geneElement.source" 'element))

(register-type! 'SubstanceReferenceInformationTarget (fhir-spec 'SubstanceReferenceInformationTarget "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target" 'type)
  #:schema (type-schema 'SubstanceReferenceInformationTarget #f 'BackboneElement "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target"
             (list
    (schema-field 'target 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.target" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.type" #f)
    (schema-field 'interaction 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.interaction" #f)
    (schema-field 'organism 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.organism" #f)
    (schema-field 'organismType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.organismType" #f)
    (schema-field 'amountType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.amountType" #f)
    (schema-field 'source 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.source" #f)
    (schema-field 'amountQuantity 0 1 (vector 'type 'Quantity) 'amount "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.amount[x]" #f)
    (schema-field 'amountRange 0 1 (vector 'type 'Range) 'amount "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.amount[x]" #f)
    (schema-field 'amountString 0 1 (vector 'prim "string") 'amount "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.amount[x]" #f)
             ) #f #f))
(register-element! "SubstanceReferenceInformation.target.target" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.target") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.target" 'element))
(register-element! "SubstanceReferenceInformation.target.type" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.type") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.type" 'element))
(register-element! "SubstanceReferenceInformation.target.interaction" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.interaction") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.interaction" 'element))
(register-element! "SubstanceReferenceInformation.target.organism" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.organism") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.organism" 'element))
(register-element! "SubstanceReferenceInformation.target.organismType" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.organismType") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.organismType" 'element))
(register-element! "SubstanceReferenceInformation.target.amountType" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.amountType") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.amountType" 'element))
(register-element! "SubstanceReferenceInformation.target.source" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.source") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.source" 'element))
(register-element! "SubstanceReferenceInformation.target.amount[x]" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.amount[x]") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.amount[x]" 'element))
(register-element! "SubstanceReferenceInformation.target.amount[x]" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.amount[x]") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.amount[x]" 'element))
(register-element! "SubstanceReferenceInformation.target.amount[x]" (fhir-spec (string->symbol "SubstanceReferenceInformation.target.amount[x]") "https://hl7.org/fhir/R5/substancereferenceinformation.html#SubstanceReferenceInformation.target.amount[x]" 'element))

