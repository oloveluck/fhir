#lang racket/base

;;; fhir-analytics.rkt — DuckDB (via FFI) over the SQLite store: SQL-on-FHIR analytics.
;;;
;;; An Analytics handle is (analytics db con): two DuckDB pointers (database, connection), both
;;; finalized — `close-analytics` is the explicit path, and a will-executor-backed finalizer covers
;;; leaks. `open-analytics` starts an in-memory DuckDB, runs `INSTALL sqlite; LOAD sqlite;` (the
;;; sqlite_scanner extension) and ATTACHes the store's SQLite file as catalog `fhir`, so the SAME
;;; file serves transactional CRUD (SQLite/WAL) and analytical SQL (DuckDB) concurrently.
;;;
;;; FFI surface (minimal, per the C API): duckdb_open/connect/query/destroy_result +
;;; column_count/row_count/column_name/column_type/value_varchar/value_is_null/free/disconnect/close.
;;; A duckdb_result is a by-value struct the caller allocates; we malloc a raw 64-byte block
;;; (the struct is 48 bytes on 64-bit; the slack is deliberate) and always destroy_result+free it.

(require racket/contract racket/string
         (rename-in ffi/unsafe [-> ~>]) ffi/unsafe/define ffi/unsafe/alloc
         json
         "fhir-sqlite.rkt")

(provide
 (contract-out
  [analytics?            (-> any/c boolean?)]
  ;; store #f = no ATTACH (reopening a persistent .duckdb just to query it);
  ;; #:duckdb path = a persistent DuckDB file instead of :memory: (tables survive the session
  ;; and are directly queryable by the standalone duckdb CLI)
  [open-analytics        (->* ((or/c fhir-store? #f)) (#:duckdb (or/c path-string? #f)) analytics?)]
  [close-analytics       (-> analytics? void?)]
  [call-with-analytics   (->* ((or/c fhir-store? #f) (-> analytics? any))
                              (#:duckdb (or/c path-string? #f)) any)]
  ;; run any SQL; rows come back as hasheq column-symbol -> string|number|boolean|'null
  [fhir-analytics-query  (-> analytics? string? (listof hash?))]
  ;; SQL-on-FHIR convenience: flatten Observations to (patient, system, code, value, unit) rows
  [fhir-flatten-observations (-> analytics? (listof hash?))]))

;; ---- library + raw bindings --------------------------------------------------
(define duck-lib
  (ffi-lib "libduckdb"
           #:fail (lambda () (ffi-lib "/opt/homebrew/opt/duckdb/lib/libduckdb"))))
(define-ffi-definer define-duckdb duck-lib)

(define _duckdb-state _int)                       ; 0 = DuckDBSuccess
(define _idx _uint64)

;; out-parameters are explicit pointer cells (allocated per call) — simplest and safest with _fun
(define-duckdb duckdb_open (_fun _string _pointer ~> _duckdb-state))
(define-duckdb duckdb_connect (_fun _pointer _pointer ~> _duckdb-state))
(define-duckdb duckdb_disconnect (_fun _pointer ~> _void))
(define-duckdb duckdb_close (_fun _pointer ~> _void))
(define-duckdb duckdb_query (_fun _pointer _string _pointer ~> _duckdb-state))
(define-duckdb duckdb_destroy_result (_fun _pointer ~> _void))
(define-duckdb duckdb_column_count (_fun _pointer ~> _idx))
(define-duckdb duckdb_row_count (_fun _pointer ~> _idx))
(define-duckdb duckdb_column_name (_fun _pointer _idx ~> _string))
(define-duckdb duckdb_column_type (_fun _pointer _idx ~> _int))
(define-duckdb duckdb_result_error (_fun _pointer ~> _string))
(define-duckdb duckdb_value_varchar (_fun _pointer _idx _idx ~> _pointer))
(define-duckdb duckdb_value_is_null (_fun _pointer _idx _idx ~> _bool))
(define-duckdb duckdb_free (_fun _pointer ~> _void))

(define DUCKDB-TYPE-BOOLEAN 1)
(define DUCKDB-TYPE-VARCHAR 17)
(define DUCKDB-TYPE-BLOB 18)

;; ---- handle -----------------------------------------------------------------
(struct analytics (db con [open? #:mutable]) #:extra-constructor-name make-analytics)

(define (alloc-ptr-cell) (malloc _pointer 'raw))
(define (result-buffer) (let ([p (malloc 64 'raw)]) (memset p 0 64) p))

(define (open-analytics store #:duckdb [duckdb-path #f])
  ;; NULL path = in-memory DuckDB; a path = a persistent DuckDB database file
  (define db-cell (alloc-ptr-cell))
  (unless (zero? (duckdb_open (and duckdb-path (if (path? duckdb-path)
                                                   (path->string duckdb-path)
                                                   duckdb-path))
                              db-cell))
    (error 'open-analytics "duckdb_open failed"))
  (define db (ptr-ref db-cell _pointer))
  (free db-cell)
  (define con-cell (alloc-ptr-cell))
  (unless (zero? (duckdb_connect db con-cell))
    (duckdb-close-db db)
    (error 'open-analytics "duckdb_connect failed"))
  (define con (ptr-ref con-cell _pointer))
  (free con-cell)
  (define a (make-analytics db con #t))
  (register-finalizer a (lambda (a) (when (analytics-open? a) (close-analytics a))))
  ;; with a store: checkpoint its WAL (so this out-of-process reader sees everything committed)
  ;; and ATTACH it; without one, this session serves the DuckDB side only
  (when store
    (close-fhir-store store)
    (exec! a "INSTALL sqlite")
    (exec! a "LOAD sqlite")
    (exec! a (format "ATTACH '~a' AS fhir (TYPE SQLITE, READ_ONLY)" (fhir-store-path store))))
  a)

(define (close-analytics a)
  (when (analytics-open? a)
    (set-analytics-open?! a #f)
    (define con-cell (alloc-ptr-cell))
    (ptr-set! con-cell _pointer (analytics-con a))
    (duckdb_disconnect con-cell)
    (free con-cell)
    (duckdb-close-db (analytics-db a)))
  (void))
(define (duckdb-close-db db)
  (define db-cell (alloc-ptr-cell))
  (ptr-set! db-cell _pointer db)
  (duckdb_close db-cell)
  (free db-cell))

(define (call-with-analytics store proc #:duckdb [duckdb-path #f])
  (define a (open-analytics store #:duckdb duckdb-path))
  (dynamic-wind void (lambda () (proc a)) (lambda () (close-analytics a))))

;; ---- querying ---------------------------------------------------------------
;; exec! : run a statement for effect (errors carry DuckDB's message)
(define (exec! a sql) (void (fhir-analytics-query a sql)))

(define (fhir-analytics-query a sql)
  (unless (analytics-open? a) (error 'fhir-analytics-query "handle is closed"))
  (define res (result-buffer))
  (dynamic-wind
   void
   (lambda ()
     (define st (duckdb_query (analytics-con a) sql res))
     (unless (zero? st)
       (error 'fhir-analytics-query "~a" (or (duckdb_result_error res) "duckdb error")))
     (define ncol (duckdb_column_count res))
     (define nrow (duckdb_row_count res))
     (define names (for/list ([c (in-range ncol)]) (string->symbol (duckdb_column_name res c))))
     (define types (for/list ([c (in-range ncol)]) (duckdb_column_type res c)))
     (for/list ([r (in-range nrow)])
       (for/hasheq ([name (in-list names)] [ty (in-list types)] [c (in-naturals)])
         (values name (cell-value res c r ty)))))
   (lambda () (duckdb_destroy_result res) (free res))))

;; cell-value : one cell -> jsexpr-ish scalar (via the varchar accessor + the column's type)
(define (cell-value res col row ty)
  (cond
    [(duckdb_value_is_null res col row) 'null]
    [else
     (define p (duckdb_value_varchar res col row))
     (define s (and p (cast p _pointer _string)))
     (when p (duckdb_free p))
     (cond
       [(not s) 'null]
       [(= ty DUCKDB-TYPE-BOOLEAN) (string=? s "true")]
       [(or (= ty DUCKDB-TYPE-VARCHAR) (= ty DUCKDB-TYPE-BLOB)) s]
       [(string->number s) => values]
       [else s])]))

;; ---- SQL-on-FHIR convenience -------------------------------------------------
;; flatten Observation rows straight out of the attached store's raw JSON (DuckDB's json functions)
(define (fhir-flatten-observations a)
  (fhir-analytics-query a
   "SELECT json_extract_string(raw_resource, '$.id')                          AS id,
           json_extract_string(raw_resource, '$.subject.reference')           AS patient,
           json_extract_string(raw_resource, '$.code.coding[0].system')       AS system,
           json_extract_string(raw_resource, '$.code.coding[0].code')         AS code,
           CAST(json_extract(raw_resource, '$.valueQuantity.value') AS DOUBLE) AS value,
           json_extract_string(raw_resource, '$.valueQuantity.unit')          AS unit
    FROM fhir.fhir_resources
    WHERE resource_type = 'Observation'"))

(module+ test
  (require rackunit racket/file)
  ;; pure-DuckDB smoke (no store): arithmetic + types round-trip through the varchar accessor
  (define tmp (make-temporary-file "fhir-analytics-~a.db"))
  (define store (open-fhir-store tmp))
  (define a (open-analytics store))
  (check-equal? (fhir-analytics-query a "SELECT 1 AS one, 'x' AS s, TRUE AS b")
                (list (hasheq 'one 1 's "x" 'b #t)))
  (check-equal? (fhir-analytics-query a "SELECT COUNT(*) AS n FROM fhir.fhir_resources")
                (list (hasheq 'n 0)))
  (close-analytics a)
  (close-fhir-store store)
  (delete-file tmp))
