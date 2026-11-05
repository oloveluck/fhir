#lang racket/base

;;; jsonrpc.rkt — JSON-RPC 2.0 over the Language Server Protocol's base transport.
;;;
;;; A Message is a jsexpr (a hash) of one of three shapes:
;;;   request       {jsonrpc "2.0", id, method, params?}      id : number | string
;;;   notification  {jsonrpc "2.0", method, params?}
;;;   response      {jsonrpc "2.0", id, result} | {jsonrpc "2.0", id, error {code, message, data?}}
;;; On the wire each message is a header block (`Content-Length: n`, more headers, a blank line, CRLF
;;; separated) followed by n bytes of UTF-8 JSON.
;;;
;;; This module is the transport and the message constructors, with nothing about the protocol's
;;; methods: `read-message` / `write-message` frame, `request?` and friends classify, `response` and
;;; `error-response` build answers.

(require racket/contract racket/string json)

(provide
 (contract-out
  [read-message   (-> input-port? (or/c hash? eof-object?))]
  [write-message  (-> hash? output-port? void?)]
  [message->bytes (-> hash? bytes?)]
  [request?       (-> any/c boolean?)]
  [notification?  (-> any/c boolean?)]
  [response?      (-> any/c boolean?)]
  [message-method (-> hash? (or/c string? #f))]
  [message-id     (-> hash? any/c)]
  [message-params (-> hash? any/c)]
  [request        (->* (any/c string?) (any/c) hash?)]
  [notification   (->* (string?) (any/c) hash?)]
  [response       (-> any/c any/c hash?)]
  [error-response (->* (any/c exact-integer? string?) (any/c) hash?)])
 ;; the error codes the protocol reserves
 parse-error invalid-request method-not-found invalid-params internal-error)

(define parse-error -32700)
(define invalid-request -32600)
(define method-not-found -32601)
(define invalid-params -32602)
(define internal-error -32603)

;; ---- classification --------------------------------------------------------------------------
(define (message-method m) (let ([v (hash-ref m 'method #f)]) (and (string? v) v)))
(define (message-id m) (hash-ref m 'id #f))
(define (message-params m) (hash-ref m 'params #f))
(define (request? m) (and (hash? m) (message-method m) (hash-has-key? m 'id) #t))
(define (notification? m) (and (hash? m) (message-method m) (not (hash-has-key? m 'id)) #t))
(define (response? m) (and (hash? m) (not (message-method m)) (hash-has-key? m 'id) #t))

;; ---- constructors ----------------------------------------------------------------------------
(define (request id method [params #f])
  (if params (hasheq 'jsonrpc "2.0" 'id id 'method method 'params params)
      (hasheq 'jsonrpc "2.0" 'id id 'method method)))
(define (notification method [params #f])
  (if params (hasheq 'jsonrpc "2.0" 'method method 'params params)
      (hasheq 'jsonrpc "2.0" 'method method)))
(define (response id result) (hasheq 'jsonrpc "2.0" 'id id 'result result))
(define (error-response id code message [data #f])
  (hasheq 'jsonrpc "2.0" 'id id
          'error (if data (hasheq 'code code 'message message 'data data) (hasheq 'code code 'message message))))

;; ---- framing ---------------------------------------------------------------------------------
;; read-message : input-port -> Message | eof   the headers, then exactly Content-Length bytes
(define (read-message in)
  (define len (read-headers in))
  (cond
    [(not len) eof]
    [else
     (define body (read-bytes len in))
     (if (or (eof-object? body) (< (bytes-length body) len))
         eof
         (let ([j (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr body))])
           (if (hash? j) j (hasheq 'jsonrpc "2.0" 'invalid body))))]))

;; read-headers : input-port -> content-length | #f   up to and including the blank line
(define (read-headers in)
  (let loop ([len #f])
    (define line (read-line in 'any))
    (cond
      [(eof-object? line) #f]
      [(string=? (string-trim line) "") len]
      [else
       (define m (regexp-match #px"^Content-Length:\\s*(\\d+)\\s*$" line))
       (loop (if m (string->number (cadr m)) len))])))

;; message->bytes : Message -> bytes   the framed message
(define (message->bytes m)
  (define body (jsexpr->bytes m))
  (bytes-append (string->bytes/utf-8 (format "Content-Length: ~a\r\n\r\n" (bytes-length body))) body))

(define (write-message m out)
  (write-bytes (message->bytes m) out)
  (flush-output out))

(module+ test
  (require rackunit)
  ;; constructors and classification
  (check-true (request? (request 1 "initialize" (hasheq))))
  (check-true (notification? (notification "initialized")))
  (check-true (response? (response 1 (hasheq 'capabilities (hasheq)))))
  (check-false (request? (notification "exit")))
  (check-equal? (message-method (request 7 "shutdown")) "shutdown")
  (check-equal? (hash-ref (hash-ref (error-response 3 method-not-found "no such method") 'error) 'code) -32601)
  ;; framing round-trips, with the length in bytes (not characters)
  (define m (request "a" "textDocument/didOpen" (hasheq 'text "héllo")))
  (define framed (message->bytes m))
  (check-true (regexp-match? #rx#"^Content-Length: [0-9]+\r\n\r\n" framed))
  (check-equal? (read-message (open-input-bytes framed)) m)
  ;; several messages on one port, other headers tolerated
  (define two (bytes-append (message->bytes (notification "a")) #"Content-Type: application/vscode-jsonrpc; charset=utf-8\r\n" (message->bytes (notification "b"))))
  (define in (open-input-bytes two))
  (check-equal? (message-method (read-message in)) "a")
  (check-equal? (message-method (read-message in)) "b")
  (check-pred eof-object? (read-message in))
  ;; a truncated body is the end of the stream; a body that is not JSON is marked invalid
  (check-pred eof-object? (read-message (open-input-bytes #"Content-Length: 100\r\n\r\n{}")))
  (check-true (hash-has-key? (read-message (open-input-bytes #"Content-Length: 3\r\n\r\nnot")) 'invalid))
  ;; write-message frames onto a port
  (define o (open-output-bytes))
  (write-message (notification "exit") o)
  (check-equal? (read-message (open-input-bytes (get-output-bytes o))) (notification "exit")))
