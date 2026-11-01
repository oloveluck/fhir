#lang racket/base

;;; base.rkt — the module language for #lang fhir/sd (the StructureDefinition / profiling language).
;;;
;;; An sd module DEFINES profiles: it has the `profile` form plus every R6 base type macro in scope
;;; (so a profile can `#:base` them and authors can nest them). `profile` auto-provides each profile
;;; it defines, so another module can `(require "my-profiles.sd")` and author with the constrained
;;; types.

(require fhir/r6/types
         "profile.rkt")

(provide (all-from-out racket/base)
         (all-from-out fhir/r6/types)
         (all-from-out "profile.rkt"))
