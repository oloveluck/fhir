#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'MeasureReport (fhir-spec 'MeasureReport "https://hl7.org/fhir/R4/measurereport.html#MeasureReport" 'type)
  #:schema (type-schema 'MeasureReport #f 'DomainResource "https://hl7.org/fhir/R4/measurereport.html#MeasureReport"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.status" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.type" #f)
    (schema-field 'measure 1 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.measure" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.subject" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.date" #f)
    (schema-field 'reporter 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.reporter" #f)
    (schema-field 'period 1 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.period" #f)
    (schema-field 'improvementNotation 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.improvementNotation" #f)
    (schema-field 'group 0 '* (vector 'type 'MeasureReportGroup) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group" #f)
    (schema-field 'evaluatedResource 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.evaluatedResource" #f)
             ) #f #f))
(register-element! "MeasureReport.identifier" (fhir-spec (string->symbol "MeasureReport.identifier") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.identifier" 'element))
(register-element! "MeasureReport.status" (fhir-spec (string->symbol "MeasureReport.status") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.status" 'element))
(register-element! "MeasureReport.type" (fhir-spec (string->symbol "MeasureReport.type") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.type" 'element))
(register-element! "MeasureReport.measure" (fhir-spec (string->symbol "MeasureReport.measure") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.measure" 'element))
(register-element! "MeasureReport.subject" (fhir-spec (string->symbol "MeasureReport.subject") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.subject" 'element))
(register-element! "MeasureReport.date" (fhir-spec (string->symbol "MeasureReport.date") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.date" 'element))
(register-element! "MeasureReport.reporter" (fhir-spec (string->symbol "MeasureReport.reporter") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.reporter" 'element))
(register-element! "MeasureReport.period" (fhir-spec (string->symbol "MeasureReport.period") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.period" 'element))
(register-element! "MeasureReport.improvementNotation" (fhir-spec (string->symbol "MeasureReport.improvementNotation") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.improvementNotation" 'element))
(register-element! "MeasureReport.group" (fhir-spec (string->symbol "MeasureReport.group") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group" 'element))
(register-element! "MeasureReport.evaluatedResource" (fhir-spec (string->symbol "MeasureReport.evaluatedResource") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.evaluatedResource" 'element))

(register-type! 'MeasureReportGroup (fhir-spec 'MeasureReportGroup "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group" 'type)
  #:schema (type-schema 'MeasureReportGroup #f 'BackboneElement "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group"
             (list
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.code" #f)
    (schema-field 'population 0 '* (vector 'type 'MeasureReportGroupPopulation) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population" #f)
    (schema-field 'measureScore 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.measureScore" #f)
    (schema-field 'stratifier 0 '* (vector 'type 'MeasureReportGroupStratifier) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier" #f)
             ) #f #f))
(register-element! "MeasureReport.group.code" (fhir-spec (string->symbol "MeasureReport.group.code") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.code" 'element))
(register-element! "MeasureReport.group.population" (fhir-spec (string->symbol "MeasureReport.group.population") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population" 'element))
(register-element! "MeasureReport.group.measureScore" (fhir-spec (string->symbol "MeasureReport.group.measureScore") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.measureScore" 'element))
(register-element! "MeasureReport.group.stratifier" (fhir-spec (string->symbol "MeasureReport.group.stratifier") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier" 'element))

(register-type! 'MeasureReportGroupPopulation (fhir-spec 'MeasureReportGroupPopulation "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population" 'type)
  #:schema (type-schema 'MeasureReportGroupPopulation #f 'BackboneElement "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population"
             (list
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population.code" #f)
    (schema-field 'count 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population.count" #f)
    (schema-field 'subjectResults 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population.subjectResults" #f)
             ) #f #f))
(register-element! "MeasureReport.group.population.code" (fhir-spec (string->symbol "MeasureReport.group.population.code") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population.code" 'element))
(register-element! "MeasureReport.group.population.count" (fhir-spec (string->symbol "MeasureReport.group.population.count") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population.count" 'element))
(register-element! "MeasureReport.group.population.subjectResults" (fhir-spec (string->symbol "MeasureReport.group.population.subjectResults") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.population.subjectResults" 'element))

(register-type! 'MeasureReportGroupStratifier (fhir-spec 'MeasureReportGroupStratifier "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier" 'type)
  #:schema (type-schema 'MeasureReportGroupStratifier #f 'BackboneElement "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier"
             (list
    (schema-field 'code 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.code" #f)
    (schema-field 'stratum 0 '* (vector 'type 'MeasureReportGroupStratifierStratum) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum" #f)
             ) #f #f))
(register-element! "MeasureReport.group.stratifier.code" (fhir-spec (string->symbol "MeasureReport.group.stratifier.code") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.code" 'element))
(register-element! "MeasureReport.group.stratifier.stratum" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum" 'element))

(register-type! 'MeasureReportGroupStratifierStratum (fhir-spec 'MeasureReportGroupStratifierStratum "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum" 'type)
  #:schema (type-schema 'MeasureReportGroupStratifierStratum #f 'BackboneElement "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum"
             (list
    (schema-field 'value 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.value" #f)
    (schema-field 'component 0 '* (vector 'type 'MeasureReportGroupStratifierStratumComponent) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.component" #f)
    (schema-field 'population 0 '* (vector 'type 'MeasureReportGroupStratifierStratumPopulation) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population" #f)
    (schema-field 'measureScore 0 1 (vector 'type 'Quantity) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.measureScore" #f)
             ) #f #f))
(register-element! "MeasureReport.group.stratifier.stratum.value" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.value") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.value" 'element))
(register-element! "MeasureReport.group.stratifier.stratum.component" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.component") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.component" 'element))
(register-element! "MeasureReport.group.stratifier.stratum.population" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.population") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population" 'element))
(register-element! "MeasureReport.group.stratifier.stratum.measureScore" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.measureScore") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.measureScore" 'element))

(register-type! 'MeasureReportGroupStratifierStratumComponent (fhir-spec 'MeasureReportGroupStratifierStratumComponent "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.component" 'type)
  #:schema (type-schema 'MeasureReportGroupStratifierStratumComponent #f 'BackboneElement "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.component"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.component.code" #f)
    (schema-field 'value 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.component.value" #f)
             ) #f #f))
(register-element! "MeasureReport.group.stratifier.stratum.component.code" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.component.code") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.component.code" 'element))
(register-element! "MeasureReport.group.stratifier.stratum.component.value" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.component.value") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.component.value" 'element))

(register-type! 'MeasureReportGroupStratifierStratumPopulation (fhir-spec 'MeasureReportGroupStratifierStratumPopulation "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population" 'type)
  #:schema (type-schema 'MeasureReportGroupStratifierStratumPopulation #f 'BackboneElement "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population"
             (list
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population.code" #f)
    (schema-field 'count 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population.count" #f)
    (schema-field 'subjectResults 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population.subjectResults" #f)
             ) #f #f))
(register-element! "MeasureReport.group.stratifier.stratum.population.code" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.population.code") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population.code" 'element))
(register-element! "MeasureReport.group.stratifier.stratum.population.count" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.population.count") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population.count" 'element))
(register-element! "MeasureReport.group.stratifier.stratum.population.subjectResults" (fhir-spec (string->symbol "MeasureReport.group.stratifier.stratum.population.subjectResults") "https://hl7.org/fhir/R4/measurereport.html#MeasureReport.group.stratifier.stratum.population.subjectResults" 'element))

