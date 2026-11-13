#lang racket/base

;;; dependencies-test.rkt — what depends on what (mcp/dependencies.rkt: CRMI's "Dependency
;;; Tracing"), as an agent meets it from the shell:
;;;   1. a CQL library's Library resource states what it depends on and the data it retrieves
;;;      (cql/requirements: `relatedArtifact` depends-on, `dataRequirement`), and is stored so;
;;;   2. CRMI's `$data-requirements`: the artifact's dependencies traced to the end, each at the
;;;      version it resolves to, as a module-definition Library — pinned otherwise for one call;
;;;   3. SQL's `dependencies`: "what depends on X" is a query over the store.

(require rackunit racket/file racket/port racket/system racket/string racket/list json)

(define dir (make-temporary-directory "dependencies-~a"))
(define (sh cmd)
  (define out (open-output-string))
  (define ok (parameterize ([current-directory dir] [current-output-port out] [current-error-port out]) (system cmd)))
  (values ok (get-output-string out)))
(define (save name . lines) (with-output-to-file (build-path dir name) #:exists 'truncate (lambda () (for ([l (in-list lines)]) (displayln l)))))
(define (batch . lines)
  (apply save "session.txt" lines)
  (define-values (_ok out) (sh "raco fhir-mcp batch session.txt --workspace ws"))
  (cdr (regexp-split #rx"(?m:^### )" out)))
;; the JSON an answer carries, after its `### <line>` header
(define (answer-json a) (string->jsexpr (cadr (regexp-match #rx"^[^\n]*\n(.*)$" a))))

(let-values ([(ok _o) (sh "raco fhir-mcp init ws")]) (check-true ok))
(save "guide.yaml" "id: example.clinic" "canonical: http://example.org/clinic" "title: Clinic Guide" "version: 0.1.0"
      "fhirVersion: 4.0.1" "publisher:" "  name: Example Clinic" "description: What the example clinic records about lab results.")
(save "lab.fsh"
      "Profile: Result" "Parent: Observation" "Id: result" "Title: \"A result\"" "Description: \"Any result of a known patient.\""
      "* subject 1..1"
      "" "Profile: Lab" "Parent: Result" "Id: lab" "Title: \"A lab result\"" "Description: \"A laboratory result.\""
      "* code from http://example.org/clinic/ValueSet/labs (required)"
      "" "Instance: ann" "InstanceOf: Patient" "* name.family = \"Lee\""
      "" "Instance: a1c-1" "InstanceOf: lab" "* status = #final" "* code = http://loinc.org#4548-4"
      "* subject = Reference(Patient/ann)" "* valueQuantity = 7.2 '%'")
(save "labs.vcl" "(http://loinc.org)(4548-4;2345-7)")
(save "A1c.cql"
      "/* Who has been tested. */" "library A1c version '0.1.0'" "using FHIR version '4.0.1'"
      "include FHIRHelpers version '4.0.1'" "codesystem \"LOINC\": 'http://loinc.org'"
      "valueset \"Labs\": 'http://example.org/clinic/ValueSet/labs'"
      "code \"HbA1c\": '4548-4' from \"LOINC\""
      "context Patient" "define \"Tested\": exists [Observation: \"HbA1c\"]" "define \"Any Lab\": exists [Observation: \"Labs\"]")
(save "requirements.json" "{\"url\": \"http://example.org/clinic/Library/A1c\"}")
(save "requirements-of-lab.json" "{\"url\": \"http://example.org/clinic/StructureDefinition/lab\"}")
(define a
  (batch "write path=sushi-config.yaml text=@guide.yaml" "write path=lab.fsh text=@lab.fsh" "write path=labs.vcl text=@labs.vcl"
         "write path=A1c.cql text=@A1c.cql"
         "stage path=sushi-config.yaml" "commit stage=latest reason=\"the clinic's definitions\""
         "describe ref=Library/A1c"
         "apply operation=$data-requirements inputs:=@requirements.json"
         "apply operation=$data-requirements inputs:=@requirements-of-lab.json"
         "query language=sql text=\"SELECT type, id, path FROM dependencies WHERE target = 'http://example.org/clinic/ValueSet/labs' ORDER BY type, id, path\" as=csv"
         "query language=sql text=\"SELECT type, id FROM dependencies WHERE target = 'http://example.org/clinic/StructureDefinition/lab' ORDER BY type, id\" as=csv"
         "query language=sql text=\"SELECT DISTINCT target FROM dependencies WHERE id = 'A1c' ORDER BY target\" as=csv"))
(check-regexp-match #rx"\"errors\":0" (list-ref a 4))

;; ---- 1. the stored Library states its dependencies and its data requirements -------------------
(define library (answer-json (list-ref a 6)))
(check-equal? (for/list ([ra (in-list (hash-ref library 'relatedArtifact))]) (list (hash-ref ra 'type) (hash-ref ra 'display) (hash-ref ra 'resource)))
              '(("depends-on" "Library FHIRHelpers" "http://hl7.org/fhir/Library/FHIRHelpers|4.0.1")
                ("depends-on" "Code system LOINC" "http://loinc.org")
                ("depends-on" "Value set Labs" "http://example.org/clinic/ValueSet/labs")))
(check-equal? (for/list ([dr (in-list (hash-ref library 'dataRequirement))]) (list (hash-ref dr 'type) (hash-ref dr 'codeFilter #f)))
              (list (list "Patient" #f)
                    (list "Observation" (list (hasheq 'path "code" 'code (list (hasheq 'system "http://loinc.org" 'code "4548-4")))))
                    (list "Observation" (list (hasheq 'path "code" 'valueSet "http://example.org/clinic/ValueSet/labs")))))

;; ---- 2. $data-requirements: a module-definition Library, dependencies traced to the end --------
(define needs (answer-json (list-ref a 7)))
(check-equal? (hash-ref (car (hash-ref (hash-ref needs 'type) 'coding)) 'code) "module-definition")
;; the library's own dependencies; the value set resolves to the workspace's working copy (a file
;; states no version: the guide gives it one when it is staged)
(check-equal? (for/list ([ra (in-list (hash-ref needs 'relatedArtifact))]) (hash-ref ra 'resource))
              '("http://hl7.org/fhir/Library/FHIRHelpers|4.0.1" "http://loinc.org" "http://example.org/clinic/ValueSet/labs"))
(check-equal? (hash-ref needs 'dataRequirement) (hash-ref library 'dataRequirement))
;; a profile: its parent, its value set, and what that includes
(check-equal? (for/list ([ra (in-list (hash-ref (answer-json (list-ref a 8)) 'relatedArtifact))]) (hash-ref ra 'resource))
              '("http://example.org/clinic/StructureDefinition/result" "http://example.org/clinic/ValueSet/labs" "http://loinc.org"))

;; ---- 3. what depends on X is a query --------------------------------------------------------------
;; the value set: the library (one row per target, at the first element that names it) and the profile bound to it
(check-regexp-match #rx"type,id,path\nLibrary,A1c,relatedArtifact.resource\nStructureDefinition,lab,differential.element.binding.valueSet\n"
                    (list-ref a 9))
;; the profile: the example that claims it
(check-regexp-match #rx"type,id\nObservation,a1c-1\n" (list-ref a 10))
(check-regexp-match #rx"target\nhttp://example.org/clinic/ValueSet/labs\nhttp://hl7.org/fhir/Library/FHIRHelpers\nhttp://loinc.org\n" (list-ref a 11))

;; ---- with the working files gone, the store answers: each dependency at the version stored ------
(for ([f (in-list '("lab.fsh" "labs.vcl" "A1c.cql" "sushi-config.yaml"))]) (delete-file (build-path dir "ws" f)))
(let ([b (batch "apply operation=$data-requirements inputs:=@requirements.json"
                "apply operation=$data-requirements inputs:=@requirements-of-lab.json")])
  (check-equal? (for/list ([ra (in-list (hash-ref (answer-json (list-ref b 0)) 'relatedArtifact))]) (hash-ref ra 'resource))
                '("http://hl7.org/fhir/Library/FHIRHelpers|4.0.1" "http://loinc.org" "http://example.org/clinic/ValueSet/labs|0.1.0"))
  (check-equal? (for/list ([ra (in-list (hash-ref (answer-json (list-ref b 1)) 'relatedArtifact))]) (list (hash-ref ra 'resource) (hash-ref ra 'display #f)))
                '(("http://example.org/clinic/StructureDefinition/result|0.1.0" "StructureDefinition A result")
                  ("http://example.org/clinic/ValueSet/labs|0.1.0" "ValueSet labs")
                  ("http://loinc.org" #f))))

(delete-directory/files dir)
