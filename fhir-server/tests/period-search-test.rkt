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
        (lambda (o) (write-string "#lang fhir/capability\n(server #:url \"http://example.org/fhir\")\n(resource Encounter #:interactions (read update search-type) #:search-params ([date date]))\n(resource Observation #:interactions (read update search-type) #:search-params ([date date]))\n" o))))
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

(define (ids qs #:type [type "Encounter"])
  (define-values (st js) (handle app "GET" (string-append "/" type) (parse-query qs) ""))
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

;; a zone's `+` written unencoded in the query string arrives as a space: it is read as the `+` it
;; was (MedagentBench's agents write `date=ge2023-11-12T10:15:00+00:00`; HAPI reads it so). It was
;; "search parameter `date` is not supported here: it was ignored", and every visit came back.
(check-equal? (ids "date=ge2126-01-05T13:00:00+00:00") (ids "date=ge2126-01-05T13:00:00%2B00:00"))
(check-equal? (ids "date=lt2125-03-01T00:00:00+00:00") '("a"))
;; a date that is no date is the client's error, said with the form: ignored, the search would answer
;; every visit to a question about some
(define-values (bad-status bad) (handle app "GET" "/Encounter" (parse-query "date=ge2125-13-45") ""))
(check-equal? bad-status 400)
(check-regexp-match #rx"`date`: `ge2125-13-45` is not a date" (hash-ref (car (hash-ref bad 'issue)) 'diagnostics))

;; A date with no zone is the day (the time) AS THE RECORD WROTE IT. It was compared with the
;; record's UTC range, so `date=2116-12-17` over readings written at -05:00 answered the evening of
;; the 16th and lost the 17th after 19:00 — an agent asked for a day's readings and missed the one
;; of 23:52 (FHIR-AgentBench, round 5).
(for ([v (in-list '(("eve"   "2116-12-16T19:30:00-05:00")
                    ("noon"  "2116-12-17T12:00:00-05:00")
                    ("late"  "2116-12-17T23:52:00-05:00")
                    ("next"  "2116-12-18T00:10:00-05:00")
                    ("tokyo" "2116-12-17T08:00:00+09:00")))])      ; the 16th, 23:00 in UTC
  (define-values (st _)
    (handle app "PUT" (string-append "/Observation/" (car v)) '()
            (format "{\"resourceType\":\"Observation\",\"id\":\"~a\",\"status\":\"final\",\"code\":{\"text\":\"pulse\"},\"effectiveDateTime\":\"~a\"}" (car v) (cadr v))))
  (check-true (and (memv st '(200 201)) #t) (car v)))
(define (readings qs) (sort (ids qs #:type "Observation") string<?))
(check-equal? (readings "date=2116-12-17") '("late" "noon" "tokyo"))
(check-equal? (readings "date=ge2116-12-17&date=lt2116-12-18") '("late" "noon" "tokyo"))
(check-equal? (readings "date=ge2116-12-17T23:00") '("late" "next"))
(check-equal? (readings "date=le2116-12-16") '("eve"))
(check-equal? (readings "date=ne2116-12-17") '("eve" "next"))
(check-equal? (readings "date=2116-12") '("eve" "late" "next" "noon" "tokyo"))
;; a value WITH a zone is an instant, whatever clock each record was written on
(check-equal? (readings "date=ge2116-12-18T00:00:00Z") '("late" "next"))
(check-equal? (readings "date=lt2116-12-17T00:00:00Z") '("tokyo"))
(check-equal? (readings "date=ge2116-12-17T00:00:00-05:00&date=lt2116-12-18T00:00:00-05:00") '("late" "noon"))
;; and the order is the instants'
(check-equal? (ids "_sort=date" #:type "Observation") '("tokyo" "eve" "noon" "late" "next"))

(delete-directory/files dir)
