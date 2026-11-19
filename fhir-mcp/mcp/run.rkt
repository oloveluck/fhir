#lang racket/base

;;; run.rkt — the verbs run, query and explain: a file or ad-hoc text executed by its language's
;;; workspace support against the data, the result kept (`result://rN`). The hub's own: FHIR JSON (a
;;; Measure evaluated, any other resource validated), FHIR search, and SQL over the workspace's
;;; ViewDefinitions, results and store.

(require racket/list racket/string racket/file racket/path racket/match racket/promise json net/uri-codec
         fhir/lang/workspace (only-in fhir/suggest did-you-mean)
         (only-in fhir/data-source current-data-source data-source-all data-source-search data-source-read resources->data-source)
         (only-in fhir/model/registry type-registered?) (only-in fhir/model/introspect full-field-specs)
         (only-in fhir/model/schema field-spec? field-spec-name)
         (only-in fhir/sd/sd-index current-sd-packages) (only-in fhir/operation apply-operation)
         (only-in db sqlite3-connect disconnect query-value) (only-in file/sha1 sha1)
         "search-index.rkt" "sql.rkt" "views.rkt" "view-cache.rkt" "results.rkt" "hub.rkt" "data.rkt" "digest.rkt"
         (only-in "dependencies.rkt" dependency-rows dependency-columns))

;; Contracted in workspace.rkt; describe and stage use the rest.
(provide execute hub-run hub-query current-extra-tables view-table element? hub-explain search-store)

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
        [(equal? lang "sql") (run-sql h text)]
        [(equal? lang "search") (run-search h text opts)]
        [(equal? lang "find") (run-find h text)]
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

(define query-languages (hash "fhirpath" "fhirpath" "cql" "cql" "vcl" "vcl" "search" "search" "find" "find" "view" "sql-on-fhir" "sql-on-fhir" "sql-on-fhir" "sql" "sql"))
(define (hub-query h language text args)
  (define lang (or (hash-ref query-languages language #f)
                   (error 'query (format "query takes fhirpath, cql, vcl, search, find, view or sql (got ~a)" language))))
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
;; Provenances (trail-view); `dependencies`: what each stored resource depends on, one row per
;; reference (dependencies.rkt: CRMI's paths), so "what depends on X" is a query. A workspace view
;; or result of either name wins.
(define (builtin-tables h)
  (list (cons "trail" (lambda () (view-table (trail-view (ws-config-fhir-version (workspace-config (hub-ws h))))
                                             ((data-source-all (hub-data h)) "Provenance"))))
        (cons "dependencies" (lambda () (table dependency-columns (dependency-rows (all-data h)))))))

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
;; view-facts : view-file -> (cons name|#f type)   what a statement needs to know of a view before
;; it reads its rows: its `name` and the resource type it reads. Remembered by the file's text (a
;; statement asks every view of a workspace, and every statement asked again: thirteen files
;; parsed twice each was an eighth of a statement's time).
(define facts (make-weak-hash))
(define (view-facts f)
  (define text (with-handlers ([exn:fail? (lambda (_) "")]) (file->string f)))
  (hash-ref! facts text
             (lambda ()
               (define j (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr text)))
               (define (text-at key) (let ([v (and (hash? j) (hash-ref j key #f))]) (and (string? v) v)))
               (cons (text-at 'name) (or (text-at 'resource) "?")))))

;; view-names : view-file -> (listof string)   the names SQL knows a view by: its file stem and `name`
(define (view-names f)
  (remove-duplicates
   (filter values (list (regexp-replace #rx"[.]view[.]json$|[.]json$" (path->string (file-name-from-path f)) "")
                        (car (view-facts f))))))

;; ---- a view's rows kept between calls (view-cache.rkt) -------------------------------------------
;; kept-view : hub view-file kind (-> table) -> (or/c kept table)   the view's rows over the data
;; (kind 'current) or over every stored version ('history), kept in `.fhir-mcp/views.db` under a
;; key of everything they depend on: the view's text, the workspace's FHIR version and packages,
;; the data (data-stamp), the workspace's files (a definition a file states is read before the
;; store's) and the engine (engine-stamp). Only a store's views are kept (data-stamp).
(define (kept-view h f kind compute [definitions (lambda () (definitions-stamp h))] [stamp-of (lambda (type) (data-stamp h type))])
  (define stamp (stamp-of (view-resource f)))
  (if (not stamp)
      (compute)
      (kept-rows (build-path (hub-root h) ".fhir-mcp" "views.db")
                 ;; named by its place in the workspace, not on the disk: a copy of the workspace
                 ;; (with a copy of, or a link to, this file) reads the rows already made
                 (format "~a ~a" kind (rel h f))
                 (key-of (list 'view-cache 1 kind (file->string f)
                               (ws-config-fhir-version (workspace-config (hub-ws h))) (hub-packages h)
                               stamp (definitions) (engine-stamp)))
                 compute)))

;; view-resource : view-file -> type   the resource type a ViewDefinition reads
(define (view-resource f) (cdr (view-facts f)))

;; data-stamp : hub type -> datum | #f   what changes whenever the data a view of the type reads
;; changes, for a store (read live, so a stamp read now describes what a view reads now): the last
;; version written (every create and update adds one to its history) and how many resources of the
;; type it holds (a delete adds none). Not for files: a hub reads a directory when it opens, so a
;; stamp of the files on disk could describe rows the hub did not read; nor for a FHIR server.
(define (data-stamp h type)
  (define p (data-store-path h))
  (and p
       (let ([c (sqlite3-connect #:database p #:mode 'read-only)])
         (dynamic-wind void
                       (lambda ()
                         (list 'store (path->string p)
                               (query-value c "SELECT coalesce(max(rowid), 0) FROM fhir_history")
                               (query-value c "SELECT count(*) FROM fhir_resources WHERE resource_type = ?" type)))
                       (lambda () (disconnect c))))))

;; definition-files : hub -> (listof path)   the workspace's files a view's rows could depend on:
;; those that define something a path may resolve (a profile, a value set, a code system). Not the
;; other views, nor the tables defined over them: writing one of those changes no row of this view,
;; and with them in the key every edit of a `.sql` file computed every view again — minutes, over
;; a store of 800,000 observations. Nor a JSON file that states no resource (an answer someone
;; wrote beside the sources): it defines nothing.
(define (definition-files h)
  (filter (lambda (f)
            (match (workspace-language-of f)
              [(or "sql" "sql-on-fhir") #f]
              ["fhir" (states-resource? f)]
              [_ #t]))
          (workspace-files (hub-ws h))))

;; states-resource? : path -> boolean   the file is JSON with a `resourceType`
(define (states-resource? f)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (let ([j (call-with-input-file f read-json)]) (and (hash? j) (string? (hash-ref j 'resourceType #f))))))

;; definitions-stamp : hub -> (listof (list name sha1))   those files by their place in the
;; workspace and their content: a copy of the workspace (with a copy of, or a link to, its kept
;; rows) has the same stamp, whenever its files were written
(define (definitions-stamp h)
  (sort (for/list ([f (in-list (definition-files h))] #:when (file-exists? f))
          (list (rel h f) (call-with-input-file f sha1)))
        string<? #:key car))

;; files-stamp : (listof path) -> (listof (list string size seconds))
(define (files-stamp fs)
  (sort (for/list ([f (in-list fs)] #:when (file-exists? f))
          (list (path->string f) (file-size f) (file-or-directory-modify-seconds f)))
        string<? #:key car))

;; engine-stamp : -> string   the source of what computes a view's rows (sql-on-fhir, fhirpath, the
;; foundation's JSON reading and primitives, this module), by size and time: a changed engine is a
;; new key. Once per process.
(define engine
  (delay
    (define (dir-of mod coll . sub) (let-values ([(d _n _x) (split-path (apply collection-file-path mod coll sub))]) d))
    (define dirs (list (dir-of "view.rkt" "sql-on-fhir") (dir-of "eval.rkt" "fhirpath")
                       (dir-of "from-json.rkt" "fhir" "serialize") (dir-of "primitives.rkt" "fhir" "primitives")
                       (dir-of "run.rkt" "fhir" "mcp")))
    (sha1 (open-input-string
           (format "~s" (for*/list ([d (in-list dirs)])
                          (files-stamp (for/list ([f (in-directory d (lambda (p) (not (regexp-match? #rx"compiled$" (path->string p)))))]
                                                  #:when (regexp-match? #rx"[.]rkt$" (path->string f)))
                                         f))))))))
(define (engine-stamp) (force engine))

;; run-sql : hub sql -> run-result   SQL over the workspace's tables (sql.rkt): each ViewDefinition
;; file's rows, named by its file (`patients.view.json` is `patients`) and by its `name`, and every
;; earlier result whose rows are a table (`r1`, `r2`, …: a CQL run's defines per patient, a view's
;; rows), so a cohort can be joined with a view's columns
(define (run-sql h text)
  ;; read once a statement: the workspace's files (listed and told apart by language), and what
  ;; every view's key holds of them (definitions-stamp: each defining file read and hashed). A
  ;; statement over fifteen views did both fifteen times, which was two fifths of its time.
  (define files (workspace-files (hub-ws h)))
  (define definitions (let ([stamp (delay (definitions-stamp h))]) (lambda () (force stamp))))
  ;; and the data's stamp for a type (two questions of the store over a connection of their own)
  (define stamp-of (let ([seen (make-hash)]) (lambda (type) (hash-ref! seen type (lambda () (data-stamp h type))))))
  (define view-files (filter (lambda (f) (equal? (workspace-language-of f) "sql-on-fhir")) files))
  (define views
    (for*/list ([f (in-list view-files)]
                [name (in-list (view-names f))])
      (cons name (lambda () (kept-view h f 'current
                                       (lambda () (let ([r (execute h "sql-on-fhir" f (file->string f) (hasheq))])
                                                    (table (run-result-columns r) (run-result-rows r))))
                                       definitions stamp-of)))))
  ;; each view over EVERY version too (`bp_history`): the store's history as the view's input, so the
  ;; values of a corrected reading are a column, not json_each over JSONB (a `meta.versionId` column
  ;; says which version a row is)
  (define history-views
    (if (not (data-store-path h)) '()
        (for/list ([v (in-list views)])
          (cons (string-append (car v) "_history")
                (lambda ()
                  (define f (for/first ([f (in-list view-files)] #:when (member (car v) (view-names f))) f))
                  (kept-view h f 'history
                             (lambda ()
                               (define r (parameterize ([current-sd-packages (hub-packages h)]
                                                        [current-data-source (resources->data-source (history-resources (data-store-path h) (view-resource f)))])
                                           ((ws-support-run (support-for "sql-on-fhir")) (hub-ws h) f (file->string f) (hasheq))))
                               (table (run-result-columns r) (run-result-rows r)))
                             definitions stamp-of))))))
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
  ;; Every table is asked for at most once in a statement (a view's thunk reads the data's stamp).
  (define (once thunk) (let ([p (delay (thunk))]) (lambda () (force p))))
  (define tables (make-hash))
  (for ([nt (in-list (append (builtin-tables h) (current-extra-tables) results history-views views))])
    (hash-set! tables (car nt) (once (cdr nt))))
  ;; A table a `<name>.sql` file defines: its statement over the views, under the file's name.
  ;; When every table it reads is kept (views over a store, other such tables), its rows are kept
  ;; too — computed once and indexed (view-cache.rkt `kept-select`), under a key of its statement
  ;; and of the tables it read; otherwise (it reads a result, the store's own tables, or it does
  ;; not run) it is the statement itself, run inside each query, where its errors are said.
  (define cache (build-path (hub-root h) ".fhir-mcp" "views.db"))
  (for ([f (in-list files)] #:when (equal? (workspace-language-of f) "sql"))
    (define name (file-stem f))
    (when (assoc name views)
      (error 'sql (format "~a and a view are both named ~a: a table has one definition" (rel h f) name)))
    (hash-set! tables name
               (once (lambda ()
                       (define body (file->string f))
                       (with-handlers ([exn:fail? (lambda (_) (defined body))])
                         (define read (for/list ([d (in-list (tables-named body (remove name (hash-keys tables))))])
                                        (cons d ((hash-ref tables d)))))
                         (if (and (reading? body) (pair? read) (andmap (lambda (r) (kept? (cdr r))) read))
                             (let ([deps (sort (for/list ([r (in-list read)]) (cons (car r) (kept-name (cdr r)))) string<? #:key car)])
                               (kept-select cache (format "sql ~a" (rel h f))
                                            (key-of (list 'sql-table 1 (statement body) deps))
                                            deps (statement body)))
                             (defined body)))))))
  (define t (with-handlers ([exn:fail:user? (lambda (e) (error 'sql (regexp-replace #rx"^sql: " (exn-message e) "")))])
              (sql-query text (for/hash ([(n th) (in-hash tables)]) (values n th))
                         #:database (data-store-path h))))
  (run-result "table" (table-columns t) (table-rows t) (hasheq 'rows (length (table-rows t)))))

;; ---- search ------------------------------------------------------------------------------------
;; run-search : "Type?params" options -> run-result   FHIR search where the data source can run it.
;;
;; The rows are for reading: each resource as `Type/id` and its Digest (digest.rkt: what it is
;; about, its value, when, its status, whose it is), the JSON kept in the result. The answer is a
;; PAGE: `_count` resources (default-page when the search names none) from `_offset`, and `total`
;; says how many match in all — a patient's 48,000 observations are counted, not read.
;; `_summary=count` (or `_count=0`) answers the total alone.
;;
;; A parameter the search could not apply (unknown to the type, `_has`, chaining, an unsupported
;; modifier) is said in the answer (`ignored`, with the nearest name); `strict:=true` refuses such a
;; search — `Patient?_has:Observation:subject:code=4548-4` answered every patient, silently
(define default-page 1000)

(define (run-search h text opts)
  (define m (regexp-match #px"^\\s*([A-Za-z]+)(?:\\?(.*))?\\s*$" text))
  (unless m (error 'search "a search is Type?name=value&… (Observation?code=http://loinc.org|4548-4)"))
  (define type (cadr m))
  (define params (if (and (caddr m) (not (string=? (caddr m) ""))) (form-urlencoded->alist (caddr m)) '()))
  (define asked (for/list ([p (in-list params)]) (cons (symbol->string (car p)) (or (cdr p) ""))))
  (define (asked-number name) (let ([c (assoc name asked)]) (and c (string->number (cdr c)))))
  (define count-only? (or (equal? (cond [(assoc "_summary" asked) => cdr] [else #f]) "count") (eqv? (asked-number "_count") 0)))
  ;; the search as the store is asked it: `_summary` is answered here, and a page is always asked for
  (define qps
    (let* ([q (filter (lambda (p) (not (member (car p) '("_summary" "_count")))) asked)])
      (append q (list (cons "_count" (number->string (cond [count-only? 0] [(asked-number "_count") => values] [else default-page])))))))
  (define offset (or (asked-number "_offset") 0))
  (define ds (current-data-source))
  (define store-path (data-store-path h))
  ;; found: the matches; store: the store that answered (its _include/_revinclude pull in more), or #f
  (define-values (found ignored total names store catalog)
    (cond [(and store-path (search-index-available?))
           (define-values (store catalog) (open-store store-path (hub-packages h)))
           (define-values (rs ig total) ((dynamic-require 'fhir/store/fhir-engine 'fhir-search/page) store type qps #:search-params catalog))
           (values rs ig total (search-param-names catalog type) store catalog)]
          ;; a FHIR server answers its own page; what it holds in all is its to say
          [(data-source-search ds) (let ([rs ((data-source-search ds) type asked)]) (values (if count-only? '() rs) '() (length rs) '() #f #f))]
          [(null? params) (let ([rs ((data-source-all ds) type)]) (values rs '() (length rs) '() #f #f))]
          [(file-search-index h)
           => (lambda (index)
                (define catalog (search-catalog (hub-packages h)))
                (define-values (rs ig total) ((search-index-search index) type qps))
                (values rs ig total (search-param-names catalog type) (search-index-store index) catalog))]
          [else (error 'search "searching files needs the fhir-server package (raco pkg install fhir-server); meanwhile ask with FHIRPath: query(\"fhirpath\", \"Observation.where(…)\")")]))
  ;; what `_include` / `_revinclude` pull in beside the matches (rows of their own, `mode` include;
  ;; the workspace ignored them without a word)
  (define included
    (if (and store (pair? found) (ormap (lambda (p) (member (car p) '("_include" "_revinclude"))) asked))
        ((dynamic-require 'fhir/store/fhir-engine 'fhir-includes) store type found asked)
        '()))
  (define (why n)
    (cond [(regexp-match? #rx"^_has:" n) (format "`~a`: reverse chaining (_has) is not supported — ask CQL or SQL (learn://search)" n)]
          [(regexp-match? #rx"[.]" n)
           (format "`~a`: a chain is a reference parameter of ~a, then a parameter of the type it points at (medication.code=…, subject:Patient.name=…)" n type)]
          [else (let* ([base (car (string-split n ":"))])
                  (if (member base names)
                      (format "`~a`: the modifier is not supported" n)
                      (format "`~a`: ~a does not search on it~a" n type (did-you-mean base names))))]))
  ;; reverse chaining, and a chain the store could not apply, are refused, not answered as if absent
  ;; (a `_has` search answered every patient beside its note, and a reader of the rows got a wrong
  ;; list); a chain the store can apply was answered (fhir-engine's `unchained`)
  (define never (filter (lambda (n) (or (regexp-match? #rx"^_has:" n) (regexp-match? #rx"[.]" n))) ignored))
  (when (pair? never)
    (error 'search (format "not supported: ~a — ask \"has a …\" or \"has none\" with CQL (exists [Observation: …], the CQL guide's \"No HbA1c\") or SQL over a view"
                           (string-join (map why never) "; "))))
  (when (and (pair? ignored) (hash-ref opts 'strict #f))
    (error 'search (format "not applied: ~a (~a searches on ~a and _id, _lastUpdated, _count, _sort)"
                           (string-join (map why ignored) "; ") type (string-join names ", "))))
  (define all-found (append found included))
  (define digests (with-labels (map digest all-found) (data-source-read ds)))
  (define columns (append (if (null? included) '() '(mode)) (digest-columns digests)))
  (define next (+ offset (length found)))
  (define summary
    (let* ([s (hasheq 'resources (length found) 'total total)]
           [s (if (null? included) s (hash-set s 'included (length included)))]
           [s (if (assoc "_count" asked) (hash-set s 'count (asked-number "_count")) s)]
           [s (if (and (< next total) (not count-only?))
                  (hash-set s 'next (format "~a~a_offset=~a" (regexp-replace #px"[?&]_offset=[0-9]+" (string-trim text) "")
                                            (if (regexp-match? #rx"[?]" (regexp-replace #px"[?&]_offset=[0-9]+" (string-trim text) "")) "&" "?") next))
                  s)]
           [s (if (and store (zero? total) (not count-only?)) (with-alone s store catalog type asked) s)]
           [s (if (null? ignored) s
                  (hash-set* s 'ignored (map why ignored)
                             'note "the answer is the search WITHOUT these parameters; strict:=true refuses such a search"))])
      s))
  (run-result "resources" (append '("resource") (map symbol->string columns) '("json"))
              (for/list ([r (in-list all-found)] [d (in-list digests)] [i (in-naturals)])
                (for/fold ([row (hasheq 'resource (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id "?")) 'json r)])
                          ([c (in-list columns)])
                  (hash-set row c (cond [(eq? c 'mode) (if (< i (length found)) "match" "include")]
                                        [(assq c d) => cdr] [else 'null]))))
              summary))

;; with-alone : Summary store type (listof (cons name value)) -> Summary   an empty answer says what
;; each of its parameters matches on its own (`patient=Patient/S62…: 466`, `code=A1C: 13495`), so
;; "this patient has none" reads at once from the first search. Without it an agent asked again with
;; `patient=S62…`, `code=http://loinc.org|A1C`, `code:text=A1C` … five searches to believe an empty
;; answer. Only for a store (each count is an index lookup), at most four parameters.
(define (with-alone summary store catalog type asked)
  (define named (filter (lambda (p) (not (regexp-match? #rx"^_" (car p)))) asked))
  (define page (dynamic-require 'fhir/store/fhir-engine 'fhir-search/page))
  (define (matching qps)
    (with-handlers ([exn:fail? (lambda (_) #f)])
      (define-values (rs ig total) (page store type (append qps (list (cons "_count" "0"))) #:search-params catalog))
      (and (null? ig) total)))
  (cond
    [(or (null? named) (> (length named) 4)) summary]
    [else
     (define counts (for/list ([p (in-list named)]) (cons p (matching (list p)))))
     (if (ormap (lambda (c) (not (cdr c))) counts)
         summary
         (let ([none (for/list ([c (in-list counts)] #:when (zero? (cdr c))) (car c))])
           (hash-set* summary
                      'alone (for/list ([c (in-list counts)]) (format "~a=~a: ~a" (car (car c)) (cdr (car c)) (cdr c)))
                      'note (cond
                              [(pair? none)
                               (format "`~a=~a` matches no ~a at all: `query language=find text=\"<words>\"` says which codes and values the data uses"
                                       (car (car none)) (cdr (car none)) type)]
                              [else (format "each parameter is understood and matches on its own (`alone`); no ~a matches them all together — the answer is none~a"
                                            type
                                            (if (ormap (lambda (p) (member (car p) '("patient" "subject" "encounter"))) named)
                                                " (a reference is one search written Patient/x or x)" ""))]))))]))

;; with-labels : (listof Digest) read -> (listof Digest)   a cell that is a reference to a resource
;; the row is not about (its medication; not its subject or encounter, which the rows share) says
;; what that resource is called: `Medication/920f… (63323026201 / HEPA5I / Heparin)`. A
;; prescription's row named only `Medication/920f…`, and every reader looked each one up.
(define shared-references '(subject patient encounter partOf context beneficiary))
(define (with-labels digests read)
  (define labels (make-hash))
  (define (label ref)
    (hash-ref! labels ref
               (lambda ()
                 (match (regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" ref)
                   [(list _ type id)
                    (define r (with-handlers ([exn:fail? (lambda (_) #f)]) (read type id)))
                    (and (hash? r) (label-of r))]
                   [_ #f]))))
  ;; a specimen's cell is what was sampled (a culture's `PERITONEAL FLUID`, a lab's `Blood`) and
  ;; not its reference: every row's own Specimen id cost a page of labs more than their values, and
  ;; a page of one kind says `Blood` once (`every`). A specimen that names no type has no cell.
  (define (sampled ref)
    (match (regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" ref)
      [(list _ type id)
       (define r (with-handlers ([exn:fail? (lambda (_) #f)]) (read type id)))
       (and (hash? r) (label-of (hash-remove r 'identifier)))]
      [_ #f]))
  (define samples (make-hash))
  (for/list ([d (in-list digests)])
    (for*/list ([cell (in-list d)]
                [l (in-value (cond [(eq? (car cell) 'specimen) (hash-ref! samples (cdr cell) (lambda () (sampled (cdr cell))))]
                                   [(memq (car cell) shared-references) #f]
                                   [else (label (cdr cell))]))]
                #:when (or l (not (eq? (car cell) 'specimen))))
      (cond [(eq? (car cell) 'specimen) (cons 'specimen l)]
            [l (cons (car cell) (format "~a (~a)" (cdr cell) l))]
            [else cell]))))

;; search-store : hub symbol -> (values store catalog)   the store that indexes the data — the
;; workspace's own, or the one its files were indexed into — with its search parameters; an error
;; saying why when the data has none (a FHIR server keeps its own indexes)
(define (search-store h who)
  (define store-path (data-store-path h))
  (cond [(and store-path (search-index-available?)) (open-store store-path (hub-packages h))]
        [(data-source-search (current-data-source))
         (error who "the data is a FHIR server: its indexes are its own (ask it with query search)")]
        [(file-search-index h) => (lambda (index) (values (search-index-store index) (search-catalog (hub-packages h))))]
        [else (error who "this reads the data's search indexes, which needs the fhir-server package (raco pkg install fhir-server)")]))

;; ---- find --------------------------------------------------------------------------------------
;; run-find : hub words -> run-result   where the words occur in the data (fhir-server's
;; store/census `store-find`): the codes CALLED so, the code and identifier values and the names
;; that hold them — each with how many resources and the search that finds them. The step before a
;; search when a question names something by its words ("a hemoglobin A1c", "miconazole").
(define (run-find h words)
  (define-values (store _catalog) (search-store h 'find))
  (define found ((dynamic-require 'fhir/store/census 'store-find) store words))
  (run-result "table" '("where" "value" "text" "resources" "search" "referencedBy")
              (for/list ([f (in-list found)])
                (for/fold ([f f]) ([k '(text referencedBy)] #:unless (hash-has-key? f k)) (hash-set f k 'null)))
              (if (null? found)
                  (hasheq 'found 0 'note "no code is called so, and no code, identifier or name holds the words: try one word, or a part of it")
                  (hasheq 'found (length found)))))

;; file-search-index : hub -> Index | #f   the data's files indexed for FHIR
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
