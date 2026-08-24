#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'FormularyItem (fhir-spec 'FormularyItem "https://hl7.org/fhir/R5/formularyitem.html#FormularyItem" 'type)
  #:schema (type-schema 'FormularyItem #f 'DomainResource "https://hl7.org/fhir/R5/formularyitem.html#FormularyItem"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/formularyitem.html#FormularyItem.identifier" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/formularyitem.html#FormularyItem.code" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/formularyitem.html#FormularyItem.status" #f)
             ) #f #f))
(register-element! "FormularyItem.identifier" (fhir-spec (string->symbol "FormularyItem.identifier") "https://hl7.org/fhir/R5/formularyitem.html#FormularyItem.identifier" 'element))
(register-element! "FormularyItem.code" (fhir-spec (string->symbol "FormularyItem.code") "https://hl7.org/fhir/R5/formularyitem.html#FormularyItem.code" 'element))
(register-element! "FormularyItem.status" (fhir-spec (string->symbol "FormularyItem.status") "https://hl7.org/fhir/R5/formularyitem.html#FormularyItem.status" 'element))

