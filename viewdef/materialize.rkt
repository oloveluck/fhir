#lang racket/base

;;; materialize.rkt — materialize ANY SQL-on-FHIR ViewDefinition as a DuckDB table.
;;;
;;; The generic bottom half of FHIR->relational: a view (evaluated by eval.rkt over typed
;;; resources) becomes a `CREATE OR REPLACE TABLE <schema>.<table>` + batched INSERTs in an
;;; analytics session (store/fhir-analytics.rkt) — in-memory, or a persistent .duckdb file the
;;; standalone duckdb CLI can open. `CREATE OR REPLACE` makes re-materialization idempotent.
;;;
;;; Column DuckDB types come from, in order:
;;;   1. an explicit #:columns override — (listof (cons col-sym ducktype-string)) — for callers
;;;      whose table schema is richer than the view (fhir/omop derives DDL from the IG's logical
;;;      models this way);
;;;   2. the view's own column `type` hints (ViewDefinition.select.column.type, a FHIR type code);
;;;   3. inference from the materialized row values (integer -> BIGINT, real -> DOUBLE,
;;;      boolean -> BOOLEAN, else VARCHAR).
;;;
;;; #:transform is an optional per-row post-pass (Row -> Row) between evaluation and insertion —
;;; the seam fhir/omop uses for ConceptMap translation and id minting.

(require racket/contract racket/list racket/string racket/match
         json
         "schema/ViewDefinition.rkt"              ; registers ViewDefinition (resolves vs any core tower)
         (only-in "eval.rkt" eval-view view-columns)
         (only-in "../model/node.rkt" fhir?)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../result/result.rkt" ok? ok-value err-error)
         (only-in "../store/fhir-analytics.rkt" analytics? fhir-analytics-query))

(provide
 (contract-out
  ;; FHIR type code -> DuckDB column type
  [duck-type (-> (or/c string? symbol? #f) string?)]
  ;; one row cell -> a DuckDB SQL literal (escaped; 'null/#f -> NULL)
  [sql-literal (-> any/c string?)]
  ;; the bottom half: CREATE OR REPLACE TABLE schema.table (columns) + batched INSERT of rows
  [replace-table! (-> analytics? string? (or/c symbol? string?)
                      (listof (cons/c symbol? string?)) (listof list?) void?)]
  ;; view (typed node or jsexpr) × resources -> the created table's row count
  [materialize-view! (->* (analytics? (or/c fhir? jsexpr?) (listof fhir?))
                          (#:schema string? #:table (or/c symbol? string? #f)
                           #:transform (-> list? list?)
                           #:columns (or/c #f (listof (cons/c symbol? string?))))
                          exact-nonnegative-integer?)]))

;; ---- typing -----------------------------------------------------------------
(define (duck-type ftype)
  (match (and ftype (format "~a" ftype))
    ["integer" "BIGINT"] ["integer64" "BIGINT"] ["positiveInt" "BIGINT"] ["unsignedInt" "BIGINT"]
    ["decimal" "DOUBLE"]
    ["boolean" "BOOLEAN"]
    ["date" "DATE"]
    ["dateTime" "TIMESTAMP"] ["instant" "TIMESTAMP"]
    [_ "VARCHAR"]))                                ; code, string, id, uri, …

;; infer-type : the column's values -> a DuckDB type (first non-null value decides)
(define (infer-type vals)
  (define v (for/first ([x (in-list vals)] #:unless (or (eq? x 'null) (not x))) x))
  (cond [(exact-integer? v) "BIGINT"]
        [(real? v) "DOUBLE"]
        [(boolean? v) "BOOLEAN"]
        [else "VARCHAR"]))

;; column-types : view-node rows -> (listof (cons col-sym ducktype)) via hints, else inference
(define (column-types view rows)
  (define hints (column-type-hints view))
  (for/list ([col (in-list (view-columns view))])
    (cons col
          (cond [(assq col hints) => (lambda (h) (duck-type (cdr h)))]
                [else (infer-type (for/list ([r (in-list rows)])
                                    (cond [(assq col r) => cdr] [else 'null])))]))))

;; column-type-hints : walk the view's select tree for columns carrying a `type` element
(define (column-type-hints view)
  (define js (if (fhir? view) #f view))            ; hints are read from the jsexpr form
  (let walk ([sels (if js (hash-ref js 'select '()) '())])
    (append*
     (for/list ([s (in-list sels)])
       (append (for/list ([c (in-list (hash-ref s 'column '()))]
                          #:when (hash-ref c 'type #f))
                 (cons (string->symbol (hash-ref c 'name)) (hash-ref c 'type)))
               (walk (hash-ref s 'select '()))
               (walk (hash-ref s 'unionAll '())))))))

;; ---- SQL rendering ----------------------------------------------------------
(define (sql-literal v)
  (cond [(or (eq? v 'null) (not v)) "NULL"]
        [(exact-integer? v) (number->string v)]
        [(real? v) (number->string (exact->inexact v))]
        [(boolean? v) "TRUE"]                       ; #f handled above
        [(list? v) (format "'~a'" (escape (jsexpr->string v)))]   ; collection column -> JSON text
        [else (format "'~a'" (escape (format "~a" v)))]))
(define (escape s) (string-replace s "'" "''"))

;; ---- materialization --------------------------------------------------------
;; the view's jsexpr + typed forms (accept either; validate the jsexpr strictly)
(define (view-node-of v)
  (cond [(fhir? v) v]
        [else (define r (from-json v))
              (if (ok? r) (ok-value r) (error 'materialize-view! "invalid ViewDefinition: ~a"
                                              (err-error r)))]))

;; replace-table! : the shared bottom half — idempotent table replacement + batched insert.
;; Rows are ordered alists; a column missing from a row inserts as NULL.
(define (replace-table! a schema table cols rows)
  (void (fhir-analytics-query a (format "CREATE SCHEMA IF NOT EXISTS ~a" schema)))
  (void (fhir-analytics-query a
         (format "CREATE OR REPLACE TABLE ~a.~a (~a)" schema table
                 (string-join (for/list ([c (in-list cols)])
                                (format "~a ~a" (car c) (cdr c))) ", "))))
  (unless (null? rows)
    (define col-names (map car cols))
    (void (fhir-analytics-query a
           (format "INSERT INTO ~a.~a (~a) VALUES ~a" schema table
                   (string-join (map symbol->string col-names) ", ")
                   (string-join
                    (for/list ([row (in-list rows)])
                      (format "(~a)"
                              (string-join (for/list ([c (in-list col-names)])
                                             (sql-literal (cond [(assq c row) => cdr] [else 'null])))
                                           ", ")))
                    ", "))))))

(define (materialize-view! a view resources
                           #:schema [schema "sof"] #:table [table #f]
                           #:transform [transform values] #:columns [columns #f])
  (define node (view-node-of view))
  (define name (or table
                   (and (hash? view) (hash-ref view 'name #f))
                   (error 'materialize-view! "view has no name and no #:table given")))
  (define rows (map transform (eval-view node resources)))
  (define cols (or columns (column-types node rows)))
  (replace-table! a schema name cols rows)
  (length rows))

(module+ test
  (require rackunit racket/file
           fhir/r5/schemas
           (only-in "../store/fhir-sqlite.rkt" open-fhir-store close-fhir-store)
           (only-in "../store/fhir-analytics.rkt" open-analytics close-analytics))
  ;; unit: typing
  (check-equal? (duck-type "integer") "BIGINT")
  (check-equal? (duck-type "dateTime") "TIMESTAMP")
  (check-equal? (duck-type "code") "VARCHAR")
  (check-equal? (sql-literal "O'Brien") "'O''Brien'")
  (check-equal? (sql-literal 'null) "NULL")
  ;; a custom (non-OMOP) view: one row per Patient NAME (forEach), with a typed hint column
  (define names-view
    (hasheq 'resourceType "ViewDefinition" 'name "patient_names" 'status "active"
            'resource "Patient"
            'select (list (hasheq 'column (list (hasheq 'name "pid" 'path "getResourceKey()")
                                                (hasheq 'name "birth_year"
                                                        'path "birthDate.toString().substring(0, 4).toInteger()"
                                                        'type "integer")))
                          (hasheq 'forEach "name"
                                  'column (list (hasheq 'name "family" 'path "family")
                                                (hasheq 'name "given" 'path "given.first()"))))))
  (define (mk js) (ok-value (from-json js #:lenient? #t)))
  (define pts
    (list (mk (hasheq 'resourceType "Patient" 'id "1" 'birthDate "1980-06-15"
                      'name (list (hasheq 'family "O'Brien" 'given (list "Miles"))
                                  (hasheq 'family "Smith" 'given (list "Jane")))))
          (mk (hasheq 'resourceType "Patient" 'id "2" 'birthDate "1975-01-02"
                      'name (list (hasheq 'family "Doe" 'given (list "John")))))))
  (define tmp (make-temporary-file "materialize-~a.db"))
  (define store (open-fhir-store tmp))
  (define a (open-analytics store))
  (check-equal? (materialize-view! a names-view pts) 3)     ; 2 + 1 names
  (require (only-in "../store/fhir-analytics.rkt" fhir-analytics-query))
  ;; the typed hint made birth_year a BIGINT; escaping survived
  (check-equal?
   (fhir-analytics-query a "SELECT family, birth_year FROM sof.patient_names WHERE given = 'Miles'")
   (list (hasheq 'family "O'Brien" 'birth_year 1980)))
  (check-equal?
   (hash-ref (car (fhir-analytics-query a
                   "SELECT COUNT(*) AS n FROM sof.patient_names WHERE birth_year < 1980")) 'n) 1)
  ;; re-materialization is idempotent (CREATE OR REPLACE, not append)
  (check-equal? (materialize-view! a names-view pts) 3)
  (check-equal? (hash-ref (car (fhir-analytics-query a "SELECT COUNT(*) AS n FROM sof.patient_names")) 'n) 3)
  ;; #:transform post-pass + #:table override
  (check-equal? (materialize-view! a names-view pts
                                   #:table "upper_names"
                                   #:transform (lambda (row)
                                                 (for/list ([cell (in-list row)])
                                                   (if (and (eq? (car cell) 'family) (string? (cdr cell)))
                                                       (cons 'family (string-upcase (cdr cell)))
                                                       cell))))
                3)
  (check-equal?
   (hash-ref (car (fhir-analytics-query a "SELECT family FROM sof.upper_names WHERE given = 'John'"))
             'family)
   "DOE")
  (close-analytics a)
  (close-fhir-store store)
  (delete-file tmp))
