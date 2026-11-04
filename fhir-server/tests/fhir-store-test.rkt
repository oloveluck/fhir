#lang racket/base

;;; fhir-store-test.rkt — end-to-end integration of the persistence engine:
;;;   1. batch-insert Patients + Observations through the transactional API
;;;   2. FHIR search via the SQLite indexes
;;;   3. WAL concurrency: a reader thread sees a stable snapshot while a writer commits

(require rackunit racket/file racket/list
         (only-in fhir/r5/schemas)                       ; register the tower for index extraction
         fhir/store/fhir-sqlite
         fhir/store/fhir-engine)

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

;; ---- 3. WAL concurrency: reader and writer overlap --------------------------
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

;; ---- 4. _sort and _offset ----------------------------------------------------
(define (mrns qs) (for/list ([p (in-list (fhir-search store "Patient" qs))])
                    (hash-ref (car (hash-ref p 'identifier)) 'value)))
(check-equal? (mrns (list (cons "_sort" "identifier"))) '("MRN-0" "MRN-1" "MRN-2"))
(check-equal? (mrns (list (cons "_sort" "-identifier"))) '("MRN-2" "MRN-1" "MRN-0"))
(check-equal? (mrns (list (cons "_sort" "identifier") (cons "_offset" "1") (cons "_count" "1"))) '("MRN-1"))
(check-equal? (map (lambda (p) (hash-ref p 'id)) (fhir-search store "Patient" (list (cons "_sort" "_id"))))
              (sort patient-ids string<?))
;; a _sort naming nothing sortable is ignored as a whole, and said so
(let-values ([(rs ignored) (fhir-search/ignored store "Patient" (list (cons "_sort" "identifier,nope")))])
  (check-equal? (length rs) 3)
  (check-equal? ignored '("_sort")))

(close-fhir-store store)
(delete-file tmp)
(printf "fhir-store integration: all green (CRUD, search, WAL concurrency)\n")
