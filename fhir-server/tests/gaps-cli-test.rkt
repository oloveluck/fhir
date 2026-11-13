#lang racket/base

;;; gaps-cli-test.rkt — `raco fhir-server serve-ig <ig> --gaps`: the guide's requirements the
;;; generated server does not meet, one row each on stdout; and when there is none, a line that says
;;; so (on stderr: stdout stays a table). It printed nothing at all for US Core, which read the same
;;; as a command that had not run (found by the standalone tools' smoke test).

(require rackunit racket/system racket/port racket/string)

(define (gaps ig)
  (define out (open-output-string))
  (define err (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port err])
                 (system*/exit-code (find-executable-path "raco") "fhir-server" "serve-ig" ig "--gaps")))
  (values code (get-output-string out) (get-output-string err)))

(let-values ([(code out err) (gaps "hl7.fhir.us.core")])
  (check-equal? code 0 err)
  (check-equal? out "" "no gap: no row")
  (check-regexp-match #rx"^hl7.fhir.us.core: no unmet requirement" err))

(let-values ([(code out err) (gaps "hl7.fhir.uv.ips")])
  (check-equal? code 0 err)
  (check-equal? out "Patient\toperation\tsummary\tSHOULD\toperation not implemented\n")
  (check-false (string-contains? err "no unmet requirement")))
