#lang racket/base

;;; etl.rkt — FHIR -> OMOP: run the SQL-on-FHIR views (omop/views.rkt), apply the IG's ConceptMap
;;; translations, and load the rows into a DuckDB `omop` schema for analytical SQL.
;;;
;;; The pipeline (each stage a pure function over the previous):
;;;   resources (typed nodes)
;;;     --eval-view-->      raw rows (source codes, string keys)
;;;     --translate-->      concept columns mapped through the IG's OWN ConceptMaps (terminology/
;;;                         service over spec/hl7.fhir.uv.omop.tgz); unmapped/absent -> "0", the
;;;                         OMOP "no matching concept" — mirroring the StructureMaps' translate()
;;;                         and the PersonMap nogender default
;;;     --mint-ids-->       integer-typed columns: numeric strings pass through, non-numeric FHIR
;;;                         ids get a stable minted integer (per-run, keyed by the id string)
;;;     --load-omop!-->     CREATE TABLE omop.<table> (DDL DERIVED from the generated OMOP logical
;;;                         models: integer->BIGINT, code/string->VARCHAR, date->DATE,
;;;                         dateTime->TIMESTAMP, decimal->DOUBLE) + INSERTs, in the DuckDB session
;;;                         alongside the ATTACHed SQLite store — FHIR and OMOP queryable side by side.
;;;
;;; Typing follows the IG's logical models (concept ids are `code` -> VARCHAR), not OHDSI DDL —
;;; the IG is this repo's source of truth. DDL emits no NOT NULL: the ETL is lenient by design.

(require racket/contract racket/list racket/string racket/match racket/promise
         json
         fhir/omop/types                                   ; the generated OMOP tower (registry)
         "views.rkt"
         (only-in "../viewdef/eval.rkt" eval-view)
         (only-in "../viewdef/materialize.rkt" replace-table! duck-type sql-literal)
         (only-in "../model/node.rkt" fhir? fhir-type)
         (only-in "../model/base.rkt" primitive-type? primitive-type-value)
         (only-in "../model/introspect.rkt" full-field-specs)
         (only-in "../model/schema.rkt" field-spec-name field-spec-min field-spec-ftype)
         (only-in "../fhirpath/terminology.rkt" tx-service? tx-service-translate)
         (only-in "../terminology/service.rkt" make-terminology)
         (only-in "../serialize/to-json.rkt" node->jsexpr)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../result/result.rkt" ok? ok-value)
         (only-in "../store/fhir-sqlite.rkt" fhir-store?)
         (only-in "../store/fhir-engine.rkt" fhir-search)
         (only-in "../store/fhir-analytics.rkt" analytics? fhir-analytics-query))

(provide
 (contract-out
  ;; the OMOP package's terminology service (lazy; translate uses the IG's ConceptMaps)
  [omop-terminology (-> tx-service?)]
  ;; typed FHIR resources -> hash table-sym -> rows (translated + minted, ready to load)
  [flatten-resources (->* ((listof fhir?)) (#:specs (listof view-spec?)) hash?)]
  ;; DDL for one OMOP table, derived from the generated logical model
  [omop-ddl (-> symbol? string?)]
  ;; create schema+tables and insert the rows into the DuckDB session
  [load-omop! (-> analytics? hash? void?)]
  ;; the whole pipeline: every resource in the store -> omop schema in the analytics session;
  ;; returns hash table -> row count
  [store->omop! (->* (fhir-store? analytics?) (#:specs (listof view-spec?)) hash?)]))

;; ---- terminology (the IG's ConceptMaps) -------------------------------------
(define-values (omop-tgz)
  (build-path (collection-path "fhir") "spec" "hl7.fhir.uv.omop.tgz"))
(define tx-promise (delay (make-terminology omop-tgz)))
(define (omop-terminology) (force tx-promise))

;; translate-code : conceptmap-url code -> target code | #f
;; runs the IG ConceptMap through the terminology service; the result is a Parameters node
(define (translate-code url code)
  (define params ((tx-service-translate (omop-terminology)) url code #f))
  (and (pair? params)
       (let ([js (node->jsexpr (car params))])
         (for/or ([p (in-list (hash-ref js 'parameter '()))])
           (and (equal? (hash-ref p 'name #f) "match")
                (for/or ([part (in-list (hash-ref p 'part '()))])
                  (and (equal? (hash-ref part 'name #f) "concept")
                       (hash-ref (hash-ref part 'valueCoding (hasheq)) 'code #f))))))))

;; ---- row post-passes --------------------------------------------------------
;; A Row is an ordered (Listof (cons col-sym jsexpr-scalar)) — eval-view's shape.

;; translate-row : apply the spec's ConceptMap translations; unmapped/absent concept -> "0"
(define (translate-row row translations)
  (for/list ([cell (in-list row)])
    (match-define (cons col v) cell)
    (define cm (assq col translations))
    (cond [(not cm) cell]
          [(or (eq? v 'null) (not v)) (cons col "0")]
          [else (cons col (or (translate-code (cdr cm) (format "~a" v)) "0"))])))

;; the table's required (min>=1) code columns — computed ONCE per table, not per row
(define (required-code-columns table)
  (for/list ([f (in-list (full-field-specs table))]
             #:when (and (>= (field-spec-min f) 1)
                         (equal? (field-spec-ftype f) #(prim "code"))))
    (field-spec-name f)))

;; required-concept-defaults : a required code column still null -> "0" (OMOP no-matching-concept)
(define (required-concept-defaults row required-codes)
  (for/list ([cell (in-list row)])
    (match-define (cons col v) cell)
    (if (and (memq col required-codes) (eq? v 'null)) (cons col "0") cell)))

;; make-id-minter : -> (string -> exact-integer)  numeric ids pass through; others get a stable
;; per-run integer (>= 1000000, so minted ids are visibly distinct from passthrough ones)
(define (make-id-minter)
  (define table (make-hash))
  (define next (box 1000000))
  (lambda (s)
    (or (string->number s)
        (hash-ref! table s (lambda () (begin0 (unbox next) (set-box! next (add1 (unbox next)))))))))

;; integer-typed columns of a table (person_id, visit_occurrence_id, year_of_birth, …)
(define (integer-columns table)
  (for/list ([f (in-list (full-field-specs table))]
             #:when (equal? (field-spec-ftype f) #(prim "integer")))
    (field-spec-name f)))

;; mint-row : integer columns carrying strings -> integers (via the shared minter)
(define (mint-row row int-cols mint)
  (for/list ([cell (in-list row)])
    (match-define (cons col v) cell)
    (cond [(not (memq col int-cols)) cell]
          [(string? v) (cons col (mint v))]
          [else cell])))

;; ---- flatten ----------------------------------------------------------------
(define (flatten-resources resources #:specs [specs omop-view-specs])
  (define mint (make-id-minter))                 ; ONE minter across tables: person_id keys agree
  (for/hash ([vs (in-list specs)])
    (define table (view-spec-table vs))
    (define int-cols (integer-columns table))
    (define required-codes (required-code-columns table))
    (define rows (eval-view (load-view (view-spec-view vs)) resources))
    (values table
            (for/list ([row (in-list rows)])
              (mint-row (required-concept-defaults
                         (translate-row row (view-spec-translations vs)) required-codes)
                        int-cols mint)))))

;; ---- DuckDB DDL + load ------------------------------------------------------
;; omop-columns : the table's DuckDB columns, DERIVED from the generated OMOP logical model —
;; richer than what the view alone could infer, passed to materialize-view! as the #:columns override
(define (omop-columns table)
  (for/list ([f (in-list (full-field-specs table))])
    (cons (field-spec-name f)
          (duck-type (match (field-spec-ftype f)
                       [(vector 'prim p) p]
                       [_ #f])))))

(define (omop-ddl table)
  (format "CREATE OR REPLACE TABLE omop.~a (~a)" table
          (string-join (for/list ([c (in-list (omop-columns table))])
                         (format "~a ~a" (car c) (cdr c))) ", ")))

;; load-omop! : each table's rows -> a DuckDB omop.<table>, via the generic replace-table!
;; (viewdef/materialize.rkt). Rows are already translated/minted (flatten-resources); columns come
;; from the OMOP logical models, so the table schema is richer than any single row. CREATE OR
;; REPLACE makes the ETL idempotent — including into a persistent .duckdb (open-analytics #:duckdb).
(define (load-omop! a tables)
  (for ([(table rows) (in-hash tables)])
    (replace-table! a "omop" table (omop-columns table) rows)))

;; ---- the whole pipeline -----------------------------------------------------
;; every current resource of the views' source types, out of the store, through the views, into DuckDB
(define (store->omop! store a #:specs [specs omop-view-specs])
  (define source-types
    (remove-duplicates (for/list ([vs (in-list specs)])
                         (hash-ref (view-spec-view vs) 'resource))))
  (define resources
    (append* (for/list ([ty (in-list source-types)])
               (filter values
                       (for/list ([js (in-list (fhir-search store ty '()))])
                         (define r (from-json js #:lenient? #t))
                         (and (ok? r) (ok-value r)))))))
  (define tables (flatten-resources resources #:specs specs))
  (load-omop! a tables)
  (for/hash ([(t rows) (in-hash tables)]) (values t (length rows))))

(module+ test
  (require rackunit fhir/r5/schemas)
  ;; unit: the IG's GenderClass ConceptMap translates administrative-gender -> OMOP concept ids
  (check-equal? (translate-code "http://hl7.org/fhir/uv/omop/ConceptMap/GenderClass" "male") "8507")
  (check-equal? (translate-code "http://hl7.org/fhir/uv/omop/ConceptMap/GenderClass" "female") "8532")
  (check-false (translate-code "http://hl7.org/fhir/uv/omop/ConceptMap/GenderClass" "nope"))
  ;; unit: minting — numeric passthrough, stable mint for the same string
  (define mint (make-id-minter))
  (check-equal? (mint "123") 123)
  (define m1 (mint "pat-x"))
  (check-equal? (mint "pat-x") m1)
  (check-true (>= m1 1000000))
  ;; unit: DDL derives from the generated logical model
  (define ddl (omop-ddl 'person))
  (check-true (regexp-match? #px"person_id BIGINT" ddl))
  (check-true (regexp-match? #px"gender_concept_id VARCHAR" ddl))
  (check-true (regexp-match? #px"birth_datetime TIMESTAMP" ddl))
  ;; end-to-end flatten: Patient -> person row with the translated gender concept
  (define pt (ok-value (from-json (hasheq 'resourceType "Patient" 'id "42" 'gender "female"
                                          'birthDate "1980-06-15")
                                  #:lenient? #t)))
  (define tables (flatten-resources (list pt)))
  (define prow (car (hash-ref tables 'person)))
  (check-equal? (cdr (assq 'person_id prow)) 42)
  (check-equal? (cdr (assq 'gender_concept_id prow)) "8532")
  (check-equal? (cdr (assq 'year_of_birth prow)) 1980)
  (check-equal? (cdr (assq 'month_of_birth prow)) 6)
  (check-equal? (cdr (assq 'gender_source_value prow)) "female"))
