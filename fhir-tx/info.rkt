#lang info

;; fhir-tx — a FHIR terminology service as a value.
;;
;; $expand, $validate-code (ValueSet and CodeSystem), $lookup and $translate over the CodeSystems,
;; ValueSets and ConceptMaps in FHIR NPM packages or in resources you hold (terminology/service),
;; the same as fhir/operation values (terminology/operations), and the official hl7.fhir.uv.tx-ecosystem
;; suite behind `raco fhir-tx tck`. FHIRPath's %terminologies, the validator's bindings, fhir-server's
;; terminology endpoints and VCL's implicit value set urls all come here.
;; Contributes to the `fhir` collection (module-disjoint from fhir, fhir-validation and fhir-server).

(define collection "fhir")
(define version "0.3")
(define pkg-desc "A FHIR terminology service: $expand, $validate-code, $lookup and $translate over FHIR packages, as procedures, as FHIR operations and as FHIRPath's %terminologies; `raco fhir-tx`")
(define pkg-authors '(oloveluck))
(define license 'MIT)
;; fhir-spec: the vendored core packages make-r5-terminology / make-r4-terminology serve, and the
;; tx-ecosystem suite; vcl: implicit VCL value set urls; fhirpath: the tx-service handle
(define deps '("base" "fhir" "fhir-spec" "fhirpath" "vcl"))
(define build-deps '("rackunit-lib" "scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/fhir-tx.scrbl" ())))
(define raco-commands
  '(("fhir-tx" (submod fhir/tx-cli main) "expand value sets, validate codes, look up concepts and translate over FHIR packages; run the terminology suite" #f)))
(define test-omit-paths '("scribblings"))
