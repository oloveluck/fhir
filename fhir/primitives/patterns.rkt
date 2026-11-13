#lang racket/base

;;; patterns.rkt — the single source of truth for FHIR primitive-type regexes.
;;;
;;; Each pattern is transcribed from the FHIR spec (https://build.fhir.org/datatypes.html) and
;;; anchored with ^(?: ... )$ so it matches the WHOLE lexical form. The spec URL for each type is
;;; attached at the macro call site in primitives.rkt, not here.
;;;
;;; Naming convention: px:<type>.

(provide px:string px:markdown px:xhtml
         px:id px:code px:uri px:url px:canonical px:oid px:uuid
         px:boolean px:integer px:integer64 px:positiveInt px:unsignedInt px:decimal
         px:base64Binary
         px:date px:time px:dateTime px:instant
         pattern-matches?)

;; --- string-like ----------------------------------------------------
;; string / markdown: any non-empty sequence (length cap enforced separately). The spec writes
;; ^[\s\S]+$; every character matches [\s\S], so the set is "has a first character", and matching
;; that alone is the same test in O(1) — the long form walked every character of every value (a
;; narrative div: 0.5 ms per 5 KB, 13% of validating US Core's examples).
(define px:string   #px"^[\\s\\S]")
(define px:markdown #px"^[\\s\\S]")
;; xhtml: validated structurally elsewhere; accept any non-empty here.
(define px:xhtml    #px"^[\\s\\S]")

(define px:id        #px"^(?:[A-Za-z0-9\\-\\.]{1,64})$")
(define px:code      #px"^(?:[^\\s]+(?: [^\\s]+)*)$")
(define px:uri       #px"^(?:\\S*)$")
(define px:url       #px"^(?:\\S*)$")
(define px:canonical #px"^(?:\\S*)$")
;; pattern-matches? : pattern string -> boolean   does the whole string match the pattern
;; The patterns that say "no white space" (uri, url, canonical) or "words with single spaces
;; between" (code) are decided by one pass over the characters: the regexp matcher took 1.5 µs for
;; a 60-character system url where the pass takes 0.2, and a resource holds a dozen (11% of
;; reading one). Every other pattern is the regexp's.
(define (pattern-matches? pat s)
  (cond [(or (eq? pat px:uri) (eq? pat px:url) (eq? pat px:canonical)) (no-space? s)]
        [(eq? pat px:code) (code-lexeme? s)]
        [else (regexp-match? pat s)]))

;; space? : char -> boolean   what `\s` matches: ASCII white space
(define (space? c) (or (eqv? c #\space) (eqv? c #\tab) (eqv? c #\newline) (eqv? c #\page) (eqv? c #\return)))
;; no-space? : string -> boolean   ^\S*$
(define (no-space? s) (for/and ([c (in-string s)]) (not (space? c))))
;; code-lexeme? : string -> boolean   ^[^\s]+( [^\s]+)*$ — not empty, no white space but single
;; spaces, none at either end
(define (code-lexeme? s)
  (define n (string-length s))
  (and (> n 0)
       (not (space? (string-ref s 0)))
       (not (space? (string-ref s (sub1 n))))
       (let loop ([i 1])
         (or (>= i n)
             (let ([c (string-ref s i)])
               (and (or (not (space? c))
                        (and (eqv? c #\space) (not (space? (string-ref s (sub1 i))))))
                    (loop (add1 i))))))))

(define px:oid       #px"^(?:urn:oid:[0-2](?:\\.(?:0|[1-9][0-9]*))+)$")
(define px:uuid      #px"^(?:urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$")

;; --- numeric --------------------------------------------------------
(define px:boolean     #px"^(?:true|false)$")
(define px:integer     #px"^(?:[0]|[-+]?[1-9][0-9]*)$")
(define px:integer64   #px"^(?:[0]|[-+]?[1-9][0-9]*)$")
(define px:positiveInt #px"^(?:[1-9][0-9]*)$")
(define px:unsignedInt #px"^(?:[0]|[1-9][0-9]*)$")
(define px:decimal     #px"^(?:-?(?:0|[1-9][0-9]{0,17})(?:\\.[0-9]{1,17})?(?:[eE][+-]?[0-9]{1,9})?)$")

;; --- binary ---------------------------------------------------------
(define px:base64Binary #px"^(?:(?:\\s*[0-9a-zA-Z+/=]{4}\\s*)+)?$")

;; --- temporal -------------------------------------------------------
(define px:date #px"^(?:([0-9]([0-9]([0-9][1-9]|[1-9]0)|[1-9]00)|[1-9]000)(-(0[1-9]|1[0-2])(-(0[1-9]|[1-2][0-9]|3[0-1]))?)?)$")

(define px:time #px"^(?:([01][0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)(\\.[0-9]{1,9})?)$")

(define px:dateTime
  #px"^(?:([0-9]([0-9]([0-9][1-9]|[1-9]0)|[1-9]00)|[1-9]000)(-(0[1-9]|1[0-2])(-(0[1-9]|[1-2][0-9]|3[0-1])(T([01][0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)(\\.[0-9]{1,9})?(Z|(\\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00)))?)?)?)$")

(define px:instant
  #px"^(?:([0-9]([0-9]([0-9][1-9]|[1-9]0)|[1-9]00)|[1-9]000)-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])T([01][0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)(\\.[0-9]{1,9})?(Z|(\\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00)))$")

;; ── living examples: one accepted + one rejected lexeme per pattern ──────────────────────────
(module+ test
  (require rackunit)
  (define (ok? px s) (regexp-match? px s))
  ;; the character passes decide exactly what the regexps decide: every string of up to five
  ;; characters over an alphabet of letters and every kind of space (ASCII white space, a
  ;; vertical tab and a no-break space, which `\s` does not match)
  (define alphabet (list #\a #\. #\space #\tab #\newline #\page #\return #\vtab #\u00A0))
  (define (strings n) (if (zero? n) '("") (for*/list ([s (in-list (strings (sub1 n)))] [c (in-list alphabet)]) (string-append s (string c)))))
  (for* ([n (in-range 0 6)] [s (in-list (strings n))] [px (in-list (list px:uri px:url px:canonical px:code))])
    (unless (eq? (pattern-matches? px s) (regexp-match? px s))
      (fail (format "~s: the pass says ~a, ~a says ~a" s (pattern-matches? px s) px (regexp-match? px s)))))
  (check-true (pattern-matches? px:uri "http://loinc.org"))
  (check-false (pattern-matches? px:uri "http://loinc.org "))
  (check-true (pattern-matches? px:code "final"))
  (check-false (pattern-matches? px:code "a  b"))
  (check-true (pattern-matches? px:id "patient-01"))    ; any other pattern is the regexp's
  (check-true  (ok? px:id "patient-01"))       (check-false (ok? px:id "has space"))
  (check-true  (ok? px:code "a b"))            (check-false (ok? px:code " leading"))
  (check-true  (ok? px:oid "urn:oid:2.16.840")) (check-false (ok? px:oid "2.16.840"))
  (check-true  (ok? px:uuid "urn:uuid:c757873d-ec9a-4326-a141-556f43239520"))
  (check-false (ok? px:uuid "c757873d-ec9a-4326-a141-556f43239520"))
  (check-true  (ok? px:boolean "true"))        (check-false (ok? px:boolean "True"))
  (check-true  (ok? px:integer "-12"))         (check-false (ok? px:integer "012"))
  (check-true  (ok? px:positiveInt "1"))       (check-false (ok? px:positiveInt "0"))
  (check-true  (ok? px:unsignedInt "0"))       (check-false (ok? px:unsignedInt "-1"))
  (check-true  (ok? px:decimal "-3.14"))       (check-false (ok? px:decimal "1."))
  (check-true  (ok? px:base64Binary "QUJD"))   (check-false (ok? px:base64Binary "not base64!"))
  ;; temporal: variable precision is legal; out-of-range components are not
  (check-true  (ok? px:date "1974"))
  (check-true  (ok? px:date "1974-12-25"))     (check-false (ok? px:date "1974-13-01"))
  (check-true  (ok? px:time "23:59:60"))       (check-false (ok? px:time "24:00:00"))
  (check-true  (ok? px:dateTime "2015-02-07T13:28:17-05:00"))
  (check-false (ok? px:dateTime "2015-02-07T13:28:17"))    ; time REQUIRES a timezone
  (check-true  (ok? px:instant "2015-02-07T13:28:17.239+02:00"))
  (check-false (ok? px:instant "2015-02-07"))              ; instant requires full precision
  ;; string-like: exactly the spec's ^[\s\S]+$ — any non-empty value, whitespace and newlines too
  (for ([px (list px:string px:markdown px:xhtml)])
    (check-false (ok? px ""))
    (for ([s (list "a" " " "\n" "line one\nline two" (make-string 5000 #\x))])
      (check-true (ok? px s))
      (check-equal? (ok? px s) (regexp-match? #px"^(?:[\\s\\S])+$" s)))))
