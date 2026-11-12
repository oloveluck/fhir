#lang racket/base

;;; run.rkt — the verbs run, query and explain: a file or ad-hoc text executed by its language's
;;; workspace support against the data, the result kept (`result://rN`). The hub's own: FHIR JSON (a
;;; Measure evaluated, any other resource validated), FHIR search, and SQL over the workspace's
;;; ViewDefinitions, results and store.

(require racket/list racket/string racket/file racket/path racket/match json net/uri-codec
         fhir/lang/workspace (only-in fhir/suggest did-you-mean)
         (only-in fhir/data-source current-data-source data-source-all data-source-search resources->data-source)
         (only-in fhir/model/registry type-registered?) (only-in fhir/model/introspect full-field-specs)
         (only-in fhir/model/schema field-spec? field-spec-name)
         (only-in fhir/sd/sd-index current-sd-packages) (only-in fhir/operation apply-operation)
         "search-index.rkt" "sql.rkt" "views.rkt" "results.rkt" "hub.rkt" "data.rkt")

;; Contracted in workspace.rkt; describe and stage use the rest.
(provide execute hub-run hub-query current-extra-tables view-table element? hub-explain)

;; ---- run, query --------------------------------------------------------------------------------
;; options : hash -> Options   the verbs' arguments as a language's options
(define (options args)
  (for/hasheq ([k '(entry over parameters name strict)] #:when (and (hash-ref args k #f) (not (eq? (hash-ref args k) 'null))))
    (values k (let ([v (hash-ref args k)]) (if (and (eq? k 'parameters) (hash? v))
                                               (for/hash ([(n x) (in-hash v)]) (values (symbol->string n) (format "~a" x)))
                                               v)))))

(define (support-for lang)
  (or (workspace-support lang) (error 'run (format "the ~a package is not installed" lang))))

;; execute : hub language path|#f text options -> run-result
(define (execute h lang path text opts)
  (with-hub h
    (lambda ()
      (cond
        [(equal? lang "fhir") (run-json h text opts)]
        [(equal? lang "search") (run-search h text opts)]
        [else (define sup (support-for lang))
              (unless (ws-support-run sup) (error 'run (format "~a files do not run" lang)))
              ((ws-support-run sup) (hub-ws h) path text opts)]))))

(define (hub-run h p args)
  (define full (inside h p))
  (unless (file-exists? full) (error 'run (format "no file ~a in the workspace" p)))
  (define lang (or (workspace-language-of full) (error 'run (format "~a is not a file of the workspace's languages" p))))
  (refresh! h)
  (define text (file->string full))
  (define opts (named (options args) (file-result-name full)))
  (define r (audited h "run" (hasheq 'kind "file" 'path (rel h full) 'language lang 'text text)
                     (lambda () (execute h lang full text opts))))
  (result-json (store! h (stored lang full text opts r)) r (hash-ref opts 'name #f) #:path (rel h full)))

(define query-languages (hash "fhirpath" "fhirpath" "cql" "cql" "vcl" "vcl" "search" "search" "view" "sql-on-fhir" "sql-on-fhir" "sql-on-fhir" "sql" "sql"))
(define (hub-query h language text args)
  (define lang (or (hash-ref query-languages language #f)
                   (error 'query (format "query takes fhirpath, cql, vcl, search, view or sql (got ~a)" language))))
  (refresh! h)
  ;; what the result came from besides its text: the file it was read from (`text=@table.sql`) and,
  ;; for SQL, the earlier results it reads (`r1`), so a derived table's trail is complete too
  (define opts
    (let* ([o (named (options args) #f)]
           [f (argument-source args 'text h)]
           [o (if f (hash-set o 'textFile f) o)]
           [reads (if (equal? lang "sql")
                      ;; by number (`r3`) and by name (`diabetes`): the result each one is NOW
                      (for*/list ([n (in-list (remove-duplicates (regexp-match* #px"\\b[A-Za-z_][A-Za-z0-9_]*\\b" text)))]
                                  [uri (in-value (result-uri h (string-append "result://" n)))]
                                  #:when uri)
                        uri)
                      '())])
      (if (pair? reads) (hash-set o 'reads reads) o)))
  (define r (audited h (string-append "query " language) (hasheq 'kind "query" 'language language 'text text)
                     (lambda () (if (equal? lang "sql") (run-sql h text) (execute h lang #f text opts)))))
  (define answer (result-json (store! h (stored lang #f text opts r)) r (hash-ref opts 'name #f)))
  (define asked (hash-ref args 'name #f))
  (if (and (string? asked) (not (equal? asked (hash-ref opts 'name #f))))
      (hash-set answer 'note (format "named ~a: a result's name is a SQL table's (letters, digits and _); result://~a reads it too" (hash-ref opts 'name) asked))
      answer))

;; ---- the workspace's own tables, as ViewDefinitions (views.rkt) --------------------------------
;; current-extra-tables : (parameter (listof (cons name thunk)))   tables one call adds (describe's trail)
(define current-extra-tables (make-parameter '()))

;; view-table : view resources -> table   a ViewDefinition's rows over the resources, by the
;; sql-on-fhir engine (loaded on first use; the workspace's tower is pinned, so it reads them as the
;; workspace's FHIR version does), in the view's column order
(define (view-table v resources)
  (define rows ((dynamic-require 'sql-on-fhir/operations 'view-rows) v resources))
  (define cols (for*/list ([sel (in-list (hash-ref v 'select))] [c (in-list (hash-ref sel 'column '()))]) (hash-ref c 'name)))
  (table cols rows))

;; builtin-tables : hub -> (listof (cons name thunk))   `trail`: each version a commit wrote, from the
;; Provenances (trail-view); a workspace view or result of that name wins
(define (builtin-tables h)
  (list (cons "trail" (lambda () (view-table (trail-view (ws-config-fhir-version (workspace-config (hub-ws h))))
                                             ((data-source-all (hub-data h)) "Provenance"))))))

;; element? : type -> (symbol -> boolean)   whether the type has an element, as the workspace's tower
;; defines it (`value` for value[x]: `valueQuantity` …)
(define (element? type)
  (define names (if (type-registered? (string->symbol type))
                    (for/list ([f (in-list (full-field-specs (string->symbol type)))] #:when (field-spec? f))
                      (symbol->string (field-spec-name f)))
                    '()))
  (lambda (e)
    (define s (symbol->string e))
    (for/or ([n (in-list names)])
      (or (equal? n s)
          (and (> (string-length n) (string-length s)) (string-prefix? n s) (char-upper-case? (string-ref n (string-length s))))))))

;; ---- SQL ---------------------------------------------------------------------------------------
;; view-names : view-file -> (listof string)   the names SQL knows a view by: its file stem and `name`
(define (view-names f)
  (remove-duplicates
   (filter values (list (regexp-replace #rx"[.]view[.]json$|[.]json$" (path->string (file-name-from-path f)) "")
                        (with-handlers ([exn:fail? (lambda (_) #f)])
                          (let ([n (hash-ref (call-with-input-file f read-json) 'name #f)]) (and (string? n) n)))))))

;; run-sql : hub sql -> run-result   SQL over the workspace's tables (sql.rkt): each ViewDefinition
;; file's rows, named by its file (`patients.view.json` is `patients`) and by its `name`, and every
;; earlier result whose rows are a table (`r1`, `r2`, …: a CQL run's defines per patient, a view's
;; rows), so a cohort can be joined with a view's columns
(define (run-sql h text)
  (define views
    (for*/list ([f (in-list (workspace-files (hub-ws h)))]
                #:when (equal? (workspace-language-of f) "sql-on-fhir")
                [name (in-list (view-names f))])
      (cons name (lambda () (let ([r (execute h "sql-on-fhir" f (file->string f) (hasheq))])
                              (table (run-result-columns r) (run-result-rows r)))))))
  ;; each view over EVERY version too (`bp_history`): the store's history as the view's input, so the
  ;; values of a corrected reading are a column, not json_each over JSONB (a `meta.versionId` column
  ;; says which version a row is)
  (define history-views
    (if (not (data-store-path h)) '()
        (for/list ([v (in-list views)])
          (cons (string-append (car v) "_history")
                (lambda ()
                  (define f (for/first ([f (in-list (workspace-files (hub-ws h)))]
                                        #:when (equal? (workspace-language-of f) "sql-on-fhir")
                                        #:when (member (car v) (view-names f)))
                              f))
                  (define type (hash-ref (call-with-input-file f read-json) 'resource "?"))
                  (define r (parameterize ([current-sd-packages (hub-packages h)]
                                           [current-data-source (resources->data-source (history-resources (data-store-path h) type))])
                              ((ws-support-run (support-for "sql-on-fhir")) (hub-ws h) f (file->string f) (hasheq))))
                  (table (run-result-columns r) (run-result-rows r)))))))
  (define (result-table st)
    (lambda () (table (map (lambda (c) (format "~a" c)) (run-result-columns (stored-result st)))
                      (run-result-rows (stored-result st)))))
  (define tabular
    (for*/list ([uri (in-list (hub-result-uris h))] [st (in-value (result-of* h uri))] #:when st
                #:when (andmap hash? (run-result-rows (stored-result st))))
      (cons uri st)))
  ;; by number, and by name: the latest of each name (a later one replaces an earlier in the hash)
  (define results
    (append (for/list ([u+st (in-list tabular)])
              (cons (regexp-replace #rx"^result://" (car u+st) "") (result-table (cdr u+st))))
            (for/list ([u+st (in-list tabular)] #:when (hash-ref (stored-options (cdr u+st)) 'name #f))
              (cons (hash-ref (stored-options (cdr u+st)) 'name) (result-table (cdr u+st))))))
  (define t (with-handlers ([exn:fail:user? (lambda (e) (error 'sql (regexp-replace #rx"^sql: " (exn-message e) "")))])
              (sql-query text (make-immutable-hash (append (builtin-tables h) (current-extra-tables) results history-views views))
                         #:database (data-store-path h))))
  (run-result "table" (table-columns t) (table-rows t) (hasheq 'rows (length (table-rows t)))))

;; ---- search ------------------------------------------------------------------------------------
;; run-search : "Type?params" options -> run-result   FHIR search where the data source can run it.
;; A parameter the search could not apply (unknown to the type, `_has`, chaining, an unsupported
;; modifier) is said in the answer (`ignored`, with the nearest name); `strict:=true` refuses such a
;; search — `Patient?_has:Observation:subject:code=4548-4` answered every patient, silently
(define (run-search h text opts)
  (define m (regexp-match #px"^\\s*([A-Za-z]+)(?:\\?(.*))?\\s*$" text))
  (unless m (error 'search "a search is Type?name=value&… (Observation?code=http://loinc.org|4548-4)"))
  (define type (cadr m))
  (define params (if (and (caddr m) (not (string=? (caddr m) ""))) (form-urlencoded->alist (caddr m)) '()))
  (define qps (for/list ([p (in-list params)]) (cons (symbol->string (car p)) (or (cdr p) ""))))
  (define ds (current-data-source))
  (define store-path (data-store-path h))
  (define-values (found ignored names)
    (cond [(and store-path (search-index-available?))
           (define-values (store catalog) (open-store store-path (hub-packages h)))
           (define-values (rs ig) ((dynamic-require 'fhir/store/fhir-engine 'fhir-search/ignored) store type qps #:search-params catalog))
           (values rs ig (search-param-names catalog type))]
          [(data-source-search ds) (values ((data-source-search ds) type qps) '() '())]
          [(null? params) (values ((data-source-all ds) type) '() '())]
          [(file-search-index h)
           => (lambda (search)
                (define-values (rs ig) (search type qps))
                (values rs ig (search-param-names (search-catalog (hub-packages h)) type)))]
          [else (error 'search "searching files needs the fhir-server package (raco pkg install fhir-server); meanwhile ask with FHIRPath: query(\"fhirpath\", \"Observation.where(…)\")")]))
  (define (why n)
    (cond [(regexp-match? #rx"^_has:" n) (format "`~a`: reverse chaining (_has) is not supported — ask CQL or SQL (learn://search)" n)]
          [(regexp-match? #rx"[.]" n) (format "`~a`: chained parameters are not supported — ask CQL or SQL (learn://search)" n)]
          [else (let* ([base (car (string-split n ":"))])
                  (if (member base names)
                      (format "`~a`: the modifier is not supported" n)
                      (format "`~a`: ~a does not search on it~a" n type (did-you-mean base names))))]))
  ;; reverse chaining and chaining can never be applied here: refused, not answered as if absent (a
  ;; `_has` search answered every patient beside its note, and a reader of the rows got a wrong list)
  (define never (filter (lambda (n) (or (regexp-match? #rx"^_has:" n) (regexp-match? #rx"[.]" n))) ignored))
  (when (pair? never)
    (error 'search (format "not supported: ~a — ask \"has a …\" or \"has none\" with CQL (exists [Observation: …], the CQL guide's \"No HbA1c\") or SQL over a view"
                           (string-join (map why never) "; "))))
  (when (and (pair? ignored) (hash-ref opts 'strict #f))
    (error 'search (format "not applied: ~a (~a searches on ~a and _id, _lastUpdated, _count, _sort)"
                           (string-join (map why ignored) "; ") type (string-join names ", "))))
  (run-result "resources" '("resource" "json")
              (for/list ([r (in-list found)]) (hasheq 'resource (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id "?")) 'json r))
              (if (null? ignored)
                  (hasheq 'resources (length found))
                  (hasheq 'resources (length found)
                          'ignored (map why ignored)
                          'note "the answer is the search WITHOUT these parameters; strict:=true refuses such a search"))))

;; file-search-index : hub -> (type params -> resources) | #f   the data's files indexed for FHIR
;; search (search-index.rkt), built on the first search and kept until the data is read again (a
;; commit, a new workspace.yaml): keyed by the data source, which configure! replaces
(define file-indexes (make-weak-hasheq))
(define (file-search-index h)
  (and (search-index-available?)
       (hash-ref! file-indexes (hub-data h)
                  (lambda () (build-search-index (data-resources h) (hub-packages h)
                                                 (if (workspace-r4? (hub-ws h)) 'fhir/r4/schemas 'fhir/r5/schemas))))))

;; ---- FHIR JSON ---------------------------------------------------------------------------------
;; run-json : hub text options -> run-result   a Measure evaluated, any other resource validated
(define (run-json h text opts)
  (define r (string->jsexpr text))
  (match (hash-ref r 'resourceType #f)
    ["Measure"
     (define ps (hash-ref opts 'parameters (hash)))
     (define (param k) (or (hash-ref ps k #f) (error 'run (format "a Measure runs over a period: give parameters {\"periodStart\": \"2025-01-01\", \"periodEnd\": \"2025-12-31\"}"))))
     (define report (apply-operation "$evaluate-measure" r #:periodStart (param "periodStart") #:periodEnd (param "periodEnd")))
     (define rows (for*/list ([g (in-list (hash-ref report 'group '()))]
                              [p (in-list (hash-ref g 'population '()))])
                    (hasheq 'group (hash-ref g 'id 'null)
                            'population (let ([c (hash-ref p 'code (hasheq))]) (let ([cs (hash-ref c 'coding '())]) (if (pair? cs) (hash-ref (car cs) 'code "") "")))
                            'count (hash-ref p 'count 0))))
     (run-result "rows" '("group" "population" "count") rows
                 (hasheq 'measureScore (for/list ([g (in-list (hash-ref report 'group '()))]) (hash-ref g 'measureScore 'null))
                         'report report))]
    [_
     (define oo (apply-operation "$validate" r))
     (define issues (hash-ref oo 'issue '()))
     (run-result "rows" '("severity" "code" "location" "diagnostics")
                 (for/list ([i (in-list issues)])
                   (hasheq 'severity (hash-ref i 'severity "") 'code (hash-ref i 'code "")
                           'location (let ([e (hash-ref i 'expression (hash-ref i 'location '()))]) (if (pair? e) (car e) 'null))
                           'diagnostics (hash-ref i 'diagnostics 'null)))
                 (hasheq 'errors (count (lambda (i) (member (hash-ref i 'severity #f) '("error" "fatal"))) issues)
                         'warnings (count (lambda (i) (equal? (hash-ref i 'severity #f) "warning")) issues)))]))

;; ---- explain -----------------------------------------------------------------------------------
(define (hub-explain h ref subject args)
  (refresh! h)
  (define-values (lang path text opts)
    (cond
      [(result-of h ref)
       => (lambda (st) (values (stored-language st) (stored-path st) (stored-text st)
                               (for/fold ([o (stored-options st)]) ([(k v) (in-hash (options args))]) (hash-set o k v))))]
      [(regexp-match? #rx"^result://" ref) (error 'explain (format "no result ~a (results: ~a)" ref (result-listing h)))]
      [else (define full (inside h ref))
            (unless (file-exists? full) (error 'explain (format "no file ~a in the workspace" ref)))
            (values (workspace-language-of full) full (file->string full) (options args))]))
  (with-hub h
    (lambda ()
      (cond
        [(equal? lang "fhir")
         (define r (string->jsexpr text))
         (hasheq 'resource (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id "?"))
                 'issues (hash-ref (apply-operation "$validate" r) 'issue '()))]
        [(equal? lang "search") (error 'explain "a search has nothing to explain: describe the resource it found")]
        [else (define sup (support-for lang))
              (unless (ws-support-explain sup) (error 'explain (format "~a has no explanations" lang)))
              ((ws-support-explain sup) (hub-ws h) path text subject opts)]))))
