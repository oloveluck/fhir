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
         racket/string racket/list (only-in racket/file make-temporary-file))

(provide
 (contract-out
  ;; store-repository-factory : store [#:search-params catalog] -> (type interactions sps -> repository)
  [store-repository-factory (->* (fhir-store?) (#:search-params hash? #:validate? boolean?) procedure?)]
  ;; store-file-factory : path -> factory   the store in that file (opened once per path)
  [store-file-factory (-> path-string? procedure?)]
  ;; temporary-store-factory : -> factory   a store in a temporary file, removed when the process ends
  [temporary-store-factory (-> procedure?)]
  ;; with-declared : catalog type sps -> catalog   the declaration's search parameters added
  [with-declared (-> hash? symbol? (listof list?) hash?)]
  ;; core-search-params : -> catalog   the core package's SearchParameters over the engine's own
  [core-search-params (-> hash?)]
  ;; opened-store-files : -> (listof path)   the store files this process has opened for apps
  [opened-store-files (-> (listof path?))]))
(define (opened-store-files) (sort (hash-keys opened) path<?))

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
    (restrict (declared-search (if validate? (validated-writes repo) repo) (map (lambda (sp) (symbol->string (car sp))) sps))
              interactions)))

;; declared-search : repository (listof name) -> repository
;; The server searches with what /metadata advertises: a parameter the declaration does not name
;; (`name` on an app declaring `gender`) is left out and reported in the searchset, as one the store
;; cannot apply is. The store still INDEXES with the whole catalogue, so the workspace's own search
;; over the same store loses nothing to the app's writes. `_id`, `_lastUpdated`, `_count`, `_sort`
;; and the other `_` parameters are FHIR's for every type.
(define (declared-search r names)
  (define search (repository-search r))
  (define (declared? p)
    (define n (symbol->string (car p)))
    (or (string-prefix? n "_") (member (car (string-split n #rx"[:.]")) names)))
  (if (not search)
      r
      (struct-copy repository r
                   [search (lambda (params)
                             (define-values (kept dropped) (partition declared? params))
                             (define result (search kept))
                             (define dropped-names (remove-duplicates (map (lambda (p) (symbol->string (car p))) dropped)))
                             (cond [(null? dropped-names) result]
                                   [(search-result/ignored? result)
                                    (search-result/ignored (search-result-matches result) (search-result-includes result)
                                                           (remove-duplicates (append dropped-names (search-result/ignored-names result))))]
                                   [(search-result? result)
                                    (search-result/ignored (search-result-matches result) (search-result-includes result) dropped-names)]
                                   [else (search-result/ignored result '() dropped-names)]))])))

;; temporary-store-factory : -> factory
;; An app with no store anywhere keeps its resources in a temporary SQLite file (one per process,
;; removed at exit): the same search, versions and validation as a stored app, nothing kept. The
;; in-memory repository it replaces matched parameters by string equality, so `birthdate=lt1980`,
;; `patient=Patient/x` or a parameter declared without an expression matched every resource.
(define temporary #f)
(define (temporary-store-factory)
  (unless temporary
    (define f (make-temporary-file "fhir-app-~a.db"))
    (delete-file f)
    (define (remove!) (for ([x (list f (path-add-extension f #"-wal") (path-add-extension f #"-shm"))])
                        (with-handlers ([exn:fail? void]) (when (file-exists? x) (delete-file x)))))
    ;; the default plumber is flushed as the process ends (as capability/workspace stops its servers)
    (void (plumber-add-flush! (current-plumber) (lambda (_) (remove!))))
    (set! temporary (store-repository-factory (open-fhir-store f))))
  temporary)

(define opened (make-hash))
(define (store-file-factory p)
  (store-repository-factory (hash-ref! opened (simplify-path (path->complete-path p)) (lambda () (open-fhir-store p)))))

;; with-declared : catalog type (listof (list name kind expr|#f)) -> catalog
(define (with-declared catalog type sps)
  (define known (hash-ref catalog type '()))
  ;; every problem of the declaration at once, each a line (the module says them at its form)
  (define problems
    (for*/list ([sp (in-list sps)] #:unless (caddr sp)
                [name (in-value (symbol->string (car sp)))]
                [def (in-value (findf (lambda (p) (equal? (search-param-name p) name)) known))]
                #:unless (and def (eq? (search-param-kind def) (cadr sp))))
      (if (not def)
          (format "search parameter `~a`: FHIR defines none of that name for ~a~a; give its FHIRPath: [~a ~a \"…\"]"
                  name type (did-you-mean name (map search-param-name known)) name (cadr sp))
          (format "search parameter `~a` is a ~a in FHIR, not a ~a" name (search-param-kind def) (cadr sp)))))
  (unless (null? problems)
    (raise (exn:fail:declaration (string-join problems "; ") (current-continuation-marks) type)))
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
  ;; FHIR defines `name` for Patient, but this app does not declare it: /metadata does not advertise
  ;; it, so the search ignores it and says so (a new user's app answered it unadvertised)
  (define r2 ((repository-search repo) (list (cons 'name "zzz") (cons 'gender "female"))))
  (check-equal? (search-result/ignored-names r2) '("name"))
  (check-equal? (length (search-result-matches r2)) 1)
  (check-equal? (length (let ([r ((repository-search repo) (list (cons 'family:exact "Ng") (cons '_id id)))]) (if (list? r) r (search-result-matches r)))) 1)
  ;; stored as JSONB in the file
  (check-true (file-exists? db)))
