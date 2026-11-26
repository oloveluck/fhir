#lang racket/base

;;; change-rules-test.rkt — a stored resource changed by the rules that change it, and data handed
;;; back as an instance of its profile.
;;;
;;; - `stage fsh="Instance: Observation/a1\n* status = #amended"`: the rules are laid over the stored
;;;   resource (after its own: an assignment replaces, `[+]` adds), validated and diffed like any
;;;   stage; the Provenance holds the rules as written. Measured (fhir-examples' edit-bench): the
;;;   whole resource answered is ~500 tokens, the rules that change it 26.
;;; - A problem in the rules is at its line in the text given, not in the text laid together.
;;; - `describe ref=Observation/a1 as=source` of data no commit kept a text for is an Instance OF its
;;;   profile, entries by slice, the profile's fixed values not said — and staged again is unchanged.

(require rackunit racket/file racket/string json
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/tools tool-name tool-run))

(define dir (make-temporary-directory "change-~a"))
(void (init-workspace! dir))
(define h (open-hub dir))
(define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
(define (call name args #:ok? [ok? #t])
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (when ok? (check-false err? (format "~a: ~a" name text)))
  (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)))

(define profile
  (string-append
   "Profile: Pulse\nParent: Observation\nId: pulse\n"
   "* code = http://loinc.org#8867-4\n"
   "* component ^slicing.discriminator.type = #pattern\n"
   "* component ^slicing.discriminator.path = \"code\"\n"
   "* component ^slicing.rules = #open\n"
   "* component contains rest 0..1\n"
   "* component[rest].code = http://loinc.org#40443-4\n"))

(define data
  (string-append
   "Instance: ann\nInstanceOf: Patient\n* name.family = \"Ng\"\n\n"
   "Instance: a1\nInstanceOf: Pulse\n* status = #final\n* subject = Reference(Patient/ann)\n"
   "* effectiveDateTime = \"2024-01-05\"\n* valueQuantity = 72 '/min'\n"
   "* component[rest].valueQuantity = 61 '/min'\n* note.text = \"at rest\"\n"))

(with-hub h
  (lambda ()
    (check-equal? (hash-ref (call "write" (hasheq 'path "pulse.fsh" 'text profile)) 'problems) '())
    ;; stored from a JSON resource, so no commit keeps an FSH text for it
    (define compiled (call "stage" (hasheq 'fsh data 'keep #f)))
    (check-equal? (length (hash-ref compiled 'changes)) 2)
    (define st (call "stage" (hasheq 'fsh data)))
    (call "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "intake"))

    ;; the rules that change it, and nothing else
    (define change "Instance: Observation/a1\n* status = #amended\n* valueQuantity = 75 '/min'\n* note[+].text = \"checked again\"")
    (define c (call "stage" (hasheq 'fsh change)))
    (define ch (car (hash-ref c 'changes)))
    (check-equal? (hash-ref ch 'resource) "Observation/a1")
    (check-equal? (hash-ref ch 'action) "update")
    (check-equal? (sort (map (lambda (p) (car (string-split p ":"))) (hash-ref ch 'changed)) string<?)
                  '("note" "status" "valueQuantity.value"))
    (call "commit" (hasheq 'stage (hash-ref c 'stage) 'reason "second reading"))
    (define now (call "describe" (hasheq 'ref "Observation/a1")))
    (check-equal? (hash-ref now 'status) "amended")
    (check-equal? (map (lambda (n) (hash-ref n 'text)) (hash-ref now 'note)) '("at rest" "checked again"))
    ;; (written by an FSH rule: the UCUM code names the unit, as SUSHI writes it, with no `unit`)
    (check-equal? (hash-ref (car (hash-ref now 'component)) 'valueQuantity)
                  (hasheq 'value 61 'system "http://unitsofmeasure.org" 'code "/min"))
    ;; the Provenance holds what was written: the rules
    (check-equal? (string-trim (call "describe" (hasheq 'ref "Observation/a1" 'as "source"))) change)

    ;; a change kept as a file beside the sources is no source: the workspace checks clean with it
    ;; there (as FSH on its own it is an Instance with no InstanceOf, which broke the project and
    ;; the stage of that very change)
    (display-to-file "Instance: Observation/a1\n* status = #final\n" (build-path dir "fix.fsh"))
    (check-equal? (hash-ref (call "check" (hasheq)) 'errors) 0)
    (check-equal? (hash-ref (car (hash-ref (call "stage" (hasheq 'fsh "Instance: Observation/a1\n* status = #final\n" 'keep #f)) 'changes)) 'action)
                  "would update")
    (delete-file (build-path dir "fix.fsh"))

    ;; a problem in the rules is at its line in the text given
    (define-values (bad err?) ((tool-run (hash-ref tools "stage")) (hasheq 'fsh "Instance: Observation/a1\n* status = #amended\n* statuss = #final")))
    (check-true err?)
    (check-regexp-match #rx"fsh:3:" bad)
    ;; a resource the data does not hold, and a change that restates what it is
    (define-values (none err2?) ((tool-run (hash-ref tools "stage")) (hasheq 'fsh "Instance: Observation/zz\n* status = #final")))
    (check-true err2?)
    (check-regexp-match #rx"Observation/zz is not stored" none)
    (define-values (restated err3?) ((tool-run (hash-ref tools "stage")) (hasheq 'fsh "Instance: Observation/a1\nInstanceOf: Pulse\n* status = #final")))
    (check-true err3?)
    (check-regexp-match #rx"takes rules only" restated)))

;; data with no kept text, handed back as an instance of its profile: a second workspace whose data
;; arrives as JSON
(define dir2 (make-temporary-directory "change2-~a"))
(void (init-workspace! dir2))
(define h2 (open-hub dir2))
(define tools2 (for/hash ([t (in-list (workspace-tools h2))]) (values (tool-name t) t)))
(define (call2 name args)
  (define-values (text err?) ((tool-run (hash-ref tools2 name)) args))
  (check-false err? (format "~a: ~a" name text))
  (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)))
(with-hub h2
  (lambda ()
    (call2 "write" (hasheq 'path "pulse.fsh" 'text profile))
    (define obs
      (hasheq 'resourceType "Observation" 'id "b1" 'status "final"
              'meta (hasheq 'profile (list "http://example.org/fhir/StructureDefinition/pulse"))
              'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "8867-4")))
              'valueQuantity (hasheq 'value 72 'unit "/min" 'system "http://unitsofmeasure.org" 'code "/min")
              'component (list (hasheq 'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "40443-4")))
                                       'valueQuantity (hasheq 'value 61 'unit "/min" 'system "http://unitsofmeasure.org" 'code "/min")))))
    (define st (call2 "stage" (hasheq 'resources (list obs))))
    (call2 "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "loaded"))
    (define text (call2 "describe" (hasheq 'ref "Observation/b1" 'as "source")))
    (check-regexp-match #rx"InstanceOf: Pulse" text)
    (check-regexp-match #rx"[*] component\\[rest\\][.]valueQuantity = 61 '/min'" text)
    (check-false (regexp-match? #rx"8867-4|40443-4|meta[.]profile" text) text)
    ;; and it is the resource: staged again, nothing changes
    (define again (call2 "stage" (hasheq 'fsh text)))
    (check-equal? (hash-ref again 'stage) 'null)))

(delete-directory/files dir)
(delete-directory/files dir2)
