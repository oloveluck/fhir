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

;; ---- writing: stage, then commit -----------------------------------------------------------------
(define store-dir (make-temporary-file "fhir-api-store-~a" 'directory))
(define store (path->string (build-path store-dir "clinic.db")))
(define (staged args) (call "stage" (hash-set args 'data store)))
(let ([st (staged (hasheq 'resources data))])
  (check-equal? (hash-ref st 'stage) "stage-1")
  (check-equal? (hash-ref st 'errors) 0)
  (check-equal? (for/list ([c (hash-ref st 'changes)]) (list (hash-ref c 'resource) (hash-ref c 'action)))
                '(("Patient/ann" "create") ("Observation/a1" "create")))
  ;; nothing is written until commit
  (check-equal? (hash-ref (call "query" (hasheq 'language "search" 'text "Patient" 'data store)) 'rows) '())
  (define c (call "commit" (hasheq 'stage "stage-1" 'data store 'reason "first load" 'agent "intake desk")))
  (check-equal? (for/list ([w (hash-ref c 'written)]) (hash-ref w 'version)) '("Patient/ann/_history/1" "Observation/a1/_history/1"))
  (check-regexp-match #rx"^Provenance/" (hash-ref c 'provenance))
  (check-equal? (hash-ref c 'reason) "first load")
  (check-equal? (hash-ref c 'agent) "intake desk")
  ;; an answer names no call of the workspace's own tools
  (check-false (hash-has-key? c 'next))
  (check-equal? (length (hash-ref (call "query" (hasheq 'language "search" 'text "Patient" 'data store)) 'rows)) 1))
;; one resource, not a list; the same resource again differs in nothing and makes no stage
(let ([st (staged (hasheq 'resources patient))])
  (check-equal? (hash-ref st 'stage) 'null)
  (check-equal? (hash-ref (car (hash-ref st 'changes)) 'action) "unchanged"))
;; a change as the FSH rules that change, laid over the stored resource
(let ([st (staged (hasheq 'fsh "Instance: Observation/a1\n* status = #amended\n* valueQuantity = 9.1 '%'"))])
  (check-equal? (hash-ref (car (hash-ref st 'changes)) 'changed) '("status: \"final\" → \"amended\"" "valueQuantity.value: 9.4 → 9.1"))
  (define c (call "commit" (hasheq 'stage "latest" 'data store 'reason "corrected")))
  (check-equal? (hash-ref (car (hash-ref c 'written)) 'version) "Observation/a1/_history/2")
  (check-equal? (hash-ref c 'agent) "fhir-api"))
;; an error refuses the commit, and says why without naming another tool's call
(let* ([bad (hash-set* observation 'id "a2" 'status "finl")]
       [st (staged (hasheq 'resources (list bad)))])
  (check-equal? (hash-ref st 'errors) 1)
  (check-regexp-match #rx"code `finl` not in required value set" (car (hash-ref (car (hash-ref st 'changes)) 'errors)))
  (define refused (call "commit" (hasheq 'stage (hash-ref st 'stage) 'data store)))
  (check-true (failed? refused))
  (check-regexp-match #rx"has 1 validation error" (message refused))
  (check-false (regexp-match? #rx"stage\\(drop" (message refused)))
  ;; a check only keeps nothing; a refused stage is dropped
  (check-equal? (hash-ref (staged (hasheq 'resources (list bad) 'keep #f)) 'stage) 'null)
  (check-equal? (hash-ref (staged (hasheq 'drop "refused")) 'stages) '()))
;; a profile of the project is what a staged instance is held to
(let ([st (staged (hasheq 'fsh "Instance: bo\nInstanceOf: AdultPatient\n* gender = #male" 'files (hasheq 'profiles.fsh fsh) 'keep #f))])
  (check-equal? (hash-ref st 'errors) 1)
  (check-regexp-match #rx"birthDate" (car (hash-ref (car (hash-ref st 'changes)) 'errors))))
;; the trail is in the store: who wrote which version, and why
(check-equal? (for/list ([r (hash-ref (call "query" (hasheq 'language "sql" 'data store
                                                            'text "SELECT type, id, versionId, agent, reason FROM trail ORDER BY type, id, versionId"))
                                      'rows)])
                (list (hash-ref r 'type) (hash-ref r 'id) (hash-ref r 'versionId) (hash-ref r 'agent) (hash-ref r 'reason)))
              '(("Observation" "a1" 1 "intake desk" "first load") ("Observation" "a1" 2 "fhir-api" "corrected")
                ("Patient" "ann" 1 "intake desk" "first load")))
(check-regexp-match #rx"give one of `resources`, `fsh`" (message (staged (hasheq))))
(check-regexp-match #rx"give one of `resources`, `fsh`" (message (staged (hasheq 'resources data 'fsh "x"))))
(check-regexp-match #rx"stage needs `data`" (message (call "stage" (hasheq 'resources data))))
(check-regexp-match #rx"no stage stage-99" (message (call "commit" (hasheq 'stage "stage-99" 'data store))))
(delete-directory/files store-dir)

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

;; ---- several resources in one call: each answered as the call for one answers it -------------------
(let* ([patients (for/list ([i 5]) (hash-set (hash-set patient 'id (format "p~a" i)) 'name (list (hasheq 'family (format "Lee~a" i)))))]
       [bundle (hasheq 'resourceType "Bundle" 'type "collection" 'entry (for/list ([p patients]) (hasheq 'resource p)))])
  (check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "name.family" 'resources patients)) 'results)
                (for/list ([i 5]) (list (format "Lee~a" i))))
  (check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "id" 'resources bundle)) 'results) (for/list ([i 5]) (list (format "p~a" i))))
  (check-equal? (hash-ref (call "fhirpath" (hasheq 'expression "id" 'resources '())) 'results) '())
  (check-regexp-match #rx"`resource` [(]one[)] or `resources` [(]several[)]" (message (call "fhirpath" (hasheq 'expression "id"))))
  (check-regexp-match #rx"`resource` [(]one[)] or `resources`" (message (call "fhirpath" (hasheq 'expression "id" 'resource patient 'resources patients))))
  (check-regexp-match #rx"resource 1 does not read as FHIR 4.0.1"
                      (message (call "fhirpath" (hasheq 'expression "id" 'resources (list patient (hasheq 'resourceType "Nope"))))))
  (define mixed (list patient (hash-set patient 'gender "florp") (hash-set patient 'birthDate "1980-02-30")))
  (check-equal? (hash-ref (call "validate" (hasheq 'resources mixed)) 'outcomes)
                (for/list ([r mixed]) (call "validate" (hasheq 'resource r))))
  (check-equal? (for/list ([o (hash-ref (call "validate" (hasheq 'resources (list patient (hasheq 'resourceType "Patient")) 'profile "AdultPatient"
                                                                 'files (hasheq 'p.fsh "Profile: AdultPatient\nParent: Patient\n* birthDate 1..1\n")))
                                        'outcomes)])
                  (hash-ref (car (hash-ref o 'issue)) 'severity))
                '("information" "error"))
  (check-regexp-match #rx"`resource` [(]one[)] or `resources`" (message (call "validate" (hasheq)))))

;; ---- data given once: kept in the process, named by its key in the calls after it -----------------
(let* ([l (call "load" (hasheq 'data data))]
       [key (hash-ref l 'loaded)]
       [loaded (hasheq 'loaded key)]
       [views (hasheq 'obs.sof "CREATE VIEW obs WITH (status = 'active') AS SELECT id, value.ofType(Quantity).value AS value FROM Observation")])
  (check-equal? (hash-ref l 'count) 2)
  (check-equal? (hash-ref (call "query" (hasheq 'language "view" 'text "SELECT id FROM Patient" 'data loaded)) 'rows) (list (hasheq 'id "ann")))
  (check-equal? (hash-ref (call "run" (hasheq 'path "A1c.cql" 'files (hasheq 'A1c.cql cql) 'data loaded)) 'rows)
                (hash-ref (call "run" (hasheq 'path "A1c.cql" 'files (hasheq 'A1c.cql cql) 'data data)) 'rows))
  ;; a search reads the resources given (its index is built of them)
  (check-equal? (map (lambda (r) (hash-ref r 'resource)) (hash-ref (call "query" (hasheq 'language "search" 'text "Observation?code=4548-4" 'data loaded)) 'rows))
                '("Observation/a1"))
  (check-equal? (map (lambda (r) (hash-ref r 'resource)) (hash-ref (call "query" (hasheq 'language "search" 'text "Observation?code=4548-4" 'data data)) 'rows))
                '("Observation/a1"))
  ;; a view's rows over loaded data are computed once and serve every statement after
  (for ([_ 2])
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT count(*) AS n, max(value) AS top FROM obs" 'files views 'data loaded)) 'rows)
                  (list (hasheq 'n 1 'top 9.4))))
  ;; other data in between is its own
  (check-equal? (hash-ref (call "query" (hasheq 'language "view" 'text "SELECT id FROM Patient" 'data (list (hash-set patient 'id "bo")))) 'rows) (list (hasheq 'id "bo")))
  (check-equal? (hash-ref (call "query" (hasheq 'language "view" 'text "SELECT id FROM Patient" 'data loaded)) 'rows) (list (hasheq 'id "ann")))
  (check-regexp-match #rx"the data is loaded already" (message (call "load" (hasheq 'data loaded))))
  ;; let go, it names nothing; a key of another process's never did
  (check-equal? (call "unload" (hasheq 'loaded key)) (hasheq 'unloaded #t))
  (check-equal? (call "unload" (hasheq 'loaded key)) (hasheq 'unloaded #f))
  (check-regexp-match #rx"no data is loaded as .* load it again" (message (call "query" (hasheq 'language "view" 'text "SELECT id FROM Patient" 'data loaded))))
  (check-regexp-match #rx"no data is loaded as fhir-api-0.1" (message (call "query" (hasheq 'language "view" 'text "SELECT id FROM Patient" 'data (hasheq 'loaded "fhir-api-0.1")))))
  ;; a place: read once, no count
  (define dir (make-temporary-file "fhir-api-data-~a" 'directory))
  (call-with-output-file (build-path dir "ann.json") (lambda (o) (write-json patient o)))
  (define place (call "load" (hasheq 'data (path->string dir))))
  (check-equal? (hash-ref place 'count) (json-null))
  (delete-directory/files dir)                      ; read when it was loaded
  (check-equal? (hash-ref (call "query" (hasheq 'language "view" 'text "SELECT id FROM Patient" 'data (hasheq 'loaded (hash-ref place 'loaded)))) 'rows)
                (list (hasheq 'id "ann")))
  (check-regexp-match #rx"^data: " (message (call "load" (hasheq 'data "/nonexistent/place")))))

;; ---- warming: each step is a first call made early; a server that is not asked takes them ----------
(let ([w (open-session)])
  (for ([step (in-list (warm-steps w))]) (check-not-exn step))
  (close-session! w))
(let ([w (open-session)])
  (define-values (in to-server) (make-pipe))
  (define out (open-output-string))
  (define server (thread (lambda () (serve w in out #:warm? #t))))
  (sleep 0.6)                                       ; nobody asks: it warms
  (check-true (positive? (hash-count (session-hubs w))) "a project was opened before any request")
  (write-string "{\"id\":1,\"method\":\"version\"}\n" to-server)
  (close-output-port to-server)
  (check-not-false (sync/timeout 120 server) "the request is answered once the step in hand is done, and the server ends with its input")
  (check-equal? (hash-ref (string->jsexpr (get-output-string out)) 'id) 1)
  (close-session! w))
(let ([w (open-session)])
  (define out (open-output-string))
  (serve w (open-input-string "") out #:warm? #f)
  (check-equal? (hash-count (session-hubs w)) 0)
  (close-session! w))

;; ---- many projects: the least recently used are closed, and come back when asked again -------------
(for ([i (in-range 12)])
  (define r (call "compile" (hasheq 'files (hasheq 'p.fsh (format "Profile: Q~a\nParent: Patient\n" i)))))
  (check-equal? (hash-ref (car (hash-ref r 'resources)) 'id) (format "Q~a" i)))
(check-equal? (length (filter (lambda (p) (regexp-match? #rx"^p-" (path->string p))) (directory-list (session-dir s)))) 8)
(check-equal? (hash-ref (car (hash-ref (call "compile" (hasheq 'files (hasheq 'p.fsh "Profile: Q0\nParent: Patient\n"))) 'resources)) 'id) "Q0")

(close-session! s)
(check-false (directory-exists? (session-dir s)))
