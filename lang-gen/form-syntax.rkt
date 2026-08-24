#lang racket/base

;;; form-syntax.rkt — the compile-time validator/expander behind generated FHIR form macros.
;;;
;;; A generated type macro is
;;;   (define-syntax (Patient stx) (build-fhir-form stx 'Patient SCHEMA #:parent 'DomainResource))
;;; where SCHEMA is the type's field list embedded as a literal of prefab `#s(field-spec …)` /
;;; `#s(choice-group …)` structs. At expansion `build-fhir-form` checks the s-expr tree against the
;;; schema — unknown field, duplicate field, wrong cardinality, missing required, choice-group
;;; min/max, wrong nested type head, and (for literal leaves) invalid primitive values — raising
;;; `raise-syntax-error` with source locations, and expands valid trees to a `node-build` call (the
;;; canonical typed value). Nested complex values expand via their own type macros, so deep trees
;;; validate compositionally.
;;;
;;; This module is required `for-syntax` by the generated modules; `build-fhir-form` runs in the
;;; transformer (phase 1), using the primitive registry for literal validation.

(require racket/list
         syntax/parse
         racket/contract
         (only-in "../model/schema.rkt"
                  schema-entry/c
                  ftype-tag ftype-prim-code ftype-type-name ftype-prim? ftype-raw?
                  fs-name fs-kind fs-ftype fs-req fs-extra fs-choice?
                  choice-min choice-max choice-members)
         (only-in "../model/registry.rkt" constructor-of)
         (only-in "../model/binding.rkt" binding-expansion binding-expansion-codes)
         (only-in "../result/result.rkt" err?)
         (only-in "../primitives/primitives.rkt")   ; register primitive constructors (phase-1 here)
         ;; the expansion uses node-build (the runtime sink that builds a typed node) + build-prim
         ;; (a validated primitive leaf) -> bind them at the template phase.
         (for-template racket/base
                       (only-in "../kernel/node-build.rkt" node-build build-prim)))

;; build-fhir-form runs at macro-expansion time (compile time), so contracting it is free at
;; runtime — it validates the generated define-syntax call sites.
(provide
 (contract-out
  [build-fhir-form
   (->* (syntax? symbol? (listof schema-entry/c))
        (symbol? #:delegate (or/c #f identifier?)
                 #:parent (or/c #f symbol?))
        syntax?)]))

;; stx : the (TypeName field-form …) use ; type : symbol (for messages) ;
;; field-schema : (listof field-spec | choice-group) ; build-type : the type to actually build.
;; #:delegate : when given, an identifier for the next-LOWER lang's form macro. The macro validates
;;   this layer's constraints then re-emits the original fields as (delegate fld …) — that lower
;;   macro validates its level and builds/delegates on (layered compilation, the profile/IG seam).
;;   Without it, this is the base layer and expands to a build of the canonical value.
;; #:parent : the framework parent type ('DomainResource, 'DataType, …) — recorded in the generated
;;   schema module (which drives resourceType stamping at serialize time); unused for the build here.
(define (build-fhir-form stx type field-schema [build-type type]
                         #:delegate [delegate #f] #:parent [parent #f])
  (define schema (make-hasheq))
  (define real-fields (filter (lambda (fs) (not (fs-choice? fs))) field-schema))
  (define choice-groups (filter fs-choice? field-schema))
  (for ([fs (in-list real-fields)]) (hash-set! schema (fs-name fs) fs))   ; name -> field-spec
  (syntax-parse stx
    [(_ fld ...)
     (define present (make-hasheq))
     (define parts
       (for/list ([f (in-list (syntax->list #'(fld ...)))])
         (process-field stx type schema present f)))
     ;; required fields must be present
     (for ([fs (in-list real-fields)])
       (when (and (fs-req fs) (not (hash-ref present (fs-name fs) #f)))
         (raise-syntax-error type (format "missing required field ~a.~a" type (fs-name fs)) stx)))
     ;; value[x] choice groups: enforce the group min/max over present allowed members
     (for ([cg (in-list choice-groups)])
       (define mn (choice-min cg)) (define mx (choice-max cg)) (define members (choice-members cg))
       (define cnt (for/sum ([m (in-list members)]) (if (hash-ref present m #f) 1 0)))
       (when (< cnt mn)
         (raise-syntax-error type (format "~a requires one of ~a" type members) stx))
       (when (and (number? mx) (> cnt mx))
         (raise-syntax-error type (format "~a allows at most ~a of ~a" type mx members) stx)))
     (if delegate
         (quasisyntax/loc stx (#,delegate fld ...))   ; layer up: hand off to the lower form
         (emit-base build-type parts))]               ; base layer: build the typed node
    [_ (raise-syntax-error type "expected (Type (field value …) …)" stx)]))

;; emit-base : (node-build 'Type (list (list 'field 'kind (list leaf …)) …)), where each leaf is
;; wrapped by ftype — a primitive literal/expr becomes (build-prim "code" v); a nested form or raw
;; value passes through (its own macro produced a node, or it is already a jsexpr).
(define (emit-base build-type parts)
  #`(node-build '#,build-type
                (list #,@(for/list ([p (in-list parts)])
                           (define fname (car p)) (define kind (cadr p))
                           (define ftype (caddr p)) (define vs (cadddr p))
                           #`(list '#,fname '#,kind
                                   (list #,@(map (lambda (v) (wrap-leaf ftype v)) vs)))))))

;; wrap one value syntax by its ftype
(define (wrap-leaf ftype v)
  (cond
    [(ftype-prim? ftype) #`(build-prim #,(ftype-prim-code ftype) #,v)]
    [else v]))   ; nested type/resource form -> a node ; raw -> a plain value

;; (field v …) -> a validated (field-name kind ftype value-syntaxes) part
(define (process-field stx type schema present f)
  (syntax-parse f
    [(field:id v ...)
     (define fname (syntax-e #'field))
     (define spec (hash-ref schema fname #f))
     (unless spec
       (raise-syntax-error type (format "unknown field ~a.~a" type fname) f #'field))
     (when (hash-ref present fname #f)
       (raise-syntax-error type (format "duplicate field ~a.~a" type fname) f #'field))
     (hash-set! present fname #t)
     (define kind (fs-kind spec))
     (define ftype (fs-ftype spec))
     (define vs (syntax->list #'(v ...)))
     (when (and (memq kind '(single optional)) (> (length vs) 1))
       (raise-syntax-error type (format "field ~a.~a is single-valued" type fname) f))
     (for ([vv (in-list vs)]) (check-value type fname ftype (fs-extra spec) vv))
     (list fname kind ftype vs)]
    [_ (raise-syntax-error type "expected (field value …)" f)]))

;; compile-time check of one value against its ftype (+ its required-binding, when one is
;; registered — see model/binding.rkt; unregistered ValueSets FAIL OPEN)
(define (check-value type fname ftype extra v)
  (cond
    [(ftype-prim? ftype)
     (define code (ftype-prim-code ftype))
     (define d (syntax->datum v))
     (when (literal-datum? d)
       (define ctor (constructor-of (string->symbol code)))
       (when (and ctor (err? (ctor d)))
         (raise-syntax-error type (format "invalid ~a value: ~s" code d) v))
       (check-binding type fname extra d v))]
    [(eq? (ftype-tag ftype) 'type)
     (define T (ftype-type-name ftype))
     (syntax-parse v
       [(head:id _ ...) (unless (eq? (syntax-e #'head) T)
                          (raise-syntax-error type
                            (format "field ~a.~a expects a ~a" type fname T) v))]
       [_ (raise-syntax-error type
            (format "field ~a.~a expects a (~a …) value" type fname T) v)])]
    [else (void)]))   ; resource / raw / unknown -> no compile-time shape check

(define (literal-datum? d) (or (string? d) (number? d) (boolean? d)))

;; a required binding whose ValueSet expanded offline rejects literal codes outside it.
;; extra is the field-spec's extra slot: (list 'required vs-url) on required-bound code fields.
(define (check-binding type fname extra d v)
  (when (and (string? d) (list? extra) (= 2 (length extra)) (eq? (car extra) 'required))
    (define url (cadr extra))
    (define exp (binding-expansion url))
    (when (and exp (not (hash-ref exp d #f)))
      (raise-syntax-error type
        (format "~s is not in the required value set for ~a.~a (~a); valid codes: ~a"
                d type fname url (binding-expansion-codes url))
        v))))
