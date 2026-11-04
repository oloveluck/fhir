#lang racket/base

;;; ig-server.rkt — a FHIR server GENERATED FROM an Implementation Guide package.
;;;
;;; The IG is the specification of the server, so the server is derived from it:
;;;   FHIR version  — package.json `fhirVersions` picks the type tower (fhir/r4|r5|r6) and the core
;;;                   package (from fhir-spec) the IG builds on
;;;   resources     — the IG's server CapabilityStatement (rest.mode = server): which types, which
;;;                   interactions, which search parameters, which supported profiles
;;;   search        — the catalog = the core package's SearchParameters overlaid by the IG's own
;;;   validation    — every create/update is validated against its base type and the profiles it
;;;                   claims in meta.profile (resolved over IG + core); errors -> HTTP 422
;;;   /metadata     — the IG's OWN CapabilityStatement turned into an `instance` statement and TRIMMED
;;;                   to what this server executes; everything trimmed is listed in the gap report
;;;
;;; Data definitions (the IgPlan and IgResource are ig-plan.rkt's, the Gap and Executes
;;; ig-capability.rkt's)
;;;   An IgServer is (ig-server plan app gaps catalog sd-packages store validate? tgz)
;;;     app         : the capability app (serve with http/server)
;;;     gaps        : (listof Gap)   the IG requirements this server does not meet
;;;     catalog     : the search-param catalog (ig-params.rkt): core overlaid by the dependencies and the IG
;;;     sd-packages : the validation context — the IG, its dependencies, the core
;;;
;;; Supported: interactions read vread create update delete search-type history-instance history-type
;;; patch (JSON Patch); search parameters of every type except composite/special
;;; (store/search-index.rkt); transaction/batch Bundles; _include/_revinclude of the form
;;; Source:param[:Target] (not :iterate). IG operations that have a registered implementation
;;; (fhir/operation: $validate, $snapshot, the terminology operations, Measure $evaluate-measure from
;;; cql, US Core $docref here), at every level their OperationDefinition declares; they run with the
;;; store as `current-data-source` and the server's packages as `current-sd-packages`.
;;; Not yet: chained parameters, other IG operations, SMART auth — each listed as a gap.

(require racket/contract racket/list racket/string
         (only-in fhir/package read-package)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/serialize/read-json strip-jnum)
         (only-in fhir/result/result ok-or-raise)
         (only-in fhir/model/registry type-registered?)
         (only-in fhir/capability/runtime make-repository build-app repository-read repository-vread
                  repository-create repository-update repository-delete repository-search
                  repository-history)
         (only-in fhir/conformance/validate validate-issues issue-severity issue-code issue-path issue-msg)
         (only-in fhir/parallel parallel-map)
         (only-in json jsexpr->string)
         "fhir-sqlite.rkt" "fhir-engine.rkt" "ig-params.rkt" "bundle.rkt" "ig-plan.rkt" "ig-capability.rkt"
         (only-in "search-index.rkt" indexed-kind?)
         (only-in "serve.rkt" store-repository)
         fhir/operation fhir/data-source
         "data-source.rkt"
         (only-in fhir/capability/operations operation->entries)
         ;; the operation implementations this server can serve register themselves when loaded
         (only-in fhir/conformance/operations) (only-in fhir/terminology/operations)
         (only-in fhir/sd/operations)
         (only-in cql/measure current-measure-offset))

(provide
 ;; the plan (ig-plan.rkt) and the gaps (ig-capability.rkt) are this module's API too
 (struct-out ig-plan) (struct-out ig-resource) (struct-out gap) (struct-out ig-server)
 package-manifest ig-package-path plan-ig-server gap->list
 (contract-out
  [make-ig-server   (->* (fhir-store? path-string?)
                           (#:validate? boolean? #:url (or/c string? #f) #:capability (or/c string? #f)
                            #:offset (or/c exact-integer? #f))
                           ig-server?)]
  ;; validate + upsert one resource by its id (the loader's path: ids and references preserved)
  [ig-server-put!   (-> ig-server? hash? (or/c 'ok any/c))]
  ;; every example in the IG package, through ig-server-put!
  [load-ig-examples! (-> ig-server? (values exact-nonnegative-integer? (listof (cons/c string? string?))))]))

;; app : the capability app (serve with http/server) ; gaps : (listof gap)
(struct ig-server (plan app gaps catalog sd-packages store validate? tgz))

;; the interactions the repository implements (ig-repository)
(define supported-interactions '("read" "vread" "create" "update" "delete" "search-type"
                                 "history-instance" "history-type" "patch"))

;; ---- the app ------------------------------------------------------------------------------------

;; validation-outcome : jsexpr (listof issue) -> OperationOutcome node (first issue: processing)
(define (validation-outcome js issues)
  (define claimed (let ([m (hash-ref js 'meta #f)]) (if (hash? m) (hash-ref m 'profile '()) '())))
  (ok-or-raise
   (from-json
    (hasheq 'resourceType "OperationOutcome"
            'issue (cons (hasheq 'severity "error" 'code "processing"
                                 'diagnostics (format "~a does not conform to ~a"
                                                      (hash-ref js 'resourceType "resource")
                                                      (if (null? claimed) "its base type" (string-join claimed ", "))))
                         (for/list ([i (in-list issues)])
                           (hasheq 'severity (issue-severity i) 'code (issue-code i)
                                   'diagnostics (issue-msg i)
                                   'expression (list (or (issue-path i) ""))))))
    #:lenient? #t)))

;; write-errors : jsexpr validate? sd-packages -> (listof issue)   error-severity issues only
(define (write-errors js validate? sd-packages)
  (if validate?
      (parameterize ([current-sd-packages sd-packages])
        (filter (lambda (i) (member (issue-severity i) '("error" "fatal"))) (validate-issues js)))
      '()))

;; a repository restricted to the IG's interactions, validating writes when asked
(define (ig-repository store type catalog allowed validate? sd-packages)
  (define base (store-repository store type catalog))
  (define (allowed? code) (member code allowed))
  (define (checked write)
    (lambda args
      (define node (last args))
      (define js (strip-jnum (node->jsexpr node)))
      (define errors (write-errors js validate? sd-packages))
      (if (null? errors) (apply write args) (validation-outcome js errors))))
  (make-repository
   #:read   (and (allowed? "read") (repository-read base))
   #:vread  (and (allowed? "vread") (repository-vread base))
   #:create (and (allowed? "create") (checked (repository-create base)))
   #:update (and (allowed? "update") (checked (repository-update base)))
   #:delete (and (allowed? "delete") (repository-delete base))
   ;; PATCH applies over read + the validated update, independently of the read/update interactions
   #:patch (and (allowed? "patch") (cons (repository-read base) (checked (repository-update base))))
   #:search (and (allowed? "search-type") (repository-search base))
   ;; one closure serves both levels; each level answers only when the IG declares it
   #:history (and (or (allowed? "history-instance") (allowed? "history-type"))
                  (let ([h (repository-history base)])
                    (lambda (id params)
                      (and (allowed? (if id "history-instance" "history-type"))   ; #f = not supported
                           (h id params)))))))

(define (make-ig-server store tgz #:validate? [validate? #t] #:url [url #f] #:capability [cs-choice #f]
                        #:offset [offset 0])
  (define plan (plan-ig-server tgz cs-choice))
  (dynamic-require (ig-plan-tower plan) #f)                       ; register the IG's FHIR version
  (define core (ig-plan-core-tgz plan))
  ;; the IG's own dependencies (US Core under mCODE, …), found in fhir-spec: their profiles resolve
  ;; Parents and claimed profiles during validation, their SearchParameters join the catalog
  (define deps (dependency-packages tgz))
  (define catalog
    (for/fold ([c (search-params-from-package core)]) ([p (in-list (append deps (list tgz)))])
      (merge-search-params c (search-params-from-package p))))
  (define served
    (filter (lambda (r) (type-registered? (string->symbol (ig-resource-type r)))) (ig-plan-resources plan)))
  ;; the IG's OperationDefinitions, then the core package's (ValueSet-expand lives in core)
  (define ods (let ([core-ods (package-operation-definitions (ig-plan-core-tgz plan))])
                (for/fold ([h core-ods]) ([(k v) (in-hash (package-operation-definitions tgz))]) (hash-set h k v))))
  (define sd-packages (append (list tgz) deps (list core)))
  ;; what this server executes, held against the IG's statement: the gaps and the instance statement
  (define ex (executes (lambda (code) (and (member code supported-interactions) #t))
                       (lambda (type name) (executable? catalog type name))
                       include-supported?
                       (lambda (u) (implemented-url? u))))
  (define gaps (plan-gaps plan served ex))
  (define capability (ok-or-raise (from-json (instance-capability plan served ex url) #:lenient? #t)))
  (define data (store->data-source store #:search-params catalog))
  (define served-ops                       ; (url . operation) for the IG's ODs with an implementation
    (for*/list ([(u od) (in-hash ods)] [op (in-value (implementation-of u ods))] #:when op) (cons u op)))
  (define app
    (build-app #:capability capability
               #:operation-definitions
               (for/list ([u+op (in-list served-ops)])
                 (ok-or-raise (from-json (strip-jnum (hash-ref ods (car u+op))) #:lenient? #t)))
               #:repositories
               (for/list ([r (in-list served)])
                 (define allowed (filter (lambda (c) (member c supported-interactions)) (map car (ig-resource-interactions r))))
                 (cons (string->symbol (ig-resource-type r))
                       (ig-repository store (string->symbol (ig-resource-type r)) catalog allowed validate? sd-packages)))
               #:operations
               ;; every implemented operation at the levels and on the types its definition declares;
               ;; it reads instance subjects from the store and runs with the store as data source
               (append*
                (for/list ([u+op (in-list served-ops)])
                  (operation->entries
                   (cdr u+op)
                   #:read (lambda (type id) (fhir-read store type id))
                   #:around (lambda (thunk)
                              (parameterize ([current-data-source data] [current-sd-packages sd-packages]
                                             [current-measure-offset offset])
                                (thunk))))))
               #:transaction (lambda (bundle-js) (process-bundle! store bundle-js #:search-params catalog
                                                                  #:tower (ig-plan-tower plan)))))
  (ig-server plan app gaps catalog sd-packages store validate? tgz))

(define (ig-server-put! srv js0)
  (define js (strip-jnum js0))
  (define errors (write-errors js (ig-server-validate? srv) (ig-server-sd-packages srv)))
  (cond [(pair? errors) (validation-outcome js errors)]
        [else (fhir-update! (ig-server-store srv) js #:search-params (ig-server-catalog srv)) 'ok]))

;; ---- IG operations ---------------------------------------------------------------------------
;; implemented-url? : canonical -> Boolean   is there an implementation to serve under this url?
(define (implemented-url? url)
  (or (and (member url (map operation-url (registered-operations))) #t)
      (and (member url docref-urls) #t)))

;; implementation-of : canonical ods -> operation|#f   the registered implementation; US Core's
;; $docref is built here from the IG's own OperationDefinition (it needs the store's search)
(define (implementation-of url ods)
  (cond [(member url (map operation-url (registered-operations))) (operation url)]
        [(member url docref-urls) (docref-operation (hash-ref ods url))]
        [else #f]))

;; US Core $docref (https://hl7.org/fhir/us/core/OperationDefinition-docref.html): the patient's
;; DocumentReferences, start/end bounding DocumentReference.context.period, `type` matching. Only
;; EXISTING documents are returned: on-demand generation and the profile filter are not supported
;; (on-demand=true is answered from storage, which the operation permits when nothing is generated).
;; IPA defines the same operation (same parameters) under its own canonical
(define docref-url "http://hl7.org/fhir/us/core/OperationDefinition/docref")
(define docref-urls (list docref-url "http://hl7.org/fhir/uv/ipa/OperationDefinition/docref"))
(define (docref-operation od)
  (make-operation
   (strip-jnum od)
   (lambda (in _)
     (define search (or (data-source-search (current-data-source))
                        (operation-error "not-supported" "$docref needs a searchable data source")))
     (define types
       (for/list ([c (in-list (hash-ref in "type" '()))] #:when (hash? c)
                  [cd (in-list (let ([cs (hash-ref c 'coding #f)]) (if (list? cs) cs (list c))))])
         (string-append (hash-ref cd 'system "") "|" (hash-ref cd 'code ""))))
     (define q (append (list (cons "patient" (input in "patient")))
                       (let ([s (input in "start")]) (if s (list (cons "period" (string-append "ge" s))) '()))
                       (let ([e (input in "end")]) (if e (list (cons "period" (string-append "le" e))) '()))
                       (if (pair? types) (list (cons "type" (string-join types ","))) '())))
     (define hits (search "DocumentReference" q))
     (hasheq 'resourceType "Bundle" 'type "searchset" 'total (length hits)
             'entry (for/list ([h (in-list hits)]) (hasheq 'resource h 'search (hasheq 'mode "match")))))))

;; OperationDefinitions of a package (url -> jsexpr), reading only OperationDefinition-*.json
(define (package-operation-definitions tgz)
  (define-values (_m ods _e) (read-package tgz #:select (lambda (f) (string-prefix? f "OperationDefinition-"))))
  (for/hash ([od (in-list ods)] #:when (hash-ref (cdr od) 'url #f)) (values (hash-ref (cdr od) 'url) (cdr od))))

;; include-supported? : String -> Boolean
;; Source:param[:Target] and Source:* includes are implemented (fhir-includes); :iterate is not
(define (include-supported? v) (and (regexp-match? #px"^[A-Z][A-Za-z]+:([A-Za-z0-9_-]+(:[A-Z][A-Za-z]+)?|[*])$" v) #t))

;; executable? : catalog type name -> Boolean   a parameter the store indexes (or a built-in one)
(define (executable? catalog type name)
  (or (and (member name '("_id" "_lastUpdated")) #t)
      (for/or ([sp (in-list (hash-ref catalog (string->symbol type) '()))])
        (and (equal? (search-param-name sp) name) (indexed-kind? (search-param-kind sp))))
      #f))

;; load-ig-examples! : ig-server -> (values loaded rejected)   rejected : (listof (cons file reason))
(define (load-ig-examples! srv)
  (define-values (_m resources examples0) (read-package (ig-server-tgz srv)))
  ;; plus the IG's own ValueSets and CodeSystems, so they are readable and expandable by id
  (define examples (append (filter (lambda (r) (member (hash-ref (cdr r) 'resourceType #f) '("ValueSet" "CodeSystem")))
                                   resources)
                           examples0))
  (define admitted (for/list ([ex (in-list examples)] #:when (loadable? (cdr ex))) (cons (car ex) (strip-jnum (cdr ex)))))
  ;; validation is the cost, and each example's is independent: every core validates a share
  ;; (fhir/parallel; the workers load this server's tower), then the writes go in, in order
  (define errors
    (if (ig-server-validate? srv)
        (parallel-map '(fhir/conformance/validate write-errors/rows)
                      (for/list ([ex (in-list admitted)])
                        (list (jsexpr->string (cdr ex)) (map path-string (ig-server-sd-packages srv))))
                      #:setup (ig-plan-tower (ig-server-plan srv)))
        (map (lambda (_) '()) admitted)))
  (for/fold ([n 0] [rejected '()] #:result (values n (reverse rejected)))
            ([ex (in-list admitted)] [rows (in-list errors)])
    (cond
      [(null? rows)
       (fhir-update! (ig-server-store srv) (cdr ex) #:search-params (ig-server-catalog srv))
       (values (add1 n) rejected)]
      [else
       (values n (cons (cons (car ex) (string-join (for/list ([r (in-list rows)]) (format "~a ~a" (or (caddr r) "") (cadddr r))) "; "))
                       rejected))])))

;; loadable? : jsexpr -> Boolean   a resource of a type this tower has, with an id to store it under
(define (loadable? js)
  (define t (hash-ref js 'resourceType #f))
  (and (string? t) (type-registered? (string->symbol t)) (string? (hash-ref js 'id #f))))

;; path-string : path-string -> String
(define (path-string p) (if (path? p) (path->string p) p))
