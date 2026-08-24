#lang racket/base

;;; run.rkt — the `raco fhir sof-tck` entry point: run every vendored official SQL-on-FHIR suite
;;; and report pass/total per file + overall, with a never-regress floor.

(require racket/runtime-path
         (only-in racket/path file-name-from-path)
         (only-in "harness.rkt" run-suite))

(define-runtime-path suite-dir "vendor/sof-tests")

(module+ main
  (define verbose? (member "-v" (vector->list (current-command-line-arguments))))
  (define suites (sort (for/list ([f (in-list (directory-list suite-dir))]
                                  #:when (regexp-match? #px"\\.json$" (path->string f)))
                         (build-path suite-dir f))
                       string<? #:key path->string))
  (define-values (tp ta fs)
    (for/fold ([tp 0] [ta 0] [fs '()]) ([s (in-list suites)])
      (define-values (p a failures) (run-suite s))
      (printf "~a: ~a/~a\n" (path->string (file-name-from-path s)) p a)
      (values (+ tp p) (+ ta a)
              (append fs (map (lambda (f) (cons (path->string (file-name-from-path s)) f)) failures)))))
  (when verbose?
    (for ([f (in-list fs)]) (printf "  FAIL [~a] ~a: ~a\n" (car f) (cadr f) (caddr f))))
  (printf "SQL-on-FHIR conformance: ~a/~a\n" tp ta)
  (define floor 133)                                   ; the full official suite
  (unless (>= tp floor)
    (eprintf "SQL-on-FHIR conformance regressed: ~a < floor ~a\n" tp floor)
    (exit 1)))
