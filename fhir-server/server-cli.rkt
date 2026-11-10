#lang racket/base

;;; server-cli.rkt — `raco fhir-server <command>`: servers generated from FHIR specs.
;;;
;;;   raco fhir-server serve-ig <ig> …        a FHIR server generated from an IG package (store/ig-server)
;;;   raco fhir-server serve <app.rkt> [port] serve a #lang fhir/capability module's `app`
;;;   raco fhir-server load <store.db> <file|dir>
;;;   raco fhir-server evaluate-measure <store.db> <Measure> --period-start D --period-end D …

(require racket/list (only-in racket/os getpid)
         (only-in json jsexpr->string write-json)
         (only-in racket/file make-temporary-file)
         (only-in racket/string string-join)
         fhir/subcommands)

;; raco fhir-server serve-ig <ig> [--db store.db] [--port 8080] [--bearer token] [--no-examples] [--no-validate] [--gaps]
;; Generate a FHIR server FROM an Implementation Guide package (store/ig-server.rkt): the IG's FHIR
;; version picks the tower, its server CapabilityStatement the types/interactions/parameters, its
;; SearchParameters (over core) the search catalog; writes are validated against claimed profiles.
;; <ig> is a package name in fhir-spec (hl7.fhir.us.core), a .tgz name there, or a path. By default
;; the IG's examples are loaded (validated) into the store. --gaps prints the IG requirements this
;; server does not meet and exits.
;; --capability picks one of several server CapabilityStatements (CQF Measures: measure-calculation-
;; service-example serves $evaluate-measure); --load preloads data; --tz-offset is the CQL evaluation
;; timezone (default UTC).
(define (cmd-serve-ig args)
  (define open-store (dynamic-require 'fhir/store/fhir-sqlite 'open-fhir-store))
  (define ig-package-path (dynamic-require 'fhir/store/ig-server 'ig-package-path))
  (define make-ig-server (dynamic-require 'fhir/store/ig-server 'make-ig-server))
  (define load-ig-examples! (dynamic-require 'fhir/store/ig-server 'load-ig-examples!))
  (define srv-app (dynamic-require 'fhir/store/ig-server 'ig-server-app))
  (define srv-gaps (dynamic-require 'fhir/store/ig-server 'ig-server-gaps))
  (define srv-plan (dynamic-require 'fhir/store/ig-server 'ig-server-plan))
  (define gap->list (dynamic-require 'fhir/store/ig-server 'gap->list))
  (define serve-app (dynamic-require 'fhir/http/server 'serve-app))
  (define (opt name default) (let ([m (member name args)]) (if (and m (pair? (cdr m))) (cadr m) default)))
  (define flag? (lambda (name) (and (member name args) #t)))
  (define ig (car args))
  (define db (opt "--db" (path->string (make-temporary-file "fhir-ig-~a.db"))))
  (define port (string->number (opt "--port" "8080")))
  (define offset (let ([o (opt "--tz-offset" #f)])
                   (cond [(and o (regexp-match #px"^([+-])([0-9]{2}):([0-9]{2})$" o))
                          => (lambda (m) (* (if (equal? (cadr m) "-") -1 1) (+ (* 60 (string->number (caddr m))) (string->number (cadddr m)))))]
                         [o (eprintf "serve-ig: --tz-offset is ±hh:mm\n") (exit 2)]
                         [else 0])))
  (define store (open-store db))
  (define srv (make-ig-server store (ig-package-path ig) #:validate? (not (flag? "--no-validate"))
                              #:url (format "http://localhost:~a" port)
                              #:capability (opt "--capability" #f) #:offset offset))
  (define gaps (srv-gaps srv))
  (cond
    [(flag? "--gaps")
     (for ([g (in-list gaps)]) (printf "~a\n" (string-join (map (lambda (x) (format "~a" x)) (gap->list g)) "\t")))]
    [else
     ;; --load <file|dir> (repeatable): Bundles, resources, .cql libraries into the store
     (for ([m (in-list (let loop ([as args]) (cond [(member "--load" as) => (lambda (t) (if (pair? (cdr t)) (cons (cadr t) (loop (cddr t))) '()))] [else '()])))])
       (define n (report-loaded ((dynamic-require 'fhir/store/load 'load-files!) store m
                                 #:search-params ((dynamic-require 'fhir/store/ig-server 'ig-server-catalog) srv)
                                 #:tower ((dynamic-require 'fhir/store/ig-server 'ig-plan-tower) (srv-plan srv)))))
       (printf "loaded ~a resource(s) from ~a\n" n m))
     (unless (flag? "--no-examples")
       (define-values (n rejected) (load-ig-examples! srv))
       (printf "loaded ~a example(s); ~a rejected by validation\n" n (length rejected))
       (for ([r (in-list rejected)]) (printf "  ~a: ~a\n" (car r) (cdr r))))
     (printf "~a IG requirement(s) not met (raco fhir-server serve-ig ~a --gaps); ~a of them SHALL\n"
             (length gaps) ig (length (filter (lambda (g) (equal? (list-ref (gap->list g) 3) "SHALL")) gaps)))
     (define bearer (opt "--bearer" #f))
     (define stop (listening serve-app (srv-app srv) port #:bearer bearer #:on-listen (lambda (p) (set! port p))))
     (when bearer (printf "requests need: Authorization: Bearer ~a  (GET /metadata is public)\n" bearer))
     (printf "FHIR server for ~a on http://localhost:~a  (store: ~a; Ctrl-C to stop)\n" ig port db)
     (with-handlers ([exn:break? (lambda (_) (stop))]) (sync/enable-break never-evt))]))

;; raco fhir-server serve <app.rkt> [port] — serve a #lang fhir/capability module's `app` over HTTP
(define (cmd-serve file port-str [store #f] #:log? [log? #f])
  (define serve-app (dynamic-require 'fhir/http/server 'serve-app))
  ;; --store: every resource declared without a repository lives in that SQLite FHIR store
  (define app (parameterize ([(dynamic-require 'fhir/capability/runtime 'current-repository-factory)
                              (and store ((dynamic-require 'fhir/capability/store 'store-file-factory) store))])
                (dynamic-require (path->complete-path file) 'app)))
  (define asked (or (and port-str (string->number port-str)) 8080))
  (define port asked)
  (define stop (listening serve-app app asked #:log? log? #:on-listen (lambda (p) (set! port p))))
  ;; what is served and where its data lives: the store `--store` named, else the module's own
  ;; `(server #:store …)` (beside it), else a temporary store; the pid, so a script can stop it
  (define stores ((dynamic-require 'fhir/capability/store 'opened-store-files)))
  (printf "FHIR server on http://localhost:~a  (Ctrl-C, or kill ~a, to stop)\n" port (getpid))
  (printf "store: ~a\n" (if (null? stores) "a temporary SQLite file, removed when the server stops (--store keeps one)"
                             (string-join (map path->string stores) ", ")))
  (flush-output)                                          ; said at once, even when the output is a file
  (with-handlers ([exn:break? (lambda (_) (stop))]) (sync/enable-break never-evt)))

;; listening : serve-app app port … -> stop   serve, or say in one line why not: a port in use was a
;; stack trace through tcp-listen (port 0 picks a free one, and the banner prints it)
(define (listening serve-app app port #:log? [log? #f] #:bearer [bearer #f] #:on-listen [on-listen #f])
  (with-handlers ([exn:fail:network?
                   (lambda (e) (eprintf "fhir-server: cannot listen on port ~a (in use?); --port 0 picks a free one\n" port) (exit 1))])
    (serve-app app #:port port #:log? log? #:bearer bearer #:on-listen on-listen)))

;; raco fhir-server load <store.db> <file|dir> — Bundles, single resources and .cql libraries (store/load.rkt)
(define (cmd-load db-path src)
  (dynamic-require 'fhir/r4/schemas #f)
  (define open-store (dynamic-require 'fhir/store/fhir-sqlite 'open-fhir-store))
  (define close-store (dynamic-require 'fhir/store/fhir-sqlite 'close-fhir-store))
  (define store (open-store db-path))
  (define total (report-loaded ((dynamic-require 'fhir/store/load 'load-files!) store src)))
  (printf "loaded ~a resources into ~a\n" total db-path)
  (close-store store))
(define (report-loaded results)
  (for/sum ([r (in-list results)])
    (printf "~a: ~a\n" (car r) (if (zero? (cdr r)) "skipped (not FHIR JSON)" (format "~a resource(s)" (cdr r))))
    (cdr r)))

;; raco fhir-server evaluate-measure <store.db> <Measure id|url> --period-start D --period-end D [--subject Patient/x]
;;                                   [--tz-offset ±hh:mm]
;; run a Measure's CQL over the store (store/measure.rkt) and print the MeasureReport (individual
;; with --subject, else summary). --tz-offset is the evaluation timezone (default: UTC).
(define (cmd-evaluate-measure args)
  (dynamic-require 'fhir/r4/schemas #f)
  (define open-store (dynamic-require 'fhir/store/fhir-sqlite 'open-fhir-store))
  (define fhir-read (dynamic-require 'fhir/store/fhir-engine 'fhir-read))
  (define fhir-search (dynamic-require 'fhir/store/fhir-engine 'fhir-search))
  (define evaluate (dynamic-require 'fhir/store/measure 'evaluate-measure))
  (define (opt name) (let ([m (member name args)]) (and m (pair? (cdr m)) (cadr m))))
  (define store (open-store (car args)))
  (define key (cadr args))
  (define measure (or (fhir-read store "Measure" key)
                      (findf (lambda (m) (equal? (hash-ref m 'url #f) key)) (fhir-search store "Measure" '()))
                      (begin (eprintf "evaluate-measure: no Measure ~a in ~a\n" key (car args)) (exit 1))))
  (define start (or (opt "--period-start") (begin (eprintf "evaluate-measure: --period-start is required\n") (exit 2))))
  (define end (or (opt "--period-end") (begin (eprintf "evaluate-measure: --period-end is required\n") (exit 2))))
  (define offset (let ([o (opt "--tz-offset")])
                   (if o
                       (let ([m (regexp-match #px"^([+-])([0-9]{2}):([0-9]{2})$" o)])
                         (unless m (eprintf "evaluate-measure: --tz-offset is ±hh:mm\n") (exit 2))
                         (* (if (equal? (cadr m) "-") -1 1) (+ (* 60 (string->number (caddr m))) (string->number (cadddr m)))))
                       0)))
  (define report (with-handlers ([exn:fail? (lambda (e) (eprintf "~a\n" (exn-message e)) (exit 1))])
                   (evaluate store measure start end #:subject (opt "--subject") #:offset offset)))
  (write-json report) (newline))


;; cmd-sql : store-path sql -> void   one reading statement over a store, as CSV: each stored type is a
;; view of (id, versionId, lastUpdated, resource), with `resources` (every type) and `history` (every
;; version); `resource` is the JSON text, so `resource ->> '$.gender'` reads a value. Read-only: the
;; store a capability app or `load` wrote, looked at without sqlite3 or a workspace.
(define (cmd-sql db sql)
  (define connect (dynamic-require 'db 'sqlite3-connect))
  (define query (dynamic-require 'db 'query))
  (define query-exec (dynamic-require 'db 'query-exec))
  (define query-list (dynamic-require 'db 'query-list))
  (define rows-result-headers (dynamic-require 'db 'rows-result-headers))
  (define rows-result-rows (dynamic-require 'db 'rows-result-rows))
  (define sql-null? (dynamic-require 'db 'sql-null?))
  (unless (regexp-match? #px"^\\s*(?i:select|with)\\b" sql)
    (eprintf "fhir-server: sql: one SELECT (or WITH … SELECT) statement\n") (exit 2))
  (define c (connect #:database db #:mode 'read-only))
  (define (q n) (string-append "\"" (regexp-replace* #rx"\"" n "\"\"") "\""))
  (for ([t (in-list (query-list c "SELECT DISTINCT resource_type FROM main.fhir_resources ORDER BY 1"))])
    (query-exec c (format "CREATE TEMP VIEW ~a AS SELECT id, version_id AS versionId, last_updated AS lastUpdated, json(resource) AS resource FROM main.fhir_resources WHERE resource_type = '~a'"
                          (q t) (regexp-replace* #rx"'" t "''"))))
  (query-exec c "CREATE TEMP VIEW resources AS SELECT resource_type AS type, id, version_id AS versionId, last_updated AS lastUpdated, json(resource) AS resource FROM main.fhir_resources")
  (query-exec c "CREATE TEMP VIEW history AS SELECT resource_type AS type, id, version_id AS versionId, last_updated AS lastUpdated, json(resource) AS resource FROM main.fhir_history")
  (define r (with-handlers ([exn:fail? (lambda (e) (eprintf "fhir-server: sql: ~a\n" (exn-message e)) (exit 1))]) (query c sql)))
  (define (cell v)
    (define t (cond [(sql-null? v) ""] [(bytes? v) (bytes->string/utf-8 v #\?)] [else (format "~a" v)]))
    (if (regexp-match? #rx"[\",\n]" t) (string-append "\"" (regexp-replace* #rx"\"" t "\"\"") "\"") t))
  (displayln (string-join (for/list ([h (in-list (rows-result-headers r))]) (cell (cdr (assq 'name h)))) ","))
  (for ([row (in-list (rows-result-rows r))])
    (displayln (string-join (for/list ([v (in-vector row)]) (cell v)) ","))))

(define usages
  '(("serve-ig"         "raco fhir-server serve-ig <ig> [--db store.db] [--port 8080] [--bearer token] [--capability id] [--load file|dir]… [--tz-offset ±hh:mm] [--no-examples] [--no-validate] [--gaps]")
    ("serve"            "raco fhir-server serve <app.rkt> [port | --port n] [--store fhir.db] [--log]   (port 0: a free one, printed; --store: resources declared without a repository kept in that SQLite store, over the module's own #:store; --log: one line per request on stderr)")
    ("load"             "raco fhir-server load <store.db> <file|dir>   (Bundles, resources, .cql libraries)")
    ("sql"              "raco fhir-server sql <store.db> \"SELECT …\"   (read-only; a view per type: id, versionId, lastUpdated, resource; resources, history; CSV out)")
    ("evaluate-measure" "raco fhir-server evaluate-measure <store.db> <Measure id|url> --period-start D --period-end D [--subject Patient/x] [--tz-offset ±hh:mm]")))

(module+ main
  (define (arg as n) (and (> (length as) n) (list-ref as n)))
  (define (need as n cmd) (unless (arg as n) (usage-error "fhir-server" usages cmd)))
  (run-subcommands
   "fhir-server" usages
   (hash "serve-ig" (lambda (as) (need as 0 "serve-ig") (cmd-serve-ig as))
         "serve" (lambda (as) (need as 0 "serve") (require-files! "fhir-server" usages "serve" (list (arg as 0)))
                   (define store (let ([m (member "--store" as)]) (and m (pair? (cdr m)) (cadr m))))
                   (define log? (and (member "--log" as) #t))
                   (define port-flag (let ([m (member "--port" as)]) (and m (pair? (cdr m)) (cadr m))))
                   (define plain (let loop ([xs as]) (cond [(null? xs) '()] [(member (car xs) '("--store" "--port")) (if (pair? (cdr xs)) (loop (cddr xs)) '())]
                                                           [(equal? (car xs) "--log") (loop (cdr xs))] [else (cons (car xs) (loop (cdr xs)))])))
                   (define port-str (or port-flag (and (pair? (cdr plain)) (cadr plain))))
                   (unless (or (not port-str) (let ([n (string->number port-str)]) (and (exact-nonnegative-integer? n) (<= n 65535))))
                     (usage-error "fhir-server" usages "serve" (format "not a port: ~a" port-str)))
                   (cmd-serve (car plain) port-str store #:log? log?))
         "load" (lambda (as) (need as 1 "load")
                  (unless (or (file-exists? (arg as 1)) (directory-exists? (arg as 1)))
                    (usage-error "fhir-server" usages "load" (format "no such file or directory: ~a" (arg as 1))))
                  (cmd-load (arg as 0) (arg as 1)))
         "sql" (lambda (as) (need as 1 "sql")
                 (unless (file-exists? (arg as 0)) (usage-error "fhir-server" usages "sql" (format "no such store: ~a" (arg as 0))))
                 (cmd-sql (arg as 0) (arg as 1)))
         "evaluate-measure" (lambda (as) (need as 1 "evaluate-measure") (cmd-evaluate-measure as)))
   (vector->list (current-command-line-arguments))))
