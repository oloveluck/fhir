#lang racket/base

;;; operations.rkt — expose operations (fhir/operation) over HTTP, with the CapabilityStatement derived
;;; from them.
;;;
;;;   (serve-operations (list $validate (operation "ValueSet/$expand")) #:port 8080)
;;;   (operations-app ops)                    the app: GET /metadata + every operation, nothing else
;;;   (operation->entries op)                 the routes of one operation, for any app
;;;   (operation->rc op) / (operation->od op) its CapabilityStatement entry / its OperationDefinition
;;;
;;; An operation is served at every level its OperationDefinition declares and on every resource type
;;; it names (Resource / DomainResource: any type). A request's Parameters become the inputs; at
;;; instance level the subject is the app's stored resource (its repository's read, through
;;; `current-app`) unless `#:read` says otherwise; `#:around` wraps each invocation (a server binds
;;; its data source and packages there). The CapabilityStatement entries carry the operation's own
;;; canonical, so what /metadata advertises is exactly what is routed.
;;; In `#lang fhir/capability`, `(operation "ValueSet/$expand")` exposes a registered operation the
;;; same way (capability/declare).

(require racket/contract racket/list
         fhir/operation
         (only-in fhir/kernel/operation-entry operation-entry)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/serialize/read-json strip-jnum)
         (only-in fhir/result/result ok-or-raise ok? ok-value)
         (only-in "derive.rkt" rc-operation rc-server derive-capability-statement)
         (only-in "runtime.rkt" build-app app? current-app app-repositories repository-read
                  request-id request-body request-type))

(provide
 (contract-out
  [operation->entries (->* (operation?) (#:read (or/c #f procedure?) #:around procedure?) list?)]
  [operation->rc (-> operation? any/c)]
  [operation->od (-> operation? any/c)]
  [operations-app (->* ((listof operation?)) (#:url (or/c string? #f) #:fhir-version string?
                                               #:terminology-capabilities (or/c hash? #f)) app?)]
  [serve-operations (->* ((listof operation?)) (#:port exact-nonnegative-integer? #:url (or/c string? #f)
                                                #:fhir-version string? #:bearer (or/c string? #f)
                                                  #:terminology-capabilities (or/c hash? #f))
                         procedure?)]))

;; the stored resource an instance-level request names: the current app's repository for the type
(define (app-read type id)
  (define a (current-app))
  (define repo (and a (hash-ref (app-repositories a) (string->symbol type) #f)))
  (define read (and repo (repository-read repo)))
  (define node (and read (read id)))
  (and node (node->jsexpr node)))

;; operation->entries : operation -> (listof operation-entry)
(define (operation->entries op #:read [read app-read] #:around [around (lambda (thunk) (thunk))])
  (define types (let ([ts (operation-resource-types op)]) (if (null? ts) '(#f) ts)))
  (define (handler level type)
    (lambda (_in req)
      (define result
        (around
         (lambda ()
           (with-handlers ([exn:fail:operation? exn:fail:operation-outcome])
             (define body (request-body req))
             (define inputs (parameters->inputs (if body (strip-jnum (node->jsexpr body)) (hasheq))))
             ;; the request's own type: an operation on Resource is entered under "Resource"
             (define rtype (let ([t (request-type req)]) (if t (symbol->string t) type)))
             (define subject (and (eq? level 'instance) read (read rtype (request-id req))))
             (if (and (eq? level 'instance) (not subject))
                 (outcome "error" "not-found" (format "~a/~a is not on this server" rtype (request-id req)))
                 (invoke op subject inputs))))))
      (ok-or-raise (from-json result #:lenient? #t))))
  (for*/list ([level (in-list (operation-levels op))]
              [type (in-list (if (eq? level 'system) '(#f) types))])
    (operation-entry level (operation-code op) type (handler level type))))

;; operation->rc : operation -> rc-operation   its CapabilityStatement entry, under its own canonical
(define (operation->rc op)
  (define levels (operation-levels op))
  (rc-operation (operation-code op) (string-append "$" (operation-code op))
                (list (and (memq 'system levels) #t) (and (memq 'type levels) #t) (and (memq 'instance levels) #t))
                (operation-resource-types op) '() '() (operation-url op)))

;; operation->od : operation -> OperationDefinition node   (drives the runtime's input validation)
(define (operation->od op) (ok-or-raise (from-json (strip-jnum (operation-definition op)) #:lenient? #t)))

;; operations-app : (listof operation) -> app   /metadata derived from the operations themselves
(define (operations-app ops #:url [url #f] #:fhir-version [fhir-version "5.0.0"]
                        #:terminology-capabilities [capabilities #f])
  (define d (seconds->date (current-seconds) #f))
  (define (p2 n) (if (< n 10) (format "0~a" n) (number->string n)))
  (build-app #:capability (derive-capability-statement
                           (rc-server "server" "active"
                                      (format "~a-~a-~a" (date-year d) (p2 (date-month d)) (p2 (date-day d)))
                                      fhir-version '("json") url)
                           '() (map operation->rc ops))
             #:operation-definitions (map operation->od ops)
             #:repositories '()
             #:operations (append-map operation->entries ops)
             ;; a TerminologyCapabilities (jsexpr) answers GET /metadata?mode=terminology
             #:metadata (let ([r (and capabilities (from-json capabilities #:lenient? #t))])
                          (if (and r (ok? r)) (hash "terminology" (ok-value r)) (hash)))))

;; serve-operations : (listof operation) -> stop-thunk   the operations over HTTP (http/server)
(define (serve-operations ops #:port [port 8080] #:url [url #f] #:fhir-version [fv "5.0.0"] #:bearer [bearer #f]
                          #:terminology-capabilities [capabilities #f])
  ((dynamic-require 'fhir/http/server 'serve-app)
   (operations-app ops #:url url #:fhir-version fv #:terminology-capabilities capabilities)
   #:port port #:bearer bearer))

(require (only-in fhir/serialize/from-json from-json) (only-in fhir/result/result ok? ok-value))
