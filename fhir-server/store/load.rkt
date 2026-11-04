#lang racket/base

;;; load.rkt — put files into a store: FHIR Bundles (transaction/batch/collection), single resources,
;;; and CQL libraries.
;;;
;;; A `.cql` file becomes a Library resource the way a measure repository holds one: id and name the
;;; CQL library's name, version from its header, `type` logic-library, the source as base64
;;; text/cql content, url <base>/Library/<name>. (Measure evaluation finds a Measure's library by url,
;;; or by the canonical's last segment = the library name, so a published Measure runs against
;;; locally loaded CQL.)

(require racket/contract racket/file racket/list racket/string json net/base64
         "fhir-sqlite.rkt" "fhir-engine.rkt" (only-in "bundle.rkt" load-bundle!))

(provide (contract-out
          [load-files!   (->* (fhir-store? path-string?) (#:search-params hash? #:library-base string? #:tower (or/c module-path? #f))
                              (listof (cons/c string? exact-nonnegative-integer?)))]
          [cql->library  (->* (string?) (#:library-base string?) hash?)]))

;; cql->library : cql-source -> Library jsexpr
(define (cql->library src #:library-base [base "http://localhost/fhir"])
  (define m (regexp-match #px"(?m:^\\s*library\\s+(\"[^\"]+\"|\\S+)(?:\\s+version\\s+'([^']+)')?)" src))
  (unless m (raise-user-error 'load "a CQL library needs a `library Name` header"))
  (define name (string-trim (cadr m) "\""))
  (define lib (hasheq 'resourceType "Library" 'id (regexp-replace* #px"[^A-Za-z0-9.-]" name "-") 'name name
                      'status "active" 'url (string-append base "/Library/" name)
                      'type (hasheq 'coding (list (hasheq 'system "http://terminology.hl7.org/CodeSystem/library-type"
                                                          'code "logic-library")))
                      'content (list (hasheq 'contentType "text/cql"
                                             'data (bytes->string/utf-8 (base64-encode (string->bytes/utf-8 src) #""))))))
  (if (caddr m) (hash-set lib 'version (caddr m)) lib))

;; load-files! : store path -> (listof (cons file-name count))   a file, or every .json/.cql under a dir
(define (load-files! store src #:search-params [sps default-search-params] #:library-base [base "http://localhost/fhir"]
                     #:tower [tower #f])
  (define files (if (directory-exists? src)
                    (sort (for/list ([f (in-directory src)] #:when (regexp-match? #rx"[.](json|cql)$" (path->string f))) f)
                          string<? #:key path->string)
                    (list (string->path src))))
  (for/list ([f (in-list files)])
    (define name (let-values ([(_b n _d) (split-path f)]) (path->string n)))
    (cond
      [(regexp-match? #rx"[.]cql$" name)
       (fhir-update! store (cql->library (file->string f) #:library-base base) #:search-params sps)
       (cons name 1)]
      [else
       (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))
       (cond [(not (and (hash? js) (hash-ref js 'resourceType #f))) (cons name 0)]
             [(equal? (hash-ref js 'resourceType) "Bundle")
              (define-values (n _resp) (load-bundle! store js #:search-params sps #:tower tower)) (cons name n)]
             [(hash-ref js 'id #f) (fhir-update! store js #:search-params sps) (cons name 1)]
             [else (fhir-create! store js #:search-params sps) (cons name 1)])])))
