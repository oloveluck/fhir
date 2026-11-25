#lang racket/base

;;; server.rkt — the function table (functions.rkt) answered over JSON lines.
;;;
;;; The protocol is JSON-RPC 2.0, one message to a line (as MCP's stdio transport frames it):
;;;   a Request  : {"jsonrpc": "2.0", "id": 1, "method": "fhirpath", "params": {"expression": …, "resource": …}}
;;;   a Response : {"jsonrpc": "2.0", "id": 1, "result": …}
;;;              | {"jsonrpc": "2.0", "id": 1, "error": {"code": c, "message": m, "data": {…}}}
;;; `method` is a function's name and `params` its arguments by name; `functions` (no parameters)
;;; answers the table itself. A request without an id is a notification and gets no answer.
;;;
;;; An ErrorCode is one of:
;;;   -32700  the line is not JSON
;;;   -32600  the message is not a request
;;;   -32601  no function of that name (`data.functions` lists them)
;;;   -32602  the arguments are not the function's (`data.problems`: one sentence each)
;;;   -32000  the function failed: `message` says why; `data.diagnostics` when the failure has a
;;;           place in a source text, `data.outcome` when it is an operation's OperationOutcome
;;; A problem IN what a caller gave to compile or translate is not an error: those functions answer
;;; their diagnostics. An error is a call that could not be answered.

(require racket/contract racket/list racket/string json
         "session.rkt" "functions.rkt"
         (only-in fhir/diagnostic exn:fail:diagnostic? exn:fail:diagnostic-diagnostic diagnostic->jsexpr)
         (only-in fhir/operation exn:fail:operation? exn:fail:operation-outcome))

(provide
 (contract-out
  ;; answer : session request -> response | #f   one request answered; never raises
  [answer (-> session? any/c (or/c hash? #f))]
  ;; answer-line : session string -> string | #f   the same, from and to a line of text
  [answer-line (-> session? string? (or/c string? #f))]
  ;; serve : session in out -> void   lines answered until the input ends
  [serve (-> session? input-port? output-port? void?)]))

(define (response id result) (hasheq 'jsonrpc "2.0" 'id id 'result result))
(define (failure id code message [data #f])
  (hasheq 'jsonrpc "2.0" 'id id
          'error (let ([e (hasheq 'code code 'message message)]) (if data (hash-set e 'data data) e))))

;; plain-source : jsexpr -> jsexpr   a diagnostic whose source is a path, as text
(define (plain-source js)
  (define src (hash-ref js 'source #f))
  (cond [(path? src) (hash-set js 'source (path->string src))]
        [(or (not src) (string? src)) js]
        [else (hash-set js 'source (format "~a" src))]))

;; failure-of : id exn -> response   why a function could not answer
(define (failure-of id e)
  (cond
    [(exn:fail:diagnostic? e)
     (failure id -32000 (exn-message e)
              (hasheq 'diagnostics (list (plain-source (diagnostic->jsexpr (exn:fail:diagnostic-diagnostic e))))))]
    [(exn:fail:problems? e) (failure id -32000 (exn-message e) (hasheq 'diagnostics (exn:fail:problems-diagnostics e)))]
    [(exn:fail:operation? e)
     (failure id -32000 (exn-message e) (hasheq 'outcome (exn:fail:operation-outcome e)))]
    [else (failure id -32000 (exn-message e))]))

(define (answer s request)
  (define id (and (hash? request) (hash-ref request 'id #f)))
  (define method (and (hash? request) (hash-ref request 'method #f)))
  (define params (if (hash? request) (hash-ref request 'params (hasheq)) (hasheq)))
  (define reply
    (cond
      [(not (and (hash? request) (string? method))) (failure (or id 'null) -32600 "a request is an object with a `method`")]
      [(not (hash? params)) (failure id -32602 "`params` is an object of arguments by name")]
      [(equal? method "functions") (response id (functions->jsexpr))]
      [(function-named method)
       => (lambda (f)
            (define problems (argument-problems f params))
            (if (pair? problems)
                (failure id -32602 (string-join problems "; ") (hasheq 'problems problems))
                (with-handlers ([exn:fail? (lambda (e) (failure-of id e))])
                  ;; what a library prints is not part of the protocol: it goes to the error port
                  (response id (parameterize ([current-output-port (current-error-port)]) ((fn-run f) s params))))))]
      [else (failure id -32601 (format "no function ~a (the functions: ~a)" method (string-join (map fn-name functions) ", "))
                     (hasheq 'functions (map fn-name functions)))]))
  ;; a notification gets no answer
  (and (or id (hash-has-key? (hash-ref reply 'error (hasheq)) 'code)) (if id reply (hash-set reply 'id 'null))))

(define (answer-line s line)
  (define request (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr line)))
  (define reply
    (if (or (not request) (eof-object? request))
        (failure 'null -32700 "the line is not JSON")
        (answer s request)))
  (and reply
       (with-handlers ([exn:fail? (lambda (e) (jsexpr->string (failure (hash-ref reply 'id 'null) -32000
                                                                       (format "the answer is not JSON: ~a" (exn-message e)))))])
         (jsexpr->string reply))))

;; serve stops when the input ends, and quietly when nobody reads its answers any more (a client
;; that closed the pipe: the write fails, and there is no one to tell)
(define (serve s in out)
  (let loop ()
    (define line (read-line in 'any))
    (unless (eof-object? line)
      (define heard?
        (or (regexp-match? #px"^\\s*$" line)
            (let ([reply (answer-line s line)])
              (or (not reply)
                  (with-handlers ([exn:fail? (lambda (_) #f)])
                    (write-string reply out) (newline out) (flush-output out) #t)))))
      (when heard? (loop)))))

(module+ test
  (require rackunit)
  (define s (open-session))
  (define (ask text) (string->jsexpr (answer-line s text)))
  (define (code js) (hash-ref (hash-ref js 'error) 'code))
  ;; not JSON, not a request, no such function, arguments that are not the function's
  (check-equal? (code (ask "{")) -32700)
  (check-equal? (code (ask "[1]")) -32600)
  (check-equal? (code (ask "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"nope\"}")) -32601)
  (check-true (pair? (hash-ref (hash-ref (hash-ref (ask "{\"id\":1,\"method\":\"nope\"}") 'error) 'data) 'functions)))
  (define bad (ask "{\"id\":2,\"method\":\"fhirpath\",\"params\":{\"expresion\":\"name\"}}"))
  (check-equal? (code bad) -32602)
  (check-equal? (hash-ref bad 'id) 2)
  (check-true (>= (length (hash-ref (hash-ref (hash-ref bad 'error) 'data) 'problems)) 2))
  ;; the table itself, and a function that needs no language
  (check-equal? (hash-ref (hash-ref (ask "{\"id\":3,\"method\":\"functions\"}") 'result) 'protocol) protocol-version)
  (check-equal? (hash-ref (hash-ref (ask "{\"id\":4,\"method\":\"version\"}") 'result) 'fhirVersion) "4.0.1")
  ;; a notification is not answered; a blank line is nothing
  (check-false (answer-line s "{\"method\":\"version\"}"))
  (define out (open-output-string))
  (serve s (open-input-string "\n{\"id\":5,\"method\":\"version\"}\n\n{\"id\":6,\"method\":\"nope\"}\n") out)
  (check-equal? (map (lambda (l) (hash-ref (string->jsexpr l) 'id)) (string-split (get-output-string out) "\n")) '(5 6))
  (close-session! s))
