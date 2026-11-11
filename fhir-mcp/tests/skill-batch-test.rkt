#lang racket/base

;;; skill-batch-test.rkt — the fhir skill's whole-session batch runs as written, from the folder above
;;; the workspace: the recipe saved by --block, written, the data staged and committed, the table
;;; with latest and ever side by side, and the trail whose files open from there (two rerun agents
;;; asked for the batch first; one opened `../patients.fsh` from the wrong folder).

(require rackunit racket/file racket/port racket/system racket/string)

(define skill (file->string (collection-file-path "../.claude/skills/fhir/SKILL.md" "fhir")))
(define block (cadr (regexp-match #px"The whole cohort session[^`]*```sh\n(.*?)```" skill)))
(define dir (make-temporary-directory "skill-batch-~a"))
(define patients (string-append
                  "Instance: maria\nInstanceOf: Patient\n* name.given = \"Maria\"\n* name.family = \"Lopez\"\n\n"
                  "Instance: maria-a1\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n"
                  "* subject = Reference(Patient/maria)\n* effectiveDateTime = \"2025-01-10\"\n* valueQuantity = 9.6 '%'\n\n"
                  "Instance: maria-a2\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#4548-4\n"
                  "* subject = Reference(Patient/maria)\n* effectiveDateTime = \"2025-06-02\"\n* valueQuantity = 8.9 '%'\n"))
(with-output-to-file (build-path dir "patients.fsh") (lambda () (display patients)))
(define out
  (parameterize ([current-directory dir])
    (check-true (parameterize ([current-output-port (open-output-nowhere)]) (system "raco fhir-mcp init ws")))
    (with-output-to-string (lambda () (check-true (system block))))))
(check-regexp-match #rx"Name,Latest Result,Latest Date,Above 9,Ever Above 9\nMaria Lopez,8[.]9 %,2025-06-02,no,yes" out)
(check-regexp-match #rx"\nmaria-a1,Patient/maria,Maria Lopez,9[.]6 %,2025-01-10,1,[^,]+,clinic intake desk,intake,patients[.]fsh,patients[.]fsh:12," out)
(check-regexp-match #rx"### 5 line[(]s[)], 0 failed" out)
;; the skill's inline SQL line, as written (column names escaped, a boolean as 1), laid out by --indent
(define sql-line (cadr (regexp-match #px"```\n(query language=sql text=\"SELECT [^\n]*)\n```" skill)))
(with-output-to-file (build-path dir "q.txt") (lambda () (displayln sql-line)))
(define out2
  (parameterize ([current-directory dir])
    (with-output-to-string (lambda () (check-true (system "raco fhir-mcp batch q.txt --workspace ws --indent"))))))
(check-regexp-match #rx"\"rows\": \\[\\]" out2)                ; Maria's latest is 8.9: nobody above 9, and she has one
(check-regexp-match #rx"\n  \"columns\": \\[\"Name\"\\]" out2)
(delete-directory/files dir)
