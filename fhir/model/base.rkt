#lang racket/base

;;; base.rkt — the FHIR abstract type hierarchy, hand-written and spec-linked.
;;;
;;; These are the roots of the whole information model (https://build.fhir.org/types.html); the
;;; code generator deliberately skips them and makes every generated datatype/resource extend the
;;; right one. The shape mirrors the spec exactly:
;;;
;;;   Base
;;;   ├─ Element            id, extension
;;;   │  ├─ BackboneElement + modifierExtension
;;;   │  └─ DataType
;;;   │     ├─ PrimitiveType + value          (primitives extend this)
;;;   │     └─ BackboneType  + modifierExtension
;;;   └─ Resource           id, meta, implicitRules, language
;;;      └─ DomainResource  + text, contained, extension, modifierExtension
;;;
;;; Resource extends Base directly — NOT Element. `extension` therefore lives on Element and
;;; (separately) on DomainResource, never on bare Resource.

(require racket/contract
         "registry.rkt")

(provide (struct-out base)
         (struct-out element)
         (struct-out backbone-element)
         (struct-out data-type)
         (struct-out primitive-type)
         (struct-out backbone-type)
         (struct-out fhir-resource)
         (struct-out domain-resource)
         (contract-out
          [element-extensions (-> element? list?)]
          [base-field-ref     (-> base? symbol? any/c)]))

;; -------------------------------------------------------------------
;; the hierarchy
;; -------------------------------------------------------------------
(struct base () #:transparent)

;; Element: id (string|#f), extension (listof Extension)
(struct element base (id extension) #:transparent)

(struct backbone-element element (modifierExtension) #:transparent)

;; DataType is an abstract marker between Element and the reusable types.
(struct data-type element () #:transparent)

;; PrimitiveType adds the primitive value; concrete primitives (fhir-id, …) extend this.
(struct primitive-type data-type (value) #:transparent)

;; The few datatypes allowed to carry modifier extensions.
(struct backbone-type data-type (modifierExtension) #:transparent)

;; Resource extends Base (not Element). Named fhir-resource to avoid a generic clash.
(struct fhir-resource base (id meta implicitRules language) #:transparent)

(struct domain-resource fhir-resource (text contained extension modifierExtension) #:transparent)

;; plural alias for the Element.extension accessor
(define (element-extensions e) (element-extension e))

;; Generic accessor for an inherited field by name — dispatches on the element/resource branch.
(define (base-field-ref inst name)
  (case name
    [(id) (cond [(fhir-resource? inst) (fhir-resource-id inst)]
                [(element? inst) (element-id inst)] [else #f])]
    [(extension) (cond [(domain-resource? inst) (domain-resource-extension inst)]
                       [(element? inst) (element-extension inst)] [else '()])]
    [(modifierExtension) (cond [(backbone-element? inst) (backbone-element-modifierExtension inst)]
                               [(backbone-type? inst) (backbone-type-modifierExtension inst)]
                               [(domain-resource? inst) (domain-resource-modifierExtension inst)]
                               [else '()])]
    [(meta) (and (fhir-resource? inst) (fhir-resource-meta inst))]
    [(implicitRules) (and (fhir-resource? inst) (fhir-resource-implicitRules inst))]
    [(language) (and (fhir-resource? inst) (fhir-resource-language inst))]
    [(text) (and (domain-resource? inst) (domain-resource-text inst))]
    [(contained) (if (domain-resource? inst) (domain-resource-contained inst) '())]
    [else #f]))

;; -------------------------------------------------------------------
;; register the abstract types into the spec-linking registry
;; -------------------------------------------------------------------
(define (types-url n) (string-append "https://build.fhir.org/types.html#" n))

(for-each
 (lambda (pair)
   (register-type! (car pair) (fhir-spec (car pair) (cdr pair) 'abstract)))
 (list (cons 'Base            (types-url "Base"))
       (cons 'Element         (types-url "Element"))
       (cons 'BackboneElement (types-url "BackboneElement"))
       (cons 'DataType        (types-url "DataType"))
       (cons 'PrimitiveType   (types-url "PrimitiveType"))
       (cons 'BackboneType    (types-url "BackboneType"))
       (cons 'Resource        "https://build.fhir.org/resource.html#Resource")
       (cons 'DomainResource  "https://build.fhir.org/domainresource.html#DomainResource")))

;; ── living examples ──────────────────────────────────────────────────────────────────────────
(module+ test
  (require rackunit (only-in "registry.rkt" type-registered?))
  ;; the hierarchy: Resource extends Base, NOT Element
  (define r (fhir-resource "r1" #f #f #f))
  (check-true (base? r))
  (check-false (element? r))
  ;; base-field-ref dispatches by branch: Element.id vs Resource.id
  (check-equal? (base-field-ref r 'id) "r1")
  (check-equal? (base-field-ref (element "e1" '()) 'id) "e1")
  ;; extension lives on Element and DomainResource — bare Resource answers '()
  (check-equal? (base-field-ref r 'extension) '())
  (check-equal? (base-field-ref (domain-resource "d" #f #f #f #f '() '(x) '()) 'extension) '(x))
  (check-false (base-field-ref r 'text))                 ; DomainResource-only field
  ;; the abstract roots are spec-registered
  (check-true (andmap type-registered?
                      '(Base Element BackboneElement DataType PrimitiveType BackboneType
                        Resource DomainResource))))
