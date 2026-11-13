#lang racket/base

;;; serve.rkt — expose the persistent store over the FHIR REST API, with the CapabilityStatement
;;; and search parameters derived FROM the IG/core package itself.
;;;
;;; The chain: package tgz --(ig-params)--> search-param catalog
;;;                        --(capability/derive)--> CapabilityStatement advertising those params
;;;                        --(store-repository)--> a capability `repository` over fhir-engine
;;;                        --(capability/runtime build-app + http/server)--> live endpoints.
;;;
;;; `make-store-app` returns the same `app` value `#lang fhir/capability` modules produce, so the
;;; existing `http/` layer (and `raco fhir-server serve`) serves it unchanged: GET /metadata, CRUD,
;;; GET /{Type}?param=…, vread — all backed by SQLite, all advertised params IG-derived.

(require (only-in fhir/spec-package spec-package-path))
(require racket/contract racket/list racket/string racket/match
         json
         "fhir-sqlite.rkt" "fhir-engine.rkt" "ig-params.rkt" "bundle.rkt"
         (only-in "search-index.rkt" indexed-kind?)
         (only-in fhir/capability/derive derive-capability-statement rc-server rc-resource)
         (only-in fhir/capability/runtime make-repository build-app app? search-page)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/result/result ok? ok-value ok-or-raise)
         (only-in fhir/model/node fhir?))

(provide
 (contract-out
  ;; a capability `repository` for one resource type, backed by the store
  [store-repository (-> fhir-store? symbol? hash? any/c)]
  ;; the full servable app: CapabilityStatement + repositories, search params from the package(s).
  ;; #:audit? #t records an AuditEvent per write (and a Provenance per create/update) INTO the
  ;; store itself — add AuditEvent/Provenance to #:types to serve and search them over REST.
  [make-store-app (->* (fhir-store?
                        #:package (or/c path-string? (listof path-string?))
                        #:types (listof symbol?))
                       (#:url (or/c string? #f) #:extra-params hash? #:fhir-version string?
                        #:audit? boolean?)
                       app?)]))

(define default-interactions '(read vread create update delete search-type))

;; ---- the repository bridge ---------------------------------------------------
;; capability handlers speak TYPED NODES; the engine speaks jsexpr — convert at the boundary.
;; `record` (or #f) is called AFTER each committed write: (record action rtype id).
(define (store-repository store type catalog [record #f])
  (define rtype (symbol->string type))
  (define (js->node js) (ok-or-raise (from-json js #:lenient? #t)))
  (define (record! action id) (when record (record action rtype id)))
  (make-repository
   #:read   (lambda (id) (let ([js (fhir-read store rtype id)]) (and js (js->node js))))
   #:vread  (lambda (id vid)
              (let ([js (fhir-vread store rtype id (or (string->number vid) 0))])
                (and js (js->node js))))
   #:create (lambda (node)
              (define js (node->jsexpr node))
              (define-values (_t id _v) (fhir-create! store js #:search-params catalog))
              (record! "create" id)
              (js->node (fhir-read store rtype id)))
   #:update (lambda (id node)
              (define js (hash-set (node->jsexpr node) 'id id))
              (fhir-update! store js #:search-params catalog)
              (record! "update" id)
              (js->node (fhir-read store rtype id)))
   #:delete (lambda (id) (fhir-delete! store rtype id) (record! "delete" id) (void))
   #:patch (cons (lambda (id) (let ([js (fhir-read store rtype id)]) (and js (js->node js))))
                 (lambda (id node)
                   (fhir-update! store (hash-set (node->jsexpr node) 'id id) #:search-params catalog)
                   (record! "update" id)
                   (js->node (fhir-read store rtype id))))
   #:history (lambda (id params)
               (define since (let ([p (assoc "_since" params)]) (and p (cdr p))))
               (define count (let ([p (assoc "_count" params)]) (and p (string->number (cdr p)))))
               (map js->node (if id
                                 (fhir-history store rtype id #:since since #:count count)
                                 (fhir-history-type store rtype #:since since #:count count))))
   #:search (lambda (params)
              (define qps (for/list ([p (in-list params)]) (cons (symbol->string (car p)) (cdr p))))
              (define-values (matches ignored total) (fhir-search/page store rtype qps #:search-params catalog))
              (define includes (if (for/or ([q (in-list qps)]) (member (car q) '("_include" "_revinclude")))
                                   (map js->node (fhir-includes store rtype matches qps))
                                   '()))
              ;; the page, what it pulls in, what the store could not search on (said in the
              ;; searchset, not silently dropped) and how many match in all
              (search-page (map js->node matches) includes ignored total))))

;; ---- audit / provenance recording --------------------------------------------
;; One AuditEvent per write (+ one Provenance per create/update), created in the SAME store so
;; they're served and searchable like any other resource. Writes to AuditEvent/Provenance
;; themselves are never recorded (no recursion); recording runs AFTER the audited transaction
;; commits (a concurrent write inside it would contend for the WAL writer lock).
(define audit-exempt '("AuditEvent" "Provenance"))

(define (make-recorder store catalog)
  (lambda (action rtype id)
    (unless (member rtype audit-exempt)
      (define now (now-instant))
      (fhir-create! store (audit-event-js action rtype id now) #:search-params catalog)
      (when (member action '("create" "update"))
        (fhir-create! store (provenance-js action rtype id now) #:search-params catalog)))))

;; https://hl7.org/fhir/R5/auditevent.html — action C/U/D, the restful-interaction as the code
(define (audit-event-js action rtype id now)
  (hasheq 'resourceType "AuditEvent"
          'action (match action ["create" "C"] ["update" "U"] ["delete" "D"] [_ "E"])
          'recorded now
          'code (hasheq 'coding (list (hasheq 'system "http://hl7.org/fhir/restful-interaction"
                                              'code action)))
          'outcome (hasheq 'code (hasheq 'system "http://terminology.hl7.org/CodeSystem/audit-event-outcome"
                                         'code "0" 'display "Success"))
          'agent (list (hasheq 'who (hasheq 'display "fhir-store") 'requestor #t))
          'entity (list (hasheq 'what (hasheq 'reference (format "~a/~a" rtype id))))))

;; https://hl7.org/fhir/R5/provenance.html — who touched the target, when, doing what
(define (provenance-js action rtype id now)
  (hasheq 'resourceType "Provenance"
          'target (list (hasheq 'reference (format "~a/~a" rtype id)))
          'recorded now
          'activity (hasheq 'coding (list (hasheq 'system "http://terminology.hl7.org/CodeSystem/v3-DataOperation"
                                                  'code (match action ["create" "CREATE"] [_ "UPDATE"]))))
          'agent (list (hasheq 'who (hasheq 'display "fhir-store")))))

;; audit a processed bundle from its request/response pair (post-commit)
(define (record-bundle! record request-js response-js)
  (for ([req (in-list (hash-ref request-js 'entry '()))]
        [rsp (in-list (hash-ref response-js 'entry '()))])
    (define r (hash-ref rsp 'response (hasheq)))
    (define status (hash-ref r 'status ""))
    (when (string-prefix? status "2")
      (define method (let ([q (hash-ref req 'request (hasheq))])
                       (and (hash? q) (hash-ref q 'method #f))))
      (define action (match method ["POST" "create"] ["PUT" "update"] ["DELETE" "delete"] [_ #f]))
      (define target
        (cond [(hash-ref r 'location #f)
               => (lambda (loc) (let ([m (regexp-match #px"^([A-Za-z]+)/([^/]+)" loc)])
                                  (and m (cons (cadr m) (caddr m)))))]
              [else (let* ([q (hash-ref req 'request (hasheq))]
                           [url (and (hash? q) (hash-ref q 'url #f))]
                           [m (and (string? url) (regexp-match #px"^([A-Za-z]+)/([^/?]+)" url))])
                      (and m (cons (cadr m) (caddr m))))]))
      (when (and action target)
        (record action (car target) (cdr target))))))

;; ---- the app -----------------------------------------------------------------
(define (make-store-app store #:package package #:types types
                        #:url [url #f] #:extra-params [extra (hash)]
                        #:fhir-version [fhir-version "5.0.0"]
                        #:audit? [audit? #f])
  ;; 1. the search-param catalog comes from the PACKAGES' SearchParameter resources
  (define catalog
    (merge-search-params
     (for/fold ([acc (hash)]) ([p (in-list (if (list? package) package (list package)))])
       (merge-search-params acc (search-params-from-package p #:types types)))
     extra))
  ;; 2. derive the CapabilityStatement advertising exactly those parameters
  (define resources
    (for/list ([ty (in-list types)])
      (rc-resource ty default-interactions
                   ;; advertise exactly what the engine executes (composite/special are
                   ;; cataloged but ignored by search — claiming them would overstate support)
                   (for/list ([sp (in-list (hash-ref catalog ty '()))]
                              #:when (indexed-kind? (search-param-kind sp)))
                     (list (string->symbol (search-param-name sp))
                           (search-param-kind sp)
                           (search-param-path sp)))
                   #f)))
  (define server (rc-server "server" "active" (now-date) fhir-version '("json") url))
  (define capability (derive-capability-statement server resources '()))
  ;; 3. one store-backed repository per type (+ the audit recorder and the Bundle processor)
  (define record (and audit? (make-recorder store catalog)))
  (build-app #:capability capability
             #:operation-definitions '()
             #:operations '()
             #:repositories (for/list ([ty (in-list types)])
                              (cons ty (store-repository store ty catalog record)))
             #:transaction (lambda (bundle-js)
                             (define resp (process-bundle! store bundle-js #:search-params catalog))
                             (when record (record-bundle! record bundle-js resp))
                             resp)))

(define (now-instant)
  (define d (seconds->date (current-seconds) #f))
  (define (p2 n) (if (< n 10) (format "0~a" n) (number->string n)))
  (format "~a-~a-~aT~a:~a:~aZ" (date-year d) (p2 (date-month d)) (p2 (date-day d))
          (p2 (date-hour d)) (p2 (date-minute d)) (p2 (date-second d))))

(define (now-date)
  (define d (seconds->date (current-seconds) #f))
  (define (p2 n) (if (< n 10) (format "0~a" n) (number->string n)))
  (format "~a-~a-~a" (date-year d) (p2 (date-month d)) (p2 (date-day d))))

(module+ test
  (require rackunit racket/file racket/runtime-path
           (only-in fhir/r5/schemas)
           (only-in fhir/capability/runtime dispatch search-request create-request)
           (only-in fhir/model/node fhir-ref fhir-type))
  (define r5 (spec-package-path "hl7.fhir.r5.core.tgz"))
  (define tmp (make-temporary-file "store-serve-~a.db"))
  (define store (open-fhir-store tmp))
  (define app (make-store-app store #:package r5 #:types '(Patient Observation)))
  ;; the CapabilityStatement advertises the IG-derived params
  (define cs (node->jsexpr (app-capability-statement app)))
  (define pat-rest (findf (lambda (r) (equal? (hash-ref r 'type) "Patient"))
                          (hash-ref (car (hash-ref cs 'rest)) 'resource)))
  (define advertised (map (lambda (s) (hash-ref s 'name)) (hash-ref pat-rest 'searchParam)))
  (check-true (and (member "gender" advertised) #t))
  (check-true (and (member "identifier" advertised) #t))
  ;; create through dispatch, then search by an IG-derived param
  (define pt (ok-value (from-json (hasheq 'resourceType "Patient" 'gender "female") #:lenient? #t)))
  (define created (dispatch app (create-request 'Patient pt)))
  (check-equal? (fhir-type created) 'Patient)
  (define hits (dispatch app (search-request 'Patient (list (cons 'gender "female")))))
  (check-equal? (fhir-type hits) 'Bundle)
  (check-equal? (length (fhir-ref hits 'entry '())) 1)
  (close-fhir-store store) (delete-file tmp))

(require (only-in fhir/capability/runtime app-capability-statement))
