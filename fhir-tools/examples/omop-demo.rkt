#lang racket/base

;;; omop-demo.rkt — FHIR -> OMOP -> DuckDB, end to end:
;;; clinical FHIR resources go into the SQLite store; `store->omop!` flattens them through the
;;; FHIR-to-OMOP IG's mappings (SQL-on-FHIR views + the IG's ConceptMaps) into a DuckDB `omop`
;;; schema; plain OMOP SQL answers cohort questions — while the same session can still query the
;;; raw FHIR (SQLite) side by side.
;;;
;;;   racket examples/omop-demo.rkt

(require racket/file json
         fhir/r5/schemas fhir/omop/types
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         (only-in fhir/store/fhir-engine fhir-create!)
         (only-in fhir/store/fhir-analytics open-analytics close-analytics fhir-analytics-query)
         (only-in fhir/omop/etl store->omop!))

(define tmp (make-temporary-file "omop-demo-~a.db"))
(define store (open-fhir-store tmp))

;; a small cohort: two patients, a condition, three glucose labs
(for ([r (in-list
          (list (hasheq 'resourceType "Patient" 'id "1" 'gender "female" 'birthDate "1980-06-15")
                (hasheq 'resourceType "Patient" 'id "2" 'gender "male" 'birthDate "1975-01-02")
                (hasheq 'resourceType "Condition" 'id "10"
                        'subject (hasheq 'reference "Patient/1")
                        'code (hasheq 'coding (list (hasheq 'system "http://snomed.info/sct"
                                                            'code "44054006" 'display "Type 2 diabetes")))
                        'clinicalStatus (hasheq 'coding (list (hasheq 'code "active")))
                        'onsetDateTime "2020-03-01T00:00:00Z")
                (hasheq 'resourceType "Observation" 'id "20" 'status "final"
                        'category (list (hasheq 'coding (list (hasheq 'code "laboratory"))))
                        'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "2339-0")))
                        'subject (hasheq 'reference "Patient/1")
                        'effectiveDateTime "2021-01-01T08:00:00Z"
                        'valueQuantity (hasheq 'value 105 'unit "mg/dL"))
                (hasheq 'resourceType "Observation" 'id "21" 'status "final"
                        'category (list (hasheq 'coding (list (hasheq 'code "laboratory"))))
                        'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "2339-0")))
                        'subject (hasheq 'reference "Patient/1")
                        'effectiveDateTime "2021-06-01T08:00:00Z"
                        'valueQuantity (hasheq 'value 115 'unit "mg/dL"))
                (hasheq 'resourceType "Observation" 'id "22" 'status "final"
                        'category (list (hasheq 'coding (list (hasheq 'code "laboratory"))))
                        'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "2339-0")))
                        'subject (hasheq 'reference "Patient/2")
                        'effectiveDateTime "2021-03-10T08:00:00Z"
                        'valueQuantity (hasheq 'value 140 'unit "mg/dL"))))])
  (fhir-create! store r))

(define a (open-analytics store))
(define counts (store->omop! store a))
(printf "ETL: ~a\n\n" (for/list ([(t n) (in-hash counts)] #:when (> n 0)) (cons t n)))

(define (show title sql)
  (printf "-- ~a\n~a\n" title sql)
  (for ([row (in-list (fhir-analytics-query a sql))])
    (displayln (jsexpr->string row)))
  (newline))

(show "persons (gender translated via the IG's GenderClass ConceptMap)"
      "SELECT person_id, gender_concept_id, year_of_birth FROM omop.person ORDER BY person_id")

(show "avg glucose per person (OMOP measurement)"
      "SELECT person_id, AVG(value_as_number) AS avg_glucose, COUNT(*) AS n
       FROM omop.measurement GROUP BY person_id ORDER BY person_id")

(show "diabetics with their latest glucose (join across OMOP tables)"
      "SELECT p.person_id, c.condition_source_value, MAX(m.value_as_number) AS max_glucose
       FROM omop.condition_occurrence c
       JOIN omop.person p USING (person_id)
       JOIN omop.measurement m USING (person_id)
       GROUP BY p.person_id, c.condition_source_value")

(show "the same session still sees the raw FHIR (SQLite via sqlite_scanner)"
      "SELECT resource_type, COUNT(*) AS n FROM fhir.fhir_resources GROUP BY 1 ORDER BY 1")

(close-analytics a)
(close-fhir-store store)
(delete-file tmp)
