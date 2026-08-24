#lang racket/base

;;; primitives.rkt — the FHIR primitive type system, declared via define-fhir-primitive.
;;;
;;; This is the catalogue. Each entry links to its FHIR spec definition; the macro turns it into a
;;; struct + validating constructor + JSON read/write + registry entry. See
;;; https://build.fhir.org/datatypes.html#primitive
;;;
;;; Underlying representations:
;;;   string-like -> string ;  numeric -> exact integer / real ;  temporal -> t-* struct.

(require racket/contract
         "define-primitive.rkt"
         "patterns.rkt"
         "temporal.rkt"
         "../result/result.rkt"
         "../model/registry.rkt"
         "../model/base.rkt")

;; Re-export the Result type, the spec-linking API, and the precision-aware temporal values, so a
;; single (require fhir/primitives/primitives) is enough to construct and inspect values.
(provide (all-from-out "../result/result.rkt")
         (all-from-out "../model/registry.rkt")
         (all-from-out "temporal.rkt")
         (contract-out
          [primitive->jsexpr (-> primitive-type? (or/c string? boolean? real?))]))

;; --- string-like --------------------------------------------------------------------
(define-fhir-primitive string #:pattern px:string #:length 1048576
  #:spec-url "https://build.fhir.org/datatypes.html#string")
(define-fhir-primitive id #:pattern px:id
  #:spec-url "https://build.fhir.org/datatypes.html#id")
(define-fhir-primitive code #:pattern px:code
  #:spec-url "https://build.fhir.org/datatypes.html#code")
(define-fhir-primitive markdown #:pattern px:markdown #:length 1048576
  #:spec-url "https://build.fhir.org/datatypes.html#markdown")
(define-fhir-primitive uri #:pattern px:uri
  #:spec-url "https://build.fhir.org/datatypes.html#uri")
(define-fhir-primitive url #:pattern px:url
  #:spec-url "https://build.fhir.org/datatypes.html#url")
(define-fhir-primitive canonical #:pattern px:canonical
  #:spec-url "https://build.fhir.org/datatypes.html#canonical")
(define-fhir-primitive oid #:pattern px:oid
  #:spec-url "https://build.fhir.org/datatypes.html#oid")
(define-fhir-primitive uuid #:pattern px:uuid
  #:spec-url "https://build.fhir.org/datatypes.html#uuid")
(define-fhir-primitive base64Binary #:pattern px:base64Binary
  #:spec-url "https://build.fhir.org/datatypes.html#base64Binary")
(define-fhir-primitive xhtml #:pattern px:xhtml
  #:spec-url "https://build.fhir.org/datatypes.html#xhtml")

;; --- numeric ------------------------------------------------------------------------
(define-fhir-primitive boolean #:base boolean?
  #:spec-url "https://build.fhir.org/datatypes.html#boolean")
(define-fhir-primitive integer #:range [-2147483648 2147483647]
  #:spec-url "https://build.fhir.org/datatypes.html#integer")
(define-fhir-primitive integer64 #:range [-9223372036854775808 9223372036854775807]
  #:spec-url "https://build.fhir.org/datatypes.html#integer64")
(define-fhir-primitive positiveInt #:range [1 2147483647]
  #:spec-url "https://build.fhir.org/datatypes.html#positiveInt")
(define-fhir-primitive unsignedInt #:range [0 2147483647]
  #:spec-url "https://build.fhir.org/datatypes.html#unsignedInt")
;; decimal is STRING-backed to preserve precision/trailing zeros (Racket reals lose "1.50" -> 1.5).
;; The lexical form is validated against the spec regex and kept verbatim; the serializer emits it as
;; a raw JSON number token (serialize/to-json.rkt), so precision survives the write path.
(define-fhir-primitive decimal #:pattern px:decimal
  #:spec-url "https://build.fhir.org/datatypes.html#decimal")

;; --- temporal (variable precision) --------------------------------------------------
(define-fhir-primitive date #:parse parse-t-date
  #:spec-url "https://build.fhir.org/datatypes.html#date")
(define-fhir-primitive time #:parse parse-t-time
  #:spec-url "https://build.fhir.org/datatypes.html#time")
(define-fhir-primitive dateTime #:parse parse-t-datetime
  #:spec-url "https://build.fhir.org/datatypes.html#dateTime")
(define-fhir-primitive instant #:parse parse-fhir-instant
  #:spec-url "https://build.fhir.org/datatypes.html#instant")

;; primitive->jsexpr : any primitive-type instance -> its JSON scalar (the structured view).
;; Temporal values render to their lexical form; a decimal (string-backed) becomes a Racket number
;; here (the structured view is lossy on trailing zeros — the precise view is node->json-string);
;; everything else is its scalar value. Dispatches on the value/type, not on a schema.
(define (primitive->jsexpr p)
  (define v (primitive-type-value p))
  (cond
    [(fhir-decimal? p) (string->number v)]
    [(or (t-date? v) (t-time? v) (t-datetime? v)) (temporal->string v)]
    [else v]))

(module+ test
  (require rackunit)
  (check-equal? (make-id "abc") (ok (fhir-id #f '() "abc")))
  (check-true   (err? (make-id "not valid id!")))
  (check-equal? (make-code "male") (ok (fhir-code #f '() "male")))
  (check-true   (err? (make-positiveInt 0)))
  (check-equal? (make-positiveInt 3) (ok (fhir-positiveInt #f '() 3)))
  (check-true   (err? (make-date "1974-13-40")))
  ;; primitive->jsexpr dispatches on the value
  (check-equal? (primitive->jsexpr (ok-or-raise (make-id "abc"))) "abc")
  (check-equal? (primitive->jsexpr (ok-or-raise (make-boolean #t))) #t)
  (check-equal? (primitive->jsexpr (ok-or-raise (make-date "1974-12-25"))) "1974-12-25")
  (check-equal? (primitive->jsexpr (ok-or-raise (make-date "1974"))) "1974")
  ;; registry wiring
  (check-true (procedure? (constructor-of 'code)))
  (check-true (primitive-name? 'dateTime))
  (check-false (primitive-name? 'Patient)))
