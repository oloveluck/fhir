#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SubstancePolymer (fhir-spec 'SubstancePolymer "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer" 'type)
  #:schema (type-schema 'SubstancePolymer #f 'DomainResource "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.identifier" #f)
    (schema-field 'class 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.class" #f)
    (schema-field 'geometry 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.geometry" #f)
    (schema-field 'copolymerConnectivity 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.copolymerConnectivity" #f)
    (schema-field 'modification 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.modification" #f)
    (schema-field 'monomerSet 0 '* (vector 'type 'SubstancePolymerMonomerSet) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet" #f)
    (schema-field 'repeat 0 '* (vector 'type 'SubstancePolymerRepeat) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat" #f)
             ) #f #f))
(register-element! "SubstancePolymer.identifier" (fhir-spec (string->symbol "SubstancePolymer.identifier") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.identifier" 'element))
(register-element! "SubstancePolymer.class" (fhir-spec (string->symbol "SubstancePolymer.class") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.class" 'element))
(register-element! "SubstancePolymer.geometry" (fhir-spec (string->symbol "SubstancePolymer.geometry") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.geometry" 'element))
(register-element! "SubstancePolymer.copolymerConnectivity" (fhir-spec (string->symbol "SubstancePolymer.copolymerConnectivity") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.copolymerConnectivity" 'element))
(register-element! "SubstancePolymer.modification" (fhir-spec (string->symbol "SubstancePolymer.modification") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.modification" 'element))
(register-element! "SubstancePolymer.monomerSet" (fhir-spec (string->symbol "SubstancePolymer.monomerSet") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet" 'element))
(register-element! "SubstancePolymer.repeat" (fhir-spec (string->symbol "SubstancePolymer.repeat") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat" 'element))

(register-type! 'SubstancePolymerMonomerSet (fhir-spec 'SubstancePolymerMonomerSet "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet" 'type)
  #:schema (type-schema 'SubstancePolymerMonomerSet #f 'BackboneElement "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet"
             (list
    (schema-field 'ratioType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.ratioType" #f)
    (schema-field 'startingMaterial 0 '* (vector 'type 'SubstancePolymerMonomerSetStartingMaterial) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial" #f)
             ) #f #f))
(register-element! "SubstancePolymer.monomerSet.ratioType" (fhir-spec (string->symbol "SubstancePolymer.monomerSet.ratioType") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.ratioType" 'element))
(register-element! "SubstancePolymer.monomerSet.startingMaterial" (fhir-spec (string->symbol "SubstancePolymer.monomerSet.startingMaterial") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial" 'element))

(register-type! 'SubstancePolymerMonomerSetStartingMaterial (fhir-spec 'SubstancePolymerMonomerSetStartingMaterial "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial" 'type)
  #:schema (type-schema 'SubstancePolymerMonomerSetStartingMaterial #f 'BackboneElement "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial"
             (list
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial.code" #f)
    (schema-field 'category 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial.category" #f)
    (schema-field 'isDefining 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial.isDefining" #f)
    (schema-field 'amount 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial.amount" #f)
             ) #f #f))
(register-element! "SubstancePolymer.monomerSet.startingMaterial.code" (fhir-spec (string->symbol "SubstancePolymer.monomerSet.startingMaterial.code") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial.code" 'element))
(register-element! "SubstancePolymer.monomerSet.startingMaterial.category" (fhir-spec (string->symbol "SubstancePolymer.monomerSet.startingMaterial.category") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial.category" 'element))
(register-element! "SubstancePolymer.monomerSet.startingMaterial.isDefining" (fhir-spec (string->symbol "SubstancePolymer.monomerSet.startingMaterial.isDefining") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial.isDefining" 'element))
(register-element! "SubstancePolymer.monomerSet.startingMaterial.amount" (fhir-spec (string->symbol "SubstancePolymer.monomerSet.startingMaterial.amount") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.monomerSet.startingMaterial.amount" 'element))

(register-type! 'SubstancePolymerRepeat (fhir-spec 'SubstancePolymerRepeat "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat" 'type)
  #:schema (type-schema 'SubstancePolymerRepeat #f 'BackboneElement "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat"
             (list
    (schema-field 'averageMolecularFormula 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.averageMolecularFormula" #f)
    (schema-field 'repeatUnitAmountType 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnitAmountType" #f)
    (schema-field 'repeatUnit 0 '* (vector 'type 'SubstancePolymerRepeatRepeatUnit) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit" #f)
             ) #f #f))
(register-element! "SubstancePolymer.repeat.averageMolecularFormula" (fhir-spec (string->symbol "SubstancePolymer.repeat.averageMolecularFormula") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.averageMolecularFormula" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnitAmountType" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnitAmountType") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnitAmountType" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit" 'element))

(register-type! 'SubstancePolymerRepeatRepeatUnit (fhir-spec 'SubstancePolymerRepeatRepeatUnit "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit" 'type)
  #:schema (type-schema 'SubstancePolymerRepeatRepeatUnit #f 'BackboneElement "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit"
             (list
    (schema-field 'unit 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.unit" #f)
    (schema-field 'orientation 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.orientation" #f)
    (schema-field 'amount 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.amount" #f)
    (schema-field 'degreeOfPolymerisation 0 '* (vector 'type 'SubstancePolymerRepeatRepeatUnitDegreeOfPolymerisation) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation" #f)
    (schema-field 'structuralRepresentation 0 '* (vector 'type 'SubstancePolymerRepeatRepeatUnitStructuralRepresentation) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation" #f)
             ) #f #f))
(register-element! "SubstancePolymer.repeat.repeatUnit.unit" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.unit") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.unit" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.orientation" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.orientation") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.orientation" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.amount" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.amount") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.amount" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.structuralRepresentation" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.structuralRepresentation") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation" 'element))

(register-type! 'SubstancePolymerRepeatRepeatUnitDegreeOfPolymerisation (fhir-spec 'SubstancePolymerRepeatRepeatUnitDegreeOfPolymerisation "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation" 'type)
  #:schema (type-schema 'SubstancePolymerRepeatRepeatUnitDegreeOfPolymerisation #f 'BackboneElement "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.type" #f)
    (schema-field 'average 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.average" #f)
    (schema-field 'low 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.low" #f)
    (schema-field 'high 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.high" #f)
             ) #f #f))
(register-element! "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.type" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.type") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.type" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.average" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.average") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.average" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.low" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.low") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.low" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.high" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.high") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation.high" 'element))

(register-type! 'SubstancePolymerRepeatRepeatUnitStructuralRepresentation (fhir-spec 'SubstancePolymerRepeatRepeatUnitStructuralRepresentation "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation" 'type)
  #:schema (type-schema 'SubstancePolymerRepeatRepeatUnitStructuralRepresentation #f 'BackboneElement "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation.type" #f)
    (schema-field 'representation 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation.representation" #f)
    (schema-field 'format 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation.format" #f)
    (schema-field 'attachment 0 1 (vector 'type 'Attachment) #f "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation.attachment" #f)
             ) #f #f))
(register-element! "SubstancePolymer.repeat.repeatUnit.structuralRepresentation.type" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.structuralRepresentation.type") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation.type" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.structuralRepresentation.representation" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.structuralRepresentation.representation") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation.representation" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.structuralRepresentation.format" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.structuralRepresentation.format") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation.format" 'element))
(register-element! "SubstancePolymer.repeat.repeatUnit.structuralRepresentation.attachment" (fhir-spec (string->symbol "SubstancePolymer.repeat.repeatUnit.structuralRepresentation.attachment") "https://hl7.org/fhir/R5/substancepolymer.html#SubstancePolymer.repeat.repeatUnit.structuralRepresentation.attachment" 'element))

