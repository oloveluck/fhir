#lang info

;; fhir — FHIR as a family of Racket #langs (language-oriented programming).
;;
;; This is the APPLICATION layer of the family and the umbrella package: the StructureDefinition-
;; driven apps and services (capability lang + HTTP, terminology service, validator, SQL-on-FHIR
;; and OMOP towers, the SQLite/DuckDB store), the `raco fhir` CLI, the integration tests and the
;; examples. The foundation (model, primitives, codegen, generated towers) is `fhir-core`; the
;; stand-alone languages are `fhir-fhirpath`, `fhir-vcl`, `fhir-cql`, `fhir-fml`, `fhir-fsh`.
;; Every package declares collection "fhir", so they splice into ONE `fhir` collection and all
;; module paths / #lang names are unchanged. Installing this package pulls in the whole family.

(define collection "fhir")
(define version "0.2")

(define deps
  '("base"
    "fhir-core"        ; foundation + towers (static)
    "fhir-fhirpath"    ; store/capability/conformance/terminology evaluate FHIRPath (static)
    "fhir-vcl"         ; terminology/service.rkt expands implicit VCL ValueSets (static)
    "fhir-cql"         ; raco fhir cql / cql-tck (loaded dynamically by the CLI)
    "fhir-fml"         ; raco fhir fml-tck (dynamic)
    "fhir-fsh"         ; raco fhir fsh / gofsh (dynamic)
    "db-lib"))         ; the persistence engine (store/) — SQLite via the db collection
;; system dependency for store/fhir-analytics.rkt: libduckdb (e.g. `brew install duckdb`)

(define build-deps '("rackunit-lib"))

(define pkg-desc "FHIR as a family of languages — application layer and umbrella (capability/HTTP, terminology, validation, SQL-on-FHIR, OMOP, store, CLI)")
(define pkg-authors '(oloveluck))

;; `raco fhir <subcommand>` — codegen and tooling (regen / check / roundtrip / the TCK runners).
(define raco-commands
  '(("fhir" (submod fhir/cli/raco-fhir main) "generate and check the FHIR type towers" #f)))
