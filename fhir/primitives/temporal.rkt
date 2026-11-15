#lang racket/base

;;; temporal.rkt — FHIR date / time / dateTime / instant with explicit precision.
;;;
;;; FHIR temporal types are partial: a `date` may be a year, a year-month, or a full date; a
;;; `dateTime` may stop at any of those or carry a full time + timezone. We make precision
;;; first-class rather than smuggling it into optional fields, so navigation and comparison can
;;; reason about it.
;;;
;;; Parsers gate on the strict spec regex (patterns.rkt) first, then re-scan with a capture regex
;;; to decompose. They take the spec URL so failures stay spec-linked.

(require racket/match
         racket/contract
         "patterns.rkt"
         fhir/result/result)

(provide (struct-out t-date)
         (struct-out t-time)
         (struct-out t-datetime)
         (contract-out
          [parse-t-date       (-> string? string? result?)]
          [parse-t-time       (-> string? string? result?)]
          [parse-t-datetime   (-> string? string? result?)]
          [parse-fhir-instant (-> string? string? result?)]
          [temporal->string   (-> any/c string?)]
          [calendar-problem   (-> string? (or/c string? #f))]))

;; precision ∈ '(year month day)
(struct t-date (year month day precision) #:transparent)
;; precision is always 'second here (FHIR time requires hh:mm:ss); frac may be #f
(struct t-time (hour minute second frac) #:transparent)
;; precision ∈ '(year month day second); tz is a string ("Z", "+05:30") or #f
(struct t-datetime (year month day hour minute second frac tz precision) #:transparent)

;; --- capture (extraction) regexes — only run AFTER strict validation passes ------
(define date-extract
  #px"^([0-9]{4})(?:-([0-9]{2})(?:-([0-9]{2}))?)?$")
(define time-extract
  #px"^([0-9]{2}):([0-9]{2}):([0-9]{2})(?:\\.([0-9]+))?$")
(define datetime-extract
  #px"^([0-9]{4})(?:-([0-9]{2})(?:-([0-9]{2})(?:T([0-9]{2}):([0-9]{2}):([0-9]{2})(?:\\.([0-9]+))?(Z|[+-][0-9]{2}:[0-9]{2}))?)?)?$")

(define (->num s) (and s (string->number s)))

;; days-in-month : year month -> natural   the Gregorian calendar (leap years by the 4/100/400 rule)
(define (days-in-month y m)
  (case m
    [(4 6 9 11) 30]
    [(2) (if (and (zero? (modulo y 4)) (or (not (zero? (modulo y 100))) (zero? (modulo y 400))))
             29 28)]
    [else 31]))

(define month-names
  #("January" "February" "March" "April" "May" "June" "July" "August" "September" "October"
    "November" "December"))

;; calendar-problem : string -> string | #f   why a date-shaped lexeme names no day of the
;; calendar ("February 1940 has 29 days"), #f when it does or is not date-shaped. The spec's
;; regexes allow a day up to 31 in every month; the calendar does not.
(define (calendar-problem raw)
  (match (regexp-match #px"^([0-9]{4})-([0-9]{2})-([0-9]{2})" raw)
    [(list _ ys ms ds)
     (define-values (y m d) (values (->num ys) (->num ms) (->num ds)))
     (and (<= 1 m 12) (> d (days-in-month y m))
          (format "~a ~a has ~a days" (vector-ref month-names (sub1 m)) y (days-in-month y m)))]
    [_ #f]))

;; calendar-error : symbol string string -> err | #f   an out-of-range error for a day the month lacks
(define (calendar-error type url raw)
  (match (regexp-match #px"^([0-9]{4})-([0-9]{2})-([0-9]{2})" raw)
    [(list _ ys ms ds)
     #:when (calendar-problem raw)
     (err (out-of-range type url raw 1 (days-in-month (->num ys) (->num ms))))]
    [_ #f]))

;; --- the common shapes, read directly ----------------------------------------------
;; Reading every date of a resource was three regular expressions a value (the spec's pattern, the
;; calendar's, the capture). The two shapes nearly every value has — a full date `YYYY-MM-DD` and a
;; full dateTime `YYYY-MM-DDThh:mm:ss[.f](Z|±hh:mm)` — are read here character by character, each
;; field held to the range the spec's pattern allows (patterns.rkt: a year not 0000, a month 01-12, a
;; day 01-31, an hour 00-23, a minute 00-59, a second 00-60, 1 to 9 fraction digits, a zone Z or
;; ±00:00-13:59 or ±14:00) and the day to its month. Anything else — another shape, a field out of
;; range, a day the month lacks — answers #f, and the regular expressions read it as before (their
;; answer, value or error, is the one returned). FullParts is
;; (vector y m d h mi s frac tz) — h … tz #f for a date.

;; digits : string start count -> natural | #f   the count ASCII digits at start, as a number
(define (digits s i n)
  (for/fold ([v 0]) ([k (in-range i (+ i n))])
    #:break (not v)
    (define c (string-ref s k))
    (and v (char<=? #\0 c #\9) (+ (* v 10) (- (char->integer c) 48)))))

;; full-parts : string -> FullParts | #f
(define (full-parts s)
  (define n (string-length s))
  (define (at i c) (char=? (string-ref s i) c))
  (and (>= n 10) (at 4 #\-) (at 7 #\-)
       (let ([y (digits s 0 4)] [m (digits s 5 2)] [d (digits s 8 2)])
         (and y m d (> y 0) (<= 1 m 12) (<= 1 d (days-in-month y m))
              (cond
                [(= n 10) (vector y m d #f #f #f #f #f)]
                [(and (>= n 20) (at 10 #\T) (at 13 #\:) (at 16 #\:))
                 (define h (digits s 11 2))
                 (define mi (digits s 14 2))
                 (define sec (digits s 17 2))
                 (define frac-end                          ; past the fraction, or 19 when none
                   (if (and (> n 19) (at 19 #\.))
                       (let loop ([k 20]) (if (and (< k n) (char<=? #\0 (string-ref s k) #\9)) (loop (add1 k)) k))
                       19))
                 (define frac (and (> frac-end 19) (substring s 20 frac-end)))
                 (define tz (substring s frac-end))
                 (and h mi sec (<= h 23) (<= mi 59) (<= sec 60)
                      (or (not frac) (<= 1 (string-length frac) 9))
                      (zone? tz)
                      (vector y m d h mi sec frac tz))]
                [else #f])))))

;; zone? : string -> boolean   Z, or ±hh:mm with hh 00-13 (any minute) or 14:00
(define (zone? z)
  (or (string=? z "Z")
      (and (= (string-length z) 6) (memv (string-ref z 0) '(#\+ #\-)) (char=? (string-ref z 3) #\:)
           (let ([h (digits z 1 2)] [mi (digits z 4 2)])
             (and h mi (or (and (<= h 13) (<= mi 59)) (and (= h 14) (= mi 0))))))))

(module+ test
  (require rackunit)
  ;; the direct read is the regular expressions' read, value or error
  (define (both-ways f raw) (check-equal? (f raw "u") (parameterize ([direct? #f]) (f raw "u")) raw))
  (for ([raw (in-list '("2024-02-29" "2023-02-29" "1990-13-01" "0000-01-01" "2024-01-31" "2024-04-31" "2024"
                        "2024-01" "2024-01-01T10:20:30Z" "2024-01-01T10:20:30.123+05:30" "2024-01-01T24:00:00Z"
                        "2024-01-01T10:20:60-14:00" "2024-01-01T10:20:30+14:01" "2024-01-01T10:20:30+13:59"
                        "2024-01-01T10:20:30" "2024-01-01T10:20:30.Z" "2024-01-01T10:20:30.1234567890Z"
                        "2024-01-01T10:20Z" "2024-1-01" "２０２４-01-01" "2024-01-01T10:20:30z"))])
    (both-ways parse-t-date raw)
    (both-ways parse-t-datetime raw)
    (both-ways parse-fhir-instant raw)))

;; direct? : whether the common shapes are read directly (#f: the regular expressions only, for tests)
(define direct? (make-parameter #t))

(define (parse-t-date raw url)
  (define p (and (string? raw) (= (string-length raw) 10) (direct?) (full-parts raw)))
  (cond
    [p (ok (t-date (vector-ref p 0) (vector-ref p 1) (vector-ref p 2) 'day))]
    [(not (string? raw)) (err (invalid-encoding 'date url raw))]
    [(not (regexp-match? px:date raw)) (err (pattern-mismatch 'date url raw px:date))]
    [(calendar-error 'date url raw) => values]
    [else
     (match-define (list _ y m d) (regexp-match date-extract raw))
     (ok (t-date (->num y) (->num m) (->num d)
                 (cond [d 'day] [m 'month] [else 'year])))]))

(define (parse-t-time raw url)
  (cond
    [(not (string? raw)) (err (invalid-encoding 'time url raw))]
    [(not (regexp-match? px:time raw)) (err (pattern-mismatch 'time url raw px:time))]
    [else
     (match-define (list _ h mi s frac) (regexp-match time-extract raw))
     (ok (t-time (->num h) (->num mi) (->num s) frac))]))

(define (parse-t-datetime raw url)
  (define p (and (string? raw) (direct?) (full-parts raw)))
  (cond
    [p (ok (t-datetime (vector-ref p 0) (vector-ref p 1) (vector-ref p 2) (vector-ref p 3) (vector-ref p 4)
                       (vector-ref p 5) (vector-ref p 6) (vector-ref p 7) (if (vector-ref p 3) 'second 'day)))]
    [(not (string? raw)) (err (invalid-encoding 'dateTime url raw))]
    [(not (regexp-match? px:dateTime raw)) (err (pattern-mismatch 'dateTime url raw px:dateTime))]
    [(calendar-error 'dateTime url raw) => values]
    [else
     (match-define (list _ y m d h mi s frac tz) (regexp-match datetime-extract raw))
     (ok (t-datetime (->num y) (->num m) (->num d)
                     (->num h) (->num mi) (->num s) frac tz
                     (cond [h 'second] [d 'day] [m 'month] [else 'year])))]))

;; instant — a dateTime constrained to full precision with a required timezone.
(define (parse-fhir-instant raw url)
  (define p (and (string? raw) (direct?) (full-parts raw)))
  (cond
    [(and p (vector-ref p 3))
     (ok (t-datetime (vector-ref p 0) (vector-ref p 1) (vector-ref p 2) (vector-ref p 3) (vector-ref p 4)
                     (vector-ref p 5) (vector-ref p 6) (vector-ref p 7) 'second))]
    [(not (string? raw)) (err (invalid-encoding 'instant url raw))]
    [(not (regexp-match? px:instant raw)) (err (pattern-mismatch 'instant url raw px:instant))]
    [(calendar-error 'instant url raw) => values]
    [else
     (match-define (list _ y m d h mi s frac tz) (regexp-match datetime-extract raw))
     (ok (t-datetime (->num y) (->num m) (->num d)
                     (->num h) (->num mi) (->num s) frac tz 'second))]))

;; --- rendering back to the FHIR lexical form ------------------------
(define (pad2 n) (if (< n 10) (string-append "0" (number->string n)) (number->string n)))
(define (pad4 n)
  (let ([s (number->string n)])
    (string-append (make-string (max 0 (- 4 (string-length s))) #\0) s)))

(define (temporal->string v)
  (match v
    [(t-date y m d prec)
     (case prec
       [(year)  (pad4 y)]
       [(month) (string-append (pad4 y) "-" (pad2 m))]
       [else    (string-append (pad4 y) "-" (pad2 m) "-" (pad2 d))])]
    [(t-time h mi s frac)
     (string-append (pad2 h) ":" (pad2 mi) ":" (pad2 s)
                    (if frac (string-append "." frac) ""))]
    [(t-datetime y m d h mi s frac tz prec)
     (define date-part
       (case prec
         [(year)  (pad4 y)]
         [(month) (string-append (pad4 y) "-" (pad2 m))]
         [else    (string-append (pad4 y) "-" (pad2 m) "-" (pad2 d))]))
     (if (eq? prec 'second)
         (string-append date-part "T" (pad2 h) ":" (pad2 mi) ":" (pad2 s)
                        (if frac (string-append "." frac) "")
                        (or tz ""))
         date-part)]))

(module+ test
  (require rackunit)
  ;; the calendar, not only the regex: a day the month lacks is refused, leap years by 4/100/400
  (check-true (err? (parse-t-date "1940-02-30" "u")))
  (check-true (ok? (parse-t-date "1940-02-29" "u")))
  (check-true (err? (parse-t-date "1900-02-29" "u")))
  (check-true (ok? (parse-t-date "2000-02-29" "u")))
  (check-true (err? (parse-t-date "2024-04-31" "u")))
  (check-true (err? (parse-t-datetime "2024-06-31T10:00:00Z" "u")))
  (check-true (err? (parse-fhir-instant "2023-02-29T10:00:00Z" "u")))
  (check-equal? (calendar-problem "1940-02-30") "February 1940 has 29 days")
  (check-equal? (calendar-problem "1941-02-30") "February 1941 has 28 days")
  (check-false (calendar-problem "1940-02"))
  (check-equal? (parse-t-date "1974" "u") (ok (t-date 1974 #f #f 'year)))
  (check-equal? (parse-t-date "1974-12" "u") (ok (t-date 1974 12 #f 'month)))
  (check-equal? (parse-t-date "1974-12-25" "u") (ok (t-date 1974 12 25 'day)))
  (check-true (err? (parse-t-date "1974-13-40" "u")))
  ;; round-trip preserves precision
  (check-equal? (temporal->string (ok-or-raise (parse-t-date "1974" "u"))) "1974")
  (check-equal? (temporal->string (ok-or-raise (parse-t-date "1974-12" "u"))) "1974-12")
  (check-equal? (temporal->string (ok-or-raise (parse-t-datetime "2013-06-08T09:30:10+01:00" "u")))
                "2013-06-08T09:30:10+01:00"))
