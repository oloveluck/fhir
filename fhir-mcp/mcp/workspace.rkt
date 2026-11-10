#lang racket/base

;;; workspace.rkt — the hub's workspace: what the verbs (verbs.rkt) act on.
;;;
;;; A Hub holds one workspace (fhir/lang/workspace) and the context its programs run in: the packages
;;; (workspace.yaml's, then the core package of its FHIR version), the data source (a directory, a
;;; JSON file, or a FHIR server's REST API), what every file defines (registered in fhir/registry under
;;; the source (workspace <language>), so the languages see each other), every problem, the results of
;;; runs (`result://rN`), and staged writes (`stage-N`). Languages are reached through their
;;; `<id>/workspace` supports; the hub knows no language internals. JSON resources (`*.json`) are the
;;; hub's own: a Measure runs by $evaluate-measure, any other resource by $validate.
;;;
;;; A Stored result is (stored language path text options run-result): what explain needs to ask again.
;;; A Change is (change resource action paths errors): action 'create | 'update | 'unchanged, paths the
;;; dotted paths that differ from the data's copy, errors the validation errors.
;;; Every hub-* procedure answers a jsexpr, or raises: exn:fail:diagnostic (positioned), exn:fail.

(require racket/contract racket/list racket/string racket/file racket/path racket/match racket/set json (only-in fhir/suggest closest-names) (only-in net/base64 base64-decode)
         (only-in fhir/serialize/json-position json-path-location)
         net/uri-codec
         fhir/lang/workspace
         (only-in fhir/lang/support language-id-of)
         (only-in fhir/diagnostic diagnostic diagnostic? loc loc-source loc-line loc-column diagnostic-loc diagnostic-severity
                  diagnostic->jsexpr diagnostic-message exn:fail:diagnostic? exn:fail:diagnostic-diagnostic)
         (only-in fhir/registry register-resources! unregister-source! registered-resource registered-resources registered-kinds)
         (only-in fhir/data-source current-data-source data-source? data-source-all data-source-read data-source-search
                  directory->data-source resources->data-source empty-data-source bundle-resources)
         (only-in fhir/rest-data-source rest->data-source rest-write! rest-url?)
         "search-index.rkt" "sql.rkt" "trail.rkt"
         (only-in net/url string->url post-pure-port)
         (only-in db sqlite3-connect query-value query-list disconnect)
         (only-in fhir/sd/sd-index current-sd-packages resolve-canonical-raw sd-index-available?)
         (only-in fhir/operation operation operation-definition operation-code operation-url operation-levels
                  operation-resource-types apply-operation exn:fail:operation? exn:fail:operation-outcome
                  add-operation-loader!)
         "tools.rkt")

(provide
 (struct-out text-answer)
 (contract-out
  [hub?            (-> any/c boolean?)]
  ;; open-hub : dir [#:data override] [#:packages extra] -> hub
  [open-hub        (->* (path-string?) (#:data (or/c string? #f) #:packages (listof string?)) hub?)]
  [hub-root        (-> hub? path?)]
  [with-hub        (-> hub? (-> any) any)]
  [hub-write!      (-> hub? string? string? jsexpr?)]
  [hub-check       (->* (hub? (listof string?)) (#:data? boolean?) jsexpr?)]
  [hub-run         (-> hub? string? hash? jsexpr?)]
  [hub-query       (-> hub? string? string? hash? jsexpr?)]
  [hub-explain     (-> hub? string? string? hash? jsexpr?)]
  [hub-describe    (-> hub? string? hash? (or/c jsexpr? text-answer?))]   ; text when `as` is "fsh"
  [hub-apply       (->* (hub? string? hash? (or/c hash? #f)) ((or/c string? #f)) jsexpr?)]
  [hub-stage!      (-> hub? hash? jsexpr?)]
  [hub-commit!     (->* (hub? string?) ((or/c string? #f)) jsexpr?)]
  [hub-result-uris (-> hub? (listof string?))]
  [hub-read-result (-> hub? string? (or/c jsexpr? #f))]))

(struct hub ([ws #:mutable] [warnings #:mutable] [packages #:mutable] [data #:mutable] [data-label #:mutable]
             data-override extra-packages
             cache                    ; language -> (cons files (cons resources diagnostics))
             [diagnostics #:mutable]  ; every problem of the last refresh
             results stages [counter #:mutable]))
(struct stored (language path text options result))
(struct change (resource action paths errors))
(struct staged (changes source))           ; a stage: its changes, and what they were made from (trail.rkt's Source)

(define (hub-root h) (workspace-root (hub-ws h)))

;; ---- opening, context ----------------------------------------------------------------------------
(define (open-hub dir #:data [data-override #f] #:packages [extra '()])
  (define h (hub #f '() '() empty-data-source "none" data-override extra (make-hash) '() (make-hash) (make-hash) 0))
  (configure! h dir)
  ;; the operation modules load the first time an operation is looked up: a call that needs none
  ;; (SQL, search, a result) does not pay for them
  (add-operation-loader! load-operations!)
  h)

;; configure! : hub dir -> void   read workspace.yaml, find the packages, open the data source
(define (configure! h dir)
  (define-values (ws0 warnings) (open-workspace dir))
  (define ws (if (hub-data-override h)
                 (workspace (workspace-root ws0) (struct-copy ws-config (workspace-config ws0) [data (hub-data-override h)]))
                 ws0))
  (define ws* (if (null? (hub-extra-packages h)) ws
                  (workspace (workspace-root ws) (struct-copy ws-config (workspace-config ws)
                                                              [packages (append (ws-config-packages (workspace-config ws)) (hub-extra-packages h))]))))
  (define-values (pkgs missing) (workspace-packages ws*))
  (define core (workspace-core-package ws*))
  (dynamic-require (if (workspace-r4? ws*) 'fhir/r4/schemas 'fhir/r5/schemas) #f)
  (define-values (ds label data-warnings) (open-data ws* (append pkgs (if core (list core) '()))))
  (set-hub-ws! h ws*)
  (set-hub-packages! h (append pkgs (if core (list core) '())))
  (set-hub-data! h ds)
  (set-hub-data-label! h label)
  (set-hub-warnings! h (append warnings
                               (for/list ([m (in-list missing)]) (format "workspace.yaml: package ~a not found (a .tgz path, or a package in fhir-spec or FHIR_PACKAGE_PATH)" m))
                               (if core '() (list "no core package for this FHIR version: install fhir-spec"))
                               data-warnings))
  (hash-clear! (hub-cache h)))

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

(define (with-hub h thunk)
  (parameterize ([current-sd-packages (hub-packages h)]
                 [current-data-source (hub-data h)])
    (thunk)))

;; ---- what the files define ---------------------------------------------------------------------
(define (path-string p) (if (path? p) (path->string p) p))
(define (rel h p) (path->string (find-relative-path (hub-root h) (simplify-path (path->complete-path p (hub-root h))))))

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

;; refresh! : hub -> void   every language's artifacts (recomputed only where a file changed),
;; registered, and every problem collected
(define (refresh! h)
  (define ws (hub-ws h))
  (define by-lang (files-by-language h))
  (define diags
    (with-hub h
      (lambda ()
        (append*
         (for/list ([lang (in-list (cons "fhir" workspace-languages))])
           (define files (hash-ref by-lang lang '()))
           (define cached (hash-ref (hub-cache h) lang #f))
           (define-values (rs ds)
             (cond
               [(null? files) (values '() '())]
               [(and cached (equal? (car cached) files)) (values (cadr cached) (cddr cached))]
               [(equal? lang "fhir") (json-artifacts ws files)]
               [else
                (define sup (workspace-support lang))
                (if sup
                    (with-handlers ([exn:fail? (lambda (e) (values '() (list (diagnostic (string->symbol lang) 'compile 'error (exn-message e) (loc (path-string (caar files)) #f #f #f #f)))))])
                      ((ws-support-artifacts sup) ws files))
                    (values '() (for/list ([f (in-list files)])
                                  (diagnostic (string->symbol lang) 'compile 'error (format "the ~a package is not installed" lang) (loc (path-string (car f)) #f #f #f #f)))))]))
           (hash-set! (hub-cache h) lang (cons files (cons rs ds)))
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

;; ---- paths ----------------------------------------------------------------------------------------
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

;; ---- write, check ---------------------------------------------------------------------------------
(define (hub-write! h p text)
  (define full (inside h p))
  (define config? (equal? (path->string (file-name-from-path full)) "workspace.yaml"))
  (define lang (workspace-language-of full))
  (unless (or config? lang)
    (error 'write (format "~a is not a file of the workspace's languages (.fsh .cql .fhirpath .vcl .map/.fml .view.json .json) or workspace.yaml" p)))
  (cond
    [(string=? (string-trim text) "")
     (when (file-exists? full) (delete-file full))]
    [else (make-parent-directory* full)
          (call-with-output-file full (lambda (o) (write-string text o)) #:exists 'truncate/replace)])
  (when config? (configure! h (hub-root h)))
  (refresh! h)
  (define mine (if config? '() (problems-of h full)))
  (define others (- (length (hub-diagnostics h)) (length mine)))
  (define answer
    (hasheq 'path (rel h full)
            'language (or lang "workspace.yaml")
            'written (file-exists? full)
            'problems (map (lambda (d) (problem-json h d)) mine)
            'problemsElsewhere others))
  (define unenforced (if (equal? lang "fsh") (unlisted-profiles h text) '()))
  (define answer* (if (pair? unenforced) (hash-set answer 'notes unenforced) answer))
  ;; the configuration only when it is what was written
  (if config? (hash-set answer* 'config (config-json h)) answer*))

;; unlisted-profiles : hub fsh-text -> (listof string)   a profile the text defines that workspace.yaml's
;; `profiles` does not name: its examples are checked against it, but stage and check(data: true)
;; hold the data only to the listed ones (a rerun's agent expected a new rule to apply at once)
(define (unlisted-profiles h text)
  (define listed (append* (hash-values (ws-config-profiles (workspace-config (hub-ws h))))))
  (define sds (registered-resources "StructureDefinition"))
  (for*/list ([e (in-list (regexp-match* #px"(?m:^Profile:\\s*([A-Za-z0-9_.-]+)\\s*$)((?:\n(?!Profile:|Instance:|Extension:|ValueSet:|CodeSystem:|Invariant:|RuleSet:|Logical:|Resource:|Mapping:|Alias:).*)*)" text #:match-select values))]
              [name (in-value (cadr e))]
              [id (in-value (let ([m (regexp-match #px"(?m:^Id:\\s*([A-Za-z0-9.-]+))" (caddr e))]) (if m (cadr m) name)))]
              [sd (in-value (findf (lambda (r) (and (equal? (hash-ref r 'id #f) id) (equal? (hash-ref r 'derivation #f) "constraint"))) sds))]
              #:when sd
              #:unless (member (hash-ref sd 'url #f) listed))
    (format "profile ~a (~a) is not in workspace.yaml's `profiles`: examples are checked against it, but stage and check(data: true) hold data to it only once listed (profiles:\n  ~a: ~a)"
            name (hash-ref sd 'url "?") (hash-ref sd 'type "?") (hash-ref sd 'url "?"))))

(define (config-json h)
  (define c (workspace-config (hub-ws h)))
  (hasheq 'fhirVersion (ws-config-fhir-version c) 'canonical (ws-config-canonical c)
          'packages (map path-string (hub-packages h)) 'data (hub-data-label h)
          'parameters (for/hasheq ([(k v) (in-hash (ws-config-parameters c))]) (values (string->symbol k) v))
          'warnings (hub-warnings h)))

(define (hub-check h paths #:data? [data? #f])
  (refresh! h)
  (define ds (if (null? paths) (hub-diagnostics h)
                 (append* (for/list ([p (in-list paths)]) (problems-of h (inside h p))))))
  (define base (hasheq 'files (map (lambda (f) (rel h f)) (workspace-files (hub-ws h)))
                       'errors (count-severity ds 'error)
                       'warnings (count-severity ds 'warning)
                       'problems (map (lambda (d) (problem-json h d)) ds)
                       'workspace (config-json h)))
  (if data? (hash-set base 'data (with-hub h (lambda () (check-data h)))) base))

;; check-data : hub -> jsexpr   every stored resource validated against its base type and the
;; workspace's profiles for its type: how many, how many break a rule, the rules by how often they
;; are broken, and the first problems as lines (`Observation/x: Observation.value[x]: …`)
(define (check-data h)
  (define resources (all-data h))
  (define found
    (for*/list ([r (in-list resources)]
                [e (in-list (validation-errors (with-profiles h r)))])
      (cons (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id "?")) e)))
  (define by-rule (for/fold ([acc (hash)]) ([f (in-list found)]) (hash-update acc (cdr f) add1 0)))
  (define bad (remove-duplicates (map car found)))
  (hasheq 'checked (length resources)
          'invalid (length bad)
          ;; per type: the trail's Provenances and AuditEvents are stored resources too
          'byType (for/hasheq ([t (in-list (remove-duplicates (map (lambda (r) (hash-ref r 'resourceType "?")) resources)))])
                    (values (string->symbol t)
                            (hasheq 'checked (count (lambda (r) (equal? (hash-ref r 'resourceType "?") t)) resources)
                                    'invalid (count (lambda (k) (string-prefix? k (string-append t "/"))) bad))))
          'profiles (for/hasheq ([(t us) (in-hash (ws-config-profiles (workspace-config (hub-ws h))))]) (values (string->symbol t) us))
          'byRule (for/list ([kv (in-list (sort (hash->list by-rule) > #:key cdr))] [_ (in-range 20)])
                    (hasheq 'rule (car kv) 'count (cdr kv)))
          'problems (for/list ([f (in-list found)] [_ (in-range 50)]) (format "~a: ~a" (car f) (cdr f)))))

;; all-data : hub -> (listof resource)   every resource the data holds (a store's current versions,
;; a directory's files); a FHIR server is not read whole
(define (all-data h)
  (define p (data-store-path h))
  (cond
    [p (define c (sqlite3-connect #:database p #:mode 'read-only))
       (begin0 (map string->jsexpr (query-list c "SELECT json(resource) FROM fhir_resources ORDER BY resource_type, id"))
               (disconnect c))]
    [else (append-map bundle-resources (data-resources h))]))

;; ---- state that outlives the process --------------------------------------------------------------
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
(define (forget-state! h kind name)
  (define f (build-path (state-dir h kind) (string-append name ".json")))
  (when (file-exists? f) (delete-file f)))
(define (load-state h kind name)
  (define f (build-path (state-dir h kind) (string-append name ".json")))
  (and (file-exists? f) (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json))))

;; ---- result names -----------------------------------------------------------------------------
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
                     (hasheq 'resource (change-resource c) 'action (symbol->string (change-action c))
                             'paths (change-paths c) 'errors (change-errors c)))))
(define (jsexpr->staged js)
  (staged (for/list ([c (in-list (hash-ref js 'changes '()))])
            (change (hash-ref c 'resource) (string->symbol (hash-ref c 'action "create")) (hash-ref c 'paths '()) (hash-ref c 'errors '())))
          (hash-ref js 'source (hasheq 'kind "resources"))))

;; ---- run, query, results ---------------------------------------------------------------------------
(define preview-rows 10)
(define max-preview 400)

;; elide : jsexpr -> jsexpr   a value too long to preview names its size
(define (elide v)
  (define s (jsexpr->string v))
  (if (> (string-length s) max-preview) (format "… ~a characters (describe the result to read it whole)" (string-length s)) v))
(define (preview row) (if (hash? row) (for/hasheq ([(k v) (in-hash row)]) (values k (elide v))) (elide row)))

(define (store! h st)
  (define uri (format "result://r~a" (next-number h "results" "result://r" (hub-results h))))
  (hash-set! (hub-results h) uri st)
  (save-state! h "results" (regexp-replace #rx"^result://" uri "") (lambda () (stored->jsexpr st)))
  uri)

(define (result-json uri r [name #f])
  (define rows (run-result-rows r))
  (define base (result-json* uri r rows))
  (if name (hash-set base 'name (string-append "result://" name)) base))
(define (result-json* uri r rows)
  (hasheq 'result uri
          'kind (run-result-kind r)
          'columns (run-result-columns r)
          'total (length rows)
          'summary (run-result-summary r)
          'rows (map preview (take rows (min preview-rows (length rows))))
          'more (if (> (length rows) preview-rows)
                    (format "describe(\"~a\", offset: ~a) for the next rows" uri preview-rows)
                    'null)))

;; options : hash -> Options   the verbs' arguments as a language's options
(define (options args)
  (for/hasheq ([k '(entry over parameters name)] #:when (and (hash-ref args k #f) (not (eq? (hash-ref args k) 'null))))
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
  (result-json (store! h (stored lang full text opts r)) r (hash-ref opts 'name #f)))

;; audited : hub what Source thunk -> value   with `audit: all`, the execution leaves an AuditEvent
;; in the data (its outcome, its source text), whether it succeeds or fails
(define (audited h what src thunk)
  (define c (workspace-config (hub-ws h)))
  (define (record! outcome)
    (write-trail! h (list (execution-audit (ws-config-fhir-version c) what src outcome (unbox current-agent) (now-instant)))))
  (cond
    [(not (equal? (ws-config-audit c) "all")) (thunk)]
    [else (with-handlers ([exn:fail? (lambda (e) (record! (exn-message e)) (raise e))])
            (begin0 (thunk) (record! #t)))]))

(define query-languages (hash "fhirpath" "fhirpath" "cql" "cql" "vcl" "vcl" "search" "search" "view" "sql-on-fhir" "sql-on-fhir" "sql-on-fhir" "sql" "sql"))
(define (hub-query h language text args)
  (define lang (or (hash-ref query-languages language #f)
                   (error 'query (format "query takes fhirpath, cql, vcl, search, view or sql (got ~a)" language))))
  (refresh! h)
  ;; what the result came from besides its text: the file it was read from (`text=@table.sql`) and,
  ;; for SQL, the earlier results it reads (`r1`), so a derived table's trail is complete too
  (define opts
    (let* ([o (named (options args) #f)]
           [f (argument-file args 'text)]
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

;; run-sql : hub sql -> run-result   SQL over the workspace's tables (sql.rkt): each ViewDefinition
;; file's rows, named by its file (`patients.view.json` is `patients`) and by its `name`, and every
;; earlier result whose rows are a table (`r1`, `r2`, …: a CQL run's defines per patient, a view's
;; rows), so a cohort can be joined with a view's columns
(define (run-sql h text)
  (define views
    (for*/list ([f (in-list (workspace-files (hub-ws h)))]
                #:when (equal? (workspace-language-of f) "sql-on-fhir")
                [name (in-list (remove-duplicates
                                (filter values (list (regexp-replace #rx"[.]view[.]json$|[.]json$" (path->string (file-name-from-path f)) "")
                                                     (with-handlers ([exn:fail? (lambda (_) #f)])
                                                       (let ([n (hash-ref (call-with-input-file f read-json) 'name #f)]) (and (string? n) n)))))))])
      (cons name (lambda () (let ([r (execute h "sql-on-fhir" f (file->string f) (hasheq))])
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
              (sql-query text (make-immutable-hash (append results views)) #:database (data-store-path h))))
  (run-result "table" (table-columns t) (table-rows t) (hasheq 'rows (length (table-rows t)))))

;; run-search : "Type?params" options -> run-result   FHIR search where the data source can run it
(define (run-search h text opts)
  (define m (regexp-match #px"^\\s*([A-Za-z]+)(?:\\?(.*))?\\s*$" text))
  (unless m (error 'search "a search is Type?name=value&… (Observation?code=http://loinc.org|4548-4)"))
  (define type (cadr m))
  (define params (if (and (caddr m) (not (string=? (caddr m) ""))) (form-urlencoded->alist (caddr m)) '()))
  (define ds (current-data-source))
  (define found
    (cond [(data-source-search ds) ((data-source-search ds) type (for/list ([p (in-list params)]) (cons (symbol->string (car p)) (or (cdr p) ""))))]
          [(null? params) ((data-source-all ds) type)]
          [(file-search-index h) => (lambda (search) (search type (for/list ([p (in-list params)]) (cons (symbol->string (car p)) (or (cdr p) "")))))]
          [else (error 'search "searching files needs the fhir-server package (raco pkg install fhir-server); meanwhile ask with FHIRPath: query(\"fhirpath\", \"Observation.where(…)\")")]))
  (run-result "resources" '("resource" "json")
              (for/list ([r (in-list found)]) (hasheq 'resource (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id "?")) 'json r))
              (hasheq 'resources (length found))))

;; file-search-index : hub -> (type params -> resources) | #f   the data's files indexed for FHIR
;; search (search-index.rkt), built on the first search and kept until the data is read again (a
;; commit, a new workspace.yaml): keyed by the data source, which configure! replaces
(define file-indexes (make-weak-hasheq))
(define (file-search-index h)
  (and (search-index-available?)
       (hash-ref! file-indexes (hub-data h)
                  (lambda () (build-search-index (data-resources h) (hub-packages h)
                                                 (if (workspace-r4? (hub-ws h)) 'fhir/r4/schemas 'fhir/r5/schemas))))))

;; data-resources : hub -> (listof jsexpr)   every resource of the data when it is files (a
;; directory's JSON files, or the one file), Bundles as they are
(define (data-resources h)
  (define d (ws-config-data (workspace-config (hub-ws h))))
  (define p (and d (not (rest-url? d)) (simplify-path (path->complete-path d (hub-root h)))))
  (define (read-one f) (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))
  (cond [(and p (directory-exists? p))
         (for*/list ([f (in-directory p)] #:when (regexp-match? #rx"[.]json$" (path->string f))
                     [js (in-value (read-one f))] #:when (and (hash? js) (string? (hash-ref js 'resourceType #f))))
           js)]
        [(and p (file-exists? p)) (let ([js (read-one p)]) (if (hash? js) (list js) '()))]
        [else '()]))

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

(define (hub-result-uris h)
  (sort (remove-duplicates (append (hash-keys (hub-results h))
                                   (map (lambda (n) (string-append "result://" n)) (saved-names h "results"))))
        < #:key result-number))
(define (hub-read-result h uri)
  (define st (result-of h uri))
  (and st (let ([r (stored-result st)])
            (hasheq 'kind (run-result-kind r) 'columns (run-result-columns r) 'summary (run-result-summary r) 'rows (run-result-rows r)))))

;; ---- explain ------------------------------------------------------------------------------------
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

;; ---- describe -----------------------------------------------------------------------------------
(define conformance-kinds '("StructureDefinition" "ValueSet" "CodeSystem" "ConceptMap" "StructureMap"))

;; A TextAnswer is (text-answer string): an answer that is text, not JSON (an FSH rendering), sent
;; as it is (as JSON every newline would be escaped)
(struct text-answer (text))
;; as-fsh : resource -> TextAnswer   the resource as an FSH Instance (fsh/decompile, loaded on demand:
;; fhir-mcp does not depend on fsh) — a third shorter than its JSON for coded data, and the form FSH files use
(define (as-fsh r)
  (define fhir->fsh (with-handlers ([exn:fail? (lambda (_) (error 'describe "as \"fsh\" needs the fsh package"))])
                      (dynamic-require 'fsh/decompile 'fhir->fsh)))
  ;; `Usage: #example` is what an Instance means without it: not said; nor the store's bookkeeping
  ;; (meta.versionId, meta.lastUpdated — describe as JSON shows them)
  (define meta (let ([m (hash-ref r 'meta #f)]) (and (hash? m) (hash-remove (hash-remove m 'versionId) 'lastUpdated))))
  (define r* (cond [(not meta) r] [(zero? (hash-count meta)) (hash-remove r 'meta)] [else (hash-set r 'meta meta)]))
  (text-answer (regexp-replace #rx"\nUsage: #example(?=\n|$)" (fhir->fsh r*) "")))

;; argument-file : args key -> string | #f   the file an argument's text was read from (`files`, which
;; `raco fhir-mcp call key=@file` fills; a client may pass it too)
(define (argument-file args k)
  (define fs (hash-ref args 'files #f))
  (define f (and (hash? fs) (hash-ref fs k #f)))
  (and (string? f) f))

;; source-line : Provenance id -> "file:line" | #f   the line of the FSH a commit's source holds where
;; the Instance with this id begins (a batch file of many resources: which lines made this one)
(define (source-line pv id)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (define text (text-answer-text (as-source pv)))
    (define line (instance-line text id))
    (define title (for*/first ([c (in-list (hash-ref pv 'contained '()))]
                               [d (in-list (hash-ref c 'content '()))]
                               [t (in-value (hash-ref (hash-ref d 'attachment (hasheq)) 'title #f))] #:when (string? t))
                    t))
    (and line (format "~a:~a" (if (and title (not (equal? title "fsh"))) title "fsh") line))))

;; as-source : resource -> text-answer   the text a resource carries as an attachment: the source a
;; commit's Provenance holds (a contained DocumentReference, base64), a DocumentReference's, a Binary's
(define (as-source r)
  (define (attachments x)
    (match (hash-ref x 'resourceType #f)
      ["Binary" (list (hasheq 'data (hash-ref x 'data "") 'contentType (hash-ref x 'contentType "")))]
      ["DocumentReference" (for/list ([c (in-list (hash-ref x 'content '()))] #:when (hash? (hash-ref c 'attachment #f))) (hash-ref c 'attachment))]
      [_ (append-map attachments (filter hash? (hash-ref x 'contained '())))]))
  (define a (for/first ([a (in-list (attachments r))] #:when (string? (hash-ref a 'data #f))) a))
  (unless a (error 'describe (format "~a/~a carries no source text (as: \"source\" reads a commit's Provenance, a DocumentReference or a Binary)"
                                     (hash-ref r 'resourceType "?") (hash-ref r 'id "?"))))
  (text-answer (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (hash-ref a 'data))) #\?)))

(define (hub-describe h ref args)
  (define fsh? (equal? (hash-ref args 'as #f) "fsh"))
  (define source? (equal? (hash-ref args 'as #f) "source"))
  (define (shown r) (cond [(and fsh? (hash? r) (string? (hash-ref r 'resourceType #f))) (as-fsh r)]
                          [(and source? (hash? r)) (as-source r)]
                          [else r]))
  (define offset (let ([o (hash-ref args 'offset 0)]) (if (exact-nonnegative-integer? o) o 0)))
  (define limit (let ([l (hash-ref args 'limit 20)]) (if (exact-positive-integer? l) l 20)))
  (define against (let ([a (hash-ref args 'against #f)]) (and (string? a) a)))
  (with-hub h
    (lambda ()
      (cond
        [(and (regexp-match? #rx"^result://" ref) (equal? (hash-ref args 'as #f) "csv") (not against))
         (result-csv h ref offset (let ([l (hash-ref args 'limit #f)]) (if (exact-positive-integer? l) l 1000)))]
        [(regexp-match? #rx"^result://" ref) (describe-result h ref offset limit against)]
        [(equal? ref "stages") (describe-stages h)]
        [(regexp-match #px"^(?:([A-Za-z]+)/)?[$]([A-Za-z-]+)$" ref) (describe-operation ref)]
        [(regexp-match? #rx"/OperationDefinition/" ref) (describe-operation ref)]
        [(regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)/_history$" ref)
         => (lambda (m) (describe-history h (cadr m) (caddr m)))]
        [(regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" ref)
         => (lambda (m) (shown (or ((data-source-read (current-data-source)) (cadr m) (caddr m))
                                   (registered-resource (cadr m) (caddr m))
                                   (error 'describe (format "no ~a in the data or the workspace" ref)))))]
        [(regexp-match? #rx"://" ref)
         (define r (or (for/or ([k (in-list (registered-kinds))]) (registered-resource k ref))
                       (and (sd-index-available?) (for/or ([k (in-list conformance-kinds)]) (resolve-canonical-raw k ref)))))
         (if r (shown (trim-definition r)) (error 'describe (format "no definition ~a in the workspace or the packages" ref)))]
        [(regexp-match #px"^([A-Z][A-Za-z]+)(?:[.](.+))?$" ref)
         => (lambda (m) (describe-element (cadr m) (caddr m) ref))]
        [else (search-definitions ref)]))))

;; describe-history : hub type id -> jsexpr   every version of a stored resource, newest first: when,
;; what changed since the one before, and the Provenance that wrote it (who, why, from what)
(define (describe-history h type id)
  (define p (or (data-store-path h) (error 'describe "history is kept by the workspace's store: data: fhir.db")))
  (define-values (store catalog) (open-store p (hub-packages h)))
  (define versions (reverse ((dynamic-require 'fhir/store/fhir-engine 'fhir-history) store type id)))   ; oldest first
  (when (null? versions) (error 'describe (format "no ~a/~a in the store" type id)))
  (define (vid r) (hash-ref (hash-ref r 'meta (hasheq)) 'versionId "?"))
  ;; the Provenances naming this resource, by the version they name
  (define provs
    (for*/hash ([pv (in-list ((dynamic-require 'fhir/store/fhir-engine 'fhir-search) store "Provenance"
                                                                                    (list (cons "target" (format "~a/~a" type id)))
                                                                                    #:search-params catalog))]
                [t (in-list (hash-ref pv 'target '()))]
                [m (in-value (regexp-match #px"^([A-Za-z]+)/([^/]+)/_history/([^/]+)$" (hash-ref t 'reference "")))]
                #:when (and m (equal? (cadr m) type) (equal? (caddr m) id)))
      (values (cadddr m) pv)))
  (define entries
    (for/list ([cur (in-list versions)] [prev (in-list (cons #f versions))])
      (define pv (hash-ref provs (vid cur) #f))
      (for/fold ([e (hasheq 'version (vid cur)
                            'recorded (hash-ref (hash-ref cur 'meta (hasheq)) 'lastUpdated "?")
                            'changed (if prev (json-diff prev cur) "created"))])
                ([kv (in-list (if pv
                                  (list (cons 'provenance (format "Provenance/~a" (hash-ref pv 'id "?")))
                                        (cons 'by (let ([a (hash-ref pv 'agent '())]) (and (pair? a) (hash-ref (hash-ref (car a) 'who (hasheq)) 'display #f))))
                                        (cons 'reason (let ([r (hash-ref pv 'reason '())]) (and (pair? r) (hash-ref (car r) 'text #f))))
                                        (cons 'source (let ([en (hash-ref pv 'entity '())]) (and (pair? en) (hash-ref (hash-ref (car en) 'what (hasheq)) 'display #f))))
                                        ;; where in that source this resource was written: an FSH Instance's line
                                        (cons 'at (source-line pv id)))
                                  '()))]
                 #:when (cdr kv))
        (hash-set e (car kv) (cdr kv)))))
  (hasheq 'resource (format "~a/~a" type id) 'versions (reverse entries)))

;; trim-definition : resource -> resource   a StructureDefinition without its snapshot (the elements
;; are a describe of Type.path away); the narrative dropped
(define (trim-definition r)
  (define r1 (hash-remove r 'text))
  (if (and (equal? (hash-ref r 'resourceType #f) "StructureDefinition") (hash-has-key? r 'snapshot))
      (hash-set (hash-remove r1 'snapshot) 'snapshot (format "~a elements: describe(\"~a.<path>\")" (length (hash-ref (hash-ref r 'snapshot) 'element '())) (hash-ref r 'type "Type")))
      r1))

(define (describe-element type path ref)
  (define r (element-info type path))
  (if (string? r) (search-definitions ref) r))

(define (search-definitions q)
  (define rx (regexp (regexp-quote (string-downcase q))))
  (define (hit? s) (and (string? s) (regexp-match? rx (string-downcase s))))
  (define own (for*/list ([k (in-list (registered-kinds))] [r (in-list (registered-resources k))]
                          #:when (or (hit? (hash-ref r 'id #f)) (hit? (hash-ref r 'name #f)) (hit? (hash-ref r 'url #f))))
                (for/hasheq ([key '(resourceType id url name title)] #:when (hash-has-key? r key)) (values key (hash-ref r key)))))
  (hasheq 'query q 'workspace own 'packages (if (sd-index-available?) (find-definitions q #f 30) '())))

(define (describe-operation ref)
  (define o (with-handlers ([exn:fail? (lambda (e) (error 'describe (format "no operation ~a (~a)" ref (exn-message e))))]) (operation ref)))
  (define od (operation-definition o))
  (hasheq 'operation (string-append "$" (operation-code o)) 'url (or (operation-url o) 'null)
          'levels (map symbol->string (operation-levels o)) 'types (operation-resource-types o)
          'title (hash-ref od 'title 'null)
          'inputs (for/list ([p (in-list (hash-ref od 'parameter '()))] #:when (equal? (hash-ref p 'use #f) "in"))
                    (hasheq 'name (hash-ref p 'name) 'type (hash-ref p 'type 'null) 'min (hash-ref p 'min 0) 'max (hash-ref p 'max "1")
                            'documentation (let ([d (hash-ref p 'documentation "")]) (if (> (string-length d) 240) (string-append (substring d 0 240) "…") d))))))

;; result-csv : hub uri offset limit -> text-answer   a result's rows as CSV, a header line first: the
;; compact form of a table (JSON rows repeat every column name); a last line says what is left
(define (result-csv h uri offset limit)
  (define st (or (result-of h uri) (error 'describe (format "no result ~a (results: ~a)" uri (result-listing h)))))
  (define r (stored-result st))
  (define cols (map (lambda (c) (format "~a" c)) (run-result-columns r)))
  (define rows (run-result-rows r))
  (define page (take (drop rows (min offset (length rows))) (min limit (max 0 (- (length rows) offset)))))
  (define (line cells) (string-join (map csv-cell cells) ","))
  (text-answer
   (string-append
    (string-join (cons (line cols)
                       (for/list ([row (in-list page)])
                         (line (for/list ([c (in-list cols)]) (if (hash? row) (hash-ref row (string->symbol c) 'null) row)))))
                 "\n")
    (let ([next (+ offset (length page))])
      (if (< next (length rows)) (format "\n… ~a more rows: describe(\"~a\", as: \"csv\", offset: ~a)" (- (length rows) next) uri next) "")))))
;; csv-cell : jsexpr -> string   RFC 4180: quoted when it holds a comma, quote or line break; null empty
(define (csv-cell v)
  (define s (cond [(eq? v 'null) ""] [(string? v) v] [(boolean? v) (if v "true" "false")]
                  [(number? v) (number->string (if (and (inexact? v) (= v (round v)) (< (abs v) 1e15)) (inexact->exact v) v))]
                  [else (jsexpr->string v)]))
  (if (regexp-match? #rx"[,\"\n\r]" s) (string-append "\"" (string-replace s "\"" "\"\"") "\"") s))

(define (describe-result h uri offset limit against)
  (define st (or (result-of h uri) (error 'describe (format "no result ~a (results: ~a)" uri (result-listing h)))))
  (define r (stored-result st))
  (cond
    [against
     (define other (or (result-of h against) (error 'describe (format "no result ~a" against))))
     (diff-results (stored-result other) r against uri)]
    [else
     (define rows (run-result-rows r))
     (define page (take (drop rows (min offset (length rows))) (min limit (max 0 (- (length rows) offset)))))
     (hasheq 'result uri 'kind (run-result-kind r) 'columns (run-result-columns r) 'total (length rows)
             'offset offset 'rows page 'summary (run-result-summary r)
             'source (result-source h st))]))

;; result-source : hub stored -> jsexpr   what a result came from: the file (or query), its hash, the
;; options, and the data it ran over (the store's latest write) — enough to run it again and compare
(define (result-source h st)
  (for/fold ([src (hasheq 'language (stored-language st) 'sha1 (text-sha1 (stored-text st)))])
            ([kv (in-list (list (cons 'file (or (and (stored-path st) (rel h (stored-path st)))
                                                (hash-ref (stored-options st) 'textFile #f)))
                                (cons 'reads (hash-ref (stored-options st) 'reads #f))
                                (cons 'entry (hash-ref (stored-options st) 'entry #f))
                                (cons 'over (hash-ref (stored-options st) 'over #f))
                                (cons 'data (hub-data-label h))
                                (cons 'dataAsOf (store-as-of h))))]
             #:when (or (string? (cdr kv)) (pair? (cdr kv))))
    (hash-set src (car kv) (cdr kv))))

;; store-as-of : hub -> string | #f   the instant of the store's latest write
(define (store-as-of h)
  (define p (data-store-path h))
  (and p (file-exists? p)
       (with-handlers ([exn:fail? (lambda (_) #f)])
         (define c (sqlite3-connect #:database p #:mode 'read-only))
         (begin0 (let ([v (query-value c "SELECT max(last_updated) FROM fhir_history")]) (and (string? v) v))
                 (disconnect c)))))

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

;; ---- apply ----------------------------------------------------------------------------------------
(define (hub-apply h ref inputs resource [url #f])
  (refresh! h)
  (with-hub h
    (lambda ()
      (define o (if url #f (with-handlers ([exn:fail? (lambda (e) e)]) (operation ref))))
      (audited h "apply" (hasheq 'kind "operation" 'operation ref 'text (jsexpr->string inputs))
               (lambda ()
                 (cond
                   ;; a server named by `url` (any FHIR server: a capability app served with
                   ;; `raco fhir-server serve`, which a shell call's process does not know of)
                   [url (or (apply-on-servers ref inputs resource (list (cons 'given (regexp-replace #rx"/+$" url ""))))
                            (error 'apply (format "~a answered no ~a" url ref)))]
                   [(not (exn? o)) (apply-json o inputs resource)]
                   [(apply-on-servers ref inputs resource) => values]
                   [else (error 'apply (format "no operation ~a: ~a~a" ref (exn-message o)
                                               "; an operation of a served capability app is applied with its url: apply(operation, url: \"http://localhost:8080\", inputs: …) (a server `run` started in another call has stopped with it)"))]))))))

;; apply-on-servers : ref inputs resource -> jsexpr | #f   an operation of a capability app the
;; workspace serves (capability/workspace's running servers), POSTed as a Parameters resource to
;; `<base>/[Type/][id/]$code`; #f when no running app has it
(define (apply-on-servers ref inputs resource [given #f])
  (define running (if given
                      (lambda () given)
                      (with-handlers ([exn:fail? (lambda (_) (lambda () '()))])
                        (dynamic-require 'fhir/capability/workspace 'running-servers))))
  (define m (regexp-match #px"^(?:([A-Z][A-Za-z]+)/)?(?:([A-Za-z0-9.-]+)/)?[$]([A-Za-z0-9-]+)$" ref))
  (and m (pair? (running))
       (let* ([type (cadr m)] [id (caddr m)] [code (cadddr m)]
              [params (hasheq 'resourceType "Parameters"
                              'parameter (append
                                          (for*/list ([(k v) (in-hash inputs)] [x (in-list (if (list? v) v (list v)))])
                                            (parameter-of (symbol->string k) x))
                                          (if resource (list (hasheq 'name "resource" 'resource resource)) '())))])
         (for/or ([srv (in-list (running))])
           (define url (string-append (cdr srv) "/" (if type (string-append type "/") "") (if id (string-append id "/") "") "$" code))
           (define answer (with-handlers ([exn:fail? (lambda (_) #f)])
                            (define in (post-pure-port (string->url url) (string->bytes/utf-8 (jsexpr->string params))
                                                       '("Content-Type: application/fhir+json")))
                            (begin0 (read-json in) (close-input-port in))))
           (and (hash? answer)
                (not (and (equal? (hash-ref answer 'resourceType #f) "OperationOutcome")
                          (for/or ([i (in-list (hash-ref answer 'issue '()))]) (equal? (hash-ref i 'code #f) "not-supported"))))
                answer)))))

;; parameter-of : name jsexpr -> Parameters.parameter   by the value's JSON type
(define (parameter-of name v)
  (cond [(and (hash? v) (hash-ref v 'resourceType #f)) (hasheq 'name name 'resource v)]
        [(boolean? v) (hasheq 'name name 'valueBoolean v)]
        [(exact-integer? v) (hasheq 'name name 'valueInteger v)]
        [(real? v) (hasheq 'name name 'valueDecimal v)]
        [else (hasheq 'name name 'valueString (format "~a" v))]))

;; ---- stage and commit -----------------------------------------------------------------------------
(define instance? (lambda (r) (not (member (hash-ref r 'resourceType #f) (append conformance-kinds '("Library" "OperationDefinition" "SearchParameter" "CapabilityStatement" "ImplementationGuide" "ViewDefinition"))))))

;; staged-resources : hub args -> (listof resource)
(define (staged-resources h args)
  (define given (hash-ref args 'resources #f))
  (define path (hash-ref args 'path #f))
  (define result (hash-ref args 'result #f))
  (define fsh (hash-ref args 'fsh #f))
  (cond
    ;; FSH Instances written in the call: the compact way to state coded data (a line per coding)
    [(string? fsh)
     ;; FSH compiles as a file of the workspace's project (its profiles in context): a temporary
     ;; file, removed (and the workspace refreshed) whatever happens
     (define tmp (build-path (hub-root h) (format "_stage-~a.fsh" (current-milliseconds))))
     (dynamic-wind
      (lambda () (call-with-output-file tmp (lambda (o) (write-string fsh o)) #:exists 'truncate/replace) (refresh! h))
      (lambda ()
        (define r (execute h "fsh" tmp fsh (hasheq)))
        ;; the text's own parse and compile errors refuse the stage, every one by its line in the text
        ;; (an entity that does not compile would otherwise be dropped from the stage without a word;
        ;; validation issues are the stage's own report, per resource)
        (define own (for/list ([p (in-list (hash-ref (run-result-summary r) 'problems '()))]
                               #:when (and (equal? (hash-ref p 'severity #f) "error")
                                           (not (equal? (hash-ref p 'phase #f) "validate"))
                                           (equal? (hash-ref p 'source #f) (path->string tmp))))
                      (format "~a:~a:~a error: ~a" (or (argument-file args 'fsh) "fsh") (hash-ref p 'line "?") (hash-ref p 'column "?") (hash-ref p 'message ""))))
        (when (pair? own) (error 'stage (string-join own "\n")))
        (define rs (filter instance? (map (lambda (row) (hash-ref row 'resource)) (run-result-rows r))))
        (when (null? rs) (error 'stage "the FSH defines no instance"))
        rs)
      (lambda () (when (file-exists? tmp) (delete-file tmp)) (refresh! h)))]
    [(list? given) (append-map (lambda (r) (if (hash? r) (bundle-resources r) (error 'stage "each resource is a JSON object"))) given)]
    [(string? result)
     (define st (or (result-of h result) (error 'stage (format "no result ~a" result))))
     (define rs (for/list ([row (in-list (run-result-rows (stored-result st)))] #:when (and (hash? row) (hash? (hash-ref row 'resource #f)))) (hash-ref row 'resource)))
     (when (null? rs) (error 'stage (format "~a holds no resources (an FML or FSH run does)" result)))
     (filter instance? rs)]
    [(string? path)
     (define full (inside h path))
     (match (workspace-language-of full)
       ["fhir" (bundle-resources (call-with-input-file full read-json))]
       ["fsh" (define r (execute h "fsh" full (file->string full) (hasheq)))
              (filter instance? (map (lambda (row) (hash-ref row 'resource)) (run-result-rows r)))]
       [_ (error 'stage "stage takes resources, a result of a run, an FSH file's instances or a JSON file")])]
    [else (error 'stage "stage takes `resources`, `fsh`, `result` or `path`")]))

;; json-diff : a b -> (listof string)   where two JSON values differ and how, one line each:
;; `valueQuantity.value: 8 → 8.4`, `note: added [{"text":"…"}]`, `status: removed "final"`
;; (a history or a stage reads as what changed, not only where; a long value is cut at 60 characters)
(define (json-diff a b [prefix ""])
  (define (at k) (if (string=? prefix "") (format "~a" k) (format "~a.~a" prefix k)))
  (define (shown v)
    (define t (jsexpr->string v))
    (if (> (string-length t) 60) (string-append (substring t 0 57) "…") t))
  (cond [(and (hash? a) (hash? b))
         (append* (for/list ([k (in-list (sort (remove-duplicates (append (hash-keys a) (hash-keys b))) symbol<?))]
                             #:unless (memq k '(meta text)))
                    (json-diff (hash-ref a k 'null) (hash-ref b k 'null) (at k))))]
        [(and (list? a) (list? b) (= (length a) (length b)))
         (append* (for/list ([x (in-list a)] [y (in-list b)] [i (in-naturals)]) (json-diff x y (format "~a[~a]" prefix i))))]
        [(equal? a b) '()]
        [else
         (define where (if (string=? prefix "") "(whole resource)" prefix))
         (list (cond [(eq? a 'null) (format "~a: added ~a" where (shown b))]
                     [(eq? b 'null) (format "~a: removed ~a" where (shown a))]
                     [else (format "~a: ~a → ~a" where (shown a) (shown b))]))]))

(define (validation-errors r) (validation-issues r '("error" "fatal")))
;; validation-issues : resource severities -> (listof string)   "path: message" for each issue of those
;; severities (a stage's warnings: a unit that is not UCUM, said without refusing the change)
(define (validation-issues r severities)
  (with-handlers ([exn:fail:operation? (lambda (e) (if (member "error" severities) (list (format "~a" (exn-message e))) '()))]
                  [exn:fail? (lambda (_) '())])
    (for/list ([i (in-list (hash-ref (apply-operation "$validate" r) 'issue '()))]
               #:when (member (hash-ref i 'severity #f) severities))
      (format "~a: ~a" (let ([e (hash-ref i 'expression (hash-ref i 'location '()))]) (if (pair? e) (car e) "")) (hash-ref i 'diagnostics (hash-ref i 'code ""))))))

(define (hub-stage! h args)
  (match (hash-ref args 'drop #f)
    ["all" (for ([id (in-list (pending-stage-ids h))]) (drop-stage! h id))      ; every stage not committed
           (hasheq 'dropped "all" 'stages (pending-stage-ids h))]
    [(? string? id) (drop-stage! h id)]
    [_ (stage! h args)]))

;; drop-stage! : hub id -> jsexpr   a stage discarded (one not committed)
(define (drop-stage! h id)
  (unless (stage-of h id)
    (error 'stage (format "no stage ~a to drop~a" id (let ([ids (pending-stage-ids h)]) (if (null? ids) "" (format " (stages: ~a)" (string-join ids ", ")))))))
  (hash-remove! (hub-stages h) id)
  ;; kept as dropped-stage-N, as a commit keeps committed-stage-N: its number is never handed out
  ;; again (a script still holding the id cannot commit other data under it)
  (let ([f (build-path (state-dir h "stages") (string-append id ".json"))])
    (when (file-exists? f) (rename-file-or-directory f (build-path (state-dir h "stages") (string-append "dropped-" id ".json")) #t)))
  (hasheq 'dropped id 'stages (pending-stage-ids h)))

;; pending-stage-ids : hub -> (listof id)   the stages not committed (in memory or saved)
(define (pending-stage-ids h)
  (define saved (filter (lambda (n) (regexp-match? #rx"^stage-" n)) (saved-names h "stages")))
  (sort (remove-duplicates (append saved (hash-keys (hub-stages h))))
        < #:key (lambda (n) (or (string->number (regexp-replace #rx"^[^0-9]*" n "")) 0))))

;; describe-stages : hub -> jsexpr   each stage not committed: its changes, errors and source
(define (describe-stages h)
  (hasheq 'stages
          (for/list ([id (in-list (pending-stage-ids h))] #:when (stage-of h id))
            (define st (stage-of h id))
            (define cs (staged-changes st))
            (hasheq 'stage id
                    'changes (length cs)
                    'errors (for/sum ([c (in-list cs)]) (length (change-errors c)))
                    'resources (for/list ([c (in-list cs)])
                                 (format "~a ~a/~a" (change-action c) (hash-ref (change-resource c) 'resourceType "?") (hash-ref (change-resource c) 'id "(new id)")))
                    'source (let ([src (staged-source st)]) (or (hash-ref src 'path #f) (hash-ref src 'kind "resources")))))))

(define (stage! h args)
  (refresh! h)
  (with-hub h
    (lambda ()
      (define rs (map (lambda (r) (with-profiles h r)) (staged-resources h args)))
      (define source (stage-source h args))
      ;; FSH written in the stage: each resource's errors name its instance's line in that text
      (define (at-line r errors)
        (define fsh (and (equal? (hash-ref source 'kind #f) "fsh") (hash-ref source 'text #f)))
        (define line (and fsh (hash-ref r 'id #f) (instance-line fsh (hash-ref r 'id))))
        ;; at the rule that wrote the element the error is about, when the instance has one; else at
        ;; the instance's header (a missing element has no rule to point at)
        (if line
            (map (lambda (e) (format "~a:~a: ~a" (hash-ref source 'path "fsh")
                                     (or (rule-line fsh line (error-element e)) line) e))
                 (remove-duplicates errors))
            (remove-duplicates errors)))
      (when (null? rs) (error 'stage "nothing to stage"))
      (define warned (make-hasheq))                   ; resource -> its validation warnings, at their lines
      (define changes
        (for/list ([r (in-list rs)])
          (define current (and (hash-ref r 'id #f) ((data-source-read (current-data-source)) (hash-ref r 'resourceType) (hash-ref r 'id))))
          (define paths (if current (json-diff current r) '()))
          (hash-set! warned r (at-line r (validation-issues r '("warning"))))
          (change r (cond [(not current) 'create] [(null? paths) 'unchanged] [else 'update]) paths (at-line r (validation-errors r)))))
      (define id (format "stage-~a" (next-number h "stages" "stage-" (hub-stages h))))
      (hash-set! (hub-stages h) id (staged changes source))
      (save-state! h "stages" id (lambda () (staged->jsexpr (staged changes source))))
      (define errors (for/sum ([c (in-list changes)]) (length (change-errors c))))
      (define dangling (dangling-references h rs))
      (hasheq 'stage id
              'target (hub-data-label h)
              'changes (for/list ([c (in-list changes)])
                         (define base (hasheq 'resource (format "~a/~a" (hash-ref (change-resource c) 'resourceType) (hash-ref (change-resource c) 'id "(new id)"))
                                              'action (symbol->string (change-action c))
                                              'changed (if (eq? (change-action c) 'create) "created" (take (change-paths c) (min 30 (length (change-paths c)))))
                                              'errors (change-errors c)))
                         (define ws (append (hash-ref warned (change-resource c) '()) (hash-ref dangling (change-resource c) '())))
                         (if (null? ws) base (hash-set base 'warnings ws)))
              'errors errors
              'next (if (zero? errors) (format "commit(\"~a\") writes the ~a change(s)" id (count (lambda (c) (not (eq? (change-action c) 'unchanged))) changes))
                        "fix the errors, then stage again: a stage with errors is not committed")))))

;; dangling-references : hub (listof resource) -> (hash resource -> (listof string))   each literal
;; reference (`Patient/pat-a`) to a resource neither in the data nor in this stage: a warning, not an
;; error (the patient may come in a later stage), so a typo in an id is seen before it is committed
(define (dangling-references h rs)
  (define staged-keys (for/set ([r (in-list rs)] #:when (hash-ref r 'id #f))
                        (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id))))
  (define read (data-source-read (current-data-source)))
  (define known (make-hash))
  (define (exists? ref)
    (hash-ref! known ref
               (lambda ()
                 (or (set-member? staged-keys ref)
                     (let ([m (regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" ref)])
                       (or (not m)                                     ; not a literal Type/id reference: not ours to judge
                           (with-handlers ([exn:fail? (lambda (_) #t)]) (and (read (cadr m) (caddr m)) #t))))))))
  (define (refs v path)
    (cond [(hash? v)
           (append (let ([r (hash-ref v 'reference #f)]) (if (and (string? r) (not (exists? r))) (list (cons path r)) '()))
                   (append* (for/list ([(k x) (in-hash v)] #:unless (eq? k 'contained))
                              (refs x (if (string=? path "") (symbol->string k) (format "~a.~a" path k))))))]
          [(list? v) (append* (for/list ([x (in-list v)] [i (in-naturals)]) (refs x (format "~a[~a]" path i))))]
          [else '()]))
  ;; the ids a misspelt one may have meant: the type's stored and staged ids
  (define (ids-of type)
    (append (for/list ([k (in-set staged-keys)] #:when (string-prefix? k (string-append type "/"))) (substring k (add1 (string-length type))))
            (with-handlers ([exn:fail? (lambda (_) '())])
              (let ([all ((data-source-all (current-data-source)) type)])
                (for/list ([x (in-list all)] [_ (in-range 5000)] #:when (string? (hash-ref x 'id #f))) (hash-ref x 'id))))))
  (define (suggestion ref)
    (define m (regexp-match #px"^([A-Z][A-Za-z]+)/(.+)$" ref))
    (define near (if m (closest-names (caddr m) (ids-of (cadr m))) '()))
    (if (null? near) "" (format " (did you mean ~a?)" (string-join (map (lambda (n) (format "`~a/~a`" (cadr m) n)) near) " or "))))
  (for/hash ([r (in-list rs)])
    (values r (for/list ([pr (in-list (refs r ""))])
                (format "~a: ~a is neither in the data nor in this stage~a" (car pr) (cdr pr) (suggestion (cdr pr)))))))

(define (hub-commit! h id0 [reason #f])
  ;; `latest`: the newest stage not committed (from the shell, a stage's id is in its own answer)
  (define id (if (equal? id0 "latest")
                 (let ([ids (pending-stage-ids h)]) (if (null? ids) (error 'commit "no stage to commit (stage something first)") (last ids)))
                 id0))
  (define st (or (stage-of h id)
                 (error 'commit (format "no stage ~a~a" id
                                        (let ([ids (filter (lambda (n) (regexp-match? #rx"^stage-" n)) (saved-names h "stages"))])
                                          (if (null? ids) " (stage something first)" (format " (stages: ~a)" (string-join ids ", "))))))))
  (define changes (staged-changes st))
  (define errors (for/sum ([c (in-list changes)]) (length (change-errors c))))
  (unless (zero? errors) (error 'commit (format "~a has ~a validation error(s); fix them and stage again" id errors)))
  (define todo (filter (lambda (c) (not (eq? (change-action c) 'unchanged))) changes))
  (define c (workspace-config (hub-ws h)))
  (define d (ws-config-data c))
  (define written
    (cond
      [(not d) (error 'commit "there is no data to write to: set `data` in workspace.yaml")]
      [(rest-url? d)
       (unless (ws-config-allow-remote-writes? c)
         (error 'commit (format "~a is read-only for this workspace: set allowRemoteWrites: true in workspace.yaml to write to it" d)))
       (define auth (getenv "FHIR_AUTHORIZATION"))
       (for/list ([ch (in-list todo)])
         (define-values (status body) (rest-write! d (change-resource ch) #:headers (if auth (list (string-append "Authorization: " auth)) '())))
         (hasheq 'resource (format "~a/~a" (hash-ref (change-resource ch) 'resourceType) (hash-ref (change-resource ch) 'id "(new)"))
                 'status status 'ok (<= 200 status 299)))]
      [(store-file? d) (commit-to-store h todo)]
      [else
       (define dir (simplify-path (path->complete-path d (hub-root h))))
       (unless (directory-exists? dir) (error 'commit (format "data ~a is a file, not a directory: commit writes to a SQLite store, a directory or a FHIR server" d)))
       (define where (resource-files dir))
       ;; every target decided before anything is written
       (define plan
         (for/list ([ch (in-list todo)])
           (define r (change-resource ch))
           (define r* (if (hash-ref r 'id #f) r (hash-set r 'id (new-id))))
           (define key (cons (hash-ref r* 'resourceType) (hash-ref r* 'id)))
           (define f (hash-ref where key #f))
           (when (and f (eq? (cdr f) 'bundle))
             (error 'commit (format "~a/~a sits in the Bundle ~a: change it there" (car key) (cdr key) (car f))))
           (cons r* (if f (car f) (build-path dir (format "~a-~a.json" (car key) (cdr key)))))))
       (for/list ([p (in-list plan)])
         (call-with-output-file (cdr p) (lambda (o) (write-json (car p) o)) #:exists 'truncate/replace)
         (hasheq 'resource (format "~a/~a" (hash-ref (car p) 'resourceType) (hash-ref (car p) 'id)) 'file (path-string (cdr p)) 'ok #t))]))
  (hash-remove! (hub-stages h) id)
  ;; kept as committed-stage-N: its number is never handed out again
  (let ([f (build-path (state-dir h "stages") (string-append id ".json"))])
    (when (file-exists? f) (rename-file-or-directory f (build-path (state-dir h "stages") (string-append "committed-" id ".json")) #t)))
  ;; the trail: a Provenance and an AuditEvent in the data, naming the versions written
  (define targets (for/list ([w (in-list written)] [ch (in-list todo)] #:when (hash-ref w 'ok #f))
                    (list (hash-ref w 'version (hash-ref w 'resource)) (if (eq? (change-action ch) 'create) 'create 'update))))
  (define trail (if (null? targets) '() (write-trail! h (list (provenance targets (staged-source st) reason (unbox current-agent) (now-instant))
                                                               (commit-audit (ws-config-fhir-version c) targets (unbox current-agent) (now-instant))))))
  (configure! h (hub-root h))                              ; the data read again
  ;; who the trail names: said, so an unnamed shell is noticed (FHIR_MCP_AGENT names it)
  (define agent (unbox current-agent))
  (define answer (hasheq 'stage id 'written (for/list ([w (in-list written)]) (hash-remove w 'version))
                         'provenance (if (pair? trail) (car trail) 'null) 'agent agent))
  (if (equal? agent "raco fhir-mcp call")
      (hash-set answer 'note "the trail names the agent \"raco fhir-mcp call\"; set FHIR_MCP_AGENT to name who is writing")
      answer))

;; instance-line : fsh-text id -> line | #f   where `Instance: <id>` (or an instance with `* id = "<id>"`) starts
(define (instance-line text id)
  (define lines (regexp-split #rx"\n" text))
  (or (for/first ([l (in-list lines)] [i (in-naturals 1)]
                  #:when (regexp-match? (pregexp (string-append "^Instance:\\s*" (regexp-quote id) "\\s*$")) l))
        i)
      (let loop ([ls lines] [i 1] [start #f])
        (cond [(null? ls) #f]
              [(regexp-match? #px"^Instance:" (car ls)) (loop (cdr ls) (add1 i) i)]
              [(and start (regexp-match? (pregexp (string-append "^\\*\\s*id\\s*=\\s*\"" (regexp-quote id) "\"")) (car ls))) start]
              [else (loop (cdr ls) (add1 i) start)]))))

;; error-element : error-text -> path|#f   the element an error is about: what an invariant found
;; (`… (found component[0].valueQuantity = 20 'kPa')` -> component[0].valueQuantity; "found no …" is
;; about what is missing, so no rule wrote it), else the path's first step
;; (`Observation.component[1].value[x]: …` -> component)
(define (error-element e)
  (cond [(regexp-match #px"[(]found (?!no )([A-Za-z][A-Za-z0-9_.\\[\\]]*)" e) => cadr]
        [(regexp-match? #px"[(]found no " e) #f]
        [(regexp-match #px"^[A-Z][A-Za-z]*[.]([a-z][A-Za-z0-9_.\\[\\]]*):" e) => cadr]
        [else #f]))

;; rule-line : fsh-text instance-line path|#f -> line|#f   the first rule of that instance writing the
;; element: the whole path (`* component[0].valueQuantity = …`), else ever shorter prefixes of it
;; (`* component[0]…`, `* component…`); `value` also matches its choice keys (`* valueQuantity`)
(define (rule-line text start element)
  (define lines (drop (regexp-split #rx"\n" text) start))
  ;; a step as an FSH rule may write it: `component` as `component[0]` (an index or a slice name),
  ;; `value[x]` (the validator's) or `value` (FHIRPath's) as `valueQuantity`; an index given stays
  (define (step-rx st)
    (cond [(regexp-match #px"^(.*)\\[x\\]$" st) => (lambda (m) (string-append (regexp-quote (cadr m)) "[A-Za-z]*(?:\\[[^\\]]*\\])?"))]
          [(regexp-match? #px"\\[[0-9]+\\]$" st) (regexp-quote st)]
          [else (string-append (regexp-quote st) "(?:[A-Z][A-Za-z]*)?(?:\\[[^\\]]*\\])?")]))
  (define (line-of path)
    (define rx (pregexp (string-append "^\\s*\\*\\s+" (string-join (map step-rx (regexp-split #rx"[.]" path)) "[.]") "(?:[.\\s=]|$)")))
    (for/first ([l (in-list lines)]
                [i (in-naturals (add1 start))]
                #:break (regexp-match? #px"^(?:Instance|Profile|Extension|ValueSet|CodeSystem|Logical|Resource|RuleSet|Invariant|Mapping|Alias):" l)
                #:when (regexp-match? rx l))
      i))
  (and element
       (let loop ([path element])
         (or (line-of path)
             (let ([shorter (regexp-replace #px"(?:[.][^.]+|\\[[0-9]+\\])$" path "")])
               (and (not (equal? shorter path)) (loop shorter)))))))

;; stage-source : hub args -> Source   what a stage's resources are made from (trail.rkt)
(define (stage-source h args)
  (define fsh (hash-ref args 'fsh #f))
  (define path (hash-ref args 'path #f))
  (define result (hash-ref args 'result #f))
  (cond
    [(string? fsh) (let ([src (hasheq 'kind "fsh" 'language "fsh" 'text fsh)]
                         [from (argument-file args 'fsh)])
                     (if from (hash-set src 'path from) src))]
    [(string? result)
     (define st (result-of h result))
     (if st
         (for/fold ([src (hasheq 'kind "result" 'result result 'language (stored-language st))])
                   ([kv (in-list (list (cons 'path (and (stored-path st) (rel h (stored-path st))))
                                       (cons 'text (stored-text st))
                                       (cons 'entry (hash-ref (stored-options st) 'entry #f))))]
                    #:when (string? (cdr kv)))
           (hash-set src (car kv) (cdr kv)))
         (hasheq 'kind "result" 'result result))]
    [(string? path)
     (define full (inside h path))
     (hasheq 'kind "file" 'path path 'language (or (workspace-language-of full) "fhir")
             'text (if (file-exists? full) (file->string full) ""))]
    [else (hasheq 'kind "resources")]))

;; with-profiles : hub resource -> resource   the workspace's profiles for its type (workspace.yaml
;; `profiles`) claimed in meta.profile, so validation holds it to them and the data says so
(define (with-profiles h r)
  (define urls (hash-ref (ws-config-profiles (workspace-config (hub-ws h))) (hash-ref r 'resourceType "") '()))
  (cond
    [(null? urls) r]
    [else
     (define meta (let ([m (hash-ref r 'meta #f)]) (if (hash? m) m (hasheq))))
     (define claimed (let ([p (hash-ref meta 'profile '())]) (if (list? p) p '())))
     (hash-set r 'meta (hash-set meta 'profile (append claimed (filter (lambda (u) (not (member u claimed))) urls))))]))

;; write-trail! : hub (listof resource) -> (listof "Type/id")   the trail written where the data is
(define (write-trail! h resources)
  (define c (workspace-config (hub-ws h)))
  (define d (ws-config-data c))
  (with-handlers ([exn:fail? (lambda (e) (log-warning "fhir-mcp: the trail was not written: ~a" (exn-message e)) '())])
    (cond
      [(store-file? d)
       (define-values (store catalog) (open-store (data-store-path h) (hub-packages h)))
       (define create! (dynamic-require 'fhir/store/fhir-engine 'fhir-create!))
       (for/list ([r (in-list resources)])
         (define-values (t id _v) (create! store r #:search-params catalog))
         (format "~a/~a" t id))]
      [(rest-url? d) '()]                                  ; a server keeps its own audit trail
      [(and d (directory-exists? (simplify-path (path->complete-path d (hub-root h)))))
       (for/list ([r (in-list resources)])
         (define id (new-id))
         (call-with-output-file (build-path (simplify-path (path->complete-path d (hub-root h))) (format "~a-~a.json" (hash-ref r 'resourceType) id))
           (lambda (o) (write-json (hash-set r 'id id) o)) #:exists 'error)
         (format "~a/~a" (hash-ref r 'resourceType) id))]
      [else '()])))

(define (now-instant)
  (define d (seconds->date (current-seconds) #f))
  (format "~a-~a-~aT~a:~a:~aZ" (date-year d) (pad (date-month d)) (pad (date-day d)) (pad (date-hour d)) (pad (date-minute d)) (pad (date-second d))))
(define (pad n) (if (< n 10) (format "0~a" n) (number->string n)))

;; commit-to-store : hub changes -> written   one FHIR transaction: a resource with an id is PUT (its
;; id kept, a new version if it exists), one without is POSTed (the store gives it an id); all or none
(define (commit-to-store h todo)
  (define-values (store catalog) (open-store (data-store-path h) (hub-packages h)))
  (define bundle
    (hasheq 'resourceType "Bundle" 'type "transaction"
            'entry (for/list ([ch (in-list todo)])
                     (define r (change-resource ch))
                     (hasheq 'resource r
                             'request (if (hash-ref r 'id #f)
                                          (hasheq 'method "PUT" 'url (format "~a/~a" (hash-ref r 'resourceType) (hash-ref r 'id)))
                                          (hasheq 'method "POST" 'url (hash-ref r 'resourceType)))))))
  (define resp ((dynamic-require 'fhir/store/bundle 'process-bundle!) store bundle #:search-params catalog
                #:tower (if (workspace-r4? (hub-ws h)) 'fhir/r4/schemas 'fhir/r5/schemas)))
  (for/list ([e (in-list (hash-ref resp 'entry '()))] [ch (in-list todo)])
    (define r (hash-ref e 'response (hasheq)))
    (define status (hash-ref r 'status ""))
    (define loc (hash-ref r 'location #f))
    (define ref (if (string? loc) (regexp-replace #rx"/_history/.*$" loc "")
                    (format "~a/~a" (hash-ref (change-resource ch) 'resourceType) (hash-ref (change-resource ch) 'id "(new)"))))
    (hasheq 'resource ref 'version (if (string? loc) loc ref)
            'status status 'ok (regexp-match? #rx"^2" status))))

;; resource-files : dir -> (hash (cons type id) -> (cons file 'resource|'bundle))
(define (resource-files dir)
  (for*/fold ([acc (hash)]) ([f (in-directory dir)] #:when (regexp-match? #rx"[.]json$" (path->string f))
                             [js (in-value (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))]
                             #:when (hash? js))
    (define bundle? (equal? (hash-ref js 'resourceType #f) "Bundle"))
    (for/fold ([acc acc]) ([r (in-list (bundle-resources js))] #:when (and (hash-ref r 'resourceType #f) (hash-ref r 'id #f)))
      (hash-set acc (cons (hash-ref r 'resourceType) (hash-ref r 'id)) (cons f (if bundle? 'bundle 'resource))))))
(define (new-id) (format "ws-~a-~a" (current-seconds) (random 1000000)))
