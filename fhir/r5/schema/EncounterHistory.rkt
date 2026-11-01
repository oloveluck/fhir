#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'EncounterHistory (fhir-spec 'EncounterHistory "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory" 'type)
  #:schema (type-schema 'EncounterHistory #f 'DomainResource "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory"
             (list
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.encounter" #f)
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.status" #f)
    (schema-field 'class 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.class" #f)
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.type" #f)
    (schema-field 'serviceType 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.serviceType" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.subject" #f)
    (schema-field 'subjectStatus 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.subjectStatus" #f)
    (schema-field 'actualPeriod 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.actualPeriod" #f)
    (schema-field 'plannedStartDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.plannedStartDate" #f)
    (schema-field 'plannedEndDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.plannedEndDate" #f)
    (schema-field 'length 0 1 (vector 'type 'Duration) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.length" #f)
    (schema-field 'location 0 '* (vector 'type 'EncounterHistoryLocation) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.location" #f)
             ) #f #f))
(register-element! "EncounterHistory.encounter" (fhir-spec (string->symbol "EncounterHistory.encounter") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.encounter" 'element))
(register-element! "EncounterHistory.identifier" (fhir-spec (string->symbol "EncounterHistory.identifier") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.identifier" 'element))
(register-element! "EncounterHistory.status" (fhir-spec (string->symbol "EncounterHistory.status") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.status" 'element))
(register-element! "EncounterHistory.class" (fhir-spec (string->symbol "EncounterHistory.class") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.class" 'element))
(register-element! "EncounterHistory.type" (fhir-spec (string->symbol "EncounterHistory.type") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.type" 'element))
(register-element! "EncounterHistory.serviceType" (fhir-spec (string->symbol "EncounterHistory.serviceType") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.serviceType" 'element))
(register-element! "EncounterHistory.subject" (fhir-spec (string->symbol "EncounterHistory.subject") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.subject" 'element))
(register-element! "EncounterHistory.subjectStatus" (fhir-spec (string->symbol "EncounterHistory.subjectStatus") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.subjectStatus" 'element))
(register-element! "EncounterHistory.actualPeriod" (fhir-spec (string->symbol "EncounterHistory.actualPeriod") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.actualPeriod" 'element))
(register-element! "EncounterHistory.plannedStartDate" (fhir-spec (string->symbol "EncounterHistory.plannedStartDate") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.plannedStartDate" 'element))
(register-element! "EncounterHistory.plannedEndDate" (fhir-spec (string->symbol "EncounterHistory.plannedEndDate") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.plannedEndDate" 'element))
(register-element! "EncounterHistory.length" (fhir-spec (string->symbol "EncounterHistory.length") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.length" 'element))
(register-element! "EncounterHistory.location" (fhir-spec (string->symbol "EncounterHistory.location") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.location" 'element))

(register-type! 'EncounterHistoryLocation (fhir-spec 'EncounterHistoryLocation "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.location" 'type)
  #:schema (type-schema 'EncounterHistoryLocation #f 'BackboneElement "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.location"
             (list
    (schema-field 'location 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.location.location" #f)
    (schema-field 'form 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.location.form" #f)
             ) #f #f))
(register-element! "EncounterHistory.location.location" (fhir-spec (string->symbol "EncounterHistory.location.location") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.location.location" 'element))
(register-element! "EncounterHistory.location.form" (fhir-spec (string->symbol "EncounterHistory.location.form") "https://hl7.org/fhir/R5/encounterhistory.html#EncounterHistory.location.form" 'element))

