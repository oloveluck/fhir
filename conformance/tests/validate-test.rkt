#lang racket/base

;;; validate-test.rkt — authored validation cases, one per check. Each asserts the exact set of
;;; ERROR issues by {code, path}. The primary oracle (the official corpus can't be matched message-for-
;;; message against the Java validator).

(require rackunit
         racket/list
         (only-in fhir/r5/schemas)
         (only-in fhir/terminology/service make-r5-terminology)
         (only-in fhir/conformance/validate
                  validate-issues issue-severity issue-code issue-path issue-msg))

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

;; ---- required binding WITHOUT a tx-service: the generated offline expansions decide -----------
;; (model/binding.rkt, populated by fhir/r5's terminology.rkt — required via fhir/r5/schemas)
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "notagender"))
              '(("code-invalid" . "Patient.gender")) "offline expansion catches a bad required-bound code")
(check-equal? (errs (hasheq 'resourceType "Patient" 'gender "male"))
              '() "a valid code passes offline")
