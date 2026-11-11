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

;; a recipe saved as a file in one command (a rerun's agent cut it out of the printed guide with sed):
;; `--blocks` lists the code blocks, `--block N` prints one, the same from both commands
(let-values ([(code listing) (run "fhir" "guide" "cql" "--blocks")])
  (check-equal? code 0)
  (define n (for/first ([l (in-list (regexp-split #rx"\n" listing))] #:when (regexp-match? #rx"library LatestA1c" l))
              (string->number (car (regexp-match #px"^[0-9]+" l)))))
  (check-true (exact-positive-integer? n) listing)
  (let-values ([(c1 a) (run "fhir" "guide" "cql" "--block" (number->string n))]
               [(c2 b) (run "fhir-mcp" "guide" "cql" "--block" (number->string n))])
    (check-equal? (list c1 c2) '(0 0))
    (check-equal? a b)
    (check-regexp-match #rx"^library LatestA1c version '1'\n" a)
    (check-false (regexp-match? #rx"```" a))))
(let-values ([(code _t) (run "fhir" "guide" "cql" "--block" "999")])
  (check-equal? code 2))
;; the CQL guide's own instruction (`--block N > LatestA1c.cql`) names the recipe's block
(let* ([n (cadr (regexp-match #px"raco fhir guide cql --block ([A-Za-z0-9]+) > LatestA1c[.]cql" (learn-text "cql")))])
  (let-values ([(code text) (run "fhir" "guide" "cql" "--block" n)])
    (check-equal? code 0)
    (check-regexp-match #rx"^library LatestA1c " text)))
;; the fhir skill's `--block egfr` for the capability guide is the eGFR operation (by name: a number
;; shifts when a guide gains a block)
(let-values ([(code text) (run "fhir" "guide" "capability" "--block" "egfr")])
  (check-equal? code 0)
  (check-regexp-match #rx"^[(]define [(]egfr-handler in req[)]" text))
;; --blocks names each block's section
(let-values ([(code listing) (run "fhir" "guide" "capability" "--blocks")])
  (check-regexp-match #rx"(?m:^3  \\[racket\\] \\(Operations: inputs and outputs\\) \\(define \\(egfr-handler)" listing))
(let-values ([(code text) (run "fhir-mcp" "guide" "workspace" "--block" "BloodPressureRule")])
  (check-equal? code 0)
  (check-regexp-match #rx"^Profile: BloodPressureRule\n" text))
;; --blocks shows the name --block takes (an agent guessed `bp`), and that name is the block declaring it
(let-values ([(code listing) (run "fhir" "guide" "workspace" "--blocks")])
  (check-regexp-match #rx"(?m:^[0-9]+  --block bp  \\[json\\])" listing)
  (check-regexp-match #rx"(?m:^[0-9]+  --block BloodPressureRule  \\[fsh\\])" listing))
(let-values ([(code text) (run "fhir" "guide" "workspace" "--block" "bp")])
  (check-regexp-match #rx"\"name\": \"bp\"" text))
