#lang racket/base

;;; mcp-cli.rkt — `raco fhir-mcp`: the Model Context Protocol server over a FHIR workspace.
;;;
;;;   raco fhir-mcp [serve] [--workspace <dir>] [--package <tgz|name>]… [--data <dir|file|url>]
;;;                                      serve on stdin/stdout (one JSON line per message): the nine
;;;                                      workspace tools over <dir> (default: the current directory),
;;;                                      configured by its workspace.yaml; --package and --data add to and
;;;                                      override it
;;;   raco fhir-mcp tools [same flags]   the tools offered, with their schemas (JSON)
;;;   raco fhir-mcp call <tool> ['<json arguments>'] [same flags]   run one tool, print its text (exit 1 on error)
;;;   raco fhir-mcp guide [<topic>]      a learn:// guide as text (the topics, without one): every
;;;                                      language's guide and the workspace's, with no server running

(require (only-in "mcp/init.rkt" init-workspace!)
         racket/list racket/string racket/port racket/file json
         (only-in fhir/subcommands run-subcommands usage-error)
         "mcp/server.rkt" "mcp/tools.rkt" "mcp/workspace.rkt" "mcp/verbs.rkt"
         (only-in "mcp/resources.rkt" current-result-resources learn-topics learn-text)
         (only-in "mcp/trail.rkt" current-agent))

(define flags "[--workspace <dir>] [--package <tgz|name>]… [--data <dir|file|url>]")
(define usages
  `(("serve" ,(format "raco fhir-mcp [serve] ~a   the server over stdin/stdout" flags))
    ("tools" ,(format "raco fhir-mcp tools ~a   the tools and their schemas" flags))
    ("call"  ,(format "raco fhir-mcp call <tool> ['<json>' | -] [key=value | key=@file | key:=<json>]… ~a   run one tool: arguments as a JSON object (- reads it from stdin) and/or one by one, a file's text with @" flags))
    ("init"  "raco fhir-mcp init [<dir>] [--fhir-version 4.0.1|5.0.0]   make a directory a workspace an agent can use: workspace.yaml (data: fhir.db, a SQLite FHIR store), .mcp.json, CLAUDE.md")
    ("guide" "raco fhir-mcp guide [<topic>]   a guide (learn://<topic>) as text; without a topic, the topics")))

;; An Opts is (opts workspace packages data rest)
(struct opts (workspace packages data rest))
(define (read-flags args)
  (let loop ([as args] [o (opts #f '() #f '())])
    (match-args as o loop)))
(define (match-args as o loop)
  (cond [(null? as) (struct-copy opts o [packages (reverse (opts-packages o))] [rest (reverse (opts-rest o))])]
        [(and (equal? (car as) "--workspace") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [workspace (cadr as)]))]
        [(and (equal? (car as) "--package") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [packages (cons (cadr as) (opts-packages o))]))]
        [(and (equal? (car as) "--data") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [data (cadr as)]))]
        [else (loop (cdr as) (struct-copy opts o [rest (cons (car as) (opts-rest o))]))]))

;; with-workspace : opts (hub tools -> any) -> any   the hub opened, its context and results in place
(define (with-workspace o k)
  (define dir (or (opts-workspace o) (current-directory)))
  (unless (directory-exists? dir) (eprintf "fhir-mcp: no such directory: ~a\n" dir) (exit 2))
  (define h (open-hub dir #:data (opts-data o) #:packages (opts-packages o)))
  (define tools (workspace-tools h))
  (parameterize ([current-result-resources (cons (lambda () (hub-result-uris h)) (lambda (u) (hub-read-result h u)))])
    (with-hub h (lambda () (k h tools)))))

;; only-flags : command opts -> opts   a word that is not a flag is a usage error
(define (only-flags cmd o)
  (unless (null? (opts-rest o)) (usage-error "fhir-mcp" usages cmd (format "unexpected ~a" (car (opts-rest o)))))
  o)

(define (serve-command args)
  (with-workspace (only-flags "serve" (read-flags args)) (lambda (h tools) (serve tools))))

(define (tools-command args)
  (with-workspace (only-flags "tools" (read-flags args)) (lambda (h tools) (write-json (hasheq 'tools (map tool->jsexpr tools))) (newline))))

(define (call-command args)
  (define o (read-flags args))
  (define rest (opts-rest o))
  (when (null? rest) (usage-error "fhir-mcp" usages "call" "no tool named"))
  (define name (car rest))
  (define arguments (call-arguments (cdr rest)))
  ;; who the trail names: the shell, unless FHIR_MCP_AGENT says who is at it
  (set-box! current-agent (or (getenv "FHIR_MCP_AGENT") "raco fhir-mcp call"))
  (with-workspace o
    (lambda (h tools)
      (define t (findf (lambda (x) (equal? (tool-name x) name)) tools))
      (unless t (usage-error "fhir-mcp" usages "call" (format "no tool ~a (raco fhir-mcp tools lists them)" name)))
      (define-values (text err?) (call-tool t arguments))
      (displayln text)
      (exit (if err? 1 0)))))

;; call-arguments : (listof string) -> jsexpr   a JSON object (or `-`: JSON on stdin), then
;; `key=value` (a string), `key=@file` (the file's text: FSH, CQL, SQL with no escaping) and
;; `key:=<json>` (a number, a boolean, an array, an object), later ones winning
(define (call-arguments words)
  (define (bad msg) (usage-error "fhir-mcp" usages "call" msg))
  (define (json-of s what)
    (with-handlers ([exn:fail? (lambda (_) (bad (format "~a is not JSON" what)))]) (string->jsexpr s)))
  (for/fold ([args (hasheq)]) ([w (in-list words)])
    (cond
      [(equal? w "-") (let ([j (json-of (port->string (current-input-port)) "stdin")])
                        (if (hash? j) (for/fold ([a args]) ([(k v) (in-hash j)]) (hash-set a k v)) (bad "stdin is not a JSON object")))]
      [(regexp-match? #rx"^[ \t\n]*[{]" w)
       (let ([j (json-of w "the arguments")]) (for/fold ([a args]) ([(k v) (in-hash j)]) (hash-set a k v)))]
      [(regexp-match #rx"^([A-Za-z_][A-Za-z0-9_]*):=(.*)$" w)
       => (lambda (m) (hash-set args (string->symbol (cadr m)) (json-of (caddr m) (format "~a's value" (cadr m)))))]
      [(regexp-match #rx"^([A-Za-z_][A-Za-z0-9_]*)=@(.+)$" w)
       => (lambda (m) (define f (caddr m))
            (unless (file-exists? f) (bad (format "~a=@~a: no such file" (cadr m) f)))
            (hash-set args (string->symbol (cadr m)) (file->string f)))]
      [(regexp-match #rx"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$" w)
       => (lambda (m) (hash-set args (string->symbol (cadr m)) (caddr m)))]
      [else (bad (format "unexpected ~a (arguments are '<json>', key=value, key=@file or key:=<json>)" w))])))

;; init-command : args -> void   a directory made ready for an agent (mcp/init.rkt); one line per file
(define (init-command args)
  (define-values (dir fv)
    (let loop ([as args] [dir #f] [fv "4.0.1"])
      (cond [(null? as) (values (or dir ".") fv)]
            [(and (equal? (car as) "--fhir-version") (pair? (cdr as)))
             (unless (member (cadr as) '("4.0.1" "5.0.0")) (usage-error "fhir-mcp" usages "init" (format "--fhir-version ~a: 4.0.1 or 5.0.0" (cadr as))))
             (loop (cddr as) dir (cadr as))]
            [(and (not dir) (not (regexp-match? #rx"^-" (car as)))) (loop (cdr as) (car as) fv)]
            [else (usage-error "fhir-mcp" usages "init" (format "unexpected ~a" (car as)))])))
  (for ([r (in-list (init-workspace! dir #:fhir-version fv))])
    (printf "~a ~a\n" (if (eq? (cdr r) 'written) "wrote" "kept ") (path->string (build-path dir (car r)))))
  (printf "Claude Code starts the server from .mcp.json in ~a. The data is ~a, a SQLite FHIR store: stage and commit write it; raco fhir-server load ~a <dir> imports FHIR JSON\n"
          dir (path->string (build-path dir "fhir.db")) (path->string (build-path dir "fhir.db"))))

;; guide-command : args -> void   learn://<topic> printed, or the topics with what each covers
(define (guide-command args)
  (define topic (and (pair? args) (car args)))
  (cond
    [(not topic)
     (for ([t (in-list learn-topics)]) (printf "~a  ~a\n" (car t) (cdr t)))
     (printf "\nraco fhir-mcp guide <topic> prints one; an MCP client reads it as learn://<topic>\n")]
    [(learn-text topic) => display]
    [else (usage-error "fhir-mcp" usages "guide"
                       (format "no guide ~a (topics: ~a)" topic (string-join (map car learn-topics) ", ")))]))

(module+ main
  (define args (vector->list (current-command-line-arguments)))
  (cond
    ;; -h/--help: every usage on stdout, exit 0 (as every raco command of the family)
    [(and (pair? args) (member (car args) '("-h" "--help")))
     (for ([u (in-list usages)]) (printf "~a\n" (cadr u)))
     (exit 0)]
    [(or (null? args) (regexp-match? #rx"^--" (car args))) (serve-command args)]
    [else (run-subcommands "fhir-mcp" usages
                           (hash "serve" serve-command "tools" tools-command "call" call-command "init" init-command "guide" guide-command)
                           args)]))
