#lang racket/base

;;; bundle.rkt — FHIR transaction/batch Bundle processing over the store
;;; (https://build.fhir.org/http.html#transaction).
;;;
;;; A ProcessableBundle is a jsexpr Bundle of type:
;;;   "transaction" — entries apply ATOMICALLY (one store transaction; any failure rolls back all)
;;;                   in the spec's order: DELETEs, then POSTs, then PUTs. Entry fullUrls of the
;;;                   form urn:uuid:… are assigned server ids up front and every reference to them
;;;                   (in every entry) is REWRITTEN to Type/id before anything is applied — the
;;;                   spec's internal-reference resolution.
;;;   "batch"       — entries apply independently, in order; a failing entry yields an error
;;;                   response entry, the rest proceed.
;;;   "collection"  — accepted by `load-bundle!` ONLY (a prepopulation convenience: every entry
;;;                   resource is created as a batch of POSTs); the HTTP endpoint takes
;;;                   transaction|batch, per spec.
;;;
;;; The response mirrors the request: type "transaction-response"/"batch-response", one entry per
;;; request entry (in request order) with response.status ("200 OK"/"201 Created"/"404 …"), the
;;; created/updated resource's location, and — on batch errors — an OperationOutcome.

(require racket/contract racket/list racket/string racket/match
         json
         "fhir-sqlite.rkt" "fhir-engine.rkt")

(provide
 (contract-out
  ;; process a transaction|batch Bundle -> the response Bundle (raises on a malformed Bundle;
  ;; a transaction whose any entry fails raises AFTER rolling everything back)
  [process-bundle! (->* (fhir-store? jsexpr?) (#:search-params hash?) jsexpr?)]
  ;; prepopulation: transaction|batch|collection -> (values created-count response-bundle)
  [load-bundle!    (->* (fhir-store? jsexpr?) (#:search-params hash?) (values exact-nonnegative-integer? jsexpr?))]))

;; ---- entry model -------------------------------------------------------------
;; An Entry is (entry index full-url method url resource) — one Bundle.entry, in request order.
(struct entry (index full-url method url resource) #:transparent)

(define (bundle-entries bundle)
  (for/list ([e (in-list (hash-ref bundle 'entry '()))] [i (in-naturals)])
    (define req (hash-ref e 'request (hasheq)))
    (entry i
           (hash-ref e 'fullUrl #f)
           (and (hash? req) (hash-ref req 'method #f))
           (and (hash? req) (hash-ref req 'url #f))
           (hash-ref e 'resource #f))))

;; ---- urn:uuid resolution -----------------------------------------------------
;; assign a fresh id to every POST entry whose fullUrl is a urn (or that lacks a resource id) and
;; return (values entries* urn->literal-map). PUT entries keep the id in their url.
(define (assign-ids entries)
  (define urn->ref (make-hash))
  (define entries*
    (for/list ([e (in-list entries)])
      (match e
        [(entry i full "POST" _ res)
         #:when (hash? res)
         (define rtype (hash-ref res 'resourceType "?"))
         (define id (or (hash-ref res 'id #f) (fresh-bundle-id)))
         (when (and (string? full) (string-prefix? full "urn:"))
           (hash-set! urn->ref full (string-append rtype "/" id)))
         (struct-copy entry e [resource (hash-set res 'id id)])]
        [_ e])))
  (values entries* urn->ref))

(define bundle-id-counter (box 0))
(define (fresh-bundle-id)
  (set-box! bundle-id-counter (add1 (unbox bundle-id-counter)))
  (format "b~a-~a" (current-milliseconds) (unbox bundle-id-counter)))

;; rewrite every urn reference in a jsexpr tree to its literal Type/id
(define (rewrite-refs js urn->ref)
  (cond
    [(string? js) (hash-ref urn->ref js js)]
    [(list? js) (for/list ([x (in-list js)]) (rewrite-refs x urn->ref))]
    [(hash? js) (for/hasheq ([(k v) (in-hash js)]) (values k (rewrite-refs v urn->ref)))]
    [else js]))

;; ---- application -------------------------------------------------------------
;; the spec's processing order within a transaction: DELETE, POST, PUT (reads are not supported
;; inside store bundles — they'd be non-deterministic mid-transaction)
(define (method-rank m) (match m ["DELETE" 0] ["POST" 1] ["PUT" 2] [_ 3]))

;; apply one entry on an open connection -> a response-entry jsexpr (raises on failure)
(define (apply-entry! c e sps)
  (match e
    [(entry _ _ "POST" _ (? hash? res))
     (define-values (rtype id vid) (create-in! c res sps))
     (hasheq 'response (hasheq 'status "201 Created"
                               'location (format "~a/~a/_history/~a" rtype id vid)))]
    [(entry _ _ "PUT" url (? hash? res))
     (define-values (rtype id) (parse-type/id url))
     (define vid (update-in! c (hash-set* res 'resourceType rtype 'id id) sps))
     (hasheq 'response (hasheq 'status "200 OK"
                               'location (format "~a/~a/_history/~a" rtype id vid)))]
    [(entry _ _ "DELETE" url _)
     (define-values (rtype id) (parse-type/id url))
     (delete-in! c rtype id)
     (hasheq 'response (hasheq 'status "204 No Content"))]
    [(entry i _ m _ _)
     (error 'process-bundle! "entry ~a: unsupported method ~a" i (or m "<none>"))]))

(define (parse-type/id url)
  (match (and (string? url) (regexp-match #px"^([A-Za-z]+)/([^/?]+)" url))
    [(list _ t id) (values t id)]
    [_ (error 'process-bundle! "entry url is not Type/id: ~a" url)]))

;; ---- the two bundle kinds ----------------------------------------------------
(define (process-bundle! store bundle #:search-params [sps default-search-params])
  (define ty (hash-ref bundle 'type #f))
  (unless (member ty '("transaction" "batch"))
    (error 'process-bundle! "bundle type must be transaction or batch, got ~a" ty))
  (define-values (entries urn->ref) (assign-ids (bundle-entries bundle)))
  (define resolved
    (for/list ([e (in-list entries)])
      (struct-copy entry e [resource (and (entry-resource e)
                                          (rewrite-refs (entry-resource e) urn->ref))])))
  (define ordered (sort resolved < #:key (lambda (e) (method-rank (entry-method e)))))
  (cond
    [(equal? ty "transaction")
     ;; ONE store transaction: any raise rolls back every entry
     (define responses (make-vector (length resolved) #f))
     (call-with-store-transaction store
       (lambda (c)
         (for ([e (in-list ordered)])
           (vector-set! responses (entry-index e) (apply-entry! c e sps)))))
     (response-bundle "transaction-response" (vector->list responses))]
    [else
     ;; batch: each entry its OWN transaction; failures become error response entries
     (define responses (make-vector (length resolved) #f))
     (for ([e (in-list ordered)])
       (vector-set!
        responses (entry-index e)
        (with-handlers ([exn:fail? (lambda (x) (error-entry (exn-message x)))])
          (call-with-store-transaction store
            (lambda (c) (apply-entry! c e sps))))))
     (response-bundle "batch-response" (vector->list responses))]))

(define (error-entry msg)
  (hasheq 'response (hasheq 'status "400 Bad Request"
                            'outcome (hasheq 'resourceType "OperationOutcome"
                                             'issue (list (hasheq 'severity "error" 'code "processing"
                                                                  'diagnostics msg))))))

(define (response-bundle ty entries)
  (hasheq 'resourceType "Bundle" 'type ty 'entry entries))

;; ---- prepopulation loader ----------------------------------------------------
;; a collection (e.g. a Synthea export without request entries) loads as creates; transaction/batch
;; go through the full processor. -> (values created-count response)
(define (load-bundle! store bundle #:search-params [sps default-search-params])
  (define ty (hash-ref bundle 'type #f))
  (define b
    (if (member ty '("transaction" "batch"))
        bundle
        ;; collection/searchset/document -> synthesize a batch of POSTs from the entry resources
        (hasheq 'resourceType "Bundle" 'type "batch"
                'entry (for/list ([e (in-list (hash-ref bundle 'entry '()))]
                                  #:when (hash? (hash-ref e 'resource #f)))
                         (hasheq 'fullUrl (hash-ref e 'fullUrl "")
                                 'resource (hash-ref e 'resource)
                                 'request (hasheq 'method "POST"
                                                  'url (hash-ref (hash-ref e 'resource) 'resourceType "")))))))
  (define resp (process-bundle! store b #:search-params sps))
  (define created (for/sum ([e (in-list (hash-ref resp 'entry '()))]
                            #:when (let ([r (hash-ref e 'response (hasheq))])
                                     (string-prefix? (hash-ref r 'status "") "2")))
                    1))
  (values created resp))

(module+ test
  (require rackunit racket/file fhir/r5/schemas)
  (define tmp (make-temporary-file "bundle-~a.db"))
  (define store (open-fhir-store tmp))

  ;; a transaction: two POSTs referencing each other by urn:uuid + internal reference rewriting
  (define txn
    (hasheq 'resourceType "Bundle" 'type "transaction"
            'entry (list
                    (hasheq 'fullUrl "urn:uuid:pat-1"
                            'resource (hasheq 'resourceType "Patient" 'gender "female")
                            'request (hasheq 'method "POST" 'url "Patient"))
                    (hasheq 'fullUrl "urn:uuid:obs-1"
                            'resource (hasheq 'resourceType "Observation" 'status "final"
                                              'code (hasheq 'text "x")
                                              'subject (hasheq 'reference "urn:uuid:pat-1"))
                            'request (hasheq 'method "POST" 'url "Observation")))))
  (define resp (process-bundle! store txn))
  (check-equal? (hash-ref resp 'type) "transaction-response")
  (check-equal? (map (lambda (e) (hash-ref (hash-ref e 'response) 'status)) (hash-ref resp 'entry))
                '("201 Created" "201 Created"))
  ;; the urn reference was rewritten to the assigned literal id
  (define obs (car (fhir-search store "Observation" '())))
  (define pat-ref (hash-ref (hash-ref obs 'subject) 'reference))
  (check-true (string-prefix? pat-ref "Patient/"))
  (check-true (and (fhir-read store "Patient" (cadr (string-split pat-ref "/"))) #t))

  ;; ATOMICITY: a transaction with a failing entry (duplicate create) leaves NO trace
  (define n-before (length (fhir-search store "Patient" '())))
  (define bad
    (hasheq 'resourceType "Bundle" 'type "transaction"
            'entry (list
                    (hasheq 'resource (hasheq 'resourceType "Patient" 'id "atom-1" 'gender "male")
                            'request (hasheq 'method "POST" 'url "Patient"))
                    (hasheq 'resource (hasheq 'resourceType "Patient" 'id "atom-1" 'gender "male")
                            'request (hasheq 'method "POST" 'url "Patient")))))   ; duplicate -> raise
  (check-exn exn:fail? (lambda () (process-bundle! store bad)))
  (check-equal? (length (fhir-search store "Patient" '())) n-before)   ; rolled back
  (check-false (fhir-read store "Patient" "atom-1"))

  ;; BATCH: the same failure only poisons its own entry
  (define bresp (process-bundle! store (hash-set bad 'type "batch")))
  (check-equal? (hash-ref bresp 'type) "batch-response")
  (define statuses (map (lambda (e) (hash-ref (hash-ref e 'response) 'status)) (hash-ref bresp 'entry)))
  (check-equal? (car statuses) "201 Created")
  (check-true (string-prefix? (cadr statuses) "400"))
  (check-true (and (fhir-read store "Patient" "atom-1") #t))           ; first entry landed

  ;; processing ORDER: a delete + recreate of the same id in one transaction works (DELETE first)
  (define redo
    (hasheq 'resourceType "Bundle" 'type "transaction"
            'entry (list
                    (hasheq 'resource (hasheq 'resourceType "Patient" 'id "atom-1" 'gender "other")
                            'request (hasheq 'method "POST" 'url "Patient"))
                    (hasheq 'request (hasheq 'method "DELETE" 'url "Patient/atom-1")))))
  (define rresp (process-bundle! store redo))
  (check-equal? (hash-ref (fhir-read store "Patient" "atom-1") 'gender) "other")

  ;; PUT in a transaction updates and reports 200 + a versioned location
  (define put
    (hasheq 'resourceType "Bundle" 'type "transaction"
            'entry (list (hasheq 'resource (hasheq 'resourceType "Patient" 'gender "unknown")
                                 'request (hasheq 'method "PUT" 'url "Patient/atom-1")))))
  (define presp (process-bundle! store put))
  (check-true (string-prefix? (hash-ref (hash-ref (car (hash-ref presp 'entry)) 'response) 'location)
                              "Patient/atom-1/_history/"))

  ;; collection loading (the Synthea-style convenience)
  (define-values (n cresp)
    (load-bundle! store (hasheq 'resourceType "Bundle" 'type "collection"
                                'entry (list (hasheq 'resource (hasheq 'resourceType "Patient" 'gender "female"))
                                             (hasheq 'resource (hasheq 'resourceType "Patient" 'gender "male"))))))
  (check-equal? n 2)
  (close-fhir-store store)
  (delete-file tmp))
