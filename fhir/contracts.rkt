#lang racket/base

;;; contracts.rkt — reusable domain contract aliases for the FHIR tower.
;;;
;;; The constraint-schema shapes (the field-spec list, the ftype tagged-vector, a slice
;;; discriminator) each get a single precise name, so every module boundary stays tight without
;;; re-spelling the shape. Contracts guard hot paths too — a tripped contract is a bug.

(require racket/contract
         (only-in json jsexpr?))

(provide jsexpr/c ftype/c component/c discriminator/c)

;; jsexpr/c : a JSON expression (racket/json's jsexpr?) — the derived serialization of a node.
(define jsexpr/c jsexpr?)

;; ftype/c : a field's referenced type, a tagged vector (see model/schema.rkt's Ftype).
;;   #(prim <code>) | #(type <name>) | #(resource) | #(raw) | #(unknown)
(define ftype/c
  (or/c (vector/c 'prim string?)
        (vector/c 'type symbol?)
        (vector/c 'resource)
        (vector/c 'raw)
        (vector/c 'unknown)))

;; component/c : a component identity — the symbol naming a tower layer
;; (a core type like 'Patient or a profile like 'USCorePatientProfile).
(define component/c symbol?)

;; discriminator/c : how a slice distinguishes its members (kept for the profile/IG seam).
(define discriminator/c
  (or/c (cons/c 'url string?)
        (cons/c 'pattern jsexpr/c)
        (cons/c 'exists symbol?)))
