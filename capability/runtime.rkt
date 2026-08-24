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
         racket/list
         (only-in "../model/node.rkt" fhir? fhir-type fhir-ref fhir-field-names)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../serialize/to-json.rkt" node->jsexpr)
         (only-in "../result/result.rkt" ok-or-raise)
         (only-in "../fhirpath/navigate.rkt" navigate)
         (only-in "../fhirpath/value.rkt" item->system)
         (only-in "../fhirpath/eval.rkt" eval-fhirpath)
         (only-in "../fhirpath/parser/parse.rkt" parse-fhirpath)
         (only-in "derive.rkt" op-code->canonical))

(provide
 (struct-out repository)
 (struct-out operation-handler)
 (struct-out operation-entry)
 (struct-out app)
 (struct-out request)
 (contract-out
  [make-repository (->* () (#:read (or/c procedure? #f) #:vread (or/c procedure? #f)
                            #:create (or/c procedure? #f) #:update (or/c procedure? #f)
                            #:delete (or/c procedure? #f) #:search (or/c procedure? #f))
                       repository?)]
  ;; a generic in-memory repository: type, declared interactions, search-params (list name type expr)
  [make-default-repository (-> symbol? (listof symbol?) (listof list?) repository?)]
  [build-app (->* (#:capability fhir? #:operation-definitions (listof fhir?)
                   #:repositories (listof (cons/c symbol? repository?))
                   #:operations (listof operation-entry?))
                  (#:transaction (or/c #f (-> hash? hash?))) app?)]
  [dispatch (-> app? request? fhir?)]
  ;; request smart constructors
  [read-request   (-> symbol? string? request?)]
  [vread-request  (-> symbol? string? string? request?)]
  [create-request (-> symbol? fhir? request?)]
  [update-request (-> symbol? string? fhir? request?)]
  [delete-request (-> symbol? string? request?)]
  [search-request (->* (symbol?) ((listof (cons/c symbol? string?))) request?)]
  [invoke-request (->* (#:code string?) (#:level (or/c 'system 'type 'instance)
                        #:type (or/c symbol? #f) #:id (or/c string? #f) #:body (or/c fhir? #f))
                       request?)]
  ;; OperationOutcome constructors (exposed for handlers)
  [operation-outcome (-> string? string? string? fhir?)]
  [operation-outcome-not-supported (-> string? fhir?)]
  [operation-outcome-invalid (-> string? fhir?)]
  [operation-outcome-exception (-> string? fhir?)]
  [parameters->hash (-> (or/c fhir? #f) hash?)]))

;; ---- capability handlers (struct-of-closures) -----------------------------------------------

;; each field is a closure or #f (#f => that interaction is not supported)
(struct repository (read vread create update delete search) #:transparent)

(define (make-repository #:read [read #f] #:vread [vread #f] #:create [create #f]
                         #:update [update #f] #:delete [delete #f] #:search [search #f])
  (repository read vread create update delete search))

;; a ready-made in-memory repository implementing exactly the declared interactions. Search evaluates
;; each declared search-param's FHIRPath expression against stored resources (a param without an
;; expression, or an unknown query param, is ignored — FHIR lenient handling).
(define (make-default-repository type interactions sps)
  (define store (make-hash))                 ; id(string) -> resource node
  (define counter (box 0))
  (define (has? k) (and (memq k interactions) #t))
  (define (put! node id) (define stored (node-with-id node id)) (hash-set! store id stored) stored)
  (repository
   (and (has? 'read)        (lambda (id) (hash-ref store id #f)))
   (and (has? 'vread)       (lambda (id vid) (hash-ref store id #f)))    ; no version history: latest
   (and (has? 'create)      (lambda (node) (put! node (or (node-id node) (next-id! counter)))))
   (and (has? 'update)      (lambda (id node) (put! node id)))
   (and (has? 'delete)      (lambda (id) (hash-remove! store id)))
   (and (has? 'search-type) (lambda (params) (store-search store sps params)))))

(define (next-id! b) (set-box! b (add1 (unbox b))) (number->string (unbox b)))
(define (node-id n) (let ([v (fhir-ref n 'id #f)]) (and v (leaf->string v))))
(define (node-with-id n id) (ok-or-raise (from-json (hash-set (node->jsexpr n) 'id id) #:lenient? #t)))

(define (store-search store sps params)
  (for/list ([r (in-list (hash-values store))] #:when (matches-params? r sps params)) r))
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
;; produced by the #lang emitter, paired with its OperationDefinition in build-app
(struct operation-entry (level code target proc) #:transparent)

;; ---- the application ------------------------------------------------------------------------

;; repositories : hasheq type-sym -> repository ; operations : hash (list level code target) -> handler
;; transaction : (jsexpr-Bundle -> jsexpr-Bundle) | #f — the whole-Bundle processor (POST /);
;; #f (the default) means transaction/batch is not supported by this app
(struct app (capability-statement operation-definitions repositories operations transaction)
  #:transparent)

(define (build-app #:capability cap #:operation-definitions ods
                   #:repositories repo-entries #:operations op-entries
                   #:transaction [txn #f])
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
  (app cap ods (make-immutable-hasheq repo-entries) ops txn))

(define (od-url od) (leaf->string (single (navigate (list od) 'url))))
(define (od-code od) (leaf->string (single (navigate (list od) 'code))))

;; ---- dispatch -------------------------------------------------------------------------------

(define (dispatch a req)
  (case (request-kind req)
    [(read vread create update delete search) (dispatch-interaction a req)]
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
       [else (guarded (lambda () (run-interaction (request-kind req) fn req)))])]))

(define (interaction-proc repo kind)
  (case kind
    [(read) (repository-read repo)] [(vread) (repository-vread repo)]
    [(create) (repository-create repo)] [(update) (repository-update repo)]
    [(delete) (repository-delete repo)] [(search) (repository-search repo)]))

(define (run-interaction kind fn req)
  (case kind
    [(read)   (or (fn (request-id req)) (operation-outcome "error" "not-found" "resource not found"))]
    [(vread)  (or (fn (request-id req) (request-vid req))
                  (operation-outcome "error" "not-found" "version not found"))]
    [(create) (fn (request-body req))]
    [(update) (fn (request-id req) (request-body req))]
    [(delete) (begin (fn (request-id req))
                     (operation-outcome "information" "informational" "deleted"))]
    [(search) (make-searchset (fn (request-params req)))]))

(define (dispatch-operation a req)
  (define key (list (request-level req) (request-code req) (target-of req)))
  (define h (hash-ref (app-operations a) key #f))
  (cond
    [(not h)
     (operation-outcome-not-supported
      (format "operation $~a is not supported at ~a level~a"
              (request-code req) (request-level req)
              (if (target-of req) (format " on ~a" (target-of req)) "")))]
    [else
     (define in (parameters->hash (request-body req)))
     (define bad (and (operation-handler-op-def h) (validate-inputs (operation-handler-op-def h) in)))
     (cond
       [bad bad]
       [else (guarded (lambda () ((operation-handler-proc h) in req)))])]))

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
  (define problems
    (for*/list ([p (in-list (navigate (list op-def) 'parameter))]
                #:when (equal? (leaf->string (single (navigate (list p) 'use))) "in")
                [problem (in-value (validate-one p in))]
                #:when problem)
      problem))
  (and (pair? problems) (operation-outcome-invalid (string-join* problems))))

;; returns a problem string, or #f if the parameter is satisfied
(define (validate-one p in)
  (define name (leaf->string (single (navigate (list p) 'name))))
  (define minv (let ([m (single (navigate (list p) 'min))]) (if m (item->system m) 0)))
  (define maxv (leaf->string (single (navigate (list p) 'max))))
  (define present (hash-ref in name '()))
  (define n (length present))
  (cond
    [(and (integer? minv) (< n minv))
     (format "parameter '~a' requires at least ~a value(s), got ~a" name minv n)]
    [(and (equal? maxv "1") (> n 1))
     (format "parameter '~a' allows at most 1 value, got ~a" name n)]
    [else #f]))

;; ---- node construction ----------------------------------------------------------------------

(define (make-searchset nodes)
  (ok-or-raise
   (from-json (hasheq 'resourceType "Bundle" 'type "searchset"
                      'total (length nodes)
                      ;; a nested resource inside a Bundle entry is given to from-json as jsexpr
                      'entry (for/list ([n (in-list nodes)]) (hasheq 'resource (node->jsexpr n)))))))

(define (operation-outcome severity code diagnostics)
  (ok-or-raise
   (from-json (hasheq 'resourceType "OperationOutcome"
                      'issue (list (hasheq 'severity severity 'code code
                                           'diagnostics diagnostics))))))
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
(define (search-request t [params '()]) (request 'search t #f #f params 'type #f #f))
(define (invoke-request #:code code #:level [level 'type] #:type [type #f] #:id [id #f] #:body [body #f])
  (request 'invoke type id #f '() level code body))

;; ---- small helpers --------------------------------------------------------------------------

(define (single xs) (and (pair? xs) (car xs)))
(define (leaf->string x) (let ([v (and x (item->system x))]) (and (string? v) v)))
(define (string-join* xs) (apply string-append (add-between xs "; ")))

(module+ test
  (require rackunit
           (only-in "../r6/types.rkt")
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
