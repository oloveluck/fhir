#lang racket/base

;;; store.rkt — a capability app's resources kept in a SQLite FHIR store (store/, resources as JSONB).
;;;
;;; A resource declared without `#:repository` gets the repository `current-repository-factory`
;;; makes (capability/runtime); `store-repository-factory` is one over a store: each resource type a
;;; store repository (versions, history, search over the store's indexes) offering exactly the
;;; interactions the declaration lists. Its search parameters are the catalogue given (by default the
;;; engine's own) with the declaration's: `[gender token]` uses the catalogue's definition of
;;; `gender`, `[risk token "extension('…').value"]` adds its own expression.
;;;
;;; Three ways to use it: `(server #:store "fhir.db")` in a `#lang fhir/capability` module (the
;;; file beside the module), `raco fhir-server serve app.rkt --store fhir.db`, and a workspace that
;;; serves the app over its own data.

(require racket/contract
         "runtime.rkt"
         (only-in "../store/fhir-sqlite.rkt" open-fhir-store fhir-store?)
         (only-in "../store/fhir-engine.rkt" search-param search-param-name default-search-params)
         (only-in "../store/serve.rkt" store-repository))

(provide
 (contract-out
  ;; store-repository-factory : store [#:search-params catalog] -> (type interactions sps -> repository)
  [store-repository-factory (->* (fhir-store?) (#:search-params hash?) procedure?)]
  ;; store-file-factory : path -> factory   the store in that file (opened once per path)
  [store-file-factory (-> path-string? procedure?)]
  ;; with-declared : catalog type sps -> catalog   the declaration's search parameters added
  [with-declared (-> hash? symbol? (listof list?) hash?)]))

(define (store-repository-factory store #:search-params [base default-search-params])
  (lambda (type interactions sps)
    (restrict (store-repository store type (with-declared base type sps)) interactions)))

(define opened (make-hash))
(define (store-file-factory p)
  (store-repository-factory (hash-ref! opened (simplify-path (path->complete-path p)) (lambda () (open-fhir-store p)))))

;; with-declared : catalog type (listof (list name kind expr|#f)) -> catalog
(define (with-declared catalog type sps)
  (define own (for/list ([sp (in-list sps)] #:when (caddr sp))
                (search-param (symbol->string (car sp)) (cadr sp) (caddr sp))))
  (define names (map search-param-name own))
  (hash-set catalog type
            (append own (filter (lambda (p) (not (member (search-param-name p) names))) (hash-ref catalog type '())))))

;; restrict : repository interactions -> repository   only what the declaration offers
(define (restrict r interactions)
  (define (has? . ks) (for/or ([k (in-list ks)]) (memq k interactions)))
  (make-repository #:read (and (has? 'read) (repository-read r))
                   #:vread (and (has? 'vread) (repository-vread r))
                   #:create (and (has? 'create) (repository-create r))
                   #:update (and (has? 'update) (repository-update r))
                   #:delete (and (has? 'delete) (repository-delete r))
                   #:search (and (has? 'search-type) (repository-search r))
                   #:history (and (has? 'history-instance 'history-type) (repository-history r))
                   #:patch (and (has? 'patch) (repository-patch r))))

(module+ test
  (require rackunit racket/file (only-in fhir/r6/types) (only-in fhir/serialize/from-json from-json)
           (only-in fhir/result/result ok-value) (only-in fhir/model/node fhir-ref))
  (define db (make-temporary-file "cap-store-~a.db"))
  (delete-file db)
  (define make (store-file-factory db))
  (define repo (make 'Patient '(read create search-type) (list (list 'gender 'token #f) (list 'family 'string "name.family"))))
  (check-false (repository-delete repo))                        ; not declared, not offered
  (define created ((repository-create repo) (ok-value (from-json (hasheq 'resourceType "Patient" 'gender "female" 'name (list (hasheq 'family "Ng")))))))
  (define id (fhir-ref created 'id))
  (check-true (and ((repository-read repo) (if (string? id) id (format "~a" id))) #t))
  ;; the declared expression and the catalogue's gender both search the store
  (check-equal? (length (let ([r ((repository-search repo) (list (cons 'family "ng")))]) (if (list? r) r (search-result-matches r)))) 1)
  (check-equal? (length (let ([r ((repository-search repo) (list (cons 'gender "male")))]) (if (list? r) r (search-result-matches r)))) 0)
  ;; stored as JSONB in the file
  (check-true (file-exists? db)))
