#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DeviceDefinition (fhir-spec 'DeviceDefinition "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition" 'type)
  #:schema (type-schema 'DeviceDefinition #f 'DomainResource "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.identifier" #f)
    (schema-field 'udiDeviceIdentifier 0 '* (vector 'type 'DeviceDefinitionUdiDeviceIdentifier) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier" #f)
    (schema-field 'deviceName 0 '* (vector 'type 'DeviceDefinitionDeviceName) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.deviceName" #f)
    (schema-field 'modelNumber 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.modelNumber" #f)
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.type" #f)
    (schema-field 'specialization 0 '* (vector 'type 'DeviceDefinitionSpecialization) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.specialization" #f)
    (schema-field 'version 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.version" #f)
    (schema-field 'safety 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.safety" #f)
    (schema-field 'shelfLifeStorage 0 '* (vector 'type 'ProductShelfLife) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.shelfLifeStorage" #f)
    (schema-field 'physicalCharacteristics 0 1 (vector 'type 'ProdCharacteristic) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.physicalCharacteristics" #f)
    (schema-field 'languageCode 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.languageCode" #f)
    (schema-field 'capability 0 '* (vector 'type 'DeviceDefinitionCapability) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.capability" #f)
    (schema-field 'property 0 '* (vector 'type 'DeviceDefinitionProperty) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property" #f)
    (schema-field 'owner 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.owner" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.contact" #f)
    (schema-field 'url 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.url" #f)
    (schema-field 'onlineInformation 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.onlineInformation" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.note" #f)
    (schema-field 'quantity 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.quantity" #f)
    (schema-field 'parentDevice 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.parentDevice" #f)
    (schema-field 'material 0 '* (vector 'type 'DeviceDefinitionMaterial) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material" #f)
    (schema-field 'manufacturerString 0 1 (vector 'prim "string") 'manufacturer "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.manufacturer[x]" #f)
    (schema-field 'manufacturerReference 0 1 (vector 'type 'Reference) 'manufacturer "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.manufacturer[x]" #f)
             ) #f #f))
(register-element! "DeviceDefinition.identifier" (fhir-spec (string->symbol "DeviceDefinition.identifier") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.identifier" 'element))
(register-element! "DeviceDefinition.udiDeviceIdentifier" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier" 'element))
(register-element! "DeviceDefinition.deviceName" (fhir-spec (string->symbol "DeviceDefinition.deviceName") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.deviceName" 'element))
(register-element! "DeviceDefinition.modelNumber" (fhir-spec (string->symbol "DeviceDefinition.modelNumber") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.modelNumber" 'element))
(register-element! "DeviceDefinition.type" (fhir-spec (string->symbol "DeviceDefinition.type") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.type" 'element))
(register-element! "DeviceDefinition.specialization" (fhir-spec (string->symbol "DeviceDefinition.specialization") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.specialization" 'element))
(register-element! "DeviceDefinition.version" (fhir-spec (string->symbol "DeviceDefinition.version") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.version" 'element))
(register-element! "DeviceDefinition.safety" (fhir-spec (string->symbol "DeviceDefinition.safety") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.safety" 'element))
(register-element! "DeviceDefinition.shelfLifeStorage" (fhir-spec (string->symbol "DeviceDefinition.shelfLifeStorage") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.shelfLifeStorage" 'element))
(register-element! "DeviceDefinition.physicalCharacteristics" (fhir-spec (string->symbol "DeviceDefinition.physicalCharacteristics") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.physicalCharacteristics" 'element))
(register-element! "DeviceDefinition.languageCode" (fhir-spec (string->symbol "DeviceDefinition.languageCode") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.languageCode" 'element))
(register-element! "DeviceDefinition.capability" (fhir-spec (string->symbol "DeviceDefinition.capability") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.capability" 'element))
(register-element! "DeviceDefinition.property" (fhir-spec (string->symbol "DeviceDefinition.property") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property" 'element))
(register-element! "DeviceDefinition.owner" (fhir-spec (string->symbol "DeviceDefinition.owner") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.owner" 'element))
(register-element! "DeviceDefinition.contact" (fhir-spec (string->symbol "DeviceDefinition.contact") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.contact" 'element))
(register-element! "DeviceDefinition.url" (fhir-spec (string->symbol "DeviceDefinition.url") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.url" 'element))
(register-element! "DeviceDefinition.onlineInformation" (fhir-spec (string->symbol "DeviceDefinition.onlineInformation") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.onlineInformation" 'element))
(register-element! "DeviceDefinition.note" (fhir-spec (string->symbol "DeviceDefinition.note") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.note" 'element))
(register-element! "DeviceDefinition.quantity" (fhir-spec (string->symbol "DeviceDefinition.quantity") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.quantity" 'element))
(register-element! "DeviceDefinition.parentDevice" (fhir-spec (string->symbol "DeviceDefinition.parentDevice") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.parentDevice" 'element))
(register-element! "DeviceDefinition.material" (fhir-spec (string->symbol "DeviceDefinition.material") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material" 'element))
(register-element! "DeviceDefinition.manufacturer[x]" (fhir-spec (string->symbol "DeviceDefinition.manufacturer[x]") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.manufacturer[x]" 'element))
(register-element! "DeviceDefinition.manufacturer[x]" (fhir-spec (string->symbol "DeviceDefinition.manufacturer[x]") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.manufacturer[x]" 'element))

(register-type! 'DeviceDefinitionUdiDeviceIdentifier (fhir-spec 'DeviceDefinitionUdiDeviceIdentifier "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier" 'type)
  #:schema (type-schema 'DeviceDefinitionUdiDeviceIdentifier #f 'BackboneElement "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier"
             (list
    (schema-field 'deviceIdentifier 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.deviceIdentifier" #f)
    (schema-field 'issuer 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.issuer" #f)
    (schema-field 'jurisdiction 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.jurisdiction" #f)
             ) #f #f))
(register-element! "DeviceDefinition.udiDeviceIdentifier.deviceIdentifier" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.deviceIdentifier") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.deviceIdentifier" 'element))
(register-element! "DeviceDefinition.udiDeviceIdentifier.issuer" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.issuer") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.issuer" 'element))
(register-element! "DeviceDefinition.udiDeviceIdentifier.jurisdiction" (fhir-spec (string->symbol "DeviceDefinition.udiDeviceIdentifier.jurisdiction") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.udiDeviceIdentifier.jurisdiction" 'element))

(register-type! 'DeviceDefinitionDeviceName (fhir-spec 'DeviceDefinitionDeviceName "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.deviceName" 'type)
  #:schema (type-schema 'DeviceDefinitionDeviceName #f 'BackboneElement "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.deviceName"
             (list
    (schema-field 'name 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.deviceName.name" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.deviceName.type" #f)
             ) #f #f))
(register-element! "DeviceDefinition.deviceName.name" (fhir-spec (string->symbol "DeviceDefinition.deviceName.name") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.deviceName.name" 'element))
(register-element! "DeviceDefinition.deviceName.type" (fhir-spec (string->symbol "DeviceDefinition.deviceName.type") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.deviceName.type" 'element))

(register-type! 'DeviceDefinitionSpecialization (fhir-spec 'DeviceDefinitionSpecialization "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.specialization" 'type)
  #:schema (type-schema 'DeviceDefinitionSpecialization #f 'BackboneElement "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.specialization"
             (list
    (schema-field 'systemType 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.specialization.systemType" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.specialization.version" #f)
             ) #f #f))
(register-element! "DeviceDefinition.specialization.systemType" (fhir-spec (string->symbol "DeviceDefinition.specialization.systemType") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.specialization.systemType" 'element))
(register-element! "DeviceDefinition.specialization.version" (fhir-spec (string->symbol "DeviceDefinition.specialization.version") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.specialization.version" 'element))

(register-type! 'DeviceDefinitionCapability (fhir-spec 'DeviceDefinitionCapability "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.capability" 'type)
  #:schema (type-schema 'DeviceDefinitionCapability #f 'BackboneElement "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.capability"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.capability.type" #f)
    (schema-field 'description 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.capability.description" #f)
             ) #f #f))
(register-element! "DeviceDefinition.capability.type" (fhir-spec (string->symbol "DeviceDefinition.capability.type") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.capability.type" 'element))
(register-element! "DeviceDefinition.capability.description" (fhir-spec (string->symbol "DeviceDefinition.capability.description") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.capability.description" 'element))

(register-type! 'DeviceDefinitionProperty (fhir-spec 'DeviceDefinitionProperty "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property" 'type)
  #:schema (type-schema 'DeviceDefinitionProperty #f 'BackboneElement "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property"
             (list
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property.type" #f)
    (schema-field 'valueQuantity 0 '* (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property.valueQuantity" #f)
    (schema-field 'valueCode 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property.valueCode" #f)
             ) #f #f))
(register-element! "DeviceDefinition.property.type" (fhir-spec (string->symbol "DeviceDefinition.property.type") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property.type" 'element))
(register-element! "DeviceDefinition.property.valueQuantity" (fhir-spec (string->symbol "DeviceDefinition.property.valueQuantity") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property.valueQuantity" 'element))
(register-element! "DeviceDefinition.property.valueCode" (fhir-spec (string->symbol "DeviceDefinition.property.valueCode") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.property.valueCode" 'element))

(register-type! 'DeviceDefinitionMaterial (fhir-spec 'DeviceDefinitionMaterial "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material" 'type)
  #:schema (type-schema 'DeviceDefinitionMaterial #f 'BackboneElement "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material"
             (list
    (schema-field 'substance 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material.substance" #f)
    (schema-field 'alternate 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material.alternate" #f)
    (schema-field 'allergenicIndicator 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material.allergenicIndicator" #f)
             ) #f #f))
(register-element! "DeviceDefinition.material.substance" (fhir-spec (string->symbol "DeviceDefinition.material.substance") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material.substance" 'element))
(register-element! "DeviceDefinition.material.alternate" (fhir-spec (string->symbol "DeviceDefinition.material.alternate") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material.alternate" 'element))
(register-element! "DeviceDefinition.material.allergenicIndicator" (fhir-spec (string->symbol "DeviceDefinition.material.allergenicIndicator") "https://hl7.org/fhir/R4/devicedefinition.html#DeviceDefinition.material.allergenicIndicator" 'element))

