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
    (define w (call "write" (hasheq 'path "rules.fsh" 'text rule)))
    (check-equal? (hash-ref w 'problems) '())
    (check-false (hash-ref w 'notes #f))                                  ; listed in `profiles`: enforced
    ;; a profile workspace.yaml does not list is said to be unenforced (an agent expected it to apply)
    (define w2 (call "write" (hasheq 'path "intake.fsh" 'text "Profile: IntakePatient\nParent: Patient\nId: intake-patient\n* birthDate 1..1\n")))
    (check-equal? (length (hash-ref w2 'notes)) 1)
    (check-regexp-match #rx"^profile IntakePatient [(]http://example.org/fhir/StructureDefinition/intake-patient[)] is not in workspace.yaml's `profiles`.*Patient: http://example.org/fhir/StructureDefinition/intake-patient[)]$"
                        (car (hash-ref w2 'notes)))
    (call "write" (hasheq 'path "intake.fsh" 'text ""))
    (check-equal? (errors-of (bp "ok")) '())
    (check-regexp-match #rx"bp-systolic: A blood pressure" (string-join (errors-of (bp "kpa" #:sys "20 'kPa'")) "\n"))
    (check-regexp-match #rx"bp-diastolic" (string-join (errors-of (bp "nodia" #:dia #f)) "\n"))
    (check-regexp-match #rx"bp-subject" (string-join (errors-of (bp "nosubj" #:subject #f)) "\n"))
    ;; EVERY systolic in mm[Hg]: a second one in kPa beside a good one is refused (a rerun found the gap)
    (check-regexp-match #rx"bp-systolic"
                        (string-join (errors-of (string-append (bp "mixed") "* component[2].code = http://loinc.org#8480-6\n* component[2].valueQuantity = 20 'kPa'\n")) "\n"))
    ;; another Observation is not a blood pressure: the rule does not apply
    (check-equal? (errors-of "Instance: a1c\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n* valueQuantity = 6.1 '%'\n") '())
    ;; correcting a stored reading: its FSH, one line changed, staged again
    (call "commit" (hasheq 'stage (hash-ref (call "stage" (hasheq 'fsh (bp "bp-a1"))) 'stage) 'reason "intake"))
    (define-values (fsh _e) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "Observation/bp-a1" 'as "fsh")))
    (define fixed (regexp-replace #rx"150 'mm\\[Hg\\]'" fsh "140 'mm[Hg]'"))
    (check-false (equal? fixed fsh))
    (define st (call "stage" (hasheq 'fsh fixed)))
    (check-equal? (hash-ref (car (hash-ref st 'changes)) 'action) "update")
    (check-equal? (hash-ref (car (hash-ref st 'changes)) 'changed) '("component[0].valueQuantity.value: 150 → 140"))))
(delete-directory/files dir)

;; the cookbook's rules: each refuses what it says and lets the rest through
(define cookbook (cadr (regexp-match #px"```fsh\n(Profile: VitalsRules.*?)```" (learn-text "workspace"))))
(define dir2 (make-temporary-directory "vitals-~a"))
(void (init-workspace! dir2))
(void (call-with-output-file (build-path dir2 "workspace.yaml") #:exists 'append
        (lambda (o) (write-string "profiles:\n  Observation: http://example.org/fhir/StructureDefinition/vitals-rules\n" o))))
(define h2 (open-hub dir2))
(define tools2 (for/hash ([t (in-list (workspace-tools h2))]) (values (tool-name t) t)))
(define (call2 name args)
  (define-values (text err?) ((tool-run (hash-ref tools2 name)) args))
  (check-false err? (format "~a: ~a" name text))
  (string->jsexpr text))
(define (hr id value unit date)
  (format "Instance: ~a\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#8867-4\n* subject = Reference(Patient/a)\n* effectiveDateTime = \"~a\"\n* valueQuantity = ~a '~a'\n" id date value unit))
(define (errors2 fsh) (string-join (hash-ref (car (hash-ref (call2 "stage" (hasheq 'fsh fsh)) 'changes)) 'errors) "\n"))
(with-hub h2
  (lambda ()
    (check-equal? (hash-ref (call2 "write" (hasheq 'path "rules.fsh" 'text cookbook)) 'problems) '())
    (check-equal? (errors2 (hr "ok" 72 "/min" "2025-03-01")) "")
    ;; a refusal quotes what it found, at the rule that wrote it (a rerun's agent had to find the value
    ;; itself, and the line was the instance's header), once (it was listed twice)
    (check-equal? (errors2 (hr "fast" 300 "/min" "2025-03-01"))
                  "fsh:7: Observation: hr-range: A heart rate (LOINC 8867-4) is between 20 and 250 /min (found value.ofType(Quantity) = 300 '/min')")
    (check-regexp-match #rx"^fsh:6: .*not-future.*[(]found effective.ofType[(]dateTime[)] = @2999-01-01[)]$"
                        (errors2 (hr "later2" 72 "/min" "2999-01-01")))
    (check-regexp-match #rx"hr-unit" (errors2 (hr "hz" 1.2 "Hz" "2025-03-01")))
    (check-regexp-match #rx"not-future" (errors2 (hr "later" 72 "/min" "2999-01-01")))))
(delete-directory/files dir2)
