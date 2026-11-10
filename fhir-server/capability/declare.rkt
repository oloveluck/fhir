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

(require racket/base racket/contract
         ;; identifiers emitted into the generated (user phase-0) code must be for-template here
         (for-template racket/base
                       (only-in "derive.rkt" rc-server rc-resource rc-operation rc-param derive-operation-definition)
                       (only-in "runtime.rkt" operation-entry make-default-repository)
                       (only-in fhir/operation operation)
                       (only-in "operations.rkt" operation->rc operation->od operation->entries declared-operation))
         syntax/parse
         racket/list
         (only-in fhir/model/registry type-registered? primitive-name?)
         (only-in fhir/result/result ok? ok-value err-error invalid-encoding? invalid-encoding-value)
         (only-in vcl/compile vcl->valueset)
         (only-in net/uri-codec uri-unreserved-encode)
         (only-in fhir/r6/fhir-version fhir-version)
         (only-in "interaction-codes.rkt"
                  type-interaction? system-interaction? search-param-type?))

(provide
 (struct-out parsed-operation)
 decl-error
 ;; the three declaration forms, each read at expansion time into the runtime expressions the
 ;; module body emits (contracts here run at phase 1, when the module is expanded)
 (contract-out
  ;; (server …) -> the rc-server expression
  [parse-server (-> syntax? syntax?)]
  ;; (resource Type …) -> (values the rc-resource expression, the (cons 'Type repository) expression)
  [parse-resource (-> syntax? (values syntax? syntax?))]
  ;; (operation …) -> a ParsedOperation of expressions
  [parse-operation (-> syntax? parsed-operation?)]))

;; decl-error : who message form [sub-form] -> raises   a declaration's mistake as one line,
;; `file:line:col: who: message`, positioned at the sub-form when given (as raise-syntax-error is)
;; but raised as a user error: `racket app.rkt` and `raco make` print the line, not a stack of
;; this module's frames (`context...: declare.rkt:157 parse-params` was what a new user saw)
(define (decl-error who msg form [sub #f])
  (define at (or sub form))
  (define where (and (syntax-source at)
                     (srcloc->string (srcloc (syntax-source at) (syntax-line at) (syntax-column at) (syntax-position at) (syntax-span at)))))
  (raise (exn:fail:user (if where (format "~a: ~a: ~a" where who msg) (format "~a: ~a" who msg))
                        (current-continuation-marks))))

;; ---- (server …) -----------------------------------------------------------------------------
;; -> syntax constructing an rc-server value
(define (parse-server stx)
  (syntax-parse stx
    [(_ (~alt (~optional (~seq #:mode mode:str))
              (~optional (~seq #:status status:str))
              (~optional (~seq #:fhir-version fv:str))
              (~optional (~seq #:date date:str))
              (~optional (~seq #:url url:str))
              (~optional (~seq #:name name:str))
              (~optional (~seq #:description description:str))
              (~optional (~seq #:store store:str))         ; read by module-begin (server-store)
              (~optional (~seq #:search-handling sh:str))  ; read by module-begin (the app's metadata)
              (~optional (~seq #:format fmt:str ...))) ...)
     (define mode-v (if (attribute mode) (syntax-e #'mode) "server"))
     (unless (member mode-v '("server" "client"))
       (decl-error 'server (format "#:mode must be \"server\" or \"client\", got ~s" mode-v)
                           (or (attribute mode) stx)))
     (when (and (attribute sh) (not (member (syntax-e #'sh) '("strict" "lenient"))))
       (decl-error 'server (format "#:search-handling must be \"strict\" or \"lenient\", got ~s" (syntax-e #'sh)) #'sh))
     (define fmts (if (attribute fmt) (syntax->datum #'(fmt ...)) '("application/fhir+json")))
     #`(rc-server #,mode-v
                  #,(if (attribute status) (syntax-e #'status) "active")
                  #,(if (attribute date) (syntax-e #'date) "2025-01-01T00:00:00Z")
                  #,(if (attribute fv) (syntax-e #'fv) fhir-version)
                  (list #,@fmts)
                  #,(if (attribute url) (syntax-e #'url) #f)
                  #,(if (attribute name) (syntax-e #'name) #f)
                  #,(if (attribute description) (syntax-e #'description) #f))]))

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
       (decl-error 'resource (format "unknown resource type ~a" tsym) #'type))
     (define interactions (syntax->list #'(i ...)))
     (for ([ix (in-list interactions)])
       (define code (syntax-e ix))
       (unless (or (type-interaction? code) (system-interaction? code))
         (decl-error 'resource (format "unknown restful interaction ~a" code) ix)))
     ;; each search-param is [name type] or [name type "fhirpath-expression"]
     (define sp-triples
       (for/list ([s (in-list (if (attribute sp) (syntax->list #'(sp ...)) '()))])
         (syntax-parse s
           [(sp-name:id sp-type:id (~optional sp-expr:str))
            (unless (search-param-type? (syntax-e #'sp-type))
              (decl-error 'resource (format "unknown search-param type ~a" (syntax-e #'sp-type)) #'sp-type))
            #`(list '#,#'sp-name '#,#'sp-type #,(if (attribute sp-expr) (syntax-e #'sp-expr) #f))]
           [_ (decl-error 'resource "search-param must be [name type] or [name type \"expr\"]" s)])))
     (define interactions-stx #`(list #,@(for/list ([ix (in-list interactions)]) #`'#,ix)))
     (define sps-stx #`(list #,@sp-triples))
     ;; #:repository is optional — default to a generic in-memory repository built from the declaration
     (define repo-expr
       (if (attribute repo) #'repo #`(make-default-repository '#,#'type #,interactions-stx #,sps-stx)))
     (values
      #`(rc-resource '#,#'type #,interactions-stx #,sps-stx
                     #,(if (attribute profile) (syntax-e #'profile) #f))
      #`(cons '#,#'type #,repo-expr))]))

;; ---- (operation $name …) / (operation "Type/$code") / (operation op) ------------------------
;; A ParsedOperation is (parsed-operation rc od entries definition): four runtime expressions —
;; the CapabilityStatement entry, the OperationDefinition, the list of operation-entry the app routes,
;; and, for an inline declaration only (else #f), `(define $name …)`: the declared operation as a
;; fhir/operation value — the same handler, applicable in-process (`(apply-operation "$name" …)`,
;; `($name …)`), registered by its canonical and provided by the module — so a pipeline declared
;; here is served AND callable.
;; An existing operation (fhir/operation) — a reference string, or an identifier bound to an operation
;; value — is exposed with its own OperationDefinition; a declaration (with keywords) defines one here.
(struct parsed-operation (rc od entries definition))
(define (parse-operation stx)
  (syntax-parse stx
    [(_ ref:str)
     (parsed-operation #'(operation->rc (operation ref)) #'(operation->od (operation ref)) #'(operation->entries (operation ref)) #f)]
    [(_ op:id)
     (parsed-operation #'(operation->rc op) #'(operation->od op) #'(operation->entries op) #f)]
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
       (decl-error 'operation (format "unknown resource type ~a" on-type) #'on))
     ;; resolve invocation levels
     (define declared-levels (and (attribute lvl) (map syntax-e (syntax->list #'(lvl ...)))))
     (define system? (or (and (attribute sysflag) #t)
                         (and declared-levels (and (memq 'system declared-levels) #t))))
     (define type? (cond [declared-levels (and (memq 'type declared-levels) #t)]
                         [on-type #t] [else #f]))
     (define instance? (and declared-levels (and (memq 'instance declared-levels) #t)))
     (unless (or system? type? instance?)
       (decl-error 'operation "no invocation level (need #:on, #:system, or #:level)" stx))
     (define resource-types (if on-type (list (symbol->string on-type)) '()))
     (define in-params  (parse-params (attribute in-spec) "in"))
     (define out-params (parse-params (attribute out-spec) "out"))
     (define target-stx (if on-type (symbol->string on-type) #f))
     (define entries
       (append
        (if system?   (list #`(operation-entry 'system   #,code #f handler)) '())
        (if type?     (list #`(operation-entry 'type     #,code #,target-stx handler)) '())
        (if instance? (list #`(operation-entry 'instance #,code #,target-stx handler)) '())))
     (define rc #`(rc-operation #,code #,display (list #,system? #,type? #,instance?)
                               (list #,@(map (lambda (s) #`#,s) resource-types))
                               (list #,@in-params) (list #,@out-params) #f))
     (parsed-operation rc #`(derive-operation-definition #,rc) #`(list #,@entries)
                       #`(define name (declared-operation (derive-operation-definition #,rc) handler #,code)))]))

;; parse a #:in/#:out spec (a syntax list of [name type min max]) into rc-param constructor syntaxes
(define (parse-params spec use)
  (cond
    [(not spec) '()]
    [else
     (for/list ([p (in-list (syntax->list spec))])
       (syntax-parse p
         [(pname:id ptype:id pmin:nat pmax (~alt (~optional (~seq #:binding vs:str))
                                                 (~optional (~seq #:documentation doc:str))
                                                 (~optional (~seq #:min lo:number))
                                                 (~optional (~seq #:max hi:number))) ...)
          (define tsym (syntax-e #'ptype))
          (when (and (attribute vs) (not (memq tsym '(code Coding CodeableConcept string uri))))
            (decl-error 'operation "#:binding binds a code (or Coding, CodeableConcept) parameter to a value set" p))
          (when (and (or (attribute lo) (attribute hi)) (not (memq tsym '(integer decimal positiveInt unsignedInt))))
            (decl-error 'operation "#:min and #:max bound a number (an integer or decimal parameter)" p))
          (unless (or (type-registered? tsym) (primitive-name? tsym))
            (decl-error 'operation (format "unknown parameter type ~a" tsym) #'ptype))
          (define minv (syntax-e #'pmin))
          (define maxv (syntax-parse #'pmax [n:nat (syntax-e #'n)] [(~datum *) '*] [_ #f]))
          (unless maxv
            (decl-error 'operation "parameter max must be a nonneg integer or *" #'pmax))
          (when (and (number? maxv) (< maxv minv))
            (decl-error 'operation (format "parameter max ~a < min ~a" maxv minv) p))
          #`(rc-param #,(symbol->string (syntax-e #'pname))
                      #,(symbol->string tsym)
                      #,minv
                      #,(if (eq? maxv '*) #'(quote *) maxv)
                      #,use
                      #,(if (attribute vs) (binding-url (syntax-e #'vs) #'vs) #f)
                      #,(if (attribute doc) #'doc #f)
                      #,(if (attribute lo) #'lo #f)
                      #,(if (attribute hi) #'hi #f))]
         [_ (decl-error 'operation "parameter must be [name type min max], with #:binding \"<ValueSet url or VCL>\" (a code), #:documentation \"…\" (what it is, its unit) and #:min/#:max (a number's range) when wanted" p)]))]))

;; binding-url : string syntax -> string
;; `#:binding` names a ValueSet by url, or says the codes inline as VCL — `"(http://hl7.org/fhir/
;; administrative-gender)(female;male)"` is FHIR's implicit VCL value set
;; (http://fhir.org/VCL?v1=…), which $expand compiles; a VCL expression that does not parse is an
;; error here, at the binding
(define (binding-url s stx)
  (cond
    [(regexp-match? #rx"^(https?://|urn:)" s) s]
    [else
     (define r (vcl->valueset s))
     ;; the url percent-encoded, as the VCL specification requires of an implicit value set's url
     (if (ok? r)
         (string-append "http://fhir.org/VCL?v1=" (uri-unreserved-encode s))
         (decl-error 'operation
                     (format "#:binding ~s is neither a ValueSet url nor a VCL expression (~a); a code subset is written \"(<system>)(code1;code2)\""
                             s (let ([e (err-error r)]) (if (invalid-encoding? e) (invalid-encoding-value e) e)))
                     stx))]))

(module+ test
  (require rackunit (only-in fhir/r6/types))     ; populate the registry at phase 0 for the test
  ;; parse-server yields an rc-server construction with defaults
  (check-equal? (syntax->datum (parse-server #'(server)))
                '(rc-server "server" "active" "2025-01-01T00:00:00Z" "6.0.0-ballot4"
                            (list "application/fhir+json") #f #f #f))
  ;; a name and a description for the statement (its `implementation` too)
  (check-equal? (list-tail (syntax->datum (parse-server #'(server #:name "Clinic" #:description "The clinic's server"))) 7)
                '("Clinic" "The clinic's server"))
  ;; parse-resource validates the type and interactions
  (define-values (rstx pstx) (parse-resource #'(resource Patient #:interactions (read create)
                                                          #:repository repo)))
  (check-equal? (syntax->datum rstx)
                '(rc-resource 'Patient (list 'read 'create) (list) #f))
  (check-equal? (syntax->datum pstx) '(cons 'Patient repo))
  (check-exn exn:fail:user? (lambda () (parse-resource #'(resource Bogus #:interactions (read)
                                                                     #:repository r))))
  (check-exn exn:fail:user? (lambda () (parse-resource #'(resource Patient #:interactions (frob)
                                                                     #:repository r))))
  ;; parse-operation yields rc-operation + its OperationDefinition + entries; strips the $;
  ;; validates param types
  (define po (parse-operation #'(operation $expand #:on ValueSet #:in ([url uri 1 1])
                                             #:out ([return ValueSet 1 1]) #:handler h)))
  (define ostx (parsed-operation-rc po))
  (define entries (parsed-operation-entries po))
  (check-equal? (syntax->datum ostx)
                '(rc-operation "expand" "$expand" (list #f #t #f) (list "ValueSet")
                               (list (rc-param "url" "uri" 1 1 "in" #f #f #f #f))
                               (list (rc-param "return" "ValueSet" 1 1 "out" #f #f #f #f)) #f))
  (check-equal? (syntax->datum entries)
                '(list (operation-entry 'type "expand" "ValueSet" h)))
  ;; an existing operation, by reference or as a value in scope, brings its own definition
  (define rpo (parse-operation #'(operation "ValueSet/$expand")))
  (define rrc (parsed-operation-rc rpo))
  (define rentries (parsed-operation-entries rpo))
  (check-equal? (syntax->datum rrc) '(operation->rc (operation "ValueSet/$expand")))
  (check-equal? (syntax->datum rentries) '(operation->entries (operation "ValueSet/$expand")))
  (define ventries (parsed-operation-entries (parse-operation #'(operation $validate))))
  (check-equal? (syntax->datum ventries) '(operation->entries $validate))
  (check-exn exn:fail:user? (lambda () (parse-operation #'(operation $x #:in ([p NoSuch 1 1])
                                                                       #:handler h)))))
