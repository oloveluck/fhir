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
         "../result/result.rkt")

(provide (struct-out t-date)
         (struct-out t-time)
         (struct-out t-datetime)
         (contract-out
          [parse-t-date       (-> string? string? result?)]
          [parse-t-time       (-> string? string? result?)]
          [parse-t-datetime   (-> string? string? result?)]
          [parse-fhir-instant (-> string? string? result?)]
          [temporal->string   (-> any/c string?)]))

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

(define (parse-t-date raw url)
  (cond
    [(not (string? raw)) (err (invalid-encoding 'date url raw))]
    [(not (regexp-match? px:date raw)) (err (pattern-mismatch 'date url raw px:date))]
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
  (cond
    [(not (string? raw)) (err (invalid-encoding 'dateTime url raw))]
    [(not (regexp-match? px:dateTime raw)) (err (pattern-mismatch 'dateTime url raw px:dateTime))]
    [else
     (match-define (list _ y m d h mi s frac tz) (regexp-match datetime-extract raw))
     (ok (t-datetime (->num y) (->num m) (->num d)
                     (->num h) (->num mi) (->num s) frac tz
                     (cond [h 'second] [d 'day] [m 'month] [else 'year])))]))

;; instant — a dateTime constrained to full precision with a required timezone.
(define (parse-fhir-instant raw url)
  (cond
    [(not (string? raw)) (err (invalid-encoding 'instant url raw))]
    [(not (regexp-match? px:instant raw)) (err (pattern-mismatch 'instant url raw px:instant))]
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
  (check-equal? (parse-t-date "1974" "u") (ok (t-date 1974 #f #f 'year)))
  (check-equal? (parse-t-date "1974-12" "u") (ok (t-date 1974 12 #f 'month)))
  (check-equal? (parse-t-date "1974-12-25" "u") (ok (t-date 1974 12 25 'day)))
  (check-true (err? (parse-t-date "1974-13-40" "u")))
  ;; round-trip preserves precision
  (check-equal? (temporal->string (ok-or-raise (parse-t-date "1974" "u"))) "1974")
  (check-equal? (temporal->string (ok-or-raise (parse-t-date "1974-12" "u"))) "1974-12")
  (check-equal? (temporal->string (ok-or-raise (parse-t-datetime "2013-06-08T09:30:10+01:00" "u")))
                "2013-06-08T09:30:10+01:00"))
