#lang racket/base

;;; base.rkt — the module language for #lang fhir/capability.
;;;
;;; Installs the custom #%module-begin (which assembles the app from the declarations) and puts in
;;; scope everything a capability module needs: racket/base, the R6 type macros (so handlers can
;;; build/return typed nodes), the runtime (repository/request/dispatch/…), the derive-spec
;;; constructors the generated code calls, and json/serializer helpers for the /metadata `main`.

(require (for-syntax racket/base)
         "module-begin.rkt"
         "runtime.rkt"
         "derive.rkt"
         (only-in json jsexpr->string)
         (only-in "../serialize/to-json.rkt" node->jsexpr)
         fhir/r6/types)

(provide (except-out (all-from-out racket/base) #%module-begin)
         (rename-out [app-module-begin #%module-begin])
         (all-from-out "runtime.rkt")
         (all-from-out "derive.rkt")
         (all-from-out fhir/r6/types)
         jsexpr->string node->jsexpr
         server resource operation)

;; Stub bindings so a misplaced declaration (used in expression position, not at the module top
;; level where #%module-begin consumes it) yields a clear error instead of "unbound identifier".
(define-syntax (server s)    (raise-syntax-error 'server    "only valid at capability top level" s))
(define-syntax (resource s)  (raise-syntax-error 'resource  "only valid at capability top level" s))
(define-syntax (operation s) (raise-syntax-error 'operation "only valid at capability top level" s))
