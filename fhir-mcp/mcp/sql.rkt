#lang racket/base

;;; sql.rkt — SQL over tables of FHIR data: the analysis step after a ViewDefinition has flattened
;;; resources into rows. The tables live in an in-memory SQLite database made for the one query and
;;; dropped after it; only a reading statement runs (SELECT, WITH or VALUES), so nothing is written
;;; anywhere.
;;;
;;; A Table is (table columns rows): columns (listof string), rows (listof (hash column-symbol ->
;;; jsexpr)). A cell that is a JSON array or object (a collection column) is stored as its JSON text,
;;; a boolean as 1/0, null as NULL. Tables are given as thunks, so only the ones a query names are
;;; computed.

(require racket/contract racket/list racket/string json db)

(provide
 (struct-out table)
 (contract-out
  ;; sql-query : sql (hash name -> (-> table)) -> table   the statement's answer
  [sql-query (-> string? (hash/c string? procedure?) table?)]
  ;; tables-named : sql (listof name) -> (listof name)   the names the statement mentions
  [tables-named (-> string? (listof string?) (listof string?))]))

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

(define (sql-query sql tables)
  (unless (reading? sql)
    (raise-user-error 'sql "one SELECT (or WITH … SELECT) statement over the views' tables"))
  (define names (tables-named sql (hash-keys tables)))
  (when (null? names)
    (raise-user-error 'sql (format "the statement names none of the tables: ~a" (string-join (sort (hash-keys tables) string<?) ", "))))
  (define c (sqlite3-connect #:database 'memory))
  (dynamic-wind
   void
   (lambda ()
     (for ([n (in-list names)]) (load-table! c n ((hash-ref tables n))))
     (define r (with-handlers ([exn:fail:sql? (lambda (e) (raise-user-error 'sql (sql-message e)))])
                 (query c (regexp-replace #px";\\s*$" (string-trim sql) ""))))
     (define cols (for/list ([h (in-list (rows-result-headers r))]) (cdr (assq 'name h))))
     (table cols
            (for/list ([v (in-list (rows-result-rows r))])
              (for/hasheq ([col (in-list cols)] [x (in-vector v)]) (values (string->symbol col) (cell-out x))))))
   (lambda () (disconnect c))))

(define (sql-message e)
  (define info (exn:fail:sql-info e))
  (or (let ([m (assq 'message info)]) (and m (cdr m))) (exn-message e)))

;; load-table! : connection name table -> void
(define (load-table! c name t)
  (define cols (table-columns t))
  (define (q s) (string-append "\"" (string-replace s "\"" "\"\"") "\""))
  (query-exec c (format "CREATE TABLE ~a (~a)" (q name) (string-join (map q cols) ", ")))
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
(define (cell-out x)
  (cond [(sql-null? x) 'null]
        [(and (real? x) (inexact? x) (= x (round x)) (< (abs x) 1e15)) (inexact->exact x)]
        [(real? x) x]
        [(string? x) x]
        [(bytes? x) (bytes->string/utf-8 x #\?)]
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
  (check-exn #rx"no such column: gendr" (lambda () (sql-query "SELECT gendr FROM patients" tables)))
  (check-exn #rx"names none of the tables: a1c, patients, unused" (lambda () (sql-query "SELECT 1" tables)))
  (check-equal? (tables-named "select * from \"a1c\" join patients" '("a1c" "patients" "pat")) '("a1c" "patients")))
