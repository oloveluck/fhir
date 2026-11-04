#lang racket/base

;;; tx-cli.rkt — `raco fhir-tx`: the terminology service from the command line.
;;;
;;;   raco fhir-tx expand <ValueSet url> [--package <tgz|name>]… [--filter <text>] [--count <n>] [--offset <n>]
;;;   raco fhir-tx validate-code <ValueSet url> <system> <code> [--display <text>] [--package …]…
;;;   raco fhir-tx lookup <system> <code> [--package …]…
;;;   raco fhir-tx translate <ConceptMap url> <code> [--system <system>] [--package …]…
;;;   raco fhir-tx subsumes <system> <codeA> <codeB> [--package …]…
;;;   raco fhir-tx serve [--package <tgz|name>]… [--port <n>] [--url <base url>]
;;;                                    a terminology server over the packages (needs fhir-server)
;;;   raco fhir-tx tck [-v]            the official hl7.fhir.uv.tx-ecosystem suite (floor-ratcheted)
;;;
;;; The resources come from the packages named (a .tgz path, or a file in fhir-spec such as
;;; hl7.fhir.us.core-6.1.0.tgz), searched in order; with none, the R5 core. The answer is the
;;; operation's FHIR JSON (a ValueSet or a Parameters) on stdout.
;;; Exit codes: 0 ok · 1 the operation failed / a suite regression · 2 usage.

(require racket/list racket/string
         (only-in json jsexpr->string)
         (only-in fhir/subcommands run-subcommands usage-error)
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/terminology/service packages->resolver expand/json validate-code/json
                  lookup/json translate/json subsumes/json))

(provide resolver-of split-options)

(define usages
  '(("expand"        "raco fhir-tx expand <ValueSet url> [--package <tgz|name>]… [--filter <text>] [--count <n>] [--offset <n>]")
    ("validate-code" "raco fhir-tx validate-code <ValueSet url> <system> <code> [--display <text>] [--package <tgz|name>]…")
    ("lookup"        "raco fhir-tx lookup <system> <code> [--package <tgz|name>]…")
    ("translate"     "raco fhir-tx translate <ConceptMap url> <code> [--system <system>] [--package <tgz|name>]…")
    ("subsumes"      "raco fhir-tx subsumes <system> <codeA> <codeB> [--package <tgz|name>]…")
    ("serve"         "raco fhir-tx serve [--package <tgz|name>]… [--port <n>] [--url <base url>]")
    ("tck"           "raco fhir-tx tck [-v]")))

;; split-options : args -> (values positionals (hash option -> (listof value)))
;;   every `--name value` pair is an option (repeatable); the rest are positional, in order
(define (split-options args)
  (let loop ([as args] [pos '()] [opts (hash)])
    (cond
      [(null? as) (values (reverse pos) opts)]
      [(and (regexp-match? #rx"^--" (car as)) (pair? (cdr as)))
       (loop (cddr as) pos (hash-update opts (car as) (lambda (vs) (append vs (list (cadr as)))) '()))]
      [else (loop (cdr as) (cons (car as) pos) opts)])))

;; package-paths : (listof tgz|name) -> (listof path)   the packages in order, the R5 core when none
(define (package-paths names)
  (if (null? names)
      (list (spec-package-path "hl7.fhir.r5.core.tgz"))
      (for/list ([n (in-list names)])
        (if (file-exists? n) n (spec-package-path (if (regexp-match? #rx"[.]tgz$" n) n (string-append n ".tgz")))))))

;; resolver-of : (listof tgz|name) -> resolver
(define (resolver-of names) (packages->resolver (package-paths names)))

;; serve : packages port url -> never   the terminology operations over HTTP (fhir-server, loaded on demand)
(define (serve names port url)
  (define serve-operations
    (with-handlers ([exn:fail:filesystem:missing-module?
                     (lambda (_) (eprintf "fhir-tx serve needs the fhir-server package: raco pkg install fhir-server\n") (exit 2))])
      (dynamic-require 'fhir/capability/operations 'serve-operations)))
  (dynamic-require 'fhir/r5/schemas #f)            ; the tower the served resources build against
  (current-sd-packages (package-paths names))      ; what the operations resolve from
  (define ops (dynamic-require 'fhir/terminology/operations 'terminology-operations))
  (define capabilities ((dynamic-require 'fhir/terminology/operations 'current-terminology-capabilities) #:url url))
  (define stop (serve-operations ops #:port port #:url url #:terminology-capabilities capabilities))
  (printf "terminology server on http://localhost:~a  (GET /metadata, /metadata?mode=terminology; Ctrl-C to stop)\n" port)
  (with-handlers ([exn:break? (lambda (_) (stop))]) (sync/enable-break never-evt)))

(define (option opts name [default #f])
  (let ([vs (hash-ref opts name '())]) (if (pair? vs) (last vs) default)))

(define (print-json js) (displayln (jsexpr->string js)))

(define (run cmd args)
  (define-values (pos opts) (split-options args))
  (define (need n) (unless (= (length pos) n) (usage-error "fhir-tx" usages cmd)))
  (define r (resolver-of (hash-ref opts "--package" '())))
  (with-handlers ([exn:fail? (lambda (e) (eprintf "fhir-tx: ~a\n" (exn-message e)) (exit 1))])
    (case cmd
      [("expand")
       (need 1)
       (define params
         (for/hash ([k '("filter" "count" "offset")] #:when (option opts (string-append "--" k)))
           (values k (let ([v (option opts (string-append "--" k))])
                       (if (member k '("count" "offset")) (or (string->number v) v) v)))))
       (print-json (expand/json r (car pos) #f params))]
      [("validate-code")
       (need 3)
       (print-json (validate-code/json r (car pos) (caddr pos) (cadr pos) #:display (option opts "--display")))]
      [("lookup")
       (need 2)
       (print-json (lookup/json r (car pos) (cadr pos)))]
      [("translate")
       (need 2)
       (print-json (translate/json r (car pos) (cadr pos) (option opts "--system")))]
      [("subsumes")
       (need 3)
       (print-json (subsumes/json r (car pos) (cadr pos) (caddr pos)))])))

(module+ main
  (define args (vector->list (current-command-line-arguments)))
  (run-subcommands
   "fhir-tx" usages
   (hash "expand"        (lambda (as) (run "expand" as))
         "validate-code" (lambda (as) (run "validate-code" as))
         "lookup"        (lambda (as) (run "lookup" as))
         "translate"     (lambda (as) (run "translate" as))
         "subsumes"      (lambda (as) (run "subsumes" as))
         "serve"         (lambda (as)
                           (define-values (pos opts) (split-options as))
                           (unless (null? pos) (usage-error "fhir-tx" usages "serve"))
                           (serve (hash-ref opts "--package" '())
                                  (or (string->number (option opts "--port" "8080")) (usage-error "fhir-tx" usages "serve" "--port needs a number"))
                                  (option opts "--url")))
         "tck"           (lambda (as) (parameterize ([current-command-line-arguments (list->vector as)])
                                        (dynamic-require '(submod fhir/terminology/tests/run-tx main) #f))))
   args))

(module+ test
  (require rackunit)
  (define-values (pos opts) (split-options '("http://x" "--package" "a.tgz" "--package" "b.tgz" "--count" "5")))
  (check-equal? pos '("http://x"))
  (check-equal? (hash-ref opts "--package") '("a.tgz" "b.tgz"))
  (check-equal? (hash-ref opts "--count") '("5")))
