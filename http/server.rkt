#lang racket/base

;;; server.rkt — a minimal HTTP/1.1 server (racket/tcp) that serves a capability `app`.
;;;
;;; web-server-lib isn't in this (minimal) Racket, so this is a small from-scratch transport: parse the
;;; request line + headers + Content-Length body, hand (method, path, query, body) to http/router's pure
;;; `handle`, and write back the status + JSON. One request per connection (Connection: close), each
;;; connection served on its own thread. `serve-app` returns a shutdown thunk.

(require racket/tcp
         racket/string
         racket/port
         racket/contract
         (only-in json jsexpr->string)
         (only-in "../capability/runtime.rkt" app?)
         (only-in "router.rkt" handle/raw parse-query))

(provide
 (contract-out
  [serve-app (->* (app?) (#:port (integer-in 1 65535) #:host (or/c string? #f)) (-> void))]))

;; start serving `app` on `port`; returns a thunk that stops the server.
(define (serve-app app #:port [port 8080] #:host [host #f])
  (define listener (tcp-listen port 128 #t host))
  (define stopped? (box #f))
  (define (accept-loop)
    (define conn
      (with-handlers ([exn:fail? (lambda (_) #f)])
        (call-with-values (lambda () (tcp-accept listener)) list)))
    (when (and conn (not (unbox stopped?)))
      (thread (lambda () (serve-conn app (car conn) (cadr conn))))
      (accept-loop)))
  (define worker (thread accept-loop))
  (lambda ()
    (set-box! stopped? #t)
    (with-handlers ([exn:fail? void]) (tcp-close listener))
    (kill-thread worker)))

;; serve exactly one request on this connection, then close it
(define (serve-conn app in out)
  (with-handlers ([exn:fail? (lambda (e) (write-response out 500 (oo-json "exception" (exn-message e))))])
    (define reqline (read-line in 'any))
    (when (string? reqline)
      (define parts (string-split reqline))
      (cond
        [(< (length parts) 2) (write-response out 400 (oo-json "invalid" "malformed request line"))]
        [else
         (define method (car parts))
         (define target (cadr parts))
         (define headers (read-headers in))
         (define clen (content-length headers))
         (define body (if (> clen 0)
                          (bytes->string/utf-8 (or (read-bytes clen in) #"") #\?)
                          ""))
         (define-values (path query) (split-target target))
         (define-values (status bytes ctype) (handle/raw app method path (parse-query query) body))
         (write-raw-response out status bytes ctype)])))
  (flush-output out)
  (close-output-port out)
  (close-input-port in))

;; read header lines until the blank line -> (listof (cons lowercased-name value))
(define (read-headers in)
  (let loop ([acc '()])
    (define line (read-line in 'any))
    (cond
      [(or (eof-object? line) (equal? line "")) (reverse acc)]
      [else
       (define i (for/or ([c (in-string line)] [j (in-naturals)]) (and (char=? c #\:) j)))
       (loop (if i (cons (cons (string-downcase (string-trim (substring line 0 i)))
                               (string-trim (substring line (add1 i)))) acc)
                 acc))])))

(define (content-length headers)
  (define v (assoc "content-length" headers))
  (or (and v (string->number (cdr v))) 0))

(define (split-target target)
  (define i (for/or ([c (in-string target)] [j (in-naturals)]) (and (char=? c #\?) j)))
  (if i (values (substring target 0 i) (substring target (add1 i))) (values target "")))

;; ---- response ------------------------------------------------------------------------------
(define (write-response out status js)
  (write-raw-response out status
                      (string->bytes/utf-8 (if js (jsexpr->string js) ""))
                      "application/fhir+json; charset=utf-8"))

;; the general form: any body bytes with their own content type (raw Binary streams use this)
(define (write-raw-response out status bytes ctype)
  (fprintf out "HTTP/1.1 ~a ~a\r\n" status (reason status))
  (fprintf out "Content-Type: ~a\r\n" ctype)
  (fprintf out "Content-Length: ~a\r\n" (bytes-length bytes))
  (fprintf out "Connection: close\r\n\r\n")
  (write-bytes bytes out))

(define (oo-json code msg)
  (hasheq 'resourceType "OperationOutcome"
          'issue (list (hasheq 'severity "error" 'code code 'diagnostics msg))))

(define (reason status)
  (case status
    [(200) "OK"] [(201) "Created"] [(204) "No Content"] [(400) "Bad Request"]
    [(403) "Forbidden"] [(404) "Not Found"] [(500) "Internal Server Error"] [else "OK"]))
