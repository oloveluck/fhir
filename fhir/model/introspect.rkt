#lang racket/base

;;; introspect.rkt — read a registered type's FULL field schema (inherited ⊕ own) as field-specs.
;;;
;;; The generated form macros embed this list, but don't expose it as data. `full-field-specs`
;;; reconstructs it from the runtime registry (own fields) + the inherited-field tables, so a
;;; downstream lang — notably `#lang fhir/sd` — can read a base type's schema at compile time and
;;; derive a constrained profile from it. This is the reflection seam the profiling lang grows onto.

(require racket/contract
         "schema.rkt"
         (only-in "registry.rkt" type-schema-of))

(provide
 (contract-out
  [full-field-specs (-> symbol? (listof field-spec?))]   ; inherited ⊕ own, as field-specs
  [type-parent-sym  (-> symbol? (or/c #f symbol?))]))    ; a type's framework parent

(define (type-parent-sym name)
  (let ([sch (type-schema-of name)]) (and sch (type-schema-parent sch))))

;; full-field-specs : type -> (listof field-spec)   the framework base's inherited fields, then each
;; GENERATED ancestor's own fields from the root down, then the type's own — a field defined nearer
;; the type wins. A constraint type such as Age (parent Quantity, no fields of its own) is Quantity's
;; fields; reading only the type's own schema it had none, not even `value` (the same climb as
;; from-json's field index).
(define (full-field-specs name)
  (define sch (type-schema-of name))
  (unless sch (error 'full-field-specs "no registered schema for type ~a" name))
  (define chain                                  ; the type, then each generated ancestor
    (let loop ([sch sch] [acc '()])
      (define psch (type-schema-of (type-schema-parent sch)))
      (if psch (loop psch (cons sch acc)) (cons sch acc))))       ; root-most first
  (define base (type-schema-parent (car chain)))                  ; the framework base (Element, …)
  (define specs
    (append
     (for/list ([fn (in-list (inherited-field-names base))])
       (field-spec fn (inherited-field-min fn) (inherited-field-max fn) (inherited-field-ftype fn) #f))
     (for*/list ([s (in-list chain)] [f (in-list (type-schema-fields s))])
       (field-spec (schema-field-name f) (schema-field-min f) (schema-field-max f) (schema-field-ftype f) #f))))
  ;; a name defined again further down the chain keeps the later definition, in the earlier place
  (define last-def (for/hasheq ([fs (in-list specs)]) (values (field-spec-name fs) fs)))
  (let loop ([specs specs] [seen (hasheq)])
    (cond [(null? specs) '()]
          [(hash-ref seen (field-spec-name (car specs)) #f) (loop (cdr specs) seen)]
          [else (cons (hash-ref last-def (field-spec-name (car specs)))
                      (loop (cdr specs) (hash-set seen (field-spec-name (car specs)) #t)))])))

;; ── living examples (a schema registered here, read back as field-specs) ─────────────────────
(module+ test
  (require rackunit (only-in "registry.rkt" register-type! fhir-spec))
  (require (only-in racket/list last))
  (register-type! 'DemoQuantity (fhir-spec 'DemoQuantity "https://example.org/dq" 'type)
                  #:schema (type-schema 'DemoQuantity #f 'Element "https://example.org/dq"
                                        (list (schema-field 'value 0 1 (vector 'prim "decimal")
                                                            #f "https://example.org/dq#value" #f))
                                        #f #f))
  (define specs (full-field-specs 'DemoQuantity))
  ;; inherited (Element: id, extension) ⊕ own (value), in that order
  (check-equal? (map field-spec-name specs) '(id extension value))
  (check-equal? (field-spec-ftype (last specs)) (vector 'prim "decimal"))
  ;; a constraint type with no fields of its own has its generated parent's
  (register-type! 'DemoAge (fhir-spec 'DemoAge "https://example.org/da" 'type)
                  #:schema (type-schema 'DemoAge #f 'DemoQuantity "https://example.org/da" '() #f #f))
  (check-equal? (map field-spec-name (full-field-specs 'DemoAge)) '(id extension value))
  (check-equal? (type-parent-sym 'DemoQuantity) 'Element)
  (check-exn exn:fail? (lambda () (full-field-specs 'NoSuchType))))
