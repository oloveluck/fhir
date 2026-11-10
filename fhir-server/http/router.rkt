#lang racket/base

;;; router.rkt — the FHIR REST grammar as a pure function over a capability `app`.
;;;
;;; Maps (method, path, query, body) onto the in-process dispatcher (capability/runtime) and turns the
;;; resulting typed node into an HTTP status + jsexpr. No sockets here — `handle` is a pure function so
;;; the routing/status logic is unit-testable; http/server.rkt supplies the transport.
;;;
;;;   GET  /metadata                     -> CapabilityStatement
;;;   GET  /{Type}?name=value…           -> search (Bundle)          POST /{Type}        -> create
;;;   GET  /{Type}/{id}                  -> read                     PUT  /{Type}/{id}   -> update
;;;   DELETE /{Type}/{id}                -> delete                   GET /{Type}/{id}/_history/{vid} -> vread
;;;   GET|POST /${op} | /{Type}/${op} | /{Type}/{id}/${op}          -> operation invoke

(require racket/contract
         racket/string
         racket/match
         net/base64
         (only-in json read-json jsexpr->string)
         (only-in fhir/serialize/jsexpr-util drop-false)
         (only-in fhir/model/node fhir fhir? fhir-type fhir-ref fhir-has? fhir-fields)
         (only-in racket/list append-map)
         (only-in fhir/model/registry type-registered?)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/result/result ok? ok-value)
         (only-in fhirpath/value item->system)
         (only-in fhir/capability/runtime
                  app? app-capability-statement app-transaction app-metadata app-repositories app-operation-definitions dispatch
                  operation-result? make-searchset operation-outcome
                  read-request vread-request create-request update-request delete-request
                  search-request invoke-request history-request patch-request operation-outcome-invalid operation-outcome-not-supported
                  current-request-json))

(provide
 (contract-out
  ;; handle : app method path query-alist body-string -> (values status-code jsexpr|#f)
  [handle (-> app? string? string? (listof (cons/c symbol? string?)) string?
              (values exact-integer? (or/c hash? #f)))]
  ;; handle/raw : like handle, but a Binary result from an operation STREAMS RAW — the
  ;; wire body is the Binary's decoded data with its own content type (SQL-on-FHIR $sql-run:
  ;; "a raw binary stream in the format's native media type, not a Binary resource envelope")
  [handle/raw (-> app? string? string? (listof (cons/c symbol? string?)) string?
                  (values exact-integer? bytes? string?))]
  [parse-query (-> string? (listof (cons/c symbol? string?)))]))

;; ---- the router ----------------------------------------------------------------------------
(define (handle app method path query body)
  (define segs (path-segments path))
  (define-values (kind node) (route app method segs query body))
  (values (status-of app segs kind node) (and node (node->jsexpr node))))

;; status-of : app segments kind node -> status   an interaction the app does not offer on a type it
;; serves is 405 Method Not Allowed (the type exists here); an unknown type or route stays 404
(define (status-of app segs kind node)
  (define s (status-for kind node))
  (if (and (= s 404) (equal? (issue-code node) "not-supported") (pair? segs)
           (not (ormap op-seg? segs))
           (hash-has-key? (app-repositories app) (string->symbol (car segs))))
      405
      s))

(define fhir-json-type "application/fhir+json; charset=utf-8")

(define (handle/raw app method path query body)
  (define segs (path-segments path))
  (define-values (kind node) (route app method segs query body))
  (define status (status-of app segs kind node))
  (cond
    [(and (eq? kind 'invoke) (fhir? node) (eq? (fhir-type node) 'Binary))
     (define js (node->jsexpr node))
     (values status
             (base64-decode (string->bytes/utf-8 (hash-ref js 'data "")))
             (hash-ref js 'contentType "application/octet-stream"))]
    [else
     (values status
             (string->bytes/utf-8 (if node (jsexpr->string (node->jsexpr node)) ""))
             fhir-json-type)]))

;; route : app method (listof segment) query body -> (values kind node)
;; the FHIR REST grammar as the SHAPE of the path: each clause is one URL form (the operators
;; and history forms before the plain type and instance forms, so `$op` and `_history` are never
;; read as an id)
(define (route app method segs query body)
  (match* (method segs)
    ;; capability statement; ?mode=terminology (or any mode the app has metadata for) answers that
    ;; resource instead
    [("GET" '("metadata"))
     (values 'metadata (or (let ([m (assq 'mode query)]) (and m (hash-ref (app-metadata app) (cdr m) #f)))
                           (app-capability-statement app)))]
    ;; system root: POST / with a transaction|batch Bundle
    [("POST" '()) (transaction-route app body)]
    ;; operations at the three levels:  /$op   /{Type}/$op   /{Type}/{id}/$op
    [(_ (list (? op-seg? op))) (invoke app method 'system #f #f (op-code op) query body)]
    [(_ (list (? known-type? t) (? op-seg? op))) (invoke app method 'type (sym t) #f (op-code op) query body)]
    [(_ (list (? known-type? t) id (? op-seg? op))) (invoke app method 'instance (sym t) id (op-code op) query body)]
    ;; the app's own OperationDefinitions (the derived ones, by id or code; the referenced ones by
    ;; id), when it does not store OperationDefinitions itself: a client reads what $egfr takes
    [("GET" (list "OperationDefinition" id))
     #:when (not (hash-has-key? (app-repositories app) 'OperationDefinition))
     (values 'read (or (findf (lambda (od) (member id (od-names od))) (app-operation-definitions app))
                       (operation-outcome "error" "not-found" (format "no OperationDefinition ~a here (~a)" id
                                                            (string-join (append-map od-names (app-operation-definitions app)) ", ")))))]
    [("GET" (list "OperationDefinition"))
     #:when (not (hash-has-key? (app-repositories app) 'OperationDefinition))
     (values 'search (make-searchset (app-operation-definitions app)))]
    ;; history:  /{Type}/{id}/_history   and   /{Type}/_history ; vread:  /{Type}/{id}/_history/{vid}
    [("GET" (list (? known-type? t) id "_history")) (values 'history (dispatch app (history-request (sym t) id query)))]
    [("GET" (list (? known-type? t) "_history")) (values 'history (dispatch app (history-request (sym t) #f query)))]
    [("GET" (list (? known-type? t) id "_history" vid)) (values 'read (dispatch app (vread-request (sym t) id vid)))]
    ;; type collection:  /{Type}
    [(_ (list (? known-type? type)))
     (define t (sym type))
     (case method
       [("GET")  (values 'search (dispatch app (search-request t query)))]
       ;; FHIR: a create's id is the server's; one sent is ignored (an id already in use answered a 500
       ;; naming the store's function). PUT /Type/id creates with a chosen id.
       [("POST") (with-body body (lambda (n) (if (same-type? n t) (values 'create (dispatch app (create-request t (without-id n)))) (wrong-type n t "POST"))))]
       [else (values 'error (operation-outcome-not-supported (format "~a not allowed on /~a" method type)))])]
    ;; instance:  /{Type}/{id}
    [(_ (list (? known-type? type) id))
     (define t (sym type))
     (case method
       [("GET")    (values 'read (dispatch app (read-request t id)))]
       [("PUT")    (with-body body (lambda (n) (if (same-type? n t) (values 'update (dispatch app (update-request t id n))) (wrong-type n t "PUT"))))]
       [("DELETE") (values 'delete (dispatch app (delete-request t id)))]
       ;; JSON Patch (application/json-patch+json): the body is an array of operations
       [("PATCH")
        (define ops (with-handlers ([exn:fail? (lambda (_) #f)]) (read-json (open-input-string body))))
        (if (list? ops)
            (values 'update (dispatch app (patch-request t id ops)))
            (values 'error (operation-outcome-invalid "PATCH body must be a JSON Patch array (application/json-patch+json)")))]
       [else (values 'error (operation-outcome-not-supported (format "~a not allowed on /~a/~a" method type id)))])]
    [(_ _) (values 'error (operation-outcome-not-supported (format "no route for ~a /~a" method (string-join segs "/"))))]))

;; POST / : hand the raw Bundle jsexpr to the app's transaction processor. The response Bundle is
;; parsed back to a typed node so it flows through the same response path as everything else; a
;; transaction failure surfaces as a processing OperationOutcome (HTTP 400).
(define (transaction-route app body)
  (define txn (app-transaction app))
  (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (read-json (open-input-string body))))
  (cond
    [(not (and (hash? js) (equal? (hash-ref js 'resourceType #f) "Bundle")))
     (values 'error (operation-outcome-invalid "request body must be a Bundle"))]
    ;; an app without a transaction processor still answers a BATCH: each entry is routed on its
    ;; own, as the request it is (operations included), and answered in place
    [(and (not txn) (equal? (hash-ref js 'type #f) "batch"))
     (values 'transaction (ok-value (from-json (batch-route app js) #:lenient? #t)))]
    [(not txn) (values 'error (operation-outcome-not-supported "transaction is not supported"))]
    [else
     (with-handlers ([exn:fail? (lambda (e) (values 'error (operation-outcome-invalid (exn-message e))))])
       (define resp (txn js))
       (values 'transaction (ok-value (from-json resp #:lenient? #t))))]))

;; batch-route : app batch-Bundle -> batch-response Bundle (jsexpr)   per entry: its request
;; through the router; the result as entry.resource, or as response.outcome when it failed
(define (batch-route app js)
  (define entries
    (for/list ([e (in-list (let ([v (hash-ref js 'entry '())]) (if (list? v) v '())))])
      (define req (let ([r (hash-ref e 'request #f)]) (if (hash? r) r (hasheq))))
      (define url (let ([u (hash-ref req 'url "")]) (if (string? u) u "")))
      (define parts (string-split (string-append url "?") "?"))
      (define path (string-append "/" (car parts)))
      (define query (parse-query (if (pair? (cdr parts)) (cadr parts) "")))
      (define body (let ([r (hash-ref e 'resource #f)]) (if r (jsexpr->string r) "")))
      (define-values (status out) (handle app (hash-ref req 'method "GET") path query body))
      (drop-false
       (hasheq 'resource (and (< status 400) out)
               'response (drop-false (hasheq 'status (number->string status)
                                             'outcome (and (>= status 400) out)))))))
  (hasheq 'resourceType "Bundle" 'type "batch-response" 'entry entries))

;; invoke an operation; input Parameters come from the POST body or are synthesised from the query
(define (invoke app method level type id code query body)
  (cond
    ;; an empty object is no body, as an empty POST is (`{}` asked for a 400 "not a FHIR resource")
    [(and (equal? method "POST") (positive? (string-length (string-trim body)))
          (not (regexp-match? #px"^\\s*[{]\\s*[}]\\s*$" body)))
     (with-body body (lambda (n) (values 'invoke (dispatch app (invoke-request #:code code #:level level #:type type #:id id #:body n)))))]
    [else
     (values 'invoke (dispatch app (invoke-request #:code code #:level level #:type type #:id id
                                                   #:body (query->parameters query))))]))

;; ---- helpers -------------------------------------------------------------------------------
(define (path-segments path)
  (filter (lambda (s) (positive? (string-length s)))
          (string-split (car (string-split (string-append path "?") "?")) "/")))

;; od-names : OperationDefinition -> (listof string)   its id and its code, how a client asks for it
(define (od-names od)
  (filter string? (list (let ([v (fhir-ref od 'id #f)]) (and v (leaf->string v)))
                        (let ([v (fhir-ref od 'code #f)]) (and v (leaf->string v))))))

(define (known-type? s) (and (regexp-match? #px"^[A-Z]" s) (type-registered? (string->symbol s))))
(define (op-seg? s) (and (string? s) (> (string-length s) 0) (char=? (string-ref s 0) #\$)))
(define (sym s) (string->symbol s))
(define (op-code s) (substring s 1))   ; drop the leading "$"

;; parse a query string "a=1&b=x%20y" -> (listof (cons sym decoded-value))
(define (parse-query qs)
  (for/list ([kv (in-list (string-split qs "&"))] #:when (positive? (string-length kv)))
    (define i (for/or ([c (in-string kv)] [j (in-naturals)]) (and (char=? c #\=) j)))
    (if i (cons (string->symbol (url-decode (substring kv 0 i))) (url-decode (substring kv (add1 i))))
        (cons (string->symbol (url-decode kv)) ""))))

(define (url-decode s)
  (regexp-replace* #px"%([0-9A-Fa-f][0-9A-Fa-f])"
                   (regexp-replace* #rx"[+]" s " ")
                   (lambda (_ h) (string (integer->char (string->number h 16))))))

(define (query->parameters query)
  (ok-value (from-json (hasheq 'resourceType "Parameters"
                               'parameter (for/list ([p (in-list query)])
                                            (hasheq 'name (symbol->string (car p)) 'valueString (cdr p)))))))

;; without-id : node -> node   a resource without its id (what a create stores under the server's)
(define (without-id n) (if (fhir-has? n 'id) (fhir (fhir-type n) (hash-remove (fhir-fields n) 'id)) n))

;; a body of another type than the endpoint's is the client's mistake (400), said plainly
(define (same-type? n t) (eq? (fhir-type n) t))
(define (wrong-type n t method)
  (values 'error (operation-outcome-invalid (format "the body is a ~a, ~aed to /~a: send a ~a there, or the ~a to /~a"
                                                    (fhir-type n) method t t (fhir-type n) (fhir-type n)))))

;; parse a JSON body into a typed node, or short-circuit with an `invalid` OperationOutcome
(define (with-body body k)
  (define js (with-handlers ([exn:fail? (lambda (e) #f)]) (read-json (open-input-string body))))
  (define r (and js (with-handlers ([exn:fail? (lambda (e) #f)]) (from-json js #:lenient? #t))))
  (cond [(and r (ok? r)) (parameterize ([current-request-json js]) (k (ok-value r)))]
        [(not js) (values 'error (operation-outcome-invalid "request body is not JSON"))]
        [else (values 'error (operation-outcome-invalid "request body is not a FHIR resource"))]))

;; ---- status codes --------------------------------------------------------------------------
(define (status-for kind node)
  (cond
    [(operation-result? node) 200]                     ; $validate's answer, whatever it found
    [(and (fhir? node) (eq? (fhir-type node) 'OperationOutcome)) (outcome-status node)]
    [(eq? kind 'create) 201]
    [else 200]))

;; map the first OperationOutcome issue's code to an HTTP status
(define (outcome-status node)
  (define code (issue-code node))
  (case code
    [("not-found") 404] [("not-supported") 404] [("invalid" "required" "value") 400]
    [("processing") 422]                     ; the resource violates a profile / business rule
    [("conflict" "duplicate") 409]
    [("security" "forbidden") 403] [("exception") 500] [else 200]))   ; informational -> 200

(define (issue-code node)
  (define issues (let ([v (fhir-ref node 'issue #f)]) (if (list? v) v (if v (list v) '()))))
  (and (pair? issues) (let ([c (fhir-ref (car issues) 'code #f)]) (and c (leaf->string c)))))

(define (leaf->string x) (let ([v (item->system x)]) (and (string? v) v)))

;; ── living examples: the router is PURE — drive it without sockets ───────────────────────────
(module+ test
  (require rackunit
           (only-in fhir/capability/runtime build-app make-repository)
           (only-in fhir/capability/derive derive-capability-statement rc-server rc-resource)
           fhir/r6/types)
  ;; a one-resource app over an in-memory repository
  (define pt (ok-value (from-json (hasheq 'resourceType "Patient" 'id "1" 'gender "female"))))
  (define repo (make-repository #:read (lambda (id) (and (equal? id "1") pt))
                                #:search (lambda (params) (list pt))))
  (define app
    (build-app #:capability (derive-capability-statement
                             (rc-server "server" "active" "2026-01-01" "6.0.0" '("json") #f)
                             (list (rc-resource 'Patient '(read search-type) '() #f)) '())
               #:operation-definitions '() #:repositories (list (cons 'Patient repo)) #:operations '()))
  (define (go method path [q '()] [body ""]) (call-with-values (lambda () (handle app method path q body)) list))
  (check-equal? (car (go "GET" "/metadata")) 200)
  (check-equal? (hash-ref (cadr (go "GET" "/Patient/1")) 'gender) "female")
  (check-equal? (car (go "GET" "/Patient/9")) 404)                     ; miss -> not-found
  (check-equal? (hash-ref (cadr (go "GET" "/Patient")) 'type) "searchset")
  (check-equal? (car (go "DELETE" "/Patient/1")) 405)                  ; undeclared interaction on a served type
  (check-equal? (car (go "GET" "/Nope/1")) 404)                        ; unknown type
  ;; a batch for an app without a transaction processor routes each entry on its own
  (define batch (jsexpr->string (hasheq 'resourceType "Bundle" 'type "batch"
                                        'entry (list (hasheq 'request (hasheq 'method "GET" 'url "Patient/1"))
                                                     (hasheq 'request (hasheq 'method "GET" 'url "Patient/9"))))))
  (define b (cadr (go "POST" "/" '() batch)))
  (check-equal? (hash-ref b 'type) "batch-response")
  (check-equal? (map (lambda (e) (hash-ref (hash-ref e 'response) 'status)) (hash-ref b 'entry)) '("200" "404"))
  (check-equal? (hash-ref (hash-ref (car (hash-ref b 'entry)) 'resource) 'gender) "female")
  ;; metadata by mode
  (define tc (ok-value (from-json (hasheq 'resourceType "TerminologyCapabilities" 'status "active"
                                          'date "2026-01-01" 'kind "instance"))))
  (define app/tc (build-app #:capability (app-capability-statement app) #:operation-definitions '()
                            #:repositories '() #:operations '() #:metadata (hash "terminology" tc)))
  (check-equal? (hash-ref (cadr (call-with-values (lambda () (handle app/tc "GET" "/metadata" '((mode . "terminology")) "")) list))
                          'resourceType)
                "TerminologyCapabilities")
  ;; parse-query decodes + splits
  (check-equal? (parse-query "a=1&b=x%20y") '((a . "1") (b . "x y"))))
