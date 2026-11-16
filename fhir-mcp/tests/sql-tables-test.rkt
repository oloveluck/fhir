#lang racket/base

;;; sql-tables-test.rkt — a table defined by a SQL statement over the workspace's views.
;;;
;;; A ViewDefinition reads ONE resource type. A relational schema someone hands you does not: its
;;; `admissions` table has the patient's number, which FHIR keeps on the Patient. So a workspace
;;; file `<name>.sql` is the table `<name>`: one reading statement over the views (and over other
;;; such tables), a join under the column names the schema asks for. Queries then name it as they
;;; name a view, and a query written for that schema runs unchanged.

(require rackunit racket/file racket/string json
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/tools tool-name tool-run)
         (only-in fhir/mcp/resources learn-text guide-block-text))

(define (view name type cols)
  (jsexpr->string
   (hasheq 'resourceType "ViewDefinition" 'name name 'status "active" 'resource type
           'select (list (hasheq 'column (for/list ([c (in-list cols)]) (hasheq 'name (car c) 'path (cdr c))))))))

;; caller : hub -> (name args -> (values answer error?))
(define ((caller h) name args)
  (define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (values (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)) err?))

(define dir (make-temporary-directory "sql-tables-~a"))
(void (init-workspace! dir))
(define h (open-hub dir))
(define call* (caller h))
(define (call name args) (let-values ([(a err?) (call* name args)]) (check-false err? (format "~a: ~a" name a)) a))
(define (refused name args) (let-values ([(a err?) (call* name args)]) (check-true err? (format "~a" a)) (format "~a" a)))
(define (rows sql) (hash-ref (call "query" (hasheq 'language "sql" 'text sql)) 'rows))

(with-hub h
  (lambda ()
    (define st
      (call "stage"
            (hasheq 'fsh
                    (string-append
                     "Instance: ann\nInstanceOf: Patient\n* identifier.value = \"1001\"\n* gender = #female\n\n"
                     "Instance: bob\nInstanceOf: Patient\n* identifier.value = \"1002\"\n* gender = #male\n\n"
                     "Instance: stay1\nInstanceOf: Encounter\n* status = #finished\n* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#IMP\n"
                     "* identifier.value = \"5001\"\n* subject = Reference(Patient/ann)\n"
                     "* period.start = \"2125-01-01T10:00:00-05:00\"\n* period.end = \"2125-01-04T09:30:00-05:00\"\n\n"
                     "Instance: stay2\nInstanceOf: Encounter\n* status = #in-progress\n* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#EMER\n"
                     "* identifier.value = \"5002\"\n* subject = Reference(Patient/bob)\n* period.start = \"2125-03-01T23:50:00-05:00\"\n"))))
    (call "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "intake"))
    ;; the guide's own files (`raco fhir guide tables`): two views, each of one resource with its
    ;; keys, and the table the schema asks for — the admission with its patient's number
    (define guide (learn-text "tables"))
    (call "write" (hasheq 'path "fhir_patients.view.json" 'text (guide-block-text guide "fhir_patients")))
    (call "write" (hasheq 'path "fhir_admissions.view.json" 'text (guide-block-text guide "fhir_admissions")))
    (define written (call "write" (hasheq 'path "admissions.sql" 'text (guide-block-text guide "admissions"))))
    (check-equal? (hash-ref written 'language) "sql")
    (check-equal? (hash-ref written 'problems) '())
    ;; a query written for that schema, as it stands (the guide's)
    (check-true (regexp-match? (regexp-quote "SELECT admissions.hadm_id FROM admissions WHERE admissions.subject_id = 1001 AND admissions.dischtime IS NOT NULL") guide))
    (check-equal? (rows "SELECT admissions.hadm_id FROM admissions WHERE admissions.subject_id = 1001 AND admissions.dischtime IS NOT NULL")
                  (list (hasheq 'hadm_id 5001)))
    (check-equal? (rows "SELECT COUNT(*) AS open FROM admissions WHERE admissions.dischtime IS NULL") (list (hasheq 'open 1)))
    (check-equal? (rows "SELECT strftime('%Y-%m-%d', admittime) AS day FROM admissions ORDER BY 1")
                  (list (hasheq 'day "2125-01-01") (hasheq 'day "2125-03-01"))
                  "the day as the record wrote it: 23:50 at -05:00 is the 1st, not the 2nd of UTC")
    ;; the file runs as any file does, its result named by it
    (define ran (call "run" (hasheq 'path "admissions.sql")))
    (check-equal? (hash-ref ran 'columns) '("subject_id" "hadm_id" "admittime" "dischtime"))
    (check-equal? (hash-ref (hash-ref ran 'summary) 'rows) 2)
    ;; a table defined over another defined table
    (call "write" (hasheq 'path "stays_per_patient.sql" 'text "SELECT subject_id, COUNT(*) AS stays FROM admissions GROUP BY subject_id"))
    (check-equal? (rows "SELECT stays FROM stays_per_patient WHERE subject_id = 1002") (list (hasheq 'stays 1)))
    ;; a commit shows in the table: its views are made again, the table is only a statement
    (define st2 (call "stage" (hasheq 'fsh (string-append "Instance: stay3\nInstanceOf: Encounter\n* status = #finished\n"
                                                           "* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#IMP\n* identifier.value = \"5003\"\n"
                                                           "* subject = Reference(Patient/bob)\n* period.start = \"2125-04-01T08:00:00-05:00\"\n* period.end = \"2125-04-02T08:00:00-05:00\"\n"))))
    (call "commit" (hasheq 'stage (hash-ref st2 'stage) 'reason "second stay"))
    (check-equal? (rows "SELECT stays FROM stays_per_patient WHERE subject_id = 1002") (list (hasheq 'stays 2)))

    ;; ---- what is wrong is said -----------------------------------------------------------------
    ;; not a reading statement: a problem of the file, when it is written
    (define bad (call "write" (hasheq 'path "wipe.sql" 'text "DELETE FROM admissions")))
    (check-regexp-match #rx"wipe.sql:1:1 error: a .sql file defines a table by one SELECT" (car (hash-ref bad 'problems)))
    (call "write" (hasheq 'path "wipe.sql" 'text ""))
    ;; a column its views lack: said when the table is used, naming the table
    (call "write" (hasheq 'path "broken.sql" 'text "SELECT a.shoe_size FROM fhir_admissions a"))
    (check-regexp-match #rx"no such column: a.shoe_size" (refused "query" (hasheq 'language "sql" 'text "SELECT * FROM broken")))
    (call "write" (hasheq 'path "broken.sql" 'text ""))
    ;; one name, one definition
    (call "write" (hasheq 'path "fhir_patients.sql" 'text "SELECT 1 AS x"))
    (check-regexp-match #rx"fhir_patients.sql and a view are both named fhir_patients" (refused "query" (hasheq 'language "sql" 'text "SELECT * FROM admissions")))
    (call "write" (hasheq 'path "fhir_patients.sql" 'text ""))
    (check-equal? (length (rows "SELECT * FROM admissions")) 3)))

(delete-directory/files dir)
