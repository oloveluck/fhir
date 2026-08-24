#lang racket/base

;;; run-r5.rkt — run the official FHIRPath R5 test suite (requires the full R5 tower so from-json
;;; can parse every input resource). `racket fhirpath/tests/run-r5.rkt`.

(require racket/runtime-path
         (only-in fhir/r5/schemas)          ; register every R5 type
         (only-in fhir/terminology/service make-r5-terminology)
         "harness.rkt")

(define-runtime-path here ".")

(module+ main
  (run-suite (build-path here "vendor" "tests-fhir-r5.xml")
             (build-path here "inputs")
             #:terminology (make-r5-terminology)))
