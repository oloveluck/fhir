#lang racket/base

;;; mcp-cli.rkt — `raco fhir-mcp`: the Model Context Protocol server over a FHIR workspace.
;;;
;;;   raco fhir-mcp [serve] [--workspace <dir>] [--package <tgz|name>]… [--data <dir|file|url>] [--legacy-tools]
;;;                                      serve on stdin/stdout (one JSON line per message): the nine
;;;                                      workspace tools over <dir> (default: the current directory),
;;;                                      configured by its workspace.yaml; --package and --data add to and
;;;                                      override it; --legacy-tools also serves the per-language and
;;;                                      per-operation tools
;;;   raco fhir-mcp tools [same flags]   the tools offered, with their schemas (JSON)
;;;   raco fhir-mcp call <tool> ['<json arguments>'] [same flags]   run one tool, print its text (exit 1 on error)

(require racket/list racket/string json
         (only-in fhir/subcommands run-subcommands usage-error)
         "mcp/server.rkt" "mcp/tools.rkt" "mcp/workspace.rkt" "mcp/verbs.rkt"
         (only-in "mcp/resources.rkt" current-result-resources))

(define flags "[--workspace <dir>] [--package <tgz|name>]… [--data <dir|file|url>] [--legacy-tools]")
(define usages
  `(("serve" ,(format "raco fhir-mcp [serve] ~a   the server over stdin/stdout" flags))
    ("tools" ,(format "raco fhir-mcp tools ~a   the tools and their schemas" flags))
    ("call"  ,(format "raco fhir-mcp call <tool> ['<json>'] ~a   run one tool" flags))))

;; A Flags is (flags workspace packages data legacy? rest)
(struct opts (workspace packages data legacy? rest))
(define (read-flags args)
  (let loop ([as args] [o (opts #f '() #f #f '())])
    (match-args as o loop)))
(define (match-args as o loop)
  (cond [(null? as) (struct-copy opts o [packages (reverse (opts-packages o))] [rest (reverse (opts-rest o))])]
        [(and (equal? (car as) "--workspace") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [workspace (cadr as)]))]
        [(and (equal? (car as) "--package") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [packages (cons (cadr as) (opts-packages o))]))]
        [(and (equal? (car as) "--data") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [data (cadr as)]))]
        [(equal? (car as) "--legacy-tools") (loop (cdr as) (struct-copy opts o [legacy? #t]))]
        [else (loop (cdr as) (struct-copy opts o [rest (cons (car as) (opts-rest o))]))]))

;; with-workspace : opts (hub tools -> any) -> any   the hub opened, its context and results in place
(define (with-workspace o k)
  (define dir (or (opts-workspace o) (current-directory)))
  (unless (directory-exists? dir) (eprintf "fhir-mcp: no such directory: ~a\n" dir) (exit 2))
  (define h (open-hub dir #:data (opts-data o) #:packages (opts-packages o)))
  (define tools (append (workspace-tools h) (if (opts-legacy? o) (all-tools) '())))
  (parameterize ([current-result-resources (cons (lambda () (hub-result-uris h)) (lambda (u) (hub-read-result h u)))])
    (with-hub h (lambda () (k h tools)))))

(define (serve-command args)
  (with-workspace (read-flags args) (lambda (h tools) (serve tools))))

(define (tools-command args)
  (with-workspace (read-flags args) (lambda (h tools) (write-json (hasheq 'tools (map tool->jsexpr tools))) (newline))))

(define (call-command args)
  (define o (read-flags args))
  (define rest (opts-rest o))
  (when (null? rest) (usage-error "fhir-mcp" usages "call" "no tool named"))
  (define name (car rest))
  (define arguments (if (pair? (cdr rest))
                        (with-handlers ([exn:fail? (lambda (_) (usage-error "fhir-mcp" usages "call" "the arguments are not JSON"))])
                          (string->jsexpr (cadr rest)))
                        (hasheq)))
  (with-workspace o
    (lambda (h tools)
      (define t (findf (lambda (x) (equal? (tool-name x) name)) tools))
      (unless t (usage-error "fhir-mcp" usages "call" (format "no tool ~a (raco fhir-mcp tools lists them)" name)))
      (define-values (text err?) (call-tool t arguments))
      (displayln text)
      (exit (if err? 1 0)))))

(module+ main
  (define args (vector->list (current-command-line-arguments)))
  (cond
    [(or (null? args) (regexp-match? #rx"^--" (car args))) (serve-command args)]
    [else (run-subcommands "fhir-mcp" usages
                           (hash "serve" serve-command "tools" tools-command "call" call-command)
                           args)]))
