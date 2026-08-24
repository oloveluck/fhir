#lang racket/base

;;; store-http-test.rkt — end-to-end: IG SearchParameters -> CapabilityStatement -> live HTTP
;;; endpoints over the SQLite store. The advertised params and the working search both come
;;; from the R5 core package's own SearchParameter resources (store/ig-params.rkt).

(require rackunit
         racket/tcp racket/string racket/port racket/file racket/runtime-path
         json
         fhir/r5/schemas
         (only-in fhir/http/server serve-app)
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         (only-in fhir/store/serve make-store-app))

(define-runtime-path r5-package "../spec/hl7.fhir.r5.core.tgz")
(define tmp (make-temporary-file "store-http-~a.db"))
(define store (open-fhir-store tmp))
(define app (make-store-app store #:package r5-package #:types '(Patient Observation)))

(define port 8178)
(define stop (serve-app app #:port port))

;; a tiny HTTP/1.1 client: returns (values status-code body-string)
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
  ;; /metadata advertises the IG-derived search parameters
  (let-values ([(s b) (req "GET" "/metadata")])
    (check-equal? s 200)
    (define cs (string->jsexpr b))
    (check-equal? (hash-ref cs 'resourceType) "CapabilityStatement")
    (check-equal? (hash-ref cs 'fhirVersion) "5.0.0")
    (define resources (hash-ref (car (hash-ref cs 'rest)) 'resource))
    (define (params-of ty)
      (map (lambda (p) (hash-ref p 'name))
           (hash-ref (findf (lambda (r) (equal? (hash-ref r 'type) ty)) resources) 'searchParam)))
    ;; these come from the package's SearchParameter resources, not a hand catalog
    (check-true (and (member "gender" (params-of "Patient")) #t))
    (check-true (and (member "birthdate" (params-of "Patient")) #t))
    (check-true (and (member "code" (params-of "Observation")) #t))
    (check-true (and (member "patient" (params-of "Observation")) #t)))

  ;; create Patients over HTTP (persisted to SQLite)
  (define pid
    (let-values ([(s b) (req "POST" "/Patient"
                             "{\"resourceType\":\"Patient\",\"gender\":\"female\",\"identifier\":[{\"system\":\"urn:mrn\",\"value\":\"42\"}]}")])
      (check-equal? s 201)
      (hash-ref (string->jsexpr b) 'id)))
  (let-values ([(s _) (req "POST" "/Patient" "{\"resourceType\":\"Patient\",\"gender\":\"male\"}")])
    (check-equal? s 201))

  ;; search endpoints hit the store's indexes via the IG-derived FHIRPath
  (let-values ([(s b) (req "GET" "/Patient?gender=female")])
    (check-equal? s 200)
    (define bundle (string->jsexpr b))
    (check-equal? (hash-ref bundle 'type) "searchset")
    (check-equal? (length (hash-ref bundle 'entry '())) 1))
  (let-values ([(s b) (req "GET" "/Patient?identifier=urn:mrn%7C42")])
    (check-equal? s 200)
    (check-equal? (length (hash-ref (string->jsexpr b) 'entry '())) 1))
  (let-values ([(s b) (req "GET" "/Patient?gender=other")])
    (check-equal? (length (hash-ref (string->jsexpr b) 'entry '())) 0))

  ;; reference search: an Observation pointing at the Patient
  (let-values ([(s _) (req "POST" "/Observation"
                           (jsexpr->string
                            (hasheq 'resourceType "Observation" 'status "final"
                                    'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "883-9")))
                                    'subject (hasheq 'reference (string-append "Patient/" pid)))))])
    (check-equal? s 201))
  (let-values ([(s b) (req "GET" (string-append "/Observation?patient=Patient/" pid))])
    (check-equal? s 200)
    (check-equal? (length (hash-ref (string->jsexpr b) 'entry '())) 1))
  (let-values ([(s b) (req "GET" "/Observation?code=http://loinc.org%7C883-9")])
    (check-equal? (length (hash-ref (string->jsexpr b) 'entry '())) 1))

  ;; read / vread / delete round the store
  (let-values ([(s b) (req "GET" (string-append "/Patient/" pid))])
    (check-equal? s 200)
    (check-equal? (hash-ref (string->jsexpr b) 'gender) "female"))
  (let-values ([(s b) (req "GET" (string-append "/Patient/" pid "/_history/1"))])
    (check-equal? s 200))
  (let-values ([(s _) (req "DELETE" (string-append "/Patient/" pid))])
    (check-equal? s 200))
  (let-values ([(s _) (req "GET" (string-append "/Patient/" pid))])
    (check-equal? s 404)))

(stop)
(close-fhir-store store)
(delete-file tmp)
