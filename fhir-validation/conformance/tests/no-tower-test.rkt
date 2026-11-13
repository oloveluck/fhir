#lang racket/base

;;; $validate from a program that has loaded no FHIR version (no fhir/r5/schemas): a required code
;;; is still checked. The terminology service answered typed nodes, which nothing could build
;;; without a tower, so `"gender": "florp"` was "All OK (FHIR R5 (5.0.0))" — and refused as soon as
;;; the same program required a tower for any other reason. This file must require NO tower.

(require rackunit
         (only-in fhir/operation apply-operation/outcome)
         fhir/conformance/operations)

(define (issues r) (hash-ref (apply-operation/outcome "$validate" r) 'issue))
(define (errors r) (for/list ([i (in-list (issues r))] #:when (equal? (hash-ref i 'severity) "error"))
                     (cons (hash-ref i 'code) (car (hash-ref i 'expression '(#f))))))

(check-equal? (errors (hasheq 'resourceType "Patient" 'gender "florp")) '(("code-invalid" . "Patient.gender")))
(check-equal? (errors (hasheq 'resourceType "Patient" 'gender "female")) '())
