#lang racket/base

;;; jsexpr-util.rkt — small shared helpers for building FHIR jsexprs.

(require racket/contract)
(provide (contract-out [drop-false (-> hash? hash?)]))

;; drop keys whose value is #f — the idiom for omitting absent optional FHIR fields when assembling a
;; jsexpr with a fixed hasheq literal. (Note: keeps empty lists; callers that also drop '() handle it.)
(define (drop-false h)
  (for/hasheq ([(k v) (in-hash h)] #:when v) (values k v)))
