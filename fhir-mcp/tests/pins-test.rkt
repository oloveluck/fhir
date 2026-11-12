#lang racket/base

;;; pins-test.rkt — which version an unversioned canonical means, and how that is pinned (CRMI's
;;; manifest parameters; mcp/artifacts.rkt, mcp/crmi.rkt; the fhir repo's docs/store-as-codebase.md).
;;; One workspace, the shell route. A profile is released (0.1.0, active) and its next version
;;; drafted (0.2.0: a lab result has a date); the working files are deleted, so the store answers.
;;;   1. unpinned, a canonical means the active version: a reading with no date is accepted;
;;;   2. `manifest=` on a call pins it for that call: under the draft the same reading is refused,
;;;      and `describe` of the canonical answers the draft;
;;;   3. `$resolve` (CRMI's operation) resolves by the same order: the version named, the pinned
;;;      one, the one in force;
;;;   4. the guide names its own pins (`parameters: path-expansion-params`, as the IG Publisher is
;;;      told): a Parameters resource the workspace defines — in force for every call, carried by
;;;      the compiled ImplementationGuide (contained, CRMI's `cqf-expansionParameters`), and still
;;;      in force when the guide is read from the store; one that nothing defines is a warning.

(require rackunit racket/file racket/port racket/system racket/string)

(define dir (make-temporary-directory "pins-~a"))
(define (sh cmd)
  (define out (open-output-string))
  (define ok (parameterize ([current-directory dir] [current-output-port out] [current-error-port out]) (system cmd)))
  (values ok (get-output-string out)))
(define (save name . lines) (with-output-to-file (build-path dir name) #:exists 'truncate (lambda () (for ([l (in-list lines)]) (displayln l)))))
(define (batch . lines)
  (apply save "session.txt" lines)
  (define-values (_ok out) (sh "raco fhir-mcp batch session.txt --workspace ws"))
  (cdr (regexp-split #rx"(?m:^### )" out)))

(define-values (ok-init _o) (sh "raco fhir-mcp init ws"))
(check-true ok-init)

(define lab-url "http://example.org/clinic/StructureDefinition/lab")
(define (guide version status . more)
  (apply save "guide.yaml"
         (append (list "id: example.clinic" "canonical: http://example.org/clinic" "title: Clinic Guide"
                       "description: What the example clinic records about lab results."
                       (format "version: ~a" version) (format "status: ~a" status) "fhirVersion: 4.0.1"
                       "global:" (format "  Observation: ~a" lab-url))
                 more)))
(define (lab dated?)
  (apply save "lab.fsh"
         (append (list "Profile: Lab" "Parent: Observation" "Id: lab" "Title: \"A lab result\""
                       "Description: \"A laboratory result of a known patient.\"" "* subject 1..1")
                 (if dated? (list "* effective[x] 1..1") '())
                 (list "" "Instance: ann" "InstanceOf: Patient" "* gender = #female"))))
(save "nodate.fsh" "Instance: a1c-8" "InstanceOf: Observation" "* status = #final" "* code = http://loinc.org#4548-4"
      "* subject = Reference(Patient/ann)" "* valueQuantity = 8.1 '%'")
(save "pins.json" (format "{\"resourceType\": \"Parameters\", \"parameter\": [{\"name\": \"default-canonical-version\", \"valueCanonical\": \"~a|0.2.0\"}]}" lab-url))
;; the pins, as the guide writes them (`raco fhir guide ig --block pins`)
(let-values ([(ok text) (sh "raco fhir guide ig --block pins")])
  (check-true ok)
  (check-regexp-match (regexp (regexp-quote (format "~a|0.2.0" lab-url))) text)
  (with-output-to-file (build-path dir "pins.fsh") #:exists 'truncate (lambda () (display text))))

;; released, then the next version drafted; the working files deleted
(guide "0.1.0" "active")
(lab #f)
(let ([a (batch "write path=sushi-config.yaml text=@guide.yaml" "write path=lab.fsh text=@lab.fsh"
                "stage path=sushi-config.yaml" "commit stage=latest reason=\"released 0.1.0\"")])
  (check-regexp-match #rx"\"reason\":\"released 0.1.0\"" (list-ref a 3)))
(guide "0.2.0" "draft")
(lab #t)
(let ([a (batch "write path=sushi-config.yaml text=@guide.yaml" "write path=lab.fsh text=@lab.fsh"
                "stage path=sushi-config.yaml" "commit stage=latest reason=\"0.2.0 begins: a lab result has a date\"")])
  (check-regexp-match #rx"\"action\":\"create\",\"resource\":\"StructureDefinition/lab-0.1.0\"" (list-ref a 2))
  (check-regexp-match #rx"\"reason\":\"0.2.0 begins" (list-ref a 3)))
(for ([f '("sushi-config.yaml" "lab.fsh")]) (delete-file (build-path dir "ws" f)))

;; ---- 1-3. unpinned, pinned for a call, $resolve -----------------------------------------------
(save "resolve.json" (format "{\"canonical\": \"~a\"}" lab-url))
(save "resolve-pinned.json" (format "{\"canonical\": \"~a\", \"default-canonical-version\": \"~a|0.2.0\"}" lab-url lab-url))
(save "resolve-versioned.json" (format "{\"canonical\": \"~a|0.2.0\"}" lab-url))
(save "resolve-nothing.json" "{\"canonical\": \"http://example.org/clinic/StructureDefinition/nope\"}")
(let ([a (batch "stage fsh=@nodate.fsh keep:=false"
                "!stage fsh=@nodate.fsh keep:=false manifest=@pins.json"
                (format "describe ref=~a" lab-url)
                (format "describe ref=~a manifest=@pins.json" lab-url)
                "apply operation=$resolve inputs:=@resolve.json"
                "apply operation=$resolve inputs:=@resolve-pinned.json"
                "apply operation=$resolve inputs:=@resolve-versioned.json"
                "apply operation=$resolve inputs:=@resolve.json manifest=@pins.json"
                "!apply operation=$resolve inputs:=@resolve-nothing.json"
                "!stage fsh=@nodate.fsh keep:=false manifest=Parameters/nope"
                "!stage fsh=@nodate.fsh keep:=false manifest=nonsense")])
  ;; the active version holds the data; under the pin, the draft does
  (check-regexp-match #rx"\"action\":\"would create\",\"resource\":\"Observation/a1c-8\"\\}\\],\"errors\":0" (list-ref a 0))
  (check-regexp-match #rx"Observation.effective\\[x\\]: minimum required = 1, but found 0" (list-ref a 1))
  (check-regexp-match #rx"\"version\":\"0.1.0\"" (list-ref a 2))
  (check-regexp-match #rx"\"version\":\"0.2.0\"" (list-ref a 3))
  ;; $resolve: the version in force, the one its parameters pin, the one the reference names, the call's pins
  (check-regexp-match #rx"\"resourceType\":\"StructureDefinition\",\"id\":\"lab-0.1.0\".*\"version\":\"0.1.0\"" (list-ref a 4))
  (check-regexp-match #rx"\"resourceType\":\"StructureDefinition\",\"id\":\"lab\".*\"version\":\"0.2.0\"" (list-ref a 5))
  (check-regexp-match #rx"\"id\":\"lab\".*\"version\":\"0.2.0\"" (list-ref a 6))
  (check-regexp-match #rx"\"id\":\"lab\".*\"version\":\"0.2.0\"" (list-ref a 7))
  (check-regexp-match #rx"nothing here defines http://example.org/clinic/StructureDefinition/nope" (list-ref a 8))
  ;; a manifest that is none says what one is
  (check-regexp-match #rx"no Parameters/nope in the workspace or the data" (list-ref a 9))
  (check-regexp-match #rx"a manifest is a Parameters resource of pinned versions" (list-ref a 10)))

;; ---- 4. the guide's own pins ------------------------------------------------------------------
;; the guide back as its file, naming its expansion parameters before anything defines them
(guide "0.2.0" "draft" "parameters:" "  path-expansion-params: input/resources/Parameters-pins.json")
(let ([a (batch "write path=sushi-config.yaml text=@guide.yaml"
                "write path=pins.fsh text=@pins.fsh"
                "check"
                "!stage fsh=@nodate.fsh keep:=false"
                "describe ref=http://example.org/clinic/ImplementationGuide/example.clinic"
                "stage path=sushi-config.yaml"
                "commit stage=latest reason=\"the guide pins the draft profile\"")])
  (check-regexp-match #rx"sushi-config.yaml:[0-9]+:[0-9]+ warning: path-expansion-params names Parameters/pins, which nothing in the workspace defines"
                      (list-ref a 0))
  ;; defined: no problem left, and every call is under the guide's pins
  (check-regexp-match #rx"\"errors\":0,.*\"problems\":\\[\\],\"warnings\":0" (list-ref a 2))
  (check-regexp-match #rx"Observation.effective\\[x\\]: minimum required = 1, but found 0" (list-ref a 3))
  ;; the compiled guide carries them (CRMIImplementationGuide)
  (check-regexp-match #rx"\"contained\":\\[\\{\"resourceType\":\"Parameters\",\"id\":\"pins\"" (list-ref a 4))
  (check-regexp-match #rx"\"url\":\"http://hl7.org/fhir/StructureDefinition/cqf-expansionParameters\",\"valueReference\":\\{\"reference\":\"#pins\"\\}" (list-ref a 4))
  (check-regexp-match #rx"\"errors\":0" (list-ref a 5))
  (check-regexp-match #rx"\"reason\":\"the guide pins the draft profile\"" (list-ref a 6)))
;; the files gone again: the stored guide is the workspace's, its pins with it — but the store's
;; current guide is the released 0.1.0, which pins nothing; the draft, handed back, pins again
(for ([f '("sushi-config.yaml" "pins.fsh")]) (delete-file (build-path dir "ws" f)))
(let ([a (batch "stage fsh=@nodate.fsh keep:=false"
                "write path=sushi-config.yaml ref=ImplementationGuide/example.clinic"
                "!stage fsh=@nodate.fsh keep:=false")])
  (check-regexp-match #rx"\"action\":\"would create\",\"resource\":\"Observation/a1c-8\"\\}\\],\"errors\":0" (list-ref a 0))
  (check-regexp-match #rx"path-expansion-params: input/resources/Parameters-pins.json" (file->string (build-path dir "ws" "sushi-config.yaml")))
  (check-regexp-match #rx"Observation.effective\\[x\\]: minimum required = 1, but found 0" (list-ref a 2)))

(delete-directory/files dir)
