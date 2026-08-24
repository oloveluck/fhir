#lang racket/base

;;; session.rkt — the front door for querying OMOP: open a session over a FHIR store, the ETL runs,
;;; and plain SQL answers questions — `omop.*` (the flattened CDM) and `fhir.*` (the raw resources
;;; in SQLite, via sqlite_scanner) are both visible in the same session.
;;;
;;;   (with-omop store
;;;     (lambda (s) (omop-query s "SELECT ... FROM omop.person JOIN omop.measurement ...")))
;;;
;;; #:duckdb makes the session persistent: the omop schema lands in that .duckdb FILE, which the
;;; standalone `duckdb` CLI (or any DuckDB client) opens directly after the session closes. Reopen
;;; later without the store via (open-analytics #f #:duckdb path) — or just `duckdb path`.
;;;
;;; Custom SQL-on-FHIR views materialize into the SAME session with omop-materialize! — user
;;; flattenings live alongside the OMOP CDM tables (schema "sof" by default).

(require racket/contract
         json
         "etl.rkt" "views.rkt"
         (only-in "../viewdef/materialize.rkt" materialize-view!)
         (only-in "../model/node.rkt" fhir?)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../result/result.rkt" ok? ok-value)
         (only-in "../store/fhir-sqlite.rkt" fhir-store?)
         (only-in "../store/fhir-engine.rkt" fhir-search)
         (only-in "../store/fhir-analytics.rkt" open-analytics close-analytics fhir-analytics-query
                  analytics?))

(provide
 (contract-out
  [omop-session?      (-> any/c boolean?)]
  ;; open a session: analytics over the store (+ optional persistent .duckdb) + full OMOP ETL
  [open-omop          (->* (fhir-store?) (#:duckdb (or/c path-string? #f) #:specs (listof view-spec?))
                           omop-session?)]
  ;; plain SQL -> rows (hasheq per row); omop.* and fhir.* both in scope
  [omop-query         (-> omop-session? string? (listof hash?))]
  ;; ETL row counts per table (from the session's load)
  [omop-counts        (-> omop-session? hash?)]
  ;; materialize a CUSTOM SQL-on-FHIR view into this session (resources default: the whole store)
  [omop-materialize!  (->* (omop-session? jsexpr?)
                           (#:resources (or/c #f (listof fhir?)) #:schema string?)
                           exact-nonnegative-integer?)]
  [close-omop         (-> omop-session? void?)]
  [with-omop          (->* (fhir-store? (-> omop-session? any))
                           (#:duckdb (or/c path-string? #f)) any)]))

(struct omop-session (store analytics counts) #:transparent)

(define (open-omop store #:duckdb [duckdb-path #f] #:specs [specs omop-view-specs])
  (define a (open-analytics store #:duckdb duckdb-path))
  (define counts (store->omop! store a #:specs specs))
  (omop-session store a counts))

(define (omop-query s sql) (fhir-analytics-query (omop-session-analytics s) sql))
(define (omop-counts s) (omop-session-counts s))

;; store-resources : every current resource of one type, as typed nodes
(define (store-resources store rtype)
  (filter values
          (for/list ([js (in-list (fhir-search store rtype '()))])
            (define r (from-json js #:lenient? #t))
            (and (ok? r) (ok-value r)))))

(define (omop-materialize! s view #:resources [resources #f] #:schema [schema "sof"])
  (define rs (or resources
                 (store-resources (omop-session-store s) (hash-ref view 'resource))))
  (materialize-view! (omop-session-analytics s) view rs #:schema schema))

(define (close-omop s) (close-analytics (omop-session-analytics s)))

(define (with-omop store proc #:duckdb [duckdb-path #f])
  (define s (open-omop store #:duckdb duckdb-path))
  (dynamic-wind void (lambda () (proc s)) (lambda () (close-omop s))))

(module+ test
  (require rackunit racket/file fhir/r5/schemas fhir/omop/types
           (only-in "../store/fhir-sqlite.rkt" open-fhir-store close-fhir-store)
           (only-in "../store/fhir-engine.rkt" fhir-create!))
  (define tmp (make-temporary-file "omop-session-~a.db"))
  (define store (open-fhir-store tmp))
  (fhir-create! store (hasheq 'resourceType "Patient" 'id "1" 'gender "female" 'birthDate "1980-06-15"))
  (fhir-create! store (hasheq 'resourceType "Patient" 'id "2" 'gender "male" 'birthDate "1975-01-02"))
  (with-omop store
    (lambda (s)
      (check-equal? (hash-ref (omop-counts s) 'person) 2)
      ;; OMOP SQL
      (check-equal? (omop-query s "SELECT COUNT(*) AS n FROM omop.person WHERE gender_concept_id = '8532'")
                    (list (hasheq 'n 1)))
      ;; raw FHIR in the same session
      (check-equal? (omop-query s "SELECT COUNT(*) AS n FROM fhir.fhir_resources")
                    (list (hasheq 'n 2)))
      ;; a custom view materializes ALONGSIDE the omop schema, straight from the store
      (define genders-view
        (hasheq 'resourceType "ViewDefinition" 'name "patient_genders" 'status "active"
                'resource "Patient"
                'select (list (hasheq 'column (list (hasheq 'name "pid" 'path "getResourceKey()")
                                                    (hasheq 'name "gender" 'path "gender"))))))
      (check-equal? (omop-materialize! s genders-view) 2)
      (check-equal? (omop-query s "SELECT COUNT(*) AS n FROM sof.patient_genders WHERE gender = 'male'")
                    (list (hasheq 'n 1)))))
  (close-fhir-store store)
  (delete-file tmp))
