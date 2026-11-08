#lang racket/base

;;; server.rkt — the Model Context Protocol server: dispatch and the stdio loop.
;;;
;;; MCP (https://modelcontextprotocol.io) is JSON-RPC 2.0; over stdio each message is one line of
;;; JSON. The methods served: initialize, notifications/initialized, ping, tools/list, tools/call,
;;; resources/list, resources/templates/list, resources/read, prompts/list, prompts/get (resources.rkt).
;;; A State is (state tools initialized?); dispatch is pure and the loop does the I/O, as the
;;; language server's. A tool call's result is {content [{type "text", text}], isError}.

(require racket/contract racket/string racket/list json
         (only-in fhir/lsp/jsonrpc request? notification? message-method message-id message-params
                  response error-response method-not-found invalid-params parse-error)
         "tools.rkt" "resources.rkt")

(provide
 (struct-out state)
 (contract-out
  [dispatch        (-> hash? state? (values (or/c hash? #f) state?))]
  [serve           (->* ((listof tool?)) (input-port? output-port?) void?)]
  [read-line-message (-> input-port? (or/c hash? eof-object?))]
  [write-line-message (-> hash? output-port? void?)]
  [protocol-version string?]))

(struct state (tools initialized?) #:transparent)

;; what the model is told at initialize: how to work here
(define current-server-instructions
  (make-parameter
   (string-append
    "A FHIR workspace: write programs in the FHIR languages and FHIR JSON, and run them against FHIR data. "
    "The files: .fsh (FHIR Shorthand: profiles, value sets, examples), .cql (patient logic), .fhirpath, .vcl (value sets), "
    ".map/.fml (mappings), .view.json (SQL on FHIR views), .json (resources); what one file defines, the others see by canonical. "
    "The loop: write (answers the file's problems at their lines) -> fix -> run (a summary and result://rN) -> explain one subject when an answer surprises you. "
    "query asks once without a file; describe reads any reference (results paged, types and elements, operations, Type/id, canonicals); "
    "apply runs a FHIR operation; stage then commit writes validated, diffed changes to the data. "
    "Read learn://workspace first, and learn://<language> (fsh, cql, fhirpath, vcl, fml, sql-on-fhir, search) before writing a language: each has a cheat sheet and links to its official specification.")))
(provide current-server-instructions)
(define protocol-version "2024-11-05")

;; ---- the handlers, a table: method -> (params state -> (values result state)) ----------------
(define handlers
  (hash "initialize"
        (lambda (params st)
          (values (hasheq 'protocolVersion protocol-version
                          'capabilities (hasheq 'tools (hasheq 'listChanged #f)
                                                'resources (hasheq 'listChanged #f 'subscribe #f)
                                                'prompts (hasheq 'listChanged #f))
                          'serverInfo (hasheq 'name "fhir-mcp" 'version "0.1")
                          'instructions (current-server-instructions))
                  st))
        "ping" (lambda (params st) (values (hasheq) st))
        "resources/list" (lambda (params st) (values (hasheq 'resources (resources)) st))
        "resources/templates/list" (lambda (params st) (values (hasheq 'resourceTemplates (resource-templates)) st))
        "resources/read"
        (lambda (params st)
          (define uri (hash-ref params 'uri #f))
          (define c (and (string? uri) (read-resource uri)))
          (unless c (raise (exn:fail:tool (format "no resource ~a" uri) (current-continuation-marks))))
          (values (hasheq 'contents (list c)) st))
        "prompts/list" (lambda (params st) (values (hasheq 'prompts (prompts)) st))
        "prompts/get"
        (lambda (params st)
          (define name (hash-ref params 'name #f))
          (define p (and (string? name) (get-prompt name (let ([a (hash-ref params 'arguments #f)]) (if (hash? a) a (hasheq))))))
          (unless p (raise (exn:fail:tool (format "no prompt ~a" name) (current-continuation-marks))))
          (values p st))
        "tools/list"
        (lambda (params st) (values (hasheq 'tools (map tool->jsexpr (state-tools st))) st))
        "tools/call"
        (lambda (params st)
          (define name (hash-ref params 'name #f))
          (define args (let ([a (hash-ref params 'arguments #f)]) (if (hash? a) a (hasheq))))
          (define t (findf (lambda (x) (equal? (tool-name x) name)) (state-tools st)))
          (cond
            [(not t) (raise (exn:fail:tool (format "unknown tool ~a" name) (current-continuation-marks)))]
            [else (define-values (text err?) (call-tool t args))
                  (values (hasheq 'content (list (hasheq 'type "text" 'text text)) 'isError err?) st)]))))
(struct exn:fail:tool exn:fail ())

;; dispatch : Message State -> (values response|#f State)
(define (dispatch m st)
  (cond
    [(hash-has-key? m 'invalid) (values (error-response 'null parse-error "the message was not JSON") st)]
    [(request? m)
     (define h (hash-ref handlers (message-method m) #f))
     (cond
       [(not h) (values (error-response (message-id m) method-not-found (format "unknown method ~a" (message-method m))) st)]
       [else
        (with-handlers ([exn:fail:tool? (lambda (e) (values (error-response (message-id m) invalid-params (exn-message e)) st))])
          (define-values (result st*) (h (let ([p (message-params m)]) (if (hash? p) p (hasheq))) st))
          (values (response (message-id m) result) st*))])]
    [(notification? m)
     (values #f (if (equal? (message-method m) "notifications/initialized") (struct-copy state st [initialized? #t]) st))]
    [else (values #f st)]))

;; ---- stdio transport: one JSON object per line ------------------------------------------------
(define (read-line-message in)
  (define line (read-line in 'any))
  (cond [(eof-object? line) eof]
        [(string=? (string-trim line) "") (read-line-message in)]
        [else (define j (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr line)))
              (if (hash? j) j (hasheq 'jsonrpc "2.0" 'invalid line))]))
(define (write-line-message m out)
  (write-json m out) (newline out) (flush-output out))

;; serve : tools [in out] -> void   until the stream ends
(define (serve tools [in (current-input-port)] [out (current-output-port)])
  (let loop ([st (state tools #f)])
    (define m (read-line-message in))
    (unless (eof-object? m)
      (define-values (resp st*) (dispatch m st))
      (when resp (write-line-message resp out))
      (loop st*))))

(module+ test
  (require rackunit (only-in fhir/lsp/jsonrpc request notification))
  (define echo (tool "echo" "says it back" (hasheq 'type "object" 'properties (hasheq 'text (hasheq 'type "string")))
                     (lambda (args) (values (hash-ref args 'text "") #f))))
  (define st0 (state (list echo) #f))
  (define-values (r1 s1) (dispatch (request 1 "initialize" (hasheq 'protocolVersion protocol-version)) st0))
  (check-equal? (hash-ref (hash-ref r1 'result) 'protocolVersion) protocol-version)
  (define-values (r2 s2) (dispatch (notification "notifications/initialized") s1))
  (check-false r2) (check-true (state-initialized? s2))
  (define-values (r3 s3) (dispatch (request 2 "tools/list") s2))
  (check-equal? (map (lambda (t) (hash-ref t 'name)) (hash-ref (hash-ref r3 'result) 'tools)) '("echo"))
  (define-values (r4 s4) (dispatch (request 3 "tools/call" (hasheq 'name "echo" 'arguments (hasheq 'text "hi"))) s3))
  (check-equal? (hash-ref (car (hash-ref (hash-ref r4 'result) 'content)) 'text) "hi")
  (check-false (hash-ref (hash-ref r4 'result) 'isError))
  (define-values (r5 s5) (dispatch (request 4 "tools/call" (hasheq 'name "nope")) s3))
  (check-equal? (hash-ref (hash-ref r5 'error) 'code) invalid-params)
  (define-values (r6 s6) (dispatch (request 5 "nothing/here") s3))
  (check-equal? (hash-ref (hash-ref r6 'error) 'code) method-not-found)
  ;; resources and prompts
  (define-values (rr sr) (dispatch (request 6 "resources/list") s3))
  (check-true (list? (hash-ref (hash-ref rr 'result) 'resources)))
  (define-values (rp sp) (dispatch (request 7 "prompts/get" (hasheq 'name "fsh-instance" 'arguments (hasheq 'profile "/p"))) s3))
  (check-true (regexp-match? #rx"/p" (hash-ref (hash-ref (car (hash-ref (hash-ref rp 'result) 'messages)) 'content) 'text)))
  (define-values (rx sx) (dispatch (request 8 "resources/read" (hasheq 'uri "fhir://nothing")) s3))
  (check-equal? (hash-ref (hash-ref rx 'error) 'code) invalid-params)
  ;; over the wire: one line per message
  (define in (open-input-string (string-append (jsexpr->string (request 1 "ping")) "\n\n" (jsexpr->string (request 2 "tools/list")) "\n")))
  (define out (open-output-string))
  (serve (list echo) in out)
  (define lines (filter (lambda (l) (not (string=? l ""))) (string-split (get-output-string out) "\n")))
  (check-equal? (length lines) 2)
  (check-equal? (hash-ref (string->jsexpr (car lines)) 'id) 1)
  (define-values (r7 s7) (dispatch (hasheq 'jsonrpc "2.0" 'invalid "x") st0))
  (check-equal? (hash-ref (hash-ref r7 'error) 'code) parse-error))
