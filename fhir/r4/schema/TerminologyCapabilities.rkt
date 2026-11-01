#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'TerminologyCapabilities (fhir-spec 'TerminologyCapabilities "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities" 'type)
  #:schema (type-schema 'TerminologyCapabilities #f 'DomainResource "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities"
             (list
    (schema-field 'url 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.url" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.version" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.name" #f)
    (schema-field 'title 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.title" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.status" #f)
    (schema-field 'experimental 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.experimental" #f)
    (schema-field 'date 1 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.date" #f)
    (schema-field 'publisher 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.publisher" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactDetail) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.contact" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.description" #f)
    (schema-field 'useContext 0 '* (vector 'type 'UsageContext) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.useContext" #f)
    (schema-field 'jurisdiction 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.jurisdiction" #f)
    (schema-field 'purpose 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.purpose" #f)
    (schema-field 'copyright 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.copyright" #f)
    (schema-field 'kind 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.kind" #f)
    (schema-field 'software 0 1 (vector 'type 'TerminologyCapabilitiesSoftware) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.software" #f)
    (schema-field 'implementation 0 1 (vector 'type 'TerminologyCapabilitiesImplementation) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.implementation" #f)
    (schema-field 'lockedDate 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.lockedDate" #f)
    (schema-field 'codeSystem 0 '* (vector 'type 'TerminologyCapabilitiesCodeSystem) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem" #f)
    (schema-field 'expansion 0 1 (vector 'type 'TerminologyCapabilitiesExpansion) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion" #f)
    (schema-field 'codeSearch 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSearch" #f)
    (schema-field 'validateCode 0 1 (vector 'type 'TerminologyCapabilitiesValidateCode) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.validateCode" #f)
    (schema-field 'translation 0 1 (vector 'type 'TerminologyCapabilitiesTranslation) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.translation" #f)
    (schema-field 'closure 0 1 (vector 'type 'TerminologyCapabilitiesClosure) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.closure" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.url" (fhir-spec (string->symbol "TerminologyCapabilities.url") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.url" 'element))
(register-element! "TerminologyCapabilities.version" (fhir-spec (string->symbol "TerminologyCapabilities.version") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.version" 'element))
(register-element! "TerminologyCapabilities.name" (fhir-spec (string->symbol "TerminologyCapabilities.name") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.name" 'element))
(register-element! "TerminologyCapabilities.title" (fhir-spec (string->symbol "TerminologyCapabilities.title") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.title" 'element))
(register-element! "TerminologyCapabilities.status" (fhir-spec (string->symbol "TerminologyCapabilities.status") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.status" 'element))
(register-element! "TerminologyCapabilities.experimental" (fhir-spec (string->symbol "TerminologyCapabilities.experimental") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.experimental" 'element))
(register-element! "TerminologyCapabilities.date" (fhir-spec (string->symbol "TerminologyCapabilities.date") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.date" 'element))
(register-element! "TerminologyCapabilities.publisher" (fhir-spec (string->symbol "TerminologyCapabilities.publisher") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.publisher" 'element))
(register-element! "TerminologyCapabilities.contact" (fhir-spec (string->symbol "TerminologyCapabilities.contact") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.contact" 'element))
(register-element! "TerminologyCapabilities.description" (fhir-spec (string->symbol "TerminologyCapabilities.description") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.description" 'element))
(register-element! "TerminologyCapabilities.useContext" (fhir-spec (string->symbol "TerminologyCapabilities.useContext") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.useContext" 'element))
(register-element! "TerminologyCapabilities.jurisdiction" (fhir-spec (string->symbol "TerminologyCapabilities.jurisdiction") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.jurisdiction" 'element))
(register-element! "TerminologyCapabilities.purpose" (fhir-spec (string->symbol "TerminologyCapabilities.purpose") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.purpose" 'element))
(register-element! "TerminologyCapabilities.copyright" (fhir-spec (string->symbol "TerminologyCapabilities.copyright") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.copyright" 'element))
(register-element! "TerminologyCapabilities.kind" (fhir-spec (string->symbol "TerminologyCapabilities.kind") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.kind" 'element))
(register-element! "TerminologyCapabilities.software" (fhir-spec (string->symbol "TerminologyCapabilities.software") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.software" 'element))
(register-element! "TerminologyCapabilities.implementation" (fhir-spec (string->symbol "TerminologyCapabilities.implementation") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.implementation" 'element))
(register-element! "TerminologyCapabilities.lockedDate" (fhir-spec (string->symbol "TerminologyCapabilities.lockedDate") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.lockedDate" 'element))
(register-element! "TerminologyCapabilities.codeSystem" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem" 'element))
(register-element! "TerminologyCapabilities.expansion" (fhir-spec (string->symbol "TerminologyCapabilities.expansion") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion" 'element))
(register-element! "TerminologyCapabilities.codeSearch" (fhir-spec (string->symbol "TerminologyCapabilities.codeSearch") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSearch" 'element))
(register-element! "TerminologyCapabilities.validateCode" (fhir-spec (string->symbol "TerminologyCapabilities.validateCode") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.validateCode" 'element))
(register-element! "TerminologyCapabilities.translation" (fhir-spec (string->symbol "TerminologyCapabilities.translation") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.translation" 'element))
(register-element! "TerminologyCapabilities.closure" (fhir-spec (string->symbol "TerminologyCapabilities.closure") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.closure" 'element))

(register-type! 'TerminologyCapabilitiesSoftware (fhir-spec 'TerminologyCapabilitiesSoftware "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.software" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesSoftware #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.software"
             (list
    (schema-field 'name 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.software.name" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.software.version" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.software.name" (fhir-spec (string->symbol "TerminologyCapabilities.software.name") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.software.name" 'element))
(register-element! "TerminologyCapabilities.software.version" (fhir-spec (string->symbol "TerminologyCapabilities.software.version") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.software.version" 'element))

(register-type! 'TerminologyCapabilitiesImplementation (fhir-spec 'TerminologyCapabilitiesImplementation "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.implementation" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesImplementation #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.implementation"
             (list
    (schema-field 'description 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.implementation.description" #f)
    (schema-field 'url 0 1 (vector 'prim "url") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.implementation.url" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.implementation.description" (fhir-spec (string->symbol "TerminologyCapabilities.implementation.description") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.implementation.description" 'element))
(register-element! "TerminologyCapabilities.implementation.url" (fhir-spec (string->symbol "TerminologyCapabilities.implementation.url") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.implementation.url" 'element))

(register-type! 'TerminologyCapabilitiesCodeSystem (fhir-spec 'TerminologyCapabilitiesCodeSystem "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesCodeSystem #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem"
             (list
    (schema-field 'uri 0 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.uri" #f)
    (schema-field 'version 0 '* (vector 'type 'TerminologyCapabilitiesCodeSystemVersion) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version" #f)
    (schema-field 'subsumption 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.subsumption" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.codeSystem.uri" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.uri") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.uri" 'element))
(register-element! "TerminologyCapabilities.codeSystem.version" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version" 'element))
(register-element! "TerminologyCapabilities.codeSystem.subsumption" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.subsumption") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.subsumption" 'element))

(register-type! 'TerminologyCapabilitiesCodeSystemVersion (fhir-spec 'TerminologyCapabilitiesCodeSystemVersion "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesCodeSystemVersion #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version"
             (list
    (schema-field 'code 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.code" #f)
    (schema-field 'isDefault 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.isDefault" #f)
    (schema-field 'compositional 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.compositional" #f)
    (schema-field 'language 0 '* (vector 'prim "code") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.language" #f)
    (schema-field 'filter 0 '* (vector 'type 'TerminologyCapabilitiesCodeSystemVersionFilter) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.filter" #f)
    (schema-field 'property 0 '* (vector 'prim "code") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.property" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.codeSystem.version.code" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version.code") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.code" 'element))
(register-element! "TerminologyCapabilities.codeSystem.version.isDefault" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version.isDefault") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.isDefault" 'element))
(register-element! "TerminologyCapabilities.codeSystem.version.compositional" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version.compositional") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.compositional" 'element))
(register-element! "TerminologyCapabilities.codeSystem.version.language" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version.language") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.language" 'element))
(register-element! "TerminologyCapabilities.codeSystem.version.filter" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version.filter") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.filter" 'element))
(register-element! "TerminologyCapabilities.codeSystem.version.property" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version.property") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.property" 'element))

(register-type! 'TerminologyCapabilitiesCodeSystemVersionFilter (fhir-spec 'TerminologyCapabilitiesCodeSystemVersionFilter "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.filter" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesCodeSystemVersionFilter #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.filter"
             (list
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.filter.code" #f)
    (schema-field 'op 1 '* (vector 'prim "code") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.filter.op" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.codeSystem.version.filter.code" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version.filter.code") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.filter.code" 'element))
(register-element! "TerminologyCapabilities.codeSystem.version.filter.op" (fhir-spec (string->symbol "TerminologyCapabilities.codeSystem.version.filter.op") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.codeSystem.version.filter.op" 'element))

(register-type! 'TerminologyCapabilitiesExpansion (fhir-spec 'TerminologyCapabilitiesExpansion "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesExpansion #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion"
             (list
    (schema-field 'hierarchical 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.hierarchical" #f)
    (schema-field 'paging 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.paging" #f)
    (schema-field 'incomplete 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.incomplete" #f)
    (schema-field 'parameter 0 '* (vector 'type 'TerminologyCapabilitiesExpansionParameter) #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.parameter" #f)
    (schema-field 'textFilter 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.textFilter" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.expansion.hierarchical" (fhir-spec (string->symbol "TerminologyCapabilities.expansion.hierarchical") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.hierarchical" 'element))
(register-element! "TerminologyCapabilities.expansion.paging" (fhir-spec (string->symbol "TerminologyCapabilities.expansion.paging") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.paging" 'element))
(register-element! "TerminologyCapabilities.expansion.incomplete" (fhir-spec (string->symbol "TerminologyCapabilities.expansion.incomplete") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.incomplete" 'element))
(register-element! "TerminologyCapabilities.expansion.parameter" (fhir-spec (string->symbol "TerminologyCapabilities.expansion.parameter") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.parameter" 'element))
(register-element! "TerminologyCapabilities.expansion.textFilter" (fhir-spec (string->symbol "TerminologyCapabilities.expansion.textFilter") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.textFilter" 'element))

(register-type! 'TerminologyCapabilitiesExpansionParameter (fhir-spec 'TerminologyCapabilitiesExpansionParameter "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.parameter" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesExpansionParameter #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.parameter"
             (list
    (schema-field 'name 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.parameter.name" #f)
    (schema-field 'documentation 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.parameter.documentation" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.expansion.parameter.name" (fhir-spec (string->symbol "TerminologyCapabilities.expansion.parameter.name") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.parameter.name" 'element))
(register-element! "TerminologyCapabilities.expansion.parameter.documentation" (fhir-spec (string->symbol "TerminologyCapabilities.expansion.parameter.documentation") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.expansion.parameter.documentation" 'element))

(register-type! 'TerminologyCapabilitiesValidateCode (fhir-spec 'TerminologyCapabilitiesValidateCode "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.validateCode" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesValidateCode #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.validateCode"
             (list
    (schema-field 'translations 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.validateCode.translations" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.validateCode.translations" (fhir-spec (string->symbol "TerminologyCapabilities.validateCode.translations") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.validateCode.translations" 'element))

(register-type! 'TerminologyCapabilitiesTranslation (fhir-spec 'TerminologyCapabilitiesTranslation "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.translation" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesTranslation #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.translation"
             (list
    (schema-field 'needsMap 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.translation.needsMap" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.translation.needsMap" (fhir-spec (string->symbol "TerminologyCapabilities.translation.needsMap") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.translation.needsMap" 'element))

(register-type! 'TerminologyCapabilitiesClosure (fhir-spec 'TerminologyCapabilitiesClosure "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.closure" 'type)
  #:schema (type-schema 'TerminologyCapabilitiesClosure #f 'BackboneElement "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.closure"
             (list
    (schema-field 'translation 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.closure.translation" #f)
             ) #f #f))
(register-element! "TerminologyCapabilities.closure.translation" (fhir-spec (string->symbol "TerminologyCapabilities.closure.translation") "https://hl7.org/fhir/R4/terminologycapabilities.html#TerminologyCapabilities.closure.translation" 'element))

