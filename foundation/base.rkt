#lang racket/base

;;; base.rkt — the foundation module language.
;;;
;;; The reusable base that every JSON-tower module language (fhir/r6/main, fhir/r4/main) builds on:
;;; it re-exports racket/base and the kit runtime (#%module-begin + fhir-resource-form + the JSON
;;; view). A tower's main.rkt adds the generated type macros on top of this. Authoring directly in
;;; `#lang fhir/foundation` is valid but empty (no type macros are in scope yet) — it exists so the
;;; base module language is testable on its own.

(require "../kernel/kit.rkt")

(provide (all-from-out "../kernel/kit.rkt"))
