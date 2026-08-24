#lang racket/base

;;; sof-op-test.rkt — the SQL-on-FHIR operations end to end over a real socket:
;;; ViewDefinition is a stored, searchable resource (the SOF IG's own SearchParameters), and
;;; $sql-run executes views — inline, by reference, and by canonical — returning raw ndjson/csv
;;; streams (not Binary envelopes) per the IG's OperationDefinitions, which /metadata advertises
;;; by their REAL canonical urls.

(require rackunit
         racket/tcp racket/string racket/port racket/file racket/runtime-path
         json
         fhir/r5/schemas
         (only-in fhir/http/server serve-app)
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         (only-in fhir/store/serve make-store-app))

(define-runtime-path r5-package "../spec/hl7.fhir.r5.core.tgz")
(define-runtime-path sof-package "../spec/hl7.fhir.uv.sql-on-fhir.tgz")
(define tmp (make-temporary-file "sof-op-~a.db"))
(define store (open-fhir-store tmp))
(define app (make-store-app store
                            #:package (list r5-package sof-package)
                            #:types '(Patient Observation ViewDefinition)
                            #:sof? #t))

(define port 8179)
(define stop (serve-app app #:port port))

;; a tiny HTTP/1.1 client returning (values status content-type body-string)
(define (req method path [body #f])
  (define-values (in out) (tcp-connect "127.0.0.1" port))
  (define b (or body ""))
  (fprintf out "~a ~a HTTP/1.1\r\nHost: localhost\r\nContent-Length: ~a\r\nConnection: close\r\n\r\n~a"
           method path (bytes-length (string->bytes/utf-8 b)) b)
  (flush-output out)
  (define resp (port->string in))
  (close-output-port out) (close-input-port in)
  (define status (string->number (cadr (string-split (car (string-split resp "\r\n"))))))
  (define ctype (let ([m (regexp-match #px"(?i:content-type):\\s*([^\r\n]+)" resp)])
                  (and m (cadr m))))
  (define body-str (let ([i (regexp-match-positions #rx"\r\n\r\n" resp)])
                     (if i (substring resp (cdar i)) "")))
  (values status ctype body-str))

(define view-js
  (hasheq 'resourceType "ViewDefinition" 'id "pt-view" 'name "patients" 'status "active"
          'url "http://example.org/ViewDefinition/patients"
          'resource "Patient"
          'select (list (hasheq 'column (list (hasheq 'name "id" 'path "getResourceKey()")
                                              (hasheq 'name "gender" 'path "gender"))))))

(define (params . ps)
  (jsexpr->string
   (hasheq 'resourceType "Parameters"
           'parameter (for/list ([p (in-list ps)])
                        (apply hasheq 'name (car p) (cadr p))))))

(with-handlers ([(lambda (_) #t) (lambda (e) (stop) (close-fhir-store store) (raise e))])
  ;; /metadata advertises the IG operations by their REAL canonicals
  (let-values ([(s _c b) (req "GET" "/metadata")])
    (check-equal? s 200)
    (define ops (hash-ref (car (hash-ref (string->jsexpr b) 'rest)) 'operation))
    (define defs (map (lambda (o) (hash-ref o 'definition)) ops))
    (check-true (and (member "http://hl7.org/fhir/uv/sql-on-fhir/OperationDefinition/SQLRun" defs) #t))
    (check-true (and (member "http://hl7.org/fhir/uv/sql-on-fhir/OperationDefinition/SQLExport" defs) #t))
    ;; ViewDefinition is served, with the IG's own search params advertised
    (define vd (findf (lambda (r) (equal? (hash-ref r 'type) "ViewDefinition"))
                      (hash-ref (car (hash-ref (string->jsexpr b) 'rest)) 'resource)))
    (check-true (and (member "url" (map (lambda (p) (hash-ref p 'name)) (hash-ref vd 'searchParam))) #t)))

  ;; data + a stored view
  (let-values ([(s _c _b) (req "POST" "/Patient" "{\"resourceType\":\"Patient\",\"id\":\"1\",\"gender\":\"female\"}")])
    (check-equal? s 201))
  (let-values ([(s _c _b) (req "POST" "/Patient" "{\"resourceType\":\"Patient\",\"id\":\"2\",\"gender\":\"male\"}")])
    (check-equal? s 201))
  (let-values ([(s _c _b) (req "PUT" "/ViewDefinition/pt-view" (jsexpr->string view-js))])
    (check-equal? s 200))
  ;; the IG's `url` search param finds it
  (let-values ([(s _c b) (req "GET" "/ViewDefinition?url=http://example.org/ViewDefinition/patients")])
    (check-equal? s 200)
    (check-equal? (length (hash-ref (string->jsexpr b) 'entry '())) 1))

  ;; $sql-run by CANONICAL -> raw ndjson stream (the default format)
  (let-values ([(s c b) (req "POST" "/$sql-run"
                             (params (list "subjectCanonical"
                                           '(valueCanonical "http://example.org/ViewDefinition/patients"))))])
    (check-equal? s 200)
    (check-true (regexp-match? #px"application/x-ndjson" c))
    (check-equal? (length (string-split b "\n")) 2))

  ;; by REFERENCE, csv -> text/csv with header
  (let-values ([(s c b) (req "POST" "/$sql-run"
                             (params (list "subjectReference"
                                           `(valueReference ,(hasheq 'reference "ViewDefinition/pt-view")))
                                     (list "_format" '(valueCode "csv"))))])
    (check-equal? s 200)
    (check-true (regexp-match? #px"text/csv" c))
    (check-equal? (car (string-split b "\r\n")) "id,gender"))

  ;; INLINE subjectResource with inline data, json format + _limit
  (let-values ([(s c b) (req "POST" "/$sql-run"
                             (params (list "subjectResource" `(resource ,(hash-remove view-js 'id)))
                                     (list "resource" '(resource #hasheq((resourceType . "Patient")
                                                                         (id . "9") (gender . "other"))))
                                     (list "_format" '(valueCode "json"))))])
    (check-equal? s 200)
    (check-true (regexp-match? #px"application/json" c))
    (check-equal? (map (lambda (h) (hash-ref h 'id)) (string->jsexpr b)) '("9")))

  ;; GET form: query params become the input Parameters
  (let-values ([(s c b) (req "GET" "/$sql-run?subjectCanonical=http://example.org/ViewDefinition/patients&_format=csv&header=false")])
    (check-equal? s 200)
    (check-true (regexp-match? #px"text/csv" c))
    (check-equal? (length (filter (lambda (l) (positive? (string-length l))) (string-split b "\r\n"))) 2))

  ;; exactly-one-subject violation -> 400
  (let-values ([(s _c _b) (req "POST" "/$sql-run" (params))])
    (check-equal? s 400))

  ;; _format=fhir -> a Parameters resource (FHIR JSON, not a raw stream)
  (let-values ([(s c b) (req "POST" "/$sql-run"
                             (params (list "subjectCanonical"
                                           '(valueCanonical "http://example.org/ViewDefinition/patients"))
                                     (list "_format" '(valueCode "fhir"))))])
    (check-equal? s 200)
    (check-true (regexp-match? #px"fhir\\+json" c))
    (check-equal? (hash-ref (string->jsexpr b) 'resourceType) "Parameters"))

  ;; $sql-export: synchronous-completion manifest with an output per subject
  (let-values ([(s _c b) (req "POST" "/$sql-export"
                              (params (list "subject"
                                            '(valueCanonical "http://example.org/ViewDefinition/patients"))))])
    (check-equal? s 200)
    (define ps (hash-ref (string->jsexpr b) 'parameter))
    (define (p name) (findf (lambda (x) (equal? (hash-ref x 'name) name)) ps))
    (check-equal? (hash-ref (p "status") 'valueCode) "completed")
    (check-true (hash? (p "exportId")))
    (check-true (hash? (p "output")))))

(stop)
(close-fhir-store store)
(delete-file tmp)
