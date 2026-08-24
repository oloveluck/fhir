#lang racket/base

;;; kit.rkt — the shared runtime for the JSON-tower langs (#lang fhir/r6, fhir/r4, and the
;;; foundation module language).
;;;
;;; A lang's reader wraps each top-level form as (fhir-resource-form <form>); each form expands —
;;; via its generated type macro (build-fhir-form) — to a typed `fhir` node. This kit's
;;; #%module-begin collects the nodes into `resources`, provides `->nodes` (the typed values) and
;;; `->json` (their jsexpr serialization), and — run directly — prints each resource as JSON.

(require (for-syntax racket/base syntax/parse)
         (only-in json jsexpr->string)
         (only-in "../serialize/to-json.rkt" node->jsexpr))

(provide (rename-out [kit-module-begin #%module-begin])
         (except-out (all-from-out racket/base) #%module-begin)
         fhir-resource-form
         node->jsexpr)

;; the reader's top-level wrapper: expands to the form itself (its type macro builds the node).
(define-syntax (fhir-resource-form stx)
  (syntax-parse stx
    [(_ (type . rest)) #'(type . rest)]))

(define-syntax (kit-module-begin stx)
  (syntax-parse stx
    [(_ form ...)
     #'(#%module-begin
        (define resources (list form ...))            ; each form -> a typed `fhir` node
        (define (->nodes) resources)
        (define (->json) (map node->jsexpr resources)) ; the derived JSON view
        (provide resources ->nodes ->json)
        (module+ main
          (for ([n (in-list resources)]) (displayln (jsexpr->string (node->jsexpr n))))))]))
