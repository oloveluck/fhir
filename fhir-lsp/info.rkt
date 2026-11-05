#lang info

;; fhir-lsp — a Language Server Protocol server for the FHIR languages.
;;
;; One server for FHIR Shorthand (.fsh), CQL (.cql), the FHIR Mapping Language (.fml, .map), VCL
;; (.vcl) and FHIRPath (.fhirpath): each document's problems, as the language's own compiler
;; reports them (fhir/diagnostic, positioned), published to the editor as it types; an FSH file is
;; checked as part of its project. Each language package is loaded when a document of its kind is
;; opened, so the server runs with whichever languages are installed. `raco fhir-lsp`.
;; Contributes to the `fhir` collection (modules fhir/lsp/…).

(define collection "fhir")
(define version "0.1")
(define pkg-desc "A Language Server Protocol server for the FHIR languages (FSH, CQL, FML, VCL, FHIRPath): diagnostics as you type; raco fhir-lsp")
(define pkg-authors '(oloveluck))
(define license 'MIT)
(define deps '("base" "fhir" "net-lib"))
;; the languages are loaded on demand (dynamic-require); the tests exercise them when installed
(define build-deps '("rackunit-lib" "scribble-lib" "racket-doc" "fhirpath" "vcl" "cql" "fml" "fsh"))
(define scribblings '(("scribblings/fhir-lsp.scrbl" ())))
(define raco-commands
  '(("fhir-lsp" (submod fhir/lsp-cli main) "the language server for the FHIR languages (stdio); check files" #f)))
(define test-omit-paths '("scribblings"))
