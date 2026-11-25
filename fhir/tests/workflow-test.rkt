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
;;;   - every package of this repository (a directory with an info.rkt) is one the workflow installs,
;;;     so a new package is built and tested from nothing too;
;;;   - release/family.lock (the commits a release is built from) names exactly the family's other
;;;     repositories the workflow installs, each by a whole commit id;
;;;   - the wheels workflow names files that are there.
;;; Outside a checkout (an installed package has no .github) there is nothing to check.

(require rackunit racket/file racket/list racket/string racket/runtime-path (only-in setup/getinfo get-info/full))

(define-runtime-path repository "../..")
(define workflow (build-path repository ".github" "workflows" "docs.yml"))

;; the family's packages: none is on the package catalogue, so each must be installed by name
(define family '("fhir" "fhir-spec" "fhir-tx" "fhir-validation" "fhir-server" "fhir-lsp" "fhir-mcp"
                 "fhir-api" "fhirpath" "vcl" "cql" "fml" "fsh" "sql-on-fhir" "fhir-examples"))

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
  (test-case "the workflow installs every package of this repository"
    (define here
      (for/list ([d (in-list (directory-list repository))]
                 #:when (file-exists? (build-path repository d "info.rkt")))
        (path->string d)))
    (check-true (> (length here) 5))
    (check-equal? (sort local string<?) (sort here string<?)))
  (test-case "the release's lock file names the family's other repositories, each at a commit"
    (define lock (build-path repository "release" "family.lock"))
    (check-true (file-exists? lock))
    (define locked
      (for/list ([line (in-list (file->lines lock))] #:unless (regexp-match? #px"^\\s*(#|$)" line))
        (string-split line)))
    (check-equal? (sort (map car locked) string<?) (sort remote string<?))
    (for ([l (in-list locked)])
      (check-true (and (= (length l) 2) (regexp-match? #px"^[0-9a-f]{40}$" (cadr l))) (format "~a" l)))
    ;; and the script that installs a release installs this repository's packages, all of them
    (define install (file->string (build-path repository "release" "install-family.sh")))
    (for ([package (in-list local)])
      (check-true (regexp-match? (pregexp (string-append "\\b" (regexp-quote package) "\\b")) install)
                  (format "release/install-family.sh does not install ~a" package))))
  (test-case "the wheels workflow names files that are there"
    (define wheels (file->string (build-path repository ".github" "workflows" "wheels.yml")))
    (for ([f (in-list '("release/install-family.sh" "build-tools.sh" "clients/python/build_wheel.py" "clients/python/test_wheel.py"))])
      (check-true (and (regexp-match? (regexp-quote f) wheels) #t) f)
      (check-true (or (file-exists? (build-path repository f)) (directory-exists? (build-path repository f))) f)))
  (test-case "the clients are tested where the server is"
    ;; each client's tests are run by the docs workflow, in the client's own directory
    (check-regexp-match #rx"unittest discover -s clients/python/tests" text)
    (check-regexp-match #rx"cd clients/typescript\n +npm ci[^\n]*\n +npm test" text)
    (for ([f (in-list '("clients/functions.json" "clients/python/generate.py" "clients/typescript/generate.mjs"
                        "clients/typescript/package.json" "clients/typescript/package-lock.json"))])
      (check-true (file-exists? (build-path repository f)) f))
    ;; what a release is made of is named, and is there
    (define releasing (file->string (build-path repository "release" "RELEASING.md")))
    (for ([f (in-list '("release/family.lock" "release/sqlite.lock" "release/build-sqlite.sh" "release/lock-family.sh"
                        "clients/python/build_wheel.py" "clients/python/test_wheel.py" "clients/python/pyproject.toml"))])
      (check-true (and (regexp-match? (regexp-quote f) releasing) #t) (format "RELEASING.md does not name ~a" f))
      (check-true (file-exists? (build-path repository f)) f)))
  (test-case "every file the workflow names is there"
    (define named (remove-duplicates (regexp-match* #px"[a-z-]+/[A-Za-z0-9/_.-]*[.](?:rkt|scrbl|css)" text)))
    (check-true (> (length named) 30))
    (for ([f (in-list named)])
      (check-true (file-exists? (build-path repository f)) (format "the docs workflow names ~a, which is not there" f)))))
