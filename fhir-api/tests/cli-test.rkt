#lang racket/base

;;; cli-test.rkt — `raco fhir-api` as a process, the way a client starts it: the lines it answers,
;;; one call from the shell, usage and exit statuses, a process for FHIR 5.0.0 (this test's own
;;; process loads no FHIR version, so each can be asked for), and the table kept for the clients.

(require rackunit racket/file racket/port racket/string racket/system json
         (only-in "../api/functions.rkt" functions-json-text))

(define raco (or (find-executable-path "raco") (error "raco is not on the PATH")))

;; run : (listof string) [stdin text] -> (values stdout stderr status)
(define (run args [input ""])
  (define out (open-output-string))
  (define err (open-output-string))
  (define status
    (parameterize ([current-output-port out] [current-error-port err] [current-input-port (open-input-string input)])
      (apply system*/exit-code raco "fhir-api" args)))
  (values (get-output-string out) (get-output-string err) status))

;; ---- usage -----------------------------------------------------------------------------------------
(let-values ([(out err status) (run '("--help"))])
  (check-equal? status 0)
  (check-regexp-match #rx"^raco fhir-api \\[serve\\]" out)
  (check-equal? err ""))
(let-values ([(out err status) (run '("frobnicate"))])
  (check-equal? status 2)
  (check-equal? out "")
  (check-regexp-match #rx"^fhir-api: unknown command frobnicate\n" err))
(let-values ([(out err status) (run '("serve" "--fhir-version" "3.0.2"))])
  (check-equal? status 2)
  (check-regexp-match #rx"FHIR version 3.0.2 is not one this toolkit reads" err))

;; ---- the table: what the command prints is what the clients are given ------------------------------
(let-values ([(out err status) (run '("functions" "--json"))])
  (check-equal? status 0)
  (check-equal? out (functions-json-text))
  (define kept (collection-file-path "functions.json" "fhir" #:fail (lambda (_) #f)))
  (void kept))
(define kept-table (simplify-path (build-path (collection-file-path "api-cli.rkt" "fhir") 'up 'up "clients" "functions.json")))
(check-true (file-exists? kept-table) "clients/functions.json")
(check-equal? (file->string kept-table) (functions-json-text)
              "clients/functions.json is not the table: write it again with `raco fhir-api functions --json > clients/functions.json`, then `python3 clients/python/generate.py`")
(let-values ([(out err status) (run '("functions"))])
  (check-regexp-match #rx"^compile — " out)
  (check-regexp-match #rx"\nfhirpath — A FHIRPath expression evaluated over one resource" out))

;; ---- one call from the shell ------------------------------------------------------------------------
(define patient "{\"resourceType\":\"Patient\",\"name\":[{\"family\":\"Lee\"}]}")
(let-values ([(out err status) (run (list "call" "fhirpath" (format "{\"expression\":\"name.family\",\"resource\":~a}" patient)))])
  (check-equal? status 0)
  (check-equal? (string->jsexpr out) (hasheq 'values '("Lee"))))
(let-values ([(out err status) (run '("call" "fhirpath" "-") (format "{\"expression\":\"name.family.count()\",\"resource\":~a}" patient))])
  (check-equal? (string->jsexpr out) (hasheq 'values '(1))))
(let-values ([(out err status) (run '("call" "fhirpath" "{\"expresion\":\"name\"}"))])
  (check-equal? status 2)
  (check-regexp-match #rx"`expresion` is not a parameter of fhirpath" err))
(let-values ([(out err status) (run '("call" "nope"))])
  (check-equal? status 2)
  (check-regexp-match #rx"no function nope" err))
(let-values ([(out err status) (run (list "call" "fhirpath" (format "{\"expression\":\"name.nmae\",\"resource\":~a}" patient)))])
  (check-equal? status 1)
  (check-equal? out "")
  (check-regexp-match #rx"no element HumanName.nmae" err))

;; ---- the server: a line in, a line out, in order; what a library prints stays off the protocol ------
(let-values ([(out err status)
              (run '("serve")
                   (string-append
                    "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"version\"}\n"
                    (format "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"fhirpath\",\"params\":{\"expression\":\"name.family\",\"resource\":~a}}\n" patient)
                    "not json\n"
                    "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"compile\",\"params\":{\"files\":{\"p.fsh\":\"Profile: P\\nParent: Patient\\n\"}}}\n"))])
  (check-equal? status 0)
  (define lines (map string->jsexpr (string-split out "\n")))
  (check-equal? (map (lambda (l) (hash-ref l 'id)) lines) (list 1 2 'null 3))
  (check-equal? (hash-ref (hash-ref (cadr lines) 'result) 'values) '("Lee"))
  (check-equal? (hash-ref (hash-ref (caddr lines) 'error) 'code) -32700)
  (check-equal? (hash-ref (car (hash-ref (hash-ref (cadddr lines) 'result) 'resources)) 'id) "P"))

;; ---- a process for FHIR 5.0.0: R5's elements are read, a 4.0.1 project is refused -------------------
(let-values ([(out err status)
              (run '("serve" "--fhir-version" "5.0.0")
                   (string-append
                    "{\"id\":1,\"method\":\"version\"}\n"
                    ;; Encounter.actualPeriod is R5's (R4: period)
                    "{\"id\":2,\"method\":\"fhirpath\",\"params\":{\"expression\":\"actualPeriod.start\",\"resource\":{\"resourceType\":\"Encounter\",\"status\":\"completed\",\"actualPeriod\":{\"start\":\"2025-01-01\"}}}}\n"
                    "{\"id\":3,\"method\":\"compile\",\"params\":{\"files\":{\"p.fsh\":\"Profile: P\\nParent: Patient\\n\"}}}\n"
                    "{\"id\":4,\"method\":\"compile\",\"params\":{\"files\":{\"workspace.yaml\":\"canonical: http://x.org\\n\"}}}\n"))])
  (define lines (map string->jsexpr (string-split out "\n")))
  (check-equal? (hash-ref (hash-ref (car lines) 'result) 'fhirVersion) "5.0.0")
  (check-equal? (hash-ref (hash-ref (cadr lines) 'result) 'values) '("2025-01-01"))
  (check-equal? (hash-ref (car (hash-ref (hash-ref (caddr lines) 'result) 'resources)) 'fhirVersion) "5.0.0")
  (check-regexp-match #rx"the project is FHIR 4.0.1 and this process reads FHIR 5.0.0.*say fhirVersion"
                      (hash-ref (hash-ref (cadddr lines) 'error) 'message)))
