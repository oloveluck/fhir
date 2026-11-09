#lang racket/base

;;; workspace-test.rkt — the nine verbs end to end over a small workspace: a value set in VCL that a
;;; CQL library uses by canonical, a FHIRPath expression, a ViewDefinition, an FSH profile with
;;; examples, a map; data in a directory. Each verb is called as an agent calls it (JSON in, JSON
;;; out). Also: every worked example in learn/ compiles, and every guide links its references.

(require rackunit racket/list racket/string racket/file json
         fhir/mcp/workspace fhir/mcp/verbs
         (only-in fhir/mcp/resources read-resource learn-topics learn-text)
         (only-in fhir/mcp/tools tool-name tool-run)
         (only-in fhir/lang/workspace workspace-support workspace-languages workspace-guide))

(define dir (make-temporary-directory "mcp-ws-~a"))
(define (put! rel text) (make-parent-directory* (build-path dir rel)) (call-with-output-file (build-path dir rel) (lambda (o) (void (write-string text o))) #:exists 'truncate/replace))
(define (obs id pid code) (hasheq 'resourceType "Observation" 'id id 'status "final" 'subject (hasheq 'reference (string-append "Patient/" pid))
                                  'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code code)))))
(put! "workspace.yaml" "fhirVersion: 4.0.1\ncanonical: http://example.org/ws\ndata: data\n")
(for ([r (list (hasheq 'resourceType "Patient" 'id "a" 'birthDate "1960-01-01" 'gender "female")
               (hasheq 'resourceType "Patient" 'id "b" 'birthDate "1970-01-01" 'gender "male")
               (hasheq 'resourceType "Patient" 'id "kid" 'birthDate "2020-01-01")
               (obs "o1" "a" "4548-4") (obs "o2" "b" "1234-5"))])
  (put! (format "data/~a-~a.json" (hash-ref r 'resourceType) (hash-ref r 'id)) (jsexpr->string r)))

(define h (open-hub dir))
(define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
(check-equal? (sort (hash-keys tools) string<?) '("apply" "check" "commit" "describe" "explain" "query" "run" "stage" "write"))
;; call : tool args -> (values jsexpr error?)
(define (call name args)
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (values (string->jsexpr text) err?))
(define (ok name args) (define-values (j e) (call name args)) (check-false e (format "~a: ~a" name (jsexpr->string j))) j)
(define (fails name args) (define-values (j e) (call name args)) (check-true e (format "~a should fail" name)) j)

(with-hub h
  (lambda ()
    ;; ---- write: the file's problems at their lines, in the same call
    (ok "write" (hasheq 'path "hba1c.vcl" 'text "(http://loinc.org)(4548-4; 17856-6)"))
    (define bad (ok "write" (hasheq 'path "Gap.cql" 'text "library Gap version '1'\nusing FHIR version '4.0.1'\ncontext Patient\ndefine \"Gap\": Nope\n")))
    (check-equal? (length (hash-ref bad 'problems)) 1)
    (check-equal? (hash-ref (car (hash-ref bad 'problems)) 'file) "Gap.cql")
    (define gap (string-append "library Gap version '1'\nusing FHIR version '4.0.1'\n"
                               "include FHIRHelpers version '4.0.1' called FHIRHelpers\n"
                               "valueset \"HbA1c\": 'http://example.org/ws/ValueSet/hba1c'\n"
                               "context Patient\n"
                               "define \"Tests\": [Observation: \"HbA1c\"]\n"
                               "define \"Adult\": AgeInYears() >= 18\n"
                               "define \"Gap\": \"Adult\" and not exists \"Tests\"\n"))
    (check-equal? (hash-ref (ok "write" (hasheq 'path "Gap.cql" 'text gap)) 'problems) '())
    (fails "write" (hasheq 'path "../escape.cql" 'text "library X"))
    (fails "write" (hasheq 'path "data/Patient-z.json" 'text "{}"))
    (fails "write" (hasheq 'path "notes.txt" 'text "hello"))

    ;; ---- run: CQL over every patient; the VCL value set is found by its canonical
    (define r1 (ok "run" (hasheq 'path "Gap.cql")))
    (check-equal? (hash-ref r1 'result) "result://r1")
    (check-equal? (hash-ref r1 'total) 3)
    (check-equal? (hash-ref (hash-ref (hash-ref r1 'summary) 'defines) 'Gap) (hasheq 'true 1 'false 2))
    (define by-pid (for/hash ([row (hash-ref r1 'rows)]) (values (hash-ref row 'patient) row)))
    (check-equal? (hash-ref (hash-ref by-pid "a") 'Tests) '("Observation/o1"))
    ;; ---- explain: patient b's Gap, down to the retrieve that read one Observation and kept none
    (define e (ok "explain" (hasheq 'ref "result://r1" 'subject "Patient/b" 'entry "Gap")))
    (check-equal? (hash-ref e 'value) #t)
    (define tests (findf (lambda (u) (equal? (hash-ref u 'define) "Tests")) (hash-ref e 'uses)))
    (check-equal? (hash-ref (car (hash-ref tests 'retrieves)) 'of-type) 1)
    (check-equal? (hash-ref (car (hash-ref tests 'retrieves)) 'found) '())

    ;; ---- the other languages
    (check-equal? (hash-ref (ok "run" (hasheq 'path "hba1c.vcl")) 'total) 2)
    (ok "write" (hasheq 'path "born.fhirpath" 'text "Patient.birthDate"))
    (check-equal? (hash-ref (ok "run" (hasheq 'path "born.fhirpath")) 'total) 3)
    (define fp (ok "query" (hasheq 'language "fhirpath" 'text "Patient.where(gender = 'female').id")))
    (check-equal? (hash-ref (hash-ref fp 'summary) 'nonEmpty) 1)
    (define cq (ok "query" (hasheq 'language "cql" 'text "AgeInYears() > 60")))
    (check-equal? (sort (filter values (map (lambda (row) (and (eq? (hash-ref row 'Query) #t) (hash-ref row 'patient))) (hash-ref cq 'rows))) string<?) '("a"))
    (ok "write" (hasheq 'path "patients.view.json"
                        'text (jsexpr->string (hasheq 'resourceType "ViewDefinition" 'name "patients" 'status "active" 'resource "Patient"
                                                      'select (list (hasheq 'column (list (hasheq 'name "id" 'path "getResourceKey()")
                                                                                          (hasheq 'name "gender" 'path "gender"))))))))
    (define v (ok "run" (hasheq 'path "patients.view.json")))
    (check-equal? (hash-ref v 'columns) '("id" "gender"))
    (check-equal? (hash-ref v 'total) 3)
    (define fsh (ok "write" (hasheq 'path "profiles.fsh"
                                    'text (string-append "Profile: Final\nParent: Observation\nId: final-obs\n* status = #final\n\n"
                                                         "Instance: good\nInstanceOf: Final\n* status = #final\n* code = http://loinc.org#4548-4\n\n"
                                                         "Instance: bad\nInstanceOf: Final\n* status = #preliminary\n* code = http://loinc.org#4548-4\n"))))
    (check-equal? (length (hash-ref fsh 'problems)) 1)
    (check-equal? (hash-ref (car (hash-ref fsh 'problems)) 'line) 13)          ; * status = #preliminary
    (define fx (ok "explain" (hasheq 'ref "profiles.fsh" 'subject "bad")))
    (check-equal? (length (hash-ref fx 'problems)) 1)
    (fails "run" (hasheq 'path "nope.cql"))
    (fails "query" (hasheq 'language "search" 'text "Observation?code=http://loinc.org|4548-4"))   ; files have no search engine

    ;; ---- check: every problem, and the configuration
    (define c (ok "check" (hasheq)))
    (check-equal? (hash-ref c 'errors) 1)
    (check-equal? (hash-ref (hash-ref c 'workspace) 'fhirVersion) "4.0.1")
    (check-true (and (member "Gap.cql" (hash-ref c 'files)) #t))

    ;; ---- describe: results paged, data, what the workspace defines, elements, operations
    (define page (ok "describe" (hasheq 'ref "result://r1" 'offset 1 'limit 1)))
    (check-equal? (length (hash-ref page 'rows)) 1)
    (check-equal? (hash-ref (ok "describe" (hasheq 'ref "Patient/a")) 'birthDate) "1960-01-01")
    (check-equal? (hash-ref (ok "describe" (hasheq 'ref "http://example.org/ws/ValueSet/hba1c")) 'resourceType) "ValueSet")
    (check-equal? (hash-ref (ok "describe" (hasheq 'ref "http://example.org/ws/StructureDefinition/final-obs")) 'type) "Observation")
    (check-equal? (hash-ref (car (ok "describe" (hasheq 'ref "Observation.status"))) 'path) "Observation.status")
    (check-equal? (hash-ref (ok "describe" (hasheq 'ref "$expand")) 'operation) "$expand")
    (check-true (pair? (hash-ref (ok "describe" (hasheq 'ref "hba1c")) 'workspace)))
    (fails "describe" (hasheq 'ref "result://r99"))

    ;; ---- apply: an operation in the workspace's context (the VCL value set by its canonical)
    (define ex (ok "apply" (hasheq 'operation "$expand" 'inputs (hasheq 'url "http://example.org/ws/ValueSet/hba1c"))))
    (check-equal? (length (hash-ref (hash-ref ex 'expansion) 'contains)) 2)

    ;; ---- stage and commit: validated, diffed, then written; the next run sees it
    (define bad-stage (ok "stage" (hasheq 'resources (list (hasheq 'resourceType "Observation" 'id "o9")))))
    (check-true (> (hash-ref bad-stage 'errors) 0))
    (fails "commit" (hasheq 'stage (hash-ref bad-stage 'stage)))
    (define st (ok "stage" (hasheq 'resources (list (obs "o3" "b" "4548-4") (hash-set (obs "o2" "b" "1234-5") 'status "amended")))))
    (check-equal? (map (lambda (c) (hash-ref c 'action)) (hash-ref st 'changes)) '("create" "update"))
    (check-equal? (hash-ref (cadr (hash-ref st 'changes)) 'changed) '("status"))
    (define cm (ok "commit" (hasheq 'stage (hash-ref st 'stage))))
    (check-equal? (length (hash-ref cm 'written)) 2)
    (check-true (file-exists? (build-path dir "data" "Observation-o3.json")))
    (check-equal? (hash-ref (call-with-input-file (build-path dir "data" "Observation-o2.json") read-json) 'status) "amended")
    (define r2 (ok "run" (hasheq 'path "Gap.cql" 'entry "Gap")))
    (check-equal? (hash-ref (hash-ref (hash-ref r2 'summary) 'defines) 'Gap) (hasheq 'false 3))
    (define d (ok "describe" (hasheq 'ref (hash-ref r2 'result) 'against "result://r1")))
    (check-equal? (map (lambda (x) (list (hash-ref x 'key) (hash-ref x 'column) (hash-ref x 'before) (hash-ref x 'after)))
                       (filter (lambda (x) (equal? (hash-ref x 'column) "Gap")) (hash-ref d 'changed)))
                  '(("b" "Gap" #t #f)))
    ;; staging an FSH file's examples: the invalid one blocks the commit
    (define fs (ok "stage" (hasheq 'path "profiles.fsh")))
    (check-equal? (length (hash-ref fs 'changes)) 2)
    (void (fails "commit" (hasheq 'stage (hash-ref fs 'stage))))))

;; ---- learn: each guide links its official references, and its worked example compiles
(for ([t (in-list learn-topics)])
  (define text (learn-text (car t)))
  (check-true (string? text) (car t))
  (check-regexp-match #rx"https?://" text (car t))
  (check-true (and (read-resource (string-append "learn://" (car t))) #t)))
;; every workspace language ships its own guide (its repository's guide.md, tested there), and
;; learn://<id> is that text, not a copy kept here
(for ([id (in-list workspace-languages)])
  (define g (workspace-guide id))
  (check-true (string? g) (format "~a/workspace provides no guide" id))
  (check-equal? (learn-text id) g id))
(check-regexp-match #rx"https://cql.hl7.org/" (learn-text "cql"))
(check-regexp-match #rx"https://hl7.org/fhir/uv/shorthand/" (learn-text "fsh"))
(check-regexp-match #rx"http://hl7.org/fhirpath/N1" (learn-text "fhirpath"))
(check-regexp-match #rx"https://build.fhir.org/ig/FHIR/ig-guidance/vcl.html" (learn-text "vcl"))
(check-regexp-match #rx"mapping-language.html" (learn-text "fml"))
(check-regexp-match #rx"https://sql-on-fhir.org" (learn-text "sql-on-fhir"))
(define extension (hash "fsh" "fsh" "cql" "cql" "fhirpath" "fhirpath" "vcl" "vcl" "fml" "map" "view" "view.json"))
(define examples
  (for*/list ([t (in-list learn-topics)]
              [m (in-list (regexp-match* #px"```(fsh|cql|fhirpath|vcl|fml|view)\n(.*?)```" (learn-text (car t)) #:match-select values))])
    (cons (cadr m) (caddr m))))
(check-equal? (sort (remove-duplicates (map car examples)) string<?) '("cql" "fhirpath" "fml" "fsh" "vcl" "view"))
(with-hub h
  (lambda ()
    (for ([ex (in-list examples)] [i (in-naturals)])
      (define path (format "learn/example~a.~a" i (hash-ref extension (car ex))))
      (define w (ok "write" (hasheq 'path path 'text (cdr ex))))
      (check-equal? (hash-ref w 'problems) '() (format "the ~a example in learn/: ~a" (car ex) (jsexpr->string (hash-ref w 'problems)))))))

(delete-directory/files dir)

;; ---- a data model designed in the workspace: FSH logical models, queried with CQL -------------------
;; Nothing outside the workspace knows this model: workspace.yaml names it, FSH defines its classes,
;; the data is in its own JSON shape, and a CQL library runs over it with `using Clinic`.
(define dir2 (make-temporary-directory "mcp-model-~a"))
(define (put2! rel text) (make-parent-directory* (build-path dir2 rel)) (call-with-output-file (build-path dir2 rel) (lambda (o) (void (write-string text o))) #:exists 'truncate/replace))
(put2! "workspace.yaml" (string-append "fhirVersion: 4.0.1\ncanonical: http://example.org/clinic\ndata: data\n"
                                       "models:\n  Clinic: http://example.org/clinic patient=Member birthDate=born version=1.0\n"))
(for ([r (list (hasheq 'resourceType "Member" 'id "m1" 'born "1960-05-01")
               (hasheq 'resourceType "Member" 'id "m2" 'born "1990-01-01")
               (hasheq 'resourceType "Visit" 'id "v1" 'member (hasheq 'reference "Member/m1")
                       'reason (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "4548-4"))) 'whenDateTime "2025-03-01")
               (hasheq 'resourceType "Visit" 'id "v2" 'member (hasheq 'reference "Member/m2")
                       'reason (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "1234-5")))
                       'whenPeriod (hasheq 'start "2025-04-01T09:00:00Z" 'end "2025-04-01T10:00:00Z")))])
  (put2! (format "data/~a-~a.json" (hash-ref r 'resourceType) (hash-ref r 'id)) (jsexpr->string r)))
(define h2 (open-hub dir2))
(define tools2 (for/hash ([t (in-list (workspace-tools h2))]) (values (tool-name t) t)))
(define (call2 name args) (define-values (text err?) ((tool-run (hash-ref tools2 name)) args)) (values (string->jsexpr text) err?))
(define (ok2 name args) (define-values (j e) (call2 name args)) (check-false e (format "~a: ~a" name (jsexpr->string j))) j)
(with-hub h2
  (lambda ()
    (define w (ok2 "write" (hasheq 'path "clinic.fsh"
                                   'text (string-append "Logical: Member\nId: Member\nTitle: \"Member\"\nDescription: \"A member\"\n"
                                                        "* id 1..1 string \"Key\" \"Key\"\n* born 0..1 date \"Born\" \"Born\"\n\n"
                                                        "Logical: Visit\nId: Visit\nTitle: \"Visit\"\nDescription: \"A visit\"\n"
                                                        "* reason 1..1 CodeableConcept \"Why\" \"Why\"\n"
                                                        "* when[x] 0..1 dateTime or Period \"When\" \"When\"\n"
                                                        "* member 1..1 Reference(Member) \"Who\" \"Who\"\n"))))
    (check-equal? (hash-ref w 'problems) '())
    (ok2 "write" (hasheq 'path "hba1c.vcl" 'text "(http://loinc.org)4548-4"))
    (define lib (string-append "library ClinicGap version '1'\nusing Clinic version '1.0'\n"
                               "valueset \"HbA1c\": 'http://example.org/clinic/ValueSet/hba1c'\ncontext Patient\n"
                               "define \"HbA1c Visits\": [Visit: \"HbA1c\"]\n"
                               "define \"Adult\": AgeInYearsAt(@2025-06-01) >= 18\n"
                               "define \"Gap\": \"Adult\" and not exists \"HbA1c Visits\"\n"
                               "define \"Spans\": [Visit] V where V.\"when\" is Interval<DateTime> return V.\"when\"\n"))
    (check-equal? (hash-ref (ok2 "write" (hasheq 'path "gap.cql" 'text lib)) 'problems) '())
    (define r (ok2 "run" (hasheq 'path "gap.cql")))
    (check-equal? (hash-ref r 'total) 2)                                  ; the members: the model's Patient class
    (define by (for/hash ([row (hash-ref r 'rows)]) (values (hash-ref row 'patient) row)))
    (check-equal? (hash-ref (hash-ref by "m1") 'Gap) #f)
    (check-equal? (hash-ref (hash-ref by "m2") 'Gap) #t)
    (check-equal? (hash-ref (hash-ref by "m1") '|HbA1c Visits|) '("Visit/v1"))
    (check-equal? (length (hash-ref (hash-ref by "m2") 'Spans)) 1)
    ;; explain: the retrieve read the member's one Visit (by the model's relationship) and kept none
    (define e (ok2 "explain" (hasheq 'ref (hash-ref r 'result) 'subject "Member/m2" 'entry "Gap")))
    (check-equal? (hash-ref e 'value) #t)
    (define rt (car (hash-ref (findf (lambda (u) (equal? (hash-ref u 'define) "HbA1c Visits")) (hash-ref e 'uses)) 'retrieves)))
    (check-equal? (list (hash-ref rt 'type) (hash-ref rt 'of-type) (hash-ref rt 'found)) '("Visit" 1 ()))
    ;; a library naming a model nobody installed says so at compile
    (define bad (ok2 "write" (hasheq 'path "nomodel.cql" 'text "library N\nusing Nowhere version '1'\ncontext Patient\ndefine X: [Thing]\n")))
    (check-true (pair? (hash-ref bad 'problems)))
    (void)))
(delete-directory/files dir2)
