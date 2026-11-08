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

(require racket/contract racket/list racket/string racket/file racket/path racket/match json
         net/uri-codec
         fhir/lang/workspace
         (only-in fhir/lang/support language-id-of)
         (only-in fhir/diagnostic diagnostic diagnostic? loc loc-source loc-line diagnostic-loc diagnostic-severity
                  diagnostic->jsexpr diagnostic-message exn:fail:diagnostic? exn:fail:diagnostic-diagnostic)
         (only-in fhir/registry register-resources! unregister-source! registered-resource registered-resources registered-kinds)
         (only-in fhir/data-source current-data-source data-source? data-source-all data-source-read data-source-search
                  directory->data-source resources->data-source empty-data-source bundle-resources)
         (only-in fhir/rest-data-source rest->data-source rest-write! rest-url?)
         (only-in fhir/sd/sd-index current-sd-packages resolve-canonical-raw sd-index-available?)
         (only-in fhir/operation operation operation-definition operation-code operation-url operation-levels
                  operation-resource-types registered-operations apply-operation exn:fail:operation? exn:fail:operation-outcome)
         "tools.rkt")

(provide
 (contract-out
  [hub?            (-> any/c boolean?)]
  ;; open-hub : dir [#:data override] [#:packages extra] -> hub
  [open-hub        (->* (path-string?) (#:data (or/c string? #f) #:packages (listof string?)) hub?)]
  [hub-root        (-> hub? path?)]
  [with-hub        (-> hub? (-> any) any)]
  [hub-write!      (-> hub? string? string? jsexpr?)]
  [hub-check       (-> hub? (listof string?) jsexpr?)]
  [hub-run         (-> hub? string? hash? jsexpr?)]
  [hub-query       (-> hub? string? string? hash? jsexpr?)]
  [hub-explain     (-> hub? string? string? hash? jsexpr?)]
  [hub-describe    (-> hub? string? hash? jsexpr?)]
  [hub-apply       (-> hub? string? hash? (or/c hash? #f) jsexpr?)]
  [hub-stage!      (-> hub? hash? jsexpr?)]
  [hub-commit!     (-> hub? string? jsexpr?)]
  [hub-result-uris (-> hub? (listof string?))]
  [hub-read-result (-> hub? string? (or/c jsexpr? #f))]))

(struct hub ([ws #:mutable] [warnings #:mutable] [packages #:mutable] [data #:mutable] [data-label #:mutable]
             data-override extra-packages
             cache                    ; language -> (cons files (cons resources diagnostics))
             [diagnostics #:mutable]  ; every problem of the last refresh
             results stages [counter #:mutable]))
(struct stored (language path text options result))
(struct change (resource action paths errors))

(define (hub-root h) (workspace-root (hub-ws h)))

;; ---- opening, context ----------------------------------------------------------------------------
(define (open-hub dir #:data [data-override #f] #:packages [extra '()])
  (define h (hub #f '() '() empty-data-source "none" data-override extra (make-hash) '() (make-hash) (make-hash) 0))
  (configure! h dir)
  (load-operations!)
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
  (define-values (ds label data-warnings) (open-data ws*))
  (set-hub-ws! h ws*)
  (set-hub-packages! h (append pkgs (if core (list core) '())))
  (set-hub-data! h ds)
  (set-hub-data-label! h label)
  (set-hub-warnings! h (append warnings
                               (for/list ([m (in-list missing)]) (format "workspace.yaml: package ~a not found (a .tgz path, or a package in fhir-spec or FHIR_PACKAGE_PATH)" m))
                               (if core '() (list "no core package for this FHIR version: install fhir-spec"))
                               data-warnings))
  (hash-clear! (hub-cache h)))

;; open-data : workspace -> (values data-source label warnings)
(define (open-data ws)
  (define d (ws-config-data (workspace-config ws)))
  (cond
    [(not d) (values empty-data-source "none (set `data` in workspace.yaml)" '())]
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
          [(and (hash? js) (string? (hash-ref js 'resourceType #f))) (values (append (reverse (bundle-resources js)) rs) ds)]
          [else (values rs (append ds (list (diagnostic 'fhir 'parse 'error "a FHIR resource is a JSON object with a resourceType" (loc (path-string (car f)) #f #f #f #f)))))])))

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
(define (problem-json h d)
  (define j (diagnostic->jsexpr d))
  (define src (let ([l (diagnostic-loc d)]) (and l (loc-source l))))
  (if (and src (hash? j)) (hash-set j 'file (rel h src)) j))
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
  (hasheq 'path (rel h full)
          'language (or lang "workspace.yaml")
          'written (file-exists? full)
          'problems (map (lambda (d) (problem-json h d)) mine)
          'problemsElsewhere others
          'config (if config? (config-json h) 'null)))

(define (config-json h)
  (define c (workspace-config (hub-ws h)))
  (hasheq 'fhirVersion (ws-config-fhir-version c) 'canonical (ws-config-canonical c)
          'packages (map path-string (hub-packages h)) 'data (hub-data-label h)
          'parameters (for/hasheq ([(k v) (in-hash (ws-config-parameters c))]) (values (string->symbol k) v))
          'warnings (hub-warnings h)))

(define (hub-check h paths)
  (refresh! h)
  (define ds (if (null? paths) (hub-diagnostics h)
                 (append* (for/list ([p (in-list paths)]) (problems-of h (inside h p))))))
  (hasheq 'files (map (lambda (f) (rel h f)) (workspace-files (hub-ws h)))
          'errors (count-severity ds 'error)
          'warnings (count-severity ds 'warning)
          'problems (map (lambda (d) (problem-json h d)) ds)
          'workspace (config-json h)))

;; ---- run, query, results ---------------------------------------------------------------------------
(define preview-rows 10)
(define max-preview 400)

;; elide : jsexpr -> jsexpr   a value too long to preview names its size
(define (elide v)
  (define s (jsexpr->string v))
  (if (> (string-length s) max-preview) (format "… ~a characters (read it with describe and offset)" (string-length s)) v))
(define (preview row) (if (hash? row) (for/hasheq ([(k v) (in-hash row)]) (values k (elide v))) (elide row)))

(define (store! h st)
  (set-hub-counter! h (add1 (hub-counter h)))
  (define uri (format "result://r~a" (hub-counter h)))
  (hash-set! (hub-results h) uri st)
  uri)

(define (result-json uri r)
  (define rows (run-result-rows r))
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
  (for/hasheq ([k '(entry over parameters)] #:when (and (hash-ref args k #f) (not (eq? (hash-ref args k) 'null))))
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
        [(equal? lang "search") (run-search text opts)]
        [else (define sup (support-for lang))
              (unless (ws-support-run sup) (error 'run (format "~a files do not run" lang)))
              ((ws-support-run sup) (hub-ws h) path text opts)]))))

(define (hub-run h p args)
  (define full (inside h p))
  (unless (file-exists? full) (error 'run (format "no file ~a in the workspace" p)))
  (define lang (or (workspace-language-of full) (error 'run (format "~a is not a file of the workspace's languages" p))))
  (refresh! h)
  (define text (file->string full))
  (define opts (options args))
  (define r (execute h lang full text opts))
  (result-json (store! h (stored lang full text opts r)) r))

(define query-languages (hash "fhirpath" "fhirpath" "cql" "cql" "vcl" "vcl" "search" "search" "view" "sql-on-fhir" "sql-on-fhir" "sql-on-fhir"))
(define (hub-query h language text args)
  (define lang (or (hash-ref query-languages language #f)
                   (error 'query (format "query takes fhirpath, cql, vcl, search or view (got ~a)" language))))
  (refresh! h)
  (define opts (options args))
  (define r (execute h lang #f text opts))
  (result-json (store! h (stored lang #f text opts r)) r))

;; run-search : "Type?params" options -> run-result   FHIR search where the data source can run it
(define (run-search text opts)
  (define m (regexp-match #px"^\\s*([A-Za-z]+)(?:\\?(.*))?\\s*$" text))
  (unless m (error 'search "a search is Type?name=value&… (Observation?code=http://loinc.org|4548-4)"))
  (define type (cadr m))
  (define params (if (and (caddr m) (not (string=? (caddr m) ""))) (form-urlencoded->alist (caddr m)) '()))
  (define ds (current-data-source))
  (define found
    (cond [(data-source-search ds) ((data-source-search ds) type (for/list ([p (in-list params)]) (cons (symbol->string (car p)) (or (cdr p) ""))))]
          [(null? params) ((data-source-all ds) type)]
          [else (error 'search "this data is files, not a FHIR server: it has no search engine. Ask with FHIRPath instead: query(\"fhirpath\", \"Observation.where(…)\")")]))
  (run-result "resources" '("resource" "json")
              (for/list ([r (in-list found)]) (hasheq 'resource (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id "?")) 'json r))
              (hasheq 'resources (length found))))

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

(define (hub-result-uris h) (sort (hash-keys (hub-results h)) string<?))
(define (hub-read-result h uri)
  (define st (hash-ref (hub-results h) uri #f))
  (and st (let ([r (stored-result st)])
            (hasheq 'kind (run-result-kind r) 'columns (run-result-columns r) 'summary (run-result-summary r) 'rows (run-result-rows r)))))

;; ---- explain ------------------------------------------------------------------------------------
(define (hub-explain h ref subject args)
  (refresh! h)
  (define-values (lang path text opts)
    (cond
      [(hash-ref (hub-results h) ref #f)
       => (lambda (st) (values (stored-language st) (stored-path st) (stored-text st)
                               (for/fold ([o (stored-options st)]) ([(k v) (in-hash (options args))]) (hash-set o k v))))]
      [(regexp-match? #rx"^result://" ref) (error 'explain (format "no result ~a (results: ~a)" ref (string-join (hub-result-uris h) ", ")))]
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

(define (hub-describe h ref args)
  (define offset (let ([o (hash-ref args 'offset 0)]) (if (exact-nonnegative-integer? o) o 0)))
  (define limit (let ([l (hash-ref args 'limit 20)]) (if (exact-positive-integer? l) l 20)))
  (define against (let ([a (hash-ref args 'against #f)]) (and (string? a) a)))
  (with-hub h
    (lambda ()
      (cond
        [(regexp-match? #rx"^result://" ref) (describe-result h ref offset limit against)]
        [(regexp-match #px"^(?:([A-Za-z]+)/)?[$]([A-Za-z-]+)$" ref) (describe-operation ref)]
        [(regexp-match? #rx"/OperationDefinition/" ref) (describe-operation ref)]
        [(regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" ref)
         => (lambda (m) (or ((data-source-read (current-data-source)) (cadr m) (caddr m))
                            (registered-resource (cadr m) (caddr m))
                            (error 'describe (format "no ~a in the data or the workspace" ref))))]
        [(regexp-match? #rx"://" ref)
         (define r (or (for/or ([k (in-list (registered-kinds))]) (registered-resource k ref))
                       (and (sd-index-available?) (for/or ([k (in-list conformance-kinds)]) (resolve-canonical-raw k ref)))))
         (if r (trim-definition r) (error 'describe (format "no definition ~a in the workspace or the packages" ref)))]
        [(regexp-match #px"^([A-Z][A-Za-z]+)(?:[.](.+))?$" ref)
         => (lambda (m) (describe-element (cadr m) (caddr m) ref))]
        [else (search-definitions ref)]))))

;; trim-definition : resource -> resource   a StructureDefinition without its snapshot (the elements
;; are a describe of Type.path away); the narrative dropped
(define (trim-definition r)
  (define r1 (hash-remove r 'text))
  (if (and (equal? (hash-ref r 'resourceType #f) "StructureDefinition") (hash-has-key? r 'snapshot))
      (hash-set (hash-remove r1 'snapshot) 'snapshot (format "~a elements: describe(\"~a.<path>\")" (length (hash-ref (hash-ref r 'snapshot) 'element '())) (hash-ref r 'type "Type")))
      r1))

(define (describe-element type path ref)
  (define t (findf (lambda (x) (equal? (tool-name x) "fhir_element")) (definition-tools)))
  (define-values (text err?) (call-tool t (if path (hasheq 'type type 'path path) (hasheq 'type type))))
  (if err? (search-definitions ref) (string->jsexpr text)))

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

(define (describe-result h uri offset limit against)
  (define st (or (hash-ref (hub-results h) uri #f) (error 'describe (format "no result ~a (results: ~a)" uri (string-join (hub-result-uris h) ", ")))))
  (define r (stored-result st))
  (cond
    [against
     (define other (or (hash-ref (hub-results h) against #f) (error 'describe (format "no result ~a" against))))
     (diff-results (stored-result other) r against uri)]
    [else
     (define rows (run-result-rows r))
     (define page (take (drop rows (min offset (length rows))) (min limit (max 0 (- (length rows) offset)))))
     (hasheq 'result uri 'kind (run-result-kind r) 'columns (run-result-columns r) 'total (length rows)
             'offset offset 'rows page 'summary (run-result-summary r))]))

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
(define (hub-apply h ref inputs resource)
  (refresh! h)
  (with-hub h
    (lambda ()
      (define o (with-handlers ([exn:fail? (lambda (e) (error 'apply (format "no operation ~a: ~a" ref (exn-message e))))]) (operation ref)))
      (define t (operation->tool o (registered-operations)))
      (define-values (text err?) (call-tool t (if resource (hash-set inputs 'resource resource) inputs)))
      (define j (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)))
      (if err? (raise (exn:fail:operation-json text (current-continuation-marks) j)) j))))
(struct exn:fail:operation-json exn:fail (json))
(provide (struct-out exn:fail:operation-json))

;; ---- stage and commit -----------------------------------------------------------------------------
(define instance? (lambda (r) (not (member (hash-ref r 'resourceType #f) (append conformance-kinds '("Library" "OperationDefinition" "SearchParameter" "CapabilityStatement" "ImplementationGuide" "ViewDefinition"))))))

;; staged-resources : hub args -> (listof resource)
(define (staged-resources h args)
  (define given (hash-ref args 'resources #f))
  (define path (hash-ref args 'path #f))
  (define result (hash-ref args 'result #f))
  (cond
    [(list? given) (append-map (lambda (r) (if (hash? r) (bundle-resources r) (error 'stage "each resource is a JSON object"))) given)]
    [(string? result)
     (define st (or (hash-ref (hub-results h) result #f) (error 'stage (format "no result ~a" result))))
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
    [else (error 'stage "stage takes `resources`, `result` or `path`")]))

;; json-diff : a b -> (listof dotted path)   where two JSON values differ
(define (json-diff a b [prefix ""])
  (define (at k) (if (string=? prefix "") (format "~a" k) (format "~a.~a" prefix k)))
  (cond [(and (hash? a) (hash? b))
         (append* (for/list ([k (in-list (remove-duplicates (append (hash-keys a) (hash-keys b))))]
                             #:unless (memq k '(meta text)))
                    (json-diff (hash-ref a k 'null) (hash-ref b k 'null) (at k))))]
        [(and (list? a) (list? b) (= (length a) (length b)))
         (append* (for/list ([x (in-list a)] [y (in-list b)] [i (in-naturals)]) (json-diff x y (format "~a[~a]" prefix i))))]
        [(equal? a b) '()]
        [else (list (if (string=? prefix "") "(whole resource)" prefix))]))

(define (validation-errors r)
  (with-handlers ([exn:fail:operation? (lambda (e) (list (format "~a" (exn-message e))))]
                  [exn:fail? (lambda (_) '())])
    (for/list ([i (in-list (hash-ref (apply-operation "$validate" r) 'issue '()))]
               #:when (member (hash-ref i 'severity #f) '("error" "fatal")))
      (format "~a: ~a" (let ([e (hash-ref i 'expression (hash-ref i 'location '()))]) (if (pair? e) (car e) "")) (hash-ref i 'diagnostics (hash-ref i 'code ""))))))

(define (hub-stage! h args)
  (refresh! h)
  (with-hub h
    (lambda ()
      (define rs (staged-resources h args))
      (when (null? rs) (error 'stage "nothing to stage"))
      (define changes
        (for/list ([r (in-list rs)])
          (define current (and (hash-ref r 'id #f) ((data-source-read (current-data-source)) (hash-ref r 'resourceType) (hash-ref r 'id))))
          (define paths (if current (json-diff current r) '()))
          (change r (cond [(not current) 'create] [(null? paths) 'unchanged] [else 'update]) paths (validation-errors r))))
      (set-hub-counter! h (add1 (hub-counter h)))
      (define id (format "stage-~a" (hub-counter h)))
      (hash-set! (hub-stages h) id changes)
      (define errors (for/sum ([c (in-list changes)]) (length (change-errors c))))
      (hasheq 'stage id
              'target (hub-data-label h)
              'changes (for/list ([c (in-list changes)])
                         (hasheq 'resource (format "~a/~a" (hash-ref (change-resource c) 'resourceType) (hash-ref (change-resource c) 'id "(new id)"))
                                 'action (symbol->string (change-action c))
                                 'changed (take (change-paths c) (min 30 (length (change-paths c))))
                                 'errors (change-errors c)))
              'errors errors
              'next (if (zero? errors) (format "commit(\"~a\") writes the ~a change(s)" id (count (lambda (c) (not (eq? (change-action c) 'unchanged))) changes))
                        "fix the errors, then stage again: a stage with errors is not committed")))))

(define (hub-commit! h id)
  (define changes (or (hash-ref (hub-stages h) id #f) (error 'commit (format "no stage ~a" id))))
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
      [else
       (define dir (simplify-path (path->complete-path d (hub-root h))))
       (unless (directory-exists? dir) (error 'commit (format "data ~a is a file, not a directory: commit writes to a directory or a FHIR server" d)))
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
  (configure! h (hub-root h))                              ; the data read again
  (hasheq 'stage id 'written written))

;; resource-files : dir -> (hash (cons type id) -> (cons file 'resource|'bundle))
(define (resource-files dir)
  (for*/fold ([acc (hash)]) ([f (in-directory dir)] #:when (regexp-match? #rx"[.]json$" (path->string f))
                             [js (in-value (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))]
                             #:when (hash? js))
    (define bundle? (equal? (hash-ref js 'resourceType #f) "Bundle"))
    (for/fold ([acc acc]) ([r (in-list (bundle-resources js))] #:when (and (hash-ref r 'resourceType #f) (hash-ref r 'id #f)))
      (hash-set acc (cons (hash-ref r 'resourceType) (hash-ref r 'id)) (cons f (if bundle? 'bundle 'resource))))))
(define (new-id) (format "ws-~a-~a" (current-seconds) (random 1000000)))
