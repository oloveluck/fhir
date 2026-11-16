#lang racket/base

;;; view-cache.rkt — a view's rows kept between calls.
;;;
;;; SQL over a workspace's ViewDefinitions (run.rkt) ran each view the statement named over the
;;; data, every call: over the MIMIC demo store, 17,552 MedicationRequests read, parsed into typed
;;; nodes and flattened took ~5 s, for a statement SQLite answers in milliseconds — and an agent asks
;;; a view many statements in a row. So a view's rows are written once to a SQLite file of the
;;; workspace's state (`.fhir-mcp/views.db`) and read there in place by the next statements
;;; (sql.rkt's Kept: the file attached, a TEMP view over the table), for as long as their Key holds.
;;;
;;; A Key is a string, the SHA-1 of everything the rows depend on, which the caller states
;;; (run.rkt `view-key`: the view's text, the FHIR version, the data's stamp, the engine's stamp). A
;;; name holds one table: a new key replaces the table of the name. A cache that cannot be written
;;; (a read-only directory, a writer holding the file) is not an error: the rows are answered as
;;; computed, uncached.
;;;
;;; The file's catalogue: kept(name PRIMARY KEY, key, tbl, columns, rows, made).

(require racket/contract racket/file racket/string racket/list json db file/sha1
         (only-in "sql.rkt" table table? table-columns table-rows kept kept? cell-in))

(provide
 (contract-out
  ;; kept-rows : cache-file name key (-> table) -> (or/c kept table)   the rows kept under `name` when
  ;; their key is `key`, else computed, written and answered as kept (or as computed when the file
  ;; cannot be written)
  [kept-rows (-> path-string? string? string? (-> table?) (or/c kept? table?))]
  ;; kept-select : cache-file name key (listof (cons sql-name table-name)) statement -> kept
  ;; a table DEFINED by a statement over tables already kept in the cache file (each named in the
  ;; statement by `sql-name`): computed once inside the file, indexed, and answered as kept
  [kept-select (-> path-string? string? string? (listof (cons/c string? string?)) string? kept?)]
  ;; key-of : any -> string   the SHA-1 of a datum's printed form: a Key from what the rows depend on
  [key-of (-> any/c string?)]))

(define (key-of v) (sha1 (open-input-string (format "~s" v))))

(define (q s) (string-append "\"" (string-replace s "\"" "\"\"") "\""))

;; with-cache : file (connection -> a) -> a   a connection to the cache file (made with its catalogue
;; when absent); a writer elsewhere is waited for a little
(define (with-cache file proc)
  (make-parent-directory* file)
  (define c (sqlite3-connect #:database file #:mode 'create #:busy-retry-limit 50 #:busy-retry-delay 0.1))
  (dynamic-wind
   void
   (lambda ()
     (query-exec c "CREATE TABLE IF NOT EXISTS kept (name TEXT PRIMARY KEY, key TEXT, tbl TEXT, columns TEXT, rows INTEGER, made TEXT)")
     (proc c))
   (lambda () (disconnect c))))

;; held : connection name key -> kept | #f   the name's table when it was made under this key
(define (held c file name key)
  (define row (query-maybe-row c "SELECT tbl, columns FROM kept WHERE name = ? AND key = ?" name key))
  (and row (kept file (vector-ref row 0) (string->jsexpr (vector-ref row 1)))))

(define (kept-rows file name key compute)
  (define (cached) (with-cache file (lambda (c) (held c file name key))))
  (or (with-handlers ([exn:fail? (lambda (_) #f)]) (cached))
      (let ([t (compute)])
        (with-handlers ([exn:fail? (lambda (_) t)])
          (with-cache file (lambda (c) (write-kept! c file name key t)))))))

;; write-kept! : connection file name key table -> kept   the table written as `t_<key>`, in one
;; transaction with the catalogue; the name's earlier table dropped
(define (write-kept! c file name key t)
  (define tbl (string-append "t_" key))
  (define cols (table-columns t))
  (call-with-transaction
   c
   (lambda ()
     (for ([old (in-list (query-list c "SELECT tbl FROM kept WHERE name = ?" name))])
       (query-exec c (format "DROP TABLE IF EXISTS ~a" (q old))))
     (query-exec c (format "DROP TABLE IF EXISTS ~a" (q tbl)))
     (query-exec c (format "CREATE TABLE ~a (~a)" (q tbl)
                           (if (null? cols) "\"\"" (string-join (map q cols) ", "))))
     (unless (null? cols)
       (define insert (prepare c (format "INSERT INTO ~a VALUES (~a)" (q tbl) (string-join (map (lambda (_) "?") cols) ", "))))
       (for ([row (in-list (table-rows t))])
         (apply query-exec c insert (for/list ([col (in-list cols)]) (cell-in (hash-ref row (string->symbol col) 'null))))))
     (query-exec c "INSERT OR REPLACE INTO kept VALUES (?, ?, ?, ?, ?, datetime('now'))"
                 name key tbl (jsexpr->string cols) (length (table-rows t)))))
  (kept file tbl cols))

;; ---- a table defined over kept tables -------------------------------------------------------------
;; A `<name>.sql` table over views (a join, a GROUP BY for a dictionary of items) was a statement run
;; again inside every query that named it: over 668,862 chart events, 0.8 s for the dictionary and
;; as much for the join, per query. Its rows depend only on its statement and on the tables it
;; reads, so they are kept as a view's are; and a table of some size is indexed on its columns —
;; what a query filters it by (`stay_id IN (…) AND itemid IN (…)`) is then a lookup.

;; indexed-from : rows above which a kept table's columns are indexed; indexed-columns : how many
(define indexed-from 2000)
(define indexed-columns 12)

(define (kept-select file name key deps statement)
  (with-cache file
    (lambda (c)
      (or (held c file name key)
          (let ([tbl (string-append "t_" key)])
            (for ([d (in-list deps)])
              (query-exec c (format "CREATE TEMP VIEW ~a AS SELECT * FROM main.~a" (q (car d)) (q (cdr d)))))
            (call-with-transaction
             c
             (lambda ()
               (for ([old (in-list (query-list c "SELECT tbl FROM kept WHERE name = ?" name))])
                 (query-exec c (format "DROP TABLE IF EXISTS main.~a" (q old))))
               (query-exec c (format "DROP TABLE IF EXISTS main.~a" (q tbl)))
               (query-exec c (format "CREATE TABLE main.~a AS ~a" (q tbl) statement))
               (define cols (map (lambda (v) (vector-ref v 1)) (query-rows c (format "PRAGMA main.table_info(~a)" (q tbl)))))
               (define rows (query-value c (format "SELECT COUNT(*) FROM main.~a" (q tbl))))
               (when (>= rows indexed-from)
                 (for ([col (in-list cols)] [i (in-range indexed-columns)])
                   (query-exec c (format "CREATE INDEX main.~a ON ~a (~a)" (q (format "i_~a_~a" key i)) (q tbl) (q col)))))
               (query-exec c "INSERT OR REPLACE INTO kept VALUES (?, ?, ?, ?, ?, datetime('now'))"
                           name key tbl (jsexpr->string cols) rows)
               (kept file tbl cols))))))))

(module+ test
  (require rackunit (only-in "sql.rkt" sql-query kept-name kept-columns))
  (define dir (make-temporary-directory "view-cache-~a"))
  (define file (build-path dir "state" "views.db"))
  (define computed 0)
  (define (meds) (set! computed (add1 computed))
    (table '("id" "drug" "codes") (list (hasheq 'id "a" 'drug "x" 'codes '("1" "2")) (hasheq 'id "b" 'drug 'null 'codes '()))))
  (define k1 (key-of '(view "v1" data 1)))
  ;; computed once, then read from the file
  (define made (kept-rows file "meds" k1 meds))
  (check-true (kept? made))
  (check-equal? (kept-columns made) '("id" "drug" "codes"))
  (check-equal? (kept-name (kept-rows file "meds" k1 meds)) (kept-name made))
  (check-equal? computed 1)
  ;; SQL reads it as it read the table: the same cells (a collection as JSON text, null as NULL)
  (define (rows tables sql) (table-rows (sql-query sql tables)))
  (define direct (hash "meds" (lambda () (meds))))
  (define via (hash "meds" (lambda () (kept-rows file "meds" k1 meds))))
  (for ([s '("SELECT * FROM meds ORDER BY id" "SELECT id FROM meds WHERE drug IS NULL"
             "SELECT count(*) AS n FROM meds, json_each(meds.codes)")])
    (check-equal? (rows via s) (rows direct s) s))
  ;; another key replaces the name's table
  (define k2 (key-of '(view "v1" data 2)))
  (check-not-equal? (kept-name (kept-rows file "meds" k2 meds)) (kept-name made))
  (check-equal? (with-cache file (lambda (c) (query-value c "SELECT count(*) FROM sqlite_master WHERE name LIKE 't_%'"))) 1)
  ;; a cache that cannot be written: the rows as computed
  (define blocked (build-path dir "file-not-dir"))
  (call-with-output-file blocked void)
  (check-true (table? (kept-rows (build-path blocked "views.db") "meds" k1 meds)))
  (delete-directory/files dir))
(module+ test
  ;; a table defined over a kept one: computed once, its columns indexed when it is large
  (define f2 (make-temporary-file "view-cache-select-~a.db"))
  (define big (kept-rows f2 "current big.view.json" "k-big"
                         (lambda () (table '("id" "grp") (for/list ([i (in-range 2500)]) (hasheq 'id i 'grp (modulo i 5)))))))
  (define per (kept-select f2 "sql per.sql" "k-per" (list (cons "big" (kept-name big)))
                           "SELECT grp, COUNT(*) AS n FROM big GROUP BY grp"))
  (check-equal? (kept-columns per) '("grp" "n"))
  (define doubled (kept-select f2 "sql doubled.sql" "k-doubled" (list (cons "big" (kept-name big)))
                               "SELECT id, id * 2 AS twice FROM big"))
  (let ([c (sqlite3-connect #:database f2 #:mode 'read-only)])
    (check-equal? (query-rows c (format "SELECT grp, n FROM ~a ORDER BY grp" (q (kept-name per))))
                  (for/list ([g (in-range 5)]) (vector g 500)))
    (check-equal? (query-value c "SELECT COUNT(*) FROM sqlite_master WHERE type = 'index' AND tbl_name = ?" (kept-name doubled)) 2
                  "2,500 rows: each column indexed")
    (check-equal? (query-value c "SELECT COUNT(*) FROM sqlite_master WHERE type = 'index' AND tbl_name = ?" (kept-name per)) 0
                  "five rows: none")
    (disconnect c))
  ;; asked again under the same key: the same table, not made again; a new key replaces it
  (check-equal? (kept-select f2 "sql per.sql" "k-per" (list (cons "big" (kept-name big))) "SELECT 1 AS never_run") per)
  (define per2 (kept-select f2 "sql per.sql" "k-per2" (list (cons "big" (kept-name big))) "SELECT COUNT(*) AS n FROM big"))
  (let ([c (sqlite3-connect #:database f2 #:mode 'read-only)])
    (check-equal? (query-list c "SELECT tbl FROM kept WHERE name = 'sql per.sql'") (list (kept-name per2)))
    (check-false (query-maybe-value c "SELECT name FROM sqlite_master WHERE name = ?" (kept-name per)) "the earlier table is dropped")
    (disconnect c))
  (delete-file f2))
