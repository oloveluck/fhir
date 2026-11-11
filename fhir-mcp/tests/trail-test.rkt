#lang racket/base

;;; trail-test.rkt — constraints and the trail, end to end in a workspace made by `init`: a profile
;;; with an invariant (FSH) named in workspace.yaml's `profiles` refuses a stage that breaks it; each
;;; commit leaves a Provenance (the versions, the reason, the source text) and an AuditEvent in the
;;; store; the history of a resource reads back with what changed and why; SQL joins the versions to
;;; their Provenance; `audit: all` records executions; `check(data: true)` holds the store to the rules.

(require rackunit racket/file racket/string json net/base64
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/trail current-agent)
         (only-in fhir/mcp/tools tool-name tool-run) (only-in fhir/mcp/resources learn-text))

(define dir (make-temporary-directory "trail-~a"))
(void (init-workspace! dir))
(void (call-with-output-file (build-path dir "workspace.yaml") #:exists (quote append)
  (lambda (o) (write-string "profiles:\n  Observation: http://example.org/fhir/StructureDefinition/a1c\naudit: all\n" o))))
(define h (open-hub dir))
(define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
(define (call name args #:ok? [ok? #t])
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (when ok? (check-false err? (format "~a: ~a" name text)))
  (string->jsexpr text))
(set-box! current-agent "claude-code 2.0 via fhir-mcp")

(define rules (string-append "Profile: A1c\nParent: Observation\nId: a1c\n* code = http://loinc.org#4548-4\n* subject 1..1\n"
                             "* value[x] only Quantity\n* valueQuantity 1..1\n* obeys a1c-percent\n\n"
                             "Invariant: a1c-percent\nDescription: \"An HbA1c is a percentage\"\nSeverity: #error\n"
                             "Expression: \"value.ofType(Quantity).code = '%'\"\n"))
(define (a1c value unit) (format "Instance: a1\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n* subject = Reference(Patient/ann)\n* valueQuantity = ~a '~a'\n" value unit))

(with-hub h
  (lambda ()
    (check-equal? (hash-ref (call "write" (hasheq 'path "rules.fsh" 'text rules)) 'problems) '())
    ;; the constraint: an HbA1c in mmol/mol breaks the invariant, so the stage cannot commit
    (define bad (call "stage" (hasheq 'fsh (a1c 64 "mmol/mol"))))
    (check-equal? (hash-ref (car (hash-ref bad 'changes)) 'errors) '("fsh:6: Observation: a1c-percent: An HbA1c is a percentage (found valueQuantity.code = mmol/mol)"))
    (call "commit" (hasheq 'stage (hash-ref bad 'stage)) #:ok? #f)
    ;; FSH read from a file (`fsh=@a1c.fsh` on the command line) is named by the file
    (check-equal? (hash-ref (car (hash-ref (call "stage" (hasheq 'fsh (a1c 64 "mmol/mol") 'files (hasheq 'fsh "a1c.fsh"))) 'changes)) 'errors)
                  '("a1c.fsh:6: Observation: a1c-percent: An HbA1c is a percentage (found valueQuantity.code = mmol/mol)"))
    ;; a valid one commits, claims the profile, and leaves a Provenance naming the version and the reason
    (define ok1 (call "stage" (hasheq 'fsh (string-append "Instance: ann\nInstanceOf: Patient\n* gender = #female\n\n" (a1c 8.0 "%")))))
    (define c1 (call "commit" (hasheq 'stage (hash-ref ok1 'stage) 'reason "intake: ann's first HbA1c")))
    (check-regexp-match #rx"^Provenance/" (hash-ref c1 'provenance))
    (define stored (call "describe" (hasheq 'ref "Observation/a1")))
    (check-equal? (hash-ref (hash-ref stored 'meta) 'profile) '("http://example.org/fhir/StructureDefinition/a1c"))
    (define prov (call "describe" (hasheq 'ref (hash-ref c1 'provenance))))
    (check-equal? (sort (map (lambda (t) (hash-ref t 'reference)) (hash-ref prov 'target)) string<?) '("Observation/a1/_history/1" "Patient/ann/_history/1"))
    (check-equal? (hash-ref (hash-ref (car (hash-ref prov 'agent)) 'who) 'display) "claude-code 2.0 via fhir-mcp")
    (define att (hash-ref (car (hash-ref (car (hash-ref prov 'contained)) 'content)) 'attachment))
    (check-regexp-match #rx"valueQuantity = 8.0 '%'" (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (hash-ref att 'data)))))
    ;; the source reads back as text: no base64 to decode by hand
    (let-values ([(text err?) ((tool-run (hash-ref tools "describe")) (hasheq 'ref (hash-ref c1 'provenance) 'as "source"))])
      (check-false err? text)
      (check-regexp-match #rx"^Instance: ann\n" text))
    ;; a resource's own source is its Instance alone, not the file's others
    (let-values ([(own err?) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "Observation/a1" 'as "source"))])
      (check-regexp-match #rx"^Instance: a1\n" own)
      (check-false (regexp-match? #rx"Instance: ann" own)))
    ;; a correction: version 2, its own Provenance
    (call "commit" (hasheq 'stage (hash-ref (call "stage" (hasheq 'fsh (a1c 8.4 "%"))) 'stage) 'reason "lab corrected the value"))
    (define hist (call "describe" (hasheq 'ref "Observation/a1/_history")))
    (check-equal? (map (lambda (v) (list (hash-ref v 'version) (hash-ref v 'changed) (hash-ref v 'reason) (hash-ref v 'agent))) (hash-ref hist 'versions))
                  '(("2" ("valueQuantity.value: 8.0 → 8.4") "lab corrected the value" "claude-code 2.0 via fhir-mcp")
                    ("1" "created" "intake: ann's first HbA1c" "claude-code 2.0 via fhir-mcp")))
    ;; each version names the line of its source that made it: a create the Instance's first line, a
    ;; correction the rule it changed (`* valueQuantity = 8.4 '%'`, line 6, not the header)
    (check-equal? (map (lambda (v) (hash-ref v 'at #f)) (hash-ref hist 'versions)) '("fsh:6" "fsh:10"))   ; v1, a create: its valueQuantity line, where the value is
    ;; staging the original text again would undo the correction: said, with what and why it undoes;
    ;; and the patient stored as it is comes back as a count, not a listed "unchanged" change
    (define again (call "stage" (hasheq 'fsh (string-append "Instance: ann\nInstanceOf: Patient\n* gender = #female\n\n" (a1c 8.0 "%")))))
    (check-equal? (hash-ref again 'unchanged) 1)
    (check-equal? (map (lambda (c) (hash-ref c 'resource)) (hash-ref again 'changes)) '("Observation/a1"))
    (check-regexp-match #rx"puts back version 1's values [(]valueQuantity[.]value[)], undoing version 2 [(]\"lab corrected the value\"[)]"
                        (string-join (hash-ref (car (hash-ref again 'changes)) 'warnings) "\n"))
    (call "stage" (hasheq 'drop (hash-ref again 'stage)))
    ;; and when it was written (an agent needed SQL for the time)
    (check-true (andmap (lambda (v) (regexp-match? #px"^\\d{4}-\\d\\d-\\d\\dT" (hash-ref v 'recorded))) (hash-ref hist 'versions)))
    ;; computing over the trail: every version with the reason it was written, in SQL
    (define q (call "query" (hasheq 'language "sql" 'text (string-append
                                                         "SELECT h.versionId, h.resource ->> '$.valueQuantity.value' AS value, p.resource ->> '$.reason[0].text' AS reason "
                                                         "FROM history h JOIN Provenance p ON EXISTS (SELECT 1 FROM json_each(p.resource, '$.target') t "
                                                         "WHERE t.value ->> '$.reference' = h.type || '/' || h.id || '/_history/' || h.versionId) "
                                                         "WHERE h.type = 'Observation' AND h.id = 'a1' ORDER BY h.versionId"))))
    (check-equal? (hash-ref q 'rows) (list (hasheq 'versionId 1 'value 8 'reason "intake: ann's first HbA1c")
                                           (hasheq 'versionId 2 'value 8.4 'reason "lab corrected the value")))
    ;; FHIR search finds the trail too
    (check-equal? (hash-ref (call "query" (hasheq 'language "search" 'text "Provenance?target=Observation/a1")) 'total) 2)
    ;; audit: all — the SQL query above left an execution AuditEvent beside the two commits'
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT resource ->> '$.action' AS action, count(*) AS n FROM AuditEvent GROUP BY 1 ORDER BY 1")) 'rows)
                  (list (hasheq 'action "C" 'n 1) (hasheq 'action "E" 'n 2) (hasheq 'action "U" 'n 1)))
    ;; the same, from the `trail` view: one row per version a commit wrote, no json_each to write
    (check-regexp-match #rx"^Provenance/" (hash-ref (car (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT provenance FROM trail LIMIT 1")) 'rows)) 'provenance))
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT versionId, reason, agent FROM trail WHERE type = 'Observation' AND id = 'a1' ORDER BY versionId")) 'rows)
                  (list (hasheq 'versionId 1 'reason "intake: ann's first HbA1c" 'agent "claude-code 2.0 via fhir-mcp")
                        (hasheq 'versionId 2 'reason "lab corrected the value" 'agent "claude-code 2.0 via fhir-mcp")))
    ;; trail holds no values: the guide's join with history gives each version's value and reason
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text (cadr (regexp-match #px"```\n(SELECT t.versionId.*?)```" (learn-text "workspace"))))) 'rows)
                  (list (hasheq 'versionId 1 'value 8 'reason "intake: ann's first HbA1c" 'agent "claude-code 2.0 via fhir-mcp" 'recorded (hash-ref (car (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT recorded FROM trail WHERE id = 'a1' AND versionId = 1")) 'rows)) 'recorded))
                        (hasheq 'versionId 2 'value 8.4 'reason "lab corrected the value" 'agent "claude-code 2.0 via fhir-mcp" 'recorded (hash-ref (car (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT recorded FROM trail WHERE id = 'a1' AND versionId = 2")) 'rows)) 'recorded))))
    ;; the guide's view (its JSON, as the guide writes it): values come out through a view
    (call "write" (hasheq 'path "a1c.view.json" 'text (cadr (regexp-match #px"```json\n([{]\"resourceType\": \"ViewDefinition\", \"name\": \"a1c\".*?)```" (learn-text "workspace")))))
    ;; the guide's "each stored value with where it came from": the view joined to its trail row
    (let ([rows (hash-ref (call "query" (hasheq 'language "sql" 'text (cadr (regexp-match #px"```\n(SELECT v.id, v.value.*?)```" (learn-text "workspace"))))) 'rows)])
      (define a1 (findf (lambda (r) (equal? (hash-ref r 'id) "a1")) rows))
      (check-equal? (hash-ref a1 'value) 8.4)
      (check-equal? (hash-ref a1 'reason) "lab corrected the value")
      (check-equal? (hash-ref a1 'agent) "claude-code 2.0 via fhir-mcp"))
    ;; a view over every version (`<view>_history`): a corrected value is a column, no json_each
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT version, value FROM a1c_history WHERE id = 'a1' ORDER BY version")) 'rows)
                  (list (hasheq 'version "1" 'value 8) (hasheq 'version "2" 'value 8.4)))
    ;; the guide's view-history ⋈ trail join: both versions, each with its reason and source line
    (let ([rows (hash-ref (call "query" (hasheq 'language "sql" 'text (cadr (regexp-match #px"```\n(SELECT v.id, CAST.*?)```" (learn-text "workspace"))))) 'rows)])
      (define a1 (filter (lambda (r) (equal? (hash-ref r 'id) "a1")) rows))
      (check-equal? (map (lambda (r) (list (hash-ref r 'version) (hash-ref r 'value) (hash-ref r 'reason))) a1)
                    '((1 8 "intake: ann's first HbA1c") (2 8.4 "lab corrected the value"))))
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT version, value FROM a1c WHERE id = 'a1'")) 'rows)
                  (list (hasheq 'version "2" 'value 8.4)))
    (call "write" (hasheq 'path "a1c.view.json" 'text ""))
    ;; a result says where it came from
    (check-equal? (hash-ref (hash-ref (call "describe" (hasheq 'ref (hash-ref q 'result))) 'source) 'language) "sql")
    ;; the stored data, held to the rules: all of it holds (the trail's own resources included)
    (define cd (hash-ref (call "check" (hasheq 'data #t)) 'data))
    (check-equal? (hash-ref cd 'invalid) 0)
    (check-true (>= (hash-ref cd 'checked) 8))
    ;; the trail of a type, with what each resource says: its subject and value beside who wrote it
    (let-values ([(tr _e) ((tool-run (hash-ref tools "describe")) (hasheq 'ref "Observation" 'as "trail"))])
      (check-regexp-match #rx"\na1,Patient/ann,,8[.]4 %,[^,]*,2," tr))
    ;; a define answering texts is tallied by text (it read {"other": n}), rows in patient order
    (call "write" (hasheq 'path "Above.cql" 'text (string-append "library Above version '1'\nusing FHIR version '4.0.1'\ncontext Patient\n"
                                                               "define \"Above\": if exists [Observation] then 'tested' else 'never tested'\n")))
    (define ab (call "run" (hasheq 'path "Above.cql")))
    (check-true (hash-has-key? (hash-ref (hash-ref ab 'summary) 'defines) 'Above))
    (check-false (hash-has-key? (hash-ref (hash-ref (hash-ref ab 'summary) 'defines) 'Above) 'other))
    (define pts (map (lambda (r) (hash-ref r 'patient)) (hash-ref ab 'rows)))
    (check-equal? pts (sort pts string<?))
    ;; a wide run: the CSV hint suggests the columns a person reads (it named the first three: lists and
    ;; references), and a define answering numbers is summarised by its range and mean ({"other": 2})
    (call "write" (hasheq 'path "Wide.cql" 'text (string-append "library Wide version '1'\nusing FHIR version '4.0.1'\ninclude FHIRHelpers version '4.0.1'\ncontext Patient\n"
                                                              "define \"Results\": [Observation]\n"
                                                              "define \"Latest\": Last(\"Results\")\n"
                                                              "define \"Count\": Count(\"Results\")\n"
                                                              "define \"Tested\": exists \"Results\"\n"
                                                              "define \"Label\": if exists \"Results\" then 'tested' else 'never tested'\n"
                                                              "define \"Twice\": Count(\"Results\") * 2\n")))
    (define wide (call "run" (hasheq 'path "Wide.cql")))
    (check-regexp-match #rx"columns=\"patient,Count,Label,Twice\"" (hash-ref wide 'table))   ; the yes/no flag left out
    (define count-tally (hash-ref (hash-ref (hash-ref wide 'summary) 'defines) 'Count))
    (check-true (and (hash-has-key? count-tally 'min) (hash-has-key? count-tally 'max) (hash-has-key? count-tally 'mean)) (format "~s" count-tally))
    (void (call "write" (hasheq 'path "Wide.cql" 'text "")))
    ;; the CQL guide's latest-value recipe: the hint names the recipe's own table (it left out Name
    ;; and Above 9 for the patient id and a yes/no flag)
    (define recipe (cadr (regexp-match #px"```cql\n(library LatestA1c.*?)```" (learn-text "cql"))))
    (call "write" (hasheq 'path "LatestA1c.cql" 'text recipe))
    (define recipe-run (call "run" (hasheq 'path "LatestA1c.cql")))
    (check-regexp-match #rx"run[(]\"LatestA1c[.]cql\"[)] as=csv columns=\"Name,Latest Number,Latest Unit,Latest Date,Above 9\""
                        (hash-ref recipe-run 'table))
    ;; a Quantity define is summarised as numbers are, with its unit (it read {"other": n})
    (define latest-tally (hash-ref (hash-ref (hash-ref recipe-run 'summary) 'defines) '|Latest Value|))
    (check-true (and (hash-has-key? latest-tally 'quantities) (hash-has-key? latest-tally 'mean) (equal? (hash-ref latest-tally 'unit #f) "%"))
                (format "~s" latest-tally))
    (void (call "write" (hasheq 'path "LatestA1c.cql" 'text "")))
    (void (call "write" (hasheq 'path "Above.cql" 'text "")))))

(delete-directory/files dir)
