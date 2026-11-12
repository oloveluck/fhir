#lang racket/base

;;; hub.rkt — the Hub: one workspace (fhir/lang/workspace) and the context its programs run in.
;;;
;;; A Hub holds the packages (the guide's and workspace.yaml's, then the core package of its FHIR
;;; version), the data source (a SQLite store, a directory, a JSON file, or a FHIR server's REST API),
;;; what every file defines (registered in fhir/registry under the source (workspace <language>), so
;;; the languages see each other), every problem, the results of runs (`result://rN`) and staged
;;; writes (`stage-N`). Languages are reached through their `<id>/workspace` supports; the hub knows
;;; no language internals. JSON resources (`*.json`) are the hub's own.
;;;
;;; A Stored result is (stored language path text options run-result): what explain needs to ask again.
;;; A Change is (change resource action paths errors source): action 'create | 'update | 'unchanged,
;;; paths the lines saying what differs from the data's copy, errors the validation errors, source
;;; what it was made from when that is not the stage's own source (a guide's stage: each
;;; definition's file), else #f.
;;; A Staged is (staged changes source): a stage's changes, and what they were made from (trail.rkt's Source).
;;;
;;; The verbs are built on this module, one module each (check, run, describe, apply, stage);
;;; workspace.rkt is their contracted interface.

(require racket/list racket/string racket/file racket/path racket/match json fhir/lang/workspace
         (only-in fhir/serialize/json-position json-path-location)
         (only-in fhir/diagnostic diagnostic loc loc-source loc-line loc-column diagnostic-loc diagnostic-severity
                  diagnostic-message)
         (only-in fhir/registry register-resources! unregister-source! registered-source)
         (only-in fhir/data-source current-data-source data-source data-source-all data-source-read data-source-search
                  data-source-of-patient directory->data-source resources->data-source empty-data-source bundle-resources)
         (only-in fhir/rest-data-source rest->data-source rest-url?)
         (only-in fhir/model/registry pin-registered-types! unpin-registered-types!)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/operation apply-operation add-operation-loader!) (only-in fhir/ig-config parse-ig-config)
         (only-in db sqlite3-connect query-list disconnect) "artifacts.rkt" "search-index.rkt"
         "tools.rkt" "calls.rkt" "results.rkt")

;; For the verbs' modules; what other code calls is workspace.rkt, where the contracts are.
(provide (struct-out hub) (struct-out stored) (struct-out change) (struct-out staged) hub-root open-hub
         configure! store-file? data-store-path open-store with-hub guide-file? path-string rel from-here at-root?
         inside argument-source shown-path path-from-here files-by-language refresh! problems-of problem-json count-severity
         state-dir saved-names next-number save-state! staged->jsexpr store! result-of result-of* stage-of
         result-uri result-listing hub-result-uris hub-read-result pending-stage-ids)

(struct hub ([ws #:mutable] [warnings #:mutable] [packages #:mutable] [data #:mutable] [data-label #:mutable]
             data-override extra-packages
             cache                    ; language -> Compiled (below): what its files were found to define
             [diagnostics #:mutable]  ; every problem of the last refresh
             results stages           ; uri -> Stored ; id -> Staged (in memory; saved in .fhir-mcp/ too)
             ;; the workspace's implementation guide (fhir/ig-config) and where it is read from:
             ;; sushi-config.yaml, else the ImplementationGuide the store holds; #f without one
             [guide #:mutable] [guide-label #:mutable]))
(struct stored (language path text options result))
(struct change (resource action paths errors source))
(struct staged (changes source))           ; a stage: its changes, and what they were made from (trail.rkt's Source)

(define (hub-root h) (workspace-root (hub-ws h)))

;; ---- opening, context --------------------------------------------------------------------------
(define (open-hub dir #:data [data-override #f] #:packages [extra '()])
  (define h (hub #f '() '() empty-data-source "none" data-override extra (make-hash) '() (make-hash) (make-hash) #f #f))
  (configure! h dir)
  ;; the operation modules load the first time an operation is looked up: a call that needs none
  ;; (SQL, search, a result) does not pay for them
  (add-operation-loader! load-operations!)
  h)

;; configure! : hub dir -> void   read workspace.yaml and the guide, find the packages, open the
;; data source
(define (configure! h dir)
  ;; with-overrides : workspace -> workspace   the data and packages this hub was opened with
  (define (with-overrides ws)
    (define c (workspace-config ws))
    (workspace (workspace-root ws)
               (struct-copy ws-config c
                            [data (or (hub-data-override h) (ws-config-data c))]
                            [packages (append (ws-config-packages c) (hub-extra-packages h))])))
  (define-values (file-ws file-warnings) (open-workspace dir))
  ;; no sushi-config.yaml: the guide is the ImplementationGuide the store holds
  (define-values (stored stored-label stored-warnings) (stored-guide (with-overrides file-ws)))
  (define-values (ws0 warnings) (if stored (open-workspace dir #:guide stored) (values file-ws (append file-warnings stored-warnings))))
  (define ws* (with-overrides ws0))
  (define file-guide (workspace-implementation-guide ws*))
  (set-hub-guide! h (or file-guide stored))
  (set-hub-guide-label! h (cond [file-guide ig-file-name] [stored stored-label] [else #f]))
  (define-values (pkgs missing) (workspace-packages ws*))
  (define core (workspace-core-package ws*))
  ;; the workspace's own tower, pinned: a language loaded later that brings another (sql-on-fhir's
  ;; ViewDefinition model is built over R6) adds its new types and replaces none of these
  (unpin-registered-types!)
  (dynamic-require (if (workspace-r4? ws*) 'fhir/r4/schemas 'fhir/r5/schemas) #f)
  (pin-registered-types!)
  (define-values (ds label data-warnings) (open-data ws* (append pkgs (if core (list core) '()))))
  (set-hub-ws! h ws*)
  (set-hub-packages! h (append pkgs (if core (list core) '())))
  (set-hub-data! h ds)
  (set-hub-data-label! h label)
  (set-hub-warnings! h (append warnings
                               (for/list ([m (in-list missing)]) (format "package ~a not found (a .tgz path, or a package in fhir-spec or FHIR_PACKAGE_PATH)" m))
                               (if core '() (list "no core package for this FHIR version: install fhir-spec"))
                               data-warnings))
  (hash-clear! (hub-cache h)))

;; stored-guide : workspace -> (values ig-config|#f label|#f warnings)   the workspace's
;; implementation guide as its store holds it, for a workspace with no sushi-config.yaml: the file
;; is a working copy and may be deleted; the ImplementationGuide a commit stored is the guide. It is
;; read as the text it is handed back as (fsh/ig), so the file and the store state the same facts.
;; Read with SQL: the store is not open yet, and what the guide says decides how it is opened.
(define (stored-guide ws)
  (define d (ws-config-data (workspace-config ws)))
  (define p (and (store-file? d) (not (rest-url? d)) (simplify-path (path->complete-path d (workspace-root ws)))))
  (define guides
    (if (and p (file-exists? p) (not (file-exists? (build-path (workspace-root ws) ig-file-name))))
        (with-handlers ([exn:fail? (lambda (_) '())])
          (define c (sqlite3-connect #:database p #:mode 'read-only))
          (begin0 (current-versions
                   (map string->jsexpr (query-list c "SELECT json(resource) FROM fhir_resources WHERE resource_type = 'ImplementationGuide'")))
                  (disconnect c)))
        '()))
  (define (reference g) (format "ImplementationGuide/~a" (hash-ref g 'id "?")))
  (match guides
    ['() (values #f #f '())]
    [(list g)
     (with-handlers ([exn:fail? (lambda (e) (values #f #f (list (format "the stored ~a is not read as the workspace's guide: ~a" (reference g) (exn-message e)))))])
       (values (parse-ig-config ((dynamic-require 'fsh/ig 'implementation-guide->config-text) (unarchived g)))
               (format "~a (stored)" (reference g))
               '()))]
    [_ (values #f #f
               (list (format "the store holds ~a implementation guides (~a): none is taken as the workspace's — hand one back as its file (write path=sushi-config.yaml ref=ImplementationGuide/<id>)"
                             (length guides) (string-join (map reference guides) ", "))))]))

;; store-file? : data-setting -> boolean   a SQLite FHIR store (fhir-server's): `data: fhir.db`
(define (store-file? d) (and (string? d) (regexp-match? #rx"[.](db|sqlite|sqlite3)$" d)))
;; data-store-path : hub -> path | #f   the store file when the data is one
(define (data-store-path h)
  (define d (ws-config-data (workspace-config (hub-ws h))))
  (and (store-file? d) (not (rest-url? d)) (simplify-path (path->complete-path d (hub-root h)))))

;; open-store : path packages -> (values store catalog)   one store per file for the process (a store
;; is a connection pool; the data is read again after every commit), its search parameters the
;; packages' own
(define stores (make-hash))
(define (open-store p packages)
  (values (hash-ref! stores p (lambda () ((dynamic-require 'fhir/store/fhir-sqlite 'open-fhir-store) p)))
          (search-catalog packages)))

;; open-data : workspace packages -> (values data-source label warnings)
(define (open-data ws packages)
  (define d (ws-config-data (workspace-config ws)))
  (cond
    [(not d) (values empty-data-source "none (set `data` in workspace.yaml)" '())]
    [(store-file? d)
     (define p (simplify-path (path->complete-path d (workspace-root ws))))
     (cond
       [(search-index-available?)
        (define-values (store catalog) (open-store p packages))
        (values ((dynamic-require 'fhir/store/data-source 'store->data-source) store #:search-params catalog)
                (format "the SQLite store ~a (resources as JSONB; FHIR search; SQL)" (path->string p)) '())]
       [else (values empty-data-source "none"
                     (list (format "workspace.yaml: data ~a is a SQLite FHIR store, which needs the fhir-server package (raco pkg install fhir-server)" d)))])]
    [(rest-url? d)
     (define auth (getenv "FHIR_AUTHORIZATION"))
     (values (rest->data-source d #:headers (if auth (list (string-append "Authorization: " auth)) '()))
             (format "the FHIR server ~a (~a)" d (if (ws-config-allow-remote-writes? (workspace-config ws)) "writes allowed" "read-only"))
             '())]
    [else
     (define p (simplify-path (path->complete-path d (workspace-root ws))))
     (cond [(directory-exists? p) (values (directory->data-source p) (format "the directory ~a" (path->string p)) '())]
           [(file-exists? p)
            (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (file->jsexpr* p)))
            (if (hash? js)
                (values (resources->data-source (list js)) (format "the file ~a" (path->string p)) '())
                (values empty-data-source "none" (list (format "workspace.yaml: data ~a is not a FHIR resource or Bundle" d))))]
           [else (values empty-data-source "none" (list (format "workspace.yaml: data ~a does not exist" d)))])]))
(define (file->jsexpr* p) (call-with-input-file p read-json))

;; The stored definitions as the workspace's programs see them (CRMI artifacts, artifacts.rkt): an
;; artifact a workspace file defines again is left to that file — the working copy, which every
;; resolver finds in fhir/registry next — and among the stored versions of one canonical the
;; current one answers (the active of the highest version, else the highest). Reading by Type/id
;; is the store's own: a stage diffs against what is stored.
(define working-views (make-weak-hasheq))        ; data source -> its view (one per source: caches key on it)
(define (working-copies-first ds)
  (hash-ref! working-views ds
             (lambda ()
               (define (shadowed? r)
                 (define src (and (string? (hash-ref r 'url #f)) (string? (hash-ref r 'resourceType #f))
                                  (registered-source (hash-ref r 'resourceType) (hash-ref r 'url))))
                 (and (pair? src) (eq? (car src) 'workspace)))
               (define (view type rs)
                 (if (member type artifact-types)
                     (current-versions (filter (lambda (r) (not (shadowed? r))) rs))
                     rs))
               (data-source (lambda (type) (view type ((data-source-all ds) type)))
                            (data-source-read ds)
                            (data-source-of-patient ds)
                            (let ([search (data-source-search ds)])
                              (and search (lambda (type params) (view type (search type params)))))))))

;; guide-file? : hub -> boolean   the guide is the workspace's file, the one being written
(define (guide-file? h) (equal? (hub-guide-label h) ig-file-name))

(define (with-hub h thunk)
  (parameterize ([current-sd-packages (hub-packages h)]
                 [current-data-source (working-copies-first (hub-data h))])
    (thunk)))

;; ---- paths -------------------------------------------------------------------------------------
(define (path-string p) (if (path? p) (path->string p) p))
(define (rel h p) (path->string (find-relative-path (hub-root h) (simplify-path (path->complete-path p (hub-root h))))))

;; from-here : path -> string   a path as seen from the current directory (where the shell call was made)
(define (from-here p)
  (path->string (find-relative-path (simplify-path (path->complete-path (current-directory)))
                                    (simplify-path (path->complete-path p)))))

;; at-root? : hub -> boolean   the call is made from the workspace's own directory (`ws` and `ws/`
;; are one: comparing them as paths said the workspace was elsewhere, and a note printed its full path)
(define (at-root? h)
  (define (dir p) (path->directory-path (simplify-path (path->complete-path p))))
  (equal? (dir (current-directory)) (dir (hub-root h))))

;; inside : hub string -> path   a path inside the workspace (never above it, never in the data
;; directory: data changes go through stage and commit)
(define (inside h p)
  (define root (path-string (hub-root h)))
  (define full (simplify-path (path->complete-path p (hub-root h))))
  (unless (string-prefix? (path-string full) (string-append (regexp-replace #rx"/$" root "") "/"))
    (error 'workspace (format "~a is outside the workspace ~a" p root)))
  (define d (ws-config-data (workspace-config (hub-ws h))))
  (when (and d (not (rest-url? d)))
    (define dp (path-string (simplify-path (path->complete-path d (hub-root h)))))
    (when (or (equal? (path-string full) dp) (string-prefix? (path-string full) (string-append (regexp-replace #rx"/$" dp "") "/")))
      (error 'workspace (format "~a is in the data; change data with stage and commit" p))))
  full)

;; file-label : path-string hub|#f -> string   how the trail names a file: relative to the workspace
;; — inside it, or up to two levels above (`../src/bad.fsh`, a file kept beside the workspace) — else
;; absolute. Read against the workspace, it names the file from anywhere; one form for every answer
(define (file-label f h)
  (define full (simplify-path (path->complete-path (expand-user-path f))))
  (define root (and h (simplify-path (path->complete-path (hub-root h)))))
  (define relative (and root (let ([r (path->string (find-relative-path root full))])
                               (and (not (regexp-match? #rx"^/|^([.][.]/){3}" r)) r))))
  (or relative (path->string full)))

;; argument-source : args key hub -> string | #f   the same file as the trail keeps it: relative to the
;; workspace when inside it, else absolute — resolved where the call was made, so a name that was
;; relative to the shell's directory (`patients.fsh` beside the workspace) still names the file later
(define (argument-source args k h)
  (define f (argument-file args k))
  (and f (file-label f h)))

;; shown-path : hub string -> string   a path the trail keeps (workspace-relative or absolute) as a
;; message shows it: relative to the current directory when that is shorter
(define (shown-path h stored)
  (with-handlers ([exn:fail? (lambda (_) stored)])
    (define full (if (absolute-path? stored) (string->path stored) (build-path (hub-root h) stored)))
    (define here (path->string (find-relative-path (simplify-path (path->complete-path (current-directory)))
                                                   (simplify-path (path->complete-path full)))))
    (if (< (string-length here) (string-length stored)) here stored)))

;; path-from-here : hub string -> string   a trail path (`../patients.fsh:12`, relative to the
;; workspace) as seen from the current directory, when the file is there to open; else as given
(define (path-from-here h v)
  (match (and (string? v) (regexp-match #px"^(.*?)(:[0-9]+)?$" v))
    [(list _ file line)
     (define full (with-handlers ([exn:fail? (lambda (_) #f)])
                    (if (absolute-path? file) (string->path file) (build-path (hub-root h) file))))
     (if (and full (file-exists? full)) (string-append (from-here full) (or line "")) v)]
    [_ v]))

;; ---- what the files define ---------------------------------------------------------------------
;; files-by-language : hub -> (hash language -> (listof (cons path text)))
(define (files-by-language h)
  (for/fold ([acc (hash)]) ([f (in-list (workspace-files (hub-ws h)))])
    (hash-update acc (workspace-language-of f) (lambda (l) (append l (list (cons f (file->string f))))) '())))

;; json-artifacts : workspace files -> (values resources diagnostics)   the workspace's FHIR JSON
(define (json-artifacts ws files)
  (for/fold ([rs '()] [ds '()] #:result (values (reverse rs) ds)) ([f (in-list files)])
    (define js (with-handlers ([exn:fail? (lambda (e) e)]) (string->jsexpr (cdr f))))
    (cond [(exn? js) (values rs (append ds (list (diagnostic 'fhir 'parse 'error (format "not JSON: ~a" (exn-message js)) (loc (path-string (car f)) #f #f #f #f)))))]
          [(and (hash? js) (string? (hash-ref js 'resourceType #f)))
           (values (append (reverse (bundle-resources js)) rs) (append ds (resource-problems f js)))]
          [else (values rs (append ds (list (diagnostic 'fhir 'parse 'error "a FHIR resource is a JSON object with a resourceType" (loc (path-string (car f)) #f #f #f #f)))))])))

;; resource-problems : (cons path text) jsexpr -> diagnostics   the resource validated ($validate:
;; its base type, the profiles it claims, the workspace's own), each issue at the key of its element
;; in the file (`json-path-location`), else at the file. Errors and warnings; information is not a
;; problem. Undecidable (no validator, a failure) -> none.
(define (resource-problems f js)
  (define oo (with-handlers ([exn:fail? (lambda (_) #f)]) (apply-operation "$validate" js)))
  (for*/list ([i (in-list (if (hash? oo) (hash-ref oo 'issue '()) '()))]
              [sev (in-value (case (hash-ref i 'severity #f) [("error" "fatal") 'error] [("warning") 'warning] [else #f]))]
              #:when sev)
    (define where (let ([e (hash-ref i 'expression (hash-ref i 'location '()))]) (and (pair? e) (string? (car e)) (car e))))
    (define at (and where (json-path-location (cdr f) where)))
    (diagnostic 'fhir 'validate sev
                (format "~a~a" (if where (string-append where ": ") "") (hash-ref i 'diagnostics (hash-ref i 'code "invalid")))
                (if at
                    (loc (path-string (car f)) (car at) (cadr at) (caddr at) (cadddr at))
                    (loc (path-string (car f)) #f #f #f #f)))))

;; A Compiled is (compiled files basis resources diagnostics): what a language's files were found to
;; define, kept until they change — `files` as (path . text) pairs, and for a language that composes
;; the others, `basis`: the resources they defined then
(struct compiled (files basis resources diagnostics))
;; same-resources? : (listof resource) (listof resource) -> boolean   the very same resources, in order
(define (same-resources? a b) (and (= (length a) (length b)) (andmap eq? a b)))

;; refresh! : hub -> void   every language's artifacts (recomputed only where a file changed),
;; registered, and every problem collected
(define (refresh! h)
  (define ws (hub-ws h))
  (define by-lang (files-by-language h))
  (define diags
    (with-hub h
      (lambda ()
        ;; `earlier` is what the languages before this one define: a language that composes the
        ;; others (the implementation guide lists them) is computed again when that changes
        (define earlier '())
        (append*
         (for/list ([lang (in-list (cons "fhir" workspace-languages))])
           (define files (hash-ref by-lang lang '()))
           (define was (hash-ref (hub-cache h) lang #f))
           (define basis (if (and (not (equal? lang "fhir")) (workspace-composes? lang)) earlier '()))
           (define-values (rs ds)
             (cond
               [(null? files) (values '() '())]
               [(and was (equal? (compiled-files was) files) (same-resources? (compiled-basis was) basis))
                (values (compiled-resources was) (compiled-diagnostics was))]
               [(equal? lang "fhir") (json-artifacts ws files)]
               [else
                (define sup (workspace-support lang))
                (if sup
                    (with-handlers ([exn:fail? (lambda (e) (values '() (list (diagnostic (string->symbol lang) 'compile 'error (exn-message e) (loc (path-string (caar files)) #f #f #f #f)))))])
                      ((ws-support-artifacts sup) ws files))
                    (values '() (for/list ([f (in-list files)])
                                  (diagnostic (string->symbol lang) 'compile 'error (format "the ~a package is not installed" lang) (loc (path-string (car f)) #f #f #f #f)))))]))
           (hash-set! (hub-cache h) lang (compiled files basis rs ds))
           (set! earlier (append earlier rs))
           (unregister-source! (list 'workspace lang))
           (define conflict
             (with-handlers ([exn:fail? (lambda (e) (list (diagnostic (string->symbol lang) 'compile 'error (exn-message e) (loc (path-string (hub-root h)) #f #f #f #f))))])
               (register-resources! rs #:source (list 'workspace lang))
               '()))
           (append ds conflict))))))
  (set-hub-diagnostics! h (remove-duplicates diags)))

;; problems-of : hub path -> diagnostics   the problems positioned in one file
(define (problems-of h p)
  (define full (path-string (simplify-path (path->complete-path p (hub-root h)))))
  (filter (lambda (d) (let ([l (diagnostic-loc d)])
                        (and l (loc-source l) (equal? (path-string (simplify-path (path->complete-path (loc-source l) (hub-root h)))) full))))
          (hub-diagnostics h)))
;; problem-json : hub diagnostic -> string   one line an agent reads at a glance and acts on:
;; "pat.json:5:3 error: Patient.birthDat: element 'birthDat' is not defined … (did you mean …)" — the
;; file relative to the workspace, the line and column when known, the severity, the message. (A
;; problem used to be an object of nine fields, the absolute source path among them: ~3x the tokens.)
(define (problem-json h d)
  (define l (diagnostic-loc d))
  (define src (and l (loc-source l)))
  (define where
    (string-append (if src (rel h src) "")
                   (if (and l (loc-line l)) (format ":~a" (loc-line l)) "")
                   (if (and l (loc-line l) (loc-column l)) (format ":~a" (loc-column l)) "")))
  (format "~a~a~a: ~a" where (if (string=? where "") "" " ") (diagnostic-severity d) (diagnostic-message d)))
(define (count-severity ds s) (count (lambda (d) (eq? (diagnostic-severity d) s)) ds))

;; ---- state that outlives the process -----------------------------------------------------------
;; Results and stages live in the workspace (`.fhir-mcp/results/rN.json`, `.fhir-mcp/stages/stage-N.json`)
;; as well as in memory, so a stage made by one `raco fhir-mcp call` is committed by the next, and a
;; result is described, joined in SQL or staged from another process. Numbers continue from what is
;; saved; results count r1, r2, … and stages stage-1, stage-2, … each on their own.
(define (state-dir h kind) (build-path (hub-root h) ".fhir-mcp" kind))
;; saved-names : hub kind -> (listof name)   "r1", "stage-2", … in number order
(define (saved-names h kind)
  (define d (state-dir h kind))
  (define names (if (directory-exists? d)
                    (for/list ([f (in-list (directory-list d))] #:when (regexp-match? #rx"[.]json$" (path->string f)))
                      (regexp-replace #rx"[.]json$" (path->string f) ""))
                    '()))
  (sort names < #:key (lambda (n) (or (string->number (regexp-replace #rx"^[^0-9]*" n "")) 0))))
;; next-number : hub kind prefix memory -> integer   one more than any saved or held
(define (next-number h kind prefix mem)
  (define (num n) (or (string->number (regexp-replace #rx"^[^0-9]*" n "")) 0))
  (add1 (apply max 0 (append (map num (saved-names h kind))
                             (map (lambda (k) (num (regexp-replace (regexp (regexp-quote prefix)) k ""))) (hash-keys mem))))))
(define (save-state! h kind name thunk)
  (with-handlers ([exn:fail? (lambda (e) (log-warning "fhir-mcp: ~a ~a not saved: ~a" kind name (exn-message e)))])
    (define js (thunk))
    (make-directory* (state-dir h kind))
    (call-with-output-file (build-path (state-dir h kind) (string-append name ".json"))
      (lambda (o) (write-json js o)) #:exists 'truncate/replace)))
(define (load-state h kind name)
  (define f (build-path (state-dir h kind) (string-append name ".json")))
  (and (file-exists? f) (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json))))

;; ---- results and stages, kept ------------------------------------------------------------------
(define (stored->jsexpr st)
  (define r (stored-result st))
  (define o (stored-options st))
  (hasheq 'language (stored-language st)
          'path (let ([p (stored-path st)]) (if p (path->string p) 'null))
          'text (stored-text st)
          'options (for/hasheq ([(k v) (in-hash o)])
                     (values k (if (hash? v) (for/hasheq ([(n x) (in-hash v)]) (values (string->symbol n) x)) v)))
          'result (hasheq 'kind (run-result-kind r) 'columns (run-result-columns r)
                          'rows (run-result-rows r) 'summary (run-result-summary r))))
(define (jsexpr->stored js)
  (define r (hash-ref js 'result (hasheq)))
  (stored (hash-ref js 'language "?")
          (let ([p (hash-ref js 'path 'null)]) (and (string? p) (string->path p)))
          (hash-ref js 'text "")
          (for/hasheq ([(k v) (in-hash (hash-ref js 'options (hasheq)))])
            (values k (if (hash? v) (for/hash ([(n x) (in-hash v)]) (values (symbol->string n) x)) v)))
          (run-result (hash-ref r 'kind "rows") (hash-ref r 'columns '()) (hash-ref r 'rows '()) (hash-ref r 'summary (hasheq)))))
(define (staged->jsexpr st)
  (hasheq 'source (staged-source st)
          'changes (for/list ([c (in-list (staged-changes st))])
                     (define js (hasheq 'resource (change-resource c) 'action (symbol->string (change-action c))
                                        'paths (change-paths c) 'errors (change-errors c)))
                     (if (change-source c) (hash-set js 'source (change-source c)) js))))
(define (jsexpr->staged js)
  (staged (for/list ([c (in-list (hash-ref js 'changes '()))])
            (change (hash-ref c 'resource) (string->symbol (hash-ref c 'action "create")) (hash-ref c 'paths '()) (hash-ref c 'errors '())
                    (let ([src (hash-ref c 'source #f)]) (and (hash? src) src))))
          (hash-ref js 'source (hasheq 'kind "resources"))))

(define (store! h st)
  (define uri (format "result://r~a" (next-number h "results" "result://r" (hub-results h))))
  (hash-set! (hub-results h) uri st)
  (save-state! h "results" (regexp-replace #rx"^result://" uri "") (lambda () (stored->jsexpr st)))
  uri)

;; result-of : hub uri -> stored | #f ; stage-of : hub id -> staged | #f   memory, else the workspace
(define (result-of h uri0)
  (result-of* h (or (result-uri h uri0) uri0)))
(define (result-of* h uri)
  (or (hash-ref (hub-results h) uri #f)
      (let ([js (and (string? uri) (load-state h "results" (regexp-replace #rx"^result://" uri "")))])
        (and (hash? js) (let ([st (jsexpr->stored js)]) (hash-set! (hub-results h) uri st) st)))))
(define (stage-of h id)
  (or (hash-ref (hub-stages h) id #f)
      (let ([js (load-state h "stages" id)])
        (and (hash? js) (let ([st (jsexpr->staged js)]) (hash-set! (hub-stages h) id st) st)))))

;; result-uri : hub uri -> uri|#f   the numbered result a reference means: itself, or the latest of a name
(define (result-uri h uri)
  (define m (and (string? uri) (regexp-match #px"^result://(.+)$" uri)))
  (cond [(not m) #f]
        [(regexp-match? #px"^r[0-9]+$" (cadr m)) (and (or (hash-ref (hub-results h) uri #f) (load-state h "results" (cadr m))) uri)]
        ;; a name as it was asked (`a1c-table`) or as it was kept (`a1c_table`), in any case, as SQL reads it
        [else (define want (string-downcase (or (result-name (cadr m)) (cadr m))))
              (for/last ([u (in-list (hub-result-uris h))]
                         #:when (let* ([st (result-of* h u)] [n (and st (hash-ref (stored-options st) 'name #f))])
                                  (and (string? n) (equal? (string-downcase n) want))))
                u)]))

;; result-listing : hub -> string   the results by number, each with its name ("r1 (diabetes), r2")
(define (result-listing h)
  (define us (hub-result-uris h))
  (if (null? us) "none yet"
      (string-join (for/list ([u (in-list us)])
                     (define st (result-of* h u))
                     (define n (and st (hash-ref (stored-options st) 'name #f)))
                     (string-append (regexp-replace #rx"^result://" u "") (if (string? n) (format " (~a)" n) "")))
                   ", ")))

(define (hub-result-uris h)
  (sort (remove-duplicates (append (hash-keys (hub-results h))
                                   (map (lambda (n) (string-append "result://" n)) (saved-names h "results"))))
        < #:key result-number))
(define (hub-read-result h uri)
  (define st (result-of h uri))
  (and st (let ([r (stored-result st)])
            (hasheq 'kind (run-result-kind r) 'columns (run-result-columns r) 'summary (run-result-summary r) 'rows (run-result-rows r)))))

;; pending-stage-ids : hub -> (listof id)   the stages not committed (in memory or saved)
(define (pending-stage-ids h)
  (define saved (filter (lambda (n) (regexp-match? #rx"^stage-" n)) (saved-names h "stages")))
  (sort (remove-duplicates (append saved (hash-keys (hub-stages h))))
        < #:key (lambda (n) (or (string->number (regexp-replace #rx"^[^0-9]*" n "")) 0))))
