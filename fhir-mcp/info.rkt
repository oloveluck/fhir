#lang info

;; fhir-mcp — a Model Context Protocol server over the FHIR family.
;;
;; Every FHIR operation the installed packages implement ($validate, $expand, $validate-code,
;; $lookup, $translate, $snapshot, $transform, $evaluate-measure, $sql-run, …) is a tool whose input
;; schema is its OperationDefinition's parameters, and the languages give tools of their own: check an
;; FSH project or any file of the five languages, compile FSH, translate and evaluate CQL, compile
;; VCL, evaluate FHIRPath. `raco fhir-mcp` serves over stdio for an agent; `raco fhir-mcp call` runs
;; one tool from the shell. Contributes to the `fhir` collection (modules fhir/mcp/…).

(define collection "fhir")
(define version "0.1")
(define pkg-desc "A Model Context Protocol server over the FHIR family: every registered FHIR operation as a tool (its OperationDefinition the schema), plus check/compile/evaluate tools for FSH, CQL, FML, VCL and FHIRPath; raco fhir-mcp")
(define pkg-authors '(oloveluck))
(define license 'MIT)
(define deps '("base" "fhir" "fhir-lsp"))
;; the operations and languages are loaded when installed (dynamic-require)
(define build-deps '("rackunit-lib" "scribble-lib" "racket-doc" "fhir-spec" "fhirpath" "vcl" "fhir-tx" "fhir-validation" "cql" "fml" "fsh"))
(define scribblings '(("scribblings/fhir-mcp.scrbl" ())))
(define raco-commands
  '(("fhir-mcp" (submod fhir/mcp-cli main) "the Model Context Protocol server over the FHIR operations and languages (stdio); list or call tools" #f)))
(define test-omit-paths '("scribblings"))
