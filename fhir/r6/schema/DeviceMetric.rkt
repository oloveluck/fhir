#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DeviceMetric (fhir-spec 'DeviceMetric "https://build.fhir.org/devicemetric.html#DeviceMetric" 'type)
  #:schema (type-schema 'DeviceMetric #f 'DomainResource "https://build.fhir.org/devicemetric.html#DeviceMetric"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/devicemetric.html#DeviceMetric.status" #f)
    (schema-field 'operationalStatus 0 1 (vector 'prim "code") #f "https://build.fhir.org/devicemetric.html#DeviceMetric.operationalStatus" #f)
    (schema-field 'category 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.category" #f)
    (schema-field 'type 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.type" #f)
    (schema-field 'device 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.device" #f)
    (schema-field 'unit 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.unit" #f)
    (schema-field 'color 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.color" #f)
    (schema-field 'measurementFrequency 0 1 (vector 'type 'Quantity) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.measurementFrequency" #f)
    (schema-field 'availability 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.availability" #f)
    (schema-field 'calibration 0 '* (vector 'type 'DeviceMetricCalibration) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration" #f)
             ) #f #f))
(register-element! "DeviceMetric.identifier" (fhir-spec (string->symbol "DeviceMetric.identifier") "https://build.fhir.org/devicemetric.html#DeviceMetric.identifier" 'element))
(register-element! "DeviceMetric.status" (fhir-spec (string->symbol "DeviceMetric.status") "https://build.fhir.org/devicemetric.html#DeviceMetric.status" 'element))
(register-element! "DeviceMetric.operationalStatus" (fhir-spec (string->symbol "DeviceMetric.operationalStatus") "https://build.fhir.org/devicemetric.html#DeviceMetric.operationalStatus" 'element))
(register-element! "DeviceMetric.category" (fhir-spec (string->symbol "DeviceMetric.category") "https://build.fhir.org/devicemetric.html#DeviceMetric.category" 'element))
(register-element! "DeviceMetric.type" (fhir-spec (string->symbol "DeviceMetric.type") "https://build.fhir.org/devicemetric.html#DeviceMetric.type" 'element))
(register-element! "DeviceMetric.device" (fhir-spec (string->symbol "DeviceMetric.device") "https://build.fhir.org/devicemetric.html#DeviceMetric.device" 'element))
(register-element! "DeviceMetric.unit" (fhir-spec (string->symbol "DeviceMetric.unit") "https://build.fhir.org/devicemetric.html#DeviceMetric.unit" 'element))
(register-element! "DeviceMetric.color" (fhir-spec (string->symbol "DeviceMetric.color") "https://build.fhir.org/devicemetric.html#DeviceMetric.color" 'element))
(register-element! "DeviceMetric.measurementFrequency" (fhir-spec (string->symbol "DeviceMetric.measurementFrequency") "https://build.fhir.org/devicemetric.html#DeviceMetric.measurementFrequency" 'element))
(register-element! "DeviceMetric.availability" (fhir-spec (string->symbol "DeviceMetric.availability") "https://build.fhir.org/devicemetric.html#DeviceMetric.availability" 'element))
(register-element! "DeviceMetric.calibration" (fhir-spec (string->symbol "DeviceMetric.calibration") "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration" 'element))

(register-type! 'DeviceMetricCalibration (fhir-spec 'DeviceMetricCalibration "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration" 'type)
  #:schema (type-schema 'DeviceMetricCalibration #f 'BackboneElement "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration.type" #f)
    (schema-field 'state 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration.state" #f)
    (schema-field 'time 0 1 (vector 'prim "instant") #f "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration.time" #f)
             ) #f #f))
(register-element! "DeviceMetric.calibration.type" (fhir-spec (string->symbol "DeviceMetric.calibration.type") "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration.type" 'element))
(register-element! "DeviceMetric.calibration.state" (fhir-spec (string->symbol "DeviceMetric.calibration.state") "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration.state" 'element))
(register-element! "DeviceMetric.calibration.time" (fhir-spec (string->symbol "DeviceMetric.calibration.time") "https://build.fhir.org/devicemetric.html#DeviceMetric.calibration.time" 'element))

