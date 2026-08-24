#lang racket/base

;;; target.rkt — the codegen parameterization seam: one descriptor per version tower.
;;;
;;; `generate-tower` (gen.rkt) is a single code path; a `gen-target` is what varies between R6 and
;;; R4 (and, later, an IG). The whitelist keeps the vertical slice small — set it to #f for full
;;; generation with zero code change.

(require racket/runtime-path)

(provide (struct-out gen-target)
         target-r6 target-r4 target-r5 target-sof target-omop target-for)

(define-runtime-path spec-dir "../spec")

;; id            : symbol   'r6 | 'r4 | 'r5
;; package-file  : path     the vendored .tgz
;; package-name  : string   the NPM package name (for messages)
;; out-root      : string   output subdir under the fhir collection root ("r6" -> fhir/r6/…)
;; doc-base      : string   spec doc URL prefix for spec-linking
;; whitelist     : (listof symbol)|#f   which types to generate (#f = all concrete types);
;;                          matched AFTER `rename`, so a renaming target whitelists renamed names
;; delegate-base : (or gen-target #f)   the base tower to delegate to (for a profile/IG tower)
;; quirks        : (listof symbol)      per-version deltas (reserved; e.g. 'no-integer64 for R4)
;; forms?        : boolean  #t = emit authoring form macros + #lang (an authored tower); #f =
;;                          schema-only (register-type! data + a schemas.rkt index) for FHIRPath.
;; rename        : (or (-> string? string?) #f)   applied to every SD name (and the root segment of
;;                          its element paths) right after load — the seam that lets an IG whose
;;                          names collide with the base tower (OMOP's Person/Observation/…) register
;;                          under its own domain-correct names instead.
(struct gen-target
  (id package-file package-name out-root doc-base whitelist delegate-base quirks forms? rename)
  #:transparent)

;; R6 is the full authoring tower (form macros + #lang fhir/r6). R4/R5 are full SCHEMA-ONLY towers
;; used by FHIRPath to parse arbitrary test-input resources (no form macros to keep compile light).
(define target-r6
  (gen-target 'r6 (build-path spec-dir "hl7.fhir.r6.core.tgz") "hl7.fhir.r6.core"
              "r6" "https://build.fhir.org/" #f #f '() #t #f))

(define target-r4
  (gen-target 'r4 (build-path spec-dir "hl7.fhir.r4.core.tgz") "hl7.fhir.r4.core"
              "r4" "https://hl7.org/fhir/R4/" #f #f '(no-integer64) #f #f))

(define target-r5
  (gen-target 'r5 (build-path spec-dir "hl7.fhir.r5.core.tgz") "hl7.fhir.r5.core"
              "r5" "https://hl7.org/fhir/R5/" #f #f '() #f #f))

;; The SQL-on-FHIR IG tower — the first IG-as-gen-target: generate ONLY the IG's own resources
;; (whitelist) and DELEGATE every referenced core type to the base tower (the emitted index requires
;; fhir/r6/types, so Meta/Coding/… resolve through the shared registry). `#lang fhir/viewdef`
;; authors ViewDefinitions with compile-time validation; the hand-written evaluator lives alongside.
(define target-sof
  (gen-target 'sof (build-path spec-dir "hl7.fhir.uv.sql-on-fhir.tgz") "hl7.fhir.uv.sql-on-fhir"
              "viewdef" "https://sql-on-fhir.org/ig/" '(ViewDefinition) target-r6 '() #t #f))

;; camel->snake : "ConditionOccurrence" -> "condition_occurrence", "NoteNLP" -> "note_nlp".
;; OMOP CDM table names ARE snake_case — the rename makes the generated types (and the `#lang
;; fhir/omop` forms) read like OMOP DDL, and keeps Person/Observation/Location/Specimen/Episode
;; from colliding with the R5 core resources in the shared runtime registry.
(define (camel->snake s)
  (string-downcase
   (regexp-replace* #px"([a-z0-9])([A-Z])"
                    (regexp-replace* #px"([A-Z]+)([A-Z][a-z])" s "\\1_\\2")
                    "\\1_\\2")))

;; The FHIR-to-OMOP IG tower (hl7.fhir.uv.omop, FHIR R5): the 25 OMOP CDM tables — the IG's
;; kind=logical StructureDefinitions — as generated types, snake_case per OMOP DDL. RecordSet (the
;; IG's FHIR-side bundling construct, referencing other tables by canonical URL) is deliberately
;; not whitelisted: it isn't an OMOP CDM table. `#lang fhir/omop` authors compile-time-validated
;; OMOP rows; the SQL-on-FHIR flattening + DuckDB loader live alongside in omop/.
(define target-omop
  (gen-target 'omop (build-path spec-dir "hl7.fhir.uv.omop.tgz") "hl7.fhir.uv.omop"
              "omop" "https://build.fhir.org/ig/HL7/fhir-omop-ig/"
              '(person observation_period visit_occurrence visit_detail condition_occurrence
                drug_exposure procedure_occurrence device_exposure measurement observation
                death note note_nlp specimen fact_relationship location care_site provider
                payer_plan_period cost drug_era dose_era condition_era episode episode_event)
              target-r5 '() #t camel->snake))

(define (target-for id)
  (case id
    [(r6) target-r6]
    [(r4) target-r4]
    [(r5) target-r5]
    [(sof) target-sof]
    [(omop) target-omop]
    [else (error 'target-for "unknown target ~a (expected r4, r5, r6, sof, or omop)" id)]))
