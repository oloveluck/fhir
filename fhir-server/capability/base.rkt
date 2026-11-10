#lang racket/base

;;; base.rkt — the module language for #lang fhir/capability.
;;;
;;; Installs the custom #%module-begin (which assembles the app from the declarations) and puts in
;;; scope everything a capability module needs: racket/base, the R6 type macros (so handlers can
;;; build/return typed nodes), the runtime (repository/request/dispatch/…), the derive-spec
;;; constructors the generated code calls, and json/serializer helpers for the /metadata `main`.

(require (for-syntax racket/base (only-in fhir/capability/declare decl-error))
         "module-begin.rkt"
         "runtime.rkt"
         "derive.rkt"
         (only-in json jsexpr->string)
         (only-in fhir/serialize/to-json node->jsexpr)
         fhir/r6/types)

(provide (except-out (all-from-out racket/base) #%module-begin)
         (rename-out [app-module-begin #%module-begin])
         (all-from-out "runtime.rkt")
         (all-from-out "derive.rkt")
         (all-from-out fhir/r6/types)
         jsexpr->string node->jsexpr
         server resource operation)

;; Stub bindings so a misplaced declaration (in expression position, not at the module top level
;; where #%module-begin consumes it — or the lone form of a module, which the expander expands
;; before #%module-begin sees it) is a one-line error instead of "unbound identifier".
(define-for-syntax (stray-declaration who s)
  (decl-error who "a declaration of a #lang fhir/capability module, which needs exactly one (server …) declaration at its top level" s))
(define-syntax (server s)    (stray-declaration 'server s))
(define-syntax (resource s)  (stray-declaration 'resource s))
(define-syntax (operation s) (stray-declaration 'operation s))
