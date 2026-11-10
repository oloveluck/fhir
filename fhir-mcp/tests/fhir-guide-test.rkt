#lang racket/base

;;; fhir-guide-test.rkt — `raco fhir guide <topic>` prints the same guide as `raco fhir-mcp guide`: the
;;; Racket route reads the guides without naming the MCP server (a rerun's agent asked for it).

(require rackunit racket/port racket/system compiler/find-exe
         (only-in fhir/mcp/resources learn-text))

(define (run . args)
  (define out (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port (open-output-nowhere)])
                 (apply system*/exit-code (find-exe) "-l-" "raco" args)))
  (values code (get-output-string out)))
(let-values ([(code text) (run "fhir" "guide" "cql")])
  (check-equal? code 0)
  (check-equal? text (learn-text "cql")))
(let-values ([(code text) (run "fhir" "guide")])
  (check-equal? code 0)
  (check-regexp-match #rx"(?m:^workspace  )" text))
(let-values ([(code _t) (run "fhir" "guide" "nope")])
  (check-equal? code 2))
