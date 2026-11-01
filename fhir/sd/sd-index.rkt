#lang racket/base

;;; sd-index.rkt — resolve a base StructureDefinition (with its snapshot) from the R5 core package.
;;;
;;; Snapshot generation needs the parent's full snapshot; the vendored R5 core package carries one per
;;; StructureDefinition. We lazily stream the .tgz once and index every SD by url / name / id (mirrors
;;; the terminology service's loader). Consumed by sd/{snapshot,element-index}.rkt, the validator
;;; (fhir-tools) and the FSH snapshot mode; the differential-only FSH compile path does not touch this.
;;;
;;; The packages searched are `current-sd-packages` — a list, searched in order, so an IG's profiles
;;; resolve before the core package it builds on: (list us-core.tgz r4-core.tgz). The default is the
;;; R5 core package from the OPTIONAL `fhir-spec` package. Without any package the index is empty:
;;; resolve-sd-raw returns #f and snapshot generation degrades to differential-only.
;;; Consumers that cache derived data (element-index's type cache) key it by `sd-context`.

(require json
         file/gunzip
         file/untar
         racket/contract
         (only-in racket/list last)
         (only-in fhir/spec-package spec-package-path))

(provide (contract-out
          [resolve-sd-raw (-> string? (or/c hash? #f))]
          ;; the FHIR NPM packages (.tgz) to resolve from, in priority order; #f = fhir-spec's R5 core
          [current-sd-packages (parameter/c (or/c #f (listof path-string?)))]
          ;; the effective package list — a cache key for anything derived from the index
          [sd-context (-> (listof path?))]
          ;; can snapshots be generated at all (is a core package available)?
          [sd-index-available? (-> boolean?)]))

(define current-sd-packages (make-parameter #f))
(define (sd-context)
  (map (lambda (p) (simplify-path (path->complete-path p)))
       (or (current-sd-packages)
           (let ([core (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t)]) (if core (list core) '())))))
(define (sd-index-available?) (pair? (sd-context)))

(define sd-file-rx #px"^package/StructureDefinition-.*\\.json$")

;; one index per package, built on first use; a lookup searches the context's packages in order
(define indexes (make-hash))
(define (package-index tgz) (hash-ref! indexes tgz (lambda () (load-index tgz))))

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
  (define key (car (regexp-split #rx"[|]" name-or-url)))        ; drop a |version suffix
  (define tables (map package-index (sd-context)))
  (define (lookup k) (for/or ([t (in-list tables)]) (hash-ref t k #f)))
  ;; a bare type code ("Patient") means the core canonical, NOT whatever SD happens to share that
  ;; name or id (R4 core has an extension NAMED "FamilyMemberHistory")
  (or (and (not (regexp-match? #rx"/" key))
           (lookup (string-append "http://hl7.org/fhir/StructureDefinition/" key)))
      (lookup key)
      (and (regexp-match? #rx"/" key)
           (lookup (last (regexp-split #rx"/" key))))))

