#lang info

;; fhir-server — FHIR servers generated from FHIR specs.
;;
;; #lang fhir/capability (declare an app, derive its CapabilityStatement) + a small HTTP server, an
;; embedded SQLite store (versioned CRUD, IG-driven search, transactions, audit/provenance), and
;; servers generated from an Implementation Guide package (store/ig-server: its CapabilityStatement,
;; search parameters, profiles — writes validated with fhir-validation — and operations, including
;; $expand and CQF Measures' $evaluate-measure over the cql package). `raco fhir-server`.
;; Contributes to the `fhir` collection (module-disjoint from fhir and fhir-validation).

(define collection "fhir")
(define version "0.3")
(define pkg-desc "FHIR servers generated from specs: #lang fhir/capability, an HTTP server, a SQLite FHIR store, IG-generated servers with validation, search, $expand and $evaluate-measure; raco fhir-server")
(define pkg-authors '(oloveluck))
(define license 'MIT)
(define deps '("base" "fhir" "fhir-spec" "fhirpath" "fhir-validation" "cql" "db-lib"))
;; fsh: the FSH -> package -> server test compiles mCODE's sources
(define build-deps '("rackunit-lib" "fsh" "scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/fhir-server.scrbl" ())))
(define raco-commands
  '(("fhir-server" (submod fhir/server-cli main) "serve a FHIR server generated from an IG package or a #lang fhir/capability app; load data; evaluate measures" #f)))
(define test-omit-paths '("examples" "scribblings"))
