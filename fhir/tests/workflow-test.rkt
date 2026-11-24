#lang racket/base

;;; workflow-test.rkt — the docs workflow (.github/workflows/docs.yml) can still do what it says.
;;;
;;; The workflow is the one place the family's packages are installed from nothing, and it failed
;;; for sixteen days without anyone reading it (2026-11-08 to 11-24): fhir-mcp had begun to depend
;;; on sql-on-fhir, which the workflow did not install, so every build stopped at its first step
;;; and the published site stood still; behind that, a later step named a test file that had been
;;; deleted. Both are facts about this repository that can be checked here, before a push:
;;;   - every family package an info.rkt of this repository depends on is one the workflow
;;;     installs (a directory of the repository, or the family's repository of that name);
;;;   - every file the workflow names is there.
;;; Outside a checkout (an installed package has no .github) there is nothing to check.

(require rackunit racket/file racket/list racket/string racket/runtime-path (only-in setup/getinfo get-info/full))

(define-runtime-path repository "../..")
(define workflow (build-path repository ".github" "workflows" "docs.yml"))

;; the family's packages: none is on the package catalogue, so each must be installed by name
(define family '("fhir" "fhir-spec" "fhir-tx" "fhir-validation" "fhir-server" "fhir-lsp" "fhir-mcp"
                 "fhirpath" "vcl" "cql" "fml" "fsh" "sql-on-fhir" "fhir-examples"))

;; dependencies : package directory -> (listof string)   the package names of its deps and build-deps
(define (dependencies dir)
  (define info (get-info/full dir))
  (define (names key)
    (for/list ([d (in-list (if info (info key (lambda () '())) '()))]) (if (pair? d) (car d) d)))
  (append (names 'deps) (names 'build-deps)))

(when (file-exists? workflow)
  (define text (file->string workflow))
  (define local (regexp-match* #px"\"[.]/([a-z-]+)\"" text #:match-select cadr))
  (define remote (regexp-match* #px"github[.]com/oloveluck/([a-z-]+)[.]git" text #:match-select cadr))
  (test-case "the workflow installs every family package this repository's packages depend on"
    (check-true (pair? local))
    (for ([package (in-list local)])
      (define info (build-path repository package "info.rkt"))
      (check-true (file-exists? info) (format "the workflow installs ./~a, which is no package here" package))
      (for ([d (in-list (dependencies (build-path repository package)))] #:when (member d family))
        (check-true (and (member d (append local remote)) #t)
                    (format "~a depends on ~a, which the docs workflow does not install: add its repository to the install step" package d)))))
  (test-case "every file the workflow names is there"
    (define named (remove-duplicates (regexp-match* #px"[a-z-]+/[A-Za-z0-9/_.-]*[.](?:rkt|scrbl|css)" text)))
    (check-true (> (length named) 30))
    (for ([f (in-list named)])
      (check-true (file-exists? (build-path repository f)) (format "the docs workflow names ~a, which is not there" f)))))
