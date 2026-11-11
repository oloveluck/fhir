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
    ;; one `profiles:` key in workspace.yaml, init's commented template filled, not a second appended
    (let ([yaml (file->string (build-path dir "workspace.yaml"))])
      (check-equal? (length (regexp-match* #px"(?m:^profiles:)" yaml)) 1 yaml))
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
                  '("fsh:7: Observation: bp-systolic: A blood pressure (LOINC 85354-9) has a systolic component (LOINC 8480-6), a number in mm[Hg] (found component[0].valueQuantity = 20 'kPa')"))
    (check-equal? (errors-of (bp "nodia" #:dia #f))
                  '("fsh:7: Observation: bp-diastolic: A blood pressure (LOINC 85354-9) has a diastolic component (LOINC 8462-4), a number in mm[Hg] (found no component matching '8462-4': add a component with '8462-4' after this line)"))
    (check-equal? (errors-of (bp "nosubj" #:subject #f))
                  '("fsh:1: Observation: bp-subject: A blood pressure (LOINC 85354-9) has a subject (found no subject: add a rule for it, * subject = …)"))
    ;; keep:=false checks only: the same refusal, and no stage left to drop (a refusal shown on purpose
    ;; needed `stage drop=refused` after it)
    (let-values ([(text _e) ((tool-run (hash-ref tools "stage")) (hasheq 'fsh (bp "kpa3" #:sys "20 'kPa'") 'keep #f))])
      (define a (string->jsexpr text))
      (check-equal? (hash-ref a 'stage) 'null)
      (check-equal? (hash-ref a 'errors) 1)
      (check-regexp-match #rx"^checked only" (hash-ref a 'next))
      (check-equal? (hash-ref (car (hash-ref a 'changes)) 'action) "would create")
      ;; checking only, everything to fix is said: the errors and the reference to nothing stored
      (let-values ([(text _e) ((tool-run (hash-ref tools "stage")) (hasheq 'fsh (bp "kpa4" #:sys "20 'kPa'" #:subject "Patient/nobody") 'keep #f))])
        (define a (string->jsexpr text))
        (define c (car (hash-ref a 'changes)))
        (check-equal? (length (hash-ref c 'errors)) 1)
        ;; said once for the stage, not per change
        (check-false (hash-ref c 'warnings #f))
        (check-regexp-match #rx"Patient/nobody" (string-join (hash-ref a 'references '()) " ")))
      (check-false (for/or ([st (in-list (append (hash-ref (call "describe" (hasheq 'ref "stages")) 'stages '())
                                                 (hash-ref (call "describe" (hasheq 'ref "stages")) 'refused '())))])
                     (member "create Observation/kpa3" (hash-ref st 'resources)))))
    ;; `'mmHg'` is not UCUM: a warning at its line (it was refused by the rule alone, unexplained)
    (check-equal? (car (hash-ref (car (hash-ref (call "stage" (hasheq 'fsh (bp "mmhg" #:sys "130 'mmHg'"))) 'changes)) 'warnings))
                  "fsh:7: Observation.component.value[x].code: `mmHg` is not a UCUM unit (mercury is written mm[Hg])")
    ;; EVERY systolic in mm[Hg]: a second one in kPa beside a good one is refused (a rerun found the gap)
    (check-equal? (errors-of (string-append (bp "mixed") "* component[2].code = http://loinc.org#8480-6\n* component[2].valueQuantity = 20 'kPa'\n"))
                  '("fsh:11: Observation: bp-systolic: A blood pressure (LOINC 85354-9) has a systolic component (LOINC 8480-6), a number in mm[Hg] (found component[2].valueQuantity = 20 'kPa')"))
    ;; a blood pressure coded without its system: refused by bp-coded (the other invariants are keyed
    ;; on LOINC's system, and an agent's `#85354-9` with a systolic only went through with a warning);
    ;; the stage still says which system the code's shape suggests
    (let* ([fsh (string-append "Instance: nosys\nInstanceOf: Observation\n* status = #final\n* code = #85354-9\n"
                               "* subject = Reference(Patient/a)\n* component[0].code = http://loinc.org#8480-6\n* component[0].valueQuantity = 150 'mm[Hg]'\n")]
           [a (call "stage" (hasheq 'fsh fsh 'keep #f))]
           [ws (hash-ref (car (hash-ref a 'changes)) 'warnings '())])
      (check-regexp-match #rx"bp-coded: A blood-pressure code 85354-9 names LOINC as its system"
                          (string-join (hash-ref (car (hash-ref a 'changes)) 'errors '()) "\n"))
      (check-regexp-match #rx"code[.]coding[[]0[]]: the code `85354-9` has no system: rules, views and searches matched on its system pass it by — add it [(]a LOINC code: `http://loinc.org`"
                          (string-join ws "\n")))
    ;; a unit with no number is refused too (a rerun's agent staged one: the summary's mean would
    ;; have left the reading out without a word)
    (check-equal? (errors-of (string-append
                              "Instance: nonum\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#85354-9\n"
                              "* subject = Reference(Patient/a)\n* component[0].code = http://loinc.org#8480-6\n"
                              "* component[0].valueQuantity.system = \"http://unitsofmeasure.org\"\n* component[0].valueQuantity.code = #mm[Hg]\n"
                              "* component[1].code = http://loinc.org#8462-4\n* component[1].valueQuantity = 95 'mm[Hg]'\n"))
                  '("fsh:7: Observation: bp-systolic: A blood pressure (LOINC 85354-9) has a systolic component (LOINC 8480-6), a number in mm[Hg] (found component[0].valueQuantity = 'mm[Hg]' (no number))"))
    ;; a systolic with no unit is there, not missing: its value, at the rule that wrote it (it read
    ;; "found no component[0].valueQuantity matching 'mm[Hg]'", at the instance's header)
    (check-equal? (errors-of (string-append
                              "Instance: nounit\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#85354-9\n"
                              "* subject = Reference(Patient/a)\n* component[0].code = http://loinc.org#8480-6\n"
                              "* component[0].valueQuantity.value = 120\n"
                              "* component[1].code = http://loinc.org#8462-4\n* component[1].valueQuantity = 80 'mm[Hg]'\n"))
                  '("fsh:7: Observation: bp-systolic: A blood pressure (LOINC 85354-9) has a systolic component (LOINC 8480-6), a number in mm[Hg] (found component[0].valueQuantity = 120 (no unit))"))
    ;; another Observation is not a blood pressure: the rule does not apply
    (check-equal? (errors-of "Instance: a1c\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n* valueQuantity = 6.1 '%'\n") '())
    ;; the guide's correction recipe starts from the source as written (as=source), not as=fsh
    (check-regexp-match #rx"call describe ref=Observation/bp-a1 as=source > [.][.]/bp-a1[.]fsh" (learn-text "workspace"))
    ;; correcting a stored reading: its FSH, one line changed, staged again
    (call "commit" (hasheq 'stage (hash-ref (call "stage" (hasheq 'fsh (bp "bp-a1"))) 'stage) 'reason "intake"))
    (define-values (fsh _e) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "Observation/bp-a1" 'as "fsh")))
    ;; without the profile staging claims by itself (workspace.yaml's `profiles`): nothing to delete
    (check-false (regexp-match? #rx"meta[.]profile" fsh))
    (define fixed (regexp-replace #rx"150 'mm\\[Hg\\]'" fsh "140 'mm[Hg]'"))
    (check-false (equal? fixed fsh))
    (define st (call "stage" (hasheq 'fsh fixed)))
    (check-equal? (hash-ref (car (hash-ref st 'changes)) 'action) "update")
    (check-equal? (hash-ref (car (hash-ref st 'changes)) 'changed) '("component[0].valueQuantity.value: 150 → 140"))
    ;; the guide's bp view and per-patient summary over three readings (140/95 corrected, 142/90, 138/88)
    (call "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "typo"))
    (call "commit" (hasheq 'stage (hash-ref (call "stage" (hasheq 'fsh (string-append (bp "bp-a2" #:sys "142 'mm[Hg]'" #:dia "90 'mm[Hg]'") "\n"
                                                                                     (bp "bp-a3" #:sys "138 'mm[Hg]'" #:dia "88 'mm[Hg]'"))))
                                           'stage)))
    (define view (cadr (regexp-match #px"```json\n([{]\"resourceType\": \"ViewDefinition\", \"name\": \"bp\".*?)```" (learn-text "workspace"))))
    (call "write" (hasheq 'path "bp.view.json" 'text view))
    (define summary (cadr (regexp-match #px"```\n((?:-- [^\n]*\n)*SELECT patient, count.*?)```" (learn-text "workspace"))))
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text summary)) 'rows)
                  (list (hasheq 'patient "a" 'readings 3 'mean_systolic "140.0" 'mean_diastolic "91.0" 'at_or_above_140_90 "yes")))
    ;; the guide's RuleSet for many readings: one line each, held to the rule, each version's trail at
    ;; its line; the trail's value reads a blood pressure's components (it was empty)
    ;; the guide's whole readings.fsh, staged as it is (its ids renamed: bp-a1 is this test's own)
    (define readings (string-replace (cadr (regexp-match #px"```fsh\n(RuleSet: Reading.*?)```" (learn-text "workspace"))) "bp-a" "bp-r"))
    (define (line-of rx) (for/first ([l (in-list (regexp-split #rx"\n" readings))] [i (in-naturals 1)] #:when (regexp-match? rx l)) i))
    (define rst (call "stage" (hasheq 'fsh readings 'files (hasheq 'fsh "readings.fsh"))))
    (check-equal? (for/list ([c (in-list (hash-ref rst 'changes))]) (list (hash-ref c 'resource) (hash-ref c 'errors '())))
                  '(("Patient/a" ()) ("Observation/bp-r1" ()) ("Observation/bp-r2" ())))
    (call "commit" (hasheq 'stage (hash-ref rst 'stage) 'reason "readings"))
    (define-values (trail-csv _e1) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "Observation/bp-r1/_history" 'as "trail")))
    (check-regexp-match #rx"^id,subject,name,value,date,versionId,recorded,agent,reason,source,at,provenance\n" trail-csv)
    (check-regexp-match (pregexp (format "\nbp-r1,Patient/a,Alice Abara,142 mm\\[Hg\\] / 91 mm\\[Hg\\],2025-01-10,1,[^,]+,[^,]*,readings,[^,]*readings[.]fsh,[^,]*readings[.]fsh:~a,"
                                 (line-of #rx"insert Reading[(]a, 2025-01-10")))
                        trail-csv)   ; its insert line, where the values are
    (define-values (cols-csv _e2) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "Observation" 'as "trail" 'columns "id,value,at" 'sort "-id")))
    (check-regexp-match (pregexp (format "^id,value,at\nbp-r2,128 mm\\[Hg\\] / 82 mm\\[Hg\\],[^,\n]*readings[.]fsh:~a\n" (line-of #rx"insert Reading[(]a, 2025-02-10")))
                        cols-csv)
    ;; the guide's patients view and the summary by name: the table a person reads (the agent wrote
    ;; the view and its name column itself)
    (call "write" (hasheq 'path "patients.view.json"
                          'text (cadr (regexp-match #px"```json\n([{]\"resourceType\": \"ViewDefinition\", \"name\": \"patients\".*?)```" (learn-text "workspace")))))
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text (cadr (regexp-match #px"```\n((?:-- [^\n]*\n)*SELECT p.name, count.*?)```" (learn-text "workspace"))))) 'rows)
                  (list (hasheq 'name "Alice Abara" 'readings 5 'mean_systolic "138.0" 'mean_diastolic "89.2" 'at_or_above_140_90 "no")))
    (void (call "write" (hasheq 'path "patients.view.json" 'text "")))
    ;; the reading's source text stages again: its RuleSet comes with it (it failed: RuleSet not found)
    (define-values (src-text _e3) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "Observation/bp-r1" 'as "source")))
    (check-regexp-match #rx"^RuleSet: Reading[(]" src-text)
    (check-regexp-match #rx"\nInstance: bp-r1\nInstanceOf: Observation\n[*] insert Reading[(]a, 2025-01-10, 142, 91[)]" src-text)
    (define again (call "stage" (hasheq 'fsh (string-replace src-text "142, 91" "141, 91"))))
    (check-equal? (map (lambda (c) (list (hash-ref c 'resource) (hash-ref c 'errors '()))) (hash-ref again 'changes))
                  '(("Observation/bp-r1" ())))
    ;; committed, the correction's `at` is the insert line that changed (it was the Instance header)
    (call "commit" (hasheq 'stage (hash-ref again 'stage) 'reason "typo"))
    (define insert-at (for/first ([l (in-list (regexp-split #rx"\n" src-text))] [i (in-naturals 1)]
                                  #:when (regexp-match? #rx"^[*] insert Reading[(]a, 2025-01-10" l))
                        i))
    (check-regexp-match (pregexp (format ":~a$" insert-at))
                        (hash-ref (car (hash-ref (call "describe" (hasheq 'ref "Observation/bp-r1/_history")) 'versions)) 'at))
    ;; a refused stage is listed apart from those that can be committed, with the call that drops them
    (call "stage" (hasheq 'drop "refused"))                ; the earlier refusals of this test
    (call "stage" (hasheq 'fsh (bp "bp-bad" #:dia #f)))
    (define stages (call "describe" (hasheq 'ref "stages")))
    (check-false (for/or ([st (in-list (hash-ref stages 'stages))]) (member "create Observation/bp-bad" (hash-ref st 'resources))))
    (check-equal? (map (lambda (st) (hash-ref st 'resources)) (hash-ref stages 'refused)) '(("create Observation/bp-bad")))
    (check-regexp-match #rx"drop" (hash-ref stages 'next))
    (check-equal? (length (hash-ref (call "stage" (hasheq 'drop "refused")) 'dropped)) 1)
    (check-false (hash-ref (call "describe" (hasheq 'ref "stages")) 'refused #f))
    (void (call "write" (hasheq 'path "bp.view.json" 'text "")))))
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
    (check-regexp-match #rx"not-future" (errors2 (hr "later" 72 "/min" "2999-01-01")))
    ;; a code without its system: refused by `code-system` (the stage alone only warned of it)
    (check-regexp-match #rx"code-system: Every coding of an observation's code names its code system"
                        (errors2 (string-replace (hr "nosys" 72 "/min" "2025-03-01") "http://loinc.org#8867-4" "#8867-4")))))
(delete-directory/files dir2)

;; in a workspace fresh from init, `enforce` fills init's commented `profiles:` template in place
(let ()
  (define d3 (make-temporary-directory "enforce-~a"))
  (void (init-workspace! d3))
  (define h3 (open-hub d3))
  (define t3 (for/hash ([t (in-list (workspace-tools h3))]) (values (tool-name t) t)))
  (with-hub h3
    (lambda ()
      ((tool-run (hash-ref t3 "write")) (hasheq 'path "r.fsh" 'text "Profile: R\nParent: Patient\nId: r\n* birthDate 1..1\n" 'enforce #t))))
  (define yaml (file->string (build-path d3 "workspace.yaml")))
  (check-equal? (length (regexp-match* #px"(?m:^profiles:)" yaml)) 1 yaml)
  (check-false (regexp-match? #px"(?m:^# profiles:)" yaml) yaml)
  (check-regexp-match #px"(?m:^profiles:.*\n  Patient: http://example.org/fhir/StructureDefinition/r$)" yaml)
  ;; a second profile of a type already listed joins its line (a second `Patient:` line was what YAML
  ;; kept alone, so the first profile was silently no longer enforced), and both hold
  (with-hub h3
    (lambda ()
      ((tool-run (hash-ref t3 "write")) (hasheq 'path "r2.fsh" 'text "Profile: R2\nParent: Patient\nId: r2\n* gender 1..1\n" 'enforce #t))))
  (define yaml2 (file->string (build-path d3 "workspace.yaml")))
  (check-equal? (length (regexp-match* #px"(?m:^  Patient:)" yaml2)) 1 yaml2)
  (check-regexp-match #px"(?m:^  Patient: http://example.org/fhir/StructureDefinition/r http://example.org/fhir/StructureDefinition/r2$)" yaml2)
  (with-hub h3
    (lambda ()
      (define-values (text _e) ((tool-run (hash-ref t3 "stage")) (hasheq 'fsh "Instance: p\nInstanceOf: Patient\n* active = true\n")))
      (define errs (hash-ref (car (hash-ref (string->jsexpr text) 'changes)) 'errors '()))
      (check-true (for/or ([e errs]) (regexp-match? #rx"birthDate" e)) text)
      (check-true (for/or ([e errs]) (regexp-match? #rx"gender" e)) text)))
  (delete-directory/files d3))
