#lang racket/base

;;; apply.rkt — the verb apply: any operation (fhir/operation) applied by reference, here or on a
;;; FHIR server.

(require json (only-in net/url string->url post-pure-port get-pure-port) (only-in fhir/operation operation) "tools.rkt"
         "hub.rkt" "data.rkt")

;; Contracted in workspace.rkt.
(provide hub-apply)

(define (hub-apply h ref inputs resource [url #f])
  (refresh! h)
  (with-hub h
    (lambda ()
      (define o (if url #f (with-handlers ([exn:fail? (lambda (e) e)]) (operation ref))))
      (audited h "apply" (hasheq 'kind "operation" 'operation ref 'text (jsexpr->string inputs))
               (lambda ()
                 (cond
                   ;; a server named by `url` (any FHIR server: a capability app served with
                   ;; `raco fhir-server serve`, which a shell call's process does not know of)
                   [url (or (apply-on-servers ref inputs resource (list (cons 'given (regexp-replace #rx"/+$" url ""))))
                            (error 'apply (format "~a answered no ~a" url ref)))]
                   [(not (exn? o)) (apply-json o inputs resource)]
                   [(apply-on-servers ref inputs resource) => values]
                   [else (error 'apply (format "no operation ~a: ~a~a" ref (exn-message o)
                                               "; an operation of a served capability app is applied with its url: apply(operation, url: \"http://localhost:8080\", inputs: …) (a server `run` started in another call has stopped with it)"))]))))))

;; apply-on-servers : ref inputs resource -> jsexpr | #f   an operation of a capability app the
;; workspace serves (capability/workspace's running servers), POSTed as a Parameters resource to
;; `<base>/[Type/][id/]$code`; #f when no running app has it
(define (apply-on-servers ref inputs resource [given #f])
  (define running (if given
                      (lambda () given)
                      (with-handlers ([exn:fail? (lambda (_) (lambda () '()))])
                        (dynamic-require 'fhir/capability/workspace 'running-servers))))
  (define m (regexp-match #px"^(?:([A-Z][A-Za-z]+)/)?(?:([A-Za-z0-9.-]+)/)?[$]([A-Za-z0-9-]+)$" ref))
  (and m (pair? (running))
       (let* ([type (cadr m)] [id (caddr m)] [code (cadddr m)])
         (for/or ([srv (in-list (running))])
           ;; each input under the key of the type the server's definition declares for it: a
           ;; server holds a POSTed value to the type its key names
           (define types (declared-types (cdr srv) code))
           (define params (hasheq 'resourceType "Parameters"
                                  'parameter (append
                                              (for*/list ([(k v) (in-hash inputs)] [x (in-list (if (list? v) v (list v)))])
                                                (parameter-of (symbol->string k) x (hash-ref types (symbol->string k) #f)))
                                              (if resource (list (hasheq 'name "resource" 'resource resource)) '()))))
           (define url (string-append (cdr srv) "/" (if type (string-append type "/") "") (if id (string-append id "/") "") "$" code))
           (define answer (with-handlers ([exn:fail? (lambda (_) #f)])
                            (define in (post-pure-port (string->url url) (string->bytes/utf-8 (jsexpr->string params))
                                                       '("Content-Type: application/fhir+json")))
                            (begin0 (read-json in) (close-input-port in))))
           (and (hash? answer)
                (not (and (equal? (hash-ref answer 'resourceType #f) "OperationOutcome")
                          (for/or ([i (in-list (hash-ref answer 'issue '()))]) (equal? (hash-ref i 'code #f) "not-supported"))))
                answer)))))

;; declared-types : base-url code -> (hash name type)   the inputs' types in the definition the
;; server publishes for the operation (`GET <base>/OperationDefinition/<code>`); none when it
;; publishes none
(define (declared-types base code)
  (define od (with-handlers ([exn:fail? (lambda (_) #f)])
               (define in (get-pure-port (string->url (string-append base "/OperationDefinition/" code)) '("Accept: application/fhir+json")))
               (begin0 (read-json in) (close-input-port in))))
  (for/hash ([p (in-list (if (and (hash? od) (equal? (hash-ref od 'resourceType #f) "OperationDefinition"))
                             (hash-ref od 'parameter '())
                             '()))]
             #:when (and (hash? p) (equal? (hash-ref p 'use #f) "in") (string? (hash-ref p 'type #f))))
    (values (hash-ref p 'name "") (hash-ref p 'type))))

;; value-key : type -> symbol   the key a value of a FHIR type is under in a Parameters entry
(define (value-key type) (string->symbol (string-append "value" (string-upcase (substring type 0 1)) (substring type 1))))

;; parameter-of : name jsexpr (or/c #f type) -> Parameters.parameter   under the key of the declared
;; type when the definition is known — text given for a number or a boolean (a shell's `weight=80`)
;; read as one —, else by the value's JSON type
(define (parameter-of name v [type #f])
  (define (as key value) (hasheq 'name name key value))
  (define number-types '("decimal" "integer" "positiveInt" "unsignedInt" "integer64"))
  (cond [(and (hash? v) (hash-ref v 'resourceType #f)) (as 'resource v)]
        [(boolean? v) (as 'valueBoolean v)]
        [(exact-integer? v) (as (if (equal? type "decimal") 'valueDecimal 'valueInteger) v)]
        [(real? v) (as 'valueDecimal v)]
        [(and (hash? v) type (regexp-match? #rx"^[A-Z]" type)) (as (value-key type) v)]
        [(not (string? v)) (as 'valueString (format "~a" v))]
        [(and (member type number-types) (string->number v 10))
         => (lambda (n) (if (and (real? n) (or (equal? type "decimal") (exact-integer? n)))
                            (as (value-key type) (if (exact? n) (if (integer? n) n (exact->inexact n)) n))
                            (as 'valueString v)))]
        [(and (equal? type "boolean") (member v '("true" "false"))) (as 'valueBoolean (equal? v "true"))]
        [(and type (regexp-match? #rx"^[a-z]" type) (not (member type (cons "boolean" number-types)))) (as (value-key type) v)]
        [else (as 'valueString v)]))

(module+ test
  (require rackunit)
  ;; by the value's JSON type when no definition is known
  (check-equal? (parameter-of "x" 80) (hasheq 'name "x" 'valueInteger 80))
  (check-equal? (parameter-of "x" 80.5) (hasheq 'name "x" 'valueDecimal 80.5))
  (check-equal? (parameter-of "x" #t) (hasheq 'name "x" 'valueBoolean #t))
  (check-equal? (parameter-of "x" "female") (hasheq 'name "x" 'valueString "female"))
  (check-equal? (parameter-of "x" (hasheq 'resourceType "Patient")) (hasheq 'name "x" 'resource (hasheq 'resourceType "Patient")))
  ;; under the declared type's key when it is known; a shell's text read as the number it writes
  (check-equal? (parameter-of "sex" "female" "code") (hasheq 'name "sex" 'valueCode "female"))
  (check-equal? (parameter-of "on" "2024-03-01" "date") (hasheq 'name "on" 'valueDate "2024-03-01"))
  (check-equal? (parameter-of "note" "fasting" "string") (hasheq 'name "note" 'valueString "fasting"))
  (check-equal? (parameter-of "weight" "80" "decimal") (hasheq 'name "weight" 'valueDecimal 80))
  (check-equal? (parameter-of "weight" "80.5" "decimal") (hasheq 'name "weight" 'valueDecimal 80.5))
  (check-equal? (parameter-of "weight" 80 "decimal") (hasheq 'name "weight" 'valueDecimal 80))
  (check-equal? (parameter-of "age" "41" "integer") (hasheq 'name "age" 'valueInteger 41))
  (check-equal? (parameter-of "age" "old" "integer") (hasheq 'name "age" 'valueString "old"))   ; the server says what is wrong with it
  (check-equal? (parameter-of "age" "41.5" "integer") (hasheq 'name "age" 'valueString "41.5"))
  (check-equal? (parameter-of "fasting" "true" "boolean") (hasheq 'name "fasting" 'valueBoolean #t))
  (check-equal? (parameter-of "lactate" (hasheq 'value 2.1 'code "mmol/L") "Quantity")
                (hasheq 'name "lactate" 'valueQuantity (hasheq 'value 2.1 'code "mmol/L"))))
