#lang racket/base

;;; load-spec.rkt — read a vendored FHIR package (.tgz) in memory and yield its contents.
;;;
;;; A FHIR NPM package is a gzip'd tar whose `package/` directory holds one conformance resource
;;; per file plus `package/package.json`. We stream gunzip → untar (no disk extraction): a thread
;;; inflates the .tgz into a bounded pipe, and `untar`'s #:handle-entry reads each file's bytes.
;;; What is kept (everything else is skipped cheaply by prefix):
;;;   StructureDefinition-*.json     -> structure-definitions (the type source)
;;;   OperationDefinition-*.json     -> raw jsexpr (generated operation scaffolding)
;;;   ValueSet-*.json / CodeSystem-*.json -> raw jsexpr (offline binding expansions)
;;;   example/*.json                 -> (cons filename jsexpr) (the every-example-parses guarantee)

(require json
         file/gunzip
         file/untar
         racket/contract
         racket/list
         "structure-definition.rkt")

(provide
 (struct-out package-contents)
 (contract-out
  ;; package tgz -> its contents; ODs sorted by (code, id), VS/CS by url, examples by filename —
  ;; every collection deterministic so generation can byte-diff
  [load-package (-> path-string? package-contents?)]))

;; A PackageContents gathers what the generator and harnesses read from one package.
(struct package-contents (sds operations valuesets codesystems examples version) #:transparent)

(define sd-file-rx #px"^package/StructureDefinition-.*\\.json$")
(define od-file-rx #px"^package/OperationDefinition-.*\\.json$")
(define vs-file-rx #px"^package/ValueSet-.*\\.json$")
(define cs-file-rx #px"^package/CodeSystem-.*\\.json$")
(define ex-file-rx #px"^package/example/[^.][^/]*\\.json$")   ; skip .index.json etc.

(define (load-package tgz-path)
  (define sds '()) (define ods '()) (define vss '()) (define css '()) (define exs '())
  (define version #f)
  (define-values (pin pout) (make-pipe (* 1024 1024)))   ; 1 MB bounded -> streaming
  (define inflate
    (thread
     (lambda ()
       (call-with-input-file tgz-path (lambda (gz) (gunzip-through-ports gz pout)))
       (close-output-port pout))))
  (untar pin
         #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define bytes (if (= size 0) #"" (read-bytes size content)))  ; always consume `size`
             (define s (path->string name))
             (cond
               [(regexp-match? sd-file-rx s)
                (set! sds (cons (jsexpr->structure-definition (bytes->jsexpr bytes)) sds))]
               [(regexp-match? od-file-rx s) (set! ods (cons (bytes->jsexpr bytes) ods))]
               [(regexp-match? vs-file-rx s) (set! vss (cons (bytes->jsexpr bytes) vss))]
               [(regexp-match? cs-file-rx s) (set! css (cons (bytes->jsexpr bytes) css))]
               [(regexp-match? ex-file-rx s) (set! exs (cons (cons s (bytes->jsexpr bytes)) exs))]
               [(string=? s "package/package.json")
                (let ([pkg (bytes->jsexpr bytes)])
                  (set! version (and (hash? pkg) (hash-ref pkg 'version #f))))]))
           '()))
  (thread-wait inflate)
  (define (by-url l) (sort l string<? #:key (lambda (r) (hash-ref r 'url ""))))
  (package-contents
   (reverse sds)
   (sort ods string<? #:key (lambda (od) (format "~a/~a" (hash-ref od 'code "") (hash-ref od 'id ""))))
   (by-url vss)
   (by-url css)
   (sort exs string<? #:key car)
   version))
