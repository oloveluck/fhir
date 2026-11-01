#lang racket/base

;;; expand.rkt — expand choice-type fields (value[x]) into one field per allowed type, and record
;;; the choice group so the form macro can enforce "at most one of" at compile time.
;;;
;;; `value[x]` with types {Quantity, string, boolean} becomes valueQuantity / valueString /
;;; valueBoolean — each optional, max 1. Recurses through backbones. The set of members per choice
;;; base is returned alongside the node via `type-node-choice-groups` (see gen.rkt consumption).

(require racket/list
         "ir.rkt"
         "type-registry.rkt")

(provide expand
         choice-groups-of)

(define (expand node)
  (define-values (choices regular) (partition choice-field? (type-node-fields node)))
  (type-node (type-node-name node)
             (append regular (append-map expand-one choices))
             (map expand (type-node-backbones node))
             (type-node-doc node)
             (type-node-parent node)
             (type-node-path node)))

(define (choice-field? f) (> (length (field-def-types f)) 1))

(define (expand-one f)
  (for/list ([t (in-list (field-def-types f))])
    (field-def (string-append (field-def-name f) (choice-suffix t))
               (list t)
               0 "1"          ; choice variants are always optional, max 1
               (field-def-doc f)
               #f
               (field-def-path f)      ; keep the value[x] path for spec-linking
               (field-def-binding f))))

;; the choice groups of a (pre-expansion) type-node: (listof (cons base-min (listof member-name)))
;; recomputed from the ORIGINAL fields so gen.rkt can emit choice-group entries into the schema.
(define (choice-groups-of orig-node)
  (for/list ([f (in-list (type-node-fields orig-node))] #:when (choice-field? f))
    (list (field-def-min f)
          (for/list ([t (in-list (field-def-types f))])
            (string->symbol (string-append (field-def-name f) (choice-suffix t)))))))
