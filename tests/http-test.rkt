#lang racket/base

;;; http-test.rkt — end-to-end HTTP: start the example server, drive it over a real TCP socket.

(require rackunit
         racket/tcp
         racket/string
         racket/port
         (only-in fhir/http/server serve-app)
         (only-in (file "../examples/server-app.rkt") app))

(define port 8177)
(define stop (serve-app app #:port port))

;; a tiny HTTP/1.1 client: returns (values status-code body-string)
(define (req method path [body #f])
  (define-values (in out) (tcp-connect "127.0.0.1" port))
  (define b (or body ""))
  (fprintf out "~a ~a HTTP/1.1\r\nHost: localhost\r\nContent-Length: ~a\r\nConnection: close\r\n\r\n~a"
           method path (bytes-length (string->bytes/utf-8 b)) b)
  (flush-output out)
  (define resp (port->string in))
  (close-output-port out) (close-input-port in)
  (define status (string->number (cadr (string-split (car (string-split resp "\r\n"))))))
  (define body-str (let ([i (regexp-match-positions #rx"\r\n\r\n" resp)])
                     (if i (substring resp (cdar i)) "")))
  (values status body-str))

(with-handlers ([(lambda (_) #t) (lambda (e) (stop) (raise e))])
  ;; capabilities: GET /metadata
  (let-values ([(s b) (req "GET" "/metadata")])
    (check-equal? s 200)
    (check-true (regexp-match? #rx"CapabilityStatement" b))
    (check-true (regexp-match? #rx"searchParam" b)))          ; declared search params are advertised

  ;; create + read a resource
  (let-values ([(s b) (req "POST" "/Patient" "{\"resourceType\":\"Patient\",\"gender\":\"male\"}")])
    (check-equal? s 201)
    (check-true (regexp-match? #rx"\"resourceType\":\"Patient\"" b)))
  (let-values ([(s b) (req "POST" "/Patient" "{\"resourceType\":\"Patient\",\"gender\":\"female\"}")])
    (check-equal? s 201))
  (let-values ([(s b) (req "GET" "/Patient/1")])
    (check-equal? s 200)
    (check-true (regexp-match? #rx"\"id\":\"1\"" b)))

  ;; search parameter actually filters (gender token -> Patient.gender)
  (let-values ([(s b) (req "GET" "/Patient?gender=male")])
    (check-equal? s 200)
    (check-true (regexp-match? #rx"\"type\":\"searchset\"" b))
    (check-true (regexp-match? #rx"\"total\":1" b)))
  (let-values ([(s b) (req "GET" "/Patient")])
    (check-true (regexp-match? #rx"\"total\":2" b)))

  ;; not found + unknown type
  (let-values ([(s b) (req "GET" "/Patient/999")]) (check-equal? s 404))
  (let-values ([(s b) (req "GET" "/Nope")]) (check-equal? s 404))
  (let-values ([(s b) (req "DELETE" "/Observation/1")]) (check-equal? s 404)) ; delete undeclared on Observation

  ;; a system-level operation
  (let-values ([(s b) (req "POST" "/$ping"
                           "{\"resourceType\":\"Parameters\",\"parameter\":[{\"name\":\"message\",\"valueString\":\"hi\"}]}")])
    (check-equal? s 200)
    (check-true (regexp-match? #rx"\"resourceType\":\"Parameters\"" b))
    (check-true (regexp-match? #rx"hi" b)))

  (printf "http-test: all checks passed\n"))

(stop)
