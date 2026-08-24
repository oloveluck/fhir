#lang racket/base

;;; form-syntax-test.rkt — exercise the compile-time form macro end-to-end against a hand-built
;;; schema (the codegen tests do the same on generated modules). Proves: good trees build correct
;;; typed nodes that serialize + round-trip, and bad trees fail at COMPILE time with located errors.

(require rackunit
         syntax/macro-testing               ; convert-compile-time-error
         (for-syntax racket/base
                     (only-in "../lang-gen/form-syntax.rkt" build-fhir-form))
         "../model/node.rkt"
         "../model/schema.rkt"
         "../model/registry.rkt"
         "../result/result.rkt"
         "../serialize/to-json.rkt"
         "../serialize/from-json.rkt"
         (only-in "../primitives/primitives.rkt" primitive->jsexpr))

;; --- register runtime schemas (what the generator would emit) ---------------------------------
(define HN-URL "https://build.fhir.org/datatypes.html#HumanName")
(register-type! 'HumanName (fhir-spec 'HumanName HN-URL 'type)
  #:schema (type-schema 'HumanName #f 'DataType HN-URL
             (list (schema-field 'use    0 1   #(prim "code")   #f (string-append HN-URL ".use") #f)
                   (schema-field 'family 0 1   #(prim "string") #f (string-append HN-URL ".family") #f)
                   (schema-field 'given  0 '*  #(prim "string") #f (string-append HN-URL ".given") #f))
             #f #f))

(define PT-URL "https://build.fhir.org/patient.html")
(register-type! 'Patient (fhir-spec 'Patient PT-URL 'type)
  #:schema (type-schema 'Patient #f 'DomainResource PT-URL
             (list (schema-field 'active    0 1  #(prim "boolean") #f (string-append PT-URL "#active") #f)
                   (schema-field 'name      0 '* #(type HumanName)  #f (string-append PT-URL "#name") #f)
                   (schema-field 'birthDate 0 1  #(prim "date")     #f (string-append PT-URL "#birthDate") #f))
             #f #f))

;; --- define the form macros (what emit-form would emit) --------------------------------------
(define-syntax (HumanName stx)
  (build-fhir-form stx 'HumanName
    '(#s(field-spec use 0 1 #(prim "code") #f)
      #s(field-spec family 0 1 #(prim "string") #f)
      #s(field-spec given 0 * #(prim "string") #f))
    #:parent 'DataType))

(define-syntax (Patient stx)
  (build-fhir-form stx 'Patient
    '(#s(field-spec id 0 1 #(raw) #f)
      #s(field-spec active 0 1 #(prim "boolean") #f)
      #s(field-spec name 0 * #(type HumanName) #f)
      #s(field-spec birthDate 0 1 #(prim "date") #f))
    #:parent 'DomainResource))

;; --- good trees build correct typed nodes -----------------------------------------------------
(define hn (HumanName (use "official") (family "Chalmers") (given "Eve" "A")))
(check-equal? (fhir-type hn) 'HumanName)
(check-equal? (node->jsexpr hn) (hasheq 'use "official" 'family "Chalmers" 'given '("Eve" "A")))

(define pat (Patient (id "example")
                     (active #t)
                     (name (HumanName (family "Chalmers") (given "Peter")))
                     (birthDate "1974-12-25")))
(check-equal? (node->jsexpr pat)
              (hasheq 'resourceType "Patient"
                      'id "example"
                      'active #t
                      'name (list (hasheq 'family "Chalmers" 'given '("Peter")))
                      'birthDate "1974-12-25"))

;; --- round-trip: parse the JSON back to an equal node -----------------------------------------
(define j (node->jsexpr pat))
(check-equal? (from-json j) (ok pat))
(check-equal? (result-map node->jsexpr (from-json j)) (ok j))

;; --- bad trees fail at COMPILE time with located errors ---------------------------------------
(check-exn #rx"invalid date value"
           (lambda () (convert-compile-time-error (Patient (birthDate "1974-13-40")))))
(check-exn #rx"unknown field Patient.foo"
           (lambda () (convert-compile-time-error (Patient (foo "x")))))
(check-exn #rx"expects a HumanName"
           (lambda () (convert-compile-time-error (Patient (name (Patient))))))
(check-exn #rx"single-valued"
           (lambda () (convert-compile-time-error (Patient (birthDate "1974" "1975")))))
(check-exn #rx"invalid code value"
           (lambda () (convert-compile-time-error (HumanName (use " leading-space")))))
