#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ProdCharacteristic (fhir-spec 'ProdCharacteristic "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic" 'type)
  #:schema (type-schema 'ProdCharacteristic #f 'BackboneElement "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic"
             (list
    (schema-field 'height 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.height" #f)
    (schema-field 'width 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.width" #f)
    (schema-field 'depth 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.depth" #f)
    (schema-field 'weight 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.weight" #f)
    (schema-field 'nominalVolume 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.nominalVolume" #f)
    (schema-field 'externalDiameter 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.externalDiameter" #f)
    (schema-field 'shape 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.shape" #f)
    (schema-field 'color 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.color" #f)
    (schema-field 'imprint 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.imprint" #f)
    (schema-field 'image 0 '* (vector 'type 'Attachment) #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.image" #f)
    (schema-field 'scoring 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.scoring" #f)
             ) #f #f))
(register-element! "ProdCharacteristic.height" (fhir-spec (string->symbol "ProdCharacteristic.height") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.height" 'element))
(register-element! "ProdCharacteristic.width" (fhir-spec (string->symbol "ProdCharacteristic.width") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.width" 'element))
(register-element! "ProdCharacteristic.depth" (fhir-spec (string->symbol "ProdCharacteristic.depth") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.depth" 'element))
(register-element! "ProdCharacteristic.weight" (fhir-spec (string->symbol "ProdCharacteristic.weight") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.weight" 'element))
(register-element! "ProdCharacteristic.nominalVolume" (fhir-spec (string->symbol "ProdCharacteristic.nominalVolume") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.nominalVolume" 'element))
(register-element! "ProdCharacteristic.externalDiameter" (fhir-spec (string->symbol "ProdCharacteristic.externalDiameter") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.externalDiameter" 'element))
(register-element! "ProdCharacteristic.shape" (fhir-spec (string->symbol "ProdCharacteristic.shape") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.shape" 'element))
(register-element! "ProdCharacteristic.color" (fhir-spec (string->symbol "ProdCharacteristic.color") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.color" 'element))
(register-element! "ProdCharacteristic.imprint" (fhir-spec (string->symbol "ProdCharacteristic.imprint") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.imprint" 'element))
(register-element! "ProdCharacteristic.image" (fhir-spec (string->symbol "ProdCharacteristic.image") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.image" 'element))
(register-element! "ProdCharacteristic.scoring" (fhir-spec (string->symbol "ProdCharacteristic.scoring") "https://hl7.org/fhir/R4/datatypes.html#ProdCharacteristic.scoring" 'element))

