#lang racket/base

;;; bp-rule-test.rkt — the blood-pressure rule learn://workspace gives does what it says: named in
;;; workspace.yaml's `profiles`, it refuses a reading in kPa, one without a diastolic, one without a
;;; subject (each by its own invariant), and lets a valid reading and any other Observation through.

(require rackunit racket/file racket/string json
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/resources learn-text)
         (only-in fhir/mcp/tools tool-name tool-run))

(define rule (cadr (regexp-match #px"```fsh\n(Profile: BloodPressureRule.*?)```" (learn-text "workspace"))))
(define dir (make-temporary-directory "bp-rule-~a"))
(void (init-workspace! dir))
(void (call-with-output-file (build-path dir "workspace.yaml") #:exists 'append
        (lambda (o) (write-string "profiles:\n  Observation: http://example.org/fhir/StructureDefinition/bp-rule\n" o))))
(define h (open-hub dir))
(define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
(define (call name args)
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (check-false err? (format "~a: ~a" name text))
  (string->jsexpr text))

(define (bp id #:subject [subject "Patient/a"] #:sys [sys "150 'mm[Hg]'"] #:dia [dia "95 'mm[Hg]'"])
  (string-append
   (format "Instance: ~a\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#85354-9\n" id)
   (if subject (format "* subject = Reference(~a)\n" subject) "")
   (format "* component[0].code = http://loinc.org#8480-6\n* component[0].valueQuantity = ~a\n" sys)
   (if dia (format "* component[1].code = http://loinc.org#8462-4\n* component[1].valueQuantity = ~a\n" dia) "")))
(define (errors-of fsh) (hash-ref (car (hash-ref (call "stage" (hasheq 'fsh fsh)) 'changes)) 'errors))

(with-hub h
  (lambda ()
    (check-equal? (hash-ref (call "write" (hasheq 'path "rules.fsh" 'text rule)) 'problems) '())
    (check-equal? (errors-of (bp "ok")) '())
    (check-regexp-match #rx"bp-systolic: A blood pressure" (string-join (errors-of (bp "kpa" #:sys "20 'kPa'")) "\n"))
    (check-regexp-match #rx"bp-diastolic" (string-join (errors-of (bp "nodia" #:dia #f)) "\n"))
    (check-regexp-match #rx"bp-subject" (string-join (errors-of (bp "nosubj" #:subject #f)) "\n"))
    ;; another Observation is not a blood pressure: the rule does not apply
    (check-equal? (errors-of "Instance: a1c\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n* valueQuantity = 6.1 '%'\n") '())))
(delete-directory/files dir)
