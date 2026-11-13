#lang racket/base

;;; export-test.rkt — the text export (mcp/export.rkt): what the store holds as definitions, written
;;; out as text for git, as an agent meets it from the shell:
;;;   1. `init` names the directory (`export: export/`); a commit of definitions writes it — the
;;;      files the commit kept, the author's own text with its comments;
;;;   2. the law: the export, put back as the workspace's files, compiles to what is stored
;;;      ("nothing to commit");
;;;   3. a JSON file of the workspace is kept as it is; a definition no file of the workspace states
;;;      (staged from text given in the call) is written from the resource, one file of its own;
;;;   4. `raco fhir-mcp export --check` is the CI gate: up to date, or what differs (exit 1);
;;;      `raco fhir-mcp export` writes it again and removes what no longer belongs;
;;;   5. the directory is not read back as the workspace's sources.

(require rackunit racket/file racket/port racket/system racket/string racket/list)

(define dir (make-temporary-directory "export-~a"))
(define (sh cmd)
  (define out (open-output-string))
  (define ok (parameterize ([current-directory dir] [current-output-port out] [current-error-port out]) (system cmd)))
  (values ok (get-output-string out)))
(define (save name . lines) (with-output-to-file (build-path dir name) #:exists 'truncate (lambda () (for ([l (in-list lines)]) (displayln l)))))
(define (batch . lines)
  (apply save "session.txt" lines)
  (define-values (_ok out) (sh "raco fhir-mcp batch session.txt --workspace ws"))
  (cdr (regexp-split #rx"(?m:^### )" out)))
(define (exported name) (file->string (build-path dir "ws" "export" name)))
(define (export-names) (sort (for/list ([f (in-directory (build-path dir "ws" "export"))]) (path->string (file-name-from-path* f))) string<?))
(define (file-name-from-path* f) (let-values ([(_b n _d) (split-path f)]) n))

(let-values ([(ok _o) (sh "raco fhir-mcp init ws")]) (check-true ok))
(check-regexp-match #rx"(?m:^export: export/ )" (file->string (build-path dir "ws" "workspace.yaml")))

;; ---- 1. a commit of definitions writes the export: the files it kept -------------------------
(save "guide.yaml" "id: example.clinic" "canonical: http://example.org/clinic" "title: Clinic Guide" "version: 0.1.0"
      "fhirVersion: 4.0.1" "publisher:" "  name: Example Clinic" "description: What the example clinic records about lab results.")
(define lab-lines
  (list "Profile: Lab" "Parent: Observation" "Id: lab" "Title: \"A lab result\""
        "Description: \"A laboratory result of a known patient.\""
        "// a result is always somebody's" "* subject 1..1"
        "" "Instance: ann" "InstanceOf: Patient" "* name.family = \"Lee\"" "* gender = #female"
        "" "Instance: a1c-1" "InstanceOf: lab" "* status = #final" "* code = http://loinc.org#4548-4"
        "* subject = Reference(Patient/ann)" "* valueQuantity = 7.2 '%'"))
(apply save "lab.fsh" lab-lines)
(save "A1c.cql"
      "/* The latest HbA1c of each patient. */" "library A1c version '0.1.0'" "using FHIR version '4.0.1'"
      "include FHIRHelpers version '4.0.1'" "codesystem \"LOINC\": 'http://loinc.org'" "code \"HbA1c\": '4548-4' from \"LOINC\""
      "context Patient" "define \"Tested\": exists [Observation: \"HbA1c\"]")
(save "gender.vcl" "(http://hl7.org/fhir/administrative-gender)(female;male)")
(let ([a (batch "write path=sushi-config.yaml text=@guide.yaml" "write path=lab.fsh text=@lab.fsh" "write path=A1c.cql text=@A1c.cql"
                "write path=gender.vcl text=@gender.vcl"
                "stage path=sushi-config.yaml" "commit stage=latest reason=\"the clinic's first definitions\"")])
  (check-regexp-match #rx"\"export\":\\{\"directory\":\"export/?\",\"files\":4,\"written\":\\[\"A1c.cql\",\"gender.vcl\",\"lab.fsh\",\"sushi-config.yaml\"\\]\\}" (list-ref a 5)))
(check-equal? (export-names) '("A1c.cql" "gender.vcl" "lab.fsh" "sushi-config.yaml"))
;; the author's own text: the comment, the profile and its examples in the one file they wrote
(check-equal? (exported "lab.fsh") (file->string (build-path dir "lab.fsh")))
(check-regexp-match #rx"^/[*] The latest HbA1c of each patient. [*]/\nlibrary A1c version '0.1.0'" (exported "A1c.cql"))
(check-regexp-match #rx"version: 0.1.0" (exported "sushi-config.yaml"))

;; ---- 5. the export is not the workspace's own sources: one Lab, not two -----------------------
(let ([a (batch "check")])
  (check-false (regexp-match? #rx"export/" (car a)) (car a)))

;; ---- 2. the law: the export, put back as the workspace's files, is what is stored -------------
(for ([f (in-list '("sushi-config.yaml" "lab.fsh" "A1c.cql" "gender.vcl"))])
  (delete-file (build-path dir "ws" f))
  (copy-file (build-path dir "ws" "export" f) (build-path dir "ws" f)))
(let ([a (batch "stage path=sushi-config.yaml keep:=false")])
  (check-regexp-match #rx"nothing to commit: the [0-9]+ resource[(]s[)] are stored as they are" (car a)))

;; ---- 3. what no kept file of the workspace states is written from the resource ---------------
;; a published map given as a JSON file of the workspace: that file is the text kept
(save "names.json" "{\"resourceType\": \"StructureMap\", \"id\": \"names\", \"url\": \"http://elsewhere.example/StructureMap/names\","
      " \"version\": \"1.0.0\", \"name\": \"Names\", \"status\": \"active\","
      " \"structure\": [{\"url\": \"http://hl7.org/fhir/StructureDefinition/Patient\", \"mode\": \"source\", \"alias\": \"In\"},"
      "               {\"url\": \"http://hl7.org/fhir/StructureDefinition/Patient\", \"mode\": \"target\", \"alias\": \"Out\"}],"
      " \"group\": [{\"name\": \"names\", \"typeMode\": \"none\","
      "   \"input\": [{\"name\": \"src\", \"type\": \"In\", \"mode\": \"source\"}, {\"name\": \"tgt\", \"type\": \"Out\", \"mode\": \"target\"}],"
      "   \"rule\": [{\"name\": \"gender\","
      "     \"source\": [{\"context\": \"src\", \"element\": \"gender\", \"variable\": \"g\"}],"
      "     \"target\": [{\"context\": \"tgt\", \"contextType\": \"variable\", \"element\": \"gender\", \"transform\": \"copy\", \"parameter\": [{\"valueId\": \"g\"}]}]}]}]}")
(let ([a (batch "write path=names.json text=@names.json" "stage path=names.json" "commit stage=latest reason=\"a published map\"")])
  (check-regexp-match #rx"\"export\":\\{\"directory\":\"export/?\",\"files\":5,\"written\":\\[\"names.json\"\\]\\}" (list-ref a 2)))
(check-equal? (exported "names.json") (file->string (build-path dir "names.json")))
;; a profile staged from a file that is not the workspace's (nothing of the workspace states it):
;; one file of its own, `<Type>-<id>.fsh`, the definition as its commit's text had it
(save "vital.fsh" "Profile: Vital" "Parent: Observation" "Id: vital" "Title: \"A vital sign\""
      "Description: \"A vital sign of a known patient.\"" "// measured, not reported" "* subject 1..1" "* effective[x] 1..1")
(let ([a (batch "stage fsh=@vital.fsh definitions:=true" "commit stage=latest reason=\"vital signs\"")])
  (check-regexp-match #rx"\"export\":\\{\"directory\":\"export/?\",\"files\":6,\"written\":\\[\"StructureDefinition-vital.fsh\"\\]\\}" (list-ref a 1)))
(check-regexp-match #rx"^Profile: Vital\nParent: Observation\nId: vital\n" (exported "StructureDefinition-vital.fsh"))
(check-regexp-match #rx"// measured, not reported\n[*] subject 1[.][.]1\n[*] effective\\[x\\] 1[.][.]1\n" (exported "StructureDefinition-vital.fsh"))

;; a commit of data alone leaves the export as it is
(save "bob.fsh" "Instance: bob" "InstanceOf: Patient" "* name.family = \"Ng\"")
(let ([a (batch "stage fsh=@bob.fsh" "commit stage=latest reason=\"a patient\"")])
  (check-regexp-match #rx"\"written\"" (list-ref a 1))
  (check-false (regexp-match? #rx"\"export\"" (list-ref a 1)) (list-ref a 1)))

;; ---- 4. the CI gate, and writing it again -----------------------------------------------------
(let-values ([(ok out) (sh "raco fhir-mcp export --check --workspace ws")])
  (check-true ok out)
  (check-regexp-match #rx"the export is up to date" out))
;; somebody edits the mirror, and leaves a file of an earlier export behind
(with-output-to-file (build-path dir "ws" "export" "gender.vcl") #:exists 'truncate (lambda () (displayln "(http://hl7.org/fhir/administrative-gender)(female)")))
(with-output-to-file (build-path dir "ws" "export" "old.fsh") (lambda () (displayln "Profile: Old\nParent: Patient")))
(with-output-to-file (build-path dir "ws" ".fhir-mcp" "export.json") #:exists 'truncate
  (lambda () (display "[\"A1c.cql\",\"StructureDefinition-vital.fsh\",\"gender.vcl\",\"lab.fsh\",\"names.json\",\"old.fsh\",\"sushi-config.yaml\"]")))
(with-output-to-file (build-path dir "ws" "export" "README.md") (lambda () (displayln "ours to keep")))
(let-values ([(ok out) (sh "raco fhir-mcp export --check --workspace ws")])
  (check-false ok)
  (check-regexp-match #rx"differs gender.vcl\nstale old.fsh\n" out))
(let-values ([(ok out) (sh "raco fhir-mcp export --workspace ws")])
  (check-true ok out)
  (check-regexp-match #rx"\"removed\":\\[\"old.fsh\"\\]" out)
  (check-regexp-match #rx"\"written\":\\[\"gender.vcl\"\\]" out))
(check-equal? (export-names) '("A1c.cql" "README.md" "StructureDefinition-vital.fsh" "gender.vcl" "lab.fsh" "names.json" "sushi-config.yaml"))   ; a file that was never ours is left
(check-equal? (exported "gender.vcl") "(http://hl7.org/fhir/administrative-gender)(female;male)\n")
(let-values ([(ok out) (sh "raco fhir-mcp export --workspace ws")])
  (check-false (regexp-match? #rx"written|removed" out) out))                 ; written again: nothing to write

(delete-directory/files dir)
