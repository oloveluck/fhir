#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ImplementationGuide (fhir-spec 'ImplementationGuide "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide" 'type)
  #:schema (type-schema 'ImplementationGuide #f 'DomainResource "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide"
             (list
    (schema-field 'url 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.url" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.version" #f)
    (schema-field 'name 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.name" #f)
    (schema-field 'title 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.title" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.status" #f)
    (schema-field 'experimental 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.experimental" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.date" #f)
    (schema-field 'publisher 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.publisher" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactDetail) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.contact" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.description" #f)
    (schema-field 'useContext 0 '* (vector 'type 'UsageContext) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.useContext" #f)
    (schema-field 'jurisdiction 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.jurisdiction" #f)
    (schema-field 'copyright 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.copyright" #f)
    (schema-field 'packageId 1 1 (vector 'prim "id") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.packageId" #f)
    (schema-field 'license 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.license" #f)
    (schema-field 'fhirVersion 1 '* (vector 'prim "code") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.fhirVersion" #f)
    (schema-field 'dependsOn 0 '* (vector 'type 'ImplementationGuideDependsOn) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn" #f)
    (schema-field 'global 0 '* (vector 'type 'ImplementationGuideGlobal) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.global" #f)
    (schema-field 'definition 0 1 (vector 'type 'ImplementationGuideDefinition) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition" #f)
    (schema-field 'manifest 0 1 (vector 'type 'ImplementationGuideManifest) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest" #f)
             ) #f #f))
(register-element! "ImplementationGuide.url" (fhir-spec (string->symbol "ImplementationGuide.url") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.url" 'element))
(register-element! "ImplementationGuide.version" (fhir-spec (string->symbol "ImplementationGuide.version") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.version" 'element))
(register-element! "ImplementationGuide.name" (fhir-spec (string->symbol "ImplementationGuide.name") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.name" 'element))
(register-element! "ImplementationGuide.title" (fhir-spec (string->symbol "ImplementationGuide.title") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.title" 'element))
(register-element! "ImplementationGuide.status" (fhir-spec (string->symbol "ImplementationGuide.status") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.status" 'element))
(register-element! "ImplementationGuide.experimental" (fhir-spec (string->symbol "ImplementationGuide.experimental") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.experimental" 'element))
(register-element! "ImplementationGuide.date" (fhir-spec (string->symbol "ImplementationGuide.date") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.date" 'element))
(register-element! "ImplementationGuide.publisher" (fhir-spec (string->symbol "ImplementationGuide.publisher") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.publisher" 'element))
(register-element! "ImplementationGuide.contact" (fhir-spec (string->symbol "ImplementationGuide.contact") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.contact" 'element))
(register-element! "ImplementationGuide.description" (fhir-spec (string->symbol "ImplementationGuide.description") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.description" 'element))
(register-element! "ImplementationGuide.useContext" (fhir-spec (string->symbol "ImplementationGuide.useContext") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.useContext" 'element))
(register-element! "ImplementationGuide.jurisdiction" (fhir-spec (string->symbol "ImplementationGuide.jurisdiction") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.jurisdiction" 'element))
(register-element! "ImplementationGuide.copyright" (fhir-spec (string->symbol "ImplementationGuide.copyright") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.copyright" 'element))
(register-element! "ImplementationGuide.packageId" (fhir-spec (string->symbol "ImplementationGuide.packageId") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.packageId" 'element))
(register-element! "ImplementationGuide.license" (fhir-spec (string->symbol "ImplementationGuide.license") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.license" 'element))
(register-element! "ImplementationGuide.fhirVersion" (fhir-spec (string->symbol "ImplementationGuide.fhirVersion") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.fhirVersion" 'element))
(register-element! "ImplementationGuide.dependsOn" (fhir-spec (string->symbol "ImplementationGuide.dependsOn") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn" 'element))
(register-element! "ImplementationGuide.global" (fhir-spec (string->symbol "ImplementationGuide.global") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.global" 'element))
(register-element! "ImplementationGuide.definition" (fhir-spec (string->symbol "ImplementationGuide.definition") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition" 'element))
(register-element! "ImplementationGuide.manifest" (fhir-spec (string->symbol "ImplementationGuide.manifest") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest" 'element))

(register-type! 'ImplementationGuideDependsOn (fhir-spec 'ImplementationGuideDependsOn "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn" 'type)
  #:schema (type-schema 'ImplementationGuideDependsOn #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn"
             (list
    (schema-field 'uri 1 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn.uri" #f)
    (schema-field 'packageId 0 1 (vector 'prim "id") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn.packageId" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn.version" #f)
             ) #f #f))
(register-element! "ImplementationGuide.dependsOn.uri" (fhir-spec (string->symbol "ImplementationGuide.dependsOn.uri") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn.uri" 'element))
(register-element! "ImplementationGuide.dependsOn.packageId" (fhir-spec (string->symbol "ImplementationGuide.dependsOn.packageId") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn.packageId" 'element))
(register-element! "ImplementationGuide.dependsOn.version" (fhir-spec (string->symbol "ImplementationGuide.dependsOn.version") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.dependsOn.version" 'element))

(register-type! 'ImplementationGuideGlobal (fhir-spec 'ImplementationGuideGlobal "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.global" 'type)
  #:schema (type-schema 'ImplementationGuideGlobal #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.global"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.global.type" #f)
    (schema-field 'profile 1 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.global.profile" #f)
             ) #f #f))
(register-element! "ImplementationGuide.global.type" (fhir-spec (string->symbol "ImplementationGuide.global.type") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.global.type" 'element))
(register-element! "ImplementationGuide.global.profile" (fhir-spec (string->symbol "ImplementationGuide.global.profile") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.global.profile" 'element))

(register-type! 'ImplementationGuideDefinition (fhir-spec 'ImplementationGuideDefinition "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition" 'type)
  #:schema (type-schema 'ImplementationGuideDefinition #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition"
             (list
    (schema-field 'grouping 0 '* (vector 'type 'ImplementationGuideDefinitionGrouping) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.grouping" #f)
    (schema-field 'resource 1 '* (vector 'type 'ImplementationGuideDefinitionResource) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource" #f)
    (schema-field 'page 0 1 (vector 'type 'ImplementationGuideDefinitionPage) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page" #f)
    (schema-field 'parameter 0 '* (vector 'type 'ImplementationGuideDefinitionParameter) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.parameter" #f)
    (schema-field 'template 0 '* (vector 'type 'ImplementationGuideDefinitionTemplate) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template" #f)
             ) #f #f))
(register-element! "ImplementationGuide.definition.grouping" (fhir-spec (string->symbol "ImplementationGuide.definition.grouping") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.grouping" 'element))
(register-element! "ImplementationGuide.definition.resource" (fhir-spec (string->symbol "ImplementationGuide.definition.resource") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource" 'element))
(register-element! "ImplementationGuide.definition.page" (fhir-spec (string->symbol "ImplementationGuide.definition.page") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page" 'element))
(register-element! "ImplementationGuide.definition.parameter" (fhir-spec (string->symbol "ImplementationGuide.definition.parameter") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.parameter" 'element))
(register-element! "ImplementationGuide.definition.template" (fhir-spec (string->symbol "ImplementationGuide.definition.template") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template" 'element))

(register-type! 'ImplementationGuideDefinitionGrouping (fhir-spec 'ImplementationGuideDefinitionGrouping "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.grouping" 'type)
  #:schema (type-schema 'ImplementationGuideDefinitionGrouping #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.grouping"
             (list
    (schema-field 'name 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.grouping.name" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.grouping.description" #f)
             ) #f #f))
(register-element! "ImplementationGuide.definition.grouping.name" (fhir-spec (string->symbol "ImplementationGuide.definition.grouping.name") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.grouping.name" 'element))
(register-element! "ImplementationGuide.definition.grouping.description" (fhir-spec (string->symbol "ImplementationGuide.definition.grouping.description") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.grouping.description" 'element))

(register-type! 'ImplementationGuideDefinitionResource (fhir-spec 'ImplementationGuideDefinitionResource "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource" 'type)
  #:schema (type-schema 'ImplementationGuideDefinitionResource #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource"
             (list
    (schema-field 'reference 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.reference" #f)
    (schema-field 'fhirVersion 0 '* (vector 'prim "code") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.fhirVersion" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.name" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.description" #f)
    (schema-field 'groupingId 0 1 (vector 'prim "id") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.groupingId" #f)
    (schema-field 'exampleBoolean 0 1 (vector 'prim "boolean") 'example "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.example[x]" #f)
    (schema-field 'exampleCanonical 0 1 (vector 'prim "canonical") 'example "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.example[x]" #f)
             ) #f #f))
(register-element! "ImplementationGuide.definition.resource.reference" (fhir-spec (string->symbol "ImplementationGuide.definition.resource.reference") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.reference" 'element))
(register-element! "ImplementationGuide.definition.resource.fhirVersion" (fhir-spec (string->symbol "ImplementationGuide.definition.resource.fhirVersion") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.fhirVersion" 'element))
(register-element! "ImplementationGuide.definition.resource.name" (fhir-spec (string->symbol "ImplementationGuide.definition.resource.name") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.name" 'element))
(register-element! "ImplementationGuide.definition.resource.description" (fhir-spec (string->symbol "ImplementationGuide.definition.resource.description") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.description" 'element))
(register-element! "ImplementationGuide.definition.resource.groupingId" (fhir-spec (string->symbol "ImplementationGuide.definition.resource.groupingId") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.groupingId" 'element))
(register-element! "ImplementationGuide.definition.resource.example[x]" (fhir-spec (string->symbol "ImplementationGuide.definition.resource.example[x]") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.example[x]" 'element))
(register-element! "ImplementationGuide.definition.resource.example[x]" (fhir-spec (string->symbol "ImplementationGuide.definition.resource.example[x]") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.resource.example[x]" 'element))

(register-type! 'ImplementationGuideDefinitionPage (fhir-spec 'ImplementationGuideDefinitionPage "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page" 'type)
  #:schema (type-schema 'ImplementationGuideDefinitionPage #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page"
             (list
    (schema-field 'title 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.title" #f)
    (schema-field 'generation 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.generation" #f)
    (schema-field 'page 0 '* (vector 'type 'ImplementationGuideDefinitionPage) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.page" #f)
    (schema-field 'nameUrl 0 1 (vector 'prim "url") 'name "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.name[x]" #f)
    (schema-field 'nameReference 0 1 (vector 'type 'Reference) 'name "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.name[x]" #f)
             ) #f #f))
(register-element! "ImplementationGuide.definition.page.title" (fhir-spec (string->symbol "ImplementationGuide.definition.page.title") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.title" 'element))
(register-element! "ImplementationGuide.definition.page.generation" (fhir-spec (string->symbol "ImplementationGuide.definition.page.generation") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.generation" 'element))
(register-element! "ImplementationGuide.definition.page.page" (fhir-spec (string->symbol "ImplementationGuide.definition.page.page") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.page" 'element))
(register-element! "ImplementationGuide.definition.page.name[x]" (fhir-spec (string->symbol "ImplementationGuide.definition.page.name[x]") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.name[x]" 'element))
(register-element! "ImplementationGuide.definition.page.name[x]" (fhir-spec (string->symbol "ImplementationGuide.definition.page.name[x]") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.page.name[x]" 'element))

(register-type! 'ImplementationGuideDefinitionParameter (fhir-spec 'ImplementationGuideDefinitionParameter "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.parameter" 'type)
  #:schema (type-schema 'ImplementationGuideDefinitionParameter #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.parameter"
             (list
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.parameter.code" #f)
    (schema-field 'value 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.parameter.value" #f)
             ) #f #f))
(register-element! "ImplementationGuide.definition.parameter.code" (fhir-spec (string->symbol "ImplementationGuide.definition.parameter.code") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.parameter.code" 'element))
(register-element! "ImplementationGuide.definition.parameter.value" (fhir-spec (string->symbol "ImplementationGuide.definition.parameter.value") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.parameter.value" 'element))

(register-type! 'ImplementationGuideDefinitionTemplate (fhir-spec 'ImplementationGuideDefinitionTemplate "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template" 'type)
  #:schema (type-schema 'ImplementationGuideDefinitionTemplate #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template"
             (list
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template.code" #f)
    (schema-field 'source 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template.source" #f)
    (schema-field 'scope 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template.scope" #f)
             ) #f #f))
(register-element! "ImplementationGuide.definition.template.code" (fhir-spec (string->symbol "ImplementationGuide.definition.template.code") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template.code" 'element))
(register-element! "ImplementationGuide.definition.template.source" (fhir-spec (string->symbol "ImplementationGuide.definition.template.source") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template.source" 'element))
(register-element! "ImplementationGuide.definition.template.scope" (fhir-spec (string->symbol "ImplementationGuide.definition.template.scope") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.definition.template.scope" 'element))

(register-type! 'ImplementationGuideManifest (fhir-spec 'ImplementationGuideManifest "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest" 'type)
  #:schema (type-schema 'ImplementationGuideManifest #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest"
             (list
    (schema-field 'rendering 0 1 (vector 'prim "url") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.rendering" #f)
    (schema-field 'resource 1 '* (vector 'type 'ImplementationGuideManifestResource) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource" #f)
    (schema-field 'page 0 '* (vector 'type 'ImplementationGuideManifestPage) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page" #f)
    (schema-field 'image 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.image" #f)
    (schema-field 'other 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.other" #f)
             ) #f #f))
(register-element! "ImplementationGuide.manifest.rendering" (fhir-spec (string->symbol "ImplementationGuide.manifest.rendering") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.rendering" 'element))
(register-element! "ImplementationGuide.manifest.resource" (fhir-spec (string->symbol "ImplementationGuide.manifest.resource") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource" 'element))
(register-element! "ImplementationGuide.manifest.page" (fhir-spec (string->symbol "ImplementationGuide.manifest.page") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page" 'element))
(register-element! "ImplementationGuide.manifest.image" (fhir-spec (string->symbol "ImplementationGuide.manifest.image") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.image" 'element))
(register-element! "ImplementationGuide.manifest.other" (fhir-spec (string->symbol "ImplementationGuide.manifest.other") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.other" 'element))

(register-type! 'ImplementationGuideManifestResource (fhir-spec 'ImplementationGuideManifestResource "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource" 'type)
  #:schema (type-schema 'ImplementationGuideManifestResource #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource"
             (list
    (schema-field 'reference 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource.reference" #f)
    (schema-field 'relativePath 0 1 (vector 'prim "url") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource.relativePath" #f)
    (schema-field 'exampleBoolean 0 1 (vector 'prim "boolean") 'example "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource.example[x]" #f)
    (schema-field 'exampleCanonical 0 1 (vector 'prim "canonical") 'example "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource.example[x]" #f)
             ) #f #f))
(register-element! "ImplementationGuide.manifest.resource.reference" (fhir-spec (string->symbol "ImplementationGuide.manifest.resource.reference") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource.reference" 'element))
(register-element! "ImplementationGuide.manifest.resource.relativePath" (fhir-spec (string->symbol "ImplementationGuide.manifest.resource.relativePath") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource.relativePath" 'element))
(register-element! "ImplementationGuide.manifest.resource.example[x]" (fhir-spec (string->symbol "ImplementationGuide.manifest.resource.example[x]") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource.example[x]" 'element))
(register-element! "ImplementationGuide.manifest.resource.example[x]" (fhir-spec (string->symbol "ImplementationGuide.manifest.resource.example[x]") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.resource.example[x]" 'element))

(register-type! 'ImplementationGuideManifestPage (fhir-spec 'ImplementationGuideManifestPage "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page" 'type)
  #:schema (type-schema 'ImplementationGuideManifestPage #f 'BackboneElement "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page"
             (list
    (schema-field 'name 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page.name" #f)
    (schema-field 'title 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page.title" #f)
    (schema-field 'anchor 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page.anchor" #f)
             ) #f #f))
(register-element! "ImplementationGuide.manifest.page.name" (fhir-spec (string->symbol "ImplementationGuide.manifest.page.name") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page.name" 'element))
(register-element! "ImplementationGuide.manifest.page.title" (fhir-spec (string->symbol "ImplementationGuide.manifest.page.title") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page.title" 'element))
(register-element! "ImplementationGuide.manifest.page.anchor" (fhir-spec (string->symbol "ImplementationGuide.manifest.page.anchor") "https://hl7.org/fhir/R4/implementationguide.html#ImplementationGuide.manifest.page.anchor" 'element))

