#lang racket/base

;;; module-begin.rkt — the custom #%module-begin for #lang fhir/capability.
;;;
;;; It PARTITIONS the module's top-level forms into declaration clauses (server / resource /
;;; operation) versus pass-through Racket code (require/define — the handler procedures and the
;;; repository values), validates and parses the declarations at the transformer phase (see
;;; declare.rkt), and emits ONE #%module-begin body: all pass-through forms verbatim, then the derived
;;; CapabilityStatement + OperationDefinitions + the assembled `app`, then the provides and a `main`
;;; that prints /metadata. Because everything lands in one module body with the app defines emitted
;;; last, the declarations' references to handler/repository identifiers resolve regardless of source
;;; order (constraint: a handler must not depend on `app`).

(require (for-syntax racket/base
                     syntax/parse
                     racket/list
                     "declare.rkt"
                     fhir/r6/types)             ; populate the phase-1 registry for validation
         ;; runtime bindings the emitted template references (resolve at the user module's phase 0)
         (only-in "derive.rkt" derive-capability-statement derive-operation-definition)
         (only-in "runtime.rkt" build-app)
         (only-in json jsexpr->string)
         (only-in "../serialize/to-json.rkt" node->jsexpr))

(provide app-module-begin)

(begin-for-syntax
  (define (decl-head stx)
    (syntax-parse stx
      [((~datum server) . _)    'server]
      [((~datum resource) . _)  'resource]
      [((~datum operation) . _) 'operation]
      [_ #f])))

(define-syntax (app-module-begin stx)
  (syntax-parse stx
    [(_ form ...)
     (define forms (syntax->list #'(form ...)))
     ;; 1. partition, preserving source order for pass-through forms
     (define-values (servers resources operations passthru)
       (for/fold ([sv '()] [rs '()] [op '()] [pt '()]
                  #:result (values (reverse sv) (reverse rs) (reverse op) (reverse pt)))
                 ([f (in-list forms)])
         (case (decl-head f)
           [(server)    (values (cons f sv) rs op pt)]
           [(resource)  (values sv (cons f rs) op pt)]
           [(operation) (values sv rs (cons f op) pt)]
           [else        (values sv rs op (cons f pt))])))
     ;; 2. exactly one server
     (when (null? servers) (raise-syntax-error 'capability "a (server …) declaration is required" stx))
     (unless (null? (cdr servers))
       (raise-syntax-error 'capability "only one (server …) declaration is allowed" (cadr servers)))
     ;; 3. parse + validate declarations -> runtime construction syntax
     (define server-stx (parse-server (car servers)))
     (define-values (resource-stxs repo-pair-stxs)
       (for/lists (rs ps) ([r (in-list resources)]) (parse-resource r)))
     (define-values (operation-stxs entry-lists)
       (for/lists (os es) ([o (in-list operations)]) (parse-operation o)))
     (define op-entry-stxs (append* entry-lists))
     ;; 4. emit one module body
     #`(#%module-begin
        #,@passthru
        (define capability-statement
          (derive-capability-statement #,server-stx
                                       (list #,@resource-stxs)
                                       (list #,@operation-stxs)))
        (define operation-definitions
          (list #,@(for/list ([o (in-list operation-stxs)]) #`(derive-operation-definition #,o))))
        (define app
          (build-app #:capability capability-statement
                     #:operation-definitions operation-definitions
                     #:repositories (list #,@repo-pair-stxs)
                     #:operations (list #,@op-entry-stxs)))
        (provide app capability-statement operation-definitions)
        (module+ main
          (displayln (jsexpr->string (node->jsexpr capability-statement)))))]))
