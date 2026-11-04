#lang racket/base

;;; jsexpr-util.rkt — small shared helpers for building and reading FHIR jsexprs: the family's
;;; readers of raw resources (the SD index, logical models, the terminology service, StructureMaps)
;;; all read "a field that may be absent, of a value that may not be the shape expected" the same way.

(require racket/contract)
(provide (contract-out
          [drop-false (-> hash? hash?)]
          ;; jref : jsexpr key [default] -> value   a field of an object, the default when the value
          ;; is not an object or lacks the key (a lenient read: raw resources are untrusted shapes)
          [jref (->* (any/c symbol?) (any/c) any/c)]
          ;; jlist : jsexpr key -> list   a repeating field, '() when absent or not a list
          [jlist (-> any/c symbol? list?)]))

(define (jref h k [d #f]) (if (hash? h) (hash-ref h k d) d))
(define (jlist h k) (let ([v (jref h k '())]) (if (list? v) v '())))

;; drop keys whose value is #f — the idiom for omitting absent optional FHIR fields when assembling a
;; jsexpr with a fixed hasheq literal. (Note: keeps empty lists; callers that also drop '() handle it.)
(define (drop-false h)
  (for/hasheq ([(k v) (in-hash h)] #:when v) (values k v)))

(module+ test
  (require rackunit)
  (check-equal? (jref (hasheq 'a 1) 'a) 1)
  (check-equal? (jref (hasheq 'a 1) 'b 'none) 'none)
  (check-equal? (jref "not an object" 'a 0) 0)
  (check-equal? (jlist (hasheq 'xs (list 1 2)) 'xs) '(1 2))
  (check-equal? (jlist (hasheq 'xs "one") 'xs) '())
  (check-equal? (jlist #f 'xs) '())
  (check-equal? (drop-false (hasheq 'a 1 'b #f)) (hasheq 'a 1)))
