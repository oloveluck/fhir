#lang racket/base

;;; apply.rkt — the verb apply: any operation (fhir/operation) applied by reference, here or on a
;;; FHIR server.

(require json (only-in net/url string->url post-pure-port) (only-in fhir/operation operation) "tools.rkt"
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
       (let* ([type (cadr m)] [id (caddr m)] [code (cadddr m)]
              [params (hasheq 'resourceType "Parameters"
                              'parameter (append
                                          (for*/list ([(k v) (in-hash inputs)] [x (in-list (if (list? v) v (list v)))])
                                            (parameter-of (symbol->string k) x))
                                          (if resource (list (hasheq 'name "resource" 'resource resource)) '())))])
         (for/or ([srv (in-list (running))])
           (define url (string-append (cdr srv) "/" (if type (string-append type "/") "") (if id (string-append id "/") "") "$" code))
           (define answer (with-handlers ([exn:fail? (lambda (_) #f)])
                            (define in (post-pure-port (string->url url) (string->bytes/utf-8 (jsexpr->string params))
                                                       '("Content-Type: application/fhir+json")))
                            (begin0 (read-json in) (close-input-port in))))
           (and (hash? answer)
                (not (and (equal? (hash-ref answer 'resourceType #f) "OperationOutcome")
                          (for/or ([i (in-list (hash-ref answer 'issue '()))]) (equal? (hash-ref i 'code #f) "not-supported"))))
                answer)))))

;; parameter-of : name jsexpr -> Parameters.parameter   by the value's JSON type
(define (parameter-of name v)
  (cond [(and (hash? v) (hash-ref v 'resourceType #f)) (hasheq 'name name 'resource v)]
        [(boolean? v) (hasheq 'name name 'valueBoolean v)]
        [(exact-integer? v) (hasheq 'name name 'valueInteger v)]
        [(real? v) (hasheq 'name name 'valueDecimal v)]
        [else (hasheq 'name name 'valueString (format "~a" v))]))
