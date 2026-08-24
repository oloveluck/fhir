#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Substance (fhir-spec 'Substance "https://hl7.org/fhir/R4/substance.html#Substance" 'type)
  #:schema (type-schema 'Substance #f 'DomainResource "https://hl7.org/fhir/R4/substance.html#Substance"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/substance.html#Substance.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/substance.html#Substance.status" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/substance.html#Substance.category" #f)
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/substance.html#Substance.code" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/substance.html#Substance.description" #f)
    (schema-field 'instance 0 '* (vector 'type 'SubstanceInstance) #f "https://hl7.org/fhir/R4/substance.html#Substance.instance" #f)
    (schema-field 'ingredient 0 '* (vector 'type 'SubstanceIngredient) #f "https://hl7.org/fhir/R4/substance.html#Substance.ingredient" #f)
             ) #f #f))
(register-element! "Substance.identifier" (fhir-spec (string->symbol "Substance.identifier") "https://hl7.org/fhir/R4/substance.html#Substance.identifier" 'element))
(register-element! "Substance.status" (fhir-spec (string->symbol "Substance.status") "https://hl7.org/fhir/R4/substance.html#Substance.status" 'element))
(register-element! "Substance.category" (fhir-spec (string->symbol "Substance.category") "https://hl7.org/fhir/R4/substance.html#Substance.category" 'element))
(register-element! "Substance.code" (fhir-spec (string->symbol "Substance.code") "https://hl7.org/fhir/R4/substance.html#Substance.code" 'element))
(register-element! "Substance.description" (fhir-spec (string->symbol "Substance.description") "https://hl7.org/fhir/R4/substance.html#Substance.description" 'element))
(register-element! "Substance.instance" (fhir-spec (string->symbol "Substance.instance") "https://hl7.org/fhir/R4/substance.html#Substance.instance" 'element))
(register-element! "Substance.ingredient" (fhir-spec (string->symbol "Substance.ingredient") "https://hl7.org/fhir/R4/substance.html#Substance.ingredient" 'element))

(register-type! 'SubstanceInstance (fhir-spec 'SubstanceInstance "https://hl7.org/fhir/R4/substance.html#Substance.instance" 'type)
  #:schema (type-schema 'SubstanceInstance #f 'BackboneElement "https://hl7.org/fhir/R4/substance.html#Substance.instance"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/substance.html#Substance.instance.identifier" #f)
    (schema-field 'expiry 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/substance.html#Substance.instance.expiry" #f)
    (schema-field 'quantity 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/substance.html#Substance.instance.quantity" #f)
             ) #f #f))
(register-element! "Substance.instance.identifier" (fhir-spec (string->symbol "Substance.instance.identifier") "https://hl7.org/fhir/R4/substance.html#Substance.instance.identifier" 'element))
(register-element! "Substance.instance.expiry" (fhir-spec (string->symbol "Substance.instance.expiry") "https://hl7.org/fhir/R4/substance.html#Substance.instance.expiry" 'element))
(register-element! "Substance.instance.quantity" (fhir-spec (string->symbol "Substance.instance.quantity") "https://hl7.org/fhir/R4/substance.html#Substance.instance.quantity" 'element))

(register-type! 'SubstanceIngredient (fhir-spec 'SubstanceIngredient "https://hl7.org/fhir/R4/substance.html#Substance.ingredient" 'type)
  #:schema (type-schema 'SubstanceIngredient #f 'BackboneElement "https://hl7.org/fhir/R4/substance.html#Substance.ingredient"
             (list
    (schema-field 'quantity 0 1 (vector 'type 'Ratio) #f "https://hl7.org/fhir/R4/substance.html#Substance.ingredient.quantity" #f)
    (schema-field 'substanceCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'substance "https://hl7.org/fhir/R4/substance.html#Substance.ingredient.substance[x]" #f)
    (schema-field 'substanceReference 0 1 (vector 'type 'Reference) 'substance "https://hl7.org/fhir/R4/substance.html#Substance.ingredient.substance[x]" #f)
             ) #f #f))
(register-element! "Substance.ingredient.quantity" (fhir-spec (string->symbol "Substance.ingredient.quantity") "https://hl7.org/fhir/R4/substance.html#Substance.ingredient.quantity" 'element))
(register-element! "Substance.ingredient.substance[x]" (fhir-spec (string->symbol "Substance.ingredient.substance[x]") "https://hl7.org/fhir/R4/substance.html#Substance.ingredient.substance[x]" 'element))
(register-element! "Substance.ingredient.substance[x]" (fhir-spec (string->symbol "Substance.ingredient.substance[x]") "https://hl7.org/fhir/R4/substance.html#Substance.ingredient.substance[x]" 'element))

