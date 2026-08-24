#lang racket/base

;;; leaf.rkt — reading LEAF values off typed nodes.
;;;
;;; The tiny vocabulary every node consumer (store indexing, view evaluation, operation handlers)
;;; kept re-inventing, defined once:
;;;   pv        : a primitive newtype -> its value; anything else passes through
;;;   listify   : a repeating field read -> always a list (fhir-ref returns a bare value for 0..1)
;;;   node-str  : node.field -> its leaf rendered as a string, or #f when absent
;;;
;;; Deliberately model-layer only (no fhirpath dependency): callers that need the full
;;; System-value collapse (moments, quantities) use fhirpath/value's item->system instead.

(require racket/contract
         (only-in "node.rkt" fhir? fhir-ref)
         (only-in "base.rkt" primitive-type? primitive-type-value))

(provide
 (contract-out
  [pv       (-> any/c any/c)]
  [listify  (-> any/c list?)]
  [node-str (-> fhir? symbol? (or/c string? #f))]))

(define (pv x) (if (primitive-type? x) (primitive-type-value x) x))

(define (listify v) (if (list? v) v (list v)))

(define (node-str n key)
  (define v (fhir-ref n key #f))
  (and v (format "~a" (pv v))))

(module+ test
  (require rackunit
           (only-in "node.rkt" fhir)
           (only-in "../primitives/primitives.rkt" make-string)
           (only-in "../result/result.rkt" ok-value))
  (define s (ok-value (make-string "hello")))
  (check-equal? (pv s) "hello")
  (check-equal? (pv 42) 42)                       ; non-primitives pass through
  (check-equal? (listify '(1 2)) '(1 2))
  (check-equal? (listify 1) '(1))
  (define n (fhir 'Demo (hasheq 'name s)))
  (check-equal? (node-str n 'name) "hello")
  (check-false (node-str n 'missing)))
