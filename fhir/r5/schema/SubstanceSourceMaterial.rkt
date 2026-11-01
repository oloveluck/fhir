#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SubstanceSourceMaterial (fhir-spec 'SubstanceSourceMaterial "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial" 'type)
  #:schema (type-schema 'SubstanceSourceMaterial #f 'DomainResource "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial"
             (list
    (schema-field 'sourceMaterialClass 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.sourceMaterialClass" #f)
    (schema-field 'sourceMaterialType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.sourceMaterialType" #f)
    (schema-field 'sourceMaterialState 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.sourceMaterialState" #f)
    (schema-field 'organismId 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organismId" #f)
    (schema-field 'organismName 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organismName" #f)
    (schema-field 'parentSubstanceId 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.parentSubstanceId" #f)
    (schema-field 'parentSubstanceName 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.parentSubstanceName" #f)
    (schema-field 'countryOfOrigin 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.countryOfOrigin" #f)
    (schema-field 'geographicalLocation 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.geographicalLocation" #f)
    (schema-field 'developmentStage 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.developmentStage" #f)
    (schema-field 'fractionDescription 0 '* (vector 'type 'SubstanceSourceMaterialFractionDescription) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.fractionDescription" #f)
    (schema-field 'organism 0 1 (vector 'type 'SubstanceSourceMaterialOrganism) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism" #f)
    (schema-field 'partDescription 0 '* (vector 'type 'SubstanceSourceMaterialPartDescription) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.partDescription" #f)
             ) #f #f))
(register-element! "SubstanceSourceMaterial.sourceMaterialClass" (fhir-spec (string->symbol "SubstanceSourceMaterial.sourceMaterialClass") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.sourceMaterialClass" 'element))
(register-element! "SubstanceSourceMaterial.sourceMaterialType" (fhir-spec (string->symbol "SubstanceSourceMaterial.sourceMaterialType") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.sourceMaterialType" 'element))
(register-element! "SubstanceSourceMaterial.sourceMaterialState" (fhir-spec (string->symbol "SubstanceSourceMaterial.sourceMaterialState") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.sourceMaterialState" 'element))
(register-element! "SubstanceSourceMaterial.organismId" (fhir-spec (string->symbol "SubstanceSourceMaterial.organismId") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organismId" 'element))
(register-element! "SubstanceSourceMaterial.organismName" (fhir-spec (string->symbol "SubstanceSourceMaterial.organismName") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organismName" 'element))
(register-element! "SubstanceSourceMaterial.parentSubstanceId" (fhir-spec (string->symbol "SubstanceSourceMaterial.parentSubstanceId") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.parentSubstanceId" 'element))
(register-element! "SubstanceSourceMaterial.parentSubstanceName" (fhir-spec (string->symbol "SubstanceSourceMaterial.parentSubstanceName") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.parentSubstanceName" 'element))
(register-element! "SubstanceSourceMaterial.countryOfOrigin" (fhir-spec (string->symbol "SubstanceSourceMaterial.countryOfOrigin") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.countryOfOrigin" 'element))
(register-element! "SubstanceSourceMaterial.geographicalLocation" (fhir-spec (string->symbol "SubstanceSourceMaterial.geographicalLocation") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.geographicalLocation" 'element))
(register-element! "SubstanceSourceMaterial.developmentStage" (fhir-spec (string->symbol "SubstanceSourceMaterial.developmentStage") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.developmentStage" 'element))
(register-element! "SubstanceSourceMaterial.fractionDescription" (fhir-spec (string->symbol "SubstanceSourceMaterial.fractionDescription") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.fractionDescription" 'element))
(register-element! "SubstanceSourceMaterial.organism" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism" 'element))
(register-element! "SubstanceSourceMaterial.partDescription" (fhir-spec (string->symbol "SubstanceSourceMaterial.partDescription") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.partDescription" 'element))

(register-type! 'SubstanceSourceMaterialFractionDescription (fhir-spec 'SubstanceSourceMaterialFractionDescription "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.fractionDescription" 'type)
  #:schema (type-schema 'SubstanceSourceMaterialFractionDescription #f 'BackboneElement "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.fractionDescription"
             (list
    (schema-field 'fraction 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.fractionDescription.fraction" #f)
    (schema-field 'materialType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.fractionDescription.materialType" #f)
             ) #f #f))
(register-element! "SubstanceSourceMaterial.fractionDescription.fraction" (fhir-spec (string->symbol "SubstanceSourceMaterial.fractionDescription.fraction") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.fractionDescription.fraction" 'element))
(register-element! "SubstanceSourceMaterial.fractionDescription.materialType" (fhir-spec (string->symbol "SubstanceSourceMaterial.fractionDescription.materialType") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.fractionDescription.materialType" 'element))

(register-type! 'SubstanceSourceMaterialOrganism (fhir-spec 'SubstanceSourceMaterialOrganism "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism" 'type)
  #:schema (type-schema 'SubstanceSourceMaterialOrganism #f 'BackboneElement "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism"
             (list
    (schema-field 'family 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.family" #f)
    (schema-field 'genus 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.genus" #f)
    (schema-field 'species 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.species" #f)
    (schema-field 'intraspecificType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.intraspecificType" #f)
    (schema-field 'intraspecificDescription 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.intraspecificDescription" #f)
    (schema-field 'author 0 '* (vector 'type 'SubstanceSourceMaterialOrganismAuthor) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.author" #f)
    (schema-field 'hybrid 0 1 (vector 'type 'SubstanceSourceMaterialOrganismHybrid) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid" #f)
    (schema-field 'organismGeneral 0 1 (vector 'type 'SubstanceSourceMaterialOrganismOrganismGeneral) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral" #f)
             ) #f #f))
(register-element! "SubstanceSourceMaterial.organism.family" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.family") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.family" 'element))
(register-element! "SubstanceSourceMaterial.organism.genus" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.genus") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.genus" 'element))
(register-element! "SubstanceSourceMaterial.organism.species" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.species") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.species" 'element))
(register-element! "SubstanceSourceMaterial.organism.intraspecificType" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.intraspecificType") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.intraspecificType" 'element))
(register-element! "SubstanceSourceMaterial.organism.intraspecificDescription" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.intraspecificDescription") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.intraspecificDescription" 'element))
(register-element! "SubstanceSourceMaterial.organism.author" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.author") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.author" 'element))
(register-element! "SubstanceSourceMaterial.organism.hybrid" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.hybrid") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid" 'element))
(register-element! "SubstanceSourceMaterial.organism.organismGeneral" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.organismGeneral") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral" 'element))

(register-type! 'SubstanceSourceMaterialOrganismAuthor (fhir-spec 'SubstanceSourceMaterialOrganismAuthor "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.author" 'type)
  #:schema (type-schema 'SubstanceSourceMaterialOrganismAuthor #f 'BackboneElement "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.author"
             (list
    (schema-field 'authorType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.author.authorType" #f)
    (schema-field 'authorDescription 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.author.authorDescription" #f)
             ) #f #f))
(register-element! "SubstanceSourceMaterial.organism.author.authorType" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.author.authorType") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.author.authorType" 'element))
(register-element! "SubstanceSourceMaterial.organism.author.authorDescription" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.author.authorDescription") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.author.authorDescription" 'element))

(register-type! 'SubstanceSourceMaterialOrganismHybrid (fhir-spec 'SubstanceSourceMaterialOrganismHybrid "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid" 'type)
  #:schema (type-schema 'SubstanceSourceMaterialOrganismHybrid #f 'BackboneElement "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid"
             (list
    (schema-field 'maternalOrganismId 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.maternalOrganismId" #f)
    (schema-field 'maternalOrganismName 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.maternalOrganismName" #f)
    (schema-field 'paternalOrganismId 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.paternalOrganismId" #f)
    (schema-field 'paternalOrganismName 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.paternalOrganismName" #f)
    (schema-field 'hybridType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.hybridType" #f)
             ) #f #f))
(register-element! "SubstanceSourceMaterial.organism.hybrid.maternalOrganismId" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.hybrid.maternalOrganismId") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.maternalOrganismId" 'element))
(register-element! "SubstanceSourceMaterial.organism.hybrid.maternalOrganismName" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.hybrid.maternalOrganismName") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.maternalOrganismName" 'element))
(register-element! "SubstanceSourceMaterial.organism.hybrid.paternalOrganismId" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.hybrid.paternalOrganismId") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.paternalOrganismId" 'element))
(register-element! "SubstanceSourceMaterial.organism.hybrid.paternalOrganismName" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.hybrid.paternalOrganismName") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.paternalOrganismName" 'element))
(register-element! "SubstanceSourceMaterial.organism.hybrid.hybridType" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.hybrid.hybridType") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.hybrid.hybridType" 'element))

(register-type! 'SubstanceSourceMaterialOrganismOrganismGeneral (fhir-spec 'SubstanceSourceMaterialOrganismOrganismGeneral "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral" 'type)
  #:schema (type-schema 'SubstanceSourceMaterialOrganismOrganismGeneral #f 'BackboneElement "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral"
             (list
    (schema-field 'kingdom 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral.kingdom" #f)
    (schema-field 'phylum 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral.phylum" #f)
    (schema-field 'class 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral.class" #f)
    (schema-field 'order 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral.order" #f)
             ) #f #f))
(register-element! "SubstanceSourceMaterial.organism.organismGeneral.kingdom" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.organismGeneral.kingdom") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral.kingdom" 'element))
(register-element! "SubstanceSourceMaterial.organism.organismGeneral.phylum" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.organismGeneral.phylum") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral.phylum" 'element))
(register-element! "SubstanceSourceMaterial.organism.organismGeneral.class" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.organismGeneral.class") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral.class" 'element))
(register-element! "SubstanceSourceMaterial.organism.organismGeneral.order" (fhir-spec (string->symbol "SubstanceSourceMaterial.organism.organismGeneral.order") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.organism.organismGeneral.order" 'element))

(register-type! 'SubstanceSourceMaterialPartDescription (fhir-spec 'SubstanceSourceMaterialPartDescription "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.partDescription" 'type)
  #:schema (type-schema 'SubstanceSourceMaterialPartDescription #f 'BackboneElement "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.partDescription"
             (list
    (schema-field 'part 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.partDescription.part" #f)
    (schema-field 'partLocation 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.partDescription.partLocation" #f)
             ) #f #f))
(register-element! "SubstanceSourceMaterial.partDescription.part" (fhir-spec (string->symbol "SubstanceSourceMaterial.partDescription.part") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.partDescription.part" 'element))
(register-element! "SubstanceSourceMaterial.partDescription.partLocation" (fhir-spec (string->symbol "SubstanceSourceMaterial.partDescription.partLocation") "https://hl7.org/fhir/R5/substancesourcematerial.html#SubstanceSourceMaterial.partDescription.partLocation" 'element))

