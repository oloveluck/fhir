#lang racket/base

;;; store.rkt — a capability app's resources kept in a SQLite FHIR store (store/, resources as JSONB).
;;;
;;; A resource declared without `#:repository` gets the repository `current-repository-factory`
;;; makes (capability/runtime); `store-repository-factory` is one over a store: each resource type a
;;; store repository (versions, history, search over the store's indexes) offering exactly the
;;; interactions the declaration lists. Its search parameters are the catalogue given (by default every
;;; SearchParameter of the FHIR core package — R6, the language's version) with the declaration's:
;;; `[birthdate date]` uses FHIR's definition of `birthdate`, `[risk token "extension('…').value"]`
;;; adds its own expression. A `[name type]` FHIR does not define for the type (or defines with
;;; another type) is an error when the app is built: searching on it would match nothing it could
;;; index, and answer every resource.
;;;
;;; Three ways to use it: `(server #:store "fhir.db")` in a `#lang fhir/capability` module (the
;;; file beside the module), `raco fhir-server serve app.rkt --store fhir.db`, and a workspace that
;;; serves the app over its own data.

(require racket/contract
         "runtime.rkt"
         (only-in "../store/fhir-sqlite.rkt" open-fhir-store fhir-store?)
         (only-in "../store/fhir-engine.rkt" search-param search-param-name search-param-kind default-search-params)
         (only-in "../store/ig-params.rkt" search-params-from-package merge-search-params)
         (only-in "../store/serve.rkt" store-repository)
         (only-in "../store/validated.rkt" validated-writes)
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/suggest did-you-mean)
         racket/string racket/list)

(provide
 (contract-out
  ;; store-repository-factory : store [#:search-params catalog] -> (type interactions sps -> repository)
  [store-repository-factory (->* (fhir-store?) (#:search-params hash? #:validate? boolean?) procedure?)]
  ;; store-file-factory : path -> factory   the store in that file (opened once per path)
  [store-file-factory (-> path-string? procedure?)]
  ;; with-declared : catalog type sps -> catalog   the declaration's search parameters added
  [with-declared (-> hash? symbol? (listof list?) hash?)]
  ;; core-search-params : -> catalog   the core package's SearchParameters over the engine's own
  [core-search-params (-> hash?)]))

;; core-search-params : -> catalog   read once per process
(define core-catalog #f)
(define (core-search-params)
  (unless core-catalog
    (define pkg (or (spec-package-path "hl7.fhir.r6.core.tgz" #:optional? #t)
                    (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t)))
    (set! core-catalog (if pkg (merge-search-params default-search-params (search-params-from-package pkg)) default-search-params)))
  core-catalog)

(define (store-repository-factory store #:search-params [base (core-search-params)] #:validate? [validate? #t])
  (lambda (type interactions sps)
    (define repo (store-repository store type (with-declared base type sps)))
    ;; what is stored is valid FHIR: a create or update that breaks its base type or a profile it
    ;; claims is refused (422) rather than stored with whatever the lenient parse dropped
    (restrict (if validate? (validated-writes repo) repo) interactions)))

(define opened (make-hash))
(define (store-file-factory p)
  (store-repository-factory (hash-ref! opened (simplify-path (path->complete-path p)) (lambda () (open-fhir-store p)))))

;; with-declared : catalog type (listof (list name kind expr|#f)) -> catalog
(define (with-declared catalog type sps)
  (define known (hash-ref catalog type '()))
  (for ([sp (in-list sps)] #:unless (caddr sp))
    (define name (symbol->string (car sp)))
    (define def (findf (lambda (p) (equal? (search-param-name p) name)) known))
    (cond
      [(not def)
       (error 'capability (format "search parameter `~a` of ~a: FHIR defines none of that name for ~a~a; give its FHIRPath: [~a ~a \"…\"]"
                                  name type type (did-you-mean name (map search-param-name known)) name (cadr sp)))]
      [(not (eq? (search-param-kind def) (cadr sp)))
       (error 'capability (format "search parameter `~a` of ~a is a ~a in FHIR, not a ~a" name type (search-param-kind def) (cadr sp)))]))
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
  (define repo (make 'Patient '(read create search-type) (list (list 'gender 'token #f) (list 'birthdate 'date #f) (list 'family 'string "name.family"))))
  ;; FHIR's own definitions: birthdate is searchable with no expression of ours
  (check-exn #rx"FHIR defines none of that name for Patient [(]did you mean `birthdate`[?][)]"
             (lambda () (make 'Patient '(search-type) (list (list 'birthdat 'date #f)))))
  (check-exn #rx"is a token in FHIR, not a string" (lambda () (make 'Patient '(search-type) (list (list 'gender 'string #f)))))
  (check-false (repository-delete repo))                        ; not declared, not offered
  (define created ((repository-create repo) (ok-value (from-json (hasheq 'resourceType "Patient" 'gender "female" 'birthDate "1965-04-02" 'name (list (hasheq 'family "Ng")))))))
  (define id (fhir-ref created 'id))
  (check-true (and ((repository-read repo) (if (string? id) id (format "~a" id))) #t))
  ;; the declared expression and the catalogue's gender both search the store
  (check-equal? (length (let ([r ((repository-search repo) (list (cons 'family "ng")))]) (if (list? r) r (search-result-matches r)))) 1)
  (check-equal? (length (let ([r ((repository-search repo) (list (cons 'gender "male")))]) (if (list? r) r (search-result-matches r)))) 0)
  (check-equal? (length (let ([r ((repository-search repo) (list (cons 'birthdate "lt1900")))]) (if (list? r) r (search-result-matches r)))) 0)
  (check-equal? (length (let ([r ((repository-search repo) (list (cons 'birthdate "lt1970")))]) (if (list? r) r (search-result-matches r)))) 1)
  ;; a parameter it cannot search is reported, not silently matched
  (define r ((repository-search repo) (list (cons 'foo "bar"))))
  (check-equal? (search-result/ignored-names r) '("foo"))
  ;; stored as JSONB in the file
  (check-true (file-exists? db)))
