#lang racket/base

;;; manuals-test.rkt — every manual the docs workflow builds expands FROM ITS SOURCE.
;;;
;;; `raco scribble` on a machine that has built a manual before loads the compiled copy beside
;;; it, and a compiled manual does not notice that a module it requires for its labels now
;;; exports a name another of them exports too: here everything passed while the workflow, which
;;; starts from nothing, failed with "identifier already required for label" (`rest-url?`, moved
;;; to fhir/data-source and still exported by fhir/rest-data-source under a contract of its own —
;;; a second binding). So each manual's source is read and expanded here, whatever is compiled.
;;; A manual whose package is not installed (its modules are not found) is skipped, and said.

(require rackunit racket/runtime-path racket/file racket/string racket/list)

(define-runtime-path root "../..")
(define workflow (build-path root ".github" "workflows" "docs.yml"))

;; manuals : -> (listof path)   the .scrbl files the workflow gives to `raco scribble`
(define (manuals)
  (remove-duplicates
   (for*/list ([line (in-list (file->lines workflow))]
               #:when (regexp-match? #rx"raco scribble" line)
               [m (in-value (regexp-match #rx"([^ ]+[.]scrbl)" line))]
               #:when m)
     (simplify-path (build-path root (cadr m))))))

;; expansion-problem : path -> string | #f   what expanding the manual's source raises
(define (expansion-problem scrbl)
  (define-values (dir _name _d) (split-path scrbl))
  (parameterize ([current-namespace (make-base-namespace)]
                 [current-load-relative-directory dir]
                 [current-directory dir]
                 [read-accept-reader #t]
                 [read-accept-lang #t])
    (with-handlers ([exn:fail? exn-message])
      (define stx (call-with-input-file scrbl
                    (lambda (in) (port-count-lines! in) (read-syntax scrbl in))))
      (expand stx)
      #f)))

;; not-installed? : string -> boolean   the problem is a module of a package that is not here
(define (not-installed? message)
  (regexp-match? #rx"collection not found|cannot open module file|standard-module-name-resolver" message))

(module+ test
  (check-true (file-exists? workflow))
  (define all (manuals))
  (check-true (>= (length all) 8) "the workflow builds the site's index and a manual a package")
  (for ([scrbl (in-list all)])
    (check-true (file-exists? scrbl) (format "~a is built by the workflow and is not there" scrbl))
    (define problem (and (file-exists? scrbl) (expansion-problem scrbl)))
    (cond
      [(and problem (not-installed? problem))
       (printf "  ~a: not expanded (a package it documents is not installed)\n" (find-relative-path* scrbl))]
      [else (check-false problem (format "~a does not expand from its source" (find-relative-path* scrbl)))]))
  ;; the rule itself: two modules required for label that both export a name are refused
  (check-regexp-match
   #rx"already required"
   (parameterize ([current-namespace (make-base-namespace)])
     (with-handlers ([exn:fail? exn-message])
       (expand '(module m racket/base
                  (module a racket/base (provide f) (define (f) 1))
                  (module b racket/base (provide f) (define (f) 2))
                  (require (for-label (submod "." a) (submod "." b)))))
       "expanded"))))

;; find-relative-path* : path -> string   the path from the repository's root
(define (find-relative-path* p)
  (define r (path->string (simplify-path root)))
  (define s (path->string p))
  (if (string-prefix? s r) (substring s (string-length r)) s))
