#lang racket/base

;;; determinism-test.rkt — the committed type towers must byte-match a fresh regeneration. If this
;;; fails, either a generated file was hand-edited or the generator became nondeterministic; run
;;; `raco fhir regen` to restore.

(require rackunit
         fhir/codegen/check
         fhir/codegen/target)

(check-equal? (check-tower target-r6) '() "fhir/r6 is up to date")
(check-equal? (check-tower target-r4) '() "fhir/r4 is up to date")
