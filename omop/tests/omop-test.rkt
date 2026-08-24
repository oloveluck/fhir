#lang racket/base

;;; omop-test.rkt — end-to-end FHIR -> OMOP -> DuckDB:
;;; a synthetic clinical bundle goes into the SQLite store, `store->omop!` flattens it through the
;;; SQL-on-FHIR views (+ the IG's ConceptMap translations) into a DuckDB `omop` schema, and plain
;;; OMOP SQL (joins, aggregates, date arithmetic) answers questions about it.

(require rackunit racket/file
         json
         fhir/r5/schemas fhir/omop/types
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         (only-in fhir/store/fhir-engine fhir-create!)
         (only-in fhir/store/fhir-analytics open-analytics close-analytics fhir-analytics-query)
         (only-in fhir/omop/etl store->omop!))

;; ---- the synthetic cohort ---------------------------------------------------
(define (patient id gender birth)
  (hasheq 'resourceType "Patient" 'id id 'gender gender 'birthDate birth))
(define (condition id pid code display onset status)
  (hasheq 'resourceType "Condition" 'id id
          'subject (hasheq 'reference (string-append "Patient/" pid))
          'code (hasheq 'coding (list (hasheq 'system "http://snomed.info/sct"
                                              'code code 'display display)))
          'clinicalStatus (hasheq 'coding (list (hasheq 'code status)))
          'onsetDateTime onset))
(define (lab id pid code value unit when)
  (hasheq 'resourceType "Observation" 'id id 'status "final"
          'category (list (hasheq 'coding (list (hasheq 'code "laboratory"))))
          'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code code)))
          'subject (hasheq 'reference (string-append "Patient/" pid))
          'effectiveDateTime when
          'valueQuantity (hasheq 'value value 'unit unit)))
(define (encounter id pid class start end)
  (hasheq 'resourceType "Encounter" 'id id 'status "completed"
          'class (list (hasheq 'coding (list (hasheq 'code class))))
          'subject (hasheq 'reference (string-append "Patient/" pid))
          'actualPeriod (hasheq 'start start 'end end)))

(define tmp (make-temporary-file "omop-test-~a.db"))
(define store (open-fhir-store tmp))
(for ([r (in-list (list (patient "1" "female" "1980-06-15")
                        (patient "2" "male" "1975-01-02")
                        (patient "pat-x" "other" "1990-12-31")   ; non-numeric id -> minted
                        (condition "10" "1" "44054006" "Type 2 diabetes" "2020-03-01T00:00:00Z" "active")
                        (condition "11" "2" "38341003" "Hypertension" "2019-07-15T00:00:00Z" "resolved")
                        (lab "20" "1" "2339-0" 105 "mg/dL" "2021-01-01T08:00:00Z")
                        (lab "21" "1" "2339-0" 115 "mg/dL" "2021-06-01T08:00:00Z")
                        (lab "22" "2" "2339-0" 140 "mg/dL" "2021-03-10T08:00:00Z")
                        (encounter "30" "1" "IMP" "2020-03-01T10:00:00Z" "2020-03-05T16:00:00Z")))])
  (fhir-create! store r))

;; ---- ETL --------------------------------------------------------------------
(define a (open-analytics store))
(define counts (store->omop! store a))
(check-equal? (hash-ref counts 'person) 3)
(check-equal? (hash-ref counts 'condition_occurrence) 2)
(check-equal? (hash-ref counts 'measurement) 3)
(check-equal? (hash-ref counts 'visit_occurrence) 1)

;; ---- OMOP SQL over DuckDB ---------------------------------------------------
(define (q sql) (fhir-analytics-query a sql))

;; genders arrived translated through the IG's GenderClass ConceptMap
(check-equal?
 (q "SELECT gender_concept_id, COUNT(*) AS n FROM omop.person GROUP BY 1 ORDER BY 1")
 (list (hasheq 'gender_concept_id "44814653" 'n 1)     ; other
       (hasheq 'gender_concept_id "8507" 'n 1)         ; male
       (hasheq 'gender_concept_id "8532" 'n 1)))       ; female

;; the non-numeric FHIR id was minted; the numeric ones passed through
(check-equal? (hash-ref (car (q "SELECT COUNT(*) AS n FROM omop.person WHERE person_id >= 1000000")) 'n) 1)
(check-equal? (hash-ref (car (q "SELECT person_source_value FROM omop.person WHERE person_id >= 1000000"))
                        'person_source_value)
              "pat-x")

;; join: conditions per person with year_of_birth (classic OMOP query shape)
(check-equal?
 (q "SELECT p.year_of_birth, c.condition_source_value
     FROM omop.condition_occurrence c JOIN omop.person p USING (person_id)
     ORDER BY p.year_of_birth")
 (list (hasheq 'year_of_birth 1975 'condition_source_value "Hypertension")
       (hasheq 'year_of_birth 1980 'condition_source_value "Type 2 diabetes")))

;; clinicalStatus through ConditionStatusConcepts: the IG maps only resolved -> 32906;
;; an unmapped code (active) lands as "0" — OMOP's "no matching concept"
(check-equal?
 (q "SELECT condition_status_source_value, condition_status_concept_id
     FROM omop.condition_occurrence ORDER BY 1")
 (list (hasheq 'condition_status_source_value "active" 'condition_status_concept_id "0")
       (hasheq 'condition_status_source_value "resolved" 'condition_status_concept_id "32906")))

;; aggregate over measurements: avg glucose per person (values from Observation.valueQuantity)
(check-equal?
 (q "SELECT person_id, AVG(value_as_number) AS avg_v, COUNT(*) AS n
     FROM omop.measurement GROUP BY person_id ORDER BY person_id")
 (list (hasheq 'person_id 1 'avg_v 110.0 'n 2)
       (hasheq 'person_id 2 'avg_v 140.0 'n 1)))

;; DATE/TIMESTAMP columns are real DuckDB types: date arithmetic works
(check-equal?
 (hash-ref (car (q "SELECT datediff('day', visit_start_date, visit_end_date) AS los
                    FROM omop.visit_occurrence"))
           'los)
 4)

;; visit_concept_id went through EncounterClass; the visit joins back to its person
(check-equal?
 (q "SELECT p.gender_concept_id, v.visit_concept_id
     FROM omop.visit_occurrence v JOIN omop.person p USING (person_id)")
 (list (hasheq 'gender_concept_id "8532" 'visit_concept_id "9201")))  ; IMP -> inpatient 9201

;; cross-engine: the same session still sees the raw FHIR in SQLite
(check-equal? (hash-ref (car (q "SELECT COUNT(*) AS n FROM fhir.fhir_resources")) 'n) 9)

(close-analytics a)

;; ---- persistence: the omop schema in a .duckdb FILE survives the session ----
(define duckdb-file (make-temporary-file "omop-out-~a.duckdb"))
(delete-file duckdb-file)                          ; DuckDB must create it itself
(define a2 (open-analytics store #:duckdb duckdb-file))
(store->omop! store a2)
(close-analytics a2)
;; reopen the FILE alone — no store attached — and the OMOP tables are all there
(define a3 (open-analytics #f #:duckdb duckdb-file))
(check-equal? (hash-ref (car (fhir-analytics-query a3 "SELECT COUNT(*) AS n FROM omop.person")) 'n) 3)
(check-equal?
 (fhir-analytics-query a3 "SELECT person_id, gender_concept_id FROM omop.person WHERE person_id = 1")
 (list (hasheq 'person_id 1 'gender_concept_id "8532")))
;; re-running the ETL into the same file REPLACES (idempotent), never appends
(close-analytics a3)
(define a4 (open-analytics store #:duckdb duckdb-file))
(store->omop! store a4)
(check-equal? (hash-ref (car (fhir-analytics-query a4 "SELECT COUNT(*) AS n FROM omop.person")) 'n) 3)
(close-analytics a4)
(delete-file duckdb-file)

(close-fhir-store store)
(delete-file tmp)
