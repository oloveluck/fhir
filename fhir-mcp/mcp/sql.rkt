#lang racket/base

;;; sql.rkt — SQL over tables of FHIR data: the analysis step after a ViewDefinition has flattened
;;; resources into rows. The tables live in an in-memory SQLite database made for the one query and
;;; dropped after it; only a reading statement runs (SELECT, WITH or VALUES), so nothing is written
;;; anywhere. Over a FHIR store (#:database, fhir-server's SQLite file) the query runs on a READ-ONLY
;;; connection to the store itself: the tables become TEMP tables there, and every resource type
;;; stored is a TEMP view `"<Type>"(id, versionId, lastUpdated, resource)`, plus `resources(type, …)`
;;; and `history(type, id, versionId, lastUpdated, resource)` (every version ever written),
;;; whose `resource` is the stored JSONB — `resource ->> '$.gender'`, `json_each(resource, '$.name')`.
;;; A JSONB cell in the answer is rendered as its JSON text.
;;;
;;; A Table is (table columns rows): columns (listof string), rows (listof (hash column-symbol ->
;;; jsexpr)). A cell that is a JSON array or object (a collection column) is stored as its JSON text,
;;; a boolean as 1/0, null as NULL. Tables are given as thunks, so only the ones a query names are
;;; computed.

(require racket/contract racket/list racket/string racket/file json db (only-in fhir/suggest did-you-mean))

(provide
 (struct-out table)
 (contract-out
  ;; sql-query : sql (hash name -> (-> table)) [#:database store-file] -> table   the statement's answer
  [sql-query (->* (string? (hash/c string? procedure?)) (#:database (or/c path-string? #f)) table?)]
  ;; tables-named : sql (listof name) -> (listof name)   the names the statement mentions
  [tables-named (-> string? (listof string?) (listof string?))]
  ;; history-resources : store-file type -> (listof jsexpr)   every version of every resource of the
  ;; type, oldest first (meta.versionId says which), read-only
  [history-resources (-> path-string? string? (listof hash?))]))

(define (history-resources store type)
  (define c (sqlite3-connect #:database store #:mode 'read-only))
  (dynamic-wind void
                (lambda () (for/list ([t (in-list (query-list c "SELECT json(resource) FROM fhir_history WHERE resource_type = ? ORDER BY id, version_id" type))])
                             (string->jsexpr t)))
                (lambda () (disconnect c))))

(struct table (columns rows) #:transparent)

(define (tables-named sql names)
  (for/list ([n (in-list names)]
             #:when (regexp-match? (pregexp (string-append "(?i:(?<![A-Za-z0-9_])\"?" (regexp-quote n) "\"?(?![A-Za-z0-9_]))")) sql))
    n))

;; reading? : sql -> boolean   one statement that reads
(define (reading? sql)
  (define s (string-trim (regexp-replace #px";\\s*$" (string-trim sql) "")))
  (and (regexp-match? #px"(?i:^(select|with|values)\\b)" s)
       (not (regexp-match? #px";" (regexp-replace* #px"'(?:[^']|'')*'" s "")))))

(define (sql-query sql tables #:database [store #f])
  (unless (reading? sql)
    (raise-user-error 'sql "one SELECT (or WITH … SELECT) statement over the views' tables"))
  (define c (if store (sqlite3-connect #:database store #:mode 'read-only) (sqlite3-connect #:database 'memory)))
  (dynamic-wind
   void
   (lambda ()
     (define types (if store (store-views! c (hash-keys tables)) '()))
     (define names (tables-named sql (hash-keys tables)))
     (when (and (null? names) (null? (tables-named sql types)))
       (raise-user-error 'sql (format "the statement names none of the tables: ~a" (string-join (sort (append (hash-keys tables) types) string<?) ", "))))
     (for ([n (in-list names)]) (load-table! c n ((hash-ref tables n)) #:temp? (and store #t)))
     (define named (remove-duplicates (append names (tables-named sql (append types '("resources" "history"))))))
     (define r (with-handlers ([exn:fail:sql? (lambda (e) (raise-user-error 'sql (with-columns (sql-message e) c named)))])
                 (query c (regexp-replace #px";\\s*$" (string-trim sql) ""))))
     (define cols (for/list ([h (in-list (rows-result-headers r))]) (cdr (assq 'name h))))
     (table cols
            (for/list ([v (in-list (rows-result-rows r))])
              (for/hasheq ([col (in-list cols)] [x (in-vector v)]) (values (string->symbol col) (cell-out x c))))))
   (lambda () (disconnect c))))

;; with-columns : message connection tables -> message   a column SQLite does not know is said with
;; the nearest one and each named table's columns (`no such column: gendr (did you mean `gender`?;
;; patients: id, gender)`): a reader cannot otherwise see a view's columns
(define (with-columns msg c tables)
  (define m (regexp-match #px"^no such column: (?:[A-Za-z_][A-Za-z0-9_]*[.])?\"?([^\" ]+)\"?" msg))
  (cond
    [(not m) msg]
    [else
     (define cols (for/list ([t (in-list tables)])
                    (cons t (with-handlers ([exn:fail? (lambda (_) '())])
                              (map (lambda (v) (vector-ref v 1)) (query-rows c (format "PRAGMA table_info(~a)" (q t))))))))
     (define all (remove-duplicates (append-map cdr cols)))
     (format "~a~a~a" msg (did-you-mean (cadr m) all)
             (let ([listed (filter (lambda (tc) (pair? (cdr tc))) cols)])
               (if (null? listed) ""
                   (format " (~a)" (string-join (for/list ([tc (in-list listed)]) (format "~a: ~a" (car tc) (string-join (cdr tc) ", "))) "; ")))))]))

(define (sql-message e)
  (define info (exn:fail:sql-info e))
  (or (let ([m (assq 'message info)]) (and m (cdr m))) (exn-message e)))

;; store-views! : connection (listof taken-name) -> (listof name)   a TEMP view per resource type in
;; the store (unless a table of the same name, any case, is given) and `resources`
(define (store-views! c taken)
  (define (free? n) (not (member (string-downcase n) (map string-downcase taken))))
  (define types (filter free? (query-list c "SELECT DISTINCT resource_type FROM main.fhir_resources ORDER BY 1")))
  (for ([t (in-list types)])
    (query-exec c (format "CREATE TEMP VIEW ~a AS SELECT id, version_id AS versionId, last_updated AS lastUpdated, resource FROM main.fhir_resources WHERE resource_type = '~a'"
                          (q t) (string-replace t "'" "''"))))
  (define (view! name sql) (and (free? name) (begin (query-exec c sql) name)))
  (append (filter values
                  (list (view! "resources" "CREATE TEMP VIEW resources AS SELECT resource_type AS type, id, version_id AS versionId, last_updated AS lastUpdated, resource FROM main.fhir_resources")
                        ;; every version of every resource, the current one included: what changed, when
                        (view! "history" "CREATE TEMP VIEW history AS SELECT resource_type AS type, id, version_id AS versionId, last_updated AS lastUpdated, resource FROM main.fhir_history")))
          types))
(define (q s) (string-append "\"" (string-replace s "\"" "\"\"") "\""))

;; load-table! : connection name table [#:temp?] -> void
(define (load-table! c name t #:temp? [temp? #f])
  (define cols (table-columns t))
  (query-exec c (format "CREATE ~aTABLE ~a (~a)" (if temp? "TEMP " "") (q name) (string-join (map q cols) ", ")))
  (unless (null? cols)
    (define insert (prepare c (format "INSERT INTO ~a VALUES (~a)" (q name) (string-join (map (lambda (_) "?") cols) ", "))))
    (query-exec c "BEGIN")
    (for ([row (in-list (table-rows t))])
      (apply query-exec c insert (for/list ([col (in-list cols)]) (cell-in (hash-ref row (string->symbol col) 'null)))))
    (query-exec c "COMMIT")))

;; cell-in : jsexpr -> sql value ; cell-out : sql value -> jsexpr
(define (cell-in v)
  (cond [(eq? v 'null) sql-null]
        [(eq? v #t) 1] [(eq? v #f) 0]
        [(or (string? v) (exact-integer? v)) v]
        [(real? v) (exact->inexact v)]
        [else (jsexpr->string v)]))
;; a blob is a JSONB value (a stored resource, or a part of one), rendered as JSON; any other blob as text
(define (cell-out x c)
  (cond [(sql-null? x) 'null]
        [(and (real? x) (inexact? x) (= x (round x)) (< (abs x) 1e15)) (inexact->exact x)]
        [(real? x) x]
        [(string? x) x]
        [(bytes? x) (with-handlers ([exn:fail? (lambda (_) (bytes->string/utf-8 x #\?))])
                      (string->jsexpr (query-value c "SELECT json(?)" x)))]
        [else (format "~a" x)]))

(module+ test
  (require rackunit)
  (define patients (table '("id" "gender" "birth")
                          (list (hasheq 'id "a" 'gender "female" 'birth "1960-01-01")
                                (hasheq 'id "b" 'gender "male" 'birth "1990-01-01")
                                (hasheq 'id "c" 'gender "female" 'birth 'null))))
  (define a1c (table '("patient" "value" "codes")
                     (list (hasheq 'patient "a" 'value 6.2 'codes '("4548-4"))
                           (hasheq 'patient "a" 'value 7.0 'codes '("4548-4"))
                           (hasheq 'patient "b" 'value 9.1 'codes '("4548-4" "x")))))
  (define calls 0)
  (define tables (hash "patients" (lambda () patients) "a1c" (lambda () a1c)
                       "unused" (lambda () (set! calls (add1 calls)) patients)))
  ;; group, join, aggregate: the answer is a table
  (check-equal? (sql-query "SELECT gender, count(*) AS n FROM patients GROUP BY gender ORDER BY gender" tables)
                (table '("gender" "n") (list (hasheq 'gender "female" 'n 2) (hasheq 'gender "male" 'n 1))))
  (check-equal? (table-rows (sql-query "select p.gender, round(avg(v.value), 2) as mean from a1c v join patients p on p.id = v.patient group by p.gender order by mean;" tables))
                (list (hasheq 'gender "female" 'mean 6.6) (hasheq 'gender "male" 'mean 9.1)))
  ;; a collection column is its JSON text (SQLite's json functions read it); null is NULL
  (check-equal? (table-rows (sql-query "SELECT count(*) AS n FROM a1c, json_each(a1c.codes) WHERE json_each.value = 'x'" tables))
                (list (hasheq 'n 1)))
  (check-equal? (table-rows (sql-query "SELECT id FROM patients WHERE birth IS NULL" tables)) (list (hasheq 'id "c")))
  (check-equal? calls 0)                                                      ; only the named tables
  ;; only one reading statement; errors in SQLite's words
  (check-exn #rx"one SELECT" (lambda () (sql-query "DELETE FROM patients" tables)))
  (check-exn #rx"one SELECT" (lambda () (sql-query "SELECT 1 FROM patients; ATTACH 'x.db' AS x" tables)))
  (check-exn #rx"one SELECT" (lambda () (sql-query "ATTACH DATABASE 'x.db' AS x" tables)))
  (check-exn #rx"no such column: gendr [(]did you mean `gender`[?][)] [(]patients: [^)]*gender" (lambda () (sql-query "SELECT gendr FROM patients" tables)))
  (check-exn #rx"names none of the tables: a1c, patients, unused" (lambda () (sql-query "SELECT 1" tables)))
  (check-equal? (tables-named "select * from \"a1c\" join patients" '("a1c" "patients" "pat")) '("a1c" "patients"))
  ;; over a store: a view per resource type, the resource as JSONB read in place; tables beside it;
  ;; the store is never written
  (define db (make-temporary-file "sql-store-~a.db"))
  (let ([w (sqlite3-connect #:database db)])
    (query-exec w "CREATE TABLE fhir_resources (resource_type TEXT, id TEXT, version_id INTEGER, last_updated TEXT, resource BLOB)")
    (query-exec w "CREATE TABLE fhir_history (resource_type TEXT, id TEXT, version_id INTEGER, last_updated TEXT, resource BLOB)")
    (for ([r (list "{\"resourceType\":\"Patient\",\"id\":\"a\",\"gender\":\"female\",\"name\":[{\"family\":\"Ng\"}]}"
                   "{\"resourceType\":\"Patient\",\"id\":\"b\",\"gender\":\"male\"}")])
      (query-exec w "INSERT INTO fhir_resources VALUES ('Patient', json_extract(?, '$.id'), 1, '2025-01-01', jsonb(?))" r r))
    (disconnect w))
  (check-equal? (table-rows (sql-query "SELECT resource ->> '$.gender' AS g, count(*) AS n FROM Patient GROUP BY g ORDER BY g" (hash) #:database db))
                (list (hasheq 'g "female" 'n 1) (hasheq 'g "male" 'n 1)))
  (check-equal? (table-rows (sql-query "SELECT p.id, a.value FROM Patient p JOIN a1c a ON a.patient = p.id WHERE a.value > 7" tables #:database db))
                (list (hasheq 'id "b" 'value 9.1)))
  (check-equal? (table-rows (sql-query "SELECT resource -> '$.name' AS names FROM resources WHERE id = 'a'" (hash) #:database db))
                (list (hasheq 'names "[{\"family\":\"Ng\"}]")))
  (check-equal? (table-rows (sql-query "SELECT resource FROM Patient WHERE id = 'b'" (hash) #:database db))
                (list (hasheq 'resource (hasheq 'resourceType "Patient" 'id "b" 'gender "male"))))
  (check-exn #rx"names none of the tables: Patient, history, resources" (lambda () (sql-query "SELECT 1" (hash) #:database db)))
  (delete-file db))
