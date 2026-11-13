#lang racket/base

;;; runtime.rkt — the in-process application: capability registry + request dispatcher.
;;;
;;; The `#lang fhir/capability` module assembles an `app` value from its declarations. Handlers are
;;; supplied as struct-of-closures (a `repository` per resource type, a proc per operation), mirroring
;;; the dependency-injected `tx-service` pattern in fhirpath/terminology.rkt. `dispatch` routes a
;;; `request` record over typed nodes to the right handler and always returns a typed node — a
;;; resource, a searchset Bundle, a Parameters, or an OperationOutcome. There is no network layer;
;;; a request is plain data, so an HTTP front end can be attached later without touching this core.

(require racket/contract
         racket/match
         (only-in net/uri-codec uri-unreserved-encode)
         racket/list (only-in racket/string string-join string-append*) (only-in net/uri-codec uri-decode)
         (only-in fhir/suggest did-you-mean)
         (only-in fhir/model/node fhir? fhir-type fhir-ref fhir-field-names)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/result/result ok-or-raise ok? ok-value)
         (only-in fhirpath/navigate navigate)
         (only-in fhirpath/value item->system)
         (only-in fhirpath/decimal fp-decimal? decimal->exact decimal->string)
         (only-in fhirpath/render item->json)
         (only-in fhirpath/eval eval-fhirpath)
         (only-in fhirpath/parser/parse parse-fhirpath)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/spec-package spec-package-path)
         (only-in "derive.rkt" op-code->canonical)
         (only-in "json-patch.rkt" apply-json-patch exn:fail:json-patch?)
         fhir/kernel/operation-entry)

(provide
 (struct-out exn:fail:declaration)
 with-declared-locations
 (struct-out repository)
 (struct-out operation-handler)
 (struct-out operation-entry)
 (struct-out app)
 (struct-out request)
 (struct-out search-result)
 (struct-out search-result/ignored)
 (struct-out search-page)
 search-facts with-ignored
 current-app
 strict-search-app?
 r6-sd-packages
 ;; current-request-json : (parameter jsexpr|#f)   the request body AS SENT (the HTTP layer sets it
 ;; while dispatching): validation and operations read it, since the typed node is parsed leniently
 ;; and has dropped whatever it did not know (a misspelt element, a value it could not parse)
 current-request-json
 current-search-strict?
 (contract-out
  [make-repository (->* () (#:read (or/c procedure? #f) #:vread (or/c procedure? #f)
                            #:create (or/c procedure? #f) #:update (or/c procedure? #f)
                            #:delete (or/c procedure? #f) #:search (or/c procedure? #f)
                            #:history (or/c procedure? #f)
                            #:patch (or/c (cons/c procedure? procedure?) #f))
                       repository?)]
  ;; the repository of a resource declared without #:repository: the factory's when one is set
  ;; (capability/store: a SQLite store), else a generic in-memory one; type, declared interactions,
  ;; search-params (list name type expr)
  [make-default-repository (-> symbol? (listof symbol?) (listof list?) repository?)]
  [current-repository-factory (parameter/c (or/c #f (-> symbol? (listof symbol?) (listof list?) repository?)))]
  [build-app (->* (#:capability fhir? #:operation-definitions (listof fhir?)
                   #:repositories (listof (cons/c symbol? repository?))
                   #:operations (listof operation-entry?))
                  (#:transaction (or/c #f (-> hash? hash?)) #:metadata hash?) app?)]
  [dispatch (-> app? request? fhir?)]
  ;; request smart constructors
  [read-request   (-> symbol? string? request?)]
  [vread-request  (-> symbol? string? string? request?)]
  [create-request (-> symbol? fhir? request?)]
  [update-request (-> symbol? string? fhir? request?)]
  [delete-request (-> symbol? string? request?)]
  [history-request (->* (symbol? (or/c string? #f)) ((listof (cons/c symbol? string?))) request?)]
  [patch-request   (-> symbol? string? list? request?)]
  [search-request (->* (symbol?) ((listof (cons/c symbol? string?))) request?)]
  [invoke-request (->* (#:code string?) (#:level (or/c 'system 'type 'instance)
                        #:type (or/c symbol? #f) #:id (or/c string? #f) #:body (or/c fhir? #f))
                       request?)]
  ;; OperationOutcome constructors (exposed for handlers)
  [operation-outcome (-> string? string? string? fhir?)]
  [operation-outcome-not-supported (-> string? fhir?)]
  [operation-result? (-> any/c boolean?)]
  [refused! (-> any/c any/c)]
  [make-searchset (->* (any/c) (#:links list?) fhir?)]
  [operation-outcome-invalid (-> string? fhir?)]
  [operation-outcome-exception (-> string? fhir?)]
  [parameters->hash (-> (or/c fhir? #f) hash?)]))

;; ---- capability handlers (struct-of-closures) -----------------------------------------------

;; each field is a closure or #f (#f => that interaction is not supported)
;; patch   : (or #f (cons read update)) — the read/update pair PATCH uses (separate from the read and
;;           update interactions, which a server may declare independently)
;; history : (or #f (-> (or/c string? #f) (listof (cons/c string? string?)) (or/c (listof fhir?) #f)))
;;   instance history when given an id, type history when given #f; newest version first;
;;   #f = this level is not supported
(struct repository (read vread create update delete search history patch) #:transparent)

(define (make-repository #:read [read #f] #:vread [vread #f] #:create [create #f]
                         #:update [update #f] #:delete [delete #f] #:search [search #f]
                         #:history [history #f] #:patch [patch #f])
  (repository read vread create update delete search history patch))

;; a ready-made in-memory repository implementing exactly the declared interactions. Search evaluates
;; each declared search-param's FHIRPath expression against stored resources (a param without an
;; expression, or an unknown query param, is ignored — FHIR lenient handling).
(define current-repository-factory (make-parameter #f))
(define current-request-json (make-parameter #f))
;; current-search-strict? : (parameter boolean)   the request said `Prefer: handling=strict` (FHIR
;; search): an unsupported parameter answers 400 instead of being ignored and reported
(define current-search-strict? (make-parameter #f))
(define (make-default-repository type interactions sps)
  (define f (current-repository-factory))
  (if f (f type interactions sps) (make-memory-repository type interactions sps)))
(define (make-memory-repository type interactions sps)
  (define store (make-hash))                 ; id(string) -> resource node
  (define counter (box 0))
  (define (has? k) (and (memq k interactions) #t))
  (define (put! node id) (define stored (node-with-id node id)) (hash-set! store id stored) stored)
  (make-repository
   #:read   (and (has? 'read)        (lambda (id) (hash-ref store id #f)))
   #:vread  (and (has? 'vread)       (lambda (id vid) (hash-ref store id #f)))   ; no version history: latest
   #:create (and (has? 'create)      (lambda (node) (put! node (or (node-id node) (next-id! counter)))))
   #:update (and (has? 'update)      (lambda (id node) (put! node id)))
   #:delete (and (has? 'delete)      (lambda (id) (hash-remove! store id)))
   #:search (and (has? 'search-type) (lambda (params) (store-search store sps params)))
   #:patch  (and (has? 'patch) (cons (lambda (id) (hash-ref store id #f)) (lambda (id node) (put! node id))))))

(define (next-id! b) (set-box! b (add1 (unbox b))) (number->string (unbox b)))
(define (node-id n) (let ([v (fhir-ref n 'id #f)]) (and v (leaf->string v))))
(define (node-with-id n id) (ok-or-raise (from-json (hash-set (node->jsexpr n) 'id id) #:lenient? #t)))

(define (store-search store sps params)
  (define matches (for/list ([r (in-list (hash-values store))] #:when (matches-params? r sps params)) r))
  ;; what it could not apply is said, as the store-backed search does (the searchset reports it;
  ;; strict handling refuses it) — an in-memory app answered `?subject=…` with every resource
  (define ignored
    (remove-duplicates
     (for/list ([p (in-list params)]
                #:unless (let ([sp (findf (lambda (s) (eq? (car s) (car p))) sps)]) (and sp (caddr sp))))
       (symbol->string (car p)))))
  (if (null? ignored) matches (search-result/ignored matches '() ignored)))
(define (matches-params? r sps params)
  (for/and ([p (in-list params)])
    (define sp (findf (lambda (s) (eq? (car s) (car p))) sps))
    (cond
      [(or (not sp) (not (caddr sp))) #t]          ; unknown / expression-less param -> ignored
      [else (define vals (map ->str (map item->system (eval-fhirpath (parse-fhirpath (caddr sp)) (list r)))))
            (and (member (cdr p) vals) #t)])))
(define (->str v) (cond [(string? v) v] [(boolean? v) (if v "true" "false")] [else (format "~a" v)]))

;; an installed operation: its handler proc, the derived OperationDefinition (the runtime contract),
;; and where it applies. proc : (in-hash request) -> fhir
(struct operation-handler (proc op-def level target) #:transparent)
;; A SearchResult is what a repository's search answers. It is one of:
;;  - (listof node)                                 the matches, all of them
;;  - (search-result matches includes)              … and the resources _include/_revinclude pull in
;;  - (search-result/ignored matches includes names)   … and the parameters the search could not
;;        apply, which the searchset reports (an OperationOutcome entry, mode "outcome")
;;  - (search-page matches includes names total)    … where the matches are ONE PAGE (`_count`,
;;        `_offset`) of `total` matches in all
;; `search-facts` is the one reading of it; nothing else takes the variants apart.
(struct search-result (matches includes) #:transparent)
(struct search-result/ignored search-result (names) #:transparent)
(struct search-page search-result/ignored (total) #:transparent)

;; search-facts : SearchResult -> (values matches includes ignored-names total)
(define (search-facts r)
  (match r
    [(search-page ms is names total) (values ms is names total)]
    [(search-result/ignored ms is names) (values ms is names (length ms))]
    [(search-result ms is) (values ms is '() (length ms))]
    [(? list? ms) (values ms '() '() (length ms))]))

;; with-ignored : SearchResult (listof name) -> SearchResult   the same answer, also naming these
;; parameters as not applied
(define (with-ignored r more)
  (define-values (ms is names total) (search-facts r))
  (cond [(null? more) r]
        [else (search-page ms is (remove-duplicates (append more names)) total)]))

;; paging-links : type params total -> (listof link-jsexpr)
;; FHIR's paging links for a searchset that is a page (https://hl7.org/fhir/http.html#paging):
;; `next` while matches remain after this page, `previous` when it does not start at the first.
;; Each is the search itself with `_offset` moved by `_count`, relative to the server's base (the
;; HTTP layer, which knows the base, makes them absolute and adds `self`). A search with no
;; `_count` answers every match: no links.
(define (paging-links type params total)
  (define (number-of name) (let ([p (assq name params)]) (and p (string->number (cdr p)))))
  (define count (number-of '_count))
  (define offset (let ([o (number-of '_offset)]) (if (exact-nonnegative-integer? o) o 0)))
  (define (at new-offset)
    (define others (filter (lambda (p) (not (eq? (car p) '_offset))) params))
    (format "~a?~a" type
            (string-join (for/list ([p (in-list (append others (if (zero? new-offset) '() (list (cons '_offset (number->string new-offset))))))])
                           (format "~a=~a" (uri-unreserved-encode (symbol->string (car p))) (uri-unreserved-encode (cdr p))))
                         "&")))
  (cond
    [(not (exact-positive-integer? count)) '()]
    [else (append (if (> offset 0) (list (hasheq 'relation "previous" 'url (at (max 0 (- offset count))))) '())
                  (if (< (+ offset count) total) (list (hasheq 'relation "next" 'url (at (+ offset count)))) '()))]))
;; operation-entry (produced by the #lang emitter, paired with its OperationDefinition in
;; build-app) is defined in kernel/operation-entry.rkt so generated towers need only fhir.

;; ---- the application ------------------------------------------------------------------------

;; repositories : hasheq type-sym -> repository ; operations : hash (list level code target) -> handler
;; transaction : (jsexpr-Bundle -> jsexpr-Bundle) | #f — the whole-Bundle processor (POST /);
;; #f (the default) means a transaction is not supported by this app (a batch is routed entry by
;; entry regardless); metadata : hash mode-string -> node, what GET /metadata?mode=<mode> answers
;; besides the CapabilityStatement (a TerminologyCapabilities under "terminology")
(struct app (capability-statement operation-definitions repositories operations transaction metadata)
  #:transparent)

(define (build-app #:capability cap #:operation-definitions ods
                   #:repositories repo-entries #:operations op-entries
                   #:transaction [txn #f] #:metadata [metadata (hash)])
  ;; entry -> OperationDefinition join: the derived urn convention first, then the OD's own `code`
  ;; element — so an IG-shipped OD (with its real canonical url) validates its operation too
  (define od-by-url
    (for/hash ([od (in-list ods)]) (values (od-url od) od)))
  ;; od-for : code target -> OperationDefinition | #f   two definitions may share a code
  ;; (ValueSet/$validate-code and CodeSystem/$validate-code): the one defined on the entry's type
  ;; answers there — /ValueSet/$validate-code was held to CodeSystem's inputs and refused `system`
  (define (od-for code target)
    (define same (filter (lambda (od) (equal? (od-code od) code)) ods))
    (or (hash-ref od-by-url (op-code->canonical code) #f)
        (and target (findf (lambda (od) (member target (od-resources od))) same))
        (and (pair? same) (last same))))
  (define ops
    (for/hash ([e (in-list op-entries)])
      (define code (operation-entry-code e))
      (define od (od-for code (operation-entry-target e)))
      (values (list (operation-entry-level e) code (operation-entry-target e))
              (operation-handler (operation-entry-proc e) od
                                 (operation-entry-level e) (operation-entry-target e)))))
  (app cap ods (make-immutable-hasheq repo-entries) ops txn metadata))

(define (od-url od) (leaf->string (single (navigate (list od) 'url))))
(define (od-code od) (leaf->string (single (navigate (list od) 'code))))
;; od-resources : OperationDefinition -> (listof string)   the types it is defined on
(define (od-resources od) (map leaf->string (navigate (list od) 'resource)))

;; ---- dispatch -------------------------------------------------------------------------------

;; current-app : the app dispatching the current request (an operation reads its stored subjects
;; through it — capability/operations)
(define current-app (make-parameter #f))

(define (dispatch a req)
  ;; an app's own FHIR version for validation (a capability app is R6: its `$validate` and its
  ;; write checks read R5 by default, and said so in "All OK (FHIR R5 …)") — outside settings win
  (define pkgs (and (not (current-sd-packages)) (hash-ref (app-metadata a) 'sd-packages #f)))
  (parameterize ([current-app a] [current-sd-packages (or pkgs (current-sd-packages))]) (dispatch* a req)))

;; r6-sd-packages : -> (listof path)|#f   the R6 core package, what a capability app validates in
(define (r6-sd-packages)
  (define p (spec-package-path "hl7.fhir.r6.core.tgz" #:optional? #t))
  (and p (list p)))
(define (dispatch* a req)
  (case (request-kind req)
    [(read vread create update delete search history-instance history-type patch) (dispatch-interaction a req)]
    [(invoke) (dispatch-operation a req)]
    [else (operation-outcome-invalid (format "unknown request kind ~a" (request-kind req)))]))

(define (dispatch-interaction a req)
  (define repo (hash-ref (app-repositories a) (request-type req) #f))
  (cond
    [(not repo)
     (operation-outcome-not-supported (format "resource type ~a is not supported" (request-type req)))]
    [else
     (define fn (interaction-proc repo (request-kind req)))
     (cond
       [(not fn)
        (operation-outcome-not-supported
         (format "interaction ~a is not supported on ~a" (request-kind req) (request-type req)))]
       [(and (memq (request-kind req) '(create update)) (checked-references-app? a)
             (unheld-references a req))
        => (lambda (missing)
             (operation-outcome "error" "processing"
                                (format "~a refers to ~a, which this server does not hold (#:references \"checked\"): nothing was written; create ~a first"
                                        (request-type req) (string-join missing ", ") (if (= 1 (length missing)) "it" "them"))))]
       [else (parameterize ([current-search-strict? (or (current-search-strict?) (strict-search-app? a))])
               (guarded (lambda () (run-interaction (request-kind req) fn req repo))))])]))

;; checked-references-app? : app -> boolean   `(server #:references "checked")`: a create or update
;; whose literal reference names a resource the server does not hold is refused (a study server
;; stored an Observation of `Patient/nope` without a word)
(define (checked-references-app? a) (equal? (hash-ref (app-metadata a) 'references #f) "checked"))

;; unheld-references : app request -> (listof string) | #f   the body's relative literal references
;; (`Type/id`, a version dropped) to a type the server serves whose resource it does not hold; a
;; reference to a type it does not serve, a contained (`#x`), absolute or urn: one is not decided
(define (unheld-references a req)
  (define raw (current-request-json))
  (define js (if (and (hash? raw) (equal? (hash-ref raw 'resourceType #f) (format "~a" (request-type req))))
                 raw
                 (node->jsexpr (request-body req))))
  (define refs
    (remove-duplicates
     (let walk ([v js])
       (cond [(hash? v) (append (let ([r (hash-ref v 'reference #f)]) (if (string? r) (list r) '()))
                                (append-map walk (hash-values v)))]
             [(list? v) (append-map walk v)]
             [else '()]))))
  (define missing
    (for*/list ([r (in-list refs)]
                [m (in-value (regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]{1,64})(?:/_history/[^/]+)?$" r))]
                #:when m
                [repo (in-value (hash-ref (app-repositories a) (string->symbol (cadr m)) #f))]
                #:when (and repo (repository-read repo))
                #:unless ((repository-read repo) (caddr m)))
      (format "~a/~a" (cadr m) (caddr m))))
  (and (pair? missing) missing))

;; patient-subject-hint : name declared -> string | #f   `subject` refused where `patient` is declared
;; (or the other way): the two are FHIR's own pair on Observation and its kin — `patient` reads subject
;; when it is a Patient — and a client may send either (a rerun's agent expected one to answer the other)
(define (patient-subject-hint n declared)
  (cond [(and (equal? n "subject") (member "patient" declared))
         " (did you mean `patient`? it reads the subject when it is a Patient; declare `subject` too if clients send it)"]
        [(and (equal? n "patient") (member "subject" declared))
         " (did you mean `subject`? declare `patient` too if clients send it)"]
        [else #f]))
;; advertised-search-names : app|#f type -> (listof string)   the search parameters /metadata lists
(define (advertised-search-names a type)
  (if (not a) '()
      (for*/list ([rest (in-list (navigate (list (app-capability-statement a)) 'rest))]
                  [res (in-list (navigate (list rest) 'resource))]
                  #:when (equal? (leaf->string (single (navigate (list res) 'type))) (format "~a" type))
                  [sp (in-list (navigate (list res) 'searchParam))])
        (leaf->string (single (navigate (list sp) 'name))))))

;; strict-search-app? : app -> boolean   `(server #:search-handling "strict")`: every search is strict,
;; whatever the client prefers — a filter the server cannot apply (`subject` where only `patient` is
;; declared) is refused, never answered with every resource
(define (strict-search-app? a) (equal? (hash-ref (app-metadata a) 'search-handling #f) "strict"))

;; deleted? : repository id -> boolean   no current resource, but versions of it are kept (a
;; repository that keeps no history cannot say, and answers #f)
(define (deleted? repo id)
  (define history (repository-history repo))
  (and history
       (with-handlers ([exn:fail? (lambda (_) #f)]) (pair? (history id '(("_count" . "1")))))))

(define (interaction-proc repo kind)
  (case kind
    [(read) (repository-read repo)] [(vread) (repository-vread repo)]
    [(create) (repository-create repo)] [(update) (repository-update repo)]
    [(delete) (repository-delete repo)] [(search) (repository-search repo)]
    [(history-instance history-type) (repository-history repo)]
    [(patch) (repository-patch repo)]))

;; run-interaction : kind procedure request repository -> node
(define (run-interaction kind fn req repo)
  (case kind
    [(read)   (or (fn (request-id req))
                  ;; a resource that was here and was deleted is Gone (410), not Not Found: its
                  ;; versions remain to be read (https://hl7.org/fhir/http.html#read)
                  (if (deleted? repo (request-id req))
                      (operation-outcome "error" "deleted"
                                         (format "~a/~a was deleted; its versions remain at ~a/~a/_history"
                                                 (request-type req) (request-id req) (request-type req) (request-id req)))
                      (operation-outcome "error" "not-found" "resource not found")))]
    [(vread)  (or (fn (request-id req) (request-vid req))
                  (operation-outcome "error" "not-found" "version not found"))]
    [(create) (fn (request-body req))]
    [(update) (fn (request-id req) (request-body req))]
    [(delete) (begin (fn (request-id req))
                     (operation-outcome "information" "informational" "deleted"))]
    [(search)
     ;; `_summary=count` asks for the number of matches alone: the search with a page of none
     ;; (https://hl7.org/fhir/search.html#_summary; `_count=0` is the same request)
     (define count-only? (equal? (assq '_summary (request-params req)) '(_summary . "count")))
     (define params (if count-only?
                        (append (filter (lambda (p) (not (memq (car p) '(_summary _count _offset)))) (request-params req))
                                '((_count . "0")))
                        (request-params req)))
     (define r (fn params))
     (define-values (_ms _is names total) (search-facts r))
     ;; Prefer: handling=strict — a parameter the server cannot apply is an error, not a note
     (if (and (current-search-strict?) (pair? names))
         (let* (
                [declared (advertised-search-names (current-app) (request-type req))]
                [near (string-append* (for/list ([n (in-list names)]) (or (patient-subject-hint n declared) (did-you-mean n declared))))])
           (operation-outcome-invalid (format "search parameter~a ~a not supported here (strict search handling)~a; this server searches with what /metadata advertises~a"
                                              (if (> (length names) 1) "s" "")
                                              (apply string-append (add-between (map (lambda (n) (format "`~a`" n)) names) ", "))
                                              near
                                              ;; and the parameters every type has (a rerun's agent found them by trying)
                                              (if (pair? declared) (format " (~a: ~a; every type: _id, _lastUpdated, _count, _offset, _sort)" (request-type req) (string-join declared ", ")) ""))))
         (make-searchset r #:links (paging-links (request-type req) params total)))]
    [(patch)
     ;; JSON Patch (RFC 6902): read, apply atomically, then the repository's own UPDATE — so a patched
     ;; resource is validated exactly like a PUT; a malformed or failing patch is 422
     (define read (car fn)) (define update (cdr fn))
     (define cur (read (request-id req)))
     (cond
       [(not cur) (operation-outcome "error" "not-found" "resource not found")]
       [else
        (with-handlers ([exn:fail:json-patch? (lambda (e) (operation-outcome "error" "processing" (exn-message e)))])
          (define patched (apply-json-patch (node->jsexpr cur) (request-body req)))
          (define node (from-json (hash-set patched 'id (request-id req)) #:lenient? #t))
          (if (ok? node)
              (update (request-id req) (ok-value node))
              (operation-outcome "error" "processing" "the patched resource is not valid FHIR")))])]
    [(history-instance history-type)
     ;; a history closure answers #f for a level it does not support
     (define vs (fn (and (eq? kind 'history-instance) (request-id req)) (stringify-params (request-params req))))
     (if vs
         (make-history-bundle vs)
         (operation-outcome-not-supported
          (format "~a history is not supported on ~a" (if (eq? kind 'history-instance) "instance" "type")
                  (request-type req))))]))

(define (stringify-params ps)
  (for/list ([p (in-list ps)]) (cons (format "~a" (car p)) (format "~a" (cdr p)))))

;; make-history-bundle : (listof fhir) -> Bundle node   (type history, newest first)
;; Each entry carries the version and what produced it: version 1 a create (POST, 201), later ones
;; updates (PUT, 200) — https://hl7.org/fhir/http.html#history
(define (make-history-bundle versions)
  (define entries
    (for/list ([n (in-list versions)])
      (define js (node->jsexpr n))
      (define meta (hash-ref js 'meta (hasheq)))
      (define vid (hash-ref meta 'versionId "1"))
      (define t (hash-ref js 'resourceType)) (define id (hash-ref js 'id ""))
      (define first? (equal? vid "1"))
      (hasheq 'fullUrl (format "~a/~a" t id)
              'resource js
              'request (hasheq 'method (if first? "POST" "PUT") 'url (if first? t (format "~a/~a" t id)))
              'response (drop-false-hash
                         (hasheq 'status (if first? "201 Created" "200 OK")
                                 'etag (format "W/\"~a\"" vid)
                                 'lastModified (hash-ref meta 'lastUpdated #f))))))
  (ok-or-raise
   (from-json (hasheq 'resourceType "Bundle" 'type "history" 'total (length entries) 'entry entries))))

(define (drop-false-hash h) (for/hasheq ([(k v) (in-hash h)] #:when v) (values k v)))

;; served-at : app code -> string   where the app does serve an operation it was asked for elsewhere
;; (`POST /$validate` on an app serving it per type: "; it is served at POST /Patient/$validate, …")
(define (served-at a code)
  (define types (sort (remove-duplicates (filter values (for/list ([k (in-hash-keys (app-operations a))] #:when (equal? (cadr k) code))
                                                          (and (eq? (car k) 'type) (caddr k)))))
                      string<?))
  (define declared (sort (map symbol->string (hash-keys (app-repositories a))) string<?))
  (define paths (for/list ([t (in-list (if (member "Resource" types) declared types))]) (format "/~a/$~a" t code)))
  (define system? (for/or ([k (in-hash-keys (app-operations a))]) (and (equal? (cadr k) code) (eq? (car k) 'system))))
  (cond [(pair? paths) (format "; it is served at ~a" (string-join (take paths (min 4 (length paths))) ", "))]
        [system? (format "; it is served at /$~a" code)]
        [else ""]))

(define (dispatch-operation a req)
  (define key (list (request-level req) (request-code req) (target-of req)))
  ;; an operation defined on Resource answers for every type
  (define h (or (hash-ref (app-operations a) key #f)
                (and (target-of req)
                     (hash-ref (app-operations a) (list (request-level req) (request-code req) "Resource") #f))))
  (cond
    [(not h)
     (operation-outcome-not-supported
      (format "operation $~a is not supported at ~a level~a~a"
              (request-code req) (request-level req)
              (if (target-of req) (format " on ~a" (target-of req)) "")
              (served-at a (request-code req))))]
    [else
     (define in0 (parameters->hash (request-body req)))
     (define od (operation-handler-op-def h))
     ;; every problem with the inputs at once — unknown, missing, mistyped, outside a binding or a
     ;; range — one line each (a request with two mistyped inputs was told of one)
     (define-values (in type-problems) (if od (typed-inputs/problems od in0) (values in0 '())))
     (define problems (if od (in-declared-order od (append (input-problems od in0) type-problems (range-problems od in))) '()))
     (cond
       [(pair? problems) (inputs-outcome problems)]
       [else
        ;; a handler that raises is a 500 saying what raised and how to refuse instead (a client
        ;; got `expt: undefined for 0 and -0.241`, the handler's author no hint)
        (define r (with-handlers ([exn:fail? (lambda (e)
                                               (operation-outcome-exception
                                                (format "the $~a handler raised: ~a — ~a"
                                                        (request-code req) (built-value-message (exn-message e))
                                                        (handler-crash-hint (exn-message e)))))])
                    ((operation-handler-proc h) in req)))
        ;; what a declared operation answers is what it declares (a handler's undeclared output was
        ;; served 200, so /OperationDefinition no longer said what the operation returns)
        (define out-problems (if (and od (fhir? r) (eq? (fhir-type r) 'Parameters) (declared-here? od))
                                 (output-problems od r)
                                 '()))
        (cond
          [(pair? out-problems)
           (operation-outcome-exception
            (format "the $~a handler's answer does not match its #:out: ~a — return exactly the declared outputs, each with its declared type"
                    (request-code req) (string-join out-problems "; ")))]
          [else
        (when (and (fhir? r) (eq? (fhir-type r) 'OperationOutcome) (operation-handler-op-def h)
                   (returns-outcome? (operation-handler-op-def h))
                   (not (member (outcome-code r) '("exception" "not-found")))
                   (not (hash-ref refusals r #f)))
          (hash-set! results r #t))
        r])])]))

;; declared-here? : OperationDefinition -> boolean   an operation an app declares inline (its
;; canonical is the app's urn) — a registered operation's definition is the package's, not checked here
(define (declared-here? od)
  (define u (hash-ref (node->jsexpr od) 'url #f))
  (and (string? u) (regexp-match? #rx"^urn:fhir-capability:operation:" u)))

;; output-problems : OperationDefinition Parameters -> (listof string)   each output the handler gave
;; that the definition does not declare (with the nearest), each required one it left out, and each
;; given with another type than declared (`valueString` for a decimal)
(define (output-problems od r)
  ;; read from the definition's JSON (its min is an integer leaf)
  (define outs (for/list ([p (in-list (hash-ref (node->jsexpr od) 'parameter '()))]
                          #:when (equal? (hash-ref p 'use #f) "out"))
                 p))
  (define (name-of p) (hash-ref p 'name ""))
  (define (type-of p) (hash-ref p 'type #f))
  (define (min-of p) (let ([m (hash-ref p 'min 0)]) (if (number? m) m 0)))
  (define names (map name-of outs))
  (define js (node->jsexpr r))
  (define given (for/list ([pp (in-list (hash-ref js 'parameter '()))]) pp))
  (define given-names (map (lambda (pp) (hash-ref pp 'name "")) given))
  (append
   (for/list ([n (in-list (remove-duplicates given-names))] #:unless (member n names))
     (format "`~a` is not a declared output~a" n
             (let ([near (did-you-mean n names)])
               (if (string=? near "") (format " (it declares ~a)" (if (null? names) "none" (string-join names ", "))) near))))
   (for/list ([p (in-list outs)] #:when (>= (min-of p) 1) #:unless (member (name-of p) given-names))
     (format "the required output `~a` is missing" (name-of p)))
   (for*/list ([pp (in-list given)]
               [p (in-value (findf (lambda (p) (equal? (name-of p) (hash-ref pp 'name ""))) outs))]
               #:when (and p (type-of p))
               [t (in-value (type-of p))]
               [key (in-value (for/first ([k (in-hash-keys pp)] #:when (regexp-match? #rx"^value" (symbol->string k))) (symbol->string k)))]
               #:when (and key (not (string-ci=? key (string-append "value" t)))))
     (format "`~a` is declared ~a but given as ~a" (hash-ref pp 'name) t key))))
;; handler-crash-hint : message -> string   what to do, by what failed: a value the handler BUILT that
;; FHIR refuses (`decimal: "58." does not match …` — the hint used to say to refuse an input), or
;; anything else (refuse the input instead of raising)
(define (handler-crash-hint msg)
  (if (built-value-problem? msg)
      (string-append "a value the handler built is not valid FHIR"
                     (if (regexp-match? #rx"decimal:" msg)
                         ": give a decimal as a Racket number, `(valueDecimal 57.5)`, or a string FHIR reads (\"58\" or \"57.5\", not \"58.\")"
                         ""))
      "to refuse an input, return an OperationOutcome whose issue code is `invalid` (a 400), or declare the input's range (#:min, #:max)"))
(define (built-value-problem? msg) (regexp-match? #rx"^fhir: [A-Za-z]+: |invalid [A-Za-z]+ value" msg))
;; built-value-message : message -> message   the format check's regexp left out (it read as noise)
(define (built-value-message msg)
  (regexp-replace #px" does not match \\^[^ ]*\\$" msg " is not a valid value"))

(define (outcome-code n)
  (define issues (let ([v (fhir-ref n 'issue #f)]) (if (list? v) v (if v (list v) '()))))
  (and (pair? issues) (let ([c (fhir-ref (car issues) 'code #f)]) (and c (leaf->string c)))))

;; typed-inputs : OperationDefinition inputs -> inputs | problem-string   each primitive input as its
;; declared type says, the same whether it came in a GET query (text) or a POSTed Parameters
;; (FHIRPath values): integer types -> exact integers, decimal -> a Racket real, boolean -> #t/#f,
;; everything else (string, code, uri, date, dateTime, …) -> the text as sent; resources stay nodes.
;; A value that is not of its type is a problem naming the input.
(define (typed-inputs od in)
  (define-values (typed problems) (typed-inputs/problems od in))
  (if (pair? problems) (car problems) typed))
;; typed-inputs/problems : OperationDefinition inputs -> (values inputs (listof problem-string))
;; every input typed, and every one that is not of its type said (a value that is not keeps its text)
(define (typed-inputs/problems od in)
  (define types (for/hash ([p (in-list (navigate (list od) 'parameter))]
                           #:when (equal? (leaf->string (single (navigate (list p) 'use))) "in"))
                  (values (leaf->string (single (navigate (list p) 'name)))
                          (let ([t (single (navigate (list p) 'type))]) (and t (leaf->string t))))))
  (define problems '())
  (define typed
    (for/hash ([(name vs) (in-hash in)])
      (define type (hash-ref types name #f))
      (values name
              (for/list ([v (in-list vs)])
                (define c (typed-value type v))
                (cond [(eq? c 'bad)
                       (set! problems (cons (format "parameter '~a' must be ~a ~a, got ~a" name (if (regexp-match? #rx"^[aeiou]" (format "~a" type)) "an" "a") type (shown v)) problems))
                       (raw-text v)]
                      [else c])))))
  (values typed (sort problems string<?)))

;; in-declared-order : OperationDefinition (listof problem-string) -> (listof problem-string)   the
;; problems in the order the inputs are declared (`creatinine`, `age`, `sex`), unknown inputs last
(define (in-declared-order od problems)
  (define names (for/list ([p (in-list (navigate (list od) 'parameter))]) (leaf->string (single (navigate (list p) 'name)))))
  (define (rank p)
    (define m (regexp-match #rx"^parameter '([^']+)'" p))
    (or (and m (index-of names (cadr m))) (length names)))
  (sort problems < #:key rank))

;; range-problems : OperationDefinition typed-inputs -> (listof problem-string)   a number outside
;; the range its parameter declares (`#:min`/`#:max`, the core minValue/maxValue extensions)
(define min-url "http://hl7.org/fhir/StructureDefinition/minValue")
(define max-url "http://hl7.org/fhir/StructureDefinition/maxValue")
(define (range-problems od in)
  (for*/list ([p (in-list (navigate (list od) 'parameter))]
              #:when (equal? (leaf->string (single (navigate (list p) 'use))) "in")
              [name (in-value (leaf->string (single (navigate (list p) 'name))))]
              [bound (in-list (param-bounds p))]
              [v (in-list (hash-ref in name '()))]
              #:when (real? v)
              #:unless ((car bound) v (cdr bound)))
    (format "parameter '~a' must be ~a ~a, got ~a" name (if (eq? (car bound) >=) "at least" "at most") (number-text (cdr bound)) (number-text v))))
;; number-text : real -> string   10 for 10.0, as the declaration wrote it
(define (number-text n) (number->string (if (and (inexact? n) (integer? n)) (inexact->exact n) n)))
;; param-bounds : parameter -> (listof (cons comparison number))
(define (param-bounds p)
  (for*/list ([e (in-list (navigate (list p) 'extension))]
              [url (in-value (let ([u (single (navigate (list e) 'url))]) (and u (leaf->string u))))]
              #:when (member url (list min-url max-url))
              [v (in-value (let ([x (single (navigate (list e) 'value))]) (and x (item->system x))))]
              #:when v)
    (cons (if (equal? url min-url) >= <=)
          (if (fp-decimal? v) (exact->inexact (decimal->exact v)) v))))
(define (raw-text v)
  (cond [(string? v) v]
        [(fp-decimal? v) (decimal->string v)]
        [(fhir? v) v]
        [else (let ([j (item->json v)]) (regexp-replace #rx"^@T?" (if (string? j) j (format "~a" j)) ""))]))   ; a date or time, as FHIR writes it (no FHIRPath @)
(define (shown v) (if (string? v) (format "\"~a\"" v) (format "~a" (raw-text v))))
(define (typed-value type v)
  (cond
    [(fhir? v) v]
    [(member type '("integer" "positiveInt" "unsignedInt" "integer64"))
     ;; a whole number written as a decimal (`60.0`, as JSON clients write numbers) is that integer
     (define n (cond [(exact-integer? v) v] [(fp-decimal? v) (decimal->exact v)] [(real? v) v]
                     [(string? v) (string->number v 10)] [else #f]))
     (if (and (real? n) (integer? n)) (inexact->exact n) 'bad)]
    [(equal? type "decimal")
     (define n (cond [(fp-decimal? v) (exact->inexact (decimal->exact v))] [(real? v) v] [(string? v) (string->number v 10)] [else #f]))
     (if (real? n) n 'bad)]
    [(equal? type "boolean")
     (cond [(boolean? v) v] [(member v '("true")) #t] [(member v '("false")) #f] [else 'bad])]
    [else (raw-text v)]))

(define (target-of req) (and (request-type req) (symbol->string (request-type req))))

;; run a handler/closure, converting any raised exn into an OperationOutcome
(define (guarded thunk)
  (with-handlers ([exn:fail? (lambda (e) (operation-outcome-exception (exn-message e)))])
    (thunk)))

;; ---- operation input extraction + validation ------------------------------------------------

;; parameters->hash : Parameters node | #f -> hash[string -> (listof value)]
;; value is a collapsed System value (for value[x] leaves) or a nested fhir node (resource/Coding).
(define (parameters->hash node)
  (cond
    [(not node) (hash)]
    [else
     (for/fold ([h (hash)]) ([p (in-list (navigate (list node) 'parameter))])
       (define name (leaf->string (single (navigate (list p) 'name))))
       (define vals (let ([v (navigate (list p) 'value)])
                      (if (null? v) (navigate (list p) 'resource) v)))
       (if name
           (hash-update h name (lambda (old) (append old (map collapse vals))) '())
           h))]))

(define (collapse item) (if (fhir? item) item (item->system item)))

;; validate the input hash against the OperationDefinition contract; #f = ok, else an OperationOutcome
(define (validate-inputs op-def in)
  (define problems (input-problems op-def in))
  (and (pair? problems) (inputs-outcome problems)))
;; input-problems : OperationDefinition inputs -> (listof problem-string)   unknown, missing, too
;; many, outside a required binding
(define (input-problems op-def in)
  (define ins (for/list ([p (in-list (navigate (list op-def) 'parameter))]
                         #:when (equal? (leaf->string (single (navigate (list p) 'use))) "in"))
                p))
  (define names (map (lambda (p) (leaf->string (single (navigate (list p) 'name)))) ins))
  ;; an input the definition does not name is refused, as an unknown keyword is in-process (a
  ;; misspelt `weigth` would otherwise be dropped and the operation answer without it); `_format`
  ;; and the other `_` parameters are HTTP's
  (define unknown-keys (for/list ([k (in-list (sort (hash-keys in) string<?))]
                                  #:unless (member k names)
                                  #:unless (regexp-match? #rx"^_" k))
                        k))
  ;; one unknown input given and one required input missing: the one was meant for the other, however
  ;; far apart they are spelt (`hr` for `heartRate` read as two unrelated problems)
  (define missing-required (for/list ([p (in-list ins)]
                                      #:when (let ([m (single (navigate (list p) 'min))]) (and m (let ([v (item->system m)]) (and (integer? v) (>= v 1)))))
                                      #:when (null? (hash-ref in (leaf->string (single (navigate (list p) 'name))) '())))
                             p))
  (define lone (and (= 1 (length unknown-keys)) (= 1 (length missing-required)) (car unknown-keys)))
  (define unknown (for/list ([k (in-list unknown-keys)])
                    (format "parameter '~a' is not an input of $~a~a" k
                            (leaf->string (single (navigate (list op-def) 'code)))
                            (let ([near (did-you-mean k names)])
                              (cond [(not (string=? near "")) near]
                                    [(null? names) " (it takes none)"]
                                    [(<= (length names) 8) (format " (it takes ~a)" (apply string-append (add-between names ", ")))]
                                    [else ""])))))
  (define declared-problems
    (for*/list ([p (in-list ins)]
                [problem (in-value (or (validate-one p in lone) (validate-binding p in)))]
                #:when problem)
      problem))
  ;; an unknown input a "required" problem already names (`hr` given for `heartRate`, `xx` for `x`) is
  ;; that one mistake, said once (it was two issues: "required …" and "'hr' is not an input")
  (define claimed (for*/list ([pr (in-list declared-problems)]
                              [m (in-value (regexp-match #rx"is required [(]`([^`]+)` was given" pr))]
                              #:when m)
                    (cadr m)))
  (append (for/list ([k (in-list unknown-keys)] [u (in-list unknown)] #:unless (member k claimed)) u)
          declared-problems))

;; operation-result? : node -> boolean   an OperationOutcome an operation answers AS ITS RESULT (its
;; definition's `return` is an OperationOutcome: $validate) — the HTTP layer answers it 200 whatever
;; its issues say, where an OperationOutcome a handler returns otherwise is the request's failure
(define results (make-weak-hasheq))
(define (operation-result? n) (hash-ref results n #f))
;; refused! : OperationOutcome node -> node   the REQUEST's failure, said before the operation ran (a body
;; of the wrong type): never the operation's result, so it answers by its issue code (400), not 200
(define refusals (make-weak-hasheq))
(define (refused! n) (hash-set! refusals n #t) n)
(define (returns-outcome? od)
  (for/or ([p (in-list (navigate (list od) 'parameter))])
    (and (equal? (leaf->string (single (navigate (list p) 'use))) "out")
         (equal? (leaf->string (single (navigate (list p) 'name))) "return")
         (let ([t (single (navigate (list p) 'type))]) (and t (equal? (leaf->string t) "OperationOutcome"))))))

;; validate-binding : parameter inputs -> problem | #f   a value of an input bound (required) to a value
;; set must be one of its codes: `[sex code 1 1 #:binding ".../administrative-gender"]` refuses
;; `unknown-sex` before the handler runs. A value set that does not expand here decides nothing.
(define (validate-binding p in)
  (define name (leaf->string (single (navigate (list p) 'name))))
  (define b (single (navigate (list p) 'binding)))
  (define strength (and b (leaf->string (single (navigate (list b) 'strength)))))
  (define vs (and b (let ([v (single (navigate (list b) 'valueSet))]) (and v (leaf->string v)))))
  (define codes (and vs (equal? strength "required") (value-set-codes vs)))
  (and codes
       (for/or ([v (in-list (hash-ref in name '()))])
         (define code (let ([t (raw-text v)]) (and (string? t) t)))
         (and code (not (member code codes))
              ;; the codes once, then where they come from (the inline VCL listed them twice)
              (format "parameter '~a' must be ~a, got \"~a\" (value set ~a)" name (codes-text codes) code (shown-value-set vs))))))

;; codes-text : (listof code) -> string   `female or male`, `one of a, b, c`, at most 12 named
(define (codes-text codes)
  (match codes
    [(list a) a]
    [(list a b) (format "~a or ~a" a b)]
    [_ (format "one of ~a~a" (apply string-append (add-between (take codes (min 12 (length codes))) ", "))
               (if (> (length codes) 12) ", …" ""))]))

;; shown-value-set : url -> string   a value set as a message names it: an implicit VCL value set by
;; its expression, decoded (`(http://hl7.org/fhir/administrative-gender)(female;male)`)
(define (shown-value-set url)
  (define m (regexp-match #rx"^http://fhir[.]org/VCL[?]v1=(.*)$" url))
  (if m (with-handlers ([exn:fail? (lambda (_) url)]) (uri-decode (cadr m))) url))

;; value-set-codes : url -> (listof code) | #f   its expansion's codes ($expand, fhir-tx), once per url
(define expansions (make-hash))
(define (value-set-codes url)
  (hash-ref! expansions url
             (lambda ()
               (with-handlers ([exn:fail? (lambda (_) #f)])
                 (dynamic-require 'fhir/terminology/operations #f)
                 (define ex ((dynamic-require 'fhir/operation 'apply-operation) "ValueSet/$expand" #:url url))
                 (define contains (hash-ref (hash-ref ex 'expansion (hasheq)) 'contains '()))
                 (and (pair? contains) (for/list ([c (in-list contains)]) (hash-ref c 'code)))))))

;; returns a problem string, or #f if the parameter is satisfied
(define (validate-one p in [lone #f])
  (define name (leaf->string (single (navigate (list p) 'name))))
  (define minv (let ([m (single (navigate (list p) 'min))]) (if m (item->system m) 0)))
  (define maxv (leaf->string (single (navigate (list p) 'max))))
  (define present (hash-ref in name '()))
  (define n (length present))
  (cond
    [(and (integer? minv) (= n 0) (>= minv 1))
     ;; required and absent: said so, with the misspelt input it probably was (`creatinin`)
     (define near (for/first ([k (in-list (sort (hash-keys in) string<?))]
                              #:unless (equal? k name)
                              #:when (not (string=? (did-you-mean k (list name)) "")))
                    k))
     (format "parameter '~a' is required~a" name
             (cond [near (format " (`~a` was given: a misspelling of it?)" near)]
                   [lone (format " (`~a` was given instead: is it this input?)" lone)]
                   [else ""]))]
    [(and (integer? minv) (< n minv))
     (format "parameter '~a' requires at least ~a value(s), got ~a" name minv n)]
    [(and (equal? maxv "1") (> n 1))
     (format "parameter '~a' allows at most 1 value, got ~a" name n)]
    [else #f]))

;; ---- declaration errors found when the app is built ------------------------------------------

;; exn:fail:declaration : a resource declaration the app cannot be built with (a search parameter FHIR
;; does not define for the type), known only once the core package is read — after the module expanded
(struct exn:fail:declaration exn:fail:user (type) #:transparent)

;; with-declared-locations : (listof (cons type "file:line:col")) (-> any) -> any
;; runs the build, saying a declaration error at the resource form it is about, one line — it was a
;; Racket error with a stack trace through the store's internals, and `serve` died without a word
(define (with-declared-locations locs thunk)
  (with-handlers ([exn:fail:declaration?
                   (lambda (e)
                     (define at (assq (exn:fail:declaration-type e) locs))
                     (raise (exn:fail:user (if at
                                               (format "~a: resource ~a: ~a" (cdr at) (exn:fail:declaration-type e) (exn-message e))
                                               (exn-message e))
                                           (current-continuation-marks))))])
    (thunk)))

;; ---- node construction ----------------------------------------------------------------------

;; make-searchset : SearchResult [#:links (listof link)] -> Bundle node
;; Entries are marked search.mode match | include | outcome; `total` counts every match — includes
;; and outcomes are not matches (https://hl7.org/fhir/search.html#include) — and `links` are the
;; paging links (`paging-links`).
(define (make-searchset result #:links [links '()])
  (define-values (matches includes ignored total) (search-facts result))
  (define (entry n mode) (hasheq 'resource (node->jsexpr n) 'search (hasheq 'mode mode)))
  ;; a parameter the server does not support is ignored, as FHIR allows — and said so, in an
  ;; OperationOutcome entry (https://hl7.org/fhir/search.html#errors): without it, `?birthdate=lt1900`
  ;; on a server that cannot search birthdate looks like every patient matched
  (define outcome
    (if (null? ignored) '()
        (list (hasheq 'resource (hasheq 'resourceType "OperationOutcome"
                                        'issue (for/list ([n (in-list ignored)])
                                                 (hasheq 'severity "warning" 'code "not-supported"
                                                         'diagnostics (format "search parameter `~a` is not supported here: it was ignored" n))))
                      'search (hasheq 'mode "outcome")))))
  (ok-or-raise
   (from-json
    ;; `link` and `entry` only when there are some: an empty array is not FHIR JSON
    ;; (https://hl7.org/fhir/json.html#null) — a search that matched nothing answered `"entry":[]`
    (for/fold ([bundle (hasheq 'resourceType "Bundle" 'type "searchset"
                               ;; every match, not this page's (https://hl7.org/fhir/bundle-definitions.html#Bundle.total)
                               'total total)])
              ([key (in-list '(link entry))]
               ;; a nested resource inside a Bundle entry is given to from-json as jsexpr
               [items (in-list (list links (append (for/list ([n (in-list matches)]) (entry n "match"))
                                                   (for/list ([n (in-list includes)]) (entry n "include"))
                                                   outcome)))]
               #:when (pair? items))
      (hash-set bundle key items)))))

(define (operation-outcome severity code diagnostics)
  (ok-or-raise
   (from-json (hasheq 'resourceType "OperationOutcome"
                      'issue (list (hasheq 'severity severity 'code code
                                           'diagnostics diagnostics))))))
;; inputs-outcome : (listof problem) -> OperationOutcome   one issue per problem, each naming its input
;; in `expression` (`[x]`), as FHIR places an issue: one string of every problem joined by `;` read as
;; one problem and a client could not tell which input to fix
(define (inputs-outcome problems)
  (ok-or-raise
   (from-json (hasheq 'resourceType "OperationOutcome"
                      'issue (for/list ([p (in-list problems)])
                               (define name (let ([m (regexp-match #rx"^parameter '([^']+)'" p)]) (and m (cadr m))))
                               (define i (hasheq 'severity "error" 'code "invalid" 'diagnostics p))
                               (if name (hash-set i 'expression (list name)) i))))))
(define (operation-outcome-not-supported msg) (operation-outcome "error" "not-supported" msg))
(define (operation-outcome-invalid msg)       (operation-outcome "error" "invalid" msg))
(define (operation-outcome-exception msg)     (operation-outcome "error" "exception" msg))

;; ---- request records ------------------------------------------------------------------------

;; kind: 'read 'vread 'create 'update 'delete 'search 'invoke
(struct request (kind type id vid params level code body) #:transparent)

(define (read-request t id)        (request 'read   t id #f '() 'instance #f #f))
(define (vread-request t id vid)   (request 'vread  t id vid '() 'instance #f #f))
(define (create-request t node)    (request 'create t #f #f '() 'type #f node))
(define (update-request t id node) (request 'update t id #f '() 'instance #f node))
(define (delete-request t id)      (request 'delete t id #f '() 'instance #f #f))
;; patch-request : the body is the JSON Patch document (a list of operations), not a resource
(define (patch-request t id ops) (request 'patch t id #f '() 'instance #f ops))
(define (history-request t id [params '()])
  (request (if id 'history-instance 'history-type) t id #f params (if id 'instance 'type) #f #f))
(define (search-request t [params '()]) (request 'search t #f #f params 'type #f #f))
(define (invoke-request #:code code #:level [level 'type] #:type [type #f] #:id [id #f] #:body [body #f])
  (request 'invoke type id #f '() level code body))

;; ---- small helpers --------------------------------------------------------------------------

(define (single xs) (and (pair? xs) (car xs)))
(define (leaf->string x) (let ([v (and x (item->system x))]) (and (string? v) v)))
(define (string-join* xs) (apply string-append (add-between xs "; ")))

(module+ test
  (require rackunit
           (only-in fhir/r6/types)
           (only-in "derive.rkt" rc-operation rc-param derive-operation-definition))
  ;; parameters->hash round-trip
  (define params (ok-or-raise
                  (from-json (hasheq 'resourceType "Parameters"
                                     'parameter (list (hasheq 'name "url" 'valueUri "http://x")
                                                      (hasheq 'name "count" 'valueInteger 3))))))
  (define h (parameters->hash params))
  (check-equal? (hash-ref h "url") '("http://x"))
  (check-equal? (hash-ref h "count") '(3))
  ;; validate-inputs against a derived OperationDefinition (url required, min 1)
  (define od (derive-operation-definition
              (rc-operation "expand" "$expand" (list #f #t #f) '("ValueSet")
                            (list (rc-param "url" "uri" 1 1 "in")) '() #f)))
  (check-false (validate-inputs od (hash "url" '("http://x"))))       ; ok
  (check-true (fhir? (validate-inputs od (hash))))                    ; missing required -> OO
  ;; a repository dispatch round-trip
  (define store (make-hash))
  (define repo (make-repository
                #:create (lambda (n) (hash-set! store "1" n) n)
                #:read   (lambda (id) (hash-ref store id #f))))
  (define pat (ok-or-raise (from-json (hasheq 'resourceType "Patient" 'id "1"))))
  (define a (build-app #:capability pat #:operation-definitions '()
                       #:repositories (list (cons 'Patient repo)) #:operations '()))
  (check-eq? (fhir-type (dispatch a (create-request 'Patient pat))) 'Patient)
  (check-eq? (fhir-type (dispatch a (read-request 'Patient "1"))) 'Patient)
  (check-eq? (fhir-type (dispatch a (read-request 'Observation "1"))) 'OperationOutcome)  ; not supported
  (check-eq? (fhir-type (dispatch a (delete-request 'Patient "1"))) 'OperationOutcome))   ; delete unsupported
