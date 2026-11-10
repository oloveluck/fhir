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
(define (errors-of fsh) (hash-ref (car (hash-ref (call "stage" (hasheq 'fsh fsh)) 'changes)) 'errors '()))   ; none: no key

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
    ;; enforce: true lists it (an agent had to edit workspace.yaml by hand); the note is gone, a stage holds to it
    (define w3 (call "write" (hasheq 'path "intake.fsh" 'text "Profile: IntakePatient\nParent: Patient\nId: intake-patient\n* birthDate 1..1\n" 'enforce #t)))
    (check-equal? (hash-ref w3 'enforced) '("Patient: http://example.org/fhir/StructureDefinition/intake-patient"))
    (check-false (hash-ref (call "write" (hasheq 'path "intake.fsh" 'text "Profile: IntakePatient\nParent: Patient\nId: intake-patient\n* birthDate 1..1\n")) 'notes #f))
    (check-regexp-match #rx"birthDate" (string-join (hash-ref (car (hash-ref (call "stage" (hasheq 'fsh "Instance: nob\nInstanceOf: Patient\n")) 'changes)) 'errors) "\n"))
    (check-regexp-match #rx"Observation: http://example.org/fhir/StructureDefinition/bp-rule\n  Patient: http://example.org/fhir/StructureDefinition/intake-patient|Patient: .*intake-patient"
                        (file->string (build-path dir "workspace.yaml")))
    (call "stage" (hasheq 'drop "all"))
    (call "write" (hasheq 'path "intake.fsh" 'text ""))
    (check-equal? (errors-of (bp "ok")) '())
    ;; each refusal says what it found, at the line that wrote it — the failing item by its index, or
    ;; what is missing (a rerun's agent got every component, cut off, at the component's code line)
    (check-equal? (errors-of (bp "kpa" #:sys "20 'kPa'"))
                  '("fsh:7: Observation: bp-systolic: A blood pressure (LOINC 85354-9) has a systolic component (LOINC 8480-6) in mm[Hg] (found component[0].valueQuantity = 20 'kPa')"))
    (check-equal? (errors-of (bp "nodia" #:dia #f))
                  '("fsh:1: Observation: bp-diastolic: A blood pressure (LOINC 85354-9) has a diastolic component (LOINC 8462-4) in mm[Hg] (found no component matching '8462-4')"))
    (check-equal? (errors-of (bp "nosubj" #:subject #f))
                  '("fsh:1: Observation: bp-subject: A blood pressure (LOINC 85354-9) has a subject (found no subject)"))
    ;; `'mmHg'` is not UCUM: a warning at its line (it was refused by the rule alone, unexplained)
    (check-equal? (car (hash-ref (car (hash-ref (call "stage" (hasheq 'fsh (bp "mmhg" #:sys "130 'mmHg'"))) 'changes)) 'warnings))
                  "fsh:7: Observation.component.value[x].code: `mmHg` is not a UCUM unit (mercury is written mm[Hg])")
    ;; EVERY systolic in mm[Hg]: a second one in kPa beside a good one is refused (a rerun found the gap)
    (check-equal? (errors-of (string-append (bp "mixed") "* component[2].code = http://loinc.org#8480-6\n* component[2].valueQuantity = 20 'kPa'\n"))
                  '("fsh:11: Observation: bp-systolic: A blood pressure (LOINC 85354-9) has a systolic component (LOINC 8480-6) in mm[Hg] (found component[2].valueQuantity = 20 'kPa')"))
    ;; a systolic with no unit is there, not missing: its value, at the rule that wrote it (it read
    ;; "found no component[0].valueQuantity matching 'mm[Hg]'", at the instance's header)
    (check-equal? (errors-of (string-append
                              "Instance: nounit\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#85354-9\n"
                              "* subject = Reference(Patient/a)\n* component[0].code = http://loinc.org#8480-6\n"
                              "* component[0].valueQuantity.value = 120\n"
                              "* component[1].code = http://loinc.org#8462-4\n* component[1].valueQuantity = 80 'mm[Hg]'\n"))
                  '("fsh:7: Observation: bp-systolic: A blood pressure (LOINC 85354-9) has a systolic component (LOINC 8480-6) in mm[Hg] (found component[0].valueQuantity = 120 (no unit))"))
    ;; another Observation is not a blood pressure: the rule does not apply
    (check-equal? (errors-of "Instance: a1c\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n* valueQuantity = 6.1 '%'\n") '())
    ;; correcting a stored reading: its FSH, one line changed, staged again
    (call "commit" (hasheq 'stage (hash-ref (call "stage" (hasheq 'fsh (bp "bp-a1"))) 'stage) 'reason "intake"))
    (define-values (fsh _e) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "Observation/bp-a1" 'as "fsh")))
    ;; without the profile staging claims by itself (workspace.yaml's `profiles`): nothing to delete
    (check-false (regexp-match? #rx"meta[.]profile" fsh))
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
(define (errors2 fsh) (string-join (hash-ref (car (hash-ref (call2 "stage" (hasheq 'fsh fsh)) 'changes)) 'errors '()) "\n"))
(with-hub h2
  (lambda ()
    (check-equal? (hash-ref (call2 "write" (hasheq 'path "rules.fsh" 'text cookbook)) 'problems) '())
    (check-equal? (errors2 (hr "ok" 72 "/min" "2025-03-01")) "")
    ;; a refusal quotes what it found, at the rule that wrote it (a rerun's agent had to find the value
    ;; itself, and the line was the instance's header), once (it was listed twice)
    (check-equal? (errors2 (hr "fast" 300 "/min" "2025-03-01"))
                  "fsh:7: Observation: hr-range: A heart rate (LOINC 8867-4) is between 20 and 250 /min (found valueQuantity = 300 '/min')")
    (check-regexp-match #rx"^fsh:6: .*not-future.*[(]found effectiveDateTime = @2999-01-01[)]$"
                        (errors2 (hr "later2" 72 "/min" "2999-01-01")))
    (check-regexp-match #rx"hr-unit" (errors2 (hr "hz" 1.2 "Hz" "2025-03-01")))
    (check-regexp-match #rx"not-future" (errors2 (hr "later" 72 "/min" "2999-01-01")))))
(delete-directory/files dir2)
