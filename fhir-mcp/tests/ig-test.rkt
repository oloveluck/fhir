#lang racket/base

;;; ig-test.rkt — the implementation guide as the seventh workspace language, as its guide says to
;;; use it: the guide's two blocks saved by name, `init`, one batch. What is held:
;;;   - writing sushi-config.yaml is a new configuration: its canonical and its dependencies are the
;;;     workspace's (the answer says so, with the warning about workspace.yaml's own canonical);
;;;   - the guide lists what the other files define, and again after one of them changes;
;;;   - its `global` profile is a constraint: a staged resource of the type that breaks it is refused;
;;;   - the ImplementationGuide is found by its url;
;;;   - `init` keeps the store out of git.

(require rackunit racket/file racket/port racket/system racket/string)

(define dir (make-temporary-directory "ig-session-~a"))
(define (sh cmd)
  (define out (open-output-string))
  (define ok (parameterize ([current-directory dir] [current-output-port out] [current-error-port out]) (system cmd)))
  (values ok (get-output-string out)))
(define (save name text) (with-output-to-file (build-path dir name) #:exists 'truncate (lambda () (display text))))

(for ([b+f (in-list '(("clinic-guide" . "guide.yaml") ("Lab" . "lab.fsh")))])
  (define-values (ok out) (sh (format "raco fhir guide ig --block ~a > ~a" (car b+f) (cdr b+f))))
  (check-true ok (format "--block ~a: ~a" (car b+f) out))
  (check-true (> (file-size (build-path dir (cdr b+f))) 0) (cdr b+f)))
(define-values (ok-init _o) (sh "raco fhir-mcp init ws"))
(check-true ok-init)
(check-regexp-match #rx"(?m:^fhir[.]db$)" (file->string (build-path dir "ws" ".gitignore")))

;; a reading with no subject: the guide's global profile requires one
(save "bad.fsh" "Instance: a1c-2\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n* valueQuantity = 8.1 '%'\n")
;; a second example, written after the guide was first asked
(save "more.fsh" "Instance: a1c-3\nInstanceOf: lab\n* status = #final\n* code = http://loinc.org#4548-4\n* subject = Reference(Patient/ann)\n* valueQuantity = 6.4 '%'\n")
(save "session.txt"
      (string-join '("write path=sushi-config.yaml text=@guide.yaml"
                     "write path=lab.fsh text=@lab.fsh"
                     "check"
                     "run path=sushi-config.yaml"
                     "describe ref=http://example.org/clinic/ImplementationGuide/example.clinic"
                     "!stage fsh=@bad.fsh keep:=false"
                     "write path=more.fsh text=@more.fsh"
                     "run path=sushi-config.yaml as=csv columns=reference,example")
                   "\n"))
(define-values (ok out) (sh "raco fhir-mcp batch session.txt --workspace ws"))
(check-true ok out)
(define answers (cdr (regexp-split #rx"(?m:^### )" out)))
(define (answer n) (list-ref answers n))

;; the guide written: a new configuration, said in the answer
(check-regexp-match #rx"\"canonical\":\"http://example.org/clinic\"" (answer 0))
(check-regexp-match #rx"hl7.fhir.us.core-6.1.0.tgz" (answer 0))
(check-regexp-match #rx"workspace.yaml: canonical http://example.org/fhir differs from sushi-config.yaml's http://example.org/clinic, which is used" (answer 0))
;; before the profile exists, the guide's global rule names nothing — at its line
(check-regexp-match #rx"sushi-config.yaml:[0-9]+:3 error: global: nothing defines the profile http://example.org/clinic/StructureDefinition/lab" (answer 0))
;; the profile written: defined under the guide's canonical, enforced without a note, and the guide's problem gone
(check-regexp-match #rx"\"problems\":\\[\\]" (answer 1))
(check-false (regexp-match? #rx"is not in workspace.yaml's `profiles`" (answer 1)))
(check-regexp-match #rx"\"errors\":0" (answer 2))
;; the guide lists what the files define
(check-regexp-match #rx"\"reference\":\"Observation/a1c-1\",\"name\":\"a1c-1\",\"example\":true,\"profile\":\"http://example.org/clinic/StructureDefinition/lab\"" (answer 3))
(check-regexp-match #rx"\"reference\":\"StructureDefinition/lab\",\"name\":\"A lab result\",\"example\":false" (answer 3))
(check-regexp-match #rx"\"dependsOn\":\\[\"hl7.fhir.us.core#6.1.0\"\\]" (answer 3))
;; and is found by its url
(check-regexp-match #rx"\"resourceType\":\"ImplementationGuide\",\"id\":\"example.clinic\"" (answer 4))
(check-regexp-match #rx"\"uri\":\"http://hl7.org/fhir/us/core/ImplementationGuide/hl7.fhir.us.core\"" (answer 4))
;; its global profile is a constraint on staged data
(check-regexp-match #rx"^[[]failed, as expected[]]" (answer 5))
(check-regexp-match #rx"Observation.subject: minimum required = 1, but found 0" (answer 5))
;; another file changed: the guide is computed again
(check-regexp-match #rx"reference,example\nObservation/a1c-1,true\nObservation/a1c-3,true\nStructureDefinition/lab,false" (answer 7))
(delete-directory/files dir)
