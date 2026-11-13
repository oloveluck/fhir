#lang racket/base

;;; bulk.rkt — many resources written as a stream: what a bulk load (.ndjson) does.
;;;
;;; Writing one resource is four pieces of work: read its JSON, stamp its meta and write it out as
;;; the text the store keeps, extract its index rows (a typed parse and a FHIRPath evaluation per
;;; search parameter), and the SQL. Only the SQL needs the store. So the lines of a file go to a
;;; pool of worker processes in chunks; each worker PREPARES its lines — everything but the SQL —
;;; and this process writes what comes back, a transaction per group of chunks, with statements
;;; prepared once and index rows inserted many to a statement. The workers are kept for the whole
;;; load (fhir/parallel's pool) and are told the search catalogue once.
;;;
;;; Before this the load parsed each resource here, wrote it out again for a worker, parsed it
;;; there, started four workers (each loading the type tower) for every 2,000 resources, and made
;;; some thirty SQL statements a resource: 642 resources a second on four cores, where one core
;;; alone managed 1,478.
;;;
;;; What is stored is what `fhir-update!` stores (the same stamped text, hash, version chain and
;;; index rows; `fhir-create!` for a resource without an id): tests/bulk-test.rkt compares the two
;;; stores table by table.
;;;
;;; Data definitions
;;;   An Entries is a hash: resource type (string) -> (listof (list name kind path)), the indexed
;;;     search parameters of each type — the catalogue as a worker is told it.
;;;   A Chunk — what a worker is handed — is one of
;;;     (list now bytes)          whole ndjson lines as they are in the file (UTF-8, a newline
;;;                               between them) to prepare, and the instant they are written at.
;;;                               The lines are not split here: this process hands the file's
;;;                               bytes on and the workers find the lines.
;;;     (list 'index (listof json-text))   stored resources whose index rows are wanted again
;;;                               (reindex!): the answer is each one's rows.
;;;   A Prepared is (list type id text sha1 rows now) — a resource ready to write as version 1: the
;;;     stored JSON text (meta stamped at `now`), its SHA-1, and its index rows (name table
;;;     values) — or #f for a line that is not a resource.

(require racket/contract racket/list racket/string racket/match json db
         (only-in file/sha1 sha1)
         (only-in fhir/parallel make-worker-pool pool-map close-worker-pool pool?)
         "fhir-sqlite.rkt" "fhir-engine.rkt"
         (only-in "search-index.rkt" index-tables))

(provide
 (contract-out
  ;; a loader holds the workers of one load; close it when the load is done
  [make-bulk-loader (-> hash? (or/c module-path? #f) bulk-loader?)]
  [close-bulk-loader (-> bulk-loader? void?)]
  [bulk-loader? (-> any/c boolean?)]
  ;; every resource of each source of ndjson lines, written; how many of each. A source is a
  ;; procedure that calls its argument with the open port (the file's, gunzipped or not)
  [bulk-load! (-> bulk-loader? fhir-store? (listof (-> (-> input-port? any) any)) (listof exact-nonnegative-integer?))]
  ;; the worker's function: told the Entries, it prepares chunks
  [prepare-chunks (-> hash? (-> list? list?))]
  ;; catalog -> Entries
  [catalog-entries (-> hash? hash?)]
  ;; every stored resource's index rows extracted again, and the indexes replaced by them — after
  ;; the catalogue changed (a guide's search parameters), or the way values are indexed did; how
  ;; many resources. One transaction: a reindex that fails leaves the indexes as they were.
  [reindex! (-> bulk-loader? fhir-store? exact-nonnegative-integer?)]))

;; ---- preparing (a worker's part; no store) ------------------------------------------------------
;; catalog-entries : catalog -> Entries
(define (catalog-entries sps)
  (for/hash ([type (in-hash-keys sps)])
    (values (symbol->string type) (indexed-entries sps (symbol->string type)))))

;; prepare-chunks : Entries -> (Chunk -> (listof Prepared|#f) | (listof rows))
(define ((prepare-chunks entries) chunk)
  (match chunk
    [(list 'index texts)
     (for/list ([text (in-list texts)])
       (define js (string->jsexpr text))
       (index-rows js (hash-ref entries (hash-ref js 'resourceType "") '())))]
    [(list now lines)
     (for/list ([line (in-list (regexp-split #rx#"\r?\n" lines))])
       (prepare-line line now entries))]))

;; prepare-line : bytes instant Entries -> Prepared | #f
(define (prepare-line line now entries)
  (define js (and (regexp-match? #rx#"^[ \t]*{" line)
                  (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr line))))
  (and (hash? js)
       (string? (hash-ref js 'resourceType #f))
       (let* ([type (hash-ref js 'resourceType)]
              [id (let ([i (hash-ref js 'id #f)]) (if (string? i) i (fresh-id)))]
              [stored (stamp-meta (hash-set js 'id id) 1 now)]
              [text (jsexpr->string stored)])
         (list type id text (text-sha1 text) (index-rows stored (hash-ref entries type '())) now))))

(define (text-sha1 text) (sha1 (open-input-bytes (string->bytes/utf-8 text))))

;; ---- the loader -------------------------------------------------------------------------------
;; A BulkLoader is (bulk-loader pool): the workers that prepare.
(struct bulk-loader (pool))

(define prepare-fn '(fhir/store/bulk prepare-chunks))

;; make-bulk-loader : catalog tower -> BulkLoader   the workers started, each told the catalogue.
;; Without a tower the resources are prepared in this process (a worker could not type them).
(define (make-bulk-loader sps tower)
  (define entries (catalog-entries sps))
  (bulk-loader (if tower
                   (make-worker-pool prepare-fn #:setup tower #:init entries)
                   (make-worker-pool prepare-fn #:workers 1 #:init entries))))

(define (close-bulk-loader l) (close-worker-pool (bulk-loader-pool l)))

;; bytes to a chunk, chunks to a group: a chunk is what one worker prepares at a time (small
;; enough that the workers finish together), a group what one transaction writes
(define chunk-bytes (* 256 1024))
(define group-chunks 8)

;; read-chunk : input-port -> bytes | eof   about chunk-bytes of the port, to the end of a line
(define (read-chunk in)
  (define block (read-bytes chunk-bytes in))
  (cond [(eof-object? block) eof]
        [(eqv? (bytes-ref block (sub1 (bytes-length block))) 10) block]
        [else (define rest (read-bytes-line in 'linefeed))
              (if (eof-object? rest) block (bytes-append block rest))]))

;; read-group : input-port -> (listof Chunk)   up to group-chunks chunks; '() at the end
(define (read-group in)
  (define now (now-iso))
  (let loop ([acc '()] [k 0])
    (define block (if (= k group-chunks) eof (read-chunk in)))
    (if (eof-object? block) (reverse acc) (loop (cons (list now block) acc) (add1 k)))))

;; bulk-load! : BulkLoader store (listof Source) -> (listof count)   one count per source
;; Groups are prepared ahead of the writes, across the sources: while this process is in SQLite
;; for one group, the workers prepare the next — the next file's first, when a file ends (a
;; thread reads and hands the prepared groups over, one waiting at most).
(define (bulk-load! l store sources)
  (define ready (make-channel))                      ; (cons source-index (listof Prepared)) | 'done
  (define failure #f)
  (define producer
    (thread
     (lambda ()
       (with-handlers ([(lambda (_) #t) (lambda (e) (set! failure e))])
         (for ([source (in-list sources)] [i (in-naturals)])
           (source
            (lambda (in)
              (let loop ()
                (define group (read-group in))
                (unless (null? group)
                  (channel-put ready (cons i (filter values (append* (pool-map (bulk-loader-pool l) group)))))
                  (loop)))))))
       (channel-put ready 'done))))
  (define counts (make-vector (length sources) 0))
  (dynamic-wind
   void
   (lambda ()
     (call-with-bulk-connection store
       (lambda (c indexes)
         (let loop ()
           (define next (channel-get ready))
           (cond
             [(eq? next 'done) (when failure (raise failure))]
             [else
              (call-with-transaction c (lambda () (write-prepared! c (cdr next) indexes)))
              (vector-set! counts (car next) (+ (vector-ref counts (car next)) (length (cdr next))))
              (loop)])))))
   (lambda () (kill-thread producer)))
  (vector->list counts))

;; ---- the connection of a bulk load --------------------------------------------------------------
;; A bulk load holds one connection, set for writing much: a page cache that holds the indexes
;; it is writing into (SQLite's default is 2 MB), and checkpoints of the write-ahead log when it
;; has grown, not every few megabytes. Into a store that holds NOTHING yet, two things more:
;; the search indexes are built once at the end, sorted, instead of kept in order row by row
;; (Indexes, below), and the file is not synced on the way (a machine that loses power in the
;; middle of filling an empty store has lost a load to run again, nothing that was there).
;; Everything is put back when the load ends, however it ends; a process killed in the middle
;; leaves a store whose indexes are made when it is next opened (the schema's IF NOT EXISTS).
;;
;; An Indexes is (indexes (listof (cons name create-sql)) dropped?): the search indexes of the
;; index tables, and whether they are dropped for now.
(struct indexes (definitions [dropped? #:mutable]))

;; call-with-bulk-connection : store (connection Indexes -> a) -> a
(define (call-with-bulk-connection store proc)
  (call-with-store-connection store
    (lambda (c)
      (define empty? (not (query-maybe-value c "SELECT 1 FROM fhir_resources LIMIT 1")))
      (define ix (search-indexes c))
      (dynamic-wind
       (lambda ()
         (query c "PRAGMA cache_size=-262144")
         (query c "PRAGMA wal_autocheckpoint=50000")
         (when empty?
           (query c "PRAGMA synchronous=OFF")
           (drop-indexes! c ix)))
       (lambda () (proc c ix))
       (lambda ()
         (restore-indexes! c ix)
         (query c "PRAGMA synchronous=NORMAL")
         (query c "PRAGMA wal_autocheckpoint=1000")
         (query c "PRAGMA cache_size=-2000")
         (query c "PRAGMA wal_checkpoint(TRUNCATE)"))))))

;; search-indexes : connection -> Indexes   the indexes of the index tables, as the schema made them
(define (search-indexes c)
  (indexes (for/list ([r (in-list (query-rows c "SELECT name, sql FROM sqlite_master WHERE type='index' AND sql IS NOT NULL AND tbl_name LIKE 'fhir!_%!_index' ESCAPE '!'"))])
             (cons (vector-ref r 0) (vector-ref r 1)))
           #f))

(define (drop-indexes! c ix)
  (for ([d (in-list (indexes-definitions ix))]) (query-exec c (string-append "DROP INDEX IF EXISTS " (car d))))
  (set-indexes-dropped?! ix #t))

;; restore-indexes! : connection Indexes -> Void   the dropped indexes made again (nothing to do
;; when they are there)
(define (restore-indexes! c ix)
  (when (indexes-dropped? ix)
    (for ([d (in-list (indexes-definitions ix))]) (query-exec c (cdr d)))
    (set-indexes-dropped?! ix #f)))

;; ---- reindexing --------------------------------------------------------------------------------
;; reindex! : BulkLoader store -> count
;; The index tables are emptied and filled again from the stored resources, a page at a time:
;; the workers extract a page's rows while nothing else waits on this process. The search indexes
;; are dropped for the fill and built at its end, all inside one transaction.
(define reindex-page 2000)
(define (reindex! l store)
  (call-with-store-connection store
    (lambda (c)
      (define ix (search-indexes c))
      (dynamic-wind
       (lambda () (query c "PRAGMA cache_size=-262144"))
       (lambda ()
         (call-with-transaction c
           (lambda ()
             (drop-indexes! c ix)
             (for ([t (in-list index-tables)]) (query-exec c (string-append "DELETE FROM " (car t))))
             (define pending (make-hash))
             (define total
               (let loop ([after 0] [total 0])
                 (define page (query-rows c "SELECT rowid, resource_type, id, json(resource) FROM fhir_resources WHERE rowid > ? ORDER BY rowid LIMIT ?"
                                          after reindex-page))
                 (cond
                   [(null? page) total]
                   [else
                    (define jobs (for/list ([part (in-list (in-parts page chunk-resources))])
                                   (list 'index (for/list ([r (in-list part)]) (vector-ref r 3)))))
                    (for ([r (in-list page)] [rows (in-list (append* (pool-map (bulk-loader-pool l) jobs)))])
                      (queue-rows! pending (vector-ref r 1) (vector-ref r 2) rows))
                    (flush-rows! c pending)
                    (loop (vector-ref (last page) 0) (+ total (length page)))])))
             (restore-indexes! c ix)
             total)))
       (lambda ()
         (query c "PRAGMA cache_size=-2000")
         (query c "PRAGMA wal_checkpoint(TRUNCATE)"))))))

;; resources to a reindexing chunk
(define chunk-resources 250)
;; in-parts : list n -> (listof list)   the list in runs of n
(define (in-parts xs n)
  (if (<= (length xs) n) (list xs) (let-values ([(a b) (split-at xs n)]) (cons a (in-parts b n)))))

;; ---- writing (this process; the store) ----------------------------------------------------------
(define insert-current
  "INSERT INTO fhir_resources (resource_type,id,version_id,last_updated,resource) VALUES (?,?,?,?,jsonb(?))
   ON CONFLICT(resource_type,id) DO UPDATE SET version_id=excluded.version_id, last_updated=excluded.last_updated, resource=excluded.resource")
(define insert-history
  "INSERT INTO fhir_history (resource_type,id,version_id,last_updated,content_hash,resource) VALUES (?,?,?,?,?,jsonb(?))")
(define select-version
  "SELECT MAX(version_id) FROM fhir_history WHERE resource_type=? AND id=?")

;; rows-per-statement : how many index rows one INSERT carries
(define rows-per-statement 24)

;; insert-rows-sql : table Nat -> string   an INSERT of n rows into an index table
(define (insert-rows-sql table n)
  (define cols (cdr (assoc table index-tables)))
  (define one (string-append "(?,?,?" (apply string-append (for/list ([_ (in-list cols)]) ",?")) ")"))
  (format "INSERT INTO ~a (resource_type,resource_id,param_name,~a) VALUES ~a"
          table (string-join (map symbol->string cols) ",") (string-join (for/list ([_ (in-range n)]) one) ",")))

;; write-prepared! : connection (listof Prepared) Indexes -> Void   inside the caller's transaction
(define (write-prepared! c prepared ix)
  (define current (prepare c insert-current))
  (define history (prepare c insert-history))
  (define version (prepare c select-version))
  (define pending (make-hash))                         ; table -> (listof argument-list), newest first
  (for ([p (in-list prepared)])
    (define-values (type id text hash rows now) (apply values p))
    (define prev (query-maybe-value c version type id))
    (define-values (vid text* hash*)
      (if (exact-integer? prev)
          (restamped text (add1 prev) now)
          (values 1 text hash)))
    (query-exec c current type id vid now text*)
    (query-exec c history type id vid now hash* text*)
    ;; a resource stored before has index rows to replace (queued ones included: an id that comes
    ;; twice in one group); a new one has none
    (when (exact-integer? prev)
      (restore-indexes! c ix)                           ; the rows to replace are found by index
      (flush-rows! c pending)
      (for ([t (in-list index-tables)])
        (query-exec c (string-append "DELETE FROM " (car t) " WHERE resource_type=? AND resource_id=?") type id)))
    (queue-rows! pending type id rows))
  (flush-rows! c pending))

;; queue-rows! : (hash table -> rows) type id (listof IndexRow) -> Void   a resource's index rows,
;; queued for flush-rows!
(define (queue-rows! pending type id rows)
  (for ([row (in-list rows)])
    (hash-update! pending (cadr row)
                  (lambda (acc) (cons (list* type id (car row) (map (lambda (v) (or v sql-null)) (caddr row))) acc))
                  '())))

;; flush-rows! : connection (hash table -> rows) -> Void   every queued index row inserted, many
;; to a statement, and the queue emptied
(define (flush-rows! c pending)
  (for ([(table rows) (in-hash pending)])
    (define many (prepare c (insert-rows-sql table rows-per-statement)))
    (define one (prepare c (insert-rows-sql table 1)))
    (let loop ([rows (reverse rows)] [n (length rows)])
      (cond [(>= n rows-per-statement)
             (define-values (now later) (split-at rows rows-per-statement))
             (apply query-exec c many (append* now))
             (loop later (- n rows-per-statement))]
            [else (for ([r (in-list rows)]) (apply query-exec c one r))])))
  (hash-clear! pending))

;; restamped : text version instant -> (values version text sha1)   the prepared text (stamped as
;; version 1) stamped as the version it turns out to be: its id was stored before
(define (restamped text vid now)
  (define text* (jsexpr->string (stamp-meta (string->jsexpr text) vid now)))
  (values vid text* (text-sha1 text*)))

;; for a benchmark that times the writes alone
(module+ internals (provide write-prepared!))

(module+ test
  (require rackunit)
  (define entries (hash "Patient" '(("gender" token "Patient.gender"))))
  (define prep (prepare-chunks entries))
  ;; a line that is a resource is prepared; anything else is #f
  (define out (prep (list "2026-01-01T00:00:00Z"
                          #"{\"resourceType\":\"Patient\",\"id\":\"a\",\"gender\":\"female\"}\n\r\nnot json\n[1]")))
  (check-equal? (map (lambda (p) (and p (take p 2))) out) '(("Patient" "a") #f #f #f))
  (check-equal? (hash-ref (hash-ref (string->jsexpr (caddr (car out))) 'meta) 'versionId) "1")
  (check-equal? (last (car out)) "2026-01-01T00:00:00Z")
  ;; a resource without an id is given one
  (check-true (string? (cadr (car (prep (list "2026-01-01T00:00:00Z" #"{\"resourceType\":\"Patient\"}"))))))
  ;; a chunk ends at the end of a line, wherever the block of bytes ended
  (let ([in (open-input-bytes (bytes-append (make-bytes chunk-bytes 97) #"bcd\nsecond\n"))])
    (check-equal? (bytes-length (read-chunk in)) (+ chunk-bytes 3))
    (check-equal? (read-chunk in) #"second\n")
    (check-true (eof-object? (read-chunk in))))
  ;; an INSERT of n rows names the table's columns once and carries n row tuples
  (check-equal? (insert-rows-sql "fhir_date_index" 2)
                "INSERT INTO fhir_date_index (resource_type,resource_id,param_name,low,high) VALUES (?,?,?,?,?),(?,?,?,?,?)")
  ;; restamping keeps the instant and moves the version
  (define-values (vid text sha) (restamped (caddr (car out)) 3 "2026-01-01T00:00:00Z"))
  (check-equal? (hash-ref (string->jsexpr text) 'meta) (hasheq 'versionId "3" 'lastUpdated "2026-01-01T00:00:00Z")))
