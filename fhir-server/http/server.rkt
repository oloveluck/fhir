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
         (only-in json jsexpr->string bytes->jsexpr)
         (only-in fhir/serialize/fhir-json fhir-json->string)
         (only-in fhir/capability/runtime app? current-search-strict?)
         (only-in "router.rkt" handle/raw parse-query)
         (only-in "conditional.rkt" resource-version version-headers not-modified? match-failure))

(provide
 bundle-with-urls
 (struct-out response)
 (contract-out
  ;; answer : one request answered, as a value (no socket): what `serve-app` writes for it
  [answer (-> app? string? string? (listof (cons/c string? string?)) string? response?)]
  ;; #:bearer token — require `Authorization: Bearer <token>` on every request except GET /metadata
  ;; (a static token: enough for test kits that take a manually supplied access token; NOT SMART)
  ;; #:port 0 takes a free port; #:on-listen receives the port listened on (the one to print)
  [serve-app (->* (app?) (#:port (integer-in 0 65535) #:host (or/c string? #f) #:bearer (or/c string? #f) #:log? boolean?
                          #:on-listen (or/c #f (-> (integer-in 1 65535) any)))
                  (-> void))]))

;; start serving `app` on `port`; returns a thunk that stops the server.
(define (serve-app app #:port [port 8080] #:host [host #f] #:bearer [bearer #f] #:log? [log? #f] #:on-listen [on-listen #f])
  (define listener (tcp-listen port 128 #t host))
  (when on-listen (let-values ([(_h p _rh _rp) (tcp-addresses listener #t)]) (on-listen p)))
  (define stopped? (box #f))
  (define (accept-loop)
    (define conn
      (with-handlers ([exn:fail? (lambda (_) #f)])
        (call-with-values (lambda () (tcp-accept listener)) list)))
    (when (and conn (not (unbox stopped?)))
      (thread (lambda () (serve-conn app (car conn) (cadr conn) bearer log?)))
      (accept-loop)))
  (define worker (thread accept-loop))
  (lambda ()
    (set-box! stopped? #t)
    (with-handlers ([exn:fail? void]) (tcp-close listener))
    (kill-thread worker)))

;; serve exactly one request on this connection, then close it
(define (serve-conn app in out [bearer #f] [log? #f])
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
         (cond
           [(and bearer (not (authorized? headers bearer)) (not (metadata-request? method (path-of target))))
            (write-response out 401 (oo-json "login" "a valid bearer token is required"))]
           [else
            (define r (answer app method target headers body))
            ;; --log: one line per request, as a server log reads (method, target, status)
            (when log? (eprintf "~a ~a ~a\n" method target (response-status r)) (flush-output (current-error-port)))
            (write-raw-response out (response-status r) (response-body r) (response-content-type r)
                                #:headers (response-headers r))])])))
  (flush-output out)
  (close-output-port out)
  (close-input-port in))

;; A Response is (response status body-bytes content-type headers): what goes on the wire, the
;; headers beyond Content-Type and Content-Length as (listof (cons name value)).
(struct response (status body content-type headers) #:transparent)

;; answer : app method target Headers body -> Response
;; One request answered, with no port in sight: the router's answer (http/router), and around it
;; what only HTTP knows — the base url (the Host header: absolute links, `fullUrl`s, `Location`),
;; the client's preference for strict search, and the resource's version (http/conditional): its
;; ETag and Last-Modified, a conditional read answered 304, a write refused 412 when `If-Match`
;; names another version than the current one.
(define (answer app method target headers body)
  (define-values (path query) (split-target target))
  (define base (base-of headers))
  (define refusal (and (member method '("PUT" "PATCH" "DELETE")) (assoc "if-match" headers)
                       (match-failure headers (current-version app path))))
  (cond
    [refusal (response 412 (json-bytes (oo-json "conflict" refusal)) fhir-json '())]
    [else
     (define prefer (let ([v (assoc "prefer" headers)]) (and v (cdr v))))
     (define-values (status bytes0 ctype)
       (parameterize ([current-search-strict? (and prefer (regexp-match? #rx"handling *= *strict" prefer))])
         (handle/raw app method path (parse-query query) body)))
     (define bytes (with-bundle-urls bytes0 base target))
     ;; the one resource the answer is, when it is one (a Bundle of others has no version of its own)
     (define js (and (memv status '(200 201)) (regexp-match? #rx"json" ctype)
                     (not (regexp-match? #rx#"^{\"resourceType\": ?\"Bundle\"" bytes))
                     (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bytes))))
     (define v (resource-version js))
     (define location (absolute base (created-location status js)))
     (define extra (append (if v (version-headers v) '())
                           (if location (list (cons "Location" location)) '())))
     (if (and v (= status 200) (equal? method "GET") (not-modified? headers v))
         (response 304 #"" ctype extra)
         (response status bytes ctype extra))]))

;; current-version : app path -> Version | #f   the version a read of `path` answers now
(define (current-version app path)
  (define-values (status bytes _ctype) (handle/raw app "GET" path '() ""))
  (and (= status 200)
       (resource-version (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bytes)))))

(define fhir-json "application/fhir+json; charset=utf-8")
(define (json-bytes js) (string->bytes/utf-8 (fhir-json->string js)))
(define (path-of target) (let-values ([(path _q) (split-target target)]) path))

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
  (write-raw-response out status (if js (json-bytes js) #"") fhir-json))

;; base-of : headers -> string|#f   the server's base url as the client reached it (its Host header);
;; absolute : base location -> location   FHIR's Location is [base]/Type/id/_history/vid
(define (base-of headers)
  (define h (assoc "host" headers))
  (and h (not (string=? (cdr h) "")) (format "http://~a" (cdr h))))
(define (absolute base location)
  (and location (if base (string-append base "/" location) location)))

;; with-bundle-urls : bytes (string|#f) string -> bytes
;; A searchset or history Bundle as FHIR requires it (bdl-15, bdl-18 …): each entry's `fullUrl`
;; ([base]/Type/id, a urn:uuid for an entry without an id) and a `self` link ([base] + the request
;; target). The router answers without the base, which only the request's Host header gives.
(define (with-bundle-urls bs base target)
  (cond
    [(not (and base (regexp-match? #rx#"\"(searchset|history)\"" bs))) bs]
    [else
     (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bs)))
     (if (and (hash? js) (equal? (hash-ref js 'resourceType #f) "Bundle")
              (member (hash-ref js 'type #f) '("searchset" "history")))
         (string->bytes/utf-8 (fhir-json->string (bundle-with-urls js base target)))
         bs)]))

;; bundle-with-urls : Bundle-jsexpr string string -> Bundle-jsexpr
(define (bundle-with-urls js base target)
  (define (full-url r)
    (if (and (hash? r) (string? (hash-ref r 'resourceType #f)) (string? (hash-ref r 'id #f)))
        (format "~a/~a/~a" base (hash-ref r 'resourceType) (hash-ref r 'id))
        (format "urn:uuid:~a" (random-uuid))))
  (define entries
    (for/list ([e (in-list (hash-ref js 'entry '()))])
      (if (and (hash? e) (not (hash-ref e 'fullUrl #f)))
          (hash-set e 'fullUrl (full-url (hash-ref e 'resource #f)))
          e)))
  (define with-entries (if (null? entries) js (hash-set js 'entry entries)))
  ;; the links: `self` first (the request as received), then the paging links the search gave,
  ;; which are relative to the base ("Patient?_count=2&_offset=2")
  (define (absolute-link l)
    (define url (hash-ref l 'url ""))
    (if (regexp-match? #rx"^[a-z][a-z0-9+.-]*:" url) l (hash-set l 'url (string-append base "/" url))))
  (define given (map absolute-link (filter hash? (hash-ref js 'link '()))))
  (hash-set with-entries 'link
            (if (for/or ([l (in-list given)]) (equal? (hash-ref l 'relation #f) "self"))
                given
                (cons (hasheq 'relation "self" 'url (string-append base target)) given))))

;; random-uuid : -> string   a version-4 UUID
(define (random-uuid)
  (define (hex n) (apply string-append (for/list ([_ (in-range n)]) (number->string (random 16) 16))))
  (format "~a-~a-4~a-~a~a-~a" (hex 8) (hex 4) (hex 3) (string-ref "89ab" (random 4)) (hex 3) (hex 12)))

;; created-location : status jsexpr -> string | #f   a create's Location: Type/id/_history/version
(define (created-location status js)
  (and (= status 201) js (hash? js) (string? (hash-ref js 'resourceType #f)) (string? (hash-ref js 'id #f))
       (let ([v (let ([m (hash-ref js 'meta #f)]) (and (hash? m) (hash-ref m 'versionId #f)))])
         (format "~a/~a~a" (hash-ref js 'resourceType) (hash-ref js 'id) (if (string? v) (format "/_history/~a" v) "")))))

;; the general form: any body bytes with their own content type (raw Binary streams use this)
(define (write-raw-response out status bytes ctype #:headers [headers '()])
  (fprintf out "HTTP/1.1 ~a ~a\r\n" status (reason status))
  (fprintf out "Content-Type: ~a\r\n" ctype)
  (for ([h (in-list headers)]) (fprintf out "~a: ~a\r\n" (car h) (cdr h)))
  (fprintf out "Content-Length: ~a\r\n" (bytes-length bytes))
  (fprintf out "Connection: close\r\n\r\n")
  (write-bytes bytes out))

(define (oo-json code msg)
  (hasheq 'resourceType "OperationOutcome"
          'issue (list (hasheq 'severity "error" 'code code 'diagnostics msg))))

(define (reason status)
  (case status
    [(200) "OK"] [(201) "Created"] [(204) "No Content"] [(304) "Not Modified"] [(400) "Bad Request"]
    [(401) "Unauthorized"] [(403) "Forbidden"] [(404) "Not Found"] [(405) "Method Not Allowed"]
    [(409) "Conflict"] [(410) "Gone"] [(412) "Precondition Failed"] [(422) "Unprocessable Entity"]
    [(500) "Internal Server Error"] [else "OK"]))
