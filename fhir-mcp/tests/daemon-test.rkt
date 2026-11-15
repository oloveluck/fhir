#lang racket/base

;;; daemon-test.rkt — a shell call answered by the warm process is the call answered by its own process.
;;;
;;; Two workspaces made alike get the same calls: one through `raco fhir-mcp` with the warm process
;;; off (FHIR_MCP_DAEMON=0: each call its own process), one through `answer-request` (what the warm
;;; process runs for a call). The answers are the same text, the same standard error, the same exit
;;; status, call after call — results numbered, stages kept and committed, an error, a usage error,
;;; a file given relative to the caller's directory, standard input. Then the warm process itself:
;;; started by a first call, answering the next one, stopped.

(require rackunit racket/file racket/port racket/string racket/system json racket/unix-socket
         (only-in fhir/mcp-daemon answer-request)
         (only-in fhir/mcp-main socket-path workspace-dir))

(define raco (find-executable-path "raco"))
(define (init! dir)
  (parameterize ([current-output-port (open-output-nowhere)])
    (system* raco "fhir-mcp" "init" (path->string dir))))

;; local : dir argv [stdin] -> (list stdout stderr exit)   the call in a process of its own
(define (local dir argv [stdin ""])
  (define out (open-output-string))
  (define err (open-output-string))
  (define code
    (parameterize ([current-directory dir] [current-output-port out] [current-error-port err]
                   [current-input-port (open-input-string stdin)]
                   [current-environment-variables (environment-variables-copy (current-environment-variables))])
      (putenv "FHIR_MCP_DAEMON" "0")
      (apply system*/exit-code raco "fhir-mcp" argv)))
  (list (get-output-string out) (get-output-string err) code))
;; warm : dir argv [stdin] -> (list stdout stderr exit)   the call as the warm process answers it
(define (warm dir argv [stdin ""])
  (define a (answer-request (hasheq 'argv argv 'cwd (path->string dir) 'stdin stdin
                                    'env (hasheq 'PATH (or (getenv "PATH") "")))))
  (list (hash-ref a 'stdout) (hash-ref a 'stderr) (hash-ref a 'exit)))

(define a (make-temporary-directory "warm-a-~a"))
(define b (make-temporary-directory "warm-b-~a"))
(void (init! a) (init! b))
(for ([d (list a b)])
  (call-with-output-file (build-path d "ann.fsh")
    (lambda (o) (void (write-string "Instance: ann\nInstanceOf: Patient\n* gender = #female\n* birthDate = \"1960-01-01\"\n" o)))))
;; same : argv [stdin] -> void   both ways, the same answer (the workspace's own path aside)
(define (same argv [stdin ""])
  ;; what differs between two workspaces however a call is run: their paths, the ids and times a commit makes
  (define (normal s d)
    (regexp-replace* #px"\\d{4}-\\d\\d-\\d\\dT\\d\\d:\\d\\d:\\d\\d(?:[.]\\d+)?Z"
                     (regexp-replace* #px"Provenance/[0-9a-f]{32}" (string-replace s (path->string d) "WS") "Provenance/ID")
                     "TIME"))
  (define (plain r d) (list (normal (car r) d) (normal (cadr r) d) (caddr r)))
  (define l (plain (local a argv stdin) a))
  (define w (plain (warm b argv stdin) b))
  (check-equal? w l (format "~s" argv))
  (caddr l))

(check-equal? (same '("call" "check")) 0)
(check-equal? (same '("call" "stage" "fsh=@ann.fsh" "reason=intake")) 0)           ; a file relative to the caller's directory
(check-equal? (same '("call" "describe" "ref=stages")) 0)
(check-equal? (same '("call" "commit" "stage=latest" "reason=intake")) 0)
(check-equal? (same '("call" "query" "language=fhirpath" "text=Patient.gender")) 0)
(check-equal? (same '("call" "query" "language=sql" "text=SELECT count(*) AS n FROM Patient")) 0)
(check-equal? (same '("call" "describe" "ref=result://latest")) 0)
(check-equal? (same '("call" "query" "language=nope" "text=x")) 1)              ; an error: exit 1
(check-equal? (same '("call" "nosuchtool")) 2)                                   ; a usage error: exit 2
(check-equal? (same '("call" "query" "-") "{\"language\": \"fhirpath\", \"text\": \"Patient.birthDate\"}") 0)   ; standard input
(check-equal? (same '("batch" "-") "describe ref=Patient/ann\nquery language=sql text=\"SELECT 1 AS one FROM Patient\"\n") 0)
(delete-directory/files a)
(delete-directory/files b)

;; ---- the warm process itself -----------------------------------------------------------------------
(define c (make-temporary-directory "warm-c-~a"))
(void (init! c))
(define sock (socket-path (workspace-dir (list "--workspace" (path->string c)))))
;; through raco, with the warm process on: the first call runs itself and starts it
(define (call-c . argv)
  (define out (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port (open-output-nowhere)]
                              [current-environment-variables (environment-variables-copy (current-environment-variables))])
                 (environment-variables-set! (current-environment-variables) #"FHIR_MCP_DAEMON" #f)
                 (apply system*/exit-code raco "fhir-mcp" (append argv (list "--workspace" (path->string c))))))
  (cons code (get-output-string out)))
(define first-answer (call-c "call" "describe" "ref=data"))
(check-equal? (car first-answer) 0)
(let wait ([n 0]) (unless (or (file-exists? sock) (> n 120)) (sleep 0.5) (wait (add1 n))))
(check-true (file-exists? sock) "the first call started the warm process")
(sleep 2)                                                                        ; it warms up before it listens
(define second-answer (call-c "call" "describe" "ref=data"))
(check-equal? second-answer first-answer "the warm process answers as the call's own process did")
;; stopped on request; the socket is gone
(let-values ([(i o) (unix-socket-connect sock)])
  (write-json (hasheq 'stop #t) o) (close-output-port o)
  (check-equal? (read-json i) (hasheq 'stopped #t))
  (close-input-port i))
(let wait ([n 0]) (when (and (file-exists? sock) (< n 20)) (sleep 0.25) (wait (add1 n))))
(check-false (file-exists? sock))
(delete-directory/files c)
