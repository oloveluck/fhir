#lang racket/base

;;; conditional.rkt — a resource's version on the wire, and the requests that depend on it.
;;;
;;; FHIR's RESTful API (https://hl7.org/fhir/http.html#versioning, #cread, #concurrency):
;;;   - a response that carries one resource carries its version as `ETag: W/"<versionId>"` and
;;;     its `meta.lastUpdated` as `Last-Modified`;
;;;   - a read with `If-None-Match` or `If-Modified-Since` that the current version satisfies is
;;;     answered 304 Not Modified, with no body (the client's copy is current);
;;;   - an update, patch or delete with `If-Match` is carried out only on the version it names:
;;;     any other current version is 412 Precondition Failed (someone else wrote in between).
;;;
;;; Pure functions over the request's headers and the resource as JSON: the HTTP layer applies
;;; them (http/server.rkt); nothing here reads a store or a socket.
;;;
;;; A Headers is a (listof (cons lowercased-name value)), as the server reads them.
;;; A Version is (version id-string last-updated-string|#f): what `meta` says of one resource.

(require racket/contract racket/string racket/match racket/list
         (only-in racket/date find-seconds))

(provide
 (struct-out version)
 (contract-out
  ;; resource-version : jsexpr -> Version | #f   of one resource (not a Bundle of others, not an
  ;; OperationOutcome: those are answers about resources, with no version of their own)
  [resource-version (-> any/c (or/c version? #f))]
  ;; version-headers : Version -> (listof (cons name value))   ETag and Last-Modified
  [version-headers (-> version? (listof (cons/c string? string?)))]
  ;; not-modified? : Headers Version -> boolean   a conditional read the version satisfies
  [not-modified? (-> (listof pair?) version? boolean?)]
  ;; match-failure : Headers (Version|#f) -> string | #f   why `If-Match` refuses the write, or #f
  ;; when there is no `If-Match` or the current version is the one it names
  [match-failure (-> (listof pair?) (or/c version? #f) (or/c string? #f))]
  [etag (-> string? string?)]
  [http-date (-> string? (or/c string? #f))]
  [http-date->seconds (-> string? (or/c exact-integer? #f))]))

(struct version (id last-updated) #:transparent)

(define (resource-version js)
  (and (hash? js)
       (string? (hash-ref js 'resourceType #f))
       (not (member (hash-ref js 'resourceType) '("Bundle" "OperationOutcome" "Parameters")))
       (let ([meta (hash-ref js 'meta #f)])
         (and (hash? meta)
              (string? (hash-ref meta 'versionId #f))
              (version (hash-ref meta 'versionId)
                       (let ([u (hash-ref meta 'lastUpdated #f)]) (and (string? u) u)))))))

;; etag : version-id -> string   FHIR's ETag is weak: W/"3"
(define (etag vid) (format "W/\"~a\"" vid))

(define (version-headers v)
  (define modified (and (version-last-updated v) (http-date (version-last-updated v))))
  (cons (cons "ETag" (etag (version-id v)))
        (if modified (list (cons "Last-Modified" modified)) '())))

;; etag-ids : header-value -> (listof string) | '*   the version ids an If-Match / If-None-Match
;; lists (`W/"3", "4"`; weak or strong, compared weakly as RFC 7232 says for these), or `*`
(define (etag-ids value)
  (if (equal? (string-trim value) "*")
      '*
      (for/list ([m (in-list (regexp-match* #px"(?:W/)?\"([^\"]*)\"" value #:match-select cadr))]) m)))

(define (header headers name) (let ([h (assoc name headers)]) (and h (cdr h))))

(define (not-modified? headers v)
  (define none-match (header headers "if-none-match"))
  (define since (header headers "if-modified-since"))
  (cond
    ;; If-None-Match decides alone when present (RFC 7232 §3.3: If-Modified-Since is then ignored)
    [none-match (let ([ids (etag-ids none-match)]) (or (eq? ids '*) (and (member (version-id v) ids) #t)))]
    [since (let ([asked (http-date->seconds since)]
                 [changed (and (version-last-updated v) (instant->seconds (version-last-updated v)))])
             (and asked changed (<= changed asked)))]
    [else #f]))

(define (match-failure headers current)
  (define if-match (header headers "if-match"))
  (cond
    [(not if-match) #f]
    [(not current) (format "If-Match: ~a, but there is no current version of the resource" if-match)]
    [else
     (define ids (etag-ids if-match))
     (cond [(or (eq? ids '*) (member (version-id current) ids)) #f]
           [else (format "If-Match: ~a, but the current version is ~a: the resource has changed since you read it"
                         if-match (etag (version-id current)))])]))

;; ---- dates -----------------------------------------------------------------------------------
;; instant->seconds : FHIR instant/dateTime with a time and a zone -> seconds since the epoch | #f
;; (fractions of a second dropped: HTTP dates have none)
(define (instant->seconds s)
  (match (regexp-match #px"^(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})(?:\\.\\d+)?(Z|[+-]\\d{2}:\\d{2})$" s)
    [(list _ y mo d h mi sec zone)
     (define utc (with-handlers ([exn:fail? (lambda (_) #f)])
                   (apply find-seconds (append (map string->number (list sec mi h d mo y)) (list #f)))))
     (and utc (- utc (zone-seconds zone)))]
    [_ #f]))
(define (zone-seconds zone)
  (match (regexp-match #px"^([+-])(\\d{2}):(\\d{2})$" zone)
    [(list _ sign h m) (* (if (equal? sign "-") -1 1) (+ (* 3600 (string->number h)) (* 60 (string->number m))))]
    [_ 0]))

(define day-names '#("Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat"))
(define month-names '#("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"))

;; http-date : FHIR instant -> string | #f   RFC 7231's IMF-fixdate: Sun, 06 Nov 1994 08:49:37 GMT
(define (http-date instant)
  (define secs (instant->seconds instant))
  (and secs
       (let ([d (seconds->date secs #f)])
         (format "~a, ~a ~a ~a ~a:~a:~a GMT"
                 (vector-ref day-names (date-week-day d))
                 (pad (date-day d)) (vector-ref month-names (sub1 (date-month d))) (date-year d)
                 (pad (date-hour d)) (pad (date-minute d)) (pad (date-second d))))))
(define (pad n) (if (< n 10) (format "0~a" n) (number->string n)))

;; http-date->seconds : IMF-fixdate -> seconds | #f   (the obsolete HTTP date forms are not read)
(define (http-date->seconds s)
  (match (regexp-match #px"^\\s*[A-Za-z]{3}, (\\d{2}) ([A-Za-z]{3}) (\\d{4}) (\\d{2}):(\\d{2}):(\\d{2}) GMT\\s*$" s)
    [(list _ d mon y h mi sec)
     (define month (index-of (vector->list month-names) mon))
     (and month
          (with-handlers ([exn:fail? (lambda (_) #f)])
            (find-seconds (string->number sec) (string->number mi) (string->number h)
                          (string->number d) (add1 month) (string->number y) #f)))]
    [_ #f]))

(module+ test
  (require rackunit)
  (define ann (hasheq 'resourceType "Patient" 'id "ann"
                      'meta (hasheq 'versionId "3" 'lastUpdated "1994-11-06T08:49:37.250Z")))
  (define v (resource-version ann))
  ;; one resource has a version; an answer about resources has none
  (check-equal? v (version "3" "1994-11-06T08:49:37.250Z"))
  (check-false (resource-version (hasheq 'resourceType "Bundle" 'meta (hasheq 'versionId "1"))))
  (check-false (resource-version (hasheq 'resourceType "Patient" 'id "new")))
  ;; on the wire (the date is RFC 7231's own example; a zone is brought to GMT)
  (check-equal? (version-headers v) '(("ETag" . "W/\"3\"") ("Last-Modified" . "Sun, 06 Nov 1994 08:49:37 GMT")))
  (check-equal? (http-date "1994-11-06T09:49:37+01:00") "Sun, 06 Nov 1994 08:49:37 GMT")
  (check-false (http-date "1994-11-06"))
  (check-equal? (http-date->seconds (http-date "2026-11-13T19:59:18Z")) (instant->seconds "2026-11-13T19:59:18Z"))
  ;; a conditional read
  (check-true (not-modified? '(("if-none-match" . "W/\"3\"")) v))
  (check-true (not-modified? '(("if-none-match" . "\"2\", W/\"3\"")) v))
  (check-false (not-modified? '(("if-none-match" . "W/\"2\"")) v))
  (check-true (not-modified? '(("if-modified-since" . "Sun, 06 Nov 1994 08:49:37 GMT")) v))
  (check-false (not-modified? '(("if-modified-since" . "Sun, 06 Nov 1994 08:49:36 GMT")) v))
  ;; If-None-Match decides alone when both are sent
  (check-false (not-modified? '(("if-none-match" . "W/\"2\"") ("if-modified-since" . "Mon, 07 Nov 1994 00:00:00 GMT")) v))
  (check-false (not-modified? '() v))
  ;; a version-aware write
  (check-false (match-failure '() v))
  (check-false (match-failure '(("if-match" . "W/\"3\"")) v))
  (check-false (match-failure '(("if-match" . "*")) v))
  (check-regexp-match #rx"current version is W/\"3\"" (match-failure '(("if-match" . "W/\"2\"")) v))
  (check-regexp-match #rx"no current version" (match-failure '(("if-match" . "W/\"1\"")) #f)))
