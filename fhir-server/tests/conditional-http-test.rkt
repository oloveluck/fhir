#lang racket/base

;;; conditional-http-test.rkt — a resource's version on the wire, and the requests that depend on
;;; it (https://hl7.org/fhir/http.html: #versioning, #cread, #concurrency, #read, #search), through
;;; `answer` — what the server writes for one request, with no socket:
;;;   - a read, create or update answers the resource with `ETag: W/"<versionId>"` and
;;;     `Last-Modified`;
;;;   - a read with `If-None-Match` naming the current version is 304, with no body;
;;;   - an update with `If-Match` naming another version is 412 and writes nothing;
;;;   - a resource that was deleted is 410 Gone (its versions can still be read), one that never
;;;     was is 404;
;;;   - `POST /Type/_search` with the parameters as a form is the search.
;;; None of these were there: a client could not cache a read or guard a write.

(require rackunit racket/file racket/string
         (only-in json bytes->jsexpr)
         (only-in fhir/http/server answer response-status response-body response-headers))

(define dir (make-temporary-directory "conditional-~a"))
(define app-file (build-path dir "clinic.rkt"))
(void (call-with-output-file app-file
        (lambda (o) (write-string (string-append "#lang fhir/capability\n(server #:url \"http://example.org/fhir\")\n"
                                                 "(resource Patient #:interactions (read vread create update delete search-type history-instance)"
                                                 " #:search-params ([gender token]))\n") o))))
(define app (dynamic-require app-file 'app))
(define host '(("host" . "localhost:8080")))
(define (ask method target [headers '()] [body ""]) (answer app method target (append host headers) body))
(define (header r name) (let ([h (assoc name (response-headers r))]) (and h (cdr h))))
(define (json r) (bytes->jsexpr (response-body r)))

;; create: 201, where it is, and its version
(define created (ask "POST" "/Patient" '() "{\"resourceType\":\"Patient\",\"gender\":\"female\"}"))
(check-equal? (response-status created) 201)
(define id (hash-ref (json created) 'id))
(check-equal? (header created "Location") (format "http://localhost:8080/Patient/~a/_history/1" id))
(check-equal? (header created "ETag") "W/\"1\"")
(check-regexp-match #rx"^[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] [0-9]+ [0-9:]+ GMT$" (header created "Last-Modified"))
(define path (format "/Patient/~a" id))

;; read: the same version; asked again with it, 304 and nothing to send
(define read1 (ask "GET" path))
(check-equal? (response-status read1) 200)
(check-equal? (header read1 "ETag") "W/\"1\"")
(define cached (ask "GET" path '(("if-none-match" . "W/\"1\""))))
(check-equal? (response-status cached) 304)
(check-equal? (response-body cached) #"")
(check-equal? (header cached "ETag") "W/\"1\"")
(check-equal? (response-status (ask "GET" path (list (cons "if-modified-since" (header read1 "Last-Modified"))))) 304)
(check-equal? (response-status (ask "GET" path '(("if-none-match" . "W/\"7\"")))) 200)

;; update on the version read: carried out, version 2
(define (patient gender) (format "{\"resourceType\":\"Patient\",\"id\":\"~a\",\"gender\":\"~a\"}" id gender))
(define updated (ask "PUT" path '(("if-match" . "W/\"1\"")) (patient "other")))
(check-equal? (response-status updated) 200)
(check-equal? (header updated "ETag") "W/\"2\"")
;; a second writer still holding version 1 is refused, and nothing is written
(define stale (ask "PUT" path '(("if-match" . "W/\"1\"")) (patient "male")))
(check-equal? (response-status stale) 412)
(check-regexp-match #rx"current version is W/\"2\"" (hash-ref (car (hash-ref (json stale) 'issue)) 'diagnostics))
(check-equal? (hash-ref (json (ask "GET" path)) 'gender) "other")
(check-equal? (header (ask "GET" path) "ETag") "W/\"2\"")
;; the old copy is no longer current: the conditional read answers the new one
(check-equal? (response-status (ask "GET" path '(("if-none-match" . "W/\"1\"")))) 200)
;; a search answers a Bundle: no version of its own
(check-false (header (ask "GET" "/Patient") "ETag"))

;; search by POST, the parameters as a form
(define found (ask "POST" "/Patient/_search" '(("content-type" . "application/x-www-form-urlencoded")) "gender=other&_count=5"))
(check-equal? (response-status found) 200)
(check-equal? (hash-ref (json found) 'total) 1)
(check-equal? (hash-ref (json (ask "POST" "/Patient/_search" '() "gender=male")) 'total) 0)

;; deleted is Gone, with its versions still readable; never there is Not Found
(check-equal? (response-status (ask "DELETE" path '(("if-match" . "W/\"1\"")))) 412)
(check-true (and (memv (response-status (ask "DELETE" path '(("if-match" . "W/\"2\"")))) '(200 204)) #t))
(define gone (ask "GET" path))
(check-equal? (response-status gone) 410)
(check-regexp-match #rx"was deleted" (hash-ref (car (hash-ref (json gone) 'issue)) 'diagnostics))
(check-equal? (response-status (ask "GET" (string-append path "/_history/1"))) 200)
(check-equal? (response-status (ask "GET" "/Patient/never-was")) 404)

(delete-directory/files dir)
