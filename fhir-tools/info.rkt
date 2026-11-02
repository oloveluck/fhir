#lang info

;; fhir-tools — FHIR as a family of Racket #langs: the APPLICATION layer and the `raco fhir` CLI.
;;
;; #lang fhir/capability + the HTTP server, the terminology service, the validator, SQL-on-FHIR
;; (#lang fhir/viewdef), OMOP (#lang fhir/omop), the SQLite/DuckDB store, the integration tests and
;; the examples. Contributes to the `fhir` collection alongside the foundation package `fhir`
;; (the two are module-disjoint).

(define collection "fhir")
(define version "0.3")
(define pkg-desc "FHIR tooling for Racket: #lang fhir/capability + HTTP server, terminology service, validator, SQL-on-FHIR (#lang fhir/viewdef), OMOP (#lang fhir/omop), SQLite/DuckDB store, the raco fhir CLI and the conformance suites")
(define pkg-authors '(oloveluck))
(define license 'MIT)
(define deps '("base" "fhir" "fhir-spec" "fhirpath" "vcl" "cql" "fsh" "db-lib"))
;; system dependency for store/fhir-analytics.rkt and omop/: libduckdb (brew install duckdb, or the
;; libduckdb-linux-amd64.zip release; set DUCKDB_LIB to its path if it is not on the loader path).
;; It is loaded lazily — requiring the module without it is fine; opening analytics is not.
(define build-deps '("rackunit-lib"))
(define raco-commands
  '(("fhir" (submod fhir/cli/raco-fhir main) "regenerate/check the FHIR towers; validate, serve, load, omop; run the SoF/tx/round-trip suites" #f)))
(define test-omit-paths '("tests/vendor" "conformance/tests/vendor" "viewdef/tests/vendor" "examples"))
