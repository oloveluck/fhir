#lang racket/base

;;; sd-index.rkt — resolve a base StructureDefinition (with its snapshot) from the R5 core package.
;;;
;;; Snapshot generation needs the parent's full snapshot; the vendored R5 core package carries one per
;;; StructureDefinition. We lazily stream the .tgz once and index every SD by url / name / id (mirrors
;;; terminology/service.rkt's loader). Consumed by conformance/{snapshot,element-index,validate}.rkt
;;; (and the FSH snapshot mode); the differential-only FSH compile path does not touch this.

(require json
         file/gunzip
         file/untar
         racket/promise
         racket/runtime-path
         racket/contract)

(provide (contract-out [resolve-sd-raw (-> string? (or/c hash? #f))]))

(define-runtime-path r5-core-tgz "../spec/hl7.fhir.r5.core.tgz")
(define sd-file-rx #px"^package/StructureDefinition-.*\\.json$")

(define index
  (delay
    (define table (make-hash))
    (define-values (pin pout) (make-pipe (* 1024 1024)))
    (define inflate
      (thread (lambda () (call-with-input-file r5-core-tgz (lambda (gz) (gunzip-through-ports gz pout)))
                     (close-output-port pout))))
    (untar pin
           #:handle-entry
           (lambda (kind name content size attribs)
             (when (eq? kind 'file)
               (define bytes (if (= size 0) #"" (read-bytes size content)))
               (when (regexp-match? sd-file-rx (path->string name))
                 (define js (bytes->jsexpr bytes))
                 (when (hash? js)
                   (for ([k (in-list (list (hash-ref js 'url #f) (hash-ref js 'name #f) (hash-ref js 'id #f)))]
                         #:when (string? k))
                     (hash-set! table k js)))))
             '()))
    (thread-wait inflate)
    table))

(define (resolve-sd-raw name-or-url)
  (define t (force index))
  (or (hash-ref t name-or-url #f)
      (and (regexp-match? #rx"/" name-or-url)
           (hash-ref t (last (regexp-split #rx"/" name-or-url)) #f))))

(require (only-in racket/list last))
