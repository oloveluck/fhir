#lang racket/base

;;; result.rkt — the validation Result type and the ValidationError sum type.
;;;
;;; Validation is expected, frequent, and composable, so it is modelled as data
;;; (`ok` / `err`) rather than exceptions. Every error carries the FHIR `spec-url` that
;;; defines the constraint it violated, so failures are self-documenting and tie directly
;;; into the spec-linking registry (model/registry.rkt).

(require racket/match
         racket/list
         racket/contract)

(provide (struct-out ok)
         (struct-out err)
         ;; ValidationError hierarchy (structs exported plain; functions contracted below)
         (struct-out validation-error)
         (struct-out pattern-mismatch)
         (struct-out out-of-range)
         (struct-out length-exceeded)
         (struct-out precision-exceeded)
         (struct-out invalid-encoding)
         (struct-out unknown-field)
         (struct-out missing-field)
         (struct-out multiple)
         (contract-out
          [result?                  (-> any/c boolean?)]
          [result-map               (-> (-> any/c any/c) result? result?)]
          [result-bind              (-> result? (-> any/c result?) result?)]
          [result-traverse          (->* ((listof result?)) (#:accumulate? boolean?) result?)]
          [ok-or-raise              (-> result? any/c)]
          [validation-error-message (-> validation-error? string?)]))

;; -------------------------------------------------------------------
;; Result
;; -------------------------------------------------------------------

(struct ok  (value) #:transparent)
(struct err (error) #:transparent)

(define (result? x) (or (ok? x) (err? x)))

;; (a -> b) -> Result a -> Result b
(define (result-map f r)
  (match r
    [(ok v) (ok (f v))]
    [(err _) r]))

;; (a -> Result b) -> Result a -> Result b
(define (result-bind r f)
  (match r
    [(ok v) (f v)]
    [(err _) r]))

;; (listof (Result a)) -> Result (listof a)
;; #:accumulate? #f  => first error short-circuits
;; #:accumulate? #t  => collect every error into a `multiple`
(define (result-traverse rs #:accumulate? [accumulate? #f])
  (cond
    [accumulate?
     (define errors (for/list ([r (in-list rs)] #:when (err? r)) (err-error r)))
     (cond
       [(null? errors) (ok (map ok-value rs))]
       [(null? (cdr errors)) (err (car errors))]
       [else (err (multiple/type errors))])]
    [else
     (let loop ([rs rs] [acc '()])
       (match rs
         ['() (ok (reverse acc))]
         [(cons (ok v) rest) (loop rest (cons v acc))]
         [(cons (? err? e) _) e]))]))

;; Escape hatch for call sites that want to assert validity (tests, literals, node-build).
(define (ok-or-raise r)
  (match r
    [(ok v) v]
    [(err e) (error 'fhir (validation-error-message e))]))

;; -------------------------------------------------------------------
;; ValidationError sum type
;; -------------------------------------------------------------------
;; Base carries the FHIR type name and the spec URL that defines the constraint.

(struct validation-error (type spec-url) #:transparent)

(struct pattern-mismatch   validation-error (value regex) #:transparent)
(struct out-of-range       validation-error (value lo hi) #:transparent)
(struct length-exceeded    validation-error (value max)   #:transparent)
(struct precision-exceeded validation-error (value max)   #:transparent)
(struct invalid-encoding   validation-error (value)       #:transparent)
(struct unknown-field      validation-error (field)       #:transparent)
(struct missing-field      validation-error (field)       #:transparent)
(struct multiple           validation-error (errors)      #:transparent)
;; `multiple` reuses the base fields loosely: type='multiple, spec-url=#f.

(define (validation-error-message e)
  (match e
    [(pattern-mismatch t url v rx)
     (format "~a: ~s does not match ~a (see ~a)" t v (object-name rx) url)]
    [(out-of-range t url v lo hi)
     (format "~a: ~s out of range [~a, ~a] (see ~a)" t v lo hi url)]
    [(length-exceeded t url v mx)
     (format "~a: length ~a exceeds max ~a (see ~a)"
             t (if (string? v) (string-length v) v) mx url)]
    [(precision-exceeded t url v mx)
     (format "~a: precision of ~s exceeds max ~a (see ~a)" t v mx url)]
    [(invalid-encoding t url v)
     (format "~a: invalid encoding ~s (see ~a)" t v url)]
    [(unknown-field t url f)
     (format "~a: unknown field ~a (see ~a)" t f url)]
    [(missing-field t url f)
     (format "~a: missing required field ~a (see ~a)" t f url)]
    [(multiple _ _ errs)
     (format "multiple errors:\n  ~a"
             (apply string-append
                    (add-between (map validation-error-message errs) "\n  ")))]
    [_ (format "validation error: ~s" e)]))

(define (multiple/type errs) (multiple 'multiple #f errs))

;; ── examples (living documentation; run by `raco test`) ───────────────────────────────────
(module+ test
  (require rackunit)
  (check-equal? (result-map add1 (ok 5))        (ok 6))      ; map over ok
  (check-equal? (result-map add1 (err 'oops))   (err 'oops)) ; err passes through
  (check-equal? (result-bind (ok 5) (lambda (x) (ok (* x 2)))) (ok 10))
  (check-equal? (result-bind (err 'e) (lambda (x) (ok x)))     (err 'e))
  (check-true   (result? (ok 1)))
  (check-false  (result? 1))
  (check-equal? (ok-or-raise (ok 42)) 42)
  (check-equal? (result-traverse (list (ok 1) (ok 2) (ok 3))) (ok '(1 2 3)))
  (check-equal? (result-traverse (list (ok 1) (err 'x) (ok 3))) (err 'x)))
