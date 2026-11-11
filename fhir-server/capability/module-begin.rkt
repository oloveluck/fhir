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
                     (only-in racket/string string-join)
                     "declare.rkt"
                     fhir/r6/types)             ; populate the phase-1 registry for validation
         ;; runtime bindings the emitted template references (resolve at the user module's phase 0)
         (only-in "derive.rkt" derive-capability-statement derive-operation-definition)
         (only-in "runtime.rkt" build-app current-repository-factory with-declared-locations r6-sd-packages)
         (only-in "store.rkt" store-file-factory temporary-store-factory)
         (only-in fhir/serialize/fhir-json fhir-json->string)
         (only-in fhir/serialize/to-json node->jsexpr))

(provide app-module-begin)

(begin-for-syntax
  (define (decl-head stx)
    (syntax-parse stx
      [((~datum server) . _)    'server]
      [((~datum resource) . _)  'resource]
      [((~datum operation) . _) 'operation]
      [_ #f])))

;; server-option : (server …) syntax keyword -> string | #f   a string option the module reads itself
(define-for-syntax (server-option stx kw)
  (let loop ([xs (cdr (syntax->list stx))])
    (cond [(or (null? xs) (null? (cdr xs))) #f]
          [(and (eq? (syntax-e (car xs)) kw) (string? (syntax-e (cadr xs)))) (syntax-e (cadr xs))]
          [else (loop (cdr xs))])))
;; server-store : (server …) syntax -> string | #f   its #:store file
(define-for-syntax (server-store stx) (server-option stx '#:store))

;; search-param-problems : (listof resource-syntax) -> (listof string)   the search parameters FHIR does
;; not define (or types otherwise), decided from the core package — normally when the app is built;
;; here too when other declarations already fail, so a file's mistakes are said at once (a misspelt
;; `birthDate` showed only after a bad parameter type was fixed). Undecidable (no package): none.
(define-for-syntax (search-param-problems resources)
  (with-handlers ([exn:fail? (lambda (_) '())])
    (define with-declared (dynamic-require 'fhir/capability/store 'with-declared))
    (define catalog ((dynamic-require 'fhir/capability/store 'core-search-params)))
    (define declaration? (dynamic-require 'fhir/capability/runtime 'exn:fail:declaration?))
    (for*/list ([r (in-list resources)]
                [items (in-value (syntax->list r))]
                #:when (and items (>= (length items) 2) (symbol? (syntax-e (cadr items))))
                [type (in-value (syntax-e (cadr items)))]
                [sps (in-value (let loop ([xs (cddr items)])
                                 (cond [(or (null? xs) (null? (cdr xs))) '()]
                                       [(eq? (syntax-e (car xs)) '#:search-params)
                                        ;; a type that is no search-parameter type is already an error of
                                        ;; its own: said once (`tokn` was reported twice)
                                        (for/list ([p (in-list (or (syntax->list (cadr xs)) '()))]
                                                   #:when (let ([l (syntax->list p)])
                                                            (and l (>= (length l) 2)
                                                                 (memq (syntax-e (cadr l)) '(number date string token reference composite quantity uri special)))))
                                          (define l (map syntax->datum (syntax->list p)))
                                          (list (car l) (cadr l) (and (pair? (cddr l)) (caddr l))))]
                                       [else (loop (cdr xs))])))]
                [msg (in-value (with-handlers ([declaration? exn-message] [exn:fail? (lambda (_) #f)])
                                 (with-declared catalog type sps) #f))]
                #:when msg)
      ;; positioned as the other declaration errors are (srcloc->string: relative to the directory)
      (format "~a: resource ~a: ~a"
              (srcloc->string (srcloc (syntax-source r) (syntax-line r) (syntax-column r) (syntax-position r) (syntax-span r)))
              type msg))))

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
     (when (null? servers) (decl-error 'capability "a (server …) declaration is required" stx))
     (unless (null? (cdr servers))
       (decl-error 'capability "only one (server …) declaration is allowed" (cadr servers)))
     ;; 3. parse + validate declarations -> runtime construction syntax
     ;; every declaration is checked before any error is raised: a file with a bad parameter type
     ;; and a bad interaction says both, one line each, at their forms (`collected`)
     (define problems '())
     (define (collected thunk fallback)
       (with-handlers ([exn:fail:user? (lambda (e) (set! problems (cons (exn-message e) problems)) (fallback))])
         (thunk)))
     (define server-stx (collected (lambda () (parse-server (car servers))) (lambda () #'#f)))
     ;; (server #:store "fhir.db"): the resources without a repository live in that SQLite file,
     ;; beside the module (a factory set outside — `serve --store`, a workspace — takes precedence)
     (define store-file (server-store (car servers)))
     (define-values (resource-stxs repo-pair-stxs)
       (for/lists (rs ps) ([r (in-list resources)])
         (collected (lambda () (parse-resource r)) (lambda () (values #'#f #'#f)))))
     (define parsed (for/list ([o (in-list operations)]) (collected (lambda () (parse-operation o)) (lambda () #f))))
     (unless (null? problems)
       (raise (exn:fail:user (string-join (append (reverse problems) (search-param-problems resources)) "\n")
                             (current-continuation-marks))))
     ;; where each resource is declared, so an error found when the app is built (a search parameter
     ;; FHIR does not define, which needs the core package to decide) is said at its form
     (define resource-locs
       (for/list ([r (in-list resources)])
         (define t (syntax-case r () [(_ type . _) (syntax-e #'type)]))
         #`(cons '#,t #,(format "~a:~a:~a" (let ([s (syntax-source r)]) (if (path? s) (let-values ([(d n _) (split-path s)]) (path->string n)) (format "~a" s)))
                                 (syntax-line r) (syntax-column r)))))
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
                                    ;; no store anywhere: a temporary one, removed when the process ends
                                    #'(temporary-store-factory)))])
            (with-declared-locations (list #,@resource-locs) (lambda ()
            (build-app #:capability capability-statement
                       #:operation-definitions operation-definitions
                       #:repositories (list #,@repo-pair-stxs)
                       #:operations (append #,@entry-list-stxs)
                       #:metadata #,(let ([h (server-option (car servers) '#:search-handling)])
                                      (if h
                                          #`(hasheq 'search-handling #,h 'sd-packages (r6-sd-packages))
                                          #'(hasheq 'sd-packages (r6-sd-packages)))))))))
        (provide app capability-statement operation-definitions #,@op-names)
        (module+ main
          (displayln (fhir-json->string (node->jsexpr capability-statement) #:indent 2))))]))
