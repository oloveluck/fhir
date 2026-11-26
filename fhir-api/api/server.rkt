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

(require racket/contract racket/list racket/string racket/port json
         "session.rkt" "functions.rkt"
         (only-in fhir/serialize/fast-json fast-string->jsexpr fast-bytes->jsexpr fast-jsexpr->string)
         (only-in fhir/diagnostic exn:fail:diagnostic? exn:fail:diagnostic-diagnostic diagnostic->jsexpr)
         (only-in fhir/operation exn:fail:operation? exn:fail:operation-outcome))

(provide
 (contract-out
  ;; answer : session request -> response | #f   one request answered; never raises
  [answer (-> session? any/c (or/c hash? #f))]
  ;; answer-line : session string -> string | #f   the same, from and to a line of text
  [answer-line (-> session? string? (or/c string? #f))]
  ;; serve : session in out -> void   lines answered until the input ends
  [serve (->* (session? input-port? output-port?) (#:warm? boolean?) void?)]))

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

;; reply-text : session (-> jsexpr) -> string | #f   a request read by `parsed` and answered, as the
;; line to write back. A request may carry thousands of resources: it is read by the scanner the
;; store reads resources with (the same values as racket/json's, which reads whatever the scanner
;; does not take).
(define (reply-text s parsed)
  (define request (with-handlers ([exn:fail? (lambda (_) #f)]) (parsed)))
  (define reply
    (if (or (not request) (eof-object? request))
        (failure 'null -32700 "the line is not JSON")
        (answer s request)))
  (and reply
       (with-handlers ([exn:fail? (lambda (e) (fast-jsexpr->string (failure (hash-ref reply 'id 'null) -32000
                                                                            (format "the answer is not JSON: ~a" (exn-message e)))))])
         (fast-jsexpr->string reply))))

(define (answer-line s line) (reply-text s (lambda () (fast-string->jsexpr line))))

;; ---- lines ---------------------------------------------------------------------------------------
;; A LineReader is (line-reader in buffer pending): the port, a buffer to read into, and the bytes
;; read past the last line handed out. Racket's `read-line` takes a character at a time through
;; the port's decoder: a request of 700 KB (5,000 resources) took 30 ms to READ. This takes
;; whatever the port has, up to the buffer, and looks for the line's end in it: 5 ms.
(struct line-reader (in buffer [pending #:mutable]))
(define (make-line-reader in) (line-reader in (make-bytes (* 256 1024)) #""))

;; newline-in : bytes -> natural | #f   where the first line feed is
(define (newline-in b)
  (for/first ([i (in-range (bytes-length b))] #:when (eq? (bytes-ref b i) 10)) i))

;; line-waiting? : LineReader -> boolean   is a whole line read already (so nothing need be waited for)
(define (line-waiting? r) (and (newline-in (line-reader-pending r)) #t))

;; next-line : LineReader -> bytes | eof   the next line, without its line feed; what the input
;; ends with, when that is not a line feed, is a last line
(define (next-line r)
  (define in (line-reader-in r))
  (define buffer (line-reader-buffer r))
  (let loop ([chunks (list (line-reader-pending r))])
    (define last (car chunks))
    (define at (newline-in last))
    (cond
      [at (set-line-reader-pending! r (subbytes last (add1 at)))
          (apply bytes-append (reverse (cons (subbytes last 0 at) (cdr chunks))))]
      [else
       (define n (read-bytes-avail! buffer in))
       (cond [(eof-object? n)
              (set-line-reader-pending! r #"")
              (define rest (apply bytes-append (reverse chunks)))
              (if (zero? (bytes-length rest)) eof rest)]
             [else (loop (cons (subbytes buffer 0 n) chunks))])])))

;; blank? : bytes -> boolean   nothing but JSON's whitespace
(define (blank? line)
  (for/and ([b (in-bytes line)]) (and (memv b '(32 9 13 10)) #t)))

;; serve stops when the input ends, and quietly when nobody reads its answers any more (a client
;; that closed the pipe: the write fails, and there is no one to tell).
;;
;; While nobody is asking, it WARMS (functions.rkt `warm-steps`): when no request has come for
;; `idle-seconds`, it takes the next step, then listens again. A request never waits behind more
;; than the one step in hand, and a caller that asks without pause is never made to wait at all —
;; its calls load what they need, as before. `warm?` #f (FHIR_API_WARM=0) leaves every load to
;; the call that needs it.
(define idle-seconds 0.15)
(define (serve s in out #:warm? [warm? (not (equal? (getenv "FHIR_API_WARM") "0"))])
  (define lines (make-line-reader in))
  (let loop ([steps (if warm? (warm-steps s) '())])
    (cond
      [(and (pair? steps) (not (line-waiting? lines)) (not (sync/timeout idle-seconds in)))
       ;; a step that fails warms nothing and says nothing: the call that needs it will say
       (with-handlers ([(lambda (_) #t) void])
         (parameterize ([current-output-port (open-output-nowhere)] [current-error-port (open-output-nowhere)])
           ((car steps))))
       (loop (cdr steps))]
      [else (serve-line s lines out (lambda () (loop steps)))])))

;; serve-line : session LineReader out (-> any) -> any   one line read and answered, then `next`
(define (serve-line s lines out next)
  (define line (next-line lines))
  (unless (eof-object? line)
    (define heard?
      (or (blank? line)
          (let ([reply (reply-text s (lambda () (fast-bytes->jsexpr line)))])
            (or (not reply)
                (with-handlers ([exn:fail? (lambda (_) #f)])
                  (write-string reply out) (newline out) (flush-output out) #t)))))
    (when heard? (next))))

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
  ;; lines, as the reader hands them out: whatever the port gives at a time, a line longer than the
  ;; buffer, a last line the input ends without a line feed, nothing
  (define (lines-of in)
    (define r (make-line-reader in))
    (let loop () (define l (next-line r)) (if (eof-object? l) '() (cons l (loop)))))
  (check-equal? (lines-of (open-input-bytes #"a\nbc\n\nd")) '(#"a" #"bc" #"" #"d"))
  (check-equal? (lines-of (open-input-bytes #"")) '())
  (check-equal? (lines-of (open-input-bytes #"a\r\n")) '(#"a\r"))
  (define long (make-bytes (* 700 1024) 120))
  (check-equal? (lines-of (open-input-bytes (bytes-append long #"\n" long #"y\nz\n")))
                (list long (bytes-append long #"y") #"z"))
  ;; a line that comes in pieces (a pipe gives what it has) is one line, and a line read ahead is
  ;; known to be waiting
  (let-values ([(in o) (make-pipe)])
    (define r (make-line-reader in))
    (write-bytes #"ab" o) (check-false (line-waiting? r))
    (define got (make-channel))
    (thread (lambda () (channel-put got (next-line r))))
    (sync (system-idle-evt))
    (write-bytes #"c\nd\ne" o) (close-output-port o)
    (check-equal? (channel-get got) #"abc")
    (check-true (line-waiting? r))
    (check-equal? (next-line r) #"d")
    (check-false (line-waiting? r))
    (check-equal? (next-line r) #"e")
    (check-true (eof-object? (next-line r))))
  (check-true (blank? #" \t\r")) (check-true (blank? #"")) (check-false (blank? #" x"))
  ;; a carriage return before the line feed is JSON's whitespace; bytes that are no UTF-8 are no JSON
  (define (served bytes) (let ([o (open-output-string)]) (serve s (open-input-bytes bytes) o #:warm? #f)
                           (map string->jsexpr (string-split (get-output-string o) "\n"))))
  (check-equal? (map (lambda (js) (hash-ref js 'id)) (served #"{\"id\":7,\"method\":\"version\"}\r\n \r\n{\"id\":8,\"method\":\"version\"}")) '(7 8))
  (check-equal? (map code (served #"{\"id\":9,\"method\":\"\377\"}\n")) '(-32700))
  ;; text beyond ASCII comes through whole
  (check-equal? (hash-ref (car (served (string->bytes/utf-8 "{\"id\":10,\"method\":\"fhirpath\",\"params\":{\"expression\":\"name.family\",\"resource\":{\"resourceType\":\"Patient\",\"name\":[{\"family\":\"Müller 李\"}]}}}\n"))) 'result)
                (hasheq 'values '("Müller 李")))
  (close-session! s))
