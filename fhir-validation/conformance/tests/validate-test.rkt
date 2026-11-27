#lang racket/base

;;; validate-test.rkt — authored validation cases, one per check. Each asserts the exact set of
;;; ERROR issues by {code, path}. The primary oracle (the official corpus can't be matched message-for-
;;; message against the Java validator).

(require rackunit
         racket/list
         (only-in fhir/r5/schemas)
         (only-in fhir/terminology/service make-r5-terminology resources->resolver)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/conformance/validate
                  validate-issues issue-severity issue-code issue-path issue-msg issue-location))

;; the set of (code . path) for ERROR-severity issues
(define (errs js #:profiles [ps '()] #:terminology [tx #f] #:invariants? [inv? #f] #:duplicates [dups '()])
  (sort (for/list ([i (in-list (validate-issues js #:profiles ps #:terminology tx #:invariants? inv? #:duplicates dups))]
                   #:when (equal? (issue-severity i) "error"))
          (cons (issue-code i) (issue-path i)))
        string<? #:key (lambda (p) (format "~a~a" (car p) (cdr p)))))

;; ---- valid resources: no errors -------------------------------------------------------------
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "male"
                            'name (list (hasheq 'family "Chalmers" 'given (list "Peter")))))
              '() "a valid Patient has no errors")
(check-equal? (errs (hasheq 'resourceType "Observation" 'status "final"
                            'code (hasheq 'text "x")))
              '() "a valid Observation has no errors")

;; ---- cardinality: missing required (Observation.status/code are 1..1) ------------------------
(check-equal? (errs (hasheq 'resourceType "Observation"))
              '(("required" . "Observation.code") ("required" . "Observation.status")))

;; ---- cardinality: over max (gender is 0..1) -------------------------------------------------
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender (list "male" "female")))
              '(("structure" . "Patient.gender")))

;; ---- unknown element ------------------------------------------------------------------------
(check-equal? (errs (hasheq 'resourceType "Patient" 'notAField 1))
              '(("structure" . "Patient.notAField")))

;; ---- primitive format (birthDate is a `date`) ----------------------------------------------
(check-equal? (errs (hasheq 'resourceType "Patient" 'birthDate "not-a-date"))
              '(("invalid" . "Patient.birthDate")))

;; ---- duplicate JSON keys (supplied by read-fhir-json/duplicates) -----------------------------
(check-equal? (errs (hasheq 'resourceType "Patient" 'active #t) #:duplicates '("Patient.active"))
              '(("invalid" . "Patient.active")))
(check-equal? (errs (hasheq 'resourceType "Patient" 'active #t) #:duplicates '())  ; none reported -> clean
              '())

;; ---- fixed[x] on a profile ------------------------------------------------------------------
(define fixed-gender-profile
  (hasheq 'resourceType "StructureDefinition" 'id "fg" 'url "http://ex/fg" 'name "FG"
          'type "Patient" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
          'derivation "constraint"
          'differential (hasheq 'element (list (hasheq 'id "Patient.gender" 'path "Patient.gender"
                                                       'fixedCode "female")))))
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "male") #:profiles (list fixed-gender-profile))
              '(("value" . "Patient.gender")) "gender must equal the fixed value")
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "female") #:profiles (list fixed-gender-profile))
              '() "matching fixed value is fine")

;; ---- invariant (opt-in), with an expression our engine evaluates cleanly --------------------
(define name-required-profile
  (hasheq 'resourceType "StructureDefinition" 'id "nr" 'url "http://ex/nr" 'name "NR"
          'type "Patient" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
          'derivation "constraint"
          'differential (hasheq 'element (list (hasheq 'id "Patient" 'path "Patient"
                                                       'constraint (list (hasheq 'key "nr-1" 'severity "error"
                                                                                 'human "must have a name"
                                                                                 'expression "name.exists()")))))))
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "male")
                    #:profiles (list name-required-profile) #:invariants? #t)
              '(("invariant" . "Patient")) "failing invariant fires when invariants are on")
(check-equal? (errs (hasheq 'resourceType "Patient" 'name (list (hasheq 'family "X")))
                    #:profiles (list name-required-profile) #:invariants? #t)
              '() "satisfied invariant does not fire")
;; an invariant that is false only because resolve() could not follow a reference is not decided:
;; the Practitioner is another resource (of a server, a package), not part of what is validated.
;; CARIN Blue Button's `provider.all(resolve() is Practitioner)` refused its own six examples.
(define gp-practitioner-profile
  (hasheq 'resourceType "StructureDefinition" 'id "gp" 'url "http://ex/gp" 'name "GP"
          'type "Patient" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
          'derivation "constraint"
          'differential (hasheq 'element (list (hasheq 'id "Patient" 'path "Patient"
                                                       'constraint (list (hasheq 'key "gp-1" 'severity "error"
                                                                                 'human "the general practitioner is a Practitioner"
                                                                                 'expression "generalPractitioner.all(resolve() is Practitioner)")))))))
(check-equal? (errs (hasheq 'resourceType "Patient" 'generalPractitioner (list (hasheq 'reference "Practitioner/p1")))
                    #:profiles (list gp-practitioner-profile) #:invariants? #t)
              '() "a reference that cannot be followed here: undecided, not reported")
(check-equal? (errs (hasheq 'resourceType "Patient"
                            'contained (list (hasheq 'resourceType "Organization" 'id "o1" 'name "Clinic"))
                            'generalPractitioner (list (hasheq 'reference "#o1")))
                    #:profiles (list gp-practitioner-profile) #:invariants? #t)
              '(("invariant" . "Patient")) "a reference that resolves to something else: broken")
(check-equal? (errs (hasheq 'resourceType "Patient"
                            'contained (list (hasheq 'resourceType "Practitioner" 'id "p1"))
                            'generalPractitioner (list (hasheq 'reference "#p1")))
                    #:profiles (list gp-practitioner-profile) #:invariants? #t)
              '() "a reference that resolves to a Practitioner: holds")

;; invariants are OFF by default (fail-open) — same failing resource, no #:invariants?
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "male") #:profiles (list name-required-profile))
              '() "invariants off by default")

;; ---- required binding via the terminology service -------------------------------------------
(define tx (make-r5-terminology))
;; Patient.gender is required-bound to administrative-gender; a bogus code is code-invalid
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "notagender") #:terminology tx)
              '(("code-invalid" . "Patient.gender")))
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "male") #:terminology tx)
              '() "a valid bound code passes")

;; ---- choice types (value[x]) ---------------------------------------------------------------
;; a valid single variant is accepted
(check-equal? (errs (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                            'valueQuantity (hasheq 'value 5 'unit "mg")))
              '() "a valid value[x] variant is fine")
;; two variants present at once -> exactly-one (max cardinality) on value[x]
(check-equal? (errs (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                            'valueString "a" 'valueInteger 2))
              '(("structure" . "Observation.value[x]")) "only one choice variant allowed")
;; a bad primitive inside a chosen variant is validated on the narrowed type
(check-equal? (errs (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                            'valueBoolean 1))
              '(("invalid" . "Observation.value[x]")) "valueBoolean must be a boolean")
;; a profile that narrows value[x] to Quantity rejects a disallowed variant as an unknown element
(define qty-only
  (hasheq 'resourceType "StructureDefinition" 'id "oq" 'url "http://ex/oq" 'name "OQ"
          'type "Observation" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Observation"
          'derivation "constraint"
          'differential (hasheq 'element (list (hasheq 'id "Observation.value[x]" 'path "Observation.value[x]"
                                                       'type (list (hasheq 'code "Quantity")))))))
(check-equal? (errs (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                            'valueString "hi") #:profiles (list qty-only))
              '(("structure" . "Observation.valueString")) "disallowed choice variant is unknown")
(check-equal? (errs (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                            'valueQuantity (hasheq 'value 5 'unit "mg")) #:profiles (list qty-only))
              '() "the allowed narrowed variant passes")

;; ---- slice members: an entry matching exactly one slice is held to that slice's children ------
(define sliced-components
  (hasheq 'resourceType "StructureDefinition" 'id "sc" 'url "http://ex/sc" 'name "SC"
          'type "Observation" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Observation"
          'derivation "constraint"
          'differential
          (hasheq 'element
                  (list (hasheq 'id "Observation.component" 'path "Observation.component"
                                'slicing (hasheq 'discriminator (list (hasheq 'type "pattern" 'path "code")) 'rules "open"))
                        (hasheq 'id "Observation.component:size" 'path "Observation.component" 'sliceName "size" 'min 0 'max "1")
                        (hasheq 'id "Observation.component:size.code" 'path "Observation.component.code"
                                'patternCodeableConcept (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "33728-7"))))
                        (hasheq 'id "Observation.component:size.value[x]" 'path "Observation.component.value[x]"
                                'min 1 'type (list (hasheq 'code "Quantity")))))))
(define (obs-with component)
  (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x") 'component (list component)))
(define size-code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "33728-7"))))
(check-equal? (errs (obs-with (hasheq 'code size-code 'valueQuantity (hasheq 'value 2 'unit "cm")))
                    #:profiles (list sliced-components))
              '() "a member with the slice's type passes")
(check-equal? (errs (obs-with (hasheq 'code size-code 'valueString "big")) #:profiles (list sliced-components))
              '(("required" . "Observation.component.value[x]") ("structure" . "Observation.component.value[x]"))
              "the slice's type and min apply to its member")
(check-equal? (errs (obs-with (hasheq 'code (hasheq 'text "other") 'valueString "big")) #:profiles (list sliced-components))
              '() "an entry matching no slice is only held to the unsliced element")

;; ---- required binding WITHOUT a tx-service: the generated offline expansions decide -----------
;; (model/binding.rkt, populated by fhir/r5's terminology.rkt — required via fhir/r5/schemas)
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "notagender"))
              '(("code-invalid" . "Patient.gender")) "offline expansion catches a bad required-bound code")
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "male"))
              '() "a valid code passes offline")

;; ---- a Quantity coded in UCUM carries a UCUM code ------------------------------------------
;; (a new user wrote `130 'mmHg'`: nothing said it is not UCUM, only their own rule refused it)
(define (bp-with unit) (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                               'valueQuantity (hasheq 'value 130 'system "http://unitsofmeasure.org" 'code unit)))
(check-equal? (errs (bp-with "mmHg")) '() "a warning: HL7's published examples write m^2")
(check-equal? (map issue-severity (validate-issues (bp-with "mmHg"))) '("warning"))
(check-equal? (errs (bp-with "mm[Hg]")) '())
(check-equal? (map issue-msg (validate-issues (bp-with "mmHg"))) '("`mmHg` is not a UCUM unit (mercury is written mm[Hg])"))
(check-equal? (errs (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                            'valueQuantity (hasheq 'value 130 'unit "mmHg")))
              '() "no system: the unit is free text")

;; ---- the calendar: the regex allows day 31 in every month (a new user's 1940-02-30 was "All OK") ---
(check-equal? (errs (hasheq 'resourceType "Patient" 'birthDate "1940-02-30"))
              '(("invalid" . "Patient.birthDate")))
(check-equal? (errs (hasheq 'resourceType "Patient" 'birthDate "2000-02-29")) '())
(check-equal? (errs (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                            'effectiveDateTime "2024-04-31T10:00:00Z"))
              '(("invalid" . "Observation.effective[x]")))
(check-regexp-match #rx"'1940-02-30' is not a valid date [(]February 1940 has 29 days[)]"
                    (issue-msg (car (validate-issues (hasheq 'resourceType "Patient" 'birthDate "1940-02-30")))))

;; ---- a claimed profile the resource was not held to is said (a Patient claiming US Core, validated
;; with the core package alone, was "All OK") -------------------------------------------------------
(let* ([claims (lambda (url) (hasheq 'resourceType "Patient" 'gender "female" 'meta (hasheq 'profile (list url))))]
       [unknown "http://example.org/StructureDefinition/nowhere"]
       [warnings (lambda (js #:profiles [ps '()])
                   (for/list ([i (in-list (validate-issues js #:profiles ps))] #:when (equal? (issue-severity i) "warning"))
                     (list (issue-code i) (issue-path i))))])
  (check-equal? (warnings (claims unknown)) '(("not-found" "Patient.meta.profile[0]")))
  (check-regexp-match #rx"claims profile `http://example.org/StructureDefinition/nowhere`, but nothing in context defines it: it was not checked"
                      (issue-msg (car (validate-issues (claims unknown)))))
  (check-equal? (errs (claims unknown)) '() "a warning: what was checked is still clean")
  ;; a profile given in the call, or one the packages define, is checked and nothing is said
  (check-equal? (warnings (claims (hash-ref fixed-gender-profile 'url)) #:profiles (list fixed-gender-profile)) '())
  (check-equal? (warnings (hasheq 'resourceType "Patient" 'gender "female")) '()))

;; ---- a slice of `extension` typed by an extension's profile is the entries with that url: a profile
;; requiring one particular extension was met by any extension at all -------------------------------
(let* ([ward "http://ex/StructureDefinition/ward"]
       [profile (hasheq 'resourceType "StructureDefinition" 'id "wp" 'url "http://ex/wp" 'name "WP"
                        'type "Patient" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
                        'derivation "constraint"
                        'differential
                        (hasheq 'element
                                (list (hasheq 'id "Patient.extension" 'path "Patient.extension" 'min 1
                                              'slicing (hasheq 'discriminator (list (hasheq 'type "value" 'path "url")) 'rules "open"))
                                      (hasheq 'id "Patient.extension:ward" 'path "Patient.extension" 'sliceName "ward"
                                              'min 1 'max "1"
                                              'type (list (hasheq 'code "Extension" 'profile (list ward)))))))]
       [patient (lambda (url) (hasheq 'resourceType "Patient"
                                      'extension (list (hasheq 'url url 'valueString "3B"))))])
  (check-equal? (errs (patient ward) #:profiles (list profile)) '())
  (check-equal? (errs (patient "http://ex/StructureDefinition/bed") #:profiles (list profile))
                '(("required" . "Patient.extension"))))

;; ---- inside an extension: it was skipped whole (an abstract type), so nothing in one was checked.
;; An extension is held to the Extension datatype — or to its own definition, when the packages
;; hold the one its url names — and to ext-1 (a value or extensions: one of the two) ---------------
(let ([patient (lambda (ext) (hasheq 'resourceType "Patient" 'extension (list ext)))]
      [url "http://example.org/StructureDefinition/shoe-size"])
  (check-equal? (errs (patient (hasheq 'url url 'valueInteger 42))) '())
  (check-equal? (errs (patient (hasheq 'url url 'valueInteger 42 'notAnElement "x")))
                '(("structure" . "Extension.notAnElement")))
  (check-equal? (errs (patient (hasheq 'url url 'valueDate "2024-02-30")))
                '(("invalid" . "Extension.value[x]")))
  (check-equal? (errs (patient (hasheq 'url url 'valueColour "red")))
                '(("structure" . "Extension.valueColour")) "no such type of value")
  ;; ext-1, decided on the JSON
  (check-equal? (errs (patient (hasheq 'url url))) '(("invariant" . "Patient.extension")))
  (check-equal? (errs (patient (hasheq 'url url 'valueInteger 1 'extension (list (hasheq 'url "part" 'valueInteger 2)))))
                '(("invariant" . "Patient.extension")))
  (check-equal? (errs (patient (hasheq 'url url 'extension (list (hasheq 'url "part" 'valueInteger 2))))) '())
  (check-equal? (errs (patient (hasheq 'url url '_valueString (hasheq 'extension (list (hasheq 'url "http://hl7.org/fhir/StructureDefinition/data-absent-reason" 'valueCode "unknown"))))))
                '() "a value given by its _value sibling is a value")
  ;; an extension the packages define is held to its definition: patient-birthPlace (in the R4
  ;; core package; R5's holds no extension) takes an Address
  (parameterize ([current-sd-packages (list (path->string (spec-package-path "hl7.fhir.r4.core.tgz")))])
    (define birth-place "http://hl7.org/fhir/StructureDefinition/patient-birthPlace")
    (check-equal? (errs (patient (hasheq 'url birth-place 'valueAddress (hasheq 'city "Leiden")))) '())
    (check-equal? (errs (patient (hasheq 'url birth-place 'valueString "Leiden")))
                  '(("required" . "Extension.value[x]") ("structure" . "Extension.valueString"))
                  "not the type its definition gives, so the value it requires is not there")
    ;; a core package's copy of an extension is held for its shape, not for its bindings: the
    ;; value sets have grown since (US Core's and mCODE's own value sets carry work group `cgp`,
    ;; which FHIR 4.0.1's hl7-work-group lacks)
    (define work-group "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg")
    (check-equal? (errs (patient (hasheq 'url work-group 'valueCode "cgp"))) '())
    (check-equal? (errs (patient (hasheq 'url work-group 'valueInteger 3)))
                  '(("required" . "Extension.value[x]") ("structure" . "Extension.valueInteger")))
    ;; one nobody defines is held to the Extension datatype alone
    (check-equal? (errs (patient (hasheq 'url url 'valueString "Leiden"))) '())))

;; ---- `{}` holds nothing --------------------------------------------------------------------------
(check-equal? (errs (hasheq 'resourceType "Patient" 'managingOrganization (hasheq)))
              '(("structure" . "Patient.managingOrganization")))

;; ---- a code its code system does not have: the packages hold administrative-gender whole, so a
;; Coding of it with another code names nothing — whatever the binding (maritalStatus's is
;; extensible). A system nothing here defines decides nothing. -------------------------------------
(let ([married (lambda (system code) (hasheq 'resourceType "Patient" 'maritalStatus (hasheq 'coding (list (hasheq 'system system 'code code)))))])
  (check-equal? (errs (married "http://hl7.org/fhir/administrative-gender" "female")) '())
  (check-equal? (errs (married "http://hl7.org/fhir/administrative-gender" "florp")) '(("code-invalid" . "CodeableConcept.coding.code")))
  (check-regexp-match #rx"`florp` is not a code of http://hl7.org/fhir/administrative-gender"
                      (issue-msg (car (validate-issues (married "http://hl7.org/fhir/administrative-gender" "florp")))))
  (check-equal? (errs (married "http://example.org/nobody-knows" "florp")) '()))

;; ---- a required binding on a coded value counts the coding's SYSTEM: `female` of some other
;; system is not a code of the value set (membership was asked by the code alone) -----------------
(let* ([profile (hasheq 'resourceType "StructureDefinition" 'id "ms" 'url "http://ex/ms" 'name "MS"
                        'type "Patient" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
                        'derivation "constraint"
                        'differential
                        (hasheq 'element
                                (list (hasheq 'id "Patient.maritalStatus" 'path "Patient.maritalStatus"
                                              'binding (hasheq 'strength "required" 'valueSet "http://hl7.org/fhir/ValueSet/administrative-gender")))))]
       [patient (lambda (system) (hasheq 'resourceType "Patient" 'maritalStatus (hasheq 'coding (list (hasheq 'system system 'code "female")))))])
  (check-equal? (errs (patient "http://hl7.org/fhir/administrative-gender") #:profiles (list profile)) '())
  (check-equal? (errs (patient "http://example.org/not-a-code-system") #:profiles (list profile))
                '(("code-invalid" . "Patient.maritalStatus"))))

;; a value set that NAMES the coding's system but whose expansion holds none of its codes (the
;; system's content is not in context) cannot say: CARIN Blue Button's payee types are the guide's
;; own code and codes of a terminology.hl7.org system; its own examples were refused
(let* ([mixed (hasheq 'resourceType "ValueSet" 'id "mixed" 'url "http://ex/ValueSet/mixed" 'status "active"
                      'compose (hasheq 'include (list (hasheq 'system "http://hl7.org/fhir/administrative-gender" 'concept (list (hasheq 'code "female")))
                                                      (hasheq 'system "http://example.org/a-system-not-here"))))]
       [profile (hasheq 'resourceType "StructureDefinition" 'id "mx" 'url "http://ex/mx" 'name "MX"
                        'type "Patient" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
                        'derivation "constraint"
                        'differential
                        (hasheq 'element
                                (list (hasheq 'id "Patient.maritalStatus" 'path "Patient.maritalStatus"
                                              'binding (hasheq 'strength "required" 'valueSet "http://ex/ValueSet/mixed")))))]
       [tx (resources->resolver (list mixed))]
       [patient (lambda (system code) (hasheq 'resourceType "Patient" 'maritalStatus (hasheq 'coding (list (hasheq 'system system 'code code)))))])
  (check-equal? (errs (patient "http://hl7.org/fhir/administrative-gender" "female") #:profiles (list profile) #:terminology tx) '())
  (check-equal? (errs (patient "http://example.org/a-system-not-here" "y") #:profiles (list profile) #:terminology tx) '()
                "a system the value set takes whole and nothing here holds: cannot say")
  (check-equal? (errs (patient "http://example.org/another-system" "x") #:profiles (list profile) #:terminology tx)
                '(("code-invalid" . "Patient.maritalStatus")) "a system the value set never names"))

;; ---- a slice told by the value set its codes come from (a value discriminator, a required binding
;; and no pattern: US Core's Condition.category:us-core), and a slice's maximum ---------------------
(let* ([profile (hasheq 'resourceType "StructureDefinition" 'id "sx" 'url "http://ex/sx" 'name "SX"
                        'type "Observation" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Observation"
                        'derivation "constraint"
                        'differential
                        (hasheq 'element
                                (list (hasheq 'id "Observation.category" 'path "Observation.category" 'min 1
                                              'slicing (hasheq 'discriminator (list (hasheq 'type "value" 'path "$this")) 'rules "open"))
                                      (hasheq 'id "Observation.category:sex" 'path "Observation.category" 'sliceName "sex"
                                              'min 1 'max "1"
                                              'binding (hasheq 'strength "required" 'valueSet "http://hl7.org/fhir/ValueSet/administrative-gender")))))]
       [gender (lambda (code) (hasheq 'coding (list (hasheq 'system "http://hl7.org/fhir/administrative-gender" 'code code))))]
       [observation (lambda categories (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x") 'category categories))])
  (check-equal? (errs (observation (gender "female")) #:profiles (list profile)) '())
  (check-equal? (errs (observation (gender "female") (hasheq 'text "another kind")) #:profiles (list profile)) '())
  (check-equal? (errs (observation (hasheq 'coding (list (hasheq 'system "http://example.org/other" 'code "x")))) #:profiles (list profile))
                '(("required" . "Observation.category")) "no category of the slice's value set")
  (check-equal? (errs (observation (gender "female") (gender "male")) #:profiles (list profile))
                '(("structure" . "Observation.category")) "more of the slice than it allows"))

;; ---- a datatype's own invariants, at each value of the type (a ContactPoint's cpt-2 is on
;; ContactPoint's definition, not on the elements typed by it) --------------------------------------
(check-equal? (errs (hasheq 'resourceType "Patient" 'telecom (list (hasheq 'system "phone" 'value "555"))) #:invariants? #t) '())
(check-equal? (errs (hasheq 'resourceType "Patient" 'telecom (list (hasheq 'system "phone" 'value "555") (hasheq 'value "556"))) #:invariants? #t)
              '(("invariant" . "Patient.telecom[1]")))
(check-regexp-match #rx"cpt-2"
                    (issue-msg (car (validate-issues (hasheq 'resourceType "Patient" 'telecom (list (hasheq 'value "556")))))))

;; ---- a coding that names no system is in no value set the validator can decide; a required
;; CodeableConcept holds a code (its text is not one) ----------------------------------------------
(let* ([profile (hasheq 'resourceType "StructureDefinition" 'id "rq" 'url "http://ex/rq" 'name "RQ"
                        'type "Observation" 'baseDefinition "http://hl7.org/fhir/StructureDefinition/Observation"
                        'derivation "constraint"
                        'differential
                        (hasheq 'element
                                (list (hasheq 'id "Observation.code" 'path "Observation.code"
                                              'binding (hasheq 'strength "required" 'valueSet "http://hl7.org/fhir/ValueSet/administrative-gender")))))]
       [observation (lambda (code) (hasheq 'resourceType "Observation" 'status "final" 'code code))])
  (check-equal? (errs (observation (hasheq 'coding (list (hasheq 'system "http://hl7.org/fhir/administrative-gender" 'code "female"))))
                      #:profiles (list profile))
                '())
  (check-equal? (errs (observation (hasheq 'coding (list (hasheq 'code "female")))) #:profiles (list profile))
                '(("code-invalid" . "Observation.code")) "a coding with no system")
  (check-equal? (errs (observation (hasheq 'text "female")) #:profiles (list profile))
                '(("code-invalid" . "Observation.code")) "text alone under a required binding"))
;; a value set whose code systems are not here decides nothing, with or without a system
(check-equal? (errs (hasheq 'resourceType "Condition" 'subject (hasheq 'reference "Patient/x")
                            'clinicalStatus (hasheq 'coding (list (hasheq 'code "active")))))
              '())

;; ---- where an issue is in the instance -------------------------------------------------------
;; the definition's path is what tracing to a rule reads; the location names the JSON's own keys
;; and each list entry's index, inside a datatype too, and is the OperationOutcome's expression
(let ([located (lambda (js)
                 (sort (for/list ([i (in-list (validate-issues js #:invariants? #f))] #:when (equal? (issue-severity i) "error"))
                         (list (issue-path i) (issue-location i)))
                       string<? #:key cadr))])
  (check-equal? (located (hasheq 'resourceType "Patient"
                                 'name (list (hasheq 'family "A") (hasheq 'given (list "x" 1) 'nmae 1))
                                 'contact (list (hasheq 'name (hasheq 'family "B" 'nope #t)))))
                '(("HumanName.nope" "Patient.contact[0].name.nope")
                  ("HumanName.given" "Patient.name[1].given[1]")
                  ("HumanName.nmae" "Patient.name[1].nmae")))
  ;; two entries with the same mistake are two issues
  (check-equal? (length (located (hasheq 'resourceType "Patient" 'name (list (hasheq 'nmae 1) (hasheq 'nmae 1))))) 2)
  ;; a choice element by the key the JSON writes
  (check-equal? (located (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "x")
                                 'valueQuantity (hasheq 'value "5")))
                '(("Quantity.value" "Observation.valueQuantity.value"))))

;; ---- a best practice rule is a warning -------------------------------------------------------
;; a constraint with the elementdefinition-bestpractice extension, whatever its own severity, is
;; reported as a warning (SDC's sdcqr-2 in US Core's QuestionnaireResponse profile is one)
(let* ([rule (lambda (best?)
               (hasheq 'resourceType "StructureDefinition" 'url (if best? "http://example.org/bp" "http://example.org/strict")
                       'type "Patient" 'derivation "constraint" 'kind "resource" 'abstract #f
                       'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
                       'differential
                       (hasheq 'element
                               (list (hasheq 'id "Patient" 'path "Patient"
                                             'constraint
                                             (list (let ([c (hasheq 'key "bp-1" 'severity "error" 'human "a name"
                                                                    'expression "name.exists()")])
                                                     (if best?
                                                         (hash-set c 'extension (list (hasheq 'url "http://hl7.org/fhir/StructureDefinition/elementdefinition-bestpractice" 'valueBoolean #t)))
                                                         c))))))))]
       [severities (lambda (best?)
                     (for/list ([i (in-list (validate-issues (hasheq 'resourceType "Patient") #:profiles (list (rule best?)) #:invariants? #t))]
                                #:when (regexp-match? #rx"^bp-1" (issue-msg i)))
                       (issue-severity i)))])
  (check-equal? (severities #f) '("error"))
  (check-equal? (severities #t) '("warning")))
