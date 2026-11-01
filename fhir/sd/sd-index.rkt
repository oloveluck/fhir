#lang racket/base

;;; sd-index.rkt — resolve a base StructureDefinition (with its snapshot) from the R5 core package.
;;;
;;; Snapshot generation needs the parent's full snapshot; the vendored R5 core package carries one per
;;; StructureDefinition. We lazily stream the .tgz once and index every SD by url / name / id (mirrors
;;; the terminology service's loader). Consumed by sd/{snapshot,element-index}.rkt, the validator
;;; (fhir-tools) and the FSH snapshot mode; the differential-only FSH compile path does not touch this.
;;;
;;; The package comes from the OPTIONAL `fhir-spec` package (or `current-sd-package`). Without it the
;;; index is empty: resolve-sd-raw returns #f and snapshot generation degrades to differential-only.

(require json
         file/gunzip
         file/untar
         racket/contract
         (only-in racket/list last)
         (only-in fhir/spec-package spec-package-path))

(provide (contract-out
          [resolve-sd-raw (-> string? (or/c hash? #f))]
          ;; override the core package to index (a path to a FHIR NPM .tgz); #f = fhir-spec's R5 core
          [current-sd-package (parameter/c (or/c path-string? #f))]
          ;; can snapshots be generated at all (is a core package available)?
          [sd-index-available? (-> boolean?)]))

(define current-sd-package (make-parameter #f))
(define (sd-package) (or (current-sd-package) (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t)))
(define (sd-index-available?) (and (sd-package) #t))

(define sd-file-rx #px"^package/StructureDefinition-.*\\.json$")

;; one index per package path, built on first use
(define indexes (make-hash))
(define (index)
  (define tgz (sd-package))
  (if tgz (hash-ref! indexes tgz (lambda () (load-index tgz))) (hash)))

(define (load-index r5-core-tgz)
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
    table)

(define (resolve-sd-raw name-or-url)
  (define t (index))
  (or (hash-ref t name-or-url #f)
      (and (regexp-match? #rx"/" name-or-url)
           (hash-ref t (last (regexp-split #rx"/" name-or-url)) #f))))

