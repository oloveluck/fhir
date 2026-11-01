#lang racket/base

;;; spec-package.rkt — locate the vendored HL7 FHIR NPM packages (the `fhir-spec` package).
;;;
;;; fhir-spec is a DATA package (50 MB of .tgz) that only codegen, snapshot generation, the
;;; terminology service and the conformance suites read. It is deliberately NOT a static dependency
;;; of `fhir`: a `#lang cql` user never needs it. Callers that can work without it pass
;;; #:optional? #t and get #f; everything else gets a clear "install fhir-spec" error.

(require racket/contract)

(provide (contract-out
          ;; spec-package-path : file-name [#:optional? boolean] -> (or/c path? #f)
          [spec-package-path (->* (string?) (#:optional? boolean?) (or/c path? #f))]
          ;; is the fhir-spec package installed?
          [spec-package-available? (-> boolean?)]))

;; collection-file-path answers a path whenever the COLLECTION exists, whether or not the file does,
;; so existence is checked here: a missing file and a missing package are the same failure.
(define (spec-package-path file #:optional? [optional? #f])
  (define p (collection-file-path file "fhir-spec" #:fail (lambda (msg) #f)))
  (cond
    [(and p (file-exists? p)) p]
    [optional? #f]
    [else
     (raise-user-error
      'fhir "~a is not available: it ships in the fhir-spec package (raco pkg install fhir-spec)"
      file)]))

(define (spec-package-available?)
  (and (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t) #t))

(module+ test
  (require rackunit)
  (check-pred boolean? (spec-package-available?))
  (check-equal? (spec-package-path "no-such-package.tgz" #:optional? #t) #f)
  (check-exn exn:fail:user? (lambda () (spec-package-path "no-such-package.tgz"))))
