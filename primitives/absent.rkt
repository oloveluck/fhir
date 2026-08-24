#lang racket/base

;;; absent.rkt — the sentinel for a value-less primitive.
;;;
;;; FHIR allows a primitive element to carry only `id`/`extension` and no value (JSON: a `_field`
;;; object with no matching value key, or a `null` slot in a primitive array aligned with `_field`).
;;; Such a primitive newtype instance stores `absent` in its value slot. The serializer omits the
;;; main JSON key (or emits `null` in a list) while still writing the `_field` sibling.

(require racket/contract)

(provide absent
         (contract-out [absent? (-> any/c boolean?)]))

;; uninterned, so no datum read from JSON or typed by a user can ever collide with it
(define absent (string->uninterned-symbol "fhir-absent-value"))
(define (absent? x) (eq? x absent))

(module+ test
  (require rackunit)
  (check-true (absent? absent))
  (check-false (absent? 'fhir-absent-value))   ; even the same-named interned symbol is NOT absent
  (check-false (absent? #f)))
