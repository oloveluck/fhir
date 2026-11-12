#lang racket/base

;;; artifacts-test.rkt — a workspace's definitions through stage and commit, as CRMI's artifact
;;; repository holds them (mcp/artifacts.rkt; the fhir repo's docs/store-as-codebase.md). One
;;; workspace, the shell route, in the order an author works:
;;;   1. staging the guide (`stage path=sushi-config.yaml`) stages the collection — the guide, what
;;;      its files define, their examples — each definition held to CRMI's Shareable profile: a
;;;      missing title or description is refused, saying where it is written; the version, status,
;;;      experimental flag and publisher are the guide's; a CQL library and a VCL value set get
;;;      their title and description from their name and leading comment;
;;;   2. the commit writes them with the trail, as data;
;;;   3. the lifecycle (CRMI 3.1): draft to active; an active artifact's content does not change and
;;;      it does not go back to draft;
;;;   4. another version begins: the released one is kept as an instance of its own, and a stored
;;;      example the new rule no longer accepts refuses the stage;
;;;   5. with the working files gone the store answers: data is held to the ACTIVE version, a
;;;      canonical means it, `|version` another, and the stored artifacts validate;
;;;   6. definitions need a guide; `definitions:=true` stages one file's own;
;;;   7. the authoring rules are for what the workspace's languages wrote: a definition given as
;;;      JSON (somebody's published artifact) is staged as it is, with or without a guide.

(require rackunit racket/file racket/port racket/system racket/string)

(define dir (make-temporary-directory "artifacts-~a"))
(define (sh cmd)
  (define out (open-output-string))
  (define ok (parameterize ([current-directory dir] [current-output-port out] [current-error-port out]) (system cmd)))
  (values ok (get-output-string out)))
(define (save name . lines) (with-output-to-file (build-path dir name) #:exists 'truncate (lambda () (for ([l (in-list lines)]) (displayln l)))))
;; batch : line … -> (listof answer)   the calls run in one process; each answer under its `### ` line
(define (batch . lines)
  (apply save "session.txt" lines)
  (define-values (_ok out) (sh "raco fhir-mcp batch session.txt --workspace ws"))
  (cdr (regexp-split #rx"(?m:^### )" out)))

(define-values (ok-init _o) (sh "raco fhir-mcp init ws"))
(check-true ok-init)

(define (guide #:version [version "0.1.0"] #:status [status #f] #:description? [description? #t])
  (apply save "guide.yaml"
         (append (list "id: example.clinic" "canonical: http://example.org/clinic" "title: Clinic Guide"
                       (format "version: ~a" version) "fhirVersion: 4.0.1"
                       "publisher:" "  name: Example Clinic"
                       "global:" "  Observation: http://example.org/clinic/StructureDefinition/lab")
                 (if status (list (format "status: ~a" status)) '())
                 (if description? (list "description: What the example clinic records about lab results.") '()))))
(define (lab #:description? [description? #t] #:dated? [dated? #f])
  (apply save "lab.fsh"
         (append (list "Profile: Lab" "Parent: Observation" "Id: lab" "Title: \"A lab result\"")
                 (if description? (list "Description: \"A laboratory result of a known patient.\"") '())
                 (list "* subject 1..1")
                 (if dated? (list "* effective[x] 1..1") '())
                 (list "" "Instance: ann" "InstanceOf: Patient" "* name.family = \"Lee\"" "* gender = #female"
                       "" "Instance: a1c-1" "InstanceOf: lab" "* status = #final" "* code = http://loinc.org#4548-4"
                       "* subject = Reference(Patient/ann)")
                 (if dated? (list "* effectiveDateTime = \"2025-03-01\"") '())
                 (list "* valueQuantity = 7.2 '%'"))))
(save "A1c.cql"
      "/* The latest HbA1c of each patient. */" "library A1c version '0.1.0'" "using FHIR version '4.0.1'"
      "include FHIRHelpers version '4.0.1'" "codesystem \"LOINC\": 'http://loinc.org'" "code \"HbA1c\": '4548-4' from \"LOINC\""
      "context Patient" "define \"Tested\": exists [Observation: \"HbA1c\"]")
(save "gender.vcl" "(http://hl7.org/fhir/administrative-gender)(female;male)")
(define writes '("write path=sushi-config.yaml text=@guide.yaml" "write path=lab.fsh text=@lab.fsh"))
(define sd-sql "query language=sql text=\"SELECT id, resource ->> '$.status' AS status, resource ->> '$.version' AS version FROM StructureDefinition ORDER BY id\" as=csv")

;; ---- 1. held to Shareable, with the guide's facts --------------------------------------------
(guide #:description? #f)
(lab #:description? #f)
(let ([a (apply batch (append writes '("write path=A1c.cql text=@A1c.cql" "write path=gender.vcl text=@gender.vcl"
                                       "!stage path=sushi-config.yaml keep:=false")))])
  (define refused (list-ref a 4))
  (check-regexp-match #rx"^[[]failed, as expected[]]" refused)
  (check-regexp-match #rx"ImplementationGuide.description: minimum required = 1, but found 0 [(]add `description:` to sushi-config.yaml[)]" refused)
  (check-regexp-match #rx"StructureDefinition.description: minimum required = 1, but found 0 [(]add `Description: [^)]*` to its FSH[)]" refused)
  ;; what a language has no place for is derived, not refused
  (check-regexp-match #rx"\"action\":\"would create\",\"resource\":\"Library/A1c\"" refused)
  (check-regexp-match #rx"\"action\":\"would create\",\"resource\":\"ValueSet/gender\"" refused))

;; ---- 2. the collection committed, with the trail ---------------------------------------------
(guide)
(lab)
(let ([a (apply batch (append writes
                              (list "stage path=sushi-config.yaml"
                                    "commit stage=latest reason=\"first draft of the clinic guide\" agent=\"guide author\""
                                    sd-sql
                                    "query language=sql text=\"SELECT resource ->> '$.title' AS title, resource ->> '$.description' AS description, resource ->> '$.status' AS status, resource ->> '$.version' AS version, resource ->> '$.publisher' AS publisher FROM Library\" as=csv"
                                    "query language=sql text=\"SELECT type, id, reason FROM trail WHERE type IN ('ImplementationGuide','StructureDefinition','ValueSet') ORDER BY type\" as=csv")))])
  (for ([r (in-list '("ImplementationGuide/example.clinic" "Library/A1c" "Observation/a1c-1" "Patient/ann" "StructureDefinition/lab" "ValueSet/gender"))])
    (check-regexp-match (regexp (format "\"action\":\"create\",\"resource\":\"~a\"" (regexp-quote r))) (list-ref a 2)))
  (check-regexp-match #rx"\"errors\":0" (list-ref a 2))
  (check-regexp-match #rx"\"reason\":\"first draft of the clinic guide\"" (list-ref a 3))
  ;; the guide's status (draft: it states none) and version, not the compiler's defaults
  (check-regexp-match #rx"\nlab,draft,0.1.0\n" (list-ref a 4))
  (check-regexp-match #rx"\nA1c,The latest HbA1c of each patient.,draft,0.1.0,Example Clinic\n" (list-ref a 5))
  (check-regexp-match #rx"ImplementationGuide,example.clinic,first draft of the clinic guide\nStructureDefinition,lab,first draft of the clinic guide\nValueSet,gender,first draft"
                      (list-ref a 6)))

;; ---- 3. the lifecycle ------------------------------------------------------------------------
(guide #:status "active")
(let ([a (batch "write path=sushi-config.yaml text=@guide.yaml" "stage path=sushi-config.yaml"
                "commit stage=latest reason=\"released 0.1.0\"" sd-sql)])
  (check-regexp-match #rx"\"changed\":\\[\"status: [^]]*draft[^]]*active[^]]*\\],\"resource\":\"StructureDefinition/lab\"" (list-ref a 1))
  (check-regexp-match #rx"\nlab,active,0.1.0\n" (list-ref a 3)))
;; active: its content does not change
(lab #:dated? #t)
(let ([a (batch "write path=lab.fsh text=@lab.fsh" "!stage path=sushi-config.yaml keep:=false")])
  (check-regexp-match #rx"StructureDefinition/lab [(]0.1.0[)] is active: its content does not change — a new version is required [(]CRMI 3.1[)]: raise `version` in sushi-config.yaml"
                      (list-ref a 1)))
;; active: no way back to draft
(lab)
(guide #:status "draft")
(let ([a (apply batch (append writes '("!stage path=sushi-config.yaml keep:=false")))])
  (check-regexp-match #rx"ImplementationGuide/example.clinic [(]0.1.0[)] is active: an active artifact does not go back to draft" (list-ref a 2))
  (check-regexp-match #rx"StructureDefinition/lab [(]0.1.0[)] is active: an active artifact does not go back to draft" (list-ref a 2)))

;; ---- 4. another version begins ---------------------------------------------------------------
;; the new rule (a lab result has a date) no longer accepts the stored example: refused, with why
(guide #:version "0.2.0" #:status "draft")
(lab #:dated? #t)
(save "lab-stale-example.fsh" "")      ; (the example in lab.fsh is updated with the rule; the stored one is what fails)
(let* ([text (file->string (build-path dir "lab.fsh"))]
       [stale (regexp-replace #rx"[*] effectiveDateTime = \"2025-03-01\"\n" text "")])
  (with-output-to-file (build-path dir "lab-stale.fsh") #:exists 'truncate (lambda () (display stale))))
(let ([a (batch "write path=sushi-config.yaml text=@guide.yaml" "write path=lab.fsh text=@lab-stale.fsh" "!stage path=sushi-config.yaml keep:=false")])
  (check-regexp-match #rx"\"action\":\"unchanged\",\"errors\":\\[\"Observation.effective\\[x\\]: minimum required = 1, but found 0\"\\],\"resource\":\"Observation/a1c-1\"" (list-ref a 2)))
(let ([a (batch "write path=lab.fsh text=@lab.fsh" "stage path=sushi-config.yaml"
                "commit stage=latest reason=\"0.2.0 begins: a lab result has a date\"" sd-sql
                "query language=sql text=\"SELECT id, resource ->> '$.status' AS status, resource ->> '$.version' AS version FROM ImplementationGuide ORDER BY id\" as=csv")])
  (check-regexp-match #rx"\"reason\":\"0.2.0 begins: a lab result has a date\"" (list-ref a 2))
  ;; the released version kept as an instance of its own
  (check-regexp-match #rx"\"action\":\"create\",\"resource\":\"StructureDefinition/lab-0.1.0\"" (list-ref a 1))
  (check-regexp-match #rx"\"action\":\"create\",\"resource\":\"ImplementationGuide/example.clinic-0.1.0\"" (list-ref a 1))
  (check-regexp-match #rx"\nlab,draft,0.2.0\nlab-0.1.0,active,0.1.0\n" (list-ref a 3))
  (check-regexp-match #rx"\nexample.clinic,draft,0.2.0\nexample.clinic-0.1.0,active,0.1.0\n" (list-ref a 4)))

;; ---- 5. the store alone ----------------------------------------------------------------------
(for ([f '("sushi-config.yaml" "lab.fsh" "A1c.cql" "gender.vcl")]) (delete-file (build-path dir "ws" f)))
(with-output-to-file (build-path dir "ws" "workspace.yaml") #:exists 'append
  (lambda () (display "profiles:\n  Observation: http://example.org/clinic/StructureDefinition/lab\n")))
(save "nosubject.fsh" "Instance: a1c-9" "InstanceOf: Observation" "* status = #final" "* code = http://loinc.org#4548-4" "* valueQuantity = 8.1 '%'")
(save "nodate.fsh" "Instance: a1c-8" "InstanceOf: Observation" "* status = #final" "* code = http://loinc.org#4548-4"
      "* subject = Reference(Patient/ann)" "* valueQuantity = 8.1 '%'")
(let ([a (batch "!stage fsh=@nosubject.fsh keep:=false"
                "stage fsh=@nodate.fsh keep:=false"
                "describe ref=http://example.org/clinic/StructureDefinition/lab"
                "describe ref=http://example.org/clinic/StructureDefinition/lab|0.2.0"
                "!describe ref=http://example.org/clinic/StructureDefinition/lab|9.9.9"
                "describe ref=StructureDefinition/lab as=fsh"
                "check data:=true")])
  ;; the stored profile still holds the data
  (check-regexp-match #rx"Observation.subject: minimum required = 1, but found 0" (list-ref a 0))
  ;; and it is the ACTIVE version that does (the draft 0.2.0 would want a date)
  (check-regexp-match #rx"\"action\":\"would create\",\"resource\":\"Observation/a1c-8\"\\}\\],\"errors\":0" (list-ref a 1))
  ;; a canonical means the active version; `|version` another
  (check-regexp-match #rx"\"id\":\"lab-0.1.0\"" (list-ref a 2))
  (check-regexp-match #rx"\"id\":\"lab\",.*\"version\":\"0.2.0\"" (list-ref a 3))
  (check-regexp-match #rx"no definition http://example.org/clinic/StructureDefinition/lab\\|9.9.9 in the workspace, the store or the packages" (list-ref a 4))
  ;; a stored definition comes back as text to edit
  (check-regexp-match #rx"Profile: Lab\nParent: Observation\nId: lab\nTitle: \"A lab result\"" (list-ref a 5))
  (check-regexp-match #rx"[*] effective\\[x\\] 1[.][.]" (list-ref a 5))
  ;; everything stored validates, the artifacts included
  (check-regexp-match #rx"\"StructureDefinition\":\\{\"checked\":2,\"invalid\":0\\}" (list-ref a 6))
  (check-regexp-match #rx"\"ImplementationGuide\":\\{\"checked\":2,\"invalid\":0\\}" (list-ref a 6))
  (check-regexp-match #rx"\"invalid\":0,\"problems\":\\[\\]" (list-ref a 6)))

;; ---- 6. definitions need a guide; one file's own ---------------------------------------------
(save "p.fsh" "Profile: Vital" "Parent: Observation" "Id: vital" "Title: \"A vital sign\"" "Description: \"A vital sign.\"" "* subject 1..1")
(let ([a (batch "write path=p.fsh text=@p.fsh" "!stage path=p.fsh definitions:=true" "!stage path=p.fsh")])
  (check-regexp-match #rx"definitions are staged as part of the workspace's implementation guide, whose version is theirs: write sushi-config.yaml" (list-ref a 1))
  (check-regexp-match #rx"nothing to stage|defines no instance" (list-ref a 2)))
(guide #:version "0.3.0")
(let ([a (batch "write path=sushi-config.yaml text=@guide.yaml" "stage path=p.fsh definitions:=true keep:=false")])
  (check-regexp-match #rx"\"action\":\"would create\",\"resource\":\"StructureDefinition/vital\"\\}\\],\"errors\":0" (list-ref a 1)))

;; ---- 7. a definition given as JSON is somebody's: staged as it is ----------------------------
(save "q.json" "{\"resourceType\": \"Questionnaire\", \"id\": \"intake\", \"url\": \"http://elsewhere.example/Questionnaire/intake\","
      " \"version\": \"2.0.0\", \"status\": \"active\", \"item\": [{\"linkId\": \"name\", \"type\": \"string\"}]}")
(let ([a (batch "write path=q.json text=@q.json" "stage path=q.json" "commit stage=latest reason=\"a published questionnaire\""
                "stage path=sushi-config.yaml keep:=false"
                "query language=sql text=\"SELECT id, resource ->> '$.status' AS status, resource ->> '$.version' AS version FROM Questionnaire\" as=csv")])
  ;; no title, description or experimental flag, and active in a draft guide: not this workspace's to hold or to change
  (check-regexp-match #rx"\"action\":\"create\",\"resource\":\"Questionnaire/intake\"\\}\\],\"errors\":0" (list-ref a 1))
  (check-false (regexp-match? #rx"Questionnaire/intake" (list-ref a 3)))        ; unchanged when the guide is staged
  (check-regexp-match #rx"\nintake,active,2.0.0\n" (list-ref a 4)))
;; and in a workspace with no guide at all
(let-values ([(ok _) (sh "raco fhir-mcp init ws2")]) (check-true ok))
(save "session2.txt" "write path=q.json text=@q.json" "stage path=q.json keep:=false")
(let-values ([(_ok out) (sh "raco fhir-mcp batch session2.txt --workspace ws2")])
  (check-regexp-match #rx"\"action\":\"would create\",\"resource\":\"Questionnaire/intake\"\\}\\],\"errors\":0" out))

(delete-directory/files dir)
