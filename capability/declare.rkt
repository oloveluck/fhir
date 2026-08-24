#lang racket/base

;;; declare.rkt — compile-time parsing + validation of the capability declaration forms.
;;;
;;; These procedures run at the transformer phase (module-begin.rkt requires this module
;;; `for-syntax`, and separately requires `fhir/r6/types` `for-syntax` so the type registry is
;;; populated when `type-registered?`/`primitive-name?` are consulted here). Each `parse-*` validates
;;; one declaration clause and RETURNS SYNTAX that, at runtime, constructs the corresponding derive
;;; spec (rc-server/rc-resource/rc-operation) and app entry (a repository pair / operation-entry).
;;; Load-bearing identifiers the user wrote (the #:repository value, the #:handler proc) are spliced
;;; through verbatim so they resolve at phase 0 against the user's own `define`s.

(require racket/base
         ;; identifiers emitted into the generated (user phase-0) code must be for-template here
         (for-template racket/base
                       (only-in "derive.rkt" rc-server rc-resource rc-operation rc-param)
                       (only-in "runtime.rkt" operation-entry make-default-repository))
         syntax/parse
         racket/list
         (only-in "../model/registry.rkt" type-registered? primitive-name?)
         (only-in "../r6/fhir-version.rkt" fhir-version)
         (only-in "interaction-codes.rkt"
                  type-interaction? system-interaction? search-param-type?))

(provide parse-server parse-resource parse-operation)

;; ---- (server …) -----------------------------------------------------------------------------
;; -> syntax constructing an rc-server value
(define (parse-server stx)
  (syntax-parse stx
    [(_ (~alt (~optional (~seq #:mode mode:str))
              (~optional (~seq #:status status:str))
              (~optional (~seq #:fhir-version fv:str))
              (~optional (~seq #:date date:str))
              (~optional (~seq #:url url:str))
              (~optional (~seq #:format fmt:str ...))) ...)
     (define mode-v (if (attribute mode) (syntax-e #'mode) "server"))
     (unless (member mode-v '("server" "client"))
       (raise-syntax-error 'server (format "#:mode must be \"server\" or \"client\", got ~s" mode-v)
                           (or (attribute mode) stx)))
     (define fmts (if (attribute fmt) (syntax->datum #'(fmt ...)) '("application/fhir+json")))
     #`(rc-server #,mode-v
                  #,(if (attribute status) (syntax-e #'status) "active")
                  #,(if (attribute date) (syntax-e #'date) "2025-01-01T00:00:00Z")
                  #,(if (attribute fv) (syntax-e #'fv) fhir-version)
                  (list #,@fmts)
                  #,(if (attribute url) (syntax-e #'url) #f))]))

;; ---- (resource Type …) ----------------------------------------------------------------------
;; -> (values rc-resource-stx  repo-pair-stx)
(define (parse-resource stx)
  (syntax-parse stx
    [(_ type:id
        (~alt (~once (~seq #:interactions (i:id ...)))
              (~optional (~seq #:search-params (sp ...)))
              (~optional (~seq #:repository repo))
              (~optional (~seq #:profile profile:str))) ...)
     (define tsym (syntax-e #'type))
     (unless (type-registered? tsym)
       (raise-syntax-error 'resource (format "unknown resource type ~a" tsym) #'type))
     (define interactions (syntax->list #'(i ...)))
     (for ([ix (in-list interactions)])
       (define code (syntax-e ix))
       (unless (or (type-interaction? code) (system-interaction? code))
         (raise-syntax-error 'resource (format "unknown restful interaction ~a" code) ix)))
     ;; each search-param is [name type] or [name type "fhirpath-expression"]
     (define sp-triples
       (for/list ([s (in-list (if (attribute sp) (syntax->list #'(sp ...)) '()))])
         (syntax-parse s
           [(sp-name:id sp-type:id (~optional sp-expr:str))
            (unless (search-param-type? (syntax-e #'sp-type))
              (raise-syntax-error 'resource (format "unknown search-param type ~a" (syntax-e #'sp-type)) #'sp-type))
            #`(list '#,#'sp-name '#,#'sp-type #,(if (attribute sp-expr) (syntax-e #'sp-expr) #f))]
           [_ (raise-syntax-error 'resource "search-param must be [name type] or [name type \"expr\"]" s)])))
     (define interactions-stx #`(list #,@(for/list ([ix (in-list interactions)]) #`'#,ix)))
     (define sps-stx #`(list #,@sp-triples))
     ;; #:repository is optional — default to a generic in-memory repository built from the declaration
     (define repo-expr
       (if (attribute repo) #'repo #`(make-default-repository '#,#'type #,interactions-stx #,sps-stx)))
     (values
      #`(rc-resource '#,#'type #,interactions-stx #,sps-stx
                     #,(if (attribute profile) (syntax-e #'profile) #f))
      #`(cons '#,#'type #,repo-expr))]))

;; ---- (operation $name …) --------------------------------------------------------------------
;; -> (values rc-operation-stx  (listof operation-entry-stx))
(define (parse-operation stx)
  (syntax-parse stx
    [(_ name:id
        (~alt (~optional (~seq #:on on:id))
              (~optional (~and sysflag #:system))
              (~optional (~seq #:level (lvl:id ...)))
              (~optional (~seq #:in in-spec))
              (~optional (~seq #:out out-spec))
              (~once (~seq #:handler handler))) ...)
     (define raw (symbol->string (syntax-e #'name)))
     (define code (if (and (> (string-length raw) 0) (char=? (string-ref raw 0) #\$))
                      (substring raw 1) raw))
     (define display (string-append "$" code))
     (define on-type (and (attribute on) (syntax-e #'on)))
     (when (and on-type (not (type-registered? on-type)))
       (raise-syntax-error 'operation (format "unknown resource type ~a" on-type) #'on))
     ;; resolve invocation levels
     (define declared-levels (and (attribute lvl) (map syntax-e (syntax->list #'(lvl ...)))))
     (define system? (or (and (attribute sysflag) #t)
                         (and declared-levels (and (memq 'system declared-levels) #t))))
     (define type? (cond [declared-levels (and (memq 'type declared-levels) #t)]
                         [on-type #t] [else #f]))
     (define instance? (and declared-levels (and (memq 'instance declared-levels) #t)))
     (unless (or system? type? instance?)
       (raise-syntax-error 'operation "no invocation level (need #:on, #:system, or #:level)" stx))
     (define resource-types (if on-type (list (symbol->string on-type)) '()))
     (define in-params  (parse-params (attribute in-spec) "in"))
     (define out-params (parse-params (attribute out-spec) "out"))
     (define target-stx (if on-type (symbol->string on-type) #f))
     (define entries
       (append
        (if system?   (list #`(operation-entry 'system   #,code #f handler)) '())
        (if type?     (list #`(operation-entry 'type     #,code #,target-stx handler)) '())
        (if instance? (list #`(operation-entry 'instance #,code #,target-stx handler)) '())))
     (values
      #`(rc-operation #,code #,display (list #,system? #,type? #,instance?)
                      (list #,@(map (lambda (s) #`#,s) resource-types))
                      (list #,@in-params) (list #,@out-params) #f)
      entries)]))

;; parse a #:in/#:out spec (a syntax list of [name type min max]) into rc-param constructor syntaxes
(define (parse-params spec use)
  (cond
    [(not spec) '()]
    [else
     (for/list ([p (in-list (syntax->list spec))])
       (syntax-parse p
         [(pname:id ptype:id pmin:nat pmax)
          (define tsym (syntax-e #'ptype))
          (unless (or (type-registered? tsym) (primitive-name? tsym))
            (raise-syntax-error 'operation (format "unknown parameter type ~a" tsym) #'ptype))
          (define minv (syntax-e #'pmin))
          (define maxv (syntax-parse #'pmax [n:nat (syntax-e #'n)] [(~datum *) '*] [_ #f]))
          (unless maxv
            (raise-syntax-error 'operation "parameter max must be a nonneg integer or *" #'pmax))
          (when (and (number? maxv) (< maxv minv))
            (raise-syntax-error 'operation (format "parameter max ~a < min ~a" maxv minv) p))
          #`(rc-param #,(symbol->string (syntax-e #'pname))
                      #,(symbol->string tsym)
                      #,minv
                      #,(if (eq? maxv '*) #'(quote *) maxv)
                      #,use)]
         [_ (raise-syntax-error 'operation "parameter must be [name type min max]" p)]))]))

(module+ test
  (require rackunit (only-in "../r6/types.rkt"))     ; populate the registry at phase 0 for the test
  ;; parse-server yields an rc-server construction with defaults
  (check-equal? (syntax->datum (parse-server #'(server)))
                '(rc-server "server" "active" "2025-01-01T00:00:00Z" "6.0.0-ballot4"
                            (list "application/fhir+json") #f))
  ;; parse-resource validates the type and interactions
  (define-values (rstx pstx) (parse-resource #'(resource Patient #:interactions (read create)
                                                          #:repository repo)))
  (check-equal? (syntax->datum rstx)
                '(rc-resource 'Patient (list 'read 'create) (list) #f))
  (check-equal? (syntax->datum pstx) '(cons 'Patient repo))
  (check-exn exn:fail:syntax? (lambda () (parse-resource #'(resource Bogus #:interactions (read)
                                                                     #:repository r))))
  (check-exn exn:fail:syntax? (lambda () (parse-resource #'(resource Patient #:interactions (frob)
                                                                     #:repository r))))
  ;; parse-operation yields rc-operation + entries; strips the $; validates param types
  (define-values (ostx entries)
    (parse-operation #'(operation $expand #:on ValueSet #:in ([url uri 1 1])
                                  #:out ([return ValueSet 1 1]) #:handler h)))
  (check-equal? (syntax->datum ostx)
                '(rc-operation "expand" "$expand" (list #f #t #f) (list "ValueSet")
                               (list (rc-param "url" "uri" 1 1 "in"))
                               (list (rc-param "return" "ValueSet" 1 1 "out")) #f))
  (check-equal? (map syntax->datum entries)
                '((operation-entry 'type "expand" "ValueSet" h)))
  (check-exn exn:fail:syntax? (lambda () (parse-operation #'(operation $x #:in ([p NoSuch 1 1])
                                                                       #:handler h)))))
