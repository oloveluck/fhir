#lang racket/base

;;; sql-cli-test.rkt — `raco fhir-server sql <store> "SELECT …"`: a store a capability app (or `load`)
;;; wrote, read without sqlite3 or a workspace (a new user had to find the schema in the source).

(require rackunit racket/file racket/system racket/port racket/string
         (only-in fhir/store/fhir-sqlite open-fhir-store)
         (only-in fhir/store/fhir-engine fhir-create! fhir-update!))

(define db (make-temporary-file "sql-cli-~a.db"))
(delete-file db)
(define store (open-fhir-store db))
(define-values (_t id _v) (fhir-create! store (hasheq 'resourceType "Patient" 'gender "female" 'name (list (hasheq 'family "Ng")))))
(void (fhir-update! store (hasheq 'resourceType "Patient" 'id id 'gender "male")))

(define (sql text)
  (define out (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port out])
                 (system*/exit-code (find-executable-path "raco") "fhir-server" "sql" (path->string db) text)))
  (values code (get-output-string out)))

(let-values ([(code out) (sql "SELECT resource ->> '$.gender' AS gender, versionId FROM Patient")])
  (check-equal? code 0 out)
  (check-equal? out "gender,versionId\nmale,2\n"))
(let-values ([(code out) (sql "SELECT versionId, resource ->> '$.gender' AS g FROM history WHERE type = 'Patient' ORDER BY versionId")])
  (check-equal? out "versionId,g\n1,female\n2,male\n"))
(let-values ([(code out) (sql "DELETE FROM fhir_resources")])
  (check-equal? code 2)
  (check-regexp-match #rx"one SELECT" out))
(delete-file db)
