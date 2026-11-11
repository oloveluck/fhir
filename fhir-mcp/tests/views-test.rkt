#lang racket/base

;;; views-test.rkt — what the workspace flattens for SQL is SQL on FHIR, and reads the workspace's
;;; own FHIR version.
;;;
;;; - A view over an R4-only element (MedicationRequest.medicationCodeableConcept; R5/R6 have a
;;;   CodeableReference `medication`) answers it in an R4 workspace: the sql-on-fhir engine is built
;;;   over the R6 tower, and loading it used to replace R4's types by name, so the column was empty.
;;; - `trail` is the trail ViewDefinition's rows (views.rkt) over the Provenances: after a view has
;;;   loaded the engine, the R4 `reason` is still read, and the SHA-1 is its own element and column.
;;; - `describe … as=trail` joins view tables (values, names, trail).

(require rackunit racket/file racket/string json
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/tools tool-name tool-run)
         (only-in fhir/mcp/views trail-view values-view)
         (only-in fhir/mcp/trail text-sha1))

(define dir (make-temporary-directory "views-~a"))
(void (init-workspace! dir))
(define h (open-hub dir))
(define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
(define (call name args #:ok? [ok? #t])
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (when ok? (check-false err? (format "~a: ~a" name text)))
  (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)))

(define meds.view
  (jsexpr->string
   (hasheq 'resourceType "ViewDefinition" 'name "meds" 'status "active" 'resource "MedicationRequest"
           'select (list (hasheq 'column (list (hasheq 'name "id" 'path "getResourceKey()")
                                               (hasheq 'name "drug" 'path "medicationCodeableConcept.coding.first().code")))))))
(define fsh (string-append
             "Instance: ann\nInstanceOf: Patient\n* name.given = \"Ann\"\n* name.family = \"Ng\"\n\n"
             "Instance: rx1\nInstanceOf: MedicationRequest\n* status = #active\n* intent = #order\n"
             "* subject = Reference(Patient/ann)\n* medicationCodeableConcept = http://www.nlm.nih.gov/research/umls/rxnorm#860975\n"))

(with-hub h
  (lambda ()
    (check-equal? (hash-ref (call "write" (hasheq 'path "meds.view.json" 'text meds.view)) 'problems) '())
    (define st (call "stage" (hasheq 'fsh fsh)))
    (call "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "intake"))
    ;; the R4 element, read through the view (it was null: R6 types had replaced R4's)
    (define rows (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT id, drug FROM meds")) 'rows))
    (check-equal? rows (list (hasheq 'id "rx1" 'drug "860975")))
    ;; the trail, from its ViewDefinition, after the engine loaded: reason (R4), source and SHA-1 apart
    (define trail (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT type, id, versionId, reason, source, sha1 FROM trail ORDER BY type")) 'rows))
    (check-equal? (map (lambda (r) (list (hash-ref r 'type) (hash-ref r 'id) (hash-ref r 'versionId) (hash-ref r 'reason))) trail)
                  '(("MedicationRequest" "rx1" 1 "intake") ("Patient" "ann" 1 "intake")))
    (check-equal? (hash-ref (car trail) 'source) "FSH written in the stage")
    (check-equal? (hash-ref (car trail) 'sha1) (text-sha1 fsh))
    ;; a resource is answered in FHIR's element order (status, intent, medication…, subject), not by name
    (let-values ([(text _e) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "MedicationRequest/rx1"))])
      (check-regexp-match #rx"^[{]\"resourceType\":\"MedicationRequest\",\"id\":\"rx1\".*\"status\".*\"intent\".*\"medicationCodeableConcept\".*\"subject\"" text))
    ;; describe as=trail: the type's values view joined to the names and the trail
    (define csv (call "describe" (hasheq 'ref "MedicationRequest" 'as "trail")))
    (check-regexp-match #rx"^id,subject,name,date,versionId,recorded,agent,reason,source,at,provenance\n" csv)
    (check-regexp-match #rx"\nrx1,Patient/ann,Ann Ng,,1,[^,]+,[^,]*,intake,FSH written in the stage,fsh:6,Provenance/" csv)))

;; the views themselves are data: ViewDefinitions a reader can take away
(check-equal? (hash-ref (trail-view "4.0.1") 'resource) "Provenance")
(check-equal? (hash-ref (values-view "Observation" (lambda (e) (memq e '(value)))) 'name) "observation_values")
(delete-directory/files dir)

;; called from the folder above the workspace (`--workspace ws`), the trail's source and line read from
;; there: `data.fsh:5`, a file that opens, not the workspace's `../data.fsh:5`
(let ()
  (define top (make-temporary-directory "views-top-~a"))
  (define ws (build-path top "ws"))
  (make-directory ws)
  (void (init-workspace! ws))
  (define fsh "Instance: p1\nInstanceOf: Patient\n* gender = #male\n\nInstance: o1\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n* subject = Reference(Patient/p1)\n* valueQuantity = 6.4 '%'\n")
  (with-output-to-file (build-path top "data.fsh") (lambda () (display fsh)))
  (define h2 (open-hub ws))
  (define tools2 (for/hash ([t (in-list (workspace-tools h2))]) (values (tool-name t) t)))
  (define (call2 name args) (let-values ([(text _e) ((tool-run (hash-ref tools2 name)) args)]) text))
  (parameterize ([current-directory top])
    (with-hub h2
      (lambda ()
        (define st (string->jsexpr (call2 "stage" (hasheq 'fsh fsh 'files (hasheq 'fsh "data.fsh")))))
        (call2 "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "intake"))
        (define csv (call2 "describe" (hasheq 'ref "Observation" 'as "trail")))
        ;; the value's own line (valueQuantity, line 10), from here
        (check-regexp-match #rx"\no1,Patient/p1,,6[.]4 %,[^,]*,1,[^,]+,[^,]*,intake,data[.]fsh,data[.]fsh:10," csv)
        ;; the history answers the same form (it said `../data.fsh` beside the CSV's `data.fsh`)
        (define v (car (hash-ref (string->jsexpr (call2 "describe" (hasheq 'ref "Observation/o1/_history"))) 'versions)))
        (check-equal? (list (hash-ref v 'source) (hash-ref v 'at)) '("data.fsh" "data.fsh:10")))))
  (parameterize ([current-directory ws])
    (with-hub h2
      (lambda ()
        ;; from the workspace itself, the trail's own form
        (check-regexp-match #rx",[.][.]/data[.]fsh,[.][.]/data[.]fsh:10," (call2 "describe" (hasheq 'ref "Observation" 'as "trail"))))))
  (delete-directory/files top))
