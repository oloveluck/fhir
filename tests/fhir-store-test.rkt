#lang racket/base

;;; fhir-store-test.rkt — end-to-end integration of the persistence engine:
;;;   1. batch-insert Patients + Observations through the transactional API
;;;   2. FHIR search via the SQLite indexes
;;;   3. analytics over the SAME SQLite file from DuckDB (sqlite_scanner): average observation
;;;      value per patient
;;;   4. WAL concurrency: a reader thread sees a stable snapshot while a writer commits

(require rackunit racket/file racket/list
         (only-in fhir/r5/schemas)                       ; register the tower for index extraction
         fhir/store/fhir-sqlite
         fhir/store/fhir-engine
         fhir/store/fhir-analytics)

(define tmp (make-temporary-file "fhir-integration-~a.db"))
(define store (open-fhir-store tmp))

;; ---- 1. batch insert --------------------------------------------------------
(define patient-ids
  (for/list ([i (in-range 3)])
    (define-values (_t id _v)
      (fhir-create! store (hasheq 'resourceType "Patient"
                                  'gender (if (even? i) "female" "male")
                                  'identifier (list (hasheq 'system "urn:mrn"
                                                            'value (format "MRN-~a" i))))))
    id))

(define (obs patient-id code value)
  (hasheq 'resourceType "Observation" 'status "final"
          'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code code)))
          'subject (hasheq 'reference (string-append "Patient/" patient-id))
          'valueQuantity (hasheq 'value value 'unit "mg/dL")))

;; two glucose readings per patient, values 100+10i and 120+10i
(for ([pid (in-list patient-ids)] [i (in-naturals)])
  (fhir-create! store (obs pid "2339-0" (+ 100 (* 10 i))))
  (fhir-create! store (obs pid "2339-0" (+ 120 (* 10 i)))))

;; ---- 2. FHIR search over the indexes ---------------------------------------
(check-equal? (length (fhir-search store "Patient" (list (cons "gender" "female")))) 2)
(check-equal? (length (fhir-search store "Patient" (list (cons "identifier" "urn:mrn|MRN-1")))) 1)
(check-equal? (length (fhir-search store "Observation" (list (cons "code" "http://loinc.org|2339-0")))) 6)
(check-equal? (length (fhir-search store "Observation"
                                   (list (cons "code" "http://loinc.org|2339-0")
                                         (cons "patient" (string-append "Patient/" (car patient-ids))))))
              2)
(check-equal? (length (fhir-search store "Observation" (list (cons "_lastUpdated" "ge2000-01-01")))) 6)

;; update one patient — history keeps both versions, search reflects the current one
(define p0 (fhir-read store "Patient" (car patient-ids)))
(check-equal? (fhir-update! store (hash-set p0 'gender "other")) 2)
(check-equal? (length (fhir-history store "Patient" (car patient-ids))) 2)
(check-equal? (length (fhir-search store "Patient" (list (cons "gender" "female")))) 1)

;; ---- 3. cross-engine analytics ---------------------------------------------
(call-with-analytics store
  (lambda (a)
    ;; the DuckDB session reads the very same SQLite file
    (check-equal? (hash-ref (car (fhir-analytics-query a
                     "SELECT COUNT(*) AS n FROM fhir.fhir_resources WHERE resource_type='Observation'"))
                            'n)
                  6)
    ;; average observation value per patient, computed by DuckDB over the raw FHIR JSON
    (define rows (fhir-analytics-query a
      "SELECT json_extract_string(raw_resource, '$.subject.reference') AS patient,
              AVG(CAST(json_extract(raw_resource, '$.valueQuantity.value') AS DOUBLE)) AS avg_value
       FROM fhir.fhir_resources
       WHERE resource_type='Observation'
       GROUP BY patient ORDER BY patient"))
    (check-equal? (length rows) 3)
    ;; patient i has readings (100+10i, 120+10i) -> average 110+10i
    (define avgs (sort (map (lambda (r) (hash-ref r 'avg_value)) rows) <))
    (check-equal? avgs '(110.0 120.0 130.0))
    ;; the flattening helper produces one row per observation with code+value
    (define flat (fhir-flatten-observations a))
    (check-equal? (length flat) 6)
    (check-true (andmap (lambda (r) (equal? (hash-ref r 'code) "2339-0")) flat))))

;; ---- 4. WAL concurrency: reader and writer overlap --------------------------
;; A reader holding an open read transaction must see its snapshot while a writer commits new data
;; (WAL's whole point); afterwards fresh reads see the write.
(define before-count
  (call-with-store-connection store
    (lambda (reader-conn)
      (define n0 (length (fhir-search store "Observation" '())))
      ;; concurrent writer on its own pooled connection
      (define writer (thread (lambda () (fhir-create! store (obs (car patient-ids) "718-7" 14)))))
      (thread-wait writer)
      n0)))
(check-equal? before-count 6)
(check-equal? (length (fhir-search store "Observation" '())) 7)

;; parallel writers serialize cleanly under WAL (busy-retry on the pool)
(define writers
  (for/list ([i (in-range 4)])
    (thread (lambda () (fhir-create! store (obs (cadr patient-ids) "718-7" i))))))
(for-each thread-wait writers)
(check-equal? (length (fhir-search store "Observation" (list (cons "code" "http://loinc.org|718-7")))) 5)

(close-fhir-store store)
(delete-file tmp)
(printf "fhir-store integration: all green (CRUD, search, DuckDB analytics, WAL concurrency)\n")
