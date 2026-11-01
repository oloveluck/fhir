#lang racket/base

;;; operation-entry.rkt — the one struct a generated tower's operations.rkt produces.
;;;
;;; `<code>-operation` scaffolds (emitted by codegen into r4/r5/r6/viewdef/omop `operations.rkt`)
;;; return operation-entry values that capability/runtime's `build-app` pairs with their
;;; OperationDefinitions. It lives in the foundation so the generated towers depend only on
;;; fhir; capability/runtime re-exports it.

(provide (struct-out operation-entry))

;; level  : 'system | 'type | 'instance
;; code   : string            the operation code (without `$`)
;; target : (or symbol #f)    the resource type for type/instance-level operations
;; proc   : (in-hash request) -> fhir   the handler
(struct operation-entry (level code target proc) #:transparent)
