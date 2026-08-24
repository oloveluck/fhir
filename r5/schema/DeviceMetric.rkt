#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DeviceMetric (fhir-spec 'DeviceMetric "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric" 'type)
  #:schema (type-schema 'DeviceMetric #f 'DomainResource "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.identifier" #f)
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.type" #f)
    (schema-field 'unit 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.unit" #f)
    (schema-field 'device 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.device" #f)
    (schema-field 'operationalStatus 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.operationalStatus" #f)
    (schema-field 'color 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.color" #f)
    (schema-field 'category 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.category" #f)
    (schema-field 'measurementFrequency 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.measurementFrequency" #f)
    (schema-field 'calibration 0 '* (vector 'type 'DeviceMetricCalibration) #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration" #f)
             ) #f #f))
(register-element! "DeviceMetric.identifier" (fhir-spec (string->symbol "DeviceMetric.identifier") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.identifier" 'element))
(register-element! "DeviceMetric.type" (fhir-spec (string->symbol "DeviceMetric.type") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.type" 'element))
(register-element! "DeviceMetric.unit" (fhir-spec (string->symbol "DeviceMetric.unit") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.unit" 'element))
(register-element! "DeviceMetric.device" (fhir-spec (string->symbol "DeviceMetric.device") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.device" 'element))
(register-element! "DeviceMetric.operationalStatus" (fhir-spec (string->symbol "DeviceMetric.operationalStatus") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.operationalStatus" 'element))
(register-element! "DeviceMetric.color" (fhir-spec (string->symbol "DeviceMetric.color") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.color" 'element))
(register-element! "DeviceMetric.category" (fhir-spec (string->symbol "DeviceMetric.category") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.category" 'element))
(register-element! "DeviceMetric.measurementFrequency" (fhir-spec (string->symbol "DeviceMetric.measurementFrequency") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.measurementFrequency" 'element))
(register-element! "DeviceMetric.calibration" (fhir-spec (string->symbol "DeviceMetric.calibration") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration" 'element))

(register-type! 'DeviceMetricCalibration (fhir-spec 'DeviceMetricCalibration "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration" 'type)
  #:schema (type-schema 'DeviceMetricCalibration #f 'BackboneElement "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration"
             (list
    (schema-field 'type 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration.type" #f)
    (schema-field 'state 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration.state" #f)
    (schema-field 'time 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration.time" #f)
             ) #f #f))
(register-element! "DeviceMetric.calibration.type" (fhir-spec (string->symbol "DeviceMetric.calibration.type") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration.type" 'element))
(register-element! "DeviceMetric.calibration.state" (fhir-spec (string->symbol "DeviceMetric.calibration.state") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration.state" 'element))
(register-element! "DeviceMetric.calibration.time" (fhir-spec (string->symbol "DeviceMetric.calibration.time") "https://hl7.org/fhir/R5/devicemetric.html#DeviceMetric.calibration.time" 'element))

