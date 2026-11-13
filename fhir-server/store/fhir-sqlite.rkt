#lang racket/base

;;; fhir-sqlite.rkt — the transactional FHIR store: SQLite schema + connection pool.
;;;
;;; A Store is (fhir-store path pool): `path` is the SQLite file, `pool` a db-lib connection-pool
;;; whose connections are configured for WAL (readers don't block the writer).
;;;
;;; Schema (see the module body; created idempotently on open):
;;;   fhir_resources       — the CURRENT version of every resource: (resource_type, id) PK,
;;;                          version_id, last_updated (ISO-8601 UTC), resource (SQLite JSONB: written
;;;                          with jsonb(?), read with json(resource); SQL reads it in place with
;;;                          `resource ->> '$.gender'`, json_extract, json_each)
;;;   fhir_history         — immutable version history: + content_hash (SHA-1 of the JSON text)
;;; A store written before JSONB (a `raw_resource` TEXT column) is migrated when it opens.
;;;   fhir_token_index     — search-param token index: param_name, system, code
;;;   fhir_reference_index — search-param reference index: param_name, target_type, target_id
;;; Indexes cover the search access paths (token by param/system/code; reference by param/target).
;;;
;;; No global state: every operation takes the store explicitly. All writes happen inside
;;; call-with-store-transaction (db-lib's call-with-transaction on a leased connection).

(require racket/contract
         db)

(provide
 (contract-out
  [struct fhir-store ([path path-string?] [pool connection-pool?])]
  ;; #:lazy? #t: nothing touches the file until the store is first used (`racket app.rkt`, which only
  ;; prints a capability app's statement, created the app's store beside it)
  [open-fhir-store  (->* (path-string?) (#:max-connections exact-positive-integer? #:lazy? any/c) fhir-store?)]
  [close-fhir-store (-> fhir-store? void?)]
  ;; lease a connection for the extent of `proc` (returns its result)
  [call-with-store-connection  (-> fhir-store? (-> connection? any) any)]
  ;; lease + wrap in a transaction (the ONLY sanctioned way to write)
  [call-with-store-transaction (-> fhir-store? (-> connection? any) any)]))

(struct fhir-store (path pool) #:transparent)

;; every pooled connection gets WAL + NORMAL sync (durable enough for an app store, much faster)
(define (configure! c)
  (query-exec c "PRAGMA journal_mode=WAL")
  (query-exec c "PRAGMA synchronous=NORMAL")
  (query-exec c "PRAGMA foreign_keys=ON")
  c)

(define (open-fhir-store path #:max-connections [max-conn 8] #:lazy? [lazy? #f])
  ;; lazily, the schema is made by the first connection the pool opens (once, under a lock)
  (define schema-ready? (not lazy?))
  (define lock (make-semaphore 1))
  (define (connect)
    (define c (configure! (sqlite3-connect #:database path #:mode 'create #:busy-retry-limit 20)))
    (unless schema-ready?
      (call-with-semaphore lock (lambda () (unless schema-ready? (ensure-schema! c) (set! schema-ready? #t)))))
    c)
  (define pool (connection-pool connect #:max-connections max-conn))
  (define store (fhir-store path pool))
  (unless lazy? (call-with-store-connection store ensure-schema!))
  store)

(define (close-fhir-store store)
  ;; db-lib pools close leased connections on custodian shutdown; nothing further is required,
  ;; but we checkpoint so the WAL is folded into the main file for external readers.
  (call-with-store-connection store
    (lambda (c) (query-exec c "PRAGMA wal_checkpoint(TRUNCATE)")))
  (void))

(define (call-with-store-connection store proc)
  (define c (connection-pool-lease (fhir-store-pool store)))
  (dynamic-wind void (lambda () (proc c)) (lambda () (disconnect c))))

(define (call-with-store-transaction store proc)
  (call-with-store-connection store
    (lambda (c) (call-with-transaction c (lambda () (proc c))))))

;; ---- schema -----------------------------------------------------------------
(define schema-statements
  (list
   "CREATE TABLE IF NOT EXISTS fhir_resources (
      resource_type TEXT NOT NULL,
      id            TEXT NOT NULL,
      version_id    INTEGER NOT NULL,
      last_updated  TEXT NOT NULL,
      resource      BLOB NOT NULL,
      PRIMARY KEY (resource_type, id))"
   "CREATE TABLE IF NOT EXISTS fhir_history (
      resource_type TEXT NOT NULL,
      id            TEXT NOT NULL,
      version_id    INTEGER NOT NULL,
      last_updated  TEXT NOT NULL,
      content_hash  TEXT NOT NULL,
      resource      BLOB NOT NULL,
      PRIMARY KEY (resource_type, id, version_id))"
   "CREATE TABLE IF NOT EXISTS fhir_token_index (
      resource_type TEXT NOT NULL,
      resource_id   TEXT NOT NULL,
      param_name    TEXT NOT NULL,
      system        TEXT,
      code          TEXT NOT NULL)"
   ;; Each index table has two indexes. `find`: the rows of a value, WITH the resource's id, so a
   ;; search reads the ids it is after from the index alone (without the id every match was a row
   ;; fetched: a page of a patient's 48,000 observations took 58 ms, and takes 12). `owner`: a
   ;; resource's own rows (replaced when it is written, asked when a search checks a candidate).
   "CREATE INDEX IF NOT EXISTS idx_token_find
      ON fhir_token_index (resource_type, param_name, code, system, resource_id)"
   "CREATE INDEX IF NOT EXISTS idx_token_owner
      ON fhir_token_index (resource_type, resource_id)"
   "CREATE TABLE IF NOT EXISTS fhir_reference_index (
      resource_type TEXT NOT NULL,
      resource_id   TEXT NOT NULL,
      param_name    TEXT NOT NULL,
      target_type   TEXT,
      target_id     TEXT NOT NULL)"
   "CREATE INDEX IF NOT EXISTS idx_ref_find
      ON fhir_reference_index (resource_type, param_name, target_type, target_id, resource_id)"
   "CREATE INDEX IF NOT EXISTS idx_ref_owner
      ON fhir_reference_index (resource_type, resource_id)"
   ;; string params: value_norm is case/accent-folded (default + :contains), value_exact for :exact
   "CREATE TABLE IF NOT EXISTS fhir_string_index (
      resource_type TEXT NOT NULL, resource_id TEXT NOT NULL, param_name TEXT NOT NULL,
      value_norm TEXT NOT NULL, value_exact TEXT NOT NULL)"
   "CREATE INDEX IF NOT EXISTS idx_string_find ON fhir_string_index (resource_type, param_name, value_norm, resource_id)"
   "CREATE INDEX IF NOT EXISTS idx_string_owner ON fhir_string_index (resource_type, resource_id)"
   ;; date params: every value is a RANGE [low, high], full-precision ISO text (compares lexically)
   "CREATE TABLE IF NOT EXISTS fhir_date_index (
      resource_type TEXT NOT NULL, resource_id TEXT NOT NULL, param_name TEXT NOT NULL,
      low TEXT NOT NULL, high TEXT NOT NULL)"
   "CREATE INDEX IF NOT EXISTS idx_date_find ON fhir_date_index (resource_type, param_name, low, high, resource_id)"
   ;; a resource's dates WITH their values: what a sort by date and a date condition asked of a
   ;; candidate read, per resource, without fetching the rows ("the latest", "from a date on")
   "CREATE INDEX IF NOT EXISTS idx_date_own ON fhir_date_index (resource_type, resource_id, param_name, low, high)"
   "CREATE TABLE IF NOT EXISTS fhir_number_index (
      resource_type TEXT NOT NULL, resource_id TEXT NOT NULL, param_name TEXT NOT NULL,
      value REAL NOT NULL)"
   "CREATE INDEX IF NOT EXISTS idx_number_owner ON fhir_number_index (resource_type, resource_id)"
   "CREATE TABLE IF NOT EXISTS fhir_quantity_index (
      resource_type TEXT NOT NULL, resource_id TEXT NOT NULL, param_name TEXT NOT NULL,
      value REAL NOT NULL, system TEXT, code TEXT)"
   "CREATE INDEX IF NOT EXISTS idx_quantity_owner ON fhir_quantity_index (resource_type, resource_id)"
   "CREATE INDEX IF NOT EXISTS idx_number_find ON fhir_number_index (resource_type, param_name, value, resource_id)"
   "CREATE INDEX IF NOT EXISTS idx_quantity_find ON fhir_quantity_index (resource_type, param_name, value, resource_id)"
   ;; the indexes `find` replaces (a store made before them drops these when it is opened)
   "DROP INDEX IF EXISTS idx_date_owner"
   "DROP INDEX IF EXISTS idx_token_lookup"
   "DROP INDEX IF EXISTS idx_ref_lookup"
   "DROP INDEX IF EXISTS idx_string_lookup"
   "DROP INDEX IF EXISTS idx_date_lookup"
   "DROP INDEX IF EXISTS idx_number_lookup"
   "DROP INDEX IF EXISTS idx_quantity_lookup"))

(define (ensure-schema! c)
  (for ([stmt (in-list schema-statements)]) (query-exec c stmt))
  (migrate-to-jsonb! c))

;; migrate-to-jsonb! : connection -> void   a table that still holds `raw_resource` JSON text gets
;; its `resource` JSONB column filled from it, and the text column dropped
(define (migrate-to-jsonb! c)
  (for ([t (in-list '("fhir_resources" "fhir_history"))])
    (define cols (query-list c (format "SELECT name FROM pragma_table_info('~a')" t)))
    (when (member "raw_resource" cols)
      (call-with-transaction c
        (lambda ()
          (unless (member "resource" cols) (query-exec c (format "ALTER TABLE ~a ADD COLUMN resource BLOB" t)))
          (query-exec c (format "UPDATE ~a SET resource = jsonb(raw_resource)" t))
          (query-exec c (format "ALTER TABLE ~a DROP COLUMN raw_resource" t)))))))

(module+ test
  (require rackunit racket/file)
  (define tmp (make-temporary-file "fhir-store-~a.db"))
  (define store (open-fhir-store tmp))
  ;; WAL is active on pooled connections
  (check-equal? (call-with-store-connection store
                  (lambda (c) (query-value c "PRAGMA journal_mode")))
                "wal")
  ;; a store written with JSON text is migrated to JSONB when it opens
  (define old (make-temporary-file "fhir-store-old-~a.db"))
  (let ([c (sqlite3-connect #:database old)])
    (query-exec c "CREATE TABLE fhir_resources (resource_type TEXT NOT NULL, id TEXT NOT NULL, version_id INTEGER NOT NULL, last_updated TEXT NOT NULL, raw_resource TEXT NOT NULL, PRIMARY KEY (resource_type, id))")
    (query-exec c "INSERT INTO fhir_resources VALUES ('Patient', 'p1', 1, '2025-01-01T00:00:00Z', '{\"resourceType\":\"Patient\",\"id\":\"p1\",\"gender\":\"female\"}')")
    (disconnect c))
  (define migrated (open-fhir-store old))
  (check-equal? (call-with-store-connection migrated
                  (lambda (c) (list (query-value c "SELECT resource ->> '$.gender' FROM fhir_resources")
                                    (query-value c "SELECT typeof(resource) FROM fhir_resources")
                                    (query-list c "SELECT name FROM pragma_table_info('fhir_resources') WHERE name = 'raw_resource'"))))
                '("female" "blob" ()))
  (delete-file old)
  ;; schema exists and is idempotent
  (check-not-exn (lambda () (call-with-store-connection store ensure-schema!)))
  (check-equal? (call-with-store-connection store
                  (lambda (c) (query-value c "SELECT count(*) FROM fhir_resources")))
                0)
  ;; transactions roll back on error
  (check-exn exn:fail?
             (lambda ()
               (call-with-store-transaction store
                 (lambda (c)
                   (query-exec c "INSERT INTO fhir_resources VALUES ('Patient','x',1,'t','{}')")
                   (error 'boom)))))
  (check-equal? (call-with-store-connection store
                  (lambda (c) (query-value c "SELECT count(*) FROM fhir_resources")))
                0)
  (close-fhir-store store)
  (delete-file tmp))
