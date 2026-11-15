#lang racket/base

;;; mcp-main.rkt — `raco fhir-mcp`'s entry: a shell call handed to a warm process when there is one.
;;;
;;; A call from the shell (`raco fhir-mcp call …`, `batch …`) cost ~1 s, nearly all of it before the
;;; tool ran: loading the modules (~0.45 s), reading the workspace and its FHIR version's types and
;;; opening its store (~0.35 s). A warm process (mcp-daemon.rkt) opens the workspace afresh for each
;;; call — the same hub, files and saved results and stages a new process would read — with its
;;; modules, types and store already loaded: ~60 ms. So this module, which loads almost nothing,
;;; first asks the workspace's warm process over a Unix socket; when there is none it starts one in
;;; the background for the next call and runs this one itself, as before (mcp-cli.rkt).
;;;
;;; A warm process serves one workspace, under one set of collections: the socket's name is the
;;; SHA-1 of the workspace's directory, the add-on directory, the collection paths and Racket's
;;; version, in a directory of the user's own (mode 700) under the temporary directory. It stops
;;; after `idle-seconds` without a call, when its workspace is gone, and when the installed code
;;; changes under it (it answers `stale` and the call runs here). FHIR_MCP_DAEMON=0 turns it off.

(require racket/unix-socket json file/sha1 racket/port)

(provide socket-path daemon-enabled? workspace-dir idle-seconds)

;; idle-seconds : how long a warm process waits for a call before it stops
(define idle-seconds 300)

;; daemon-enabled? : -> boolean   FHIR_MCP_DAEMON=0 (or no Unix sockets) keeps every call in its own process
(define (daemon-enabled?)
  (and unix-socket-available? (not (member (getenv "FHIR_MCP_DAEMON") '("0" "no" "off" "false")))))

;; workspace-dir : (listof string) -> path   the workspace a command's arguments name (`--workspace d`),
;; else the current directory, as a complete directory path
(define (workspace-dir args)
  (define named (let loop ([as args]) (cond [(or (null? as) (null? (cdr as))) #f]
                                            [(equal? (car as) "--workspace") (cadr as)]
                                            [else (loop (cdr as))])))
  (path->directory-path (simplify-path (path->complete-path (or named (current-directory))))))

;; socket-path : directory -> path   the warm process's socket for this workspace and installation
(define (socket-path dir)
  (define key (sha1 (open-input-string
                     (format "~s" (list (path->string dir) (path->string (find-system-path 'addon-dir))
                                        (map (lambda (p) (if (path? p) (path->string p) p)) (current-library-collection-paths))
                                        (version))))))
  (build-path (find-system-path 'temp-dir) (format "fhir-mcp-~a" (or (getenv "USER") "user")) (string-append (substring key 0 20) ".sock")))

;; forward : (listof string) -> (or/c exact-integer? #f)   the call answered by the warm process (its
;; output printed, its exit status answered), or #f when there is none to answer it
(define (forward args sock)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (define-values (in out) (unix-socket-connect sock))
    (dynamic-wind
     void
     (lambda ()
       (write-json (hasheq 'argv args
                           'cwd (path->string (current-directory))
                           'env (for/hasheq ([n (in-list (environment-variables-names (current-environment-variables)))])
                                  (values (string->symbol (bytes->string/utf-8 n #\?))
                                          (bytes->string/utf-8 (or (environment-variables-ref (current-environment-variables) n) #"") #\?)))
                           'stdin (and (reads-stdin? args) (port->string (current-input-port))))
                   out)
       (newline out) (flush-output out)
       (close-output-port out)
       (define answer (read-json in))
       (cond [(and (hash? answer) (exact-integer? (hash-ref answer 'exit #f)))
              (write-string (hash-ref answer 'stdout ""))
              (write-string (hash-ref answer 'stderr "") (current-error-port))
              (hash-ref answer 'exit)]
             [else #f]))
     (lambda () (close-input-port in) (close-output-port out)))))

;; reads-stdin? : (listof string) -> boolean   the call reads its standard input: `-`, or a batch
;; given no file
(define (reads-stdin? args)
  (or (and (member "-" args) #t)
      (and (equal? (car args) "batch")
           (let loop ([as (cdr args)])
             (cond [(null? as) #t]
                   [(member (car as) '("--workspace" "--package" "--data")) (if (pair? (cdr as)) (loop (cddr as)) #t)]
                   [(regexp-match? #rx"^--" (car as)) (loop (cdr as))]
                   [else #f])))))

;; start-daemon! : directory path -> void   a warm process for the workspace, in the background (its
;; own session: it outlives this one), its output discarded
(define (start-daemon! dir sock)
  (with-handlers ([exn:fail? void])
    (define racket ((dynamic-require 'compiler/find-exe 'find-exe)))
    (define (quoted s) (string-append "'" (regexp-replace* #rx"'" s "'\\\\''") "'"))
    (define cmd (format "cd / && exec ~a ~a -l- fhir/mcp-daemon ~a </dev/null >/dev/null 2>&1"
                        (if (file-exists? "/usr/bin/setsid") "/usr/bin/setsid" "")
                        (quoted (path->string racket)) (quoted (path->string dir))))
    (define-values (p o i e) (subprocess #f #f #f "/bin/sh" "-c" (string-append cmd " &")))
    (close-output-port i) (close-input-port o) (close-input-port e)
    (subprocess-wait p)))

(module+ main
  (define args (vector->list (current-command-line-arguments)))
  ;; a call or a batch, not its usage (`--help` is mcp-cli's, through run-subcommands)
  (define warm? (and (pair? args) (member (car args) '("call" "batch")) (not (member "--help" args)) (not (member "-h" args))
                     (daemon-enabled?)))
  (define sock (and warm? (socket-path (workspace-dir (cdr args)))))
  (define code (and sock (file-exists? sock) (forward args sock)))
  (cond
    [code (flush-output) (flush-output (current-error-port)) (exit code)]
    [else
     (when (and sock (directory-exists? (workspace-dir (cdr args)))) (start-daemon! (workspace-dir (cdr args)) sock))
     (dynamic-require '(submod fhir/mcp-cli main) #f)]))
