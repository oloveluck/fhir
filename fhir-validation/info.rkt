#lang info

;; fhir-validation — validate FHIR resources against their base types and profiles.
;;
;; The validator (conformance/validate: cardinality, unknown elements, choice types, primitive formats,
;; fixed/pattern values, required bindings, value/pattern slicing including slice members, optional
;; FHIRPath invariants; fail-open on anything undecidable) and the terminology service it uses for
;; bindings ($expand, $validate-code, $lookup, $translate over FHIR packages). Profiles and base
;; definitions resolve through fhir/sd's package index, so an IG's dependencies validate in context.
;; Contributes to the `fhir` collection (module-disjoint from the foundation and fhir-server).

(define collection "fhir")
(define version "0.3")
(define pkg-desc "FHIR validation for Racket: a fail-open profile validator (cardinality, types, slicing, bindings, invariants) and a terminology service, `raco fhir-validate`")
(define pkg-authors '(oloveluck))
(define license 'MIT)
(define deps '("base" "fhir" "fhir-spec" "fhirpath" "vcl"))
(define build-deps '("rackunit-lib"))
(define raco-commands
  '(("fhir-validate" (submod fhir/validate-cli main) "validate FHIR resources against base types and profiles; run the terminology suite" #f)))
(define test-omit-paths (quote ("tests/vendor" "conformance/tests/vendor")))
