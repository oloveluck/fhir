#lang racket/base

;;; bp-session-test.rkt — learn://workspace's whole blood-pressure program runs as written: every file
;;; saved from the guide by its block name, `raco fhir-mcp init ws`, then the `bp-session` block as a
;;; batch (a rerun's agent asked for the program as one session to save and run, not a paragraph).

(require rackunit racket/file racket/port racket/system racket/string)

(define dir (make-temporary-directory "bp-session-~a"))
(define (sh cmd)
  (define out (open-output-string))
  (define ok (parameterize ([current-directory dir] [current-output-port out] [current-error-port out]) (system cmd)))
  (values ok (get-output-string out)))
(for ([b+f (in-list '(("BloodPressureRule" . "bp-rule.fsh") ("bad-readings" . "bad.fsh") ("readings-sample" . "readings.fsh")
                      ("bp" . "bp.view.json") ("patients" . "patients.view.json") ("bp-summary-by-name" . "summary.sql")
                      ("bp-session" . "session.txt")))])
  (define-values (ok out) (sh (format "raco fhir guide workspace --block ~a > ~a" (car b+f) (cdr b+f))))
  (check-true ok (format "--block ~a: ~a" (car b+f) out))
  (check-true (> (file-size (build-path dir (cdr b+f))) 0) (cdr b+f)))
(define-values (ok-init _o) (sh "raco fhir-mcp init ws"))
(check-true ok-init)
(define-values (ok out) (sh "raco fhir-mcp batch session.txt --workspace ws"))
(check-true ok out)
;; the rule refused the bad readings (expected), the sample stored, the summary read by name
(check-regexp-match #rx"### [[]failed, as expected[]] !stage fsh=@bad[.]fsh keep:=false" out)
(check-regexp-match #rx"bp-diastolic" out)
(check-regexp-match #rx"\nAlice Abara,2,135[.]0,86[.]5,no\n" out)
(check-regexp-match #rx"### 7 line[(]s[)], 0 failed [(]1 more failed as expected[)]" out)
(delete-directory/files dir)
