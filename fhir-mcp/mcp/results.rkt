#lang racket/base

;;; results.rkt — a run's result (fhir/lang/workspace's run-result) as the hub names it and answers
;;; it: its name, its preview, its rows as a sorted table, two results compared. No hub: plain
;;; functions of the result.

(require racket/contract racket/list racket/string racket/path json
         (only-in fhir/lang/workspace run-result run-result? run-result-kind run-result-columns run-result-rows run-result-summary)
         (only-in fhir/suggest did-you-mean)
         "calls.rkt")

(provide
 (contract-out
  [result-name      (-> string? (or/c string? #f))]
  [file-result-name (-> path-string? (or/c string? #f))]
  [named            (-> hash? (or/c string? #f) hash?)]
  [result-number    (-> string? exact-nonnegative-integer?)]
  ;; result-json : uri run-result [name] [#:path file] -> jsexpr   the answer of a run or a query
  [result-json      (->* (string? run-result?) ((or/c string? #f) #:path (or/c string? #f)) hash?)]
  [sorted-rows      (-> list? (or/c string? #f) (listof string?) string? list?)]
  [column-list      (-> any/c (or/c (listof string?) #f))]
  [csv-cell         (-> any/c string?)]
  [diff-results     (-> run-result? run-result? string? string? hash?)]))

;; ---- names -------------------------------------------------------------------------------------
;; A result has a number (result://r7, never reused) and may have a NAME: a run's is its file's
;; (`diabetes.cql` -> diabetes), a query's the `name` it was given. A name means the latest result of
;; that name, so SQL saved in a file (`FROM diabetes`) reads the newest run, whatever its number.

;; result-name : string -> string|#f   an SQL identifier made of a name (r<digits> is the numbering's)
(define (result-name s)
  (define n (regexp-replace* #px"[^A-Za-z0-9_]" s "_"))
  (define n2 (if (regexp-match? #px"^[0-9]" n) (string-append "_" n) n))
  (and (positive? (string-length n2)) (not (regexp-match? #px"^r[0-9]+$" n2)) n2))

;; file-result-name : path -> string|#f   `diabetes.cql` -> diabetes, `bp.view.json` -> bp
(define (file-result-name p)
  (result-name (regexp-replace #px"[.](view[.]json|capability[.]rkt|[A-Za-z0-9]+)$" (path->string (file-name-from-path p)) "")))

;; named : options default -> options   the name asked for (made an identifier), else the default
(define (named opts default)
  (define asked (let ([n (hash-ref opts 'name #f)]) (and (string? n) (or (result-name n) (error 'run (format "`~a` cannot name a result: r<number> names results by number" n))))))
  (define n (or asked default))
  (if n (hash-set opts 'name n) (hash-remove opts 'name)))

;; result-number : uri -> integer   result://r12 -> 12 (for ordering; 0 when it is not numbered)
(define (result-number uri) (or (let ([m (regexp-match #px"^result://r([0-9]+)$" uri)]) (and m (string->number (cadr m)))) 0))

;; ---- a result as an answer ---------------------------------------------------------------------
(define preview-rows 10)
(define max-preview 400)

;; elide : jsexpr -> jsexpr   a value too long to preview names its size
(define (elide v)
  (define s (jsexpr->string v))
  (if (> (string-length s) max-preview) (format "… ~a characters (describe the result to read it whole)" (string-length s)) v))
(define (preview row) (if (hash? row) (for/hasheq ([(k v) (in-hash row)]) (values k (elide v))) (elide row)))

(define (result-json uri r [name #f] #:path [path #f])
  (define rows (run-result-rows r))
  (define base (result-json* uri r rows path))
  (if name (hash-set base 'name (string-append "result://" name)) base))
(define (result-json* uri r rows [path #f])
  ;; a search's preview names the resources; their JSON (kept in the result: describe it, stage from
  ;; it) would be most of the answer's tokens
  (define resources? (equal? (run-result-kind r) "resources"))
  (define shown (take rows (min preview-rows (length rows))))
  (define more
    (cond [(> (length rows) preview-rows)
           (format "~a for the next rows~a" (call-text "describe" (list (cons 'ref uri) (cons 'offset preview-rows))) (if resources? ", with each resource's JSON" ""))]
          [resources? (format "~a for each resource's JSON, or ~a for one" (call-text "describe" (list (cons 'ref uri))) (call-text "describe" (list (cons 'ref "Type/id"))))]
          [else #f]))
  (define answer
   (hasheq 'result uri
          'kind (run-result-kind r)
          'columns (if resources? (remove "json" (run-result-columns r)) (run-result-columns r))
          'total (length rows)
          'summary (run-result-summary r)
          'rows (if resources? (map (lambda (row) (if (hash? row) (hash-remove row 'json) row)) shown) (map preview shown))))
  ;; `more` only when there is more to read (`"more": null` said nothing); a wide table says how to
  ;; have it compact (11 columns of JSON objects was a long answer for a yes/no question)
  (define cols (run-result-columns r))
  (define with-more0 (if more (hash-set answer 'more more) answer))
  ;; what a search could not apply is at the top of the answer, where it cannot be missed
  (define sm (run-result-summary r))
  (define with-more
    (if (and (hash? sm) (hash-ref sm 'ignored #f))
        (hash-set* with-more0 'ignored (hash-ref sm 'ignored) 'note (hash-ref sm 'note "")
                   'summary (hash-remove (hash-remove sm 'ignored) 'note))
        with-more0))
  (if (and (not resources?) (> (length cols) 6))
      ;; a file's run says it as the run itself (`run path=… as=csv columns=…`, the skill's idiom), a
      ;; query's result through describe
      (hash-set with-more 'table (format "~a as=csv columns=\"~a\": the rows as CSV, the columns you choose"
                                         (if path (call-text "run" (list (cons 'path path))) (call-text "describe" (list (cons 'ref uri))))
                                         (string-join (readable-columns cols rows) ",")))
      with-more))

;; readable-columns : columns rows -> (listof string)   the columns to suggest for a table a person reads:
;; those whose values are text, numbers or booleans in every row (it suggested the first three, lists
;; and references); at most five, in column order
(define (readable-columns cols rows)
  (define (cell row c) (if (hash? row) (hash-ref row (if (symbol? c) c (string->symbol (format "~a" c))) 'null) 'null))
  (define (scalar? v) (or (eq? v 'null) (number? v) (boolean? v)
                          (and (string? v) (not (regexp-match? #px"^[A-Z][A-Za-z]+/[A-Za-z0-9.-]+$" v)))))   ; not a resource
  (define good (for/list ([c (in-list cols)]
                          #:when (for/and ([r (in-list rows)]) (scalar? (cell r c))))   ; null in every row too: a value not known yet
                 (format "~a" c)))
  ;; what a person reads first: values that are not yes/no flags (when there are a few of them), and
  ;; a name rather than the patient's id (it suggested `patient,…,Poorly Controlled` and left out
  ;; `Name` and `Above 9`, the recipe's own table)
  (define (flag? c) (and (for/and ([r (in-list rows)]) (let ([v (cell r c)]) (or (boolean? v) (eq? v 'null))))
                         (for/or ([r (in-list rows)]) (boolean? (cell r c)))))
  (define unflagged (filter (lambda (c) (not (flag? c))) good))
  (define readable (if (>= (length unflagged) 3) unflagged good))
  (define named (if (and (member "patient" readable) (ormap (lambda (c) (regexp-match? #px"(?i:name)" c)) readable))
                    (remove "patient" readable)
                    readable))
  (define picked (if (null? named) (map (lambda (c) (format "~a" c)) cols) named))
  ;; a name column leads, as a person reads a table (`Name,Latest Number,…`; past five columns it was
  ;; the one left out)
  ;; then text (a result with its unit, a date, yes/no) before plain numbers, which a text column
  ;; often says better (`Latest Result` 8.9 % beside `Latest Number` 8.9)
  (define-values (names others) (partition (lambda (c) (regexp-match? #px"(?i:name)" c)) picked))
  (define (numeric? c) (let ([vs (filter (lambda (v) (not (eq? v 'null))) (map (lambda (r) (cell r c)) rows))])
                         (and (pair? vs) (andmap number? vs))))
  (define-values (numbers texts) (partition numeric? others))
  (define ordered (append names texts numbers))
  (take ordered (min 5 (length ordered))))

;; ---- a result as a table -----------------------------------------------------------------------
;; sorted-rows : rows (string | #f) columns uri -> rows
(define (sorted-rows rows sort-by cols uri)
  (cond
    [(not (string? sort-by)) rows]
    [else
     (define desc? (string-prefix? sort-by "-"))
     (define col (if desc? (substring sort-by 1) sort-by))
     (unless (member col cols)
       (error 'describe (format "~a has no column ~s to sort by~a (columns: ~a)" uri col (did-you-mean col cols) (string-join cols ", "))))
     (define key (string->symbol col))
     (define (cell r) (if (hash? r) (hash-ref r key 'null) 'null))
     (define (before? a b)
       (cond [(eq? a 'null) #f] [(eq? b 'null) #t]
             [(and (real? a) (real? b)) (< a b)]
             [else (string<? (format "~a" a) (format "~a" b))]))
     (define asc (sort rows before? #:key cell))
     (if desc?
         (let-values ([(nulls vals) (partition (lambda (r) (eq? (cell r) 'null)) asc)]) (append (reverse vals) nulls))
         asc)]))

;; column-list : string | (listof string) | #f -> (listof string) | #f   `"A,B"` or a JSON list
(define (column-list v)
  (cond [(string? v) (filter (lambda (x) (not (string=? x ""))) (map string-trim (string-split v ",")))]
        [(and (list? v) (andmap string? v)) v]
        [else #f]))
;; csv-cell : jsexpr -> string   RFC 4180: quoted when it holds a comma, quote or line break; null empty
(define (csv-cell v)
  (define s (cond [(eq? v 'null) ""] [(string? v) v] [(boolean? v) (if v "true" "false")]
                  [(number? v) (number->string (if (and (inexact? v) (= v (round v)) (< (abs v) 1e15)) (inexact->exact v) v))]
                  [else (jsexpr->string v)]))
  (if (regexp-match? #rx"[,\"\n\r]" s) (string-append "\"" (string-replace s "\"" "\"\"") "\"") s))

;; ---- two results compared ----------------------------------------------------------------------
;; diff-results : before after -> {added removed changed}   rows matched by their first column
(define (diff-results before after bname aname)
  (define key (let ([cs (run-result-columns after)]) (and (pair? cs) (string->symbol (car cs)))))
  (define (index r) (for/hash ([row (in-list (run-result-rows r))] #:when (hash? row)) (values (hash-ref row key 'null) row)))
  (define b (index before))
  (define a (index after))
  (hasheq 'before bname 'after aname 'key (if key (symbol->string key) 'null)
          'added (for/list ([(k row) (in-hash a)] #:unless (hash-has-key? b k)) k)
          'removed (for/list ([(k row) (in-hash b)] #:unless (hash-has-key? a k)) k)
          'changed (for*/list ([(k row) (in-hash a)] #:when (hash-has-key? b k)
                               [(c v) (in-hash row)] #:unless (equal? v (hash-ref (hash-ref b k) c 'null)))
                     (hasheq 'key k 'column (symbol->string c) 'before (elide (hash-ref (hash-ref b k) c 'null)) 'after (elide v)))))

(module+ test
  (require rackunit)
  ;; names: an SQL identifier; r<number> is the numbering's own
  (check-equal? (result-name "a1c-table") "a1c_table")
  (check-equal? (result-name "2024 cohort") "_2024_cohort")
  (check-false (result-name "r12"))
  (check-equal? (file-result-name (string->path "queries/diabetes.cql")) "diabetes")
  (check-equal? (file-result-name "bp.view.json") "bp")
  (check-equal? (named (hasheq 'name "a1c-table") "x") (hasheq 'name "a1c_table"))
  (check-equal? (named (hasheq) "diabetes") (hasheq 'name "diabetes"))
  (check-equal? (named (hasheq) #f) (hasheq))
  (check-exn #rx"cannot name a result" (lambda () (named (hasheq 'name "r3") #f)))
  (check-equal? (result-number "result://r12") 12)
  (check-equal? (result-number "result://diabetes") 0)

  ;; a table: the preview is its first rows, a wide one says how to have it as CSV
  (define rows (for/list ([i (in-range 12)]) (hasheq 'patient (format "Patient/p~a" i) 'Name (format "N~a" i) 'value i 'high (even? i))))
  (define r (run-result "rows" '("patient" "Name" "value" "high") rows (hasheq 'patients 12)))
  (define answer (result-json "result://r1" r "cohort"))
  (check-equal? (hash-ref answer 'total) 12)
  (check-equal? (length (hash-ref answer 'rows)) 10)
  (check-equal? (hash-ref answer 'name) "result://cohort")
  (check-regexp-match #rx"offset: 10" (hash-ref answer 'more))
  (check-false (hash-ref answer 'table #f))
  ;; a search's rows name the resources; their JSON stays in the result
  (define found (run-result "resources" '("resource" "json") (list (hasheq 'resource "Patient/a" 'json (hasheq 'id "a")))
                            (hasheq 'resources 1 'ignored '("`x`: Patient does not search on it") 'note "without these")))
  (define sa (result-json "result://r2" found))
  (check-equal? (hash-ref sa 'columns) '("resource"))
  (check-equal? (hash-ref sa 'rows) (list (hasheq 'resource "Patient/a")))
  (check-equal? (hash-ref sa 'ignored) '("`x`: Patient does not search on it"))   ; at the top of the answer
  (check-equal? (hash-ref sa 'summary) (hasheq 'resources 1))
  ;; the columns a person reads: a name first (a reference to the patient is not one), then text and
  ;; yes/no, then plain numbers; with three other columns to read, the yes/no flags are left out
  (check-equal? (readable-columns '("patient" "Name" "value" "high") rows) '("Name" "high" "value"))
  (check-equal? (readable-columns '("patient" "Name" "Latest Result" "value" "Latest Date" "high")
                                  (list (hasheq 'patient "Patient/a" 'Name "Ann" (string->symbol "Latest Result") "8.9 %" 'value 8.9
                                                (string->symbol "Latest Date") "2025-01-01" 'high #t)))
                '("Name" "Latest Result" "Latest Date" "value"))

  ;; a table sorted: numbers as numbers, nulls last either way, an unknown column named
  (define t (list (hasheq 'n 10 's "b") (hasheq 'n 'null 's "a") (hasheq 'n 9 's "c")))
  (check-equal? (map (lambda (x) (hash-ref x 'n)) (sorted-rows t "n" '("n" "s") "result://r1")) '(9 10 null))
  (check-equal? (map (lambda (x) (hash-ref x 'n)) (sorted-rows t "-n" '("n" "s") "result://r1")) '(10 9 null))
  (check-equal? (sorted-rows t #f '("n" "s") "result://r1") t)
  (check-exn #rx"no column \"m\" to sort by" (lambda () (sorted-rows t "m" '("n" "s") "result://r1")))
  (check-equal? (column-list "Name, Latest Date,") '("Name" "Latest Date"))
  (check-equal? (column-list '("a" "b")) '("a" "b"))
  (check-false (column-list 3))
  ;; RFC 4180 cells
  (check-equal? (map csv-cell (list 'null "a" #t 8.0 8.5 "x, y" "say \"hi\"" (hasheq 'a 1)))
                '("" "a" "true" "8" "8.5" "\"x, y\"" "\"say \"\"hi\"\"\"" "\"{\"\"a\"\":1}\""))

  ;; two results compared, rows matched by their first column
  (define before (run-result "rows" '("patient" "high") (list (hasheq 'patient "a" 'high #f) (hasheq 'patient "b" 'high #t)) (hasheq)))
  (define after (run-result "rows" '("patient" "high") (list (hasheq 'patient "a" 'high #t) (hasheq 'patient "c" 'high #t)) (hasheq)))
  (define d (diff-results before after "result://r1" "result://r2"))
  (check-equal? (hash-ref d 'added) '("c"))
  (check-equal? (hash-ref d 'removed) '("b"))
  (check-equal? (hash-ref d 'changed) (list (hasheq 'key "a" 'column "high" 'before #f 'after #t))))
