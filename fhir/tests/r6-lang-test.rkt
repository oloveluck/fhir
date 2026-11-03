#lang racket/base

;;; r6-lang-test.rkt — the generated R6 tower, end to end: author via the type macros, serialize to
;;; JSON, round-trip back to an equal typed node, and confirm malformed authoring fails at COMPILE
;;; time. This is the vertical slice's headline test.

(require rackunit
         syntax/macro-testing
         fhir/r6/types                        ; the generated form macros (Patient, HumanName, …)
         fhir/model/node
         fhir/result/result
         fhir/serialize/to-json
         fhir/serialize/from-json)

;; --- author a Patient with nested datatypes, a backbone, a list, and a choice ------------------
(define pat
  (Patient
   (id "example")
   (active #t)
   (name (HumanName (use "official") (family "Chalmers") (given "Peter" "James")
                    (period (Period (start "1974-12-25")))))
   (gender "male")
   (birthDate "1974-12-25")
   (maritalStatus (CodeableConcept
                   (coding (Coding (system "http://terminology.hl7.org/CodeSystem/v3-MaritalStatus")
                                   (code "M") (display "Married")))
                   (text "Married")))
   (deceasedBoolean #f)
   (contact (PatientContact
             (relationship (CodeableConcept (text "Emergency Contact")))
             (name (HumanName (family "du Marché") (given "Bénédicte")))
             (gender "female")))))

(check-equal? (fhir-type pat) 'Patient)

(define expected
  (hasheq 'resourceType "Patient"
          'id "example"
          'active #t
          'name (list (hasheq 'use "official" 'family "Chalmers" 'given '("Peter" "James")
                              'period (hasheq 'start "1974-12-25")))
          'gender "male"
          'birthDate "1974-12-25"
          'maritalStatus (hasheq 'coding (list (hasheq 'system "http://terminology.hl7.org/CodeSystem/v3-MaritalStatus"
                                                       'code "M" 'display "Married"))
                                 'text "Married")
          'deceasedBoolean #f
          'contact (list (hasheq 'relationship (list (hasheq 'text "Emergency Contact"))
                                 'name (hasheq 'family "du Marché" 'given '("Bénédicte"))
                                 'gender "female"))))

(check-equal? (node->jsexpr pat) expected)

;; --- round-trip: JSON -> node -> JSON, and the node is structurally equal --------------------
(check-equal? (from-json (node->jsexpr pat)) (ok pat))
(check-equal? (result-map node->jsexpr (from-json (node->jsexpr pat))) (ok expected))

;; --- malformed authoring fails at COMPILE time -----------------------------------------------
(check-exn #rx"invalid date value"
           (lambda () (convert-compile-time-error (Patient (birthDate "1974-13-40")))))
(check-exn #rx"unknown field Patient"
           (lambda () (convert-compile-time-error (Patient (notAField "x")))))
(check-exn #rx"expects a HumanName"
           (lambda () (convert-compile-time-error (Patient (name (Coding (code "x")))))))
(check-exn #rx"single-valued"
           (lambda () (convert-compile-time-error (Patient (birthDate "1974" "1975")))))
(check-exn #rx"invalid code value"
           (lambda () (convert-compile-time-error (Patient (gender " bad")))))
