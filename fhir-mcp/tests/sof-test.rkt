#lang racket/base

;;; sof-test.rkt — a view written as source text in a workspace.
;;;
;;; sql-on-fhir's source language (its LANGUAGE.md: `SELECT … FROM Patient WHERE …`, SQL's clauses
;;; with FHIRPath between them) compiles to a ViewDefinition. A workspace file ending `.sof` is a
;;; view as a `*.view.json` file is: written and checked with its problems at their lines and
;;; columns, run, and a table in SQL under the file's name. An ad-hoc `query` of language `view`
;;; takes the text too.

(require rackunit racket/file racket/string json
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/tools tool-name tool-run)
         (only-in fhir/lang/workspace workspace-language-of))

(define ((caller h) name args)
  (define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (values (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)) err?))

(define dir (make-temporary-directory "sof-~a"))
(void (init-workspace! dir))
(define h (open-hub dir))
(define call* (caller h))
(define (call name args) (let-values ([(a err?) (call* name args)]) (check-false err? (format "~a: ~a" name a)) a))
(define (rows sql) (hash-ref (call "query" (hasheq 'language "sql" 'text sql)) 'rows))

(define contacts
  (string-append "-- one row for each way of reaching a patient; a patient with none keeps one row\n"
                 "CREATE VIEW contacts WITH (status = 'active') AS\n"
                 "SELECT getResourceKey() AS id, name.family.first() AS family,\n"
                 "       (SELECT system, value FROM telecom OR NULL)\n"
                 "FROM Patient\n"))

(check-equal? (workspace-language-of "contacts.sof") "sql-on-fhir")

(with-hub h
  (lambda ()
    (define st
      (call "stage"
            (hasheq 'fsh
                    (string-append
                     "Instance: ann\nInstanceOf: Patient\n* name.family = \"Lee\"\n* gender = #female\n"
                     "* telecom[0].system = #phone\n* telecom[0].value = \"555-0100\"\n\n"
                     "Instance: bob\nInstanceOf: Patient\n* name.family = \"Ortiz\"\n* gender = #male\n"))))
    (call "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "intake"))
    ;; written: a view, with no problem
    (define written (call "write" (hasheq 'path "contacts.sof" 'text contacts)))
    (check-equal? (hash-ref written 'language) "sql-on-fhir")
    (check-equal? (hash-ref written 'problems) '())
    ;; run: its rows, in column order
    (define ran (call "run" (hasheq 'path "contacts.sof")))
    (check-equal? (hash-ref ran 'columns) '("id" "family" "system" "value"))
    (check-equal? (hash-ref ran 'rows)
                  (list (hasheq 'id "ann" 'family "Lee" 'system "phone" 'value "555-0100")
                        (hasheq 'id "bob" 'family "Ortiz" 'system 'null 'value 'null)))
    ;; a table in SQL, under the file's name (and the view's)
    (check-equal? (rows "SELECT family, count(value) AS ways FROM contacts GROUP BY family ORDER BY family")
                  (list (hasheq 'family "Lee" 'ways 1) (hasheq 'family "Ortiz" 'ways 0)))
    ;; asked once, without a file
    (define asked (call "query" (hasheq 'language "view" 'text "SELECT id, gender FROM Patient WHERE gender = 'female'")))
    (check-equal? (hash-ref asked 'rows) (list (hasheq 'id "ann" 'gender "female")))
    ;; problems at their lines and columns: an element the type lacks, and a text that is no statement
    (define typo (call "write" (hasheq 'path "typo.sof" 'text "CREATE VIEW typo WITH (status = 'active') AS\nSELECT id,\n  nmae.family AS family\nFROM Patient\n")))
    (check-equal? (hash-ref typo 'problems) '("typo.sof:3:3 error: no element Patient.nmae (did you mean `name`?)"))
    (define unnamed (call "write" (hasheq 'path "unnamed.sof" 'text "SELECT id,\n  name.family\nFROM Patient\n")))
    (check-equal? (hash-ref unnamed 'problems) '("unnamed.sof:2:3 error: this column needs a name: write `name.family AS <name>`"))))

(delete-directory/files dir)
