#lang racket/base

;;; mcp-daemon.rkt — the warm process that answers a workspace's shell calls (mcp-main.rkt).
;;;
;;;   racket -l- fhir/mcp-daemon <workspace-dir>
;;;
;;; It listens on the workspace's socket and answers one call at a time, each as `raco fhir-mcp`
;;; would in a process of its own: the command's arguments, working directory, environment and
;;; standard input are the caller's; the workspace is opened afresh (mcp-cli.rkt's commands open a
;;; hub per call), so its files, saved results and stages are read as a new process reads them;
;;; standard output, standard error and the exit status go back to the caller. What stays warm is
;;; what does not depend on the call: the loaded modules, the FHIR types, the open store, the search
;;; catalogue.
;;;
;;; It stops when no call came for `idle-seconds`, when its workspace directory is gone, and — at a
;;; call — when any compiled directory of the family changed since it started (the code it runs is
;;; not the installed code any more): that call is answered `stale` and runs in the caller.
;;;
;;; A Request is {argv, cwd, env, stdin} or {stop: true}; an Answer is {stdout, stderr, exit},
;;; {stale: true} or {stopped: true}.

(require racket/unix-socket racket/file racket/list racket/port json
         (only-in "mcp-main.rkt" socket-path idle-seconds)
         (only-in "mcp-cli.rkt" call-command batch-command)
         (only-in "mcp/workspace.rkt" open-hub))

(provide answer-request code-stamp)

;; answer-request : Request -> Answer   the call run here as it would run in its own process
(define (answer-request req)
  (define out (open-output-string))
  (define err (open-output-string))
  (define argv (hash-ref req 'argv))
  (define env (make-environment-variables))
  (for ([(k v) (in-hash (hash-ref req 'env (hasheq)))])
    (environment-variables-set! env (string->bytes/utf-8 (symbol->string k)) (string->bytes/utf-8 v)))
  (define code
    (let/ec k
      (parameterize ([current-output-port out]
                     [current-error-port err]
                     [current-input-port (open-input-string (let ([s (hash-ref req 'stdin #f)]) (if (string? s) s "")))]
                     [current-directory (hash-ref req 'cwd)]
                     [current-environment-variables env]
                     [exit-handler (lambda (c) (k (if (byte? c) c 0)))])
        (with-handlers ([exn:break? raise]
                        [(lambda (_) #t)
                         (lambda (e) ((error-display-handler) (if (exn? e) (exn-message e) (format "uncaught: ~e" e)) e) 1)])
          (match-command argv)
          0))))
  (hasheq 'stdout (get-output-string out) 'stderr (get-output-string err) 'exit code))

;; match-command : (listof string) -> void   the two commands a warm process answers
(define (match-command argv)
  (cond [(equal? (car argv) "call") (call-command (cdr argv))]
        [(equal? (car argv) "batch") (batch-command (cdr argv))]
        [else (error 'fhir-mcp "a warm process answers call and batch, not ~a" (car argv))]))

;; compiled-dirs : -> (listof path)   every `compiled` directory of the family's collections
(define (compiled-dirs)
  (define roots
    (remove-duplicates
     (for*/list ([c+m (in-list '(("fhir" "registry.rkt") ("fhirpath" "eval.rkt") ("cql" "compile.rkt") ("fsh" "compile.rkt")
                                 ("fml" "compile.rkt") ("vcl" "compile.rkt") ("sql-on-fhir" "view.rkt")))]
                 [p (in-value (with-handlers ([exn:fail? (lambda (_) #f)]) (collection-file-path (cadr c+m) (car c+m))))]
                 #:when p)
       (let-values ([(d _n _x) (split-path p)]) d))))
  (for*/list ([r (in-list roots)]
              [d (in-directory r (lambda (p) (not (regexp-match? #rx"/(vendor|tests|scribblings|[.]git|compiled)$" (path->string p)))))]
              #:when (and (directory-exists? d) (regexp-match? #rx"/compiled$" (path->string d))))
    d))
;; code-stamp : (listof path) -> (listof seconds)   when each compiled directory last changed (a
;; compiled file is written by a rename into it)
(define (code-stamp dirs)
  (for/list ([d (in-list dirs)]) (if (directory-exists? d) (file-or-directory-modify-seconds d) 0)))

;; serve! : directory -> void   listen, warm up, answer until idle or stale
(define (serve! dir)
  (define sock (socket-path dir))
  (define parent (let-values ([(p _n _x) (split-path sock)]) p))
  (make-directory* parent)
  (file-or-directory-permissions parent #o700)
  ;; a socket file nobody listens on (a process that died) is taken over; one that answers is not
  (when (file-exists? sock)
    (cond [(with-handlers ([exn:fail? (lambda (_) #f)]) (let-values ([(i o) (unix-socket-connect sock)]) (close-input-port i) (close-output-port o) #t))
           (exit 0)]
          [else (delete-file sock)]))
  (define listener (with-handlers ([exn:fail? (lambda (_) (exit 0))]) (unix-socket-listen sock 8)))
  (define dirs (compiled-dirs))
  (define stamp (code-stamp dirs))
  (define (stop!) (with-handlers ([exn:fail? void]) (unix-socket-close-listener listener) (delete-file sock)) (exit 0))
  ;; warm up: the modules are loaded; open the workspace once (its types, its store, its catalogue)
  (with-handlers ([exn:fail? void]) (parameterize ([current-directory dir]) (open-hub dir)))
  (let loop ([idle 0])
    (define conn (sync/timeout 30 (unix-socket-accept-evt listener)))
    (cond
      [(not (directory-exists? dir)) (stop!)]
      [(not conn) (if (>= (+ idle 30) idle-seconds) (stop!) (loop (+ idle 30)))]
      [else
       (define in (car conn))
       (define out (cadr conn))
       (define stale? (not (equal? (code-stamp dirs) stamp)))
       (define req (with-handlers ([exn:fail? (lambda (_) #f)]) (read-json in)))
       (define stop? (or stale? (and (hash? req) (hash-ref req 'stop #f) #t)))
       (with-handlers ([exn:fail? void])
         (write-json (cond [stale? (hasheq 'stale #t)]
                           [stop? (hasheq 'stopped #t)]
                           [(hash? req) (answer-request req)]
                           [else (hasheq 'stdout "" 'stderr "fhir-mcp: the call could not be read\n" 'exit 2)])
                     out)
         (flush-output out))
       (close-input-port in)
       (close-output-port out)
       (if stop? (stop!) (loop 0))])))

(module+ main
  (define args (current-command-line-arguments))
  (unless (= (vector-length args) 1)
    (eprintf "usage: racket -l- fhir/mcp-daemon <workspace-dir>\n")
    (exit 2))
  (serve! (path->directory-path (simplify-path (path->complete-path (vector-ref args 0))))))
