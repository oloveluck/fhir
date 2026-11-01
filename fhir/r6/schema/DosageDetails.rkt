#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DosageDetails (fhir-spec 'DosageDetails "https://build.fhir.org/datatypes.html#DosageDetails" 'type)
  #:schema (type-schema 'DosageDetails #f 'BackboneType "https://build.fhir.org/datatypes.html#DosageDetails"
             (list
    (schema-field 'renderedInstruction 1 1 (vector 'prim "markdown") #f "https://build.fhir.org/datatypes.html#DosageDetails.renderedInstruction" #f)
    (schema-field 'step 0 '* (vector 'type 'DosageDetailsStep) #f "https://build.fhir.org/datatypes.html#DosageDetails.step" #f)
    (schema-field 'safety 0 1 (vector 'type 'DosageSafety) #f "https://build.fhir.org/datatypes.html#DosageDetails.safety" #f)
             ) #f #f))
(register-element! "DosageDetails.renderedInstruction" (fhir-spec (string->symbol "DosageDetails.renderedInstruction") "https://build.fhir.org/datatypes.html#DosageDetails.renderedInstruction" 'element))
(register-element! "DosageDetails.step" (fhir-spec (string->symbol "DosageDetails.step") "https://build.fhir.org/datatypes.html#DosageDetails.step" 'element))
(register-element! "DosageDetails.safety" (fhir-spec (string->symbol "DosageDetails.safety") "https://build.fhir.org/datatypes.html#DosageDetails.safety" 'element))

(register-type! 'DosageDetailsStep (fhir-spec 'DosageDetailsStep "https://build.fhir.org/datatypes.html#DosageDetails.step" 'type)
  #:schema (type-schema 'DosageDetailsStep #f 'BackboneElement "https://build.fhir.org/datatypes.html#DosageDetails.step"
             (list
    (schema-field 'start 0 1 (vector 'type 'RelativeTime) #f "https://build.fhir.org/datatypes.html#DosageDetails.step.start" #f)
    (schema-field 'end 0 1 (vector 'type 'RelativeTime) #f "https://build.fhir.org/datatypes.html#DosageDetails.step.end" #f)
    (schema-field 'count 0 1 (vector 'prim "integer") #f "https://build.fhir.org/datatypes.html#DosageDetails.step.count" #f)
    (schema-field 'component 1 '* (vector 'type 'Dosage) #f "https://build.fhir.org/datatypes.html#DosageDetails.step.component" #f)
    (schema-field 'safety 0 1 (vector 'type 'DosageSafety) #f "https://build.fhir.org/datatypes.html#DosageDetails.step.safety" #f)
             ) #f #f))
(register-element! "DosageDetails.step.start" (fhir-spec (string->symbol "DosageDetails.step.start") "https://build.fhir.org/datatypes.html#DosageDetails.step.start" 'element))
(register-element! "DosageDetails.step.end" (fhir-spec (string->symbol "DosageDetails.step.end") "https://build.fhir.org/datatypes.html#DosageDetails.step.end" 'element))
(register-element! "DosageDetails.step.count" (fhir-spec (string->symbol "DosageDetails.step.count") "https://build.fhir.org/datatypes.html#DosageDetails.step.count" 'element))
(register-element! "DosageDetails.step.component" (fhir-spec (string->symbol "DosageDetails.step.component") "https://build.fhir.org/datatypes.html#DosageDetails.step.component" 'element))
(register-element! "DosageDetails.step.safety" (fhir-spec (string->symbol "DosageDetails.step.safety") "https://build.fhir.org/datatypes.html#DosageDetails.step.safety" 'element))

