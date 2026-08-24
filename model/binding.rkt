#lang racket/base

;;; binding.rkt — the required-binding expansion registry.
;;;
;;; A generated tower's terminology.rkt registers, per REQUIRED-bound ValueSet it could expand
;;; OFFLINE from its own package (whole-system / enumerated includes only), the set of valid codes.
;;; Two readers:
;;;   - lang-gen/form-syntax (PHASE 1): a literal code in a form whose field carries a required
;;;     binding is checked at COMPILE time — `(gender "florp")` is a syntax error;
;;;   - anything at runtime that wants the same catalogue.
;;; The registry is instantiated per phase; the tower index requires terminology.rkt both normally
;;; and for-syntax so both instantiations are populated. Unregistered urls mean "not offline-
;;; expandable" — every consumer FAILS OPEN on them.

(require racket/contract)

(provide
 (contract-out
  [register-binding-expansion! (-> string? (listof string?) void?)]
  [binding-expansion           (-> string? (or/c #f (hash/c string? boolean?)))]
  [binding-expansion-codes     (-> string? (or/c #f (listof string?)))]))

(define expansions (make-hash))    ; vs-url -> hash code -> #t (set semantics, O(1) member)

(define (register-binding-expansion! url codes)
  (hash-set! expansions url (for/hash ([c (in-list codes)]) (values c #t)))
  (void))

(define (binding-expansion url) (hash-ref expansions url #f))
(define (binding-expansion-codes url)
  (define h (binding-expansion url))
  (and h (sort (hash-keys h) string<?)))

(module+ test
  (require rackunit)
  (register-binding-expansion! "urn:demo-vs" '("a" "b"))
  (check-true (hash-ref (binding-expansion "urn:demo-vs") "a" #f))
  (check-false (hash-ref (binding-expansion "urn:demo-vs") "z" #f))
  (check-equal? (binding-expansion-codes "urn:demo-vs") '("a" "b"))
  (check-false (binding-expansion "urn:not-registered")))   ; unknown -> fail open
