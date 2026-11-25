#lang info

;; fhir-api — the toolkit's functions for programs in other languages.
;;
;; One process that answers function calls over JSON lines on stdin/stdout: compile and check
;; sources in the FHIR languages, run them over data, validate, apply operations, evaluate FHIRPath,
;; translate CQL, decompile. `api/functions.rkt` is the table of functions (data: names, parameters,
;; what each answers), which the server dispatches from and every client (clients/python) is held
;; to. Built over fhir-mcp's hub, so each language is reached through its `<id>/workspace` module.
;; Contributes to the `fhir` collection (modules fhir/api/…).

(define collection "fhir")
(define version "0.1")
(define pkg-desc "The FHIR toolkit's functions over JSON lines, for programs in other languages (the Python client is built on it): compile, check, run, query, explain, validate, apply operations, FHIRPath, CQL to ELM, decompile; raco fhir-api")
(define pkg-authors '(oloveluck))
(define license 'MIT)
(define deps '("base" "fhir" "fhir-mcp"))
;; the operations and languages are loaded when installed (dynamic-require, lazy-require)
(define build-deps '("rackunit-lib" "scribble-lib" "racket-doc" "fhir-spec" "fhirpath" "vcl" "fhir-tx" "fhir-validation" "cql" "fml" "fsh" "sql-on-fhir" "fhir-server"))
(define scribblings '(("scribblings/fhir-api.scrbl" ())))
(define test-omit-paths '("scribblings"))
(define raco-commands
  '(("fhir-api" (submod fhir/api-cli main) "the toolkit's functions over JSON lines (stdio), for programs in other languages; list or call them" #f)))
