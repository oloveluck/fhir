#lang racket/base

;;; package-set.rkt — a FHIR package with what it builds on: the packages a validation or a server
;;; reads together.
;;;
;;; A published Implementation Guide is an NPM package whose package.json names the packages it
;;; depends on and the FHIR version it is written for. To hold a resource to the guide's profiles,
;;; the guide, its dependencies (transitively) and the core package of its FHIR version have to be
;;; in context together, the guide first. This module finds them; nothing here reads a profile.
;;;
;;; Data definitions
;;;   A PackageRef is a String: a file ("./x.tgz"), a file name among the family's packages
;;;     ("hl7.fhir.us.core-6.1.0.tgz") or a package name ("hl7.fhir.us.core", "hl7.fhir.us.core-6.1.0").
;;;   A PackageSet is a (listof path): the package, its dependencies nearest first, each once, then
;;;     the core package — the order `current-sd-packages` reads them in.

(require racket/contract racket/list racket/string
         (only-in "package.rkt" read-package)
         (only-in "spec-package.rkt" spec-package-path current-package-directories))

(provide
 (contract-out
  [package-manifest     (-> path-string? (or/c hash? #f))]
  [package-file         (-> string? (or/c path? #f))]
  [package-dependencies (-> path-string? (listof path?))]
  [package-fhir-version (-> path-string? (or/c string? #f))]
  [core-package-file    (-> (or/c string? #f) (or/c string? #f))]
  [package-set          (-> path-string? (listof path?))]
  [find-package         (-> string? string? (or/c path? #f))]
  [core-package-name?   (-> string? boolean?)]
  [version-matches?     (-> string? string? boolean?)]))

;; package-manifest : path -> jsexpr | #f   the package's package.json
(define (package-manifest tgz) (let-values ([(m _r _e) (read-package tgz #:select (lambda (_) #f))]) m))

;; package-file : PackageRef -> path | #f   the package's file, #f when nothing has that name
(define (package-file s)
  (cond [(file-exists? s) (string->path s)]
        [(regexp-match? #rx"[.]tgz$" s) (spec-package-path s #:optional? #t)]
        [else (spec-package-path (string-append s ".tgz") #:optional? #t)]))

;; package-fhir-version : path -> string | #f   the first FHIR version its package.json names
(define (package-fhir-version tgz)
  (define m (package-manifest tgz))
  (define vs (and m (or (hash-ref m 'fhirVersions #f) (hash-ref m 'fhir-version-list #f))))
  (cond [(and (pair? vs) (string? (car vs))) (car vs)]
        [(string? vs) vs]
        [else #f]))

;; core-package-file : fhir-version | #f -> file-name | #f   the core package of a FHIR version
(define (core-package-file v)
  (cond [(not v) #f]
        [(regexp-match? #rx"^4[.]0" v) "hl7.fhir.r4.core.tgz"]
        [(regexp-match? #rx"^5[.]0" v) "hl7.fhir.r5.core.tgz"]
        [(regexp-match? #rx"^6[.]" v) "hl7.fhir.r6.core.tgz"]
        [else #f]))

;; package-set : path -> PackageSet   the package, what it depends on, and the core of its version
;; (a core package is its own set; a package naming no known version brings no core)
(define (package-set tgz)
  (define m (package-manifest tgz))
  (define core (let ([f (core-package-file (package-fhir-version tgz))])
                 (and f (spec-package-path f #:optional? #t))))
  (define path (if (path? tgz) tgz (string->path tgz)))
  (if (and m (core-package-name? (hash-ref m 'name "")))
      (list path)
      (append (list path) (package-dependencies tgz) (if core (list core) '()))))

;; package-dependencies : tgz -> (listof path)
;; package.json `dependencies`, transitively (nearest first, each once), located as
;; <name>-<version>.tgz (or <name>.tgz when that IS the version) in `current-package-directories` or
;; among the family's packages; a version may be a pattern (`3.3.x`). Core packages and ones not
;; found are left out (the core is added separately; a missing one only narrows validation)
(define (package-dependencies tgz)
  (let loop ([todo (direct-dependencies tgz)] [seen '()])
    (cond [(null? todo) (reverse seen)]
          [(member (car todo) seen) (loop (cdr todo) seen)]
          [else (loop (append (cdr todo) (direct-dependencies (car todo))) (cons (car todo) seen))])))

;; direct-dependencies : tgz -> (listof path)   the dependencies named in its package.json and found
(define (direct-dependencies tgz)
  (define m (package-manifest tgz))
  (define ds (if (and m (hash? (hash-ref m 'dependencies #f))) (hash-ref m 'dependencies) (hash)))
  (for*/list ([(name version) (in-hash ds)]
              #:unless (core-package-name? (symbol->string name))
              #:when (string? version)
              [p (in-value (find-package (symbol->string name) version))]
              #:when p)
    p))

;; core-package-name? : String -> Boolean   a core, terminology or extensions package (never a dependency)
(define (core-package-name? name)
  (regexp-match? #px"^hl7[.]fhir[.]r[0-9]+b?[.]core$|^hl7[.]terminology|[.]extensions" name))

;; find-package : name version-or-pattern -> path | #f
(define (find-package name version)
  (define (version-ok? q) (let ([qm (package-manifest q)])
                            (and qm (version-matches? (hash-ref qm 'version "") version))))
  (or (spec-package-path (format "~a-~a.tgz" name version) #:optional? #t)
      (for*/first ([d (in-list (current-package-directories))]
                   #:when (directory-exists? d)
                   [f (in-list (sort (directory-list d) string>? #:key path->string))]   ; newest first
                   #:when (regexp-match? (pregexp (format "^~a-[^-]+[.]tgz$" (regexp-quote name))) (path->string f))
                   #:when (version-ok? (build-path d f)))
        (build-path d f))
      (let ([q (spec-package-path (format "~a.tgz" name) #:optional? #t)])
        (and q (version-ok? q) q))))

;; version-matches? : "3.3.2" "3.3.x" -> Boolean   (x / * stand for any one part)
(define (version-matches? v pattern)
  (define ps (string-split pattern "."))
  (define vs (string-split v "."))
  (and (= (length ps) (length vs))
       (for/and ([p (in-list ps)] [x (in-list vs)]) (or (member p '("x" "X" "*")) (equal? p x)))
       #t))

(module+ test
  (require rackunit)
  (check-true (version-matches? "3.3.2" "3.3.x"))
  (check-true (version-matches? "3.3.2" "3.3.2"))
  (check-false (version-matches? "3.4.2" "3.3.x"))
  (check-false (version-matches? "3.3" "3.3.x"))
  (check-true (core-package-name? "hl7.fhir.r4.core"))
  (check-true (core-package-name? "hl7.terminology.r4"))
  (check-false (core-package-name? "hl7.fhir.us.core"))
  (check-equal? (core-package-file "4.0.1") "hl7.fhir.r4.core.tgz")
  (check-equal? (core-package-file "6.0.0-ballot4") "hl7.fhir.r6.core.tgz")
  (check-false (core-package-file "3.0.2"))
  (check-false (package-file "no.such.package"))
  ;; over the family's packages, when they are installed: mCODE builds on US Core and Genomics
  ;; Reporting, and is written for R4
  (define mcode (package-file "hl7.fhir.us.mcode-4.0.0"))
  (when mcode
    (define (names ps) (for/list ([p (in-list ps)]) (hash-ref (package-manifest p) 'name)))
    (define set (package-set mcode))
    (check-equal? (car (names set)) "hl7.fhir.us.mcode")
    (check-equal? (last (names set)) "hl7.fhir.r4.core")
    (check-not-false (member "hl7.fhir.us.core" (names set)))
    (check-equal? (package-fhir-version mcode) "4.0.1")
    (check-equal? (length (package-set (last set))) 1)))
