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
         px:date px:time px:dateTime px:instant)

;; --- string-like ----------------------------------------------------
;; string / markdown: any non-empty sequence (length cap enforced separately).
(define px:string   #px"^(?:[\\s\\S])+$")
(define px:markdown #px"^(?:[\\s\\S])+$")
;; xhtml: validated structurally elsewhere; accept any non-empty here.
(define px:xhtml    #px"^(?:[\\s\\S])+$")

(define px:id        #px"^(?:[A-Za-z0-9\\-\\.]{1,64})$")
(define px:code      #px"^(?:[^\\s]+(?: [^\\s]+)*)$")
(define px:uri       #px"^(?:\\S*)$")
(define px:url       #px"^(?:\\S*)$")
(define px:canonical #px"^(?:\\S*)$")
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
  (check-false (ok? px:instant "2015-02-07")))             ; instant requires full precision
