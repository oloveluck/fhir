#lang racket/base

;;; functions.rkt — the functions the toolkit offers a program in another language, as one table.
;;;
;;; Start here to see what a client (clients/python, later others) can call. Each function is a row:
;;; its name, what it is for, its parameters and what it answers, and the procedure that runs it.
;;; The server (server.rkt) dispatches from the table and checks a call's arguments against it;
;;; `raco fhir-api functions --json` writes it as JSON Schema, which is kept as
;;; clients/functions.json — the one description every client is generated from or held to.
;;;
;;; A Fn is (fn name summary params returns run):
;;;   name    : string                 as a client names it: "compile", "fhirpath"
;;;   summary : string                 one sentence
;;;   params  : (listof Param)
;;;   returns : string                 the answer's shape, in words
;;;   run     : session Args -> jsexpr   Args is a hasheq of the arguments given, by name
;;; A Param is (param name type required? doc); a ParamType is one of
;;;   'string | 'boolean | 'object | 'resource (a FHIR resource as JSON) |
;;;   'files (an object of file name -> text) | 'data (resources, or a string naming where they are)
;;;
;;; Most functions take a PROJECT (session.rkt): sources in any of the languages and FHIR JSON
;;; definitions, as `files` or as a `directory`. What the project defines is in context for the
;;; call: a profile written in FSH is what `validate` holds a resource to, a value set written in
;;; VCL is what a CQL library retrieves by. A function that reads data takes `data`.
;;;
;;; A Table (what run and query answer) is {kind, columns, rows, summary}: fhir/lang/workspace's
;;; RunResult as JSON — `columns` the keys of each row in order, `rows` one object per row.
;;; A Diagnostic is fhir/diagnostic's as JSON: {lang, phase, severity, message, source, line, column}
;;; (`source` a file of the project by its name).

(require racket/contract racket/list racket/string racket/file racket/runtime-path racket/lazy-require json net/base64
         (for-syntax racket/base)
         "session.rkt"
         (only-in fhir/mcp/hub hub? hub-ws hub-root hub-diagnostics hub-warnings hub-defined with-hub inside)
         (only-in fhir/mcp/run execute hub-explain)
         (only-in fhir/mcp/tools apply-json)
         (only-in fhir/mcp/resources learn-topics learn-text)
         (only-in fhir/operation operation)
         (only-in fhir/diagnostic diagnostic loc diagnostic->jsexpr diagnostic-severity diagnostic-message
                  exn:fail:diagnostic? exn:fail:diagnostic-diagnostic)
         (only-in fhir/lang/workspace run-result-kind run-result-columns run-result-rows run-result-summary
                  workspace-language-of workspace-support ws-support-artifacts)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/lenient lenient-drops drops-message)
         (only-in fhir/result/result ok? ok-value err-error)
         (only-in fhir/model/registry pin-registered-types!))
;; staging and committing bring the trail, the artifacts' rules and the text export with them: a
;; third of what the process loads, for two functions most sessions never call
(lazy-require [fhir/mcp/stage (hub-stage! hub-commit!)])

(provide
 (struct-out fn) (struct-out param) (struct-out exn:fail:problems)
 (contract-out
  [functions (listof fn?)]
  [function-named (-> string? (or/c fn? #f))]
  ;; argument-problems : fn args -> (listof string)   what is wrong with a call's arguments
  [argument-problems (-> fn? hash? (listof string?))]
  ;; functions->jsexpr : -> jsexpr   the table as data: each function with its parameters as a JSON Schema
  [functions->jsexpr (-> jsexpr?)]
  [functions->text (-> string?)]
  ;; warm-steps : session -> (listof (-> any))   what a process's first calls each wait for, as
  ;; steps a server takes while nobody is asking (server.rkt), most likely needed first
  [warm-steps (-> session? (listof (-> any)))]
  ;; with-warnings : (-> X) -> (values X (listof string))   a call's answer with what it warned of:
  ;; something the caller should know that is no error and no part of the answer (a value of the
  ;; input that could not be read, so the answer was made without it)
  [with-warnings (-> (-> any/c) (values any/c (listof string?)))]
  ;; functions-json-text : -> string   the table as the text kept in clients/functions.json: the
  ;; same for the same table (keys by name, a value to a line)
  [functions-json-text (-> string?)]
  [protocol-version exact-positive-integer?]))

;; a call refused for problems that have places in a source the caller gave: `diagnostics` as JSON
(struct exn:fail:problems exn:fail:user (diagnostics))

(struct param (name type required? doc) #:transparent)
(struct fn (name summary params returns run) #:transparent)

;; the protocol's version: raised when a function's parameters or answer change in a way a client
;; written for the version before would get wrong
(define protocol-version 1)

;; ---- the languages, loaded when a function first needs one --------------------------------------
;; (named as runtime module paths, so a standalone build carries them)
(define-runtime-module-path-index fhirpath-eval 'fhirpath/eval)
(define-runtime-module-path-index fhirpath-parse 'fhirpath/parser/parse)
(define-runtime-module-path-index fhirpath-render 'fhirpath/render)
(define-runtime-module-path-index fhirpath-value 'fhirpath/value)
(define-runtime-module-path-index fhirpath-temporal 'fhirpath/temporal-ops)
(define-runtime-module-path-index cql-parse 'cql/parser/parse)
(define-runtime-module-path-index cql-compile 'cql/compile)
(define-runtime-module-path-index cql-error 'cql/error)
(define-runtime-module-path-index cql-run 'cql/run)
(define-runtime-module-path-index cql-elm-json 'cql/elm/json)
(define-runtime-module-path-index fsh-decompile 'fsh/decompile)
(define-runtime-module-path-index fml-print 'fml/print)
(define-runtime-module-path-index fml-structuremap 'fml/structuremap)
(define-runtime-module-path-index vcl-decompile 'vcl/decompile)
(define-runtime-module-path-index sof-decompile 'sql-on-fhir/decompile)
(define-runtime-module-path-index conformance-operations 'fhir/conformance/operations)
(define-runtime-module-path-index r4-tower 'fhir/r4/schemas)
(define-runtime-module-path-index r5-tower 'fhir/r5/schemas)

;; from : module name -> value   the module's export, or a user error naming the package to install.
;; Looked up once: `dynamic-require` resolves the module's name on disk at every call (2.3 ms each,
;; which was all but 0.03 ms of a FHIRPath call).
(define exports (make-hasheq))                  ; module path index -> (hasheq name -> value)
(define (from module name)
  (define names (hash-ref! exports module make-hasheq))
  (hash-ref! names name
             (lambda ()
               (with-handlers ([exn:fail:filesystem:missing-module?
                                (lambda (e) (raise-user-error 'fhir-api "this needs a package that is not installed: ~a" (exn-message e)))])
                 (dynamic-require module name)))))

;; ---- arguments ---------------------------------------------------------------------------------
(define (arg a name) (let ([v (hash-ref a name #f)]) (if (eq? v 'null) #f v)))

;; type-ok? : ParamType jsexpr -> boolean
(define (type-ok? type v)
  (case type
    [(string) (string? v)]
    [(boolean) (boolean? v)]
    [(object resource) (hash? v)]
    [(resources) (or (hash? v) (and (list? v) (andmap hash? v)))]
    [(files) (and (hash? v) (for/and ([x (in-hash-values v)]) (string? x)))]
    [(data) (or (string? v) (hash? v) (and (list? v) (andmap hash? v)))]
    [else #t]))

(define (type-words type)
  (case type
    [(string) "a string"] [(boolean) "true or false"] [(object) "an object"]
    [(resource) "a FHIR resource (a JSON object)"]
    [(resources) "FHIR resources (a list of JSON objects, or one: a resource or a Bundle)"]
    [(files) "an object of file name -> text"]
    [(data) "resources (a list, a resource, a Bundle) or a string naming where they are"]
    [else "a value"]))

(define (argument-problems f a)
  (define names (map param-name (fn-params f)))
  (append
   (for/list ([k (in-hash-keys a)] #:unless (member (symbol->string k) names))
     (format "`~a` is not a parameter of ~a (it takes: ~a)" k (fn-name f)
             (if (null? names) "none" (string-join names ", "))))
   (for/list ([p (in-list (fn-params f))] #:when (and (param-required? p) (not (arg a (string->symbol (param-name p))))))
     (format "~a needs `~a` (~a)" (fn-name f) (param-name p) (type-words (param-type p))))
   (for*/list ([p (in-list (fn-params f))]
               [v (in-value (arg a (string->symbol (param-name p))))]
               #:when (and v (not (type-ok? (param-type p) v))))
     (format "`~a` is ~a" (param-name p) (type-words (param-type p))))))

;; ---- what several functions share ---------------------------------------------------------------
(define p-files (param "files" 'files #f "the project: sources in any of the languages and FHIR JSON definitions, by file name (`profiles.fsh`, `Screening.cql`, `intake.map`, `labs.vcl`, `bp.sof`, `ValueSet-x.json`); what they define is in context for the call"))
(define p-directory (param "directory" 'string #f "the project as a directory on disk, in place of `files` (its workspace.yaml and sushi-config.yaml are read)"))
(define p-canonical (param "canonical" 'string #f "the base of the canonicals the project's files define when they state none (http://example.org otherwise); with `files`"))
(define p-data (param "data" 'data #f "the FHIR data to read: resources given here (a list, one resource, a Bundle), or a string naming a directory of FHIR JSON, a JSON file, a SQLite FHIR store or a FHIR server's base url"))
(define project (list p-files p-directory p-canonical))
(define p-entry (param "entry" 'string #f "the one part to run: a CQL define, a mapping group"))
(define p-over (param "over" 'string #f "what to run over: a resource type, or one resource as Type/id"))
(define p-parameters (param "parameters" 'object #f "CQL parameter values by name, each a CQL expression as text"))

;; project-of : session args -> hub
(define (project-of s a) (project-hub s (arg a 'files) (arg a 'directory) (arg a 'canonical)))

;; in-project : session args (hub -> X) -> X   the call's project, over the call's data
(define (in-project s a proc)
  (define h (project-of s a))
  ;; a problem with a place in one of the project's files names the file as the project does (a
  ;; project given as `files` is kept in a temporary directory, whose path means nothing to a caller)
  (with-handlers ([exn:fail:diagnostic?
                   (lambda (e)
                     (raise (exn:fail:problems (shown-message h (exn-message e)) (exn-continuation-marks e)
                                               (list (diagnostic-json h (exn:fail:diagnostic-diagnostic e))))))])
    (with-data s h (arg a 'data) (lambda () (proc h)))))

;; shown-source : hub source -> string   a file of the project by its name there
(define (shown-source h src)
  (define text (if (path? src) (path->string src) (format "~a" src)))
  (define root (path->string (path->directory-path (hub-root h))))
  (define full (if (and (absolute-path? text) (file-exists? text)) (path->string (simplify-path text)) text))
  (if (string-prefix? full root) (substring full (string-length root)) text))

;; shown-message : hub string -> string   a message that names a file of the project by its place on
;; disk ("constrained by profile X at /tmp/…/p-0843/profiles.fsh:3:3") names it as the project does
(define (shown-message h message)
  (string-replace message (path->string (path->directory-path (hub-root h))) ""))

;; placed : hub jsexpr -> jsexpr   a problem as JSON, its file and message in the project's names
(define (placed h js)
  (define src (hash-ref js 'source #f))
  (define message (hash-ref js 'message #f))
  (let* ([js (if src (hash-set js 'source (shown-source h src)) js)]
         [js (if (string? message) (hash-set js 'message (shown-message h message)) js)])
    js))

;; diagnostic-json : hub diagnostic -> jsexpr
(define (diagnostic-json h d) (placed h (diagnostic->jsexpr d)))

;; project-diagnostics : hub -> (listof jsexpr)   every problem of the project's files, and what
;; its configuration could not find (a package), as warnings
(define (project-diagnostics h)
  (append (for/list ([d (in-list (hub-diagnostics h))]) (diagnostic-json h d))
          (for/list ([w (in-list (hub-warnings h))])
            (hasheq 'lang "project" 'phase "configure" 'severity "warning" 'message w))))

;; table-json : hub run-result -> jsexpr   the summary's problems name their file as the project does
(define (table-json h r)
  (define summary (run-result-summary r))
  (hasheq 'kind (run-result-kind r) 'columns (run-result-columns r) 'rows (run-result-rows r)
          'summary (if (and (hash? summary) (list? (hash-ref summary 'problems #f)))
                       (hash-set summary 'problems (for/list ([p (in-list (hash-ref summary 'problems))]) (if (hash? p) (placed h p) p)))
                       summary)))

;; run-options : args -> Options (fhir/lang/workspace)
(define (run-options a)
  (for/hasheq ([k '(entry over parameters strict)] #:when (arg a k))
    (values k (let ([v (arg a k)])
                (if (eq? k 'parameters) (for/hash ([(n x) (in-hash v)]) (values (symbol->string n) (format "~a" x))) v)))))

;; tower! : session -> void   the session's FHIR types, loaded and pinned (a function that needs no
;; project reads typed resources too)
(define towers (make-hash))                     ; FHIR version -> #t, once its types are loaded and pinned
(define (tower! s)
  (hash-ref! towers (session-fhir-version s)
             (lambda ()
               (dynamic-require (if (equal? (session-fhir-version s) "4.0.1") r4-tower r5-tower) #f)
               (pin-registered-types!)
               #t))
  (void))

;; ---- warnings -----------------------------------------------------------------------------------
;; warned : (boxof (listof string)) | #f   where the call being answered collects its warnings
(define warned (make-parameter #f))
(define (with-warnings thunk)
  (define box* (box '()))
  (define v (parameterize ([warned box*]) (thunk)))
  (values v (reverse (unbox box*))))
;; warn! : string -> void
(define (warn! message)
  (define b (warned))
  (when b (set-box! b (cons message (unbox b)))))

;; unread-warning! : session jsexpr string -> void   warns of the values of a resource that a
;; lenient read leaves out (a date that is no date, an element the FHIR version lacks): what is
;; computed from the resource is computed without them, and says nothing of it by itself
(define (unread-warning! s js what)
  (when (and (hash? js) (string? (hash-ref js 'resourceType #f)))
    (tower! s)
    (define node (with-handlers ([exn:fail? (lambda (_) #f)]) (from-json js #:lenient? #t)))
    (when (and node (ok? node))
      (define drops (lenient-drops js (ok-value node)))
      (when (pair? drops)
        (warn! (format "~a ~a" what (drops-message drops (hash-ref js 'resourceType)
                                                   #:fhir (if (equal? (session-fhir-version s) "4.0.1") "FHIR R4" "FHIR R5"))))))))

;; ---- the functions ------------------------------------------------------------------------------
;; the same resource is listed once: a map beside FSH is found by fsh's project and by fml's support
(define (run-compile s a)
  (in-project s a (lambda (h) (hasheq 'resources (remove-duplicates (hub-defined h)) 'diagnostics (project-diagnostics h)))))

(define (run-run s a)
  (in-project s a
    (lambda (h)
      (define full (inside h (arg a 'path)))
      (unless (file-exists? full) (raise-user-error 'run "no file ~a in the project" (arg a 'path)))
      (define lang (or (workspace-language-of full)
                       (raise-user-error 'run "~a is not a file of the toolkit's languages" (arg a 'path))))
      (table-json h (execute h lang full (file->string full) (run-options a))))))

;; the languages a text is asked in without a file (fhir-mcp's query)
(define query-languages
  (hash "fhirpath" "fhirpath" "cql" "cql" "vcl" "vcl" "search" "search" "find" "find" "view" "sql-on-fhir" "sql" "sql"))

(define (run-query s a)
  (define lang (or (hash-ref query-languages (arg a 'language) #f)
                   (raise-user-error 'query "query takes ~a (got ~a)"
                                     (string-join (sort (hash-keys query-languages) string<?) ", ") (arg a 'language))))
  (in-project s a (lambda (h) (table-json h (execute h lang #f (arg a 'text) (run-options a))))))

(define (run-explain s a)
  (in-project s a (lambda (h) (hub-explain h (arg a 'path) (arg a 'subject) (run-options a)))))

;; run-fhirpath : one expression over one resource ({values}), or over each of several in one call
;; ({results}: a list of values for each resource, in the order given)
(define (run-fhirpath s a)
  (tower! s)
  (define one (arg a 'resource))
  (define several (arg a 'resources))
  (unless (if one (not several) several)
    (raise-user-error 'fhirpath "give `resource` (one) or `resources` (several)"))
  (define ast ((from fhirpath-parse 'parse-fhirpath) (arg a 'expression)))
  (define eval-fhirpath (from fhirpath-eval 'eval-fhirpath))
  ;; values-of : jsexpr natural|#f -> (listof jsexpr)
  (define (values-of r i)
    (define node (from-json r #:lenient? #t))
    (unless (ok? node)
      (raise-user-error 'fhirpath "~a does not read as FHIR ~a" (if i (format "resource ~a" i) "the resource") (session-fhir-version s)))
    (map value-json (eval-fhirpath ast (list (ok-value node)))))
  (if one
      (hasheq 'values (values-of one #f))
      (hasheq 'results (for/list ([r (in-list (asked-resources several))] [i (in-naturals)]) (values-of r i)))))

;; asked-resources : jsexpr -> (listof jsexpr)   the resources one question is asked of: a list's
;; items as they are — a Bundle among them is a resource like the others, so the answers line up
;; with the list — or, given a Bundle alone, the resources of its entries
(define (asked-resources several)
  (define resources
    (cond [(list? several) several]
          [(and (hash? several) (equal? (hash-ref several 'resourceType #f) "Bundle"))
           (for/list ([e (in-list (hash-ref several 'entry '()))] #:when (hash? (hash-ref e 'resource #f))) (hash-ref e 'resource))]
          [else (list several)]))
  (unless (andmap hash? resources) (raise-user-error 'resources "resources are JSON objects"))
  resources)

;; value-json : FHIRPath item -> jsexpr   as JSON holds it: FHIR JSON for an element, a number, a
;; boolean, a string — and a date, dateTime or time as FHIR JSON writes one (`1980-02-28`, not the
;; FHIRPath literal `@1980-02-28` that the renderer gives a System value)
(define (value-json v)
  (define js ((from fhirpath-render 'item->json) v))
  (define system ((from fhirpath-value 'item->system) v))
  (if (and (string? js) (not (string? system)) ((from fhirpath-temporal 'value->moment) system))
      (regexp-replace #rx"^@T?" js "")
      js))

;; run-translate : CQL text -> its ELM, with every translation error and warning. Includes are found
;; among the project's .cql files, then the libraries the toolkit carries (FHIRHelpers).
(define (run-translate s a)
  (in-project s a
    (lambda (h)
      (define name (or (arg a 'name) "library.cql"))
      (define text (regexp-replace #px"^#lang[^\n]*" (arg a 'text) ""))
      (define parsed ((from cql-parse 'parse-cql) text #:source name))
      (define (error-diagnostic e phase)
        (define d ((from cql-error 'cql-error-diagnostic) e))
        (if d
            ((from cql-error 'at-the-name) d text)
            (diagnostic 'cql phase 'error ((from cql-error 'cql-error-message) e) (loc name #f #f #f #f))))
      (cond
        [(not (ok? parsed))
         (hasheq 'elm 'null 'diagnostics (list (diagnostic-json h (error-diagnostic (err-error parsed) 'parse))))]
        [else
         (define-values (elm errors warnings)
           (with-hub h
             (lambda ()
               (parameterize ([(from cql-compile 'current-library-resolver) ((from cql-run 'directory-resolver) (hub-root h))])
                 ((from cql-compile 'compile-library/diagnostics) (ok-value parsed))))))
         (hasheq 'elm (if (and elm (null? errors)) ((from cql-elm-json 'elm->jsexpr) elm) 'null)
                 'diagnostics (for/list ([d (in-list (append (for/list ([e (in-list errors)]) (error-diagnostic e 'compile)) warnings))])
                                (diagnostic-json h d)))]))))

;; the language a resource is written back in when none is asked for
(define (source-language r)
  (case (hash-ref r 'resourceType #f)
    [("StructureMap") "fml"]
    [("ViewDefinition") "sof"]
    [("Library") (if (cql-text r) "cql" "fsh")]
    [else "fsh"]))

;; cql-text : Library -> string | #f   the library's own source, when it carries it
(define (cql-text r)
  (for/first ([c (in-list (let ([cs (hash-ref r 'content '())]) (if (list? cs) cs '())))]
              #:when (and (equal? (hash-ref c 'contentType #f) "text/cql") (string? (hash-ref c 'data #f))))
    (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (hash-ref c 'data))) #\?)))

(define (run-decompile s a)
  (define r (arg a 'resource))
  (define lang (or (arg a 'as) (source-language r)))
  (define h (project-of s a))
  (define text
    (with-hub h
      (lambda ()
        (case lang
          [("fsh") ((from fsh-decompile 'fhir->fsh) r)]
          [("fml") ((from fml-print 'fml->text) ((from fml-structuremap 'structuremap->fml) r))]
          [("sof") ((from sof-decompile 'view->sof) r)]
          [("vcl") ((from vcl-decompile 'compose->vcl)
                    (or (hash-ref r 'compose #f) (raise-user-error 'decompile "the ValueSet has no compose to write as VCL")))]
          [("cql") (or (cql-text r) (raise-user-error 'decompile "the Library carries no CQL (a content of type text/cql)"))]
          [else (raise-user-error 'decompile "a resource is written as fsh, fml, sof, vcl or cql (got ~a)" lang)]))))
  (hasheq 'language lang 'text text))

;; profile-canonical : hub string -> string   a profile named by its canonical, or by the id or name
;; of one the project defines
(define (profile-canonical h named)
  (or (and (not (regexp-match? #rx"^[a-z][a-z0-9+.-]*:" named))
           (for/first ([r (in-list (hub-defined h))]
                       #:when (and (equal? (hash-ref r 'resourceType #f) "StructureDefinition")
                                   (member named (list (hash-ref r 'id #f) (hash-ref r 'name #f)))
                                   (string? (hash-ref r 'url #f))))
             (hash-ref r 'url)))
      named))

;; run-validate : one resource (its OperationOutcome), or each of several in one call ({outcomes})
(define (run-validate s a)
  (define one (arg a 'resource))
  (define several (arg a 'resources))
  (unless (if one (not several) several)
    (raise-user-error 'validate "give `resource` (one) or `resources` (several)"))
  (in-project s a
    (lambda (h)
      (define inputs (if (arg a 'profile) (hasheq 'profile (profile-canonical h (arg a 'profile))) (hasheq)))
      ;; its own module, asked directly: `(operation "$validate")` loads every package's operations
      ;; to find it (0.3 s of a process's first validation)
      (define validate (from conformance-operations '$validate))
      (with-hub h
        (lambda ()
          (if one
              (apply-json validate inputs one)
              (hasheq 'outcomes (for/list ([r (in-list (asked-resources several))]) (apply-json validate inputs r)))))))))

;; run-load : data opened once and kept: resources given (held in memory), or a place (a directory
;; or file is read now; a store or server is opened). A later call names it as {loaded: key}.
(define (run-load s a)
  (define h (project-of s a))
  (define-values (key count) (load-data! s h (arg a 'data)))
  (hasheq 'loaded key 'count (or count 'null)))

(define (run-unload s a)
  (hasheq 'unloaded (unload-data! s (arg a 'loaded))))

;; run-transform : the map is checked against its structures first (an element the target lacks is
;; an error at its rule: run unchecked, `tgt.gendr = g` wrote a `gendr` into the result), then run
(define (run-transform s a)
  (in-project s a
    (lambda (h)
      (define fml (or (workspace-support "fml") (raise-user-error 'transform "the fml package is not installed")))
      (define-values (_resources found)
        (with-hub h (lambda () ((ws-support-artifacts fml) (hub-ws h) (list (cons "map" (arg a 'map)))))))
      (define errors (filter (lambda (d) (eq? (diagnostic-severity d) 'error)) found))
      (when (pair? errors)
        (raise (exn:fail:problems (string-join (map diagnostic-message errors) "; ") (current-continuation-marks)
                                  (for/list ([d (in-list errors)]) (diagnostic-json h d)))))
      (unread-warning! s (arg a 'source) "the source's")
      (with-hub h (lambda () (apply-json (operation "StructureMap/$transform") (hasheq 'srcMap (arg a 'map)) (arg a 'source)))))))

(define (run-operation s a)
  (in-project s a
    (lambda (h)
      (with-hub h (lambda () (apply-json (operation (arg a 'operation)) (or (arg a 'inputs) (hasheq)) (arg a 'resource)))))))

;; ---- writing: stage, then commit ---------------------------------------------------------------
;; A write goes the workspace's way (fhir-mcp's stage.rkt): staged — validated in the project's
;; context and compared with what the data holds —, then committed, which writes the resources and
;; their trail (a Provenance and an AuditEvent) in one step. The stage is kept with the project, so
;; `commit` is given the project and the place `stage` was.
(define p-place (param "data" 'string #t "where the data is kept: a SQLite FHIR store (the file is made when it is not there), or a directory of FHIR JSON"))

;; without-hints : jsexpr -> jsexpr   an answer without the lines that say the next call in the
;; workspace's own tools' words (`next`, `table`): a caller here calls functions
(define (without-hints js)
  (cond [(hash? js) (for/hasheq ([(k v) (in-hash js)] #:unless (memq k '(next table))) (values k (without-hints v)))]
        [(list? js) (map without-hints js)]
        [else js]))

;; without-hint-text : string -> string   a refusal without its parenthesis naming a tool call
(define (without-hint-text message)
  (regexp-replace* #px" \\(stage\\([^()]*\\)[^()]*\\)" message ""))

;; said-plainly : (-> X) -> X   the thunk's answer without hints; its refusal without them too
(define (said-plainly thunk)
  (with-handlers ([(lambda (e) (and (exn:fail? e) (not (exn:fail:problems? e))
                                    (not (equal? (without-hint-text (exn-message e)) (exn-message e)))))
                   (lambda (e) (raise-user-error (without-hint-text (exn-message e))))])
    (without-hints (thunk))))

(define (run-stage s a)
  (define resources (arg a 'resources))
  (define fsh (arg a 'fsh))
  (define drop (arg a 'drop))
  (unless (= 1 (length (filter values (list resources fsh drop))))
    (raise-user-error 'stage "give one of `resources`, `fsh` (what to write) or `drop` (a stage to discard)"))
  (in-project s a
    (lambda (h)
      (said-plainly
       (lambda ()
         (hub-stage! h (hasheq-some 'resources (and resources (if (list? resources) resources (list resources)))
                                    'fsh fsh
                                    'drop drop
                                    'keep (and (eq? (hash-ref a 'keep #t) #f) 'false))))))))

;; hasheq-some : key value … -> hasheq   the pairs whose value is not #f ('false: a false to keep)
(define (hasheq-some . kvs)
  (let loop ([kvs kvs] [h (hasheq)])
    (cond [(null? kvs) h]
          [(not (cadr kvs)) (loop (cddr kvs) h)]
          [else (loop (cddr kvs) (hash-set h (car kvs) (if (eq? (cadr kvs) 'false) #f (cadr kvs))))])))

(define (run-commit s a)
  (in-project s a
    (lambda (h) (said-plainly (lambda () (hub-commit! h (arg a 'stage) (arg a 'reason) #:agent (or (arg a 'agent) "fhir-api")))))))

(define (run-guide s a)
  (define topic (arg a 'topic))
  (cond [(not topic) (hasheq 'topics (for/list ([t (in-list learn-topics)]) (car t)))]
        [(learn-text topic) => (lambda (text) (hasheq 'topic topic 'text text))]
        [else (raise-user-error 'guide "no guide ~a (the guides: ~a)" topic (string-join (map car learn-topics) ", "))]))

(define (run-version s a)
  (hasheq 'protocol protocol-version 'fhirVersion (session-fhir-version s) 'packages (session-packages s)
          'functions (map fn-name functions)))

(define functions
  (list
   (fn "compile" "What a project's files define, as FHIR resources, with every problem in them (examples are validated against the profiles they claim)."
       project
       "{resources: [resource…], diagnostics: [Diagnostic…]}"
       run-compile)
   (fn "run" "One file of the project run over the data: a CQL library's defines for each patient, a view's rows, a map's results, a FHIRPath expression's values, a value set's codes, the resources an FSH file compiles to."
       (append (list (param "path" 'string #t "the file to run, by its name in the project") p-entry p-over p-parameters) project (list p-data))
       "a Table {kind, columns, rows, summary}"
       run-run)
   (fn "query" "A text asked of the data without a file: FHIRPath, CQL, VCL, a FHIR search (`Observation?code=…`), words to find, a view, or SQL over the project's views."
       (append (list (param "language" 'string #t "fhirpath | cql | vcl | search | find | view | sql")
                     (param "text" 'string #t "the expression, search, view or statement")
                     p-entry p-over p-parameters
                     (param "strict" 'boolean #f "a search: refuse a parameter the data cannot apply, where it is otherwise left out and said"))
               project (list p-data))
       "a Table {kind, columns, rows, summary}"
       run-query)
   (fn "explain" "Why a file answered what it did for one subject (a patient, a resource, an entity), each step with its place in the source."
       (append (list (param "path" 'string #t "the file, by its name in the project")
                     (param "subject" 'string #t "a patient or resource id, Type/id, or the name of an entity")
                     p-entry p-over p-parameters)
               project (list p-data))
       "an object, by language"
       run-explain)
   (fn "fhirpath" "A FHIRPath expression evaluated over one resource, or over each of several in one call."
       (list (param "expression" 'string #t "the FHIRPath expression")
             (param "resource" 'resource #f "the resource it is evaluated over")
             (param "resources" 'resources #f "in place of `resource`: several resources (a list, or a Bundle), each evaluated on its own"))
       "{values: [json…]} for `resource`: FHIR JSON for an element, a JSON number, boolean or string for a System value; {results: [[json…]…]} for `resources`: the values for each, in the order given"
       run-fhirpath)
   (fn "translate" "A CQL library translated to ELM, with every translation error and warning; includes are found in the project, then among the libraries the toolkit carries."
       (append (list (param "text" 'string #t "the library's CQL") (param "name" 'string #f "a file name for its problems (library.cql otherwise)")) project)
       "{elm: the library's ELM as JSON (null when it has errors), diagnostics: [Diagnostic…]}"
       run-translate)
   (fn "decompile" "A FHIR resource written as source text: FSH (a profile, value set, code system, instance), the mapping language (a StructureMap), a view's text (a ViewDefinition), VCL (a ValueSet's compose), CQL (a Library that carries it)."
       (append (list (param "resource" 'resource #t "the resource") (param "as" 'string #f "fsh | fml | sof | vcl | cql; by the resource's type otherwise")) project)
       "{language, text}"
       run-decompile)
   (fn "validate" "A resource held to its type, the profiles it claims and one more when named; profiles the project defines are in context."
       (append (list (param "resource" 'resource #f "the resource to validate")
                     (param "resources" 'resources #f "in place of `resource`: several resources (a list, or a Bundle), each validated on its own")
                     (param "profile" 'string #f "a profile to hold it to as well: its canonical, or the id or name of one the project defines"))
               project)
       "an OperationOutcome for `resource`; {outcomes: [OperationOutcome…]} for `resources`, in the order given"
       run-validate)
   (fn "load" "Data opened once and kept for the calls after it, so that a call need not give it again: resources (held in memory), or a place (a directory or file of FHIR JSON is read now; a store or a server is opened)."
       (append (list (param "data" 'data #t "the resources, or a string naming where they are")) project)
       "{loaded: the key — give {loaded: key} as a later call's `data` —, count: how many resources were given (null for a place)}"
       run-load)
   (fn "unload" "Data kept by load, let go."
       (list (param "loaded" 'string #t "the key load answered"))
       "{unloaded: was something kept under the key}"
       run-unload)
   (fn "transform" "A resource converted by a map written in the mapping language; structures the project defines (logical models, profiles) are in context."
       (append (list (param "map" 'string #t "the map's text") (param "source" 'resource #t "the resource to convert")) project)
       "the resulting resource"
       run-transform)
   (fn "operation" "Any FHIR operation the toolkit implements, by reference: $expand, $validate-code, $lookup, $translate, $snapshot, $evaluate-measure, $sql-run and the others."
       (append (list (param "operation" 'string #t "$code, Type/$code, or the OperationDefinition's canonical")
                     (param "resource" 'resource #f "the resource the operation applies to")
                     (param "inputs" 'object #f "the operation's input parameters by name (a list for several values)"))
               project (list p-data))
       "the resource the operation returns (its `return`, or a Parameters of its outputs)"
       run-operation)
   (fn "stage" "A write prepared and not yet made: resources, given as JSON or as FSH Instances, validated in the project's context (the profiles they claim, the project's own among them) and compared with what the data holds: created, changed (each path old → new) or unchanged, with every error. Nothing is written until commit."
       (append (list p-place
                     (param "resources" 'resources #f "the resources to write (a list, one resource, or a Bundle); one with an id the data holds is an update")
                     (param "fsh" 'string #f "in place of `resources`: FSH Instances as text; `Instance: Type/id` with rules alone changes that stored resource")
                     (param "drop" 'string #f "discard a stage instead: its id, latest, refused (those with errors) or all")
                     (param "keep" 'boolean #f "false: check only — the same answer, no stage kept"))
               project)
       "{stage, changes: [{resource, action, changed, errors, warnings}…], errors}: `stage` the id commit takes (none when nothing differs or with keep false), `action` create | update | unchanged, `errors` their count"
       run-stage)
   (fn "commit" "A stage written to the data, with its trail: the resources in one step (a SQLite store: one transaction), then a Provenance (the versions written, who, why, the source text with its hash) and an AuditEvent. A stage with errors is refused."
       (append (list (param "stage" 'string #t "the stage's id, as stage answered it, or latest")
                     p-place
                     (param "reason" 'string #f "why: recorded in the Provenance")
                     (param "agent" 'string #f "who is writing, for the Provenance and the AuditEvent: a name, or a reference (Practitioner/x); fhir-api when none is given"))
               project)
       "{stage, written: [{resource, version, status, ok}…], provenance, reason, agent}: `version` as Type/id/_history/n, `provenance` the Provenance written"
       run-commit)
   (fn "guide" "A guide to one of the languages or to FHIR itself, written for an agent; without a topic, the topics."
       (list (param "topic" 'string #f "fhir, fsh, cql, fhirpath, fml, vcl, sql-on-fhir, …"))
       "{topics: [string…]} or {topic, text}"
       run-guide)
   (fn "version" "What this process is: the protocol's version, the FHIR version it reads, the packages in context, its functions."
       '()
       "{protocol, fhirVersion, packages, functions}"
       run-version)))

(define (function-named name) (findf (lambda (f) (equal? (fn-name f) name)) functions))

;; ---- warming ------------------------------------------------------------------------------------
;; The first call of each kind waits for what only it needs loaded: the FHIR types (0.3 s), the
;; packages' definitions and terminology read and indexed (a first validation: about a second),
;; the view engine, CQL's translator. Each step here is one such first call made of a small
;; resource, so that a process that has had a moment to itself answers its first real call as
;; fast as its hundredth. They load and index; what they answer is dropped.
(define (warm-steps s)
  (define patient (hasheq 'resourceType "Patient" 'id "warm" 'gender "female" 'birthDate "1980-02-28"
                          'name (list (hasheq 'family "Warm"))))
  (define (step name args) (lambda () ((fn-run (function-named name)) s args)))
  (list (step "fhirpath" (hasheq 'expression "name.family.first()" 'resource patient))
        (step "validate" (hasheq 'resource patient))
        (step "query" (hasheq 'language "view" 'text "SELECT id FROM Patient" 'data (list patient)))
        (step "query" (hasheq 'language "search" 'text "Patient?gender=female" 'data (list patient)))
        (step "compile" (hasheq 'files (hasheq 'warm.fsh "Profile: WarmPatient\nParent: Patient\n* birthDate 1..1\n")))
        (step "run" (hasheq 'path "Warm.cql" 'data (list patient)
                            'files (hasheq 'Warm.cql "library Warm version '1'\nusing FHIR version '4.0.1'\ninclude FHIRHelpers version '4.0.1'\ncontext Patient\ndefine \"Is Female\": Patient.gender = 'female'\n")))))

;; ---- the table as data ---------------------------------------------------------------------------
;; param-schema : Param -> jsexpr   a JSON Schema for the value
(define (param-schema p)
  (define base
    (case (param-type p)
      [(string) (hasheq 'type "string")]
      [(boolean) (hasheq 'type "boolean")]
      [(object resource) (hasheq 'type "object")]
      [(resources) (hasheq 'anyOf (list (hasheq 'type "object") (hasheq 'type "array" 'items (hasheq 'type "object"))))]
      [(files) (hasheq 'type "object" 'additionalProperties (hasheq 'type "string"))]
      [(data) (hasheq 'anyOf (list (hasheq 'type "string") (hasheq 'type "object")
                                   (hasheq 'type "array" 'items (hasheq 'type "object"))))]))
  (hash-set base 'description (param-doc p)))

(define (functions->jsexpr)
  (hasheq 'protocol protocol-version
          'functions
          (for/list ([f (in-list functions)])
            (hasheq 'name (fn-name f)
                    'summary (fn-summary f)
                    'returns (fn-returns f)
                    ;; the parameters in the table's order, which an object's keys do not keep
                    'order (map param-name (fn-params f))
                    'parameters
                    (hasheq 'type "object"
                            'properties (for/hasheq ([p (in-list (fn-params f))]) (values (string->symbol (param-name p)) (param-schema p)))
                            'required (for/list ([p (in-list (fn-params f))] #:when (param-required? p)) (param-name p))
                            'additionalProperties #f)))))

;; json-text : jsexpr indent -> string   keys in name order, two spaces a level: one text for one value
(define (json-text js [depth 0])
  (define pad (make-string (* 2 (add1 depth)) #\space))
  (define close (make-string (* 2 depth) #\space))
  (cond
    [(and (hash? js) (positive? (hash-count js)))
     (string-append
      "{\n"
      (string-join (for/list ([k (in-list (sort (hash-keys js) symbol<?))])
                     (string-append pad (jsexpr->string (symbol->string k)) ": " (json-text (hash-ref js k) (add1 depth))))
                   ",\n")
      "\n" close "}")]
    [(and (list? js) (pair? js))
     (string-append "[\n" (string-join (for/list ([x (in-list js)]) (string-append pad (json-text x (add1 depth)))) ",\n") "\n" close "]")]
    [else (jsexpr->string js)]))

(define (functions-json-text) (string-append (json-text (functions->jsexpr)) "\n"))

(define (functions->text)
  (string-join
   (for/list ([f (in-list functions)])
     (string-append
      (fn-name f) " — " (fn-summary f) "\n"
      (string-append*
       (for/list ([p (in-list (fn-params f))])
         (format "    ~a~a  ~a\n" (param-name p) (if (param-required? p) "" "?") (param-doc p))))
      "    -> " (fn-returns f) "\n"))
   "\n"))

(module+ test
  (require rackunit)
  ;; every name once; every function says what it answers
  (check-false (check-duplicates (map fn-name functions)))
  (for ([f (in-list functions)])
    (check-false (check-duplicates (map param-name (fn-params f))) (fn-name f))
    (check-true (positive? (string-length (fn-returns f))) (fn-name f)))
  ;; arguments held to the table: an unknown name, a missing one, a value of another type
  (define f (function-named "fhirpath"))
  (check-equal? (argument-problems f (hasheq 'expression "name" 'resource (hasheq))) '())
  (check-regexp-match #rx"`expresion` is not a parameter of fhirpath [(]it takes: expression, resource, resources[)]"
                      (car (argument-problems f (hasheq 'expresion "name" 'resource (hasheq)))))
  (check-regexp-match #rx"fhirpath needs `expression`" (car (argument-problems f (hasheq 'resource (hasheq)))))
  (check-regexp-match #rx"`resource` is a FHIR resource" (car (argument-problems f (hasheq 'expression "name" 'resource "x"))))
  (check-regexp-match #rx"`files` is an object of file name -> text"
                      (car (argument-problems (function-named "compile") (hasheq 'files (hasheq 'a.fsh 1)))))
  ;; a JSON null is an argument not given
  (check-equal? (argument-problems (function-named "compile") (hasheq 'files 'null)) '())
  ;; the table as data: a schema for every function, required names among the properties
  (define js (functions->jsexpr))
  (check-equal? (length (hash-ref js 'functions)) (length functions))
  (for ([j (in-list (hash-ref js 'functions))])
    (define schema (hash-ref j 'parameters))
    (check-equal? (sort (map symbol->string (hash-keys (hash-ref schema 'properties))) string<?)
                  (sort (hash-ref j 'order) string<?))
    (for ([r (in-list (hash-ref schema 'required))]) (check-true (hash-has-key? (hash-ref schema 'properties) (string->symbol r)))))
  (check-true (jsexpr? js))
  ;; the kept text reads back as the table, and is the same text each time
  (check-equal? (string->jsexpr (functions-json-text)) js)
  (check-equal? (functions-json-text) (functions-json-text))
  (check-equal? (json-text (hasheq 'b 1 'a (list "x" (hasheq)) 'c (hasheq 'z #t)))
                "{\n  \"a\": [\n    \"x\",\n    {}\n  ],\n  \"b\": 1,\n  \"c\": {\n    \"z\": true\n  }\n}"))
