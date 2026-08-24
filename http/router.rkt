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
         (only-in "../model/node.rkt" fhir? fhir-type fhir-ref)
         (only-in "../model/registry.rkt" type-registered?)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../serialize/to-json.rkt" node->jsexpr)
         (only-in "../result/result.rkt" ok? ok-value)
         (only-in "../fhirpath/value.rkt" item->system)
         (only-in "../capability/runtime.rkt"
                  app? app-capability-statement app-transaction dispatch
                  read-request vread-request create-request update-request delete-request
                  search-request invoke-request operation-outcome-invalid operation-outcome-not-supported))

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
  (values (status-for kind node) (and node (node->jsexpr node))))

(define fhir-json-type "application/fhir+json; charset=utf-8")

(define (handle/raw app method path query body)
  (define segs (path-segments path))
  (define-values (kind node) (route app method segs query body))
  (define status (status-for kind node))
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

(define (route app method segs query body)
  (define (op-seg? s) (and (string? s) (> (string-length s) 0) (char=? (string-ref s 0) #\$)))
  (cond
    ;; capability statement
    [(and (equal? method "GET") (equal? segs '("metadata")))
     (values 'metadata (app-capability-statement app))]
    ;; system root: POST / with a transaction|batch Bundle
    [(and (equal? method "POST") (null? segs))
     (transaction-route app body)]
    ;; system-level operation:  /$op
    [(and (pair? segs) (null? (cdr segs)) (op-seg? (car segs)))
     (invoke app method 'system #f #f (op-code (car segs)) query body)]
    ;; type-level operation:  /{Type}/$op
    [(and (= (length segs) 2) (op-seg? (cadr segs)) (known-type? (car segs)))
     (invoke app method 'type (sym (car segs)) #f (op-code (cadr segs)) query body)]
    ;; instance-level operation:  /{Type}/{id}/$op
    [(and (= (length segs) 3) (op-seg? (caddr segs)) (known-type? (car segs)))
     (invoke app method 'instance (sym (car segs)) (cadr segs) (op-code (caddr segs)) query body)]
    ;; vread:  /{Type}/{id}/_history/{vid}
    [(and (equal? method "GET") (= (length segs) 4) (equal? (caddr segs) "_history") (known-type? (car segs)))
     (values 'read (dispatch app (vread-request (sym (car segs)) (cadr segs) (cadddr segs))))]
    ;; type collection:  /{Type}
    [(and (= (length segs) 1) (known-type? (car segs)))
     (define t (sym (car segs)))
     (case method
       [("GET")  (values 'search (dispatch app (search-request t query)))]
       [("POST") (with-body body (lambda (n) (values 'create (dispatch app (create-request t n)))))]
       [else (values 'error (operation-outcome-not-supported (format "~a not allowed on /~a" method (car segs))))])]
    ;; instance:  /{Type}/{id}
    [(and (= (length segs) 2) (known-type? (car segs)))
     (define t (sym (car segs))) (define id (cadr segs))
     (case method
       [("GET")    (values 'read (dispatch app (read-request t id)))]
       [("PUT")    (with-body body (lambda (n) (values 'update (dispatch app (update-request t id n)))))]
       [("DELETE") (values 'delete (dispatch app (delete-request t id)))]
       [else (values 'error (operation-outcome-not-supported (format "~a not allowed on /~a/~a" method (car segs) id)))])]
    [else (values 'error (operation-outcome-not-supported (format "no route for ~a /~a" method (string-join segs "/"))))]))

;; POST / : hand the raw Bundle jsexpr to the app's transaction processor. The response Bundle is
;; parsed back to a typed node so it flows through the same response path as everything else; a
;; transaction failure surfaces as a processing OperationOutcome (HTTP 400).
(define (transaction-route app body)
  (define txn (app-transaction app))
  (cond
    [(not txn) (values 'error (operation-outcome-not-supported "transaction/batch is not supported"))]
    [else
     (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (read-json (open-input-string body))))
     (cond
       [(not (and (hash? js) (equal? (hash-ref js 'resourceType #f) "Bundle")))
        (values 'error (operation-outcome-invalid "request body must be a Bundle"))]
       [else
        (with-handlers ([exn:fail? (lambda (e) (values 'error (operation-outcome-invalid (exn-message e))))])
          (define resp (txn js))
          (values 'transaction (ok-value (from-json resp #:lenient? #t))))])]))

;; invoke an operation; input Parameters come from the POST body or are synthesised from the query
(define (invoke app method level type id code query body)
  (cond
    [(and (equal? method "POST") (positive? (string-length (string-trim body))))
     (with-body body (lambda (n) (values 'invoke (dispatch app (invoke-request #:code code #:level level #:type type #:id id #:body n)))))]
    [else
     (values 'invoke (dispatch app (invoke-request #:code code #:level level #:type type #:id id
                                                   #:body (query->parameters query))))]))

;; ---- helpers -------------------------------------------------------------------------------
(define (path-segments path)
  (filter (lambda (s) (positive? (string-length s)))
          (string-split (car (string-split (string-append path "?") "?")) "/")))

(define (known-type? s) (and (regexp-match? #px"^[A-Z]" s) (type-registered? (string->symbol s))))
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

;; parse a JSON body into a typed node, or short-circuit with an `invalid` OperationOutcome
(define (with-body body k)
  (define r (with-handlers ([exn:fail? (lambda (e) #f)])
              (from-json (read-json (open-input-string body)) #:lenient? #t)))
  (cond [(and r (ok? r)) (k (ok-value r))]
        [else (values 'error (operation-outcome-invalid "request body is not valid FHIR JSON"))]))

;; ---- status codes --------------------------------------------------------------------------
(define (status-for kind node)
  (cond
    [(and (fhir? node) (eq? (fhir-type node) 'OperationOutcome)) (outcome-status node)]
    [(eq? kind 'create) 201]
    [else 200]))

;; map the first OperationOutcome issue's code to an HTTP status
(define (outcome-status node)
  (define code (issue-code node))
  (case code
    [("not-found") 404] [("not-supported") 404] [("invalid" "required" "value") 400]
    [("security" "forbidden") 403] [("exception") 500] [else 200]))   ; informational -> 200

(define (issue-code node)
  (define issues (let ([v (fhir-ref node 'issue #f)]) (if (list? v) v (if v (list v) '()))))
  (and (pair? issues) (let ([c (fhir-ref (car issues) 'code #f)]) (and c (leaf->string c)))))

(define (leaf->string x) (let ([v (item->system x)]) (and (string? v) v)))

;; ── living examples: the router is PURE — drive it without sockets ───────────────────────────
(module+ test
  (require rackunit
           (only-in "../capability/runtime.rkt" build-app make-repository)
           (only-in "../capability/derive.rkt" derive-capability-statement rc-server rc-resource)
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
  (check-equal? (car (go "DELETE" "/Patient/1")) 404)                  ; undeclared interaction
  (check-equal? (car (go "GET" "/Nope/1")) 404)                        ; unknown type
  ;; parse-query decodes + splits
  (check-equal? (parse-query "a=1&b=x%20y") '((a . "1") (b . "x y"))))
