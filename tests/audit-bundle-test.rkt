#lang racket/base

;;; audit-bundle-test.rkt — transaction Bundles + audit/provenance, end to end over HTTP:
;;; POST / applies a transaction atomically (urn:uuid references rewritten), the response is a
;;; transaction-response Bundle, and — with #:audit? — every write leaves an AuditEvent and a
;;; Provenance IN the store, served and searchable like any other resource.

(require rackunit
         racket/tcp racket/string racket/port racket/file racket/runtime-path racket/list
         json
         fhir/r5/schemas
         (only-in fhir/http/server serve-app)
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         (only-in fhir/store/serve make-store-app))

(define-runtime-path r5-package "../spec/hl7.fhir.r5.core.tgz")
(define tmp (make-temporary-file "audit-~a.db"))
(define store (open-fhir-store tmp))
(define app (make-store-app store #:package r5-package
                            #:types '(Patient Observation AuditEvent Provenance)
                            #:audit? #t))

(define port 8182)
(define stop (serve-app app #:port port))

(define (req method path [body #f])
  (define-values (in out) (tcp-connect "127.0.0.1" port))
  (define b (or body ""))
  (fprintf out "~a ~a HTTP/1.1\r\nHost: localhost\r\nContent-Length: ~a\r\nConnection: close\r\n\r\n~a"
           method path (bytes-length (string->bytes/utf-8 b)) b)
  (flush-output out)
  (define resp (port->string in))
  (close-output-port out) (close-input-port in)
  (define status (string->number (cadr (string-split (car (string-split resp "\r\n"))))))
  (define body-str (let ([i (regexp-match-positions #rx"\r\n\r\n" resp)])
                     (if i (substring resp (cdar i)) "")))
  (values status body-str))

(with-handlers ([(lambda (_) #t) (lambda (e) (stop) (close-fhir-store store) (raise e))])
  ;; a transaction with an internal urn reference, over the wire
  (define txn
    (jsexpr->string
     (hasheq 'resourceType "Bundle" 'type "transaction"
             'entry (list
                     (hasheq 'fullUrl "urn:uuid:p1"
                             'resource (hasheq 'resourceType "Patient" 'gender "female")
                             'request (hasheq 'method "POST" 'url "Patient"))
                     (hasheq 'fullUrl "urn:uuid:o1"
                             'resource (hasheq 'resourceType "Observation" 'status "final"
                                               'code (hasheq 'text "bp")
                                               'subject (hasheq 'reference "urn:uuid:p1"))
                             'request (hasheq 'method "POST" 'url "Observation"))))))
  (let-values ([(s b) (req "POST" "/" txn)])
    (check-equal? s 200)
    (define resp (string->jsexpr b))
    (check-equal? (hash-ref resp 'type) "transaction-response")
    (check-equal? (for/list ([e (in-list (hash-ref resp 'entry))])
                    (hash-ref (hash-ref e 'response) 'status))
                  '("201 Created" "201 Created")))

  ;; the reference was rewritten: the Observation's subject is a literal Patient/id that resolves
  (let-values ([(s b) (req "GET" "/Observation")])
    (define obs (hash-ref (car (hash-ref (string->jsexpr b) 'entry)) 'resource))
    (define ref (hash-ref (hash-ref obs 'subject) 'reference))
    (check-true (string-prefix? ref "Patient/"))
    (let-values ([(s2 _) (req "GET" (string-append "/" ref))])
      (check-equal? s2 200)))

  ;; the audit trail: one AuditEvent per write, searchable over REST
  (let-values ([(s b) (req "GET" "/AuditEvent?action=C")])
    (check-equal? s 200)
    (define n (length (hash-ref (string->jsexpr b) 'entry '())))
    (check-equal? n 2))                                     ; the two transaction creates
  ;; Provenance targets the created Patient
  (let-values ([(s b) (req "GET" "/Provenance")])
    (define provs (map (lambda (e) (hash-ref e 'resource)) (hash-ref (string->jsexpr b) 'entry '())))
    (check-equal? (length provs) 2)
    (check-true (for/or ([p (in-list provs)])
                  (string-prefix? (hash-ref (car (hash-ref p 'target)) 'reference) "Patient/"))))

  ;; a plain REST create is audited too (and audit writes are NOT themselves audited)
  (let-values ([(s _) (req "POST" "/Patient" "{\"resourceType\":\"Patient\",\"gender\":\"male\"}")])
    (check-equal? s 201))
  (let-values ([(s b) (req "GET" "/AuditEvent")])
    (check-equal? (length (hash-ref (string->jsexpr b) 'entry '())) 3))  ; 2 txn + 1 rest, no recursion

  ;; a failing transaction rolls back atomically — nothing new audited, nothing stored
  (define bad
    (jsexpr->string
     (hasheq 'resourceType "Bundle" 'type "transaction"
             'entry (list
                     (hasheq 'resource (hasheq 'resourceType "Patient" 'id "dup-1" 'gender "other")
                             'request (hasheq 'method "POST" 'url "Patient"))
                     (hasheq 'resource (hasheq 'resourceType "Patient" 'id "dup-1" 'gender "other")
                             'request (hasheq 'method "POST" 'url "Patient"))))))
  (let-values ([(s b) (req "POST" "/" bad)])
    (check-equal? s 400)
    (check-true (regexp-match? #rx"OperationOutcome" b)))
  (let-values ([(s _) (req "GET" "/Patient/dup-1")])
    (check-equal? s 404))                                   ; rolled back
  (let-values ([(_s b) (req "GET" "/AuditEvent")])
    (check-equal? (length (hash-ref (string->jsexpr b) 'entry '())) 3))  ; nothing recorded

  ;; a batch reports per-entry outcomes instead
  (let-values ([(s b) (req "POST" "/" (string-replace bad "transaction" "batch"))])
    (check-equal? s 200)
    (define statuses (for/list ([e (in-list (hash-ref (string->jsexpr b) 'entry))])
                       (hash-ref (hash-ref e 'response) 'status)))
    (check-equal? (car statuses) "201 Created")
    (check-true (string-prefix? (cadr statuses) "400"))))

(stop)
(close-fhir-store store)
(delete-file tmp)
