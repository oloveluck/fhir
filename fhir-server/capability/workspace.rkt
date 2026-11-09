#lang racket/base

;;; workspace.rkt — capability apps as a workspace language (fhir/lang/workspace): a file
;;; `<name>.capability.rkt` in `#lang fhir/capability` declares a FHIR server — its resources,
;;; interactions, search parameters and operations (handlers in Racket, or existing operations by
;;; reference: $validate, $expand, StructureMap/$transform, $evaluate-measure, …).
;;;
;;; The app runs in a process of its own: the capability language types resources with FHIR R6,
;;; and a workspace process holds its own FHIR version's types (two towers in one process would
;;; register over each other).
;;;   artifacts : each file compiled there (`racket <file>` prints the CapabilityStatement its
;;;               declarations derive); a compile error is a problem at its line
;;;   run       : the app served — `fhir-server serve <file> <port> --store <the workspace's store>` —
;;;               on a free port, until the workspace's process ends or the file runs again; its
;;;               resources live in the workspace's SQLite store (data: fhir.db), so what the server
;;;               writes, the workspace's tools read. The answer: the base url and what it serves
;;;   explain   : the CapabilityStatement's entry for a type (`Patient`) or an operation (`$bmi`)
;;; It also provides `guide` (capability/guide.md, fhir-mcp's learn://capability).

(require racket/contract racket/list racket/string racket/port racket/file racket/path racket/runtime-path json
         racket/tcp
         (only-in fhir/lang/workspace ws-support run-result workspace-root workspace-config ws-config-data ws-config-canonical)
         (only-in fhir/diagnostic diagnostic loc exn:fail:diagnostic))

(provide (contract-out [workspace-support any/c] [guide string?] [running-servers (-> (listof (cons/c path? string?)))]))

(define-runtime-path guide-file "guide.md")
(define guide (file->string guide-file))

;; ---- the racket that runs an app ------------------------------------------------------------
;; racket-command : -> path | #f   the Racket that runs a capability module (the tools' own, else PATH's)
(define (racket-command)
  (define exe (find-system-path 'exec-file))
  (define full (if (absolute-path? exe) exe (find-executable-path exe)))
  (cond [(and full (regexp-match? #rx"^racket" (path->string (file-name-from-path full)))) full]
        [else (find-executable-path "racket")]))

;; run-racket : args timeout -> (values exit-code stdout stderr)
(define (run-racket args [timeout 300])
  (define racket (or (racket-command) (error 'capability "a capability app runs in Racket, which is not installed here")))
  (define-values (p out in err) (apply subprocess #f #f #f racket args))
  (close-output-port in)
  (define out-s (box "")) (define err-s (box ""))
  (define t1 (thread (lambda () (set-box! out-s (port->string out)))))
  (define t2 (thread (lambda () (set-box! err-s (port->string err)))))
  (unless (sync/timeout timeout p) (subprocess-kill p #t))
  (thread-wait t1) (thread-wait t2)
  (close-input-port out) (close-input-port err)
  (values (subprocess-status p) (unbox out-s) (unbox err-s)))

;; compile-error : file stderr -> diagnostic   Racket's `path:line:col: message`, else the file
(define (compile-error file text)
  (define first-line (let ([ls (filter (lambda (l) (not (string=? (string-trim l) ""))) (string-split text "\n"))]) (if (pair? ls) (car ls) text)))
  (define m (regexp-match #px"^(.*?):([0-9]+):([0-9]+): (.*)$" first-line))
  (if m
      (diagnostic 'capability 'compile 'error (cadddr (cdr m)) (loc (path->string file) (string->number (caddr m)) (add1 (string->number (cadddr m))) #f #f))
      (diagnostic 'capability 'compile 'error (string-trim first-line) (loc (path->string file) #f #f #f #f))))

;; ---- artifacts: the CapabilityStatement each app derives ------------------------------------
(define (stem p) (regexp-replace #rx"[.]capability[.]rkt$" (path->string (file-name-from-path p)) ""))
(define compiled (make-hash))               ; (cons path text) -> (cons CapabilityStatement|#f diagnostics)
(define (capability-of ws path text)
  (hash-ref! compiled (cons path text)
             (lambda ()
               (define-values (code out err) (run-racket (list (path->string path))))
               (cond
                 [(and (eqv? code 0) (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr out)))
                  => (lambda (cs)
                       (define id (regexp-replace* #rx"[^A-Za-z0-9.-]" (stem path) "-"))
                       (cons (hash-set* cs 'id id 'name (string-titlecase id)
                                        'url (hash-ref cs 'url (string-append (ws-config-canonical (workspace-config ws)) "/CapabilityStatement/" id)))
                             '()))]
                 [else (cons #f (list (compile-error path err)))]))))

(define (artifacts ws files)
  (for/fold ([rs '()] [ds '()] #:result (values (reverse rs) ds)) ([f (in-list files)])
    (define r (capability-of ws (car f) (cdr f)))
    (values (if (car r) (cons (car r) rs) rs) (append ds (cdr r)))))

;; ---- run: the app served ---------------------------------------------------------------------
(define servers (make-hash))                ; path -> (list subprocess port)
(define (running-servers) (for/list ([(p s) (in-hash servers)]) (cons p (format "http://localhost:~a" (cadr s)))))
(define (stop! path)
  (define s (hash-ref servers path #f))
  (when s (subprocess-kill (car s) #t) (hash-remove! servers path)))
;; every server ends with the process that started it
(void (plumber-add-flush! (current-plumber) (lambda (_) (for ([p (in-list (hash-keys servers))]) (stop! p)))))

(define (free-port)
  (define l (tcp-listen 0 4 #t "127.0.0.1"))
  (define-values (_a port _b _c) (tcp-addresses l #t))
  (tcp-close l)
  port)

;; store-of : workspace -> path | #f   the workspace's SQLite store, when its data is one
(define (store-of ws)
  (define d (ws-config-data (workspace-config ws)))
  (and (string? d) (regexp-match? #rx"[.](db|sqlite|sqlite3)$" d) (not (regexp-match? #rx"^https?://" d))
       (simplify-path (path->complete-path d (workspace-root ws)))))

;; serve! : path store -> port   the app started on a free port; waits until it answers
(define (serve! path store)
  (stop! path)
  (define racket (or (racket-command) (error 'capability "a capability app runs in Racket, which is not installed here")))
  (define port (free-port))
  (define log (make-temporary-file "capability-~a.log"))
  (define-values (p out in err)
    (let ([o (open-output-file log #:exists 'truncate)])
      (begin0 (apply subprocess o #f o racket "-l-" "raco" "fhir-server" "serve" (path->string path) (number->string port)
                     (if store (list "--store" (path->string store)) '()))
              (close-output-port o))))
  (close-output-port in)
  (let wait ([n 0])
    (cond
      [(not (eq? (subprocess-status p) 'running))
       (error 'capability (format "the server stopped: ~a" (string-trim (file->string log))))]
      [(with-handlers ([exn:fail? (lambda (_) #f)])
         (define-values (i o) (tcp-connect "127.0.0.1" port))
         (close-input-port i) (close-output-port o) #t)
       (void)]
      [(> n 1200) (subprocess-kill p #t) (error 'capability "the server did not start within two minutes")]
      [else (sleep 0.1) (wait (add1 n))]))
  (hash-set! servers path (list p port))
  port)

(define (run ws path text opts)
  (unless path (error 'capability "a capability app is a file: write <name>.capability.rkt, then run it"))
  (define cs (car (or (let ([r (capability-of ws path text)]) (and (car r) r))
                      (raise (exn:fail:diagnostic "the app does not compile" (current-continuation-marks)
                                                  (car (cdr (capability-of ws path text))))))))
  (define store (store-of ws))
  (define port (serve! path store))
  (define rest0 (let ([r (hash-ref cs 'rest '())]) (if (pair? r) (car r) (hasheq))))
  (define rows
    (append
     (for/list ([res (in-list (hash-ref rest0 'resource '()))])
       (hasheq 'type (hash-ref res 'type "")
               'interactions (map (lambda (i) (hash-ref i 'code "")) (hash-ref res 'interaction '()))
               'search (map (lambda (s) (hash-ref s 'name "")) (hash-ref res 'searchParam '()))
               'operations (map (lambda (o) (hash-ref o 'name "")) (hash-ref res 'operation '()))))
     (for/list ([o (in-list (hash-ref rest0 'operation '()))])
       (hasheq 'type "(system)" 'interactions '() 'search '() 'operations (list (hash-ref o 'name ""))))))
  (run-result "server" '("type" "interactions" "search" "operations") rows
              (hasheq 'url (format "http://localhost:~a" port)
                      'store (if store (path->string store) "none: the app's own repositories")
                      'try (format "curl http://localhost:~a/metadata" port))))

(define (explain ws path text subject opts)
  (define cs (car (capability-of ws path text)))
  (unless cs (error 'capability "the app does not compile: check its problems"))
  (define rest0 (let ([r (hash-ref cs 'rest '())]) (if (pair? r) (car r) (hasheq))))
  (or (for/first ([res (in-list (hash-ref rest0 'resource '()))] #:when (equal? (hash-ref res 'type #f) subject)) res)
      (for*/first ([o (in-list (append (hash-ref rest0 'operation '())
                                       (append-map (lambda (r) (hash-ref r 'operation '())) (hash-ref rest0 'resource '()))))]
                   #:when (equal? (hash-ref o 'name #f) subject))
        o)
      (error 'capability (format "~a declares no ~a (it serves: ~a)" (stem path) subject
                                 (string-join (map (lambda (r) (hash-ref r 'type "")) (hash-ref rest0 'resource '())) ", ")))))

(define workspace-support (ws-support "capability" artifacts run explain))
