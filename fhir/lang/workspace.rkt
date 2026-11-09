#lang racket/base

;;; lang/workspace.rkt — the contract a language keeps with a workspace: a directory of source files
;;; in the family's languages and FHIR JSON that an agent writes, checks, runs and asks to explain.
;;;
;;; Each language provides, in its `<id>/workspace` module, one WsSupport value named
;;; `workspace-support`; a hub (fhir-mcp) loads it by collection name and knows no language internals.
;;; What the languages' files define is registered in fhir/registry, so they see each other: a CQL
;;; library uses a value set written in VCL by its canonical, examples validate against profiles
;;; written in FSH, a map's output against its target's profile.
;;;
;;; A Workspace is (workspace root config): the directory and its configuration.
;;; A WsConfig is (ws-config fhir-version canonical packages data parameters allow-remote-writes? models)
;;;   fhir-version : string                 "4.0.1" (the default) or "5.0.0"; every language follows it
;;;   canonical    : string                 the base of the canonicals the workspace defines
;;;   packages     : (listof string)        FHIR packages (a .tgz path or a package name) in context
;;;   data         : string | #f            a directory, a JSON file (a Bundle, a resource), or the base
;;;                                         url of a FHIR server (read-only unless writes are allowed)
;;;   parameters   : (hash string -> string)  CQL parameter values, each a CQL expression
;;;   allow-remote-writes? : boolean        whether `commit` may write to a FHIR server
;;;   models       : (hash name -> string)  data models made from the workspace's logical models, for
;;;                                         CQL's `using <name>`: "<canonical> [patient=<Class>]
;;;                                         [birthDate=<element>] [key=<element>] [version=<v>]" — the
;;;                                         logical models whose canonical starts with <canonical>
;;; read from `workspace.yaml` (a small YAML subset: `key: value`, lists of `- item`, one level of
;;; `key: value` maps) when the directory has one.
;;;
;;; A WsSupport is (ws-support id artifacts run explain)
;;;   id        : the language id ("fsh", "cql", "fml", "vcl", "fhirpath", "sql-on-fhir", "capability")
;;;   artifacts : workspace (listof (cons path text)) -> (values (listof resource) (listof diagnostic))
;;;               what the language's files define, as FHIR resources, and every problem in them
;;;   run       : workspace path|#f text options -> RunResult
;;;               a file run against the data source (or ad-hoc text, with no path); raises
;;;               exn:fail:diagnostic for a positioned problem, exn:fail otherwise
;;;   explain   : workspace path|#f text subject options -> jsexpr
;;;               why the run answered what it did for one subject (a patient, a resource, a row),
;;;               each step positioned in the source
;;;   (either may be #f: the language does not run, or does not explain)
;;; The module may also provide `guide`, a string: the language's guide for agents (its repository's
;;; guide.md — the language, how to run it, its official references), which a hub serves.
;;; Options is a hash: 'entry (a define, a group…|#f), 'over (a resource type, "Type/id"|#f),
;;; 'parameters (hash name -> CQL expression), 'limit.
;;; A RunResult is (run-result kind columns rows summary)
;;;   kind    : "patients" | "resources" | "rows" | "values" | "expansion" | "transform"
;;;   columns : (listof string)    the keys of each row, in order
;;;   rows    : (listof jsexpr)    one hash per row
;;;   summary : jsexpr             counts and totals, small enough to read whole

(require racket/contract racket/string racket/list racket/path racket/file
         (only-in "support.rkt" language-id-of)
         (only-in "../spec-package.rkt" spec-package-path))

(provide
 (struct-out workspace) (struct-out ws-config) (struct-out ws-support) (struct-out run-result)
 (contract-out
  [workspace-languages (listof string?)]
  ;; workspace-language-of : path -> id | "fhir" | #f   a ViewDefinition is `*.view.json`; any other
  ;; `.json` is a FHIR resource
  [workspace-language-of (-> path-string? (or/c string? #f))]
  ;; workspace-support : id -> ws-support|#f   loaded from `<id>/workspace`; #f when not installed
  [workspace-support (-> string? (or/c ws-support? #f))]
  [current-workspace-supports (parameter/c (hash/c string? ws-support?))]
  ;; workspace-guide : id -> string|#f   the `guide` its `<id>/workspace` provides; #f when the
  ;; language is not installed or provides none
  [workspace-guide (-> string? (or/c string? #f))]
  [default-ws-config ws-config?]
  ;; read-workspace-config : path -> (values ws-config (listof string))   the config and its warnings
  [read-workspace-config (-> path-string? (values ws-config? (listof string?)))]
  [parse-workspace-config (-> string? (values ws-config? (listof string?)))]
  ;; open-workspace : dir -> (values workspace warnings)   workspace.yaml read when present
  [open-workspace (-> path-string? (values workspace? (listof string?)))]
  ;; workspace-files : workspace -> (listof path)   every file of a workspace language, sorted;
  ;; the data directory (when inside the workspace) and hidden directories left out
  [workspace-files (-> workspace? (listof path?))]
  ;; workspace-r4? : workspace -> boolean
  [workspace-r4? (-> workspace? boolean?)]
  ;; file-canonical : workspace kind path -> url   `<canonical>/<kind>/<file stem>`: the canonical a
  ;; file that names none is given (a VCL value set, a ViewDefinition)
  [file-canonical (-> workspace? string? path-string? string?)]
  [file-stem (-> path-string? string?)]
  ;; workspace-packages : workspace -> (values paths missing)   the configured packages: a .tgz path
  ;; (relative to the workspace), else a package in fhir-spec or FHIR_PACKAGE_PATH by name
  ;; (`hl7.fhir.us.core-6.1.0`); the names not found
  [workspace-packages (-> workspace? (values (listof path?) (listof string?)))]
  ;; workspace-core-package : workspace -> path|#f   the core package of its FHIR version
  [workspace-core-package (-> workspace? (or/c path? #f))]))

(struct workspace (root config) #:transparent)
(struct ws-config (fhir-version canonical packages data parameters allow-remote-writes? models) #:transparent)
(struct ws-support (id artifacts run explain) #:transparent)
(struct run-result (kind columns rows summary) #:transparent)

(define workspace-languages '("fsh" "cql" "fml" "vcl" "fhirpath" "sql-on-fhir" "capability"))
;; support-module : id -> module name   `<id>/workspace`, but for capability apps (`#lang
;; fhir/capability`, fhir-server's), whose collection is fhir
(define (support-module id)
  (if (equal? id "capability") 'fhir/capability/workspace (string->symbol (string-append id "/workspace"))))

(define (workspace-language-of p)
  (define s (string-downcase (if (path? p) (path->string p) p)))
  (cond [(regexp-match? #rx"[.]view[.]json$" s) "sql-on-fhir"]
        [(regexp-match? #rx"[.]capability[.]rkt$" s) "capability"]
        [(regexp-match? #rx"[.]json$" s) "fhir"]
        [else (language-id-of p)]))

(define loaded (make-hash))
(define guides (make-hash))
(define (workspace-guide id)
  (hash-ref! guides id
             (lambda ()
               (and (member id workspace-languages)
                    (with-handlers ([exn:fail:filesystem:missing-module? (lambda (_) #f)]
                                    [exn:fail:syntax:missing-module? (lambda (_) #f)])
                      (define g (dynamic-require (support-module id) 'guide (lambda () #f)))
                      (and (string? g) g))))))
(define current-workspace-supports (make-parameter (hash)))
(define (workspace-support id)
  (or (hash-ref (current-workspace-supports) id #f)
      (hash-ref! loaded id
                 (lambda ()
                   (and (member id workspace-languages)
                        (with-handlers ([exn:fail:filesystem:missing-module? (lambda (_) #f)]
                                        [exn:fail:syntax:missing-module? (lambda (_) #f)])
                          (define v (dynamic-require (support-module id) 'workspace-support))
                          (and (ws-support? v) v)))))))

;; ---- configuration --------------------------------------------------------------------------
(define default-ws-config (ws-config "4.0.1" "http://example.org/workspace" '() #f (hash) #f (hash)))

;; A Yaml here is: string | (listof string) | (listof (cons string string))
;; parse-yaml-subset : text -> (values (listof (cons key Yaml)) warnings)
(define (unquote-scalar s)
  (define t (string-trim s))
  (cond [(regexp-match #px"^\"(.*)\"$" t) => cadr]
        [(regexp-match #px"^'(.*)'$" t) => cadr]
        [else t]))
(define (strip-comment line)
  ;; a `#` at the start or after a space begins a comment, outside quotes
  (let loop ([i 0] [q #f])
    (cond [(>= i (string-length line)) line]
          [else (define c (string-ref line i))
                (cond [(and (not q) (memv c '(#\" #\'))) (loop (add1 i) c)]
                      [(and q (eqv? c q)) (loop (add1 i) #f)]
                      [(and (not q) (eqv? c #\#) (or (= i 0) (char-whitespace? (string-ref line (sub1 i))))) (substring line 0 i)]
                      [else (loop (add1 i) q)])])))
(define (parse-yaml-subset text)
  (define lines (for/list ([l (in-list (regexp-split #rx"\r?\n" text))]
                           #:unless (string=? (string-trim (strip-comment l)) ""))
                  (strip-comment l)))
  (let loop ([ls lines] [acc '()] [warnings '()])
    (cond
      [(null? ls) (values (reverse acc) (reverse warnings))]
      [else
       (define l (car ls))
       (define m (regexp-match #px"^([A-Za-z][A-Za-z0-9_-]*)\\s*:\\s*(.*)$" l))
       (cond
         [(not m) (loop (cdr ls) acc (cons (format "workspace.yaml: cannot read the line `~a`" (string-trim l)) warnings))]
         [(not (string=? (string-trim (caddr m)) "")) (loop (cdr ls) (cons (cons (cadr m) (unquote-scalar (caddr m))) acc) warnings)]
         [else
          ;; the indented block below the key: a list or a map
          (define-values (block rest) (splitf-at (cdr ls) (lambda (x) (regexp-match? #px"^\\s+\\S" x))))
          (define items
            (for/list ([b (in-list block)])
              (cond [(regexp-match #px"^\\s+-\\s*(.*)$" b) => (lambda (m) (unquote-scalar (cadr m)))]
                    [(regexp-match #px"^\\s+(\"[^\"]*\"|'[^']*'|[^:]+?)\\s*:\\s*(.*)$" b)
                     => (lambda (m) (cons (unquote-scalar (cadr m)) (unquote-scalar (caddr m))))]
                    [else (string-trim b)])))
          (loop rest (cons (cons (cadr m) items) acc) warnings)])])))

(define known-keys '("fhirVersion" "canonical" "packages" "data" "parameters" "allowRemoteWrites" "models"))

(define (parse-workspace-config text)
  (define-values (kvs warnings) (parse-yaml-subset text))
  (define (get k) (let ([p (assoc k kvs)]) (and p (cdr p))))
  (define (str k d) (let ([v (get k)]) (if (and (string? v) (not (string=? v ""))) v d)))
  (define (strings k) (let ([v (get k)]) (cond [(string? v) (list v)] [(list? v) (filter string? v)] [else '()])))
  (define (pairs k) (let ([v (get k)]) (if (list? v) (for/hash ([p (in-list v)] #:when (pair? p)) (values (car p) (cdr p))) (hash))))
  (define params (pairs "parameters"))
  (define version (str "fhirVersion" (ws-config-fhir-version default-ws-config)))
  (define unknown (for/list ([kv (in-list kvs)] #:unless (member (car kv) known-keys))
                    (format "workspace.yaml: unknown key `~a` (known: ~a)" (car kv) (string-join known-keys ", "))))
  (define version-warning
    (if (regexp-match? #rx"^[45][.]" version) '()
        (list (format "workspace.yaml: fhirVersion ~a is not one this workspace runs (4.0.1 or 5.0.0)" version))))
  (values (ws-config version
                     (regexp-replace #rx"/+$" (str "canonical" (ws-config-canonical default-ws-config)) "")
                     (strings "packages")
                     (str "data" #f)
                     params
                     (and (member (str "allowRemoteWrites" "false") '("true" "yes")) #t)
                     (pairs "models"))
          (append warnings unknown version-warning)))

(define (read-workspace-config f) (parse-workspace-config (file->string f)))

(define (open-workspace dir)
  (define root (simplify-path (path->complete-path dir)))
  (define f (build-path root "workspace.yaml"))
  (if (file-exists? f)
      (let-values ([(c ws) (read-workspace-config f)]) (values (workspace root c) ws))
      (values (workspace root default-ws-config) '())))

(define (workspace-r4? ws) (regexp-match? #rx"^4[.]" (ws-config-fhir-version (workspace-config ws))))

(define (workspace-files ws)
  (define root (workspace-root ws))
  ;; compared as directory paths: `data: data/` is the directory `data` (with the slash, it never
  ;; matched, and every data file was taken for one of the workspace's own)
  (define data (let ([d (ws-config-data (workspace-config ws))])
                 (and d (not (regexp-match? #rx"^https?://" d))
                      (path->directory-path (simplify-path (path->complete-path d root))))))
  (define (skip-dir? p)
    (define name (let-values ([(_b n _d) (split-path p)]) (path->string n)))
    (or (regexp-match? #rx"^[.]" name) (equal? name "compiled")
        (and data (equal? (path->directory-path (simplify-path p)) data))))
  (sort (for/list ([f (in-directory root (lambda (p) (not (skip-dir? p))))]
                   #:when (file-exists? f)
                   #:when (workspace-language-of f)
                   #:unless (regexp-match? #rx"^[.]" (path->string (file-name-from-path f))))
          f)
        string<? #:key path->string))

(define (workspace-packages ws)
  (for/fold ([found '()] [missing '()] #:result (values (reverse found) (reverse missing)))
            ([p (in-list (ws-config-packages (workspace-config ws)))])
    (define f (path->complete-path p (workspace-root ws)))
    (define hit (cond [(file-exists? f) (simplify-path f)]
                      [else (spec-package-path (if (regexp-match? #rx"[.]tgz$" p) p (string-append p ".tgz")) #:optional? #t)]))
    (if hit (values (cons hit found) missing) (values found (cons p missing)))))
(define (workspace-core-package ws)
  (spec-package-path (if (workspace-r4? ws) "hl7.fhir.r4.core.tgz" "hl7.fhir.r5.core.tgz") #:optional? #t))

(define (file-stem p)
  (define n (path->string (file-name-from-path p)))
  (regexp-replace #rx"([.]view)?[.][^.]+$" n ""))
(define (file-canonical ws kind p)
  (string-append (ws-config-canonical (workspace-config ws)) "/" kind "/" (file-stem p)))

(module+ test
  (require rackunit)
  (check-equal? (workspace-language-of "a/b.view.json") "sql-on-fhir")
  (check-equal? (workspace-language-of "a/Patient-1.json") "fhir")
  (check-equal? (workspace-language-of "a/x.cql") "cql")
  (check-false (workspace-language-of "a/notes.md"))
  (define-values (c ws)
    (parse-workspace-config
     (string-append "# a workspace\nfhirVersion: 4.0.1\ncanonical: http://example.org/fhir/  # trailing slash dropped\n"
                    "packages:\n  - hl7.fhir.us.core-6.1.0\n  - \"local/x.tgz\"\n"
                    "data: https://hapi.fhir.org/baseR4\n"
                    "parameters:\n  \"Measurement Period\": Interval[@2025-01-01, @2025-12-31]\n"
                    "allowRemoteWrites: true\nmystery: 1\n"
                    "models:\n  Clinic: http://example.org/clinic patient=Member birthDate=born\n")))
  (check-equal? (ws-config-canonical c) "http://example.org/fhir")
  (check-equal? (ws-config-packages c) '("hl7.fhir.us.core-6.1.0" "local/x.tgz"))
  (check-equal? (ws-config-data c) "https://hapi.fhir.org/baseR4")
  (check-equal? (hash-ref (ws-config-parameters c) "Measurement Period") "Interval[@2025-01-01, @2025-12-31]")
  (check-true (ws-config-allow-remote-writes? c))
  (check-equal? (ws-config-models c) (hash "Clinic" "http://example.org/clinic patient=Member birthDate=born"))
  (check-equal? (length ws) 1)
  (check-regexp-match #rx"unknown key `mystery`" (car ws))
  (define-values (d _w) (parse-workspace-config ""))
  (check-equal? d default-ws-config)
  (define-values (_c3 w3) (parse-workspace-config "fhirVersion: 3.0.2\n"))
  (check-regexp-match #rx"3.0.2 is not one" (car w3))
  ;; files: the languages and JSON, not the data directory, hidden or compiled directories
  (define dir (make-temporary-directory))
  (for ([f '("a.cql" "v.vcl" "q.view.json" "notes.md" "data/Patient-1.json" ".git/x.cql" "compiled/y.cql" "sub/p.fsh")])
    (make-parent-directory* (build-path dir f))
    (with-output-to-file (build-path dir f) (lambda () (display "x"))))
  (with-output-to-file (build-path dir "workspace.yaml") (lambda () (display "data: data\ncanonical: http://x\n")))
  (define-values (w _) (open-workspace dir))
  (check-equal? (map (lambda (p) (path->string (find-relative-path (workspace-root w) p))) (workspace-files w))
                '("a.cql" "q.view.json" "sub/p.fsh" "v.vcl"))
  (check-equal? (file-canonical w "ValueSet" (build-path dir "v.vcl")) "http://x/ValueSet/v")
  (check-equal? (file-stem "q.view.json") "q")
  (check-true (workspace-r4? w))
  (check-false (workspace-support "cobol"))
  ;; `data: data/`, as the guide and `fhir-mcp init` write it, is the same directory (with the slash
  ;; it was not left out: every data file counted as one of the workspace's)
  (with-output-to-file (build-path dir "workspace.yaml") #:exists 'truncate (lambda () (display "data: data/\ncanonical: http://x\n")))
  (define-values (w2 _2) (open-workspace dir))
  (check-equal? (map (lambda (p) (path->string (find-relative-path (workspace-root w2) p))) (workspace-files w2))
                '("a.cql" "q.view.json" "sub/p.fsh" "v.vcl"))
  (delete-directory/files dir))
