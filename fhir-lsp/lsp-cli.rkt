#lang racket/base

;;; lsp-cli.rkt — `raco fhir-lsp`: the language server for the FHIR languages.
;;;
;;;   raco fhir-lsp                          serve the Language Server Protocol on stdin/stdout
;;;   raco fhir-lsp check <file>… [--format text|json|outcome]
;;;                                          the diagnostics the server would publish for each file,
;;;                                          as the other tools print them (exit 1 when any is an error)
;;;   raco fhir-lsp languages                the languages served, by file extension

(require racket/list racket/string racket/file
         (only-in fhir/diagnostic emit-diagnostics format-flag diagnostic-severity)
         (only-in fhir/subcommands run-subcommands usage-error require-files!)
         "lsp/server.rkt" "lsp/languages.rkt")

(define usages
  '(("serve"     "raco fhir-lsp [serve]                                the server, over stdin/stdout")
    ("check"     "raco fhir-lsp check <file>… [--format text|json|outcome]   diagnostics for files, no editor")
    ("languages" "raco fhir-lsp languages                              the languages served")))

(define (check-files args)
  (define-values (fmt files) (format-flag args))
  (when (null? files) (usage-error "fhir-lsp" usages "check" "no files"))
  (require-files! "fhir-lsp" usages "check" files)
  (define ds
    (append*
     (for/list ([f (in-list files)])
       (define lang (language-of f))
       (cond [lang (diagnose lang (file->string f) f)]
             [else (eprintf "fhir-lsp: ~a: not a file of a language served (~a)\n" f
                            (string-join (append-map language-extensions languages) ", "))
                   '()]))))
  (emit-diagnostics ds #:format fmt #:text-of (lambda (src) (and src (file-exists? src) (file->string src))))
  (exit (if (ormap (lambda (d) (eq? (diagnostic-severity d) 'error)) ds) 1 0)))

(define (list-languages _)
  (for ([l (in-list languages)])
    (printf "~a\t~a\n" (language-id l) (string-join (map (lambda (e) (string-append "." e)) (language-extensions l)) " "))))

(module+ main
  (define args (vector->list (current-command-line-arguments)))
  (cond
    ;; `serve` alone starts the server; `serve --help` (or anything after it) is a subcommand call,
    ;; so it prints usage instead of waiting on standard input for an editor that is not there
    [(or (null? args) (equal? args '("serve"))) (serve)]
    [else (run-subcommands "fhir-lsp" usages
                           (hash "serve" (lambda (as) (if (null? as) (serve) (usage-error "fhir-lsp" usages "serve")))
                                 "check" check-files "languages" list-languages)
                           args)]))
