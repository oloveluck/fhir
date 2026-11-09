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
         (only-in "runtime.rkt" build-app current-repository-factory)
         (only-in "store.rkt" store-file-factory)
         (only-in json jsexpr->string)
         (only-in fhir/serialize/to-json node->jsexpr))

(provide app-module-begin)

(begin-for-syntax
  (define (decl-head stx)
    (syntax-parse stx
      [((~datum server) . _)    'server]
      [((~datum resource) . _)  'resource]
      [((~datum operation) . _) 'operation]
      [_ #f])))

;; server-store : (server …) syntax -> string | #f   its #:store file
(define-for-syntax (server-store stx)
  (let loop ([xs (cdr (syntax->list stx))])
    (cond [(or (null? xs) (null? (cdr xs))) #f]
          [(and (eq? (syntax-e (car xs)) '#:store) (string? (syntax-e (cadr xs)))) (syntax-e (cadr xs))]
          [else (loop (cdr xs))])))

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
     ;; (server #:store "fhir.db"): the resources without a repository live in that SQLite file,
     ;; beside the module (a factory set outside — `serve --store`, a workspace — takes precedence)
     (define store-file (server-store (car servers)))
     (define-values (resource-stxs repo-pair-stxs)
       (for/lists (rs ps) ([r (in-list resources)]) (parse-resource r)))
     (define parsed (map parse-operation operations))
     (define operation-stxs (map parsed-operation-rc parsed))
     (define od-stxs (map parsed-operation-od parsed))
     (define entry-list-stxs (map parsed-operation-entries parsed))
     ;; inline declarations are also operation VALUES: defined, registered, provided
     (define op-defines (filter values (map parsed-operation-definition parsed)))
     (define op-names (map (lambda (d) (syntax-case d () [(_ name . _) #'name])) op-defines))
     ;; 4. emit one module body
     #`(#%module-begin
        #,@passthru
        (define capability-statement
          (derive-capability-statement #,server-stx
                                       (list #,@resource-stxs)
                                       (list #,@operation-stxs)))
        (define operation-definitions (list #,@od-stxs))
        #,@op-defines
        (define app
          (parameterize ([current-repository-factory
                          (or (current-repository-factory)
                              #,(if store-file
                                    #`(store-file-factory
                                       (let ([src (variable-reference->module-source (#%variable-reference))])
                                         (if (path? src)
                                             (let-values ([(dir name dir?) (split-path src)]) (build-path dir #,store-file))
                                             #,store-file)))
                                    #'#f))])
            (build-app #:capability capability-statement
                       #:operation-definitions operation-definitions
                       #:repositories (list #,@repo-pair-stxs)
                       #:operations (append #,@entry-list-stxs))))
        (provide app capability-statement operation-definitions #,@op-names)
        (module+ main
          (displayln (jsexpr->string (node->jsexpr capability-statement)))))]))
