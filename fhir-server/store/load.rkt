#lang racket/base

;;; load.rkt — put files into a store: FHIR Bundles (transaction/batch/collection), single resources,
;;; and CQL libraries.
;;;
;;; A `.cql` file becomes a Library resource (cql/library's cql->library: id and name the CQL
;;; library's name, version from its header, the source as text/cql content, url <base>/Library/<name>),
;;; so a published Measure runs against locally loaded CQL.

(require racket/contract racket/file racket/list racket/string json
         (only-in cql/library cql->library)
         "fhir-sqlite.rkt" "fhir-engine.rkt" (only-in "bundle.rkt" load-bundle!))

(provide cql->library                                   ; cql/library's, re-exported for the CLI
         (contract-out
          [load-files!   (->* (fhir-store? path-string?) (#:search-params hash? #:library-base string? #:tower (or/c module-path? #f))
                              (listof (cons/c string? exact-nonnegative-integer?)))]
          ;; file-resources : path -> (listof (cons file-name resource))   every resource load-files!
          ;; would write from the JSON files, a Bundle's entries each on their own — what a caller
          ;; validates BEFORE loading (the load itself checks nothing)
          [file-resources (-> path-string? (listof (cons/c string? hash?)))]))

;; source-files : path -> (listof path)   a file, or every .json/.cql under a directory, by name
(define (source-files src)
  (if (directory-exists? src)
      (sort (for/list ([f (in-directory src)] #:when (regexp-match? #rx"[.](json|cql)$" (path->string f))) f)
            string<? #:key path->string)
      (list (if (path? src) src (string->path src)))))
(define (file-name f) (let-values ([(_b n _d) (split-path f)]) (path->string n)))
(define (file-json f) (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))

(define (file-resources src)
  (for*/list ([f (in-list (source-files src))]
              #:unless (regexp-match? #rx"[.]cql$" (file-name f))
              [js (in-value (file-json f))]
              #:when (and (hash? js) (hash-ref js 'resourceType #f))
              [r (in-list (if (equal? (hash-ref js 'resourceType) "Bundle")
                              (for*/list ([e (in-list (let ([es (hash-ref js 'entry '())]) (if (list? es) es '())))]
                                          #:when (hash? e)
                                          [r (in-value (hash-ref e 'resource #f))]
                                          #:when (and (hash? r) (hash-ref r 'resourceType #f)))
                                r)
                              (list js)))])
    (cons (file-name f) r)))

;; load-files! : store path -> (listof (cons file-name count))   a file, or every .json/.cql under a dir
(define (load-files! store src #:search-params [sps default-search-params] #:library-base [base "http://localhost/fhir"]
                     #:tower [tower #f])
  (for/list ([f (in-list (source-files src))])
    (define name (file-name f))
    (cond
      [(regexp-match? #rx"[.]cql$" name)
       (fhir-update! store (cql->library (file->string f) #:library-base base) #:search-params sps)
       (cons name 1)]
      [else
       (define js (file-json f))
       (cond [(not (and (hash? js) (hash-ref js 'resourceType #f))) (cons name 0)]
             [(equal? (hash-ref js 'resourceType) "Bundle")
              (define-values (n _resp) (load-bundle! store js #:search-params sps #:tower tower)) (cons name n)]
             [(hash-ref js 'id #f) (fhir-update! store js #:search-params sps) (cons name 1)]
             [else (fhir-create! store js #:search-params sps) (cons name 1)])])))
