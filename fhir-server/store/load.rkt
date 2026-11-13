#lang racket/base

;;; load.rkt — put files into a store: FHIR Bundles (transaction/batch/collection), single resources,
;;; bulk data (one resource to a line: .ndjson, .ndjson.gz) and CQL libraries.
;;;
;;; A `.cql` file becomes a Library resource (cql/library's cql->library: id and name the CQL
;;; library's name, version from its header, the source as text/cql content, url <base>/Library/<name>),
;;; so a published Measure runs against locally loaded CQL.

(require racket/contract racket/file racket/list racket/string racket/port json
         (only-in file/gunzip gunzip-through-ports)
         (only-in cql/library cql->library)
         "fhir-sqlite.rkt" "fhir-engine.rkt" (only-in "bundle.rkt" load-bundle! process-bundle!))

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
      (sort (for/list ([f (in-directory src)] #:when (regexp-match? #rx"[.](json|cql|ndjson|ndjson[.]gz)$" (path->string f))) f)
            string<? #:key path->string)
      (list (if (path? src) src (string->path src)))))
(define (file-name f) (let-values ([(_b n _d) (split-path f)]) (path->string n)))
(define (file-json f) (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))

;; ---- bulk data ----------------------------------------------------------------------------------
;; FHIR's bulk format is NDJSON (https://hl7.org/fhir/uv/bulkdata/export.html#file-format): one
;; resource to a line, a file to a type, often gzipped. Such a file can hold hundreds of thousands
;; of resources, so it is never read whole: its lines are taken a batch at a time, and each batch
;; is one transaction of PUTs (the ids are kept: the files refer to one another by them).
(define (ndjson? name) (regexp-match? #rx"[.]ndjson([.]gz)?$" name))
(define batch-size 2000)

;; call-with-ndjson-lines : path (input-port -> a) -> a   the file's text, gunzipped when it is .gz
(define (call-with-ndjson-lines f proc)
  (cond
    [(regexp-match? #rx"[.]gz$" (path->string f))
     (call-with-input-file f
       (lambda (in)
         (define-values (text-in text-out) (make-pipe (* 4 1024 1024)))
         (define pump (thread (lambda () (gunzip-through-ports in text-out) (close-output-port text-out))))
         (begin0 (proc text-in) (kill-thread pump))))]
    [else (call-with-input-file f proc)]))

;; next-batch : input-port n -> (listof resource)   up to n resources, a line each (a line that is
;; not a FHIR resource is passed over); '() at the end of the file
(define (next-batch in n)
  (let loop ([acc '()] [k 0])
    (define line (if (= k n) eof (read-line in 'any)))
    (cond
      [(eof-object? line) (reverse acc)]
      [else
       (define js (and (regexp-match? #rx"^[ \t]*{" line)
                       (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr line))))
       (if (and (hash? js) (string? (hash-ref js 'resourceType #f)))
           (loop (cons js acc) (add1 k))
           (loop acc k))])))

;; load-ndjson! : store path catalog tower -> count   every resource of the file, a batch a transaction
(define (load-ndjson! store f sps tower)
  (call-with-ndjson-lines f
    (lambda (in)
      (let loop ([total 0])
        (define batch (next-batch in batch-size))
        (cond
          [(null? batch) total]
          [else
           (process-bundle! store (puts-bundle batch) #:search-params sps #:tower tower)
           (loop (+ total (length batch)))])))))

;; puts-bundle : (listof resource) -> transaction Bundle   each resource written under its own id
;; (PUT Type/id), one without an id created (POST Type)
(define (puts-bundle resources)
  (hasheq 'resourceType "Bundle" 'type "transaction"
          'entry (for/list ([r (in-list resources)])
                   (define type (hash-ref r 'resourceType))
                   (define id (hash-ref r 'id #f))
                   (hasheq 'resource r
                           'request (if (string? id)
                                        (hasheq 'method "PUT" 'url (format "~a/~a" type id))
                                        (hasheq 'method "POST" 'url type))))))

;; ndjson-resources : path -> (listof resource)   the whole file (what a validation pass reads)
(define (ndjson-resources f)
  (call-with-ndjson-lines f
    (lambda (in) (let loop ([acc '()]) (define b (next-batch in batch-size)) (if (null? b) (append* (reverse acc)) (loop (cons b acc)))))))

(define (file-resources src)
  (for*/list ([f (in-list (source-files src))]
              #:unless (regexp-match? #rx"[.]cql$" (file-name f))
              [js (in-list (if (ndjson? (file-name f)) (ndjson-resources f) (list (file-json f))))]
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
      [(ndjson? name) (cons name (load-ndjson! store f sps tower))]
      [else
       (define js (file-json f))
       (cond [(not (and (hash? js) (hash-ref js 'resourceType #f))) (cons name 0)]
             [(equal? (hash-ref js 'resourceType) "Bundle")
              (define-values (n _resp) (load-bundle! store js #:search-params sps #:tower tower)) (cons name n)]
             [(hash-ref js 'id #f) (fhir-update! store js #:search-params sps) (cons name 1)]
             [else (fhir-create! store js #:search-params sps) (cons name 1)])])))
