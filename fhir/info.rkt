#lang info

;; fhir — FHIR as a family of Racket #langs: the FOUNDATION package.
;;
;; The Result type, the typed-node model and registry, the primitive type system, the compile-time
;; validating form macros, the JSON (de)serializer, StructureDefinition tooling (#lang fhir/sd +
;; snapshot generation), the spec-driven codegen and the generated R4/R5/R6 type towers
;; (#lang fhir/r6, #lang fhir/r4). The stand-alone languages (fhirpath, cql, fsh, vcl, fml) and the
;; application layer (fhir-tools) build on this package.
;;
;; fhir-spec (the vendored HL7 packages, 50 MB) is a runtime-OPTIONAL data dependency located via
;; fhir/spec-package: codegen (`raco fhir regen`) and full snapshot generation need it;
;; `raco pkg install fhir-spec`.

(define collection "fhir")
(define version "0.3")
(define pkg-desc "FHIR as a family of Racket #langs — the foundation: Result type, typed node model, primitives, compile-time form macros, JSON (de)serializer, #lang fhir/sd + snapshot generation, spec-driven codegen and the generated R4/R5/R6 towers (#lang fhir/r6, #lang fhir/r4)")
(define pkg-authors '(oloveluck))
(define license 'MIT)
(define deps '("base"))
(define build-deps '("rackunit-lib"))
;; the generated towers carry no tests (their behaviour is tested through fhir-tools' suites and
;; `raco fhir check`); skipping them keeps `raco test -p fhir` to seconds.
(define test-omit-paths '("r4" "r5" "r6"))
