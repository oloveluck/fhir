#lang racket/base

;;; fhir-sqlite.rkt — the transactional FHIR store: SQLite schema + connection pool.
;;;
;;; A Store is (fhir-store path pool): `path` is the SQLite file (shared read-only with DuckDB via
;;; sqlite_scanner — see fhir-analytics.rkt), `pool` a db-lib connection-pool whose connections are
;;; configured for WAL (readers don't block the writer; DuckDB attaches concurrently).
;;;
;;; Schema (see the module body; created idempotently on open):
;;;   fhir_resources       — the CURRENT version of every resource: (resource_type, id) PK,
;;;                          version_id, last_updated (ISO-8601 UTC), raw_resource (JSON text)
;;;   fhir_history         — immutable version history: + content_hash (SHA-1 of the JSON text)
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
  [open-fhir-store  (->* (path-string?) (#:max-connections exact-positive-integer?) fhir-store?)]
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

(define (open-fhir-store path #:max-connections [max-conn 8])
  (define pool
    (connection-pool
     (lambda () (configure! (sqlite3-connect #:database path #:mode 'create #:busy-retry-limit 20)))
     #:max-connections max-conn))
  (define store (fhir-store path pool))
  (call-with-store-connection store ensure-schema!)
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
      raw_resource  TEXT NOT NULL,
      PRIMARY KEY (resource_type, id))"
   "CREATE TABLE IF NOT EXISTS fhir_history (
      resource_type TEXT NOT NULL,
      id            TEXT NOT NULL,
      version_id    INTEGER NOT NULL,
      last_updated  TEXT NOT NULL,
      content_hash  TEXT NOT NULL,
      raw_resource  TEXT NOT NULL,
      PRIMARY KEY (resource_type, id, version_id))"
   "CREATE TABLE IF NOT EXISTS fhir_token_index (
      resource_type TEXT NOT NULL,
      resource_id   TEXT NOT NULL,
      param_name    TEXT NOT NULL,
      system        TEXT,
      code          TEXT NOT NULL)"
   "CREATE INDEX IF NOT EXISTS idx_token_lookup
      ON fhir_token_index (resource_type, param_name, code, system)"
   "CREATE INDEX IF NOT EXISTS idx_token_owner
      ON fhir_token_index (resource_type, resource_id)"
   "CREATE TABLE IF NOT EXISTS fhir_reference_index (
      resource_type TEXT NOT NULL,
      resource_id   TEXT NOT NULL,
      param_name    TEXT NOT NULL,
      target_type   TEXT,
      target_id     TEXT NOT NULL)"
   "CREATE INDEX IF NOT EXISTS idx_ref_lookup
      ON fhir_reference_index (resource_type, param_name, target_type, target_id)"
   "CREATE INDEX IF NOT EXISTS idx_ref_owner
      ON fhir_reference_index (resource_type, resource_id)"))

(define (ensure-schema! c)
  (for ([stmt (in-list schema-statements)]) (query-exec c stmt)))

(module+ test
  (require rackunit racket/file)
  (define tmp (make-temporary-file "fhir-store-~a.db"))
  (define store (open-fhir-store tmp))
  ;; WAL is active on pooled connections
  (check-equal? (call-with-store-connection store
                  (lambda (c) (query-value c "PRAGMA journal_mode")))
                "wal")
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
