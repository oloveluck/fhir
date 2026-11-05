#lang racket/base

;;; mcp-cli.rkt — `raco fhir-mcp`: the Model Context Protocol server over the FHIR family.
;;;
;;;   raco fhir-mcp [serve] [--package <tgz|name>]… [--data <dir>]
;;;                                      serve on stdin/stdout (one JSON line per message); the packages
;;;                                      are the context profiles and value sets resolve from, the data
;;;                                      directory the resources operations read
;;;   raco fhir-mcp tools                the tools offered, with their schemas (JSON)
;;;   raco fhir-mcp call <tool> ['<json arguments>']   run one tool, print its text (exit 1 on error)

(require racket/list racket/string json
         (only-in fhir/subcommands run-subcommands usage-error)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/data-source current-data-source directory->data-source)
         "mcp/server.rkt" "mcp/tools.rkt")

(define usages
  '(("serve" "raco fhir-mcp [serve] [--package <tgz|name>]… [--data <dir>]   the server over stdin/stdout")
    ("tools" "raco fhir-mcp tools [--package <tgz|name>]…                  the tools and their schemas")
    ("call"  "raco fhir-mcp call <tool> ['<json>'] [--package <tgz|name>]… [--data <dir>]   run one tool")))

;; context-flags : args -> (values packages data-dir rest)
(define (context-flags args)
  (let loop ([as args] [pkgs '()] [data #f] [rest '()])
    (cond [(null? as) (values (reverse pkgs) data (reverse rest))]
          [(and (equal? (car as) "--package") (pair? (cdr as))) (loop (cddr as) (cons (cadr as) pkgs) data rest)]
          [(and (equal? (car as) "--data") (pair? (cdr as))) (loop (cddr as) pkgs (cadr as) rest)]
          [else (loop (cdr as) pkgs data (cons (car as) rest))])))
;; package-path : tgz|name -> path   a file, else a package in fhir-spec
(define (package-path p)
  (cond [(file-exists? p) p]
        [(spec-package-path (if (regexp-match? #rx"[.]tgz$" p) p (string-append p ".tgz")) #:optional? #t)]
        [else (eprintf "fhir-mcp: no such package: ~a\n" p) (exit 2)]))

;; with-context : packages data thunk -> any   the tools run in the given context, every installed
;; operation module loaded
(define (with-context pkgs data thunk)
  (load-operations!)
  (parameterize ([current-sd-packages (if (null? pkgs) (current-sd-packages) (map package-path pkgs))]
                 [current-data-source (if data (directory->data-source data) (current-data-source))])
    (thunk)))

(define (serve-command args)
  (define-values (pkgs data rest) (context-flags args))
  (with-context pkgs data (lambda () (serve (all-tools)))))

(define (tools-command args)
  (define-values (pkgs data rest) (context-flags args))
  (with-context pkgs data (lambda () (write-json (hasheq 'tools (map tool->jsexpr (all-tools)))) (newline))))

(define (call-command args)
  (define-values (pkgs data rest) (context-flags args))
  (when (null? rest) (usage-error "fhir-mcp" usages "call" "no tool named"))
  (define name (car rest))
  (define arguments (if (pair? (cdr rest))
                        (with-handlers ([exn:fail? (lambda (_) (usage-error "fhir-mcp" usages "call" "the arguments are not JSON"))])
                          (string->jsexpr (cadr rest)))
                        (hasheq)))
  (with-context pkgs data
    (lambda ()
      (define t (findf (lambda (x) (equal? (tool-name x) name)) (all-tools)))
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
