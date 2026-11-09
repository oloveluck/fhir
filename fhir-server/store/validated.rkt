#lang racket/base

;;; validated.rkt — writes held to FHIR before they are stored. A create or update is validated (its
;;; base type and the profiles it claims) on the JSON AS SENT when the request carries it
;;; (`current-request-json`): the typed node is parsed leniently, so a misspelt element or a value it
;;; could not read is already gone from it, and storing the node would lose it without a word. Any
;;; error-level issue refuses the write with an OperationOutcome whose first issue is `processing`
;;; (HTTP 422), every issue after it at its element.

(require racket/contract racket/list racket/string
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/read-json strip-jnum)
         (only-in fhir/result/result ok-or-raise)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/conformance/validate validate-issues issue-severity issue-code issue-msg issue-path)
         (only-in "../capability/runtime.rkt" make-repository repository-read repository-vread repository-create
                  repository-update repository-delete repository-search repository-history repository-patch
                  current-request-json))

(provide
 (contract-out
  ;; validated-writes : repository [#:sd-packages pkgs] -> repository   create, update and patch checked
  [validated-writes (->* (any/c) (#:sd-packages (or/c #f (listof path-string?))) any/c)]
  ;; write-json-of : node -> jsexpr   the request's JSON when it is this resource, else the node's
  [write-json-of (-> any/c hash?)]
  ;; write-errors : jsexpr [pkgs] -> (listof issue)   its error-level issues
  [write-errors (->* (hash?) ((or/c #f (listof path-string?))) list?)]
  ;; validation-outcome : jsexpr issues -> OperationOutcome node
  [validation-outcome (-> hash? list? any/c)]))

(define (write-json-of node)
  (define js (strip-jnum (node->jsexpr node)))
  (define raw (current-request-json))
  (if (and (hash? raw) (equal? (hash-ref raw 'resourceType #f) (hash-ref js 'resourceType #f)))
      (strip-jnum raw)
      js))

(define (write-errors js [pkgs #f])
  (define (go) (filter (lambda (i) (member (issue-severity i) '("error" "fatal"))) (validate-issues js)))
  (if pkgs (parameterize ([current-sd-packages pkgs]) (go)) (go)))

(define (validation-outcome js issues)
  (define claimed (let ([m (hash-ref js 'meta #f)]) (if (hash? m) (hash-ref m 'profile '()) '())))
  (ok-or-raise
   (from-json
    (hasheq 'resourceType "OperationOutcome"
            'issue (cons (hasheq 'severity "error" 'code "processing"
                                 'diagnostics (format "~a does not conform to ~a: nothing was written"
                                                      (hash-ref js 'resourceType "resource")
                                                      (if (null? claimed) "its base type" (string-join claimed ", "))))
                         (for/list ([i (in-list issues)])
                           (hasheq 'severity (issue-severity i) 'code (issue-code i)
                                   'diagnostics (issue-msg i)
                                   'expression (list (or (issue-path i) ""))))))
    #:lenient? #t)))

(define (validated-writes repo #:sd-packages [pkgs #f])
  (define (checked write)
    (and write
         (lambda args
           (define js (write-json-of (last args)))
           (define errors (write-errors js pkgs))
           (if (null? errors) (apply write args) (validation-outcome js errors)))))
  (make-repository #:read (repository-read repo) #:vread (repository-vread repo)
                   #:create (checked (repository-create repo))
                   #:update (checked (repository-update repo))
                   #:delete (repository-delete repo) #:search (repository-search repo)
                   #:history (repository-history repo)
                   #:patch (let ([p (repository-patch repo)]) (and p (cons (car p) (checked (cdr p)))))))
