#lang racket/base

;;; search-index.rkt — FHIR search over data that is files. A directory of FHIR JSON has no search
;;; engine of its own, so the first search builds one: the resources go into a fhir-server store (a
;;; SQLite file in the temporary directory) as one transaction of PUTs, which keeps every id, so the
;;; references between them still hold; the search parameters are the packages' own (the core
;;; package's SearchParameters, then the workspace's IGs'). A search answers the ORIGINAL resources
;;; (the store stamps meta), read back by type and id from the data.
;;;
;;; fhir-server is loaded on demand (fhir-mcp does not depend on it); without it there is no index and
;;; the caller says so.

(require racket/contract racket/list racket/file
         (only-in fhir/data-source bundle-resources))

(provide
 (contract-out
  ;; build-search-index : resources packages tower -> Index
  ;;   resources: every resource of the data (Bundles' entries included); packages: the .tgz files
  ;;   whose SearchParameters apply, core first; tower: the module that registers the FHIR version
  [build-search-index (-> (listof hash?) (listof path-string?) module-path? search-index?)]
  ;; an Index: `search`: type params -> (values resources ignored total) — a page of the matches
  ;; (`_count`, `_offset`), the parameters it could not apply, and how many match in all; `store`:
  ;; the fhir-server store the data was indexed into (a census reads it)
  [struct search-index ([search (-> string? (listof (cons/c string? string?))
                                    (values (listof hash?) (listof string?) exact-nonnegative-integer?))]
                        [store any/c])]
  ;; search-param-names : catalog type -> (listof string)   the parameters a type searches on
  [search-param-names (-> hash? string? (listof string?))]
  ;; search-index-available? : -> boolean   is fhir-server installed?
  [search-index-available? (-> boolean?)]
  ;; search-catalog : packages -> catalog   the packages' SearchParameters (core first), memoised
  [search-catalog (-> (listof path-string?) hash?)]))

(define (search-index-available?)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (and (dynamic-require 'fhir/store/fhir-sqlite 'open-fhir-store) #t)))

;; from : module symbol -> value   one binding of fhir-server, loaded on demand
(define (from m name) (dynamic-require m name))

;; catalog : (listof package) -> SearchParamCatalog   memoised per package list (reading a core
;; package's ~1,400 SearchParameters takes a moment)
(define catalogs (make-hash))
(define (search-catalog packages) (catalog packages))
(define (catalog packages)
  (hash-ref! catalogs packages
             (lambda ()
               (define from-package (from 'fhir/store/ig-params 'search-params-from-package))
               (define merge (from 'fhir/store/ig-params 'merge-search-params))
               (for/fold ([c (from 'fhir/store/fhir-engine 'default-search-params)])
                         ([p (in-list packages)])
                 (merge c (with-handlers ([exn:fail? (lambda (_) (hash))]) (from-package p)))))))

(struct search-index (search store))

(define (build-search-index resources packages tower)
  (define sps (catalog packages))
  (define db (make-temporary-file "fhir-mcp-search-~a.db"))
  (delete-file db)                                     ; the store creates it, with its schema
  (define store ((from 'fhir/store/fhir-sqlite 'open-fhir-store) db))
  (define all (remove-duplicates (append-map bundle-resources resources)
                                 (lambda (a b) (and (hash-ref a 'id #f) (equal? (key a) (key b))))))
  (define keyed (filter (lambda (r) (and (string? (hash-ref r 'resourceType #f)) (string? (hash-ref r 'id #f)))) all))
  ((from 'fhir/store/bundle 'load-bundle!)
   store
   (hasheq 'resourceType "Bundle" 'type "transaction"
           'entry (for/list ([r (in-list keyed)])
                    (hasheq 'resource r
                            'request (hasheq 'method "PUT" 'url (format "~a/~a" (hash-ref r 'resourceType) (hash-ref r 'id))))))
   #:search-params sps #:tower tower)
  (define originals (for/hash ([r (in-list keyed)]) (values (key r) r)))
  (define search (from 'fhir/store/fhir-engine 'fhir-search/page))
  (search-index
   (lambda (type params)
     (define-values (rs ignored total) (search store type params #:search-params sps))
     (values (for/list ([r (in-list rs)]) (hash-ref originals (key r) r)) ignored total))
   store))

;; search-param-names : catalog type -> (listof string)   the parameters a type searches on
(define (search-param-names sps type)
  (define name (from 'fhir/store/fhir-engine 'search-param-name))
  (sort (remove-duplicates (map name (hash-ref sps (string->symbol type) '()))) string<?))

(define (key r) (cons (hash-ref r 'resourceType #f) (hash-ref r 'id #f)))

(module+ test
  (require rackunit (only-in fhir/r4/schemas) fhir/spec-package)
  (define core (spec-package-path "hl7.fhir.r4.core.tgz" #:optional? #t))
  (when (and core (search-index-available?))
    (define (obs id pid code value)
      (hasheq 'resourceType "Observation" 'id id 'status "final" 'subject (hasheq 'reference (string-append "Patient/" pid))
              'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code code)))
              'effectiveDateTime "2025-03-01"
              'valueQuantity (hasheq 'value value 'unit "%" 'system "http://unitsofmeasure.org" 'code "%")))
    (define data (list (hasheq 'resourceType "Patient" 'id "ann" 'gender "female" 'birthDate "1960-01-01" 'name (list (hasheq 'family "Ng")))
                       (hasheq 'resourceType "Patient" 'id "bob" 'gender "male" 'birthDate "1990-01-01")
                       (hasheq 'resourceType "Bundle" 'type "collection"
                               'entry (list (hasheq 'resource (obs "a1" "ann" "4548-4" 6.2))
                                            (hasheq 'resource (obs "a2" "bob" "4548-4" 9.1))
                                            (hasheq 'resource (obs "g1" "bob" "2339-0" 100))))))
    (define search (search-index-search (build-search-index data (list core) 'fhir/r4/schemas)))
    (define (found type params) (let-values ([(rs _i _t) (search type params)]) rs))
    (define (ids type params) (sort (map (lambda (r) (hash-ref r 'id)) (found type params)) string<?))
    ;; what it could not apply is said, not silently dropped (`_has` answered every patient)
    (let-values ([(rs ignored total) (search "Patient" '(("_has:Observation:subject:code" . "4548-4") ("gender" . "male")))])
      (check-equal? ignored '("_has:Observation:subject:code"))
      (check-equal? total 1)
      (check-equal? (map (lambda (r) (hash-ref r 'id)) rs) '("bob")))
    (check-not-false (member "birthdate" (search-param-names (search-catalog (list core)) "Patient")))
    ;; tokens, references, dates and quantities, by the core package's own SearchParameters
    (check-equal? (ids "Observation" '(("code" . "http://loinc.org|4548-4"))) '("a1" "a2"))
    (check-equal? (ids "Observation" '(("subject" . "Patient/bob") ("code" . "2339-0"))) '("g1"))
    (check-equal? (ids "Observation" '(("patient" . "Patient/ann"))) '("a1"))
    (check-equal? (ids "Observation" '(("value-quantity" . "gt8"))) '("a2" "g1"))
    (check-equal? (ids "Patient" '(("birthdate" . "lt1980-01-01"))) '("ann"))
    (check-equal? (ids "Patient" '(("family" . "ng"))) '("ann"))
    ;; a page, and how many match in all; by what a code is called
    (let-values ([(rs _i total) (search "Observation" '(("_count" . "1")))])
      (check-equal? (list (length rs) total) '(1 3)))
    ;; the original resources, not the store's stamped copies
    (check-false (hash-ref (car (found "Patient" '(("gender" . "male")))) 'meta #f))))
