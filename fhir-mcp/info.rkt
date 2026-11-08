#lang info

;; fhir-mcp — a Model Context Protocol server: a FHIR workspace for an agent.
;;
;; A workspace is a directory of programs in the FHIR languages (FSH, CQL, FHIRPath, VCL, FML,
;; ViewDefinitions) and FHIR JSON; nine tools write, check, run, query, explain, describe, apply,
;; stage and commit them against FHIR data (a directory, a file, or a FHIR server). Each language is
;; reached through its `<id>/workspace` module (fhir/lang/workspace); `learn://<language>` resources
;; carry cheat sheets and links to the official references. `--legacy-tools` adds the per-operation and
;; per-language tools. Contributes to the `fhir` collection (modules fhir/mcp/…).

(define collection "fhir")
(define version "0.1")
(define pkg-desc "A Model Context Protocol server: a FHIR workspace for an agent. Programs in FSH, CQL, FHIRPath, VCL, FML and SQL on FHIR views written, checked, run against FHIR data and explained by nine tools; guides with links to each language's official reference; raco fhir-mcp")
(define pkg-authors '(oloveluck))
(define license 'MIT)
(define deps '("base" "fhir" "fhir-lsp"))
;; the operations and languages are loaded when installed (dynamic-require)
(define build-deps '("rackunit-lib" "scribble-lib" "racket-doc" "fhir-spec" "fhirpath" "vcl" "fhir-tx" "fhir-validation" "cql" "fml" "fsh" "sql-on-fhir"))
(define scribblings '(("scribblings/fhir-mcp.scrbl" ())))
(define raco-commands
  '(("fhir-mcp" (submod fhir/mcp-cli main) "the Model Context Protocol server over the FHIR operations and languages (stdio); list or call tools" #f)))
(define test-omit-paths '("scribblings"))
