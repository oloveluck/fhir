#lang racket/base

;;; ir.rkt — the intermediate representation the generator transforms.
;;;
;;; A StructureDefinition's flat snapshot is nested into a `type-node` tree (nest.rkt), choice
;;; fields are expanded (expand.rkt), and the tree is emitted as Racket source (emit-*.rkt).

(provide (struct-out type-node)
         (struct-out field-def)
         field-kind)

;; name      : string   the type/class name (e.g. "Patient", "Patient.Contact")
;; fields    : (listof field-def)   own fields (inherited ones filtered out)
;; backbones : (listof type-node)   nested backbone types
;; doc       : string|#f
;; parent    : string   "DomainResource" | "Resource" | "BackboneElement" | "DataType" | "Element"
;; path      : string   the FHIR path of this type's root element ("Coding", "Patient.contact")
(struct type-node (name fields backbones doc parent path) #:transparent)

;; name  : string   field name (choice [x] stripped; expanded later)
;; types : (listof string)   FHIR type codes ('() = backbone, 1 = simple, >1 = choice)
;; min   : exact-nonnegative-integer
;; max   : string   "1" | "*" | "0" | n
;; doc   : string|#f
;; ref   : string|#f   a content-reference target type-name (recursive reuse), or #f
;; path  : string   the original FHIR element path; choice members keep the "[x]" base path
;; binding : (cons strength-string vs-url)|#f   the element's terminology binding
(struct field-def (name types min max doc ref path binding) #:transparent)

;; classify a field by its declared types
(define (field-kind f)
  (case (length (field-def-types f))
    [(0) 'backbone]
    [(1) 'simple]
    [else 'choice]))
