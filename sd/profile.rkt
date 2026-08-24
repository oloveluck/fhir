#lang racket/base

;;; profile.rkt — the `profile` definition form of #lang fhir/sd.
;;;
;;; A profile is a StructureDefinition that constrains a base type. This is the profiling *language*:
;;;
;;;   (profile USCorePatient #:base Patient
;;;     (name 1 *)          ; tighten cardinality: name is now required 1..*
;;;     (gender 1 1))       ; gender is now required
;;;
;;; At COMPILE time the macro reads the base type's full field schema (model/introspect), applies the
;;; overrides — VALIDATING each as a genuine tightening (a profile may only narrow cardinality, never
;;; loosen it) — and synthesizes a form macro that validates the constrained schema and then
;;; DELEGATES to the base type's macro (build-fhir-form #:delegate). Because the delegate re-emits
;;; the fields to the next lower layer, profiles compose: `#:base` may be a base type OR an
;;; already-defined profile, giving multi-level delegation (profile → profile → base → node).
;;;
;;; The built value is the base resource (a US Core Patient IS a Patient); the profile adds only
;;; compile-time conformance. The profile is recorded in a compile-time table so a profile-of-profile
;;; can read its parent's constrained schema.

(require (for-syntax racket/base
                     syntax/parse
                     racket/list
                     (only-in "../model/schema.rkt"
                              field-spec field-spec? fs-name fs-min fs-max fs-ftype fs-extra)
                     (only-in "../model/registry.rkt" type-schema-of)
                     (only-in "../model/introspect.rkt" full-field-specs type-parent-sym)
                     fhir/r6/types                       ; populate the phase-1 registry (base schemas)
                     fhir/lang-gen/form-syntax))         ; build-fhir-form for the emitted macro

(provide profile)

;; a compile-time table of defined profiles: name -> (list parent-sym (listof field-spec))
(begin-for-syntax
  (define profile-table (make-hasheq)))

(define-syntax (profile stx)
  (syntax-parse stx
    [(_ name:id #:base base:id clause ...)
     (define base-name (syntax-e #'base))
     ;; the base schema + parent: an earlier profile (from the table) or a registered base type.
     (define prev (hash-ref profile-table base-name #f))
     (define-values (base-specs parent)
       (cond
         [prev (values (second prev) (first prev))]
         [(type-schema-of base-name)
          (values (full-field-specs base-name) (type-parent-sym base-name))]
         [else (raise-syntax-error 'profile
                 (format "unknown base type ~a (not a generated type or a defined profile)" base-name)
                 #'base)]))
     ;; parse the cardinality overrides
     (define overrides
       (for/list ([c (in-list (syntax->list #'(clause ...)))])
         (syntax-parse c
           [(f:id mn:nat mx)
            (list #'f (syntax-e #'f) (syntax-e #'mn) (parse-max #'mx) c)]
           [_ (raise-syntax-error 'profile "expected (field min max)" c)])))
     ;; every override must name a base field
     (for ([o (in-list overrides)])
       (unless (findf (lambda (sp) (and (field-spec? sp) (eq? (fs-name sp) (second o)))) base-specs)
         (raise-syntax-error 'profile (format "no such field ~a in base ~a" (second o) base-name)
                             (first o))))
     (define new-specs (apply-overrides base-specs overrides))
     (hash-set! profile-table (syntax-e #'name) (list parent new-specs))
     ;; emit: a form macro that validates the constrained schema, then delegates to the base macro.
     (define specs-stx (datum->syntax #'name new-specs))
     #`(begin
         (define-syntax (#,#'name s)
           (build-fhir-form s '#,(syntax-e #'name) (quote #,specs-stx)
                            #:parent '#,parent #:delegate (quote-syntax #,#'base)))
         (provide #,#'name))]))

;; ---- compile-time helpers -------------------------------------------------------------------
(begin-for-syntax
  (define (parse-max mx)
    (syntax-parse mx
      [n:nat (syntax-e #'n)]
      [(~datum *) '*]
      [_ (raise-syntax-error 'profile "max must be a nat or *" mx)]))

  ;; apply overrides to the base field-specs (choice-groups pass through untouched)
  (define (apply-overrides specs overrides)
    (for/list ([sp (in-list specs)])
      (cond
        [(not (field-spec? sp)) sp]
        [else
         (define ov (findf (lambda (o) (eq? (second o) (fs-name sp))) overrides))
         (if ov (tighten sp ov) sp)])))

  ;; narrow one field-spec's cardinality, enforcing that it is a genuine tightening.
  (define (tighten sp ov)
    (define nmin (third ov)) (define nmax (fourth ov)) (define clause (fifth ov))
    (define bmin (fs-min sp)) (define bmax (fs-max sp))
    (unless (>= nmin bmin)
      (raise-syntax-error 'profile
        (format "~a: min ~a loosens base min ~a (a profile may only narrow)" (fs-name sp) nmin bmin)
        clause))
    (unless (max<=? nmax bmax)
      (raise-syntax-error 'profile
        (format "~a: max ~a loosens base max ~a (a profile may only narrow)" (fs-name sp) nmax bmax)
        clause))
    (unless (min<=max? nmin nmax)
      (raise-syntax-error 'profile
        (format "~a: min ~a exceeds max ~a" (fs-name sp) nmin nmax) clause))
    (field-spec (fs-name sp) nmin nmax (fs-ftype sp) (fs-extra sp)))

  ;; cardinality lattice: '* is the top. is nmax ≤ bmax?
  (define (max<=? nmax bmax)
    (cond [(eq? bmax '*) #t]
          [(eq? nmax '*) #f]
          [else (<= nmax bmax)]))
  (define (min<=max? nmin nmax) (or (eq? nmax '*) (<= nmin nmax))))
