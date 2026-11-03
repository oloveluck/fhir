#lang racket/base

;;; target.rkt — the codegen parameterization seam: one descriptor per version tower.
;;;
;;; `generate-tower` (gen.rkt) is a single code path; a `gen-target` is what varies between R6 and
;;; R4 (and, later, an IG). The whitelist keeps the vertical slice small — set it to #f for full
;;; generation with zero code change.


(provide (struct-out gen-target)
         target-r6 target-r4 target-r5 target-for)

;; spec-file : string -> path   a vendored package from the fhir-spec package (a hard requirement
;; for codegen: regenerating a tower without the spec is an error, with an install hint).
(require (only-in fhir/spec-package spec-package-path))
(define (spec-file f) (spec-package-path f))

;; id            : symbol   'r6 | 'r4 | 'r5
;; package-file  : path     the vendored .tgz
;; package-name  : string   the NPM package name (for messages)
;; out-root      : string   output subdir under the collection root ("r6" -> fhir/r6/…)
;; doc-base      : string   spec doc URL prefix for spec-linking
;; whitelist     : (listof symbol)|#f   which types to generate (#f = all concrete types);
;;                          matched AFTER `rename`, so a renaming target whitelists renamed names
;; delegate-base : (or gen-target #f)   the base tower to delegate to (for a profile/IG tower)
;; quirks        : (listof symbol)      per-version deltas (reserved; e.g. 'no-integer64 for R4)
;; forms?        : boolean  #t = emit authoring form macros + #lang (an authored tower); #f =
;;                          schema-only (register-type! data + a schemas.rkt index) for FHIRPath.
;; rename        : (or (-> string? string?) #f)   applied to every SD name (and the root segment of
;;                          its element paths) right after load — the seam that lets an IG whose
;;                          names collide with the base tower register under its own names instead.
;; collection    : string   the collection the tower is written into and named under ("fhir" for the
;;                          core towers; an IG package's own collection — sql-on-fhir writes its
;;                          model to sql-on-fhir/model, `#lang sql-on-fhir/model`)
(struct gen-target
  (id package-file package-name out-root doc-base whitelist delegate-base quirks forms? rename collection)
  #:transparent)

;; R6 is the full authoring tower (form macros + #lang fhir/r6). R4/R5 are full SCHEMA-ONLY towers
;; used by FHIRPath to parse arbitrary test-input resources (no form macros to keep compile light).
(define target-r6
  (gen-target 'r6 (spec-file "hl7.fhir.r6.core.tgz") "hl7.fhir.r6.core"
              "r6" "https://build.fhir.org/" #f #f '() #t #f "fhir"))

(define target-r4
  (gen-target 'r4 (spec-file "hl7.fhir.r4.core.tgz") "hl7.fhir.r4.core"
              "r4" "https://hl7.org/fhir/R4/" #f #f '(no-integer64) #f #f "fhir"))

(define target-r5
  (gen-target 'r5 (spec-file "hl7.fhir.r5.core.tgz") "hl7.fhir.r5.core"
              "r5" "https://hl7.org/fhir/R5/" #f #f '() #f #f "fhir"))

(define (target-for id)
  (case id
    [(r6) target-r6]
    [(r4) target-r4]
    [(r5) target-r5]
    [else (error 'target-for "unknown target ~a (expected r4, r5 or r6)" id)]))
