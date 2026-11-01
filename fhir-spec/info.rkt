#lang info

;; fhir-spec — the vendored HL7 FHIR NPM packages (R4/R5/R6 core, US Core, IPS, SQL-on-FHIR,
;; FHIR-to-OMOP, tx-ecosystem) that the fhir codegen, snapshot generation, terminology service and
;; conformance suites read. Pure data; located by fhir/spec-package via (collection-file-path f "fhir-spec").

(define collection "fhir-spec")
(define version "0.3")
(define pkg-desc "Vendored HL7 FHIR NPM packages (R4/R5/R6 core, US Core, IPS, SQL-on-FHIR, FHIR-to-OMOP, tx-ecosystem) read by the fhir codegen, terminology service and conformance suites")
(define pkg-authors '(oloveluck))
(define license '(MIT AND CC0-1.0))   ; packaging MIT; every tarball's package.json declares CC0-1.0
(define deps '("base"))
(define compile-omit-paths 'all)
(define test-omit-paths 'all)
