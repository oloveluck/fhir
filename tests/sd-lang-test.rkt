#lang racket/base

;;; sd-lang-test.rkt — the StructureDefinition / profiling language and #:delegate depth.
;;;
;;; Authoring against a profile validates the profile's constraints at COMPILE time, then delegates
;;; to the base type's macro (and, for a profile-of-profile, down another level) to build the base
;;; resource. Loosening a cardinality in a profile definition is a compile error.

(require rackunit
         syntax/macro-testing
         "../examples/us-core.sd"             ; provides USCorePatient, VIPPatient
         fhir/r6/types                         ; HumanName for authoring
         fhir/model/node
         fhir/serialize/to-json)

;; --- a profile builds the BASE resource (a US Core Patient IS a Patient) ----------------------
(define p (USCorePatient
           (name (HumanName (family "Chalmers") (given "Peter")))
           (gender "male")))
(check-equal? (fhir-type p) 'Patient)                       ; delegated down to the base build
(check-equal? (hash-ref (node->jsexpr p) 'resourceType) "Patient")
(check-equal? (hash-ref (node->jsexpr p) 'gender) "male")

;; USCorePatient keeps name at 1..* — two names is fine
(check-equal? (length (hash-ref (node->jsexpr
                                 (USCorePatient (gender "female")
                                                (name (HumanName (family "A"))
                                                      (HumanName (family "B")))))
                                'name))
              2)

;; --- 2-level delegation: VIPPatient -> USCorePatient -> Patient -------------------------------
(define vip (VIPPatient (name (HumanName (family "Vip"))) (gender "other")))
(check-equal? (fhir-type vip) 'Patient)
(check-equal? (hash-ref (node->jsexpr vip) 'gender) "other")

;; --- the profile's tightened constraints fail at COMPILE time ---------------------------------
;; USCorePatient makes name required
(check-exn #rx"missing required field USCorePatient.name"
           (lambda () (convert-compile-time-error (USCorePatient (gender "male")))))
;; USCorePatient makes gender required
(check-exn #rx"missing required field USCorePatient.gender"
           (lambda () (convert-compile-time-error (USCorePatient (name (HumanName (family "X")))))))
;; VIPPatient narrows name to 1..1 — two values is now single-valued
(check-exn #rx"single-valued"
           (lambda () (convert-compile-time-error
                       (VIPPatient (gender "male")
                                   (name (HumanName (family "A")) (HumanName (family "B")))))))
;; the base type's own validation still applies through the delegate (bad primitive literal)
(check-exn #rx"invalid code value"
           (lambda () (convert-compile-time-error
                       (USCorePatient (name (HumanName (family "X"))) (gender " bad")))))
