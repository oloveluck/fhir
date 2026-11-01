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
;;; Data definitions
;;;   An IgPlan is (ig-plan name version fhir-version tower core-tgz ig-cs resources)
;;;     resources : (listof ig-resource)
;;;   An IgResource is (ig-resource type interactions search-params profiles)
;;;     interactions  : (listof (cons code expectation))   e.g. ("read" . "SHALL")
;;;     search-params : (listof (list name type expectation))
;;;     profiles      : (listof canonical)
;;;   A Gap is (gap type what name expectation reason) — one IG requirement the server does not meet
;;;
;;; Supported: interactions read vread create update delete search-type; search parameters of
;;; every type except composite/special (store/search-index.rkt); transaction/batch Bundles.
;;; _include/_revinclude of the form Source:param[:Target] (not `*`, not :iterate).
;;; IG operations with an implementation in `operation-impls` (US Core $docref so far).
;;; Not yet: patch, history, chained parameters, other IG operations, SMART auth — each listed as a gap.

(require racket/contract racket/list racket/string racket/match
         json file/gunzip file/untar
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/serialize/read-json strip-jnum)
         (only-in fhir/result/result ok? ok-value ok-or-raise)
         (only-in fhir/model/registry type-registered?)
         (only-in fhir/capability/runtime make-repository build-app repository-read repository-vread
                  repository-create repository-update repository-delete repository-search)
         (only-in fhir/kernel/operation-entry operation-entry)
         (only-in fhir/model/node fhir? fhir-ref)
         (only-in fhir/model/leaf pv)
         (only-in fhirpath/temporal-ops moment? moment->string)
         (only-in fhir/conformance/validate validate-issues issue-severity issue-code issue-path issue-msg)
         "fhir-sqlite.rkt" "fhir-engine.rkt" "ig-params.rkt" "bundle.rkt"
         (only-in "search-index.rkt" indexed-kind?)
         (only-in "serve.rkt" store-repository))

(provide
 (struct-out ig-plan) (struct-out ig-resource) (struct-out gap) (struct-out ig-server)
 (contract-out
  [package-manifest (-> path-string? (or/c hash? #f))]
  [ig-package-path  (-> string? path?)]
  [plan-ig-server   (-> path-string? ig-plan?)]
  [gap->list        (-> gap? list?)]
  [make-ig-server   (->* (fhir-store? path-string?) (#:validate? boolean? #:url (or/c string? #f)) ig-server?)]
  ;; validate + upsert one resource by its id (the loader's path: ids and references preserved)
  [ig-server-put!   (-> ig-server? hash? (or/c 'ok any/c))]
  ;; every example in the IG package, through ig-server-put!
  [load-ig-examples! (-> ig-server? (values exact-nonnegative-integer? (listof (cons/c string? string?))))]))

(struct ig-plan (name version fhir-version tower core-tgz ig-cs resources) #:transparent)
(struct ig-resource (type interactions search-params profiles) #:transparent)
(struct gap (type what name expectation reason) #:transparent)
(define (gap->list g) (list (gap-type g) (gap-what g) (gap-name g) (gap-expectation g) (gap-reason g)))
;; app : the capability app (serve with http/server) ; gaps : (listof gap)
(struct ig-server (plan app gaps catalog sd-packages store validate? tgz))

(define supported-interactions '("read" "vread" "create" "update" "delete" "search-type"))

;; ---- reading the package -----------------------------------------------------------------------

;; read-package : tgz -> (values manifest (listof (cons file-name jsexpr)))
(define (read-package tgz)
  (define manifest #f)
  (define out '())
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate (thread (lambda ()
                            (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                            (close-output-port pout))))
  (untar pin #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define n (path->string name))
             (define bs (if (= size 0) #"" (read-bytes size content)))
             (define (js) (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bs)))
             (cond [(equal? n "package/package.json") (set! manifest (js))]
                   [(regexp-match? #px"^package/[^./][^/]*\\.json$" n)
                    (define j (js))
                    (when (hash? j) (set! out (cons (cons (last (string-split n "/")) j) out)))]))
           '()))
  (thread-wait inflate)
  (values manifest (reverse out)))

(define (package-manifest tgz) (let-values ([(m _) (read-package tgz)]) m))

;; ig-package-path : "hl7.fhir.us.core" | "x.tgz" | a path -> the package file
(define (ig-package-path s)
  (cond [(file-exists? s) (string->path s)]
        [(regexp-match? #rx"[.]tgz$" s) (spec-package-path s)]
        [else (spec-package-path (string-append s ".tgz"))]))

;; fhir-version -> (values tower-module core-package-file)
(define (tower-for v)
  (match v
    [(regexp #rx"^4[.]0") (values 'fhir/r4/schemas "hl7.fhir.r4.core.tgz")]
    [(regexp #rx"^5[.]0") (values 'fhir/r5/schemas "hl7.fhir.r5.core.tgz")]
    [(regexp #rx"^6[.]") (values 'fhir/r6/types "hl7.fhir.r6.core.tgz")]
    [_ (raise-user-error 'fhir "unsupported FHIR version ~a (expected 4.0.x, 5.0.x or 6.x)" v)]))

(define (expectation-of h)
  (or (for/or ([e (in-list (let ([x (hash-ref h 'extension '())]) (if (list? x) x '())))])
        (and (equal? (hash-ref e 'url #f) "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation")
             (hash-ref e 'valueCode #f)))
      "MAY"))

(define (plan-ig-server tgz)
  (define-values (manifest resources) (read-package tgz))
  (define fv (let ([vs (and manifest (hash-ref manifest 'fhirVersions #f))])
               (cond [(and (list? vs) (pair? vs)) (car vs)]
                     [else (raise-user-error 'fhir "~a: package.json declares no fhirVersions" tgz)])))
  (define-values (tower core-file) (tower-for fv))
  (define server-cs
    (for/or ([r (in-list resources)])
      (define js (cdr r))
      (and (equal? (hash-ref js 'resourceType #f) "CapabilityStatement")
           (for/or ([rest (in-list (let ([x (hash-ref js 'rest '())]) (if (list? x) x '())))])
             (equal? (hash-ref rest 'mode #f) "server"))
           js)))
  (unless server-cs
    (raise-user-error 'fhir "~a ships no server CapabilityStatement (rest.mode = server)" tgz))
  (define rest (findf (lambda (r) (equal? (hash-ref r 'mode #f) "server")) (hash-ref server-cs 'rest)))
  (define rs
    (for/list ([res (in-list (hash-ref rest 'resource '()))])
      (ig-resource (hash-ref res 'type)
                   (for/list ([i (in-list (hash-ref res 'interaction '()))]) (cons (hash-ref i 'code) (expectation-of i)))
                   (for/list ([sp (in-list (hash-ref res 'searchParam '()))])
                     (list (hash-ref sp 'name) (hash-ref sp 'type #f) (expectation-of sp)))
                   (map (lambda (p) (car (string-split p "|")))
                        (append (let ([p (hash-ref res 'profile #f)]) (if (string? p) (list p) '()))
                                (hash-ref res 'supportedProfile '()))))))
  (ig-plan (and manifest (hash-ref manifest 'name #f)) (and manifest (hash-ref manifest 'version #f))
           fv tower (spec-package-path core-file) server-cs rs))

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
   #:search (and (allowed? "search-type") (repository-search base))))

(define (make-ig-server store tgz #:validate? [validate? #t] #:url [url #f])
  (define plan (plan-ig-server tgz))
  (dynamic-require (ig-plan-tower plan) #f)                       ; register the IG's FHIR version
  (define core (ig-plan-core-tgz plan))
  (define catalog (merge-search-params (search-params-from-package core) (search-params-from-package tgz)))
  (define served
    (filter (lambda (r) (type-registered? (string->symbol (ig-resource-type r)))) (ig-plan-resources plan)))
  (define gaps
    (append
     (for*/list ([r (in-list (ig-plan-resources plan))]
                 #:unless (memq r served))
       (gap (ig-resource-type r) 'resource (ig-resource-type r) "SHALL" "type not in this FHIR version's tower"))
     (for*/list ([r (in-list served)] [i (in-list (ig-resource-interactions r))]
                 #:unless (member (car i) supported-interactions))
       (gap (ig-resource-type r) 'interaction (car i) (cdr i) "interaction not implemented"))
     (for*/list ([r (in-list served)] [sp (in-list (ig-resource-search-params r))]
                 #:unless (executable? catalog (ig-resource-type r) (car sp)))
       (gap (ig-resource-type r) 'search-param (car sp) (caddr sp)
            (format "~a parameter not executable" (or (cadr sp) "unknown"))))
     (let ([rest (findf (lambda (x) (equal? (hash-ref x 'mode #f) "server")) (hash-ref (ig-plan-ig-cs plan) 'rest))])
       (append
        (for/list ([sp (in-list (hash-ref rest 'searchParam '()))])
          (gap "*" 'search-param (hash-ref sp 'name) (expectation-of sp) "system-level search not implemented"))
        (for*/list ([res (in-list (hash-ref rest 'resource '()))]
                    [k (in-list '(searchInclude searchRevInclude))]
                    [v (in-list (hash-ref res k '()))]
                    #:unless (include-supported? v))
          (gap (hash-ref res 'type) (if (eq? k 'searchInclude) '_include '_revinclude) v
               (expectation-of res) "wildcard / :iterate includes not implemented"))
        (for*/list ([res (in-list (hash-ref rest 'resource '()))]
                    [op (in-list (hash-ref res 'operation '()))]
                    #:unless (operation-implemented? op))
          (gap (hash-ref res 'type) 'operation (hash-ref op 'name) (expectation-of op) "operation not implemented"))))))
  (define ods (package-operation-definitions tgz))
  (define sd-packages (list tgz core))
  (define capability (ok-or-raise (from-json (instance-capability plan served catalog url) #:lenient? #t)))
  (define app
    (build-app #:capability capability
               #:operation-definitions
               (for/list ([(url impl) (in-hash operation-impls)] #:when (hash-ref ods url #f))
                 (ok-or-raise (from-json (strip-jnum (hash-ref ods url)) #:lenient? #t)))
               #:repositories
               (for/list ([r (in-list served)])
                 (define allowed (filter (lambda (c) (member c supported-interactions)) (map car (ig-resource-interactions r))))
                 (cons (string->symbol (ig-resource-type r))
                       (ig-repository store (string->symbol (ig-resource-type r)) catalog allowed validate? sd-packages)))
               #:operations
               (for/list ([(url impl) (in-hash operation-impls)] #:when (hash-ref ods url #f))
                 (define od (hash-ref ods url))
                 (operation-entry (op-impl-level impl) (hash-ref od 'code) (op-impl-type impl)
                                  ((op-impl-make-proc impl) store catalog)))
               #:transaction (lambda (bundle-js) (process-bundle! store bundle-js #:search-params catalog))))
  (ig-server plan app gaps catalog sd-packages store validate? tgz))

(define (ig-server-put! srv js0)
  (define js (strip-jnum js0))
  (define errors (write-errors js (ig-server-validate? srv) (ig-server-sd-packages srv)))
  (cond [(pair? errors) (validation-outcome js errors)]
        [else (fhir-update! (ig-server-store srv) js #:search-params (ig-server-catalog srv)) 'ok]))

;; ---- IG operations: a table keyed by OperationDefinition canonical ------------------------------
;; An OperationImpl is (op-impl level type make-proc): make-proc : ig-server-store catalog -> handler,
;; handler : (in-hash request) -> fhir node. The OperationDefinition itself comes from the IG package
;; (its inputs are validated by the capability runtime before the handler runs).
(struct op-impl (level type make-proc))

(define (in-string in name)
  (define v (hash-ref in name '()))
  (and (pair? v) (let ([x (car v)]) (cond [(string? x) x] [(moment? x) (moment->string x)] [else (format "~a" x)]))))

;; US Core $docref (https://hl7.org/fhir/us/core/OperationDefinition-docref.html): the patient's
;; DocumentReferences, start/end bounding DocumentReference.context.period, `type` matching. Only
;; EXISTING documents are returned: on-demand generation and the profile filter are not supported
;; (on-demand=true is answered from storage, which the operation permits when nothing is generated).
(define (docref-proc store catalog)
  (lambda (in req)
    (define patient (in-string in "patient"))
    (define types
      (for/list ([c (in-list (hash-ref in "type" '()))] #:when (fhir? c))
        (string-append (or (let ([s (pv (fhir-ref c 'system #f))]) s) "") "|" (or (pv (fhir-ref c 'code #f)) ""))))
    (define q (append (list (cons "patient" patient))
                      (let ([s (in-string in "start")]) (if s (list (cons "period" (string-append "ge" s))) '()))
                      (let ([e (in-string in "end")]) (if e (list (cons "period" (string-append "le" e))) '()))
                      (if (pair? types) (list (cons "type" (string-join types ","))) '())))
    (define hits (fhir-search store "DocumentReference" q #:search-params catalog))
    (ok-or-raise
     (from-json (hasheq 'resourceType "Bundle" 'type "searchset" 'total (length hits)
                        'entry (for/list ([h (in-list hits)])
                                 (hasheq 'resource h 'search (hasheq 'mode "match"))))
                #:lenient? #t))))

(define operation-impls
  (hash "http://hl7.org/fhir/us/core/OperationDefinition/docref" (op-impl 'type "DocumentReference" docref-proc)))

;; the IG's OperationDefinitions (url -> jsexpr)
(define (package-operation-definitions tgz)
  (define-values (_m resources) (read-package tgz))
  (for/hash ([r (in-list resources)] #:when (equal? (hash-ref (cdr r) 'resourceType #f) "OperationDefinition"))
    (values (hash-ref (cdr r) 'url) (cdr r))))

(define (operation-implemented? cs-op)
  (define def (hash-ref cs-op 'definition #f))
  (and (string? def) (hash-has-key? operation-impls (car (string-split def "|")))))

;; Source:param[:Target] includes are implemented (fhir-includes); `*` and :iterate are not
(define (include-supported? v) (and (regexp-match? #px"^[A-Z][A-Za-z]+:[A-Za-z0-9_-]+(:[A-Z][A-Za-z]+)?$" v) #t))

(define (executable? catalog type name)
  (or (member name '("_id" "_lastUpdated"))
      (for/or ([sp (in-list (hash-ref catalog (string->symbol type) '()))])
        (and (equal? (search-param-name sp) name) (indexed-kind? (search-param-kind sp))))))

;; the IG's server CapabilityStatement, as this server's instance statement: same resources,
;; profiles and expectations, trimmed to the interactions and parameters actually executed
(define (instance-capability plan served catalog url)
  (define cs (ig-plan-ig-cs plan))
  (define served-types (map ig-resource-type served))
  (define rest (findf (lambda (x) (equal? (hash-ref x 'mode #f) "server")) (hash-ref cs 'rest)))
  (define resources
    (for/list ([res (in-list (hash-ref rest 'resource '()))]
               #:when (member (hash-ref res 'type) served-types))
      (define t (hash-ref res 'type))
      (for/fold ([h (for/fold ([h (let ([ops (filter operation-implemented? (hash-ref res 'operation '()))])
                                    (if (null? ops) (hash-remove res 'operation) (hash-set res 'operation ops)))])
                              ([k (in-list '(searchInclude searchRevInclude))])
                      ;; keep the includes this server executes (their _ extension arrays would no
                      ;; longer line up once filtered, so they are dropped)
                      (define kept (filter include-supported? (hash-ref h k '())))
                      (define h2 (hash-remove h (string->symbol (string-append "_" (symbol->string k)))))
                      (if (null? kept) (hash-remove h2 k) (hash-set h2 k kept)))])
                ([k (in-list '(interaction searchParam))])
        (define kept
          (filter (lambda (x) (if (eq? k 'interaction)
                                  (member (hash-ref x 'code #f) supported-interactions)
                                  (executable? catalog t (hash-ref x 'name ""))))
                  (hash-ref res k '())))
        (if (null? kept) (hash-remove h k) (hash-set h k kept)))))
  (define base
    (for/fold ([h cs]) ([k (in-list '(id meta text url version name title _title publisher contact
                                      jurisdiction copyright instantiates imports _instantiates))])
      (hash-remove h k)))
  (hash-set* base
             'kind "instance"
             'status "active"
             'date (let ([d (seconds->date (current-seconds) #f)])
                     (format "~a-~a-~a" (date-year d) (~2 (date-month d)) (~2 (date-day d))))
             'instantiates (list (string-append (hash-ref cs 'url) "|" (or (ig-plan-version plan) "")))
             'software (hasheq 'name "fhir-tools ig-server")
             'implementation (if url (hasheq 'description "generated from the IG" 'url url)
                                 (hasheq 'description (format "generated from ~a ~a" (ig-plan-name plan) (ig-plan-version plan))))
             'rest (list (hash-set* (hash-remove (hash-remove rest 'searchParam) 'operation)
                                    'resource resources
                                    'interaction (filter (lambda (i) (member (hash-ref i 'code #f) '("transaction" "batch")))
                                                         (append (hash-ref rest 'interaction '())
                                                                 (list (hasheq 'code "transaction") (hasheq 'code "batch"))))))))

(define (~2 n) (if (< n 10) (format "0~a" n) (number->string n)))

;; load-ig-examples! : ig-server -> (values loaded rejected)   rejected : (listof (cons file reason))
(define (load-ig-examples! srv)
  (define-values (_m examples) (read-package-examples (ig-server-tgz srv)))
  (for/fold ([n 0] [rejected '()] #:result (values n (reverse rejected)))
            ([ex (in-list examples)])
    (define js (cdr ex))
    (define t (hash-ref js 'resourceType #f))
    (cond
      [(not (and (string? t) (type-registered? (string->symbol t)) (string? (hash-ref js 'id #f))))
       (values n rejected)]
      [else
       (define r (ig-server-put! srv js))
       (if (eq? r 'ok)
           (values (add1 n) rejected)
           (values n (cons (cons (car ex)
                                 (string-join (for/list ([i (in-list (cdr (hash-ref (node->jsexpr r) 'issue '())))])
                                                (format "~a ~a" (car (hash-ref i 'expression '(""))) (hash-ref i 'diagnostics "")))
                                              "; "))
                           rejected)))])))

;; the package's example/*.json resources
(define (read-package-examples tgz)
  (define out '())
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate (thread (lambda ()
                            (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                            (close-output-port pout))))
  (untar pin #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define n (path->string name))
             (define bs (if (= size 0) #"" (read-bytes size content)))
             (when (regexp-match? #px"^package/example/[^./][^/]*\\.json$" n)
               (define j (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bs)))
               (when (hash? j) (set! out (cons (cons (last (string-split n "/")) j) out)))))
           '()))
  (thread-wait inflate)
  (values #f (reverse out)))
