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
         (only-in fhir/capability/runtime app?)
         (only-in "router.rkt" handle/raw parse-query))

(provide
 (contract-out
  ;; #:bearer token — require `Authorization: Bearer <token>` on every request except GET /metadata
  ;; (a static token: enough for test kits that take a manually supplied access token; NOT SMART)
  [serve-app (->* (app?) (#:port (integer-in 1 65535) #:host (or/c string? #f) #:bearer (or/c string? #f))
                  (-> void))]))

;; start serving `app` on `port`; returns a thunk that stops the server.
(define (serve-app app #:port [port 8080] #:host [host #f] #:bearer [bearer #f])
  (define listener (tcp-listen port 128 #t host))
  (define stopped? (box #f))
  (define (accept-loop)
    (define conn
      (with-handlers ([exn:fail? (lambda (_) #f)])
        (call-with-values (lambda () (tcp-accept listener)) list)))
    (when (and conn (not (unbox stopped?)))
      (thread (lambda () (serve-conn app (car conn) (cadr conn) bearer)))
      (accept-loop)))
  (define worker (thread accept-loop))
  (lambda ()
    (set-box! stopped? #t)
    (with-handlers ([exn:fail? void]) (tcp-close listener))
    (kill-thread worker)))

;; serve exactly one request on this connection, then close it
(define (serve-conn app in out [bearer #f])
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
         (cond
           [(and bearer (not (authorized? headers bearer)) (not (metadata-request? method path)))
            (write-response out 401 (oo-json "login" "a valid bearer token is required"))]
           [else
            (define-values (status bytes ctype) (handle/raw app method path (parse-query query) body))
            (write-raw-response out status bytes ctype)])])))
  (flush-output out)
  (close-output-port out)
  (close-input-port in))

;; authorized? : headers token -> boolean   `Authorization: Bearer <token>` (scheme case-insensitive)
(define (authorized? headers token)
  (define v (assoc "authorization" headers))
  (and v (let ([m (regexp-match #px"^(?i:bearer)\\s+(\\S+)\\s*$" (cdr v))]) (and m (equal? (cadr m) token)))))
;; the CapabilityStatement stays public (clients discover the server before authenticating)
(define (metadata-request? method path)
  (and (equal? method "GET") (regexp-match? #rx"^/?metadata/?$" path)))

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
                      "application/fhir+json; charset=utf-8"
                      #:location (created-location status js)))

;; created-location : status jsexpr -> string | #f   a create's Location: Type/id/_history/version
(define (created-location status js)
  (and (= status 201) (hash? js) (string? (hash-ref js 'resourceType #f)) (string? (hash-ref js 'id #f))
       (let ([v (let ([m (hash-ref js 'meta #f)]) (and (hash? m) (hash-ref m 'versionId #f)))])
         (format "~a/~a~a" (hash-ref js 'resourceType) (hash-ref js 'id) (if (string? v) (format "/_history/~a" v) "")))))

;; the general form: any body bytes with their own content type (raw Binary streams use this)
(define (write-raw-response out status bytes ctype #:location [location #f])
  (fprintf out "HTTP/1.1 ~a ~a\r\n" status (reason status))
  (fprintf out "Content-Type: ~a\r\n" ctype)
  (when location (fprintf out "Location: ~a\r\n" location))
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
