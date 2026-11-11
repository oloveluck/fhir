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
  [make-searchset (-> any/c fhir?)]
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
;; what a repository's search may return instead of a plain list: matches + _include'd resources
(struct search-result (matches includes) #:transparent)
;; search-result/ignored : matches includes (listof param-name) -> search-result   the parameters the
;; search could not apply, which the searchset reports (an OperationOutcome entry, mode "outcome")
(struct search-result/ignored search-result (names) #:transparent)
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
  (define od-by-code
    (for/hash ([od (in-list ods)]) (values (od-code od) od)))
  (define ops
    (for/hash ([e (in-list op-entries)])
      (define code (operation-entry-code e))
      (define od (or (hash-ref od-by-url (op-code->canonical code) #f)
                     (hash-ref od-by-code code #f)))
      (values (list (operation-entry-level e) code (operation-entry-target e))
              (operation-handler (operation-entry-proc e) od
                                 (operation-entry-level e) (operation-entry-target e)))))
  (app cap ods (make-immutable-hasheq repo-entries) ops txn metadata))

(define (od-url od) (leaf->string (single (navigate (list od) 'url))))
(define (od-code od) (leaf->string (single (navigate (list od) 'code))))

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
       [else (parameterize ([current-search-strict? (or (current-search-strict?) (strict-search-app? a))])
               (guarded (lambda () (run-interaction (request-kind req) fn req))))])]))

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

(define (interaction-proc repo kind)
  (case kind
    [(read) (repository-read repo)] [(vread) (repository-vread repo)]
    [(create) (repository-create repo)] [(update) (repository-update repo)]
    [(delete) (repository-delete repo)] [(search) (repository-search repo)]
    [(history-instance history-type) (repository-history repo)]
    [(patch) (repository-patch repo)]))

(define (run-interaction kind fn req)
  (case kind
    [(read)   (or (fn (request-id req)) (operation-outcome "error" "not-found" "resource not found"))]
    [(vread)  (or (fn (request-id req) (request-vid req))
                  (operation-outcome "error" "not-found" "version not found"))]
    [(create) (fn (request-body req))]
    [(update) (fn (request-id req) (request-body req))]
    [(delete) (begin (fn (request-id req))
                     (operation-outcome "information" "informational" "deleted"))]
    [(search)
     (define r (fn (request-params req)))
     ;; Prefer: handling=strict — a parameter the server cannot apply is an error, not a note
     (if (and (current-search-strict?) (search-result/ignored? r))
         (let* ([names (search-result/ignored-names r)]
                [declared (advertised-search-names (current-app) (request-type req))]
                [near (string-append* (for/list ([n (in-list names)]) (did-you-mean n declared)))])
           (operation-outcome-invalid (format "search parameter~a ~a not supported here (strict search handling)~a; this server searches with what /metadata advertises~a"
                                              (if (> (length names) 1) "s" "")
                                              (apply string-append (add-between (map (lambda (n) (format "`~a`" n)) names) ", "))
                                              near
                                              ;; and the parameters every type has (a rerun's agent found them by trying)
                                              (if (pair? declared) (format " (~a: ~a; every type: _id, _lastUpdated, _count, _offset, _sort)" (request-type req) (string-join declared ", ")) ""))))
         (make-searchset r))]
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
        (when (and (fhir? r) (eq? (fhir-type r) 'OperationOutcome) (operation-handler-op-def h)
                   (returns-outcome? (operation-handler-op-def h))
                   (not (member (outcome-code r) '("exception" "not-found")))
                   (not (hash-ref refusals r #f)))
          (hash-set! results r #t))
        r])]))
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
  (define unknown (for/list ([k (in-list (sort (hash-keys in) string<?))]
                             #:unless (member k names)
                             #:unless (regexp-match? #rx"^_" k))
                    (format "parameter '~a' is not an input of $~a~a" k
                            (leaf->string (single (navigate (list op-def) 'code)))
                            (let ([near (did-you-mean k names)])
                              (cond [(not (string=? near "")) near]
                                    [(null? names) " (it takes none)"]
                                    [(<= (length names) 8) (format " (it takes ~a)" (apply string-append (add-between names ", ")))]
                                    [else ""])))))
  (define problems
    (append unknown
            (for*/list ([p (in-list ins)]
                        [problem (in-value (or (validate-one p in) (validate-binding p in)))]
                        #:when problem)
              problem)))
  problems)

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
(define (validate-one p in)
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
     (format "parameter '~a' is required~a" name (if near (format " (`~a` was given: a misspelling of it?)" near) ""))]
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

;; make-searchset : (or (listof node) search-result) -> Bundle node
;; A repository's search may return plain matches, or a `search-result` that also carries the
;; resources pulled in by _include/_revinclude; entries are marked search.mode match | include and
;; `total` counts matches only (https://hl7.org/fhir/search.html#include).
(define (make-searchset result)
  (define-values (matches includes)
    (if (search-result? result)
        (values (search-result-matches result) (search-result-includes result))
        (values result '())))
  (define ignored (if (search-result/ignored? result) (search-result/ignored-names result) '()))
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
   (from-json (hasheq 'resourceType "Bundle" 'type "searchset"
                      'total (length matches)
                      ;; a nested resource inside a Bundle entry is given to from-json as jsexpr
                      'entry (append (for/list ([n (in-list matches)]) (entry n "match"))
                                     (for/list ([n (in-list includes)]) (entry n "include"))
                                     outcome)))))

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
