#lang racket/base

;;; views.rkt — the SQL-on-FHIR ViewDefinitions that flatten FHIR R5 resources into OMOP CDM rows.
;;;
;;; One view per OMOP table, each MIRRORING the FHIR-to-OMOP IG's own StructureMap for that table
;;; (PersonMap, ConditionMap, MeasurementMap, EncounterVisitMap, MedicationMap, ProcedureMap —
;;; see spec/hl7.fhir.uv.omop.tgz): the maps are the normative mapping; the views express the same
;;; element paths as portable SQL-on-FHIR. Where a map calls `translate(…, ConceptMap, code)` the
;;; view emits the SOURCE code and the ETL applies the IG's own ConceptMap (omop/etl.rkt) — views
;;; stay pure SOF, translation stays IG-driven.
;;;
;;; A ViewSpec is (view-spec table view translations):
;;;   table        : symbol — the OMOP table (a registered fhir/omop type, snake_case)
;;;   view         : jsexpr — the ViewDefinition (validated strictly against the generated
;;;                  SQL-on-FHIR schema by `load-view`; the schema doubles as the view validator)
;;;   translations : (listof (cons column-symbol conceptmap-url)) — the map's translate() calls

(require racket/contract racket/list
         json
         fhir/viewdef/schema/ViewDefinition       ; registers ViewDefinition (resolves vs R5 base)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../result/result.rkt" ok? ok-value err-error)
         (only-in "../model/node.rkt" fhir?))

(provide
 (struct-out view-spec)
 (contract-out
  [omop-view-specs (listof view-spec?)]
  ;; strict-parse a ViewDefinition jsexpr -> typed node (raises on an invalid view)
  [load-view (-> jsexpr? fhir?)]))

(struct view-spec (table view translations) #:transparent)

(define (load-view js)
  (define r (from-json js))
  (if (ok? r) (ok-value r) (error 'load-view "invalid ViewDefinition: ~a" (err-error r))))

;; ---- view construction helpers ----------------------------------------------
(define (col name path) (hasheq 'name name 'path path))
(define (view #:name name #:resource resource #:columns columns #:where [where #f])
  (define base (hasheq 'resourceType "ViewDefinition" 'name name 'status "active"
                       'resource resource
                       'select (list (hasheq 'column columns))))
  (if where (hash-set base 'where (list (hasheq 'path where))) base))

(define cm-base "http://hl7.org/fhir/uv/omop/ConceptMap/")

;; ---- Patient -> person (PersonMap) ------------------------------------------
(define person-view
  (view #:name "omop-person" #:resource "Patient"
        #:columns
        (list (col "person_id" "getResourceKey()")
              ;; map: gender -> translate(GenderClass); empty gender -> 0/'unknown' (nogender rule)
              (col "gender_concept_id" "gender")
              (col "gender_source_value" "iif(gender.exists(), gender, 'unknown')")
              (col "year_of_birth" "birthDate.toString().substring(0, 4).toInteger()")
              (col "month_of_birth" "birthDate.toString().substring(5, 2).toInteger()")
              (col "day_of_birth" "birthDate.toString().substring(8, 2).toInteger()")
              (col "birth_datetime" "birthDate")
              (col "race_concept_id" "'0'")          ; map has no race source in this ballot
              (col "ethnicity_concept_id" "'0'")
              (col "person_source_value" "getResourceKey()"))))

;; ---- Condition -> condition_occurrence (ConditionMap) -----------------------
(define condition-occurrence-view
  (view #:name "omop-condition-occurrence" #:resource "Condition"
        #:columns
        (list (col "condition_occurrence_id" "getResourceKey()")
              (col "person_id" "subject.getReferenceKey(Patient)")
              (col "condition_concept_id" "code.coding.code.first()")
              (col "condition_source_value" "code.coding.display.first()")
              ;; map: recordedDate sets start, onsetDateTime overrides
              (col "condition_start_datetime"
                   "iif(onset.ofType(dateTime).exists(), onset.ofType(dateTime), recordedDate)")
              (col "condition_start_date"
                   "iif(onset.ofType(dateTime).exists(), onset.ofType(dateTime), recordedDate).toString().substring(0, 10)")
              (col "condition_end_datetime" "abatement.ofType(dateTime)")
              (col "condition_end_date" "abatement.ofType(dateTime).toString().substring(0, 10)")
              (col "condition_status_concept_id" "clinicalStatus.coding.code.first()")
              (col "condition_status_source_value" "clinicalStatus.coding.code.first()")
              (col "visit_occurrence_id" "encounter.getReferenceKey(Encounter)")
              (col "condition_type_concept_id" "'32817'"))))   ; map default: 32817 = EHR

;; ---- Observation[laboratory] -> measurement (MeasurementMap) ----------------
(define measurement-view
  (view #:name "omop-measurement" #:resource "Observation"
        #:where "category.coding.code contains 'laboratory'"   ; the map's OnlyMeasures gate
        #:columns
        (list (col "measurement_id" "getResourceKey()")
              (col "person_id" "subject.getReferenceKey(Patient)")
              (col "measurement_concept_id" "code.coding.code.first()")
              (col "measurement_datetime"
                   "iif(effective.ofType(dateTime).exists(), effective.ofType(dateTime), effective.ofType(Period).start)")
              (col "measurement_date"
                   "iif(effective.ofType(dateTime).exists(), effective.ofType(dateTime), effective.ofType(Period).start).toString().substring(0, 10)")
              (col "measurement_type_concept_id" "'32817'")
              (col "value_as_number" "value.ofType(Quantity).value")
              (col "unit_concept_id" "value.ofType(Quantity).unit")
              (col "value_as_concept_id" "value.ofType(CodeableConcept).coding.code.first()")
              (col "value_source_value" "value.ofType(string)")
              (col "provider_id" "performer.first().getReferenceKey(Practitioner)")
              (col "visit_occurrence_id" "encounter.getReferenceKey(Encounter)"))))

;; ---- Encounter -> visit_occurrence (EncounterVisitMap) ----------------------
(define visit-occurrence-view
  (view #:name "omop-visit-occurrence" #:resource "Encounter"
        #:columns
        (list (col "visit_occurrence_id" "getResourceKey()")
              (col "person_id" "subject.getReferenceKey(Patient)")
              (col "visit_concept_id" "class.coding.code.first()")
              (col "visit_source_value" "class.coding.code.first()")
              (col "visit_start_date" "actualPeriod.start.toString().substring(0, 10)")
              (col "visit_start_datetime" "actualPeriod.start")
              (col "visit_end_date" "actualPeriod.end.toString().substring(0, 10)")
              (col "visit_end_datetime" "actualPeriod.end")
              (col "admitted_from_concept_id" "admission.admitSource.coding.code.first()")
              (col "admitted_from_source_value" "admission.admitSource.coding.code.first()")
              (col "discharged_to_concept_id" "admission.dischargeDisposition.coding.code.first()")
              (col "discharged_to_source_value" "admission.dischargeDisposition.coding.code.first()"))))

;; ---- MedicationStatement -> drug_exposure (MedicationMap) -------------------
(define drug-exposure-view
  (view #:name "omop-drug-exposure" #:resource "MedicationStatement"
        #:columns
        (list (col "drug_exposure_id" "getResourceKey()")
              (col "person_id" "subject.getReferenceKey(Patient)")
              (col "drug_concept_id" "medication.concept.coding.code.first()")
              (col "drug_exposure_start_datetime"
                   "iif(effective.ofType(dateTime).exists(), effective.ofType(dateTime), effective.ofType(Period).start)")
              (col "drug_exposure_start_date"
                   "iif(effective.ofType(dateTime).exists(), effective.ofType(dateTime), effective.ofType(Period).start).toString().substring(0, 10)")
              (col "drug_exposure_end_datetime" "effective.ofType(Period).end")
              (col "drug_exposure_end_date" "effective.ofType(Period).end.toString().substring(0, 10)")
              (col "verbatim_end_date" "effective.ofType(Period).end.toString().substring(0, 10)")
              (col "drug_type_concept_id" "category.coding.code.first()")
              (col "stop_reason" "reason.concept.coding.code.first()"))))

;; ---- Procedure -> procedure_occurrence (ProcedureMap) -----------------------
(define procedure-occurrence-view
  (view #:name "omop-procedure-occurrence" #:resource "Procedure"
        #:columns
        (list (col "procedure_occurrence_id" "getResourceKey()")
              (col "person_id" "subject.getReferenceKey(Patient)")
              (col "procedure_concept_id" "code.coding.code.first()")
              (col "procedure_source_concept_id" "code.coding.code.first()")
              (col "procedure_source_value" "code.coding.display.first()")
              (col "procedure_datetime"
                   "iif(occurrence.ofType(dateTime).exists(), occurrence.ofType(dateTime), occurrence.ofType(Period).start)")
              (col "procedure_date"
                   "iif(occurrence.ofType(dateTime).exists(), occurrence.ofType(dateTime), occurrence.ofType(Period).start).toString().substring(0, 10)")
              (col "procedure_end_datetime" "occurrence.ofType(Period).end")
              (col "procedure_end_date" "occurrence.ofType(Period).end.toString().substring(0, 10)")
              (col "visit_occurrence_id" "encounter.getReferenceKey(Encounter)"))))

;; ---- the catalog -------------------------------------------------------------
(define omop-view-specs
  (list
   (view-spec 'person person-view
              (list (cons 'gender_concept_id (string-append cm-base "GenderClass"))))
   (view-spec 'condition_occurrence condition-occurrence-view
              (list (cons 'condition_concept_id (string-append cm-base "ConditionConcepts"))
                    (cons 'condition_status_concept_id (string-append cm-base "ConditionStatusConcepts"))))
   (view-spec 'measurement measurement-view '())
   (view-spec 'visit_occurrence visit-occurrence-view
              (list (cons 'visit_concept_id (string-append cm-base "EncounterClass"))
                    (cons 'admitted_from_concept_id (string-append cm-base "EncounterAdmitSource"))
                    (cons 'discharged_to_concept_id (string-append cm-base "EncounterDischargeDisposition"))))
   (view-spec 'drug_exposure drug-exposure-view '())
   (view-spec 'procedure_occurrence procedure-occurrence-view '())))

(module+ test
  (require rackunit fhir/r5/schemas fhir/omop/types
           (only-in "../viewdef/eval.rkt" view-columns)
           (only-in "../model/introspect.rkt" full-field-specs)
           (only-in "../model/schema.rkt" field-spec-name))
  ;; every view parses STRICTLY against the SQL-on-FHIR schema (the schema is the view validator)
  (for ([vs (in-list omop-view-specs)])
    (check-pred fhir? (load-view (view-spec-view vs))))
  ;; congruence: every view column is a genuine column of its OMOP table (the IG logical model) —
  ;; the no-drift guarantee between the flattening and the generated OMOP tower
  (for ([vs (in-list omop-view-specs)])
    (define table-fields (map field-spec-name (full-field-specs (view-spec-table vs))))
    (for ([c (in-list (view-columns (load-view (view-spec-view vs))))])
      (check-true (and (memq c table-fields) #t)
                  (format "~a.~a not in the OMOP logical model" (view-spec-table vs) c))))
  ;; every translation column is a view column
  (for ([vs (in-list omop-view-specs)])
    (define cols (view-columns (load-view (view-spec-view vs))))
    (for ([tr (in-list (view-spec-translations vs))])
      (check-true (and (memq (car tr) cols) #t)))))
