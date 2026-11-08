#lang racket/base

;;; spec-package.rkt — locate the vendored HL7 FHIR NPM packages (the `fhir-spec` package).
;;;
;;; fhir-spec is a DATA package (50 MB of .tgz) that only codegen, snapshot generation, the
;;; terminology service and the conformance suites read. It is deliberately NOT a static dependency
;;; of `fhir`: a `#lang cql` user never needs it. Callers that can work without it pass
;;; #:optional? #t and get #f; everything else gets a clear "install fhir-spec" error.
;;;
;;; A package is looked for, in order, in the directories of `current-package-directories`, then in
;;; the fhir-spec collection. The directories start as those named by the environment variable
;;; FHIR_PACKAGE_PATH (a path list, `:`-separated on Unix), then `share/fhir-packages` beside the
;;; running executable when there is one — where a standalone build of the command-line tools
;;; (no Racket installation, so no fhir-spec collection) keeps its packages.

(require racket/contract)

(provide (contract-out
          ;; spec-package-path : file-name [#:optional? boolean] -> (or/c path? #f)
          [spec-package-path (->* (string?) (#:optional? boolean?) (or/c path? #f))]
          ;; more directories of packages, searched before fhir-spec (a cache of fetched IGs)
          [current-package-directories (parameter/c (listof path-string?))]
          ;; is the fhir-spec package installed?
          [spec-package-available? (-> boolean?)]))

;; environment-package-directories : -> (listof path)   FHIR_PACKAGE_PATH's directories
(define (environment-package-directories)
  (define v (getenv "FHIR_PACKAGE_PATH"))
  (if (and v (not (equal? v ""))) (path-list-string->path-list v '()) '()))

;; executable-package-directory : -> (or/c path #f)   <executable's dir>/../share/fhir-packages, if
;; it exists (the executable found through PATH when it was started by name, a symlink to it followed)
(define (executable-package-directory)
  (define exe (find-executable-path (find-system-path 'exec-file)))
  (and exe
       (let* ([real (simplify-path (path->complete-path (resolve-path exe) (current-directory)))]
              [dir (simplify-path (build-path real 'up 'up "share" "fhir-packages"))])
         (and (directory-exists? dir) dir))))

;; current-package-directories : (parameter (listof dir))
(define current-package-directories
  (make-parameter (append (environment-package-directories)
                          (let ([d (executable-package-directory)]) (if d (list d) '())))))

;; collection-file-path answers a path whenever the COLLECTION exists, whether or not the file does,
;; so existence is checked here: a missing file and a missing package are the same failure.
(define (spec-package-path file #:optional? [optional? #f])
  (define p (or (for/or ([d (in-list (current-package-directories))])
                  (let ([q (build-path d file)]) (and (file-exists? q) q)))
                (collection-file-path file "fhir-spec" #:fail (lambda (msg) #f))))
  (cond
    [(and p (file-exists? p)) p]
    [optional? #f]
    [else
     (raise-user-error
      'fhir "~a is not available: it ships in the fhir-spec package (raco pkg install fhir-spec), or put it in a directory named by FHIR_PACKAGE_PATH"
      file)]))

(define (spec-package-available?)
  (and (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t) #t))

(module+ test
  (require rackunit racket/file)
  (check-pred boolean? (spec-package-available?))
  (check-equal? (spec-package-path "no-such-package.tgz" #:optional? #t) #f)
  (check-exn exn:fail:user? (lambda () (spec-package-path "no-such-package.tgz")))
  (define d (make-temporary-directory))
  (call-with-output-file (build-path d "x.tgz") void)
  (check-equal? (parameterize ([current-package-directories (list d)]) (spec-package-path "x.tgz"))
                (build-path d "x.tgz"))
  ;; FHIR_PACKAGE_PATH names directories of packages
  (define e (make-temporary-directory))
  (check-equal? (begin (putenv "FHIR_PACKAGE_PATH" (path->string e)) (environment-package-directories)) (list e))
  (check-equal? (begin (putenv "FHIR_PACKAGE_PATH" "") (environment-package-directories)) '()))
