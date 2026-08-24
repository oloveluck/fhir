#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DeviceDefinition (fhir-spec 'DeviceDefinition "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition" 'type)
  #:schema (type-schema 'DeviceDefinition #f 'DomainResource "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition"
             (list
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.description" #f)
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.identifier" #f)
    (schema-field 'udiDeviceIdentifier 0 '* (vector 'type 'DeviceDefinitionUdiDeviceIdentifier) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier" #f)
    (schema-field 'regulatoryIdentifier 0 '* (vector 'type 'DeviceDefinitionRegulatoryIdentifier) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier" #f)
    (schema-field 'partNumber 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.partNumber" #f)
    (schema-field 'manufacturer 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.manufacturer" #f)
    (schema-field 'deviceName 0 '* (vector 'type 'DeviceDefinitionDeviceName) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.deviceName" #f)
    (schema-field 'modelNumber 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.modelNumber" #f)
    (schema-field 'classification 0 '* (vector 'type 'DeviceDefinitionClassification) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.classification" #f)
    (schema-field 'conformsTo 0 '* (vector 'type 'DeviceDefinitionConformsTo) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo" #f)
    (schema-field 'hasPart 0 '* (vector 'type 'DeviceDefinitionHasPart) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.hasPart" #f)
    (schema-field 'packaging 0 '* (vector 'type 'DeviceDefinitionPackaging) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging" #f)
    (schema-field 'version 0 '* (vector 'type 'DeviceDefinitionVersion) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version" #f)
    (schema-field 'safety 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.safety" #f)
    (schema-field 'shelfLifeStorage 0 '* (vector 'type 'ProductShelfLife) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.shelfLifeStorage" #f)
    (schema-field 'languageCode 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.languageCode" #f)
    (schema-field 'property 0 '* (vector 'type 'DeviceDefinitionProperty) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property" #f)
    (schema-field 'owner 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.owner" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.contact" #f)
    (schema-field 'link 0 '* (vector 'type 'DeviceDefinitionLink) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.link" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.note" #f)
    (schema-field 'material 0 '* (vector 'type 'DeviceDefinitionMaterial) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material" #f)
    (schema-field 'productionIdentifierInUDI 0 '* (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.productionIdentifierInUDI" #f)
    (schema-field 'guideline 0 1 (vector 'type 'DeviceDefinitionGuideline) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline" #f)
    (schema-field 'correctiveAction 0 1 (vector 'type 'DeviceDefinitionCorrectiveAction) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction" #f)
    (schema-field 'chargeItem 0 '* (vector 'type 'DeviceDefinitionChargeItem) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem" #f)
             ) #f #f))
(register-element! "DeviceDefinition.description" (fhir-spec (string->symbol "DeviceDefinition.description") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.description" 'element))
(register-element! "DeviceDefinition.identifier" (fhir-spec (string->symbol "DeviceDefinition.identifier") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.identifier" 'element))
(register-element! "DeviceDefinition.udiDeviceIdentifier" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier" 'element))
(register-element! "DeviceDefinition.regulatoryIdentifier" (fhir-spec (string->symbol "DeviceDefinition.regulatoryIdentifier") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier" 'element))
(register-element! "DeviceDefinition.partNumber" (fhir-spec (string->symbol "DeviceDefinition.partNumber") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.partNumber" 'element))
(register-element! "DeviceDefinition.manufacturer" (fhir-spec (string->symbol "DeviceDefinition.manufacturer") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.manufacturer" 'element))
(register-element! "DeviceDefinition.deviceName" (fhir-spec (string->symbol "DeviceDefinition.deviceName") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.deviceName" 'element))
(register-element! "DeviceDefinition.modelNumber" (fhir-spec (string->symbol "DeviceDefinition.modelNumber") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.modelNumber" 'element))
(register-element! "DeviceDefinition.classification" (fhir-spec (string->symbol "DeviceDefinition.classification") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.classification" 'element))
(register-element! "DeviceDefinition.conformsTo" (fhir-spec (string->symbol "DeviceDefinition.conformsTo") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo" 'element))
(register-element! "DeviceDefinition.hasPart" (fhir-spec (string->symbol "DeviceDefinition.hasPart") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.hasPart" 'element))
(register-element! "DeviceDefinition.packaging" (fhir-spec (string->symbol "DeviceDefinition.packaging") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging" 'element))
(register-element! "DeviceDefinition.version" (fhir-spec (string->symbol "DeviceDefinition.version") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version" 'element))
(register-element! "DeviceDefinition.safety" (fhir-spec (string->symbol "DeviceDefinition.safety") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.safety" 'element))
(register-element! "DeviceDefinition.shelfLifeStorage" (fhir-spec (string->symbol "DeviceDefinition.shelfLifeStorage") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.shelfLifeStorage" 'element))
(register-element! "DeviceDefinition.languageCode" (fhir-spec (string->symbol "DeviceDefinition.languageCode") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.languageCode" 'element))
(register-element! "DeviceDefinition.property" (fhir-spec (string->symbol "DeviceDefinition.property") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property" 'element))
(register-element! "DeviceDefinition.owner" (fhir-spec (string->symbol "DeviceDefinition.owner") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.owner" 'element))
(register-element! "DeviceDefinition.contact" (fhir-spec (string->symbol "DeviceDefinition.contact") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.contact" 'element))
(register-element! "DeviceDefinition.link" (fhir-spec (string->symbol "DeviceDefinition.link") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.link" 'element))
(register-element! "DeviceDefinition.note" (fhir-spec (string->symbol "DeviceDefinition.note") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.note" 'element))
(register-element! "DeviceDefinition.material" (fhir-spec (string->symbol "DeviceDefinition.material") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material" 'element))
(register-element! "DeviceDefinition.productionIdentifierInUDI" (fhir-spec (string->symbol "DeviceDefinition.productionIdentifierInUDI") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.productionIdentifierInUDI" 'element))
(register-element! "DeviceDefinition.guideline" (fhir-spec (string->symbol "DeviceDefinition.guideline") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline" 'element))
(register-element! "DeviceDefinition.correctiveAction" (fhir-spec (string->symbol "DeviceDefinition.correctiveAction") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction" 'element))
(register-element! "DeviceDefinition.chargeItem" (fhir-spec (string->symbol "DeviceDefinition.chargeItem") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem" 'element))

(register-type! 'DeviceDefinitionUdiDeviceIdentifier (fhir-spec 'DeviceDefinitionUdiDeviceIdentifier "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier" 'type)
  #:schema (type-schema 'DeviceDefinitionUdiDeviceIdentifier #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier"
             (list
    (schema-field 'deviceIdentifier 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.deviceIdentifier" #f)
    (schema-field 'issuer 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.issuer" #f)
    (schema-field 'jurisdiction 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.jurisdiction" #f)
    (schema-field 'marketDistribution 0 '* (vector 'type 'DeviceDefinitionUdiDeviceIdentifierMarketDistribution) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.marketDistribution" #f)
             ) #f #f))
(register-element! "DeviceDefinition.udiDeviceIdentifier.deviceIdentifier" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.deviceIdentifier") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.deviceIdentifier" 'element))
(register-element! "DeviceDefinition.udiDeviceIdentifier.issuer" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.issuer") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.issuer" 'element))
(register-element! "DeviceDefinition.udiDeviceIdentifier.jurisdiction" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.jurisdiction") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.jurisdiction" 'element))
(register-element! "DeviceDefinition.udiDeviceIdentifier.marketDistribution" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.marketDistribution") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.marketDistribution" 'element))

(register-type! 'DeviceDefinitionUdiDeviceIdentifierMarketDistribution (fhir-spec 'DeviceDefinitionUdiDeviceIdentifierMarketDistribution "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.marketDistribution" 'type)
  #:schema (type-schema 'DeviceDefinitionUdiDeviceIdentifierMarketDistribution #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.marketDistribution"
             (list
    (schema-field 'marketPeriod 1 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.marketDistribution.marketPeriod" #f)
    (schema-field 'subJurisdiction 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.marketDistribution.subJurisdiction" #f)
             ) #f #f))
(register-element! "DeviceDefinition.udiDeviceIdentifier.marketDistribution.marketPeriod" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.marketDistribution.marketPeriod") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.marketDistribution.marketPeriod" 'element))
(register-element! "DeviceDefinition.udiDeviceIdentifier.marketDistribution.subJurisdiction" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.marketDistribution.subJurisdiction") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.marketDistribution.subJurisdiction" 'element))

(register-type! 'DeviceDefinitionRegulatoryIdentifier (fhir-spec 'DeviceDefinitionRegulatoryIdentifier "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier" 'type)
  #:schema (type-schema 'DeviceDefinitionRegulatoryIdentifier #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier.type" #f)
    (schema-field 'deviceIdentifier 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier.deviceIdentifier" #f)
    (schema-field 'issuer 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier.issuer" #f)
    (schema-field 'jurisdiction 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier.jurisdiction" #f)
             ) #f #f))
(register-element! "DeviceDefinition.regulatoryIdentifier.type" (fhir-spec (string->symbol "DeviceDefinition.regulatoryIdentifier.type") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier.type" 'element))
(register-element! "DeviceDefinition.regulatoryIdentifier.deviceIdentifier" (fhir-spec (string->symbol "DeviceDefinition.regulatoryIdentifier.deviceIdentifier") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier.deviceIdentifier" 'element))
(register-element! "DeviceDefinition.regulatoryIdentifier.issuer" (fhir-spec (string->symbol "DeviceDefinition.regulatoryIdentifier.issuer") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier.issuer" 'element))
(register-element! "DeviceDefinition.regulatoryIdentifier.jurisdiction" (fhir-spec (string->symbol "DeviceDefinition.regulatoryIdentifier.jurisdiction") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.regulatoryIdentifier.jurisdiction" 'element))

(register-type! 'DeviceDefinitionDeviceName (fhir-spec 'DeviceDefinitionDeviceName "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.deviceName" 'type)
  #:schema (type-schema 'DeviceDefinitionDeviceName #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.deviceName"
             (list
    (schema-field 'name 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.deviceName.name" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.deviceName.type" #f)
             ) #f #f))
(register-element! "DeviceDefinition.deviceName.name" (fhir-spec (string->symbol "DeviceDefinition.deviceName.name") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.deviceName.name" 'element))
(register-element! "DeviceDefinition.deviceName.type" (fhir-spec (string->symbol "DeviceDefinition.deviceName.type") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.deviceName.type" 'element))

(register-type! 'DeviceDefinitionClassification (fhir-spec 'DeviceDefinitionClassification "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.classification" 'type)
  #:schema (type-schema 'DeviceDefinitionClassification #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.classification"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.classification.type" #f)
    (schema-field 'justification 0 '* (vector 'type 'RelatedArtifact) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.classification.justification" #f)
             ) #f #f))
(register-element! "DeviceDefinition.classification.type" (fhir-spec (string->symbol "DeviceDefinition.classification.type") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.classification.type" 'element))
(register-element! "DeviceDefinition.classification.justification" (fhir-spec (string->symbol "DeviceDefinition.classification.justification") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.classification.justification" 'element))

(register-type! 'DeviceDefinitionConformsTo (fhir-spec 'DeviceDefinitionConformsTo "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo" 'type)
  #:schema (type-schema 'DeviceDefinitionConformsTo #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo"
             (list
    (schema-field 'category 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo.category" #f)
    (schema-field 'specification 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo.specification" #f)
    (schema-field 'version 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo.version" #f)
    (schema-field 'source 0 '* (vector 'type 'RelatedArtifact) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo.source" #f)
             ) #f #f))
(register-element! "DeviceDefinition.conformsTo.category" (fhir-spec (string->symbol "DeviceDefinition.conformsTo.category") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo.category" 'element))
(register-element! "DeviceDefinition.conformsTo.specification" (fhir-spec (string->symbol "DeviceDefinition.conformsTo.specification") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo.specification" 'element))
(register-element! "DeviceDefinition.conformsTo.version" (fhir-spec (string->symbol "DeviceDefinition.conformsTo.version") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo.version" 'element))
(register-element! "DeviceDefinition.conformsTo.source" (fhir-spec (string->symbol "DeviceDefinition.conformsTo.source") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.conformsTo.source" 'element))

(register-type! 'DeviceDefinitionHasPart (fhir-spec 'DeviceDefinitionHasPart "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.hasPart" 'type)
  #:schema (type-schema 'DeviceDefinitionHasPart #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.hasPart"
             (list
    (schema-field 'reference 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.hasPart.reference" #f)
    (schema-field 'count 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.hasPart.count" #f)
             ) #f #f))
(register-element! "DeviceDefinition.hasPart.reference" (fhir-spec (string->symbol "DeviceDefinition.hasPart.reference") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.hasPart.reference" 'element))
(register-element! "DeviceDefinition.hasPart.count" (fhir-spec (string->symbol "DeviceDefinition.hasPart.count") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.hasPart.count" 'element))

(register-type! 'DeviceDefinitionPackaging (fhir-spec 'DeviceDefinitionPackaging "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging" 'type)
  #:schema (type-schema 'DeviceDefinitionPackaging #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.identifier" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.type" #f)
    (schema-field 'count 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.count" #f)
    (schema-field 'distributor 0 '* (vector 'type 'DeviceDefinitionPackagingDistributor) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.distributor" #f)
    (schema-field 'udiDeviceIdentifier 0 '* (vector 'type 'DeviceDefinitionUdiDeviceIdentifier) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.udiDeviceIdentifier" #f)
    (schema-field 'packaging 0 '* (vector 'type 'DeviceDefinitionPackaging) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.packaging" #f)
             ) #f #f))
(register-element! "DeviceDefinition.packaging.identifier" (fhir-spec (string->symbol "DeviceDefinition.packaging.identifier") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.identifier" 'element))
(register-element! "DeviceDefinition.packaging.type" (fhir-spec (string->symbol "DeviceDefinition.packaging.type") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.type" 'element))
(register-element! "DeviceDefinition.packaging.count" (fhir-spec (string->symbol "DeviceDefinition.packaging.count") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.count" 'element))
(register-element! "DeviceDefinition.packaging.distributor" (fhir-spec (string->symbol "DeviceDefinition.packaging.distributor") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.distributor" 'element))
(register-element! "DeviceDefinition.packaging.udiDeviceIdentifier" (fhir-spec (string->symbol "DeviceDefinition.packaging.udiDeviceIdentifier") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.udiDeviceIdentifier" 'element))
(register-element! "DeviceDefinition.packaging.packaging" (fhir-spec (string->symbol "DeviceDefinition.packaging.packaging") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.packaging" 'element))

(register-type! 'DeviceDefinitionPackagingDistributor (fhir-spec 'DeviceDefinitionPackagingDistributor "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.distributor" 'type)
  #:schema (type-schema 'DeviceDefinitionPackagingDistributor #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.distributor"
             (list
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.distributor.name" #f)
    (schema-field 'organizationReference 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.distributor.organizationReference" #f)
             ) #f #f))
(register-element! "DeviceDefinition.packaging.distributor.name" (fhir-spec (string->symbol "DeviceDefinition.packaging.distributor.name") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.distributor.name" 'element))
(register-element! "DeviceDefinition.packaging.distributor.organizationReference" (fhir-spec (string->symbol "DeviceDefinition.packaging.distributor.organizationReference") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.packaging.distributor.organizationReference" 'element))

(register-type! 'DeviceDefinitionVersion (fhir-spec 'DeviceDefinitionVersion "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version" 'type)
  #:schema (type-schema 'DeviceDefinitionVersion #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version.type" #f)
    (schema-field 'component 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version.component" #f)
    (schema-field 'value 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version.value" #f)
             ) #f #f))
(register-element! "DeviceDefinition.version.type" (fhir-spec (string->symbol "DeviceDefinition.version.type") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version.type" 'element))
(register-element! "DeviceDefinition.version.component" (fhir-spec (string->symbol "DeviceDefinition.version.component") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version.component" 'element))
(register-element! "DeviceDefinition.version.value" (fhir-spec (string->symbol "DeviceDefinition.version.value") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.version.value" 'element))

(register-type! 'DeviceDefinitionProperty (fhir-spec 'DeviceDefinitionProperty "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property" 'type)
  #:schema (type-schema 'DeviceDefinitionProperty #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.type" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" #f)
    (schema-field 'valueString 0 1 (vector 'prim "string") 'value "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" #f)
    (schema-field 'valueBoolean 0 1 (vector 'prim "boolean") 'value "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" #f)
    (schema-field 'valueInteger 0 1 (vector 'prim "integer") 'value "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" #f)
    (schema-field 'valueRange 0 1 (vector 'type 'Range) 'value "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" #f)
    (schema-field 'valueAttachment 0 1 (vector 'type 'Attachment) 'value "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" #f)
             ) #f #f))
(register-element! "DeviceDefinition.property.type" (fhir-spec (string->symbol "DeviceDefinition.property.type") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.type" 'element))
(register-element! "DeviceDefinition.property.value[x]" (fhir-spec (string->symbol "DeviceDefinition.property.value[x]") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" 'element))
(register-element! "DeviceDefinition.property.value[x]" (fhir-spec (string->symbol "DeviceDefinition.property.value[x]") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" 'element))
(register-element! "DeviceDefinition.property.value[x]" (fhir-spec (string->symbol "DeviceDefinition.property.value[x]") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" 'element))
(register-element! "DeviceDefinition.property.value[x]" (fhir-spec (string->symbol "DeviceDefinition.property.value[x]") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" 'element))
(register-element! "DeviceDefinition.property.value[x]" (fhir-spec (string->symbol "DeviceDefinition.property.value[x]") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" 'element))
(register-element! "DeviceDefinition.property.value[x]" (fhir-spec (string->symbol "DeviceDefinition.property.value[x]") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" 'element))
(register-element! "DeviceDefinition.property.value[x]" (fhir-spec (string->symbol "DeviceDefinition.property.value[x]") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.property.value[x]" 'element))

(register-type! 'DeviceDefinitionLink (fhir-spec 'DeviceDefinitionLink "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.link" 'type)
  #:schema (type-schema 'DeviceDefinitionLink #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.link"
             (list
    (schema-field 'relation 1 1 (vector 'type 'Coding) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.link.relation" #f)
    (schema-field 'relatedDevice 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.link.relatedDevice" #f)
             ) #f #f))
(register-element! "DeviceDefinition.link.relation" (fhir-spec (string->symbol "DeviceDefinition.link.relation") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.link.relation" 'element))
(register-element! "DeviceDefinition.link.relatedDevice" (fhir-spec (string->symbol "DeviceDefinition.link.relatedDevice") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.link.relatedDevice" 'element))

(register-type! 'DeviceDefinitionMaterial (fhir-spec 'DeviceDefinitionMaterial "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material" 'type)
  #:schema (type-schema 'DeviceDefinitionMaterial #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material"
             (list
    (schema-field 'substance 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material.substance" #f)
    (schema-field 'alternate 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material.alternate" #f)
    (schema-field 'allergenicIndicator 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material.allergenicIndicator" #f)
             ) #f #f))
(register-element! "DeviceDefinition.material.substance" (fhir-spec (string->symbol "DeviceDefinition.material.substance") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material.substance" 'element))
(register-element! "DeviceDefinition.material.alternate" (fhir-spec (string->symbol "DeviceDefinition.material.alternate") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material.alternate" 'element))
(register-element! "DeviceDefinition.material.allergenicIndicator" (fhir-spec (string->symbol "DeviceDefinition.material.allergenicIndicator") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.material.allergenicIndicator" 'element))

(register-type! 'DeviceDefinitionGuideline (fhir-spec 'DeviceDefinitionGuideline "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline" 'type)
  #:schema (type-schema 'DeviceDefinitionGuideline #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline"
             (list
    (schema-field 'useContext 0 '* (vector 'type 'UsageContext) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.useContext" #f)
    (schema-field 'usageInstruction 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.usageInstruction" #f)
    (schema-field 'relatedArtifact 0 '* (vector 'type 'RelatedArtifact) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.relatedArtifact" #f)
    (schema-field 'indication 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.indication" #f)
    (schema-field 'contraindication 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.contraindication" #f)
    (schema-field 'warning 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.warning" #f)
    (schema-field 'intendedUse 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.intendedUse" #f)
             ) #f #f))
(register-element! "DeviceDefinition.guideline.useContext" (fhir-spec (string->symbol "DeviceDefinition.guideline.useContext") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.useContext" 'element))
(register-element! "DeviceDefinition.guideline.usageInstruction" (fhir-spec (string->symbol "DeviceDefinition.guideline.usageInstruction") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.usageInstruction" 'element))
(register-element! "DeviceDefinition.guideline.relatedArtifact" (fhir-spec (string->symbol "DeviceDefinition.guideline.relatedArtifact") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.relatedArtifact" 'element))
(register-element! "DeviceDefinition.guideline.indication" (fhir-spec (string->symbol "DeviceDefinition.guideline.indication") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.indication" 'element))
(register-element! "DeviceDefinition.guideline.contraindication" (fhir-spec (string->symbol "DeviceDefinition.guideline.contraindication") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.contraindication" 'element))
(register-element! "DeviceDefinition.guideline.warning" (fhir-spec (string->symbol "DeviceDefinition.guideline.warning") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.warning" 'element))
(register-element! "DeviceDefinition.guideline.intendedUse" (fhir-spec (string->symbol "DeviceDefinition.guideline.intendedUse") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.guideline.intendedUse" 'element))

(register-type! 'DeviceDefinitionCorrectiveAction (fhir-spec 'DeviceDefinitionCorrectiveAction "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction" 'type)
  #:schema (type-schema 'DeviceDefinitionCorrectiveAction #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction"
             (list
    (schema-field 'recall 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction.recall" #f)
    (schema-field 'scope 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction.scope" #f)
    (schema-field 'period 1 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction.period" #f)
             ) #f #f))
(register-element! "DeviceDefinition.correctiveAction.recall" (fhir-spec (string->symbol "DeviceDefinition.correctiveAction.recall") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction.recall" 'element))
(register-element! "DeviceDefinition.correctiveAction.scope" (fhir-spec (string->symbol "DeviceDefinition.correctiveAction.scope") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction.scope" 'element))
(register-element! "DeviceDefinition.correctiveAction.period" (fhir-spec (string->symbol "DeviceDefinition.correctiveAction.period") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.correctiveAction.period" 'element))

(register-type! 'DeviceDefinitionChargeItem (fhir-spec 'DeviceDefinitionChargeItem "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem" 'type)
  #:schema (type-schema 'DeviceDefinitionChargeItem #f 'BackboneElement "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem"
             (list
    (schema-field 'chargeItemCode 1 1 (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem.chargeItemCode" #f)
    (schema-field 'count 1 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem.count" #f)
    (schema-field 'effectivePeriod 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem.effectivePeriod" #f)
    (schema-field 'useContext 0 '* (vector 'type 'UsageContext) #f "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem.useContext" #f)
             ) #f #f))
(register-element! "DeviceDefinition.chargeItem.chargeItemCode" (fhir-spec (string->symbol "DeviceDefinition.chargeItem.chargeItemCode") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem.chargeItemCode" 'element))
(register-element! "DeviceDefinition.chargeItem.count" (fhir-spec (string->symbol "DeviceDefinition.chargeItem.count") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem.count" 'element))
(register-element! "DeviceDefinition.chargeItem.effectivePeriod" (fhir-spec (string->symbol "DeviceDefinition.chargeItem.effectivePeriod") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem.effectivePeriod" 'element))
(register-element! "DeviceDefinition.chargeItem.useContext" (fhir-spec (string->symbol "DeviceDefinition.chargeItem.useContext") "https://hl7.org/fhir/R5/devicedefinition.html#DeviceDefinition.chargeItem.useContext" 'element))

