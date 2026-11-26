#lang racket/base

;;; sd-index.rkt — resolve a base StructureDefinition (with its snapshot) from the R5 core package.
;;;
;;; Snapshot generation needs the parent's full snapshot; the vendored R5 core package carries one per
;;; StructureDefinition. We lazily stream the .tgz once and index every SD by url / name / id (mirrors
;;; the terminology service's loader). Consumed by sd/{snapshot,element-index}.rkt, the validator
;;; (fhir-validation) and the FSH snapshot mode; the differential-only FSH compile path does not touch this.
;;;
;;; The packages searched are `current-sd-packages` — a list, searched in order, so an IG's profiles
;;; resolve before the core package it builds on: (list us-core.tgz r4-core.tgz). The default is the
;;; R5 core package from the OPTIONAL `fhir-spec` package. Without any package the index is empty:
;;; resolve-sd-raw returns #f and snapshot generation degrades to differential-only.
;;; Consumers that cache derived data (element-index's type cache) key it by `sd-context`.

(require (only-in fhir/canonical canonical-url)
         racket/promise
         racket/contract
         (only-in fhir/package-store package-entries package-entry-kind package-entry-url package-entry-name package-entry-id
                  entry-bytes entry-kinds)
         (only-in racket/list last)
         (only-in fhir/serialize/fast-json fast-bytes->jsexpr)
         (only-in fhir/spec-package spec-package-path))

(provide (contract-out
          [resolve-sd-raw (-> string? (or/c hash? #f))]
          ;; a CodeSystem / ValueSet / StructureDefinition by url, name or id
          [resolve-canonical-raw (-> (or/c "CodeSystem" "ValueSet" "StructureDefinition" "StructureMap" "ConceptMap")
                                     string? (or/c hash? #f))]
          ;; the FHIR NPM packages (.tgz) to resolve from, in priority order; #f = fhir-spec's R5 core
          [current-sd-packages (parameter/c (or/c #f (listof path-string?)))]
          ;; the effective package list — a cache key for anything derived from the index
          [sd-context (-> (listof path?))]
          ;; context-memo : (-> X) -> (-> X)   a value made once per package context and answered
          ;; for the current one (a table of what is derived from the packages)
          [context-memo (-> (-> any/c) (-> any/c))]
          ;; can snapshots be generated at all (is a core package available)?
          [sd-index-available? (-> boolean?)]))

(define current-sd-packages (make-parameter #f))
;; sd-context : -> (listof path)   the effective packages, normalised. Asked on every lookup (and as
;; a cache key on every datatype jump), so the normal form is kept per package list (by identity)
;; when every path in it is complete — a relative one resolves against the current directory, so
;; it is normalised afresh. The default (fhir-spec's R5 core, an absolute path) is computed once.
(define contexts (make-weak-hasheq))
(define default-context #f)
(define (sd-context)
  (define pkgs (current-sd-packages))
  (cond
    [(and pkgs (andmap complete-path? pkgs)) (hash-ref! contexts pkgs (lambda () (normalise pkgs)))]
    [pkgs (normalise pkgs)]
    [else (unless default-context
            (set! default-context
                  (normalise (let ([core (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t)]) (if core (list core) '())))))
          default-context]))
(define (normalise pkgs) (map (lambda (p) (simplify-path (path->complete-path p))) pkgs))

;; What is derived from the packages is kept per context. A table keyed by the context itself
;; hashes the whole list of paths at every lookup (a datatype jump, a constraint site, a binding:
;; several a resource validated); `context-memo` finds the current context's value by IDENTITY
;; — `sd-context` answers one list for as long as the packages are the same — and by its paths
;; only when the list is a new one (a relative path, normalised afresh each time).
(define (context-memo make)
  (define by-identity (make-weak-hasheq))
  (define by-paths (make-hash))
  (lambda ()
    (define context (sd-context))
    (or (hash-ref by-identity context #f)
        (let ([v (hash-ref! by-paths context make)])
          (hash-set! by-identity context v)
          v))))
(define (sd-index-available?) (pair? (sd-context)))

;; one index per package, built on first use; a lookup searches the context's packages in order.
;; A package index is kind -> (url | name | id -> Entry), so a CodeSystem and a ValueSet that share
;; a name never shadow each other.
(define indexes (make-hash))
(define (package-index tgz) (hash-ref! indexes tgz (lambda () (load-index tgz))))

;; load-index : tgz -> (hash kind (mutable-hash key Entry))
;; An Entry is a promise of the resource jsexpr (or #f: a file that is no JSON object). Indexing
;; needs only each resource's top-level url, name and id, which the package store has
;; (fhir/package-store: read from the archive once a machine, not once a process); the resource
;; itself is read and parsed the first time a lookup reaches it (a core package holds thousands; a
;; compile touches tens). Of two resources of a kind with one key, the first in the archive wins.
(define (load-index tgz)
  (define tables (for/hash ([k (in-list entry-kinds)]) (values k (make-hash))))
  (for ([e (in-list (package-entries tgz))])
    (define entry (delay (parsed (entry-bytes e))))
    (define table (hash-ref tables (package-entry-kind e)))
    (for ([k (in-list (list (package-entry-url e) (package-entry-name e) (package-entry-id e)))] #:when k)
      (unless (hash-has-key? table k) (hash-set! table k entry))))
  tables)

;; parsed : bytes -> resource | #f
(define (parsed bs)
  (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (fast-bytes->jsexpr bs)))
  (and (hash? js) js))

;; entry-resource : Entry -> resource | #f
(define (entry-resource e) (and e (force e)))

;; resolve-canonical-raw : kind name-or-url -> resource | #f   (kind: "CodeSystem" | "ValueSet" |
;; "StructureDefinition" | "StructureMap" | "ConceptMap"; searched over the context's packages in
;; order; |version suffix ignored)
(define (resolve-canonical-raw kind name-or-url)
  (define key (canonical-url name-or-url))
  (for/or ([tgz (in-list (sd-context))])
    (entry-resource (hash-ref (hash-ref (package-index tgz) kind (hash)) key #f))))

;; resolve-sd-raw : string -> StructureDefinition | #f   by canonical, type code, name or id
;; The answer for a name is the same for as long as the context is (the packages do not change),
;; and the same names are asked over and over (a resource's type, the profiles it claims, each
;; extension's url — for every resource validated): kept per context, emptied at `kept-names`.
(define kept-names 20000)
(define resolved (context-memo make-hash))          ; per context: name -> StructureDefinition | #f
(define (resolve-sd-raw name-or-url)
  (define table (resolved))
  (define kept (hash-ref table name-or-url 'none))
  (cond [(not (eq? kept 'none)) kept]
        [else
         (define sd (resolve-sd-raw* name-or-url))
         (when (>= (hash-count table) kept-names) (hash-clear! table))
         (hash-set! table name-or-url sd)
         sd]))
(define (resolve-sd-raw* name-or-url)
  (define key (canonical-url name-or-url))        ; drop a |version suffix
  (define tables (map (lambda (t) (hash-ref (package-index t) "StructureDefinition")) (sd-context)))
  (define (lookup k) (for/or ([t (in-list tables)]) (entry-resource (hash-ref t k #f))))
  ;; a bare type code ("Patient") means the core canonical, NOT whatever SD happens to share that
  ;; name or id (R4 core has an extension NAMED "FamilyMemberHistory")
  (or (and (not (regexp-match? #rx"/" key))
           (lookup (string-append "http://hl7.org/fhir/StructureDefinition/" key)))
      (lookup key)
      (and (regexp-match? #rx"/" key)
           (lookup (last (regexp-split #rx"/" key))))))


(module+ test
  (require rackunit)
  ;; one value a context, whichever way the context is found
  (let ([made 0])
    (define table (context-memo (lambda () (set! made (add1 made)) (make-hash))))
    (define here (list (path->complete-path "a.tgz")))
    (parameterize ([current-sd-packages here])
      (check-eq? (table) (table))
      (parameterize ([current-sd-packages (list (path->complete-path "b.tgz"))]) (check-not-eq? (table) (hash)))
      (define first (table))
      ;; the same packages as a new list, and as a relative path
      (parameterize ([current-sd-packages (list (path->complete-path "a.tgz"))]) (check-eq? (table) first))
      (parameterize ([current-sd-packages (list "a.tgz")]) (check-eq? (table) first) (check-eq? (table) first)))
    (check-equal? made 2))
  ;; an entry is the parsed resource, on demand; a file that is no JSON object is none
  (check-equal? (entry-resource (delay (parsed #"{\"url\":\"u\",\"id\":\"i\",\"x\":[1]}"))) (hasheq 'url "u" 'id "i" 'x '(1)))
  (check-false (entry-resource (delay (parsed #"[1]"))))
  (check-false (entry-resource (delay (parsed #"{")))))
