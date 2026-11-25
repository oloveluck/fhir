#lang racket/base

;;; api-cli.rkt — `raco fhir-api`: the toolkit's functions for a program in another language.
;;;
;;;   raco fhir-api [serve] [--fhir-version v] [--package p]…     the functions over JSON lines (stdin/stdout)
;;;   raco fhir-api functions [--json]                            the table of functions
;;;   raco fhir-api call <function> ['<json>' | -] […]            one call, its answer printed
;;;
;;; A Command is one of: (serve-cmd options) | (functions-cmd json?) | (call-cmd name arguments options)
;;; | (help-cmd) | (usage-error message), parsed from the arguments by `parse-args` (data, tested).
;;; Options is (options fhir-version packages).

(require racket/list racket/match racket/port racket/string json
         "api/functions.rkt" "api/session.rkt" "api/server.rkt")

(provide parse-args usage-text
         (struct-out options) (struct-out serve-cmd) (struct-out functions-cmd) (struct-out call-cmd)
         (struct-out help-cmd) (struct-out usage-error))

(struct options (fhir-version packages) #:transparent)
(struct serve-cmd (options) #:transparent)
(struct functions-cmd (json?) #:transparent)
(struct call-cmd (name arguments options) #:transparent)
(struct help-cmd () #:transparent)
(struct usage-error (message) #:transparent)

(define usage-text
  (string-append
   "raco fhir-api [serve] [--fhir-version 4.0.1|5.0.0] [--package <name|file.tgz>]…   the functions over JSON lines on stdin/stdout (JSON-RPC 2.0, one message to a line)\n"
   "raco fhir-api functions [--json]   the functions: names, parameters, what each answers (--json: with a JSON Schema for each)\n"
   "raco fhir-api call <function> ['<json arguments>' | -] [--fhir-version 4.0.1|5.0.0] [--package <name|file.tgz>]…   one call: its answer as JSON (- reads the arguments from stdin)\n"))

;; take-options : (listof string) -> (values options rest) | usage-error
(define (take-options args)
  (let loop ([args args] [version "4.0.1"] [packages '()] [rest '()])
    (match args
      ['() (values (options version (reverse packages)) (reverse rest))]
      [(list "--fhir-version" v more ...) (loop more v packages rest)]
      [(list "--package" p more ...) (loop more version (cons p packages) rest)]
      [(list (and flag (or "--fhir-version" "--package"))) (values (usage-error (format "~a needs a value" flag)) '())]
      [(list (pregexp #px"^--") _ ...) #:when (not (member (car args) '("--json")))
       (values (usage-error (format "unknown option ~a" (car args))) '())]
      [(list a more ...) (loop more version packages (cons a rest))])))

;; parse-args : (listof string) -> Command
(define (parse-args args)
  (cond
    [(or (member "-h" args) (member "--help" args)) (help-cmd)]
    [else
     (define-values (opts rest) (take-options args))
     (cond
       [(usage-error? opts) opts]
       [else
        (match rest
          [(or '() (list "serve")) (serve-cmd opts)]
          [(list "functions") (functions-cmd #f)]
          [(list "functions" "--json") (functions-cmd #t)]
          [(list "call" name) (call-cmd name "{}" opts)]
          [(list "call" name arguments) (call-cmd name arguments opts)]
          [(list "call") (usage-error "call needs a function's name")]
          [_ (usage-error (format "unknown command ~a" (string-join rest " ")))])])]))

;; run-call : call-cmd -> exit status   one call through the server's own `answer`
(define (run-call c)
  (define text (if (equal? (call-cmd-arguments c) "-") (port->string (current-input-port)) (call-cmd-arguments c)))
  (define arguments (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr text)))
  (cond
    [(not (hash? arguments)) (eprintf "fhir-api: the arguments are a JSON object\n") 2]
    [else
     (define s (open-session #:fhir-version (options-fhir-version (call-cmd-options c)) #:packages (options-packages (call-cmd-options c))))
     (define reply (answer s (hasheq 'jsonrpc "2.0" 'id 1 'method (call-cmd-name c) 'params arguments)))
     (close-session! s)
     (cond [(hash-ref reply 'error #f)
            => (lambda (e)
                 (eprintf "fhir-api: ~a\n" (regexp-replace #rx"^fhir-api: " (hash-ref e 'message) ""))
                 (if (member (hash-ref e 'code) '(-32601 -32602)) 2 1))]
           [else (write-json (hash-ref reply 'result)) (newline) 0])]))

(module+ main
  (define status
    (match (parse-args (vector->list (current-command-line-arguments)))
      [(help-cmd) (display usage-text) 0]
      [(usage-error m) (eprintf "fhir-api: ~a\n~a" m usage-text) 2]
      [(functions-cmd json?)
       (display (if json? (functions-json-text) (functions->text)))
       0]
      [(? call-cmd? c) (run-call c)]
      [(serve-cmd o)
       (with-handlers ([exn:fail:user? (lambda (e) (eprintf "fhir-api: ~a\n" (regexp-replace #rx"^fhir-api: " (exn-message e) "")) 2)])
         (define s (open-session #:fhir-version (options-fhir-version o) #:packages (options-packages o)))
         (dynamic-wind void
                       (lambda () (serve s (current-input-port) (current-output-port)) 0)
                       (lambda () (close-session! s))))]))
  (exit status))

(module+ test
  (require rackunit)
  (check-equal? (parse-args '()) (serve-cmd (options "4.0.1" '())))
  (check-equal? (parse-args '("serve" "--fhir-version" "5.0.0" "--package" "a" "--package" "b"))
                (serve-cmd (options "5.0.0" '("a" "b"))))
  (check-equal? (parse-args '("functions")) (functions-cmd #f))
  (check-equal? (parse-args '("functions" "--json")) (functions-cmd #t))
  (check-equal? (parse-args '("call" "version")) (call-cmd "version" "{}" (options "4.0.1" '())))
  (check-equal? (parse-args '("call" "fhirpath" "{}" "--fhir-version" "5.0.0")) (call-cmd "fhirpath" "{}" (options "5.0.0" '())))
  (check-equal? (parse-args '("--help")) (help-cmd))
  (check-equal? (parse-args '("serve" "-h")) (help-cmd))
  (check-pred usage-error? (parse-args '("call")))
  (check-pred usage-error? (parse-args '("frobnicate")))
  (check-pred usage-error? (parse-args '("--fhir-version")))
  (check-pred usage-error? (parse-args '("serve" "--nope"))))
