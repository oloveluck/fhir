#lang racket/base

;;; search-paging-test.rkt — a searchset that is a page says so, as FHIR defines it
;;; (https://hl7.org/fhir/http.html#paging, Bundle.total): `total` is the number of resources that
;;; match, not the number on the page; `next` and `previous` links lead through the pages; and
;;; `_summary=count` (or `_count=0`) answers the total alone. Before, `total` was the page's length
;;; and there were no links: a client could not tell a full answer from the first two of a thousand.

(require rackunit racket/file racket/list
         (only-in fhir/http/router handle parse-query)
         (only-in fhir/http/server bundle-with-urls))

(define dir (make-temporary-directory "paging-~a"))
(define app-file (build-path dir "study.rkt"))
(void (call-with-output-file app-file
        (lambda (o) (write-string "#lang fhir/capability\n(server #:url \"http://example.org/fhir\")\n(resource Patient #:interactions (read create search-type) #:search-params ([gender token]))\n" o))))
(define app (dynamic-require app-file 'app))
(for ([g '("female" "male" "female" "male" "female")])
  (define-values (st _) (handle app "POST" "/Patient" '() (format "{\"resourceType\":\"Patient\",\"gender\":\"~a\"}" g)))
  (check-equal? st 201))

;; search : query-string -> Bundle jsexpr   through the router, as the server would for GET /Patient?…
(define (search qs)
  (define-values (st js) (handle app "GET" "/Patient" (parse-query qs) ""))
  (check-equal? st 200 qs)
  js)
(define (matches b) (for/list ([e (in-list (hash-ref b 'entry '()))] #:when (equal? (hash-ref (hash-ref e 'search (hasheq)) 'mode #f) "match")) e))
(define (link b rel) (for/first ([l (in-list (hash-ref b 'link '()))] #:when (equal? (hash-ref l 'relation) rel)) (hash-ref l 'url)))
(define (ids b) (for/list ([e (in-list (matches b))]) (hash-ref (hash-ref e 'resource) 'id)))

;; no paging asked: every match, total = their number, no paging links
(define all (search "gender=female"))
(check-equal? (hash-ref all 'total) 3)
(check-equal? (length (matches all)) 3)
(check-false (link all "next"))

;; the first page of two: total is still 3, and `next` is the same search moved on by the page
(define p1 (search "gender=female&_count=2"))
(check-equal? (hash-ref p1 'total) 3)
(check-equal? (length (matches p1)) 2)
(check-equal? (link p1 "next") "Patient?gender=female&_count=2&_offset=2")
(check-false (link p1 "previous"))

;; following `next`: the last match, a way back, and no further page
(define p2 (search (cadr (regexp-match #rx"[?](.*)$" (link p1 "next")))))
(check-equal? (hash-ref p2 'total) 3)
(check-equal? (length (matches p2)) 1)
(check-false (link p2 "next"))
(check-equal? (link p2 "previous") "Patient?gender=female&_count=2")
;; the pages together are the whole answer, each match once
(check-equal? (sort (append (ids p1) (ids p2)) string<?) (sort (ids all) string<?))

;; the count alone, either way it is asked
(for ([qs '("gender=female&_summary=count" "gender=female&_count=0")])
  (define c (search qs))
  (check-equal? (hash-ref c 'total) 3 qs)
  (check-equal? (matches c) '() qs)
  (check-false (hash-has-key? c 'entry) "no entries: no `entry` (an empty array is not FHIR JSON)"))

;; a parameter the server cannot apply is still said on a page, and does not change the total
(define p3 (search "gender=female&bogus=1&_count=1"))
(check-equal? (hash-ref p3 'total) 3)
(check-equal? (length (hash-ref p3 'entry)) 2 "one match and the outcome entry")

;; over HTTP the links are absolute, `self` first
(define wire (bundle-with-urls p1 "http://localhost:8080" "/Patient?gender=female&_count=2"))
(check-equal? (map (lambda (l) (hash-ref l 'relation)) (hash-ref wire 'link)) '("self" "next"))
(check-equal? (link wire "next") "http://localhost:8080/Patient?gender=female&_count=2&_offset=2")

(delete-directory/files dir)
