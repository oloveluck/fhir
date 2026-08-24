#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'CompartmentDefinition (fhir-spec 'CompartmentDefinition "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition" 'type)
  #:schema (type-schema 'CompartmentDefinition #f 'DomainResource "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition"
             (list
    (schema-field 'url 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.url" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.version" #f)
    (schema-field 'name 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.name" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.status" #f)
    (schema-field 'experimental 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.experimental" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.date" #f)
    (schema-field 'publisher 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.publisher" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactDetail) #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.contact" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.description" #f)
    (schema-field 'useContext 0 '* (vector 'type 'UsageContext) #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.useContext" #f)
    (schema-field 'purpose 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.purpose" #f)
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.code" #f)
    (schema-field 'search 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.search" #f)
    (schema-field 'resource 0 '* (vector 'type 'CompartmentDefinitionResource) #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource" #f)
             ) #f #f))
(register-element! "CompartmentDefinition.url" (fhir-spec (string->symbol "CompartmentDefinition.url") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.url" 'element))
(register-element! "CompartmentDefinition.version" (fhir-spec (string->symbol "CompartmentDefinition.version") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.version" 'element))
(register-element! "CompartmentDefinition.name" (fhir-spec (string->symbol "CompartmentDefinition.name") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.name" 'element))
(register-element! "CompartmentDefinition.status" (fhir-spec (string->symbol "CompartmentDefinition.status") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.status" 'element))
(register-element! "CompartmentDefinition.experimental" (fhir-spec (string->symbol "CompartmentDefinition.experimental") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.experimental" 'element))
(register-element! "CompartmentDefinition.date" (fhir-spec (string->symbol "CompartmentDefinition.date") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.date" 'element))
(register-element! "CompartmentDefinition.publisher" (fhir-spec (string->symbol "CompartmentDefinition.publisher") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.publisher" 'element))
(register-element! "CompartmentDefinition.contact" (fhir-spec (string->symbol "CompartmentDefinition.contact") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.contact" 'element))
(register-element! "CompartmentDefinition.description" (fhir-spec (string->symbol "CompartmentDefinition.description") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.description" 'element))
(register-element! "CompartmentDefinition.useContext" (fhir-spec (string->symbol "CompartmentDefinition.useContext") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.useContext" 'element))
(register-element! "CompartmentDefinition.purpose" (fhir-spec (string->symbol "CompartmentDefinition.purpose") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.purpose" 'element))
(register-element! "CompartmentDefinition.code" (fhir-spec (string->symbol "CompartmentDefinition.code") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.code" 'element))
(register-element! "CompartmentDefinition.search" (fhir-spec (string->symbol "CompartmentDefinition.search") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.search" 'element))
(register-element! "CompartmentDefinition.resource" (fhir-spec (string->symbol "CompartmentDefinition.resource") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource" 'element))

(register-type! 'CompartmentDefinitionResource (fhir-spec 'CompartmentDefinitionResource "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource" 'type)
  #:schema (type-schema 'CompartmentDefinitionResource #f 'BackboneElement "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource"
             (list
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource.code" #f)
    (schema-field 'param 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource.param" #f)
    (schema-field 'documentation 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource.documentation" #f)
             ) #f #f))
(register-element! "CompartmentDefinition.resource.code" (fhir-spec (string->symbol "CompartmentDefinition.resource.code") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource.code" 'element))
(register-element! "CompartmentDefinition.resource.param" (fhir-spec (string->symbol "CompartmentDefinition.resource.param") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource.param" 'element))
(register-element! "CompartmentDefinition.resource.documentation" (fhir-spec (string->symbol "CompartmentDefinition.resource.documentation") "https://hl7.org/fhir/R4/compartmentdefinition.html#CompartmentDefinition.resource.documentation" 'element))

