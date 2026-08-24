#lang info

;; fhir — FHIR as a family of Racket #langs (language-oriented programming).
;;
;; A single collection `fhir`: the foundation type framework, the primitive type system,
;; the compile-time validating form-macro machinery, the JSON serializer, and the spec-driven
;; codegen that emits the versioned type towers (#lang fhir/r6, #lang fhir/r4).

(define collection "fhir")
(define version "0.1")

(define deps
  '("base"
    "brag-lib"
    "rackunit-lib"
    "db-lib"))     ; the persistence engine (store/) — SQLite via the db collection
;; system dependency for store/fhir-analytics.rkt: libduckdb (e.g. `brew install duckdb`)

(define build-deps '())

(define pkg-desc "FHIR as a family of languages (foundation types, primitives, codegen)")
(define pkg-authors '(oloveluck))

;; `raco fhir <subcommand>` — codegen and tooling (regen / check / roundtrip).
(define raco-commands
  '(("fhir" (submod fhir/cli/raco-fhir main) "generate and check the FHIR type towers" #f)))
