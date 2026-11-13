#lang racket/base

;;; period-search-test.rkt — a date parameter whose value is a Period is searchable and sortable.
;;;
;;; FHIR's `date` on Encounter is `Encounter.period`. The index read a Period's bounds as the parsed
;;; value printed, which is no date, so NO Period was ever indexed: `Encounter?date=ge2125-01-01`
;;; matched nothing and `_sort=date` left the order as it was — both silently (found by an agent
;;; counting a patient's hospital visits in a year: the search said 0, the data held 2). The
;;; search oracle did not see it: it probes with the values the index holds.

(require rackunit racket/file
         (only-in fhir/http/router handle parse-query))

(define dir (make-temporary-directory "period-~a"))
(define app-file (build-path dir "visits.rkt"))
(void (call-with-output-file app-file
        (lambda (o) (write-string "#lang fhir/capability\n(server #:url \"http://example.org/fhir\")\n(resource Encounter #:interactions (read update search-type) #:search-params ([date date]))\n" o))))
(define app (dynamic-require app-file 'app))

;; three visits, stored out of date order; one still open (no end), one with a zone
(for ([v (in-list '(("b" "2125-03-19T08:00:00Z" "2125-03-28T10:00:00Z")
                    ("c" "2126-01-05T09:00:00-05:00" #f)
                    ("a" "2125-02-27" "2125-03-06")))])
  (define period (if (caddr v)
                     (format "{\"start\":\"~a\",\"end\":\"~a\"}" (cadr v) (caddr v))
                     (format "{\"start\":\"~a\"}" (cadr v))))
  (define-values (st _)
    (handle app "PUT" (string-append "/Encounter/" (car v)) '()
            (format "{\"resourceType\":\"Encounter\",\"id\":\"~a\",\"status\":\"completed\",\"actualPeriod\":~a}" (car v) period)))
  (check-true (and (memv st '(200 201)) #t) (car v)))

(define (ids qs)
  (define-values (st js) (handle app "GET" "/Encounter" (parse-query qs) ""))
  (check-equal? st 200 qs)
  (for/list ([e (in-list (hash-ref js 'entry '()))] #:when (equal? (hash-ref (hash-ref e 'search (hasheq)) 'mode #f) "match"))
    (hash-ref (hash-ref e 'resource) 'id)))

;; the visits of a year: a period that overlaps it
(check-equal? (sort (ids "date=2125") string<?) '("a" "b"))
(check-equal? (ids "date=ge2126-01-01") '("c"))
;; an open period reaches into the future
(check-equal? (sort (ids "date=ge2125-03-10") string<?) '("b" "c"))
(check-equal? (ids "date=lt2125-03-01") '("a"))
;; sorted by when they began, either way
(check-equal? (ids "_sort=date") '("a" "b" "c"))
(check-equal? (ids "_sort=-date") '("c" "b" "a"))

(delete-directory/files dir)
