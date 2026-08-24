#lang racket/base

;;; nest.rkt — flatten a StructureDefinition snapshot into a nested type-node tree.
;;;
;;; The snapshot is a flat list where nesting is encoded in the dotted path. We recursively pull
;;; out direct children (one level deeper, no further dot), drop inherited fields (base.path !=
;;; path), classify each as simple/backbone/choice/reference, and recurse into backbones.

(require racket/list
         racket/string
         "ir.rkt"
         "type-registry.rkt"
         "structure-definition.rkt")

(provide nest)

;; StructureDefinition -> type-node
(define (nest sd)
  (define elements (structure-definition-elements sd))
  (when (null? elements)
    (error 'nest "no snapshot for ~a" (structure-definition-name sd)))
  (define root (car elements))
  (define root-path (element-definition-path root))
  (build-node root-path
              (structure-definition-name sd)
              (cdr elements)
              (resolve-parent-type sd)
              (element-definition-short root)))

(define (resolve-parent-type sd)
  (define base (structure-definition-base-definition sd))
  (if base (last (string-split base "/")) "Base"))

;; build a single level: name = dotted Capitalized type name (e.g. "Patient.Contact")
(define (build-node root-path name all-elements parent doc)
  (define direct (filter (lambda (e) (direct-child? root-path (element-definition-path e)))
                         all-elements))
  (define own (filter own-field? direct))
  (let loop ([es own] [fields '()] [backbones '()])
    (cond
      [(null? es) (type-node name (reverse fields) (reverse backbones) doc parent root-path)]
      [else
       (define e (car es))
       (case (classify e)
         [(backbone)
          (define bb-path (element-definition-path e))
          (define bb-name (string-append name "." (backbone-class-name bb-path)))
          (define bb-children
            (filter (lambda (c) (string-prefix? (element-definition-path c)
                                                (string-append bb-path ".")))
                    all-elements))
          (define bb-node (build-node bb-path bb-name bb-children "BackboneElement"
                                      (element-definition-short e)))
          (loop (cdr es) (cons (elem->field e) fields) (cons bb-node backbones))]
         [else
          (loop (cdr es) (cons (elem->field e) fields) backbones)])])))

;; e's path is exactly one segment deeper than root
(define (direct-child? root path)
  (and (string-prefix? path (string-append root "."))
       (not (string-contains? (substring path (add1 (string-length root))) "."))))

;; own field iff it was first defined here (base.path == path) or has no base
(define (own-field? e)
  (define bp (element-definition-base-path e))
  (or (not bp) (string=? bp (element-definition-path e))))

;; classify by type count / content reference
(define (classify e)
  (define types (element-definition-types e))
  (cond
    [(element-definition-content-reference e) 'reference] ; recursive reuse — treated as a field
    [(null? types) 'backbone]
    [(and (= 1 (length types)) (not (resolve-type (car types)))) 'backbone]
    [else 'field]))  ; simple or choice; choice expanded later

(define (elem->field e)
  (field-def (field-name (element-definition-path e))
             (element-definition-types e)
             (element-definition-min e)
             (element-definition-max e)
             (element-definition-short e)
             (let ([cr (element-definition-content-reference e)])
               (and cr (content-ref->type-name cr)))
             (element-definition-path e)
             (element-definition-binding e)))

;; "#Questionnaire.item" -> "Questionnaire.Item"  (Capitalized segments, dotted). A contentReference
;; may also be ABSOLUTE ("http://…/StructureDefinition/X#X.y", as the SQL-on-FHIR IG emits) — the
;; element id is always the fragment, so take everything after the last '#'.
(define (content-ref->type-name ref)
  (define p (let ([i (for/last ([c (in-string ref)] [k (in-naturals)] #:when (char=? c #\#)) k)])
              (if i (substring ref (add1 i)) ref)))
  (string-join (map capitalize (string-split p ".")) "."))
