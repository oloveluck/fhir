#lang racket/base

;;; functions-test.rkt — every function of the table called as a client calls it (through the
;;; server's `answer`, in this process, FHIR 4.0.1): what each answers for a small project in every
;;; language, and how each refuses. tests/cli-test.rkt runs the same server as a process.

(require rackunit racket/file racket/list racket/string json
         "../api/session.rkt" "../api/server.rkt" "../api/functions.rkt")

(define s (open-session))
(define n 0)
;; call : name args -> result | (cons 'error error)
(define (call name args)
  (set! n (add1 n))
  (define reply (answer s (hasheq 'jsonrpc "2.0" 'id n 'method name 'params args)))
  (check-equal? (hash-ref reply 'id) n)
  ;; as a client reads it: through JSON
  (cond [(hash-ref reply 'error #f) => (lambda (e) (cons 'error (string->jsexpr (jsexpr->string e))))]
        [else (string->jsexpr (jsexpr->string (hash-ref reply 'result)))]))
(define (failed? r) (and (pair? r) (eq? (car r) 'error)))
(define (message r) (hash-ref (cdr r) 'message))

(define patient
  (hasheq 'resourceType "Patient" 'id "ann" 'gender "female" 'birthDate "1980-02-28"
          'name (list (hasheq 'family "Lee" 'given '("Ann")))))
(define observation
  (hasheq 'resourceType "Observation" 'id "a1" 'status "final"
          'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "4548-4")))
          'subject (hasheq 'reference "Patient/ann") 'effectiveDateTime "2025-03-01"
          'valueQuantity (hasheq 'value 9.4 'unit "%" 'system "http://unitsofmeasure.org" 'code "%")))
(define data (list patient observation))

(define fsh
  (string-append "Profile: AdultPatient\nParent: Patient\n* birthDate 1..1\n* gender 1..1\n\n"
                 "Instance: ann\nInstanceOf: AdultPatient\n* name.family = \"Lee\"\n* gender = #female\n"))
(define cql
  (string-append "library A1c version '1.0'\nusing FHIR version '4.0.1'\ninclude FHIRHelpers version '4.0.1'\ncontext Patient\n"
                 "define \"Latest\": Last([Observation] O sort by (effective as dateTime))\n"
                 "define \"Above 9\": (Latest.value as Quantity) > 9 '%'\n"))
(define fml
  (string-append "/// url = \"http://example.org/StructureMap/p2p\"\n/// name = \"p2p\"\n"
                 "uses \"http://hl7.org/fhir/StructureDefinition/Patient\" as source\n"
                 "uses \"http://hl7.org/fhir/StructureDefinition/Patient\" as target\n"
                 "group main(source src : Patient, target tgt : Patient) {\n"
                 "  src.birthDate as b -> tgt.birthDate = b;\n  src.gender as g -> tgt.gender = g;\n}\n"))

;; ---- version, functions, guide -------------------------------------------------------------------
(let ([v (call "version" (hasheq))])
  (check-equal? (hash-ref v 'fhirVersion) "4.0.1")
  (check-equal? (hash-ref v 'protocol) protocol-version)
  (check-equal? (hash-ref v 'functions) (map fn-name functions)))
(check-equal? (map (lambda (f) (hash-ref f 'name)) (hash-ref (call "functions" (hasheq)) 'functions)) (map fn-name functions))
(check-not-false (member "cql" (hash-ref (call "guide" (hasheq)) 'topics)))
(check-regexp-match #rx"FHIRPath" (hash-ref (call "guide" (hasheq 'topic "fhirpath")) 'text))
(check-regexp-match #rx"no guide nope" (message (call "guide" (hasheq 'topic "nope"))))

;; ---- fhirpath ------------------------------------------------------------------------------------
(check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "name.given.first() + ' ' + name.family.first()" 'resource patient)) 'values)
              '("Ann Lee"))
(check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "name" 'resource patient)) 'values)
              (list (hasheq 'family "Lee" 'given '("Ann"))))
(check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "birthDate < @1990-01-01" 'resource patient)) 'values) '(#t))
;; a date is the JSON string FHIR writes, a string that begins with @ is itself, a quantity its element
(check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "birthDate | (birthDate + 1 year)" 'resource patient)) 'values) '("1980-02-28" "1981-02-28"))
(check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "'@home'" 'resource patient)) 'values) '("@home"))
(check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "value" 'resource observation)) 'values)
              (list (hasheq 'value 9.4 'unit "%" 'system "http://unitsofmeasure.org" 'code "%")))
(check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "name.count() + 0.5" 'resource patient)) 'values) '(1.5))
(check-regexp-match #rx"no element HumanName.nmae" (message (call "fhirpath" (hasheq 'expression "name.nmae" 'resource patient))))
;; a syntax error has its place
(let ([r (call "fhirpath" (hasheq 'expression "name.(" 'resource patient))])
  (check-true (failed? r))
  (check-equal? (hash-ref (car (hash-ref (hash-ref (cdr r) 'data) 'diagnostics)) 'lang) "fhirpath"))

;; ---- compile: FSH with an example that breaks its profile, at its line, in the caller's file -----
(let* ([r (call "compile" (hasheq 'files (hasheq 'p.fsh fsh)))]
       [d (car (hash-ref r 'diagnostics))])
  (check-equal? (map (lambda (x) (hash-ref x 'resourceType)) (hash-ref r 'resources)) '("StructureDefinition" "Patient"))
  (check-equal? (hash-ref (car (hash-ref r 'resources)) 'url) "http://example.org/StructureDefinition/AdultPatient")
  (check-equal? (list (hash-ref d 'source) (hash-ref d 'line) (hash-ref d 'severity)) '("p.fsh" 6 "error"))
  (check-regexp-match #rx"Patient.birthDate: minimum required = 1" (hash-ref d 'message)))
;; the canonical a caller names; a file in a folder
(check-equal? (hash-ref (car (hash-ref (call "compile" (hasheq 'files (hasheq 'fsh/p.fsh "Profile: P\nParent: Patient\n") 'canonical "http://clinic.example/fhir")) 'resources)) 'url)
              "http://clinic.example/fhir/StructureDefinition/P")
;; every language in one project: a profile, a library, a map, a value set, a view
(let ([r (call "compile" (hasheq 'files (hasheq 'p.fsh "Profile: P\nParent: Patient\n" 'A1c.cql cql 'p2p.map fml
                                                'sexes.vcl "(http://hl7.org/fhir/administrative-gender)(female;male)"
                                                'pts.sof "CREATE VIEW pts WITH (status = 'active') AS SELECT id, birthDate FROM Patient")))])
  (check-equal? (sort (map (lambda (x) (hash-ref x 'resourceType)) (hash-ref r 'resources)) string<?)
                '("Library" "StructureDefinition" "StructureMap" "ValueSet" "ViewDefinition"))
  (check-equal? (hash-ref r 'diagnostics) '()))

;; ---- validate: the type's own rules, a profile of the project by canonical and by name -----------
(check-regexp-match #rx"code `florp` not in required value set"
                    (hash-ref (car (hash-ref (call "validate" (hasheq 'resource (hasheq 'resourceType "Patient" 'gender "florp"))) 'issue)) 'diagnostics))
(define profile-only (hasheq 'p.fsh "Profile: AdultPatient\nParent: Patient\n* birthDate 1..1\n"))
(for ([named '("AdultPatient" "http://example.org/StructureDefinition/AdultPatient")])
  (define oo (call "validate" (hasheq 'resource (hasheq 'resourceType "Patient" 'gender "female") 'profile named 'files profile-only)))
  (check-equal? (hash-ref (car (hash-ref oo 'issue)) 'expression) '("Patient.birthDate") named))
(check-regexp-match #rx"All OK"
                    (hash-ref (car (hash-ref (call "validate" (hasheq 'resource patient 'profile "AdultPatient" 'files profile-only)) 'issue)) 'diagnostics))
;; a profile nothing defines is the operation's own refusal, with its OperationOutcome
(let ([r (call "validate" (hasheq 'resource patient 'profile "http://example.org/StructureDefinition/Nope"))])
  (check-true (failed? r))
  (check-equal? (hash-ref (hash-ref (hash-ref (cdr r) 'data) 'outcome) 'resourceType) "OperationOutcome"))

;; ---- translate: CQL to ELM, and a mistake at its name ---------------------------------------------
(let ([r (call "translate" (hasheq 'text cql))])
  (check-equal? (hash-ref r 'diagnostics) '())
  (check-equal? (hash-ref (hash-ref (hash-ref (hash-ref r 'elm) 'library) 'identifier) 'id) "A1c"))
(let* ([r (call "translate" (hasheq 'text (string-replace cql "Last(" "Lst(") 'name "A1c.cql"))]
       [d (car (hash-ref r 'diagnostics))])
  (check-equal? (hash-ref r 'elm) 'null)
  (check-equal? (list (hash-ref d 'source) (hash-ref d 'line) (hash-ref d 'column)) '("A1c.cql" 5 18))
  (check-regexp-match #rx"unknown function 'Lst' [(]did you mean `Last`" (hash-ref d 'message)))
;; an include found among the project's own libraries
(let ([r (call "translate" (hasheq 'text "library Uses\nusing FHIR version '4.0.1'\ninclude A1c version '1.0' called A\ncontext Patient\ndefine X: A.\"Above 9\"\n"
                                   'files (hasheq 'A1c.cql cql)))])
  (check-equal? (hash-ref r 'diagnostics) '())
  (check-true (hash? (hash-ref r 'elm))))

;; ---- run, query, explain over data given in the call ----------------------------------------------
(let ([t (call "run" (hasheq 'path "A1c.cql" 'files (hasheq 'A1c.cql cql) 'data data))])
  (check-equal? (hash-ref t 'kind) "patients")
  (check-equal? (hash-ref t 'columns) '("patient" "Latest" "Above 9"))
  (check-equal? (hash-ref t 'rows) (list (hasheq 'patient "ann" 'Latest "Observation/a1" '|Above 9| #t))))
;; the same library over other data, with no recompiling in between: the answer follows the data
(let ([t (call "run" (hasheq 'path "A1c.cql" 'files (hasheq 'A1c.cql cql)
                             'data (list patient (hash-set observation 'valueQuantity (hasheq 'value 6.1 'unit "%" 'system "http://unitsofmeasure.org" 'code "%")))))])
  (check-equal? (hash-ref (car (hash-ref t 'rows)) '|Above 9|) #f))
(check-equal? (hash-ref (call "query" (hasheq 'language "cql" 'text "AgeInYearsAt(@2026-01-01)" 'data data)) 'rows)
              (list (hasheq 'patient "ann" 'Query 45)))
(check-equal? (hash-ref (call "query" (hasheq 'language "view" 'text "SELECT id, name.family.first() AS family, birthDate FROM Patient" 'data data)) 'rows)
              (list (hasheq 'id "ann" 'family "Lee" 'birthDate "1980-02-28")))
(define views
  (hasheq 'obs.sof "CREATE VIEW obs WITH (status = 'active') AS SELECT id, subject.getReferenceKey(Patient) AS patient, value.ofType(Quantity).value AS value FROM Observation"
          'pts.sof "CREATE VIEW pts WITH (status = 'active') AS SELECT getResourceKey() AS id, name.family.first() AS family FROM Patient"))
(let ([t (call "query" (hasheq 'language "sql" 'text "SELECT o.id, p.family, o.value FROM obs o JOIN pts p ON p.id = o.patient" 'files views 'data data))])
  (check-equal? (hash-ref t 'columns) '("id" "family" "value"))
  (check-equal? (hash-ref t 'rows) (list (hasheq 'id "a1" 'family "Lee" 'value 9.4))))
(let ([t (call "query" (hasheq 'language "search" 'text "Observation?code=4548-4" 'data data))])
  (check-equal? (map (lambda (r) (hash-ref r 'resource)) (hash-ref t 'rows)) '("Observation/a1")))
(check-equal? (map (lambda (r) (hash-ref r 'code))
                   (hash-ref (call "query" (hasheq 'language "vcl" 'text "(http://hl7.org/fhir/administrative-gender)(female;male)")) 'rows))
              '("female" "male"))
(check-regexp-match #rx"query takes cql, fhirpath, find, search, sql, vcl, view" (message (call "query" (hasheq 'language "xquery" 'text "x"))))
(let ([e (call "explain" (hasheq 'path "A1c.cql" 'subject "ann" 'entry "Above 9" 'files (hasheq 'A1c.cql cql) 'data data))])
  (check-equal? (hash-ref e 'value) #t)
  (check-equal? (hash-ref (car (hash-ref e 'uses)) 'define) "Latest"))
(check-regexp-match #rx"no file nope.cql in the project" (message (call "run" (hasheq 'path "nope.cql"))))

;; ---- data: one resource, a Bundle, a directory, a place that is not there -------------------------
(check-equal? (hash-ref (car (hash-ref (call "query" (hasheq 'language "fhirpath" 'text "Patient.birthDate" 'data patient)) 'rows)) 'resource) "Patient/ann")
(check-equal? (length (hash-ref (call "query" (hasheq 'language "fhirpath" 'text "Patient.birthDate"
                                                      'data (hasheq 'resourceType "Bundle" 'type "collection" 'entry (list (hasheq 'resource patient)))))
                                'rows))
              1)
(define dir (make-temporary-file "fhir-api-test-~a" 'directory))
(make-directory (build-path dir "data"))
(make-directory (build-path dir "project"))
(call-with-output-file (build-path dir "data" "Patient-ann.json") (lambda (o) (write-json patient o)))
(check-equal? (length (hash-ref (call "query" (hasheq 'language "fhirpath" 'text "Patient.birthDate" 'data (path->string (build-path dir "data")))) 'rows)) 1)
(check-regexp-match #rx"^data: .*nope does not exist" (message (call "query" (hasheq 'language "fhirpath" 'text "Patient.birthDate" 'data (path->string (build-path dir "nope"))))))

;; ---- a project as a directory: read at every call ------------------------------------------------
(display-to-file "Profile: P1\nParent: Patient\n" (build-path dir "project" "p.fsh"))
(define (defined) (map (lambda (r) (hash-ref r 'id)) (hash-ref (call "compile" (hasheq 'directory (path->string (build-path dir "project")))) 'resources)))
(check-equal? (defined) '("P1"))
(display-to-file "Profile: P2\nParent: Patient\n" (build-path dir "project" "q.fsh"))
(check-equal? (sort (defined) string<?) '("P1" "P2"))
(check-regexp-match #rx"not both" (message (call "compile" (hasheq 'files (hasheq 'a.fsh "Profile: P\nParent: Patient\n") 'directory (path->string dir)))))
(check-regexp-match #rx"is not a directory" (message (call "compile" (hasheq 'directory (path->string (build-path dir "nope"))))))
(delete-directory/files dir)

;; ---- what a project may not do --------------------------------------------------------------------
(check-regexp-match #rx"`../x.fsh` is not a file name inside the project" (message (call "compile" (hasheq 'files (hasheq '../x.fsh "Profile: P\nParent: Patient\n")))))
(check-regexp-match #rx"the project is FHIR 5.0.0 and this process reads FHIR 4.0.1"
                    (message (call "compile" (hasheq 'files (hasheq 'sushi-config.yaml "id: x\ncanonical: http://x.org\nfhirVersion: 5.0.0\nversion: 1.0.0\n")))))

;; ---- transform, operation --------------------------------------------------------------------------
(check-equal? (call "transform" (hasheq 'map fml 'source patient))
              (hasheq 'resourceType "Patient" 'birthDate "1980-02-28" 'gender "female"))
(let ([r (call "transform" (hasheq 'map (string-replace fml "tgt.gender" "tgt.gendr") 'source patient))])
  (check-true (failed? r))
  (check-regexp-match #rx"gendr" (message r))
  (check-equal? (hash-ref (car (hash-ref (hash-ref (cdr r) 'data) 'diagnostics)) 'line) 7))
(check-equal? (map (lambda (c) (hash-ref c 'code))
                   (hash-ref (hash-ref (call "operation" (hasheq 'operation "$expand" 'inputs (hasheq 'url "http://hl7.org/fhir/ValueSet/administrative-gender"))) 'expansion) 'contains))
              '("male" "female" "other" "unknown"))
(check-true (failed? (call "operation" (hasheq 'operation "$nope"))))

;; ---- decompile: each language back from the resource, and compile . decompile is the resource -----
(define (decompiled r [as #f]) (call "decompile" (if as (hasheq 'resource r 'as as) (hasheq 'resource r))))
(let ([d (decompiled patient)])
  (check-equal? (hash-ref d 'language) "fsh")
  (check-regexp-match #rx"Instance: ann\nInstanceOf: Patient" (hash-ref d 'text))
  (check-equal? (hash-ref (call "compile" (hasheq 'files (hasheq 'ann.fsh (hash-ref d 'text)))) 'resources) (list patient)))
(let* ([sm (car (hash-ref (call "compile" (hasheq 'files (hasheq 'p2p.map fml))) 'resources))]
       [d (decompiled sm)])
  (check-equal? (hash-ref d 'language) "fml")
  (check-equal? (hash-ref (call "compile" (hasheq 'files (hasheq 'again.map (hash-ref d 'text)))) 'resources) (list sm)))
(let* ([view (car (hash-ref (call "compile" (hasheq 'files (hasheq 'pts.sof "CREATE VIEW pts WITH (status = 'active') AS SELECT id, birthDate FROM Patient"))) 'resources))]
       [d (decompiled view)])
  (check-equal? (hash-ref d 'language) "sof")
  (check-regexp-match #rx"SELECT\n  id,\n  birthDate\nFROM Patient" (hash-ref d 'text)))
(check-equal? (hash-ref (decompiled (hasheq 'resourceType "ValueSet" 'compose (hasheq 'include (list (hasheq 'system "http://loinc.org" 'concept (list (hasheq 'code "4548-4")))))) "vcl") 'text)
              "(http://loinc.org)4548-4")
(let* ([lib (findf (lambda (r) (equal? (hash-ref r 'resourceType) "Library")) (hash-ref (call "compile" (hasheq 'files (hasheq 'A1c.cql cql))) 'resources))]
       [d (decompiled lib)])
  (check-equal? (hash-ref d 'language) "cql")
  (check-equal? (hash-ref d 'text) cql))
(check-regexp-match #rx"written as fsh, fml, sof, vcl or cql" (message (decompiled patient "xml")))

;; ---- many projects: the least recently used are closed, and come back when asked again -------------
(for ([i (in-range 12)])
  (define r (call "compile" (hasheq 'files (hasheq 'p.fsh (format "Profile: Q~a\nParent: Patient\n" i)))))
  (check-equal? (hash-ref (car (hash-ref r 'resources)) 'id) (format "Q~a" i)))
(check-equal? (length (filter (lambda (p) (regexp-match? #rx"^p-" (path->string p))) (directory-list (session-dir s)))) 8)
(check-equal? (hash-ref (car (hash-ref (call "compile" (hasheq 'files (hasheq 'p.fsh "Profile: Q0\nParent: Patient\n"))) 'resources)) 'id) "Q0")

(close-session! s)
(check-false (directory-exists? (session-dir s)))
