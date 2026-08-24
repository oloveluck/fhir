#lang racket/base

;;; introspect.rkt — read a registered type's FULL field schema (inherited ⊕ own) as field-specs.
;;;
;;; The generated form macros embed this list, but don't expose it as data. `full-field-specs`
;;; reconstructs it from the runtime registry (own fields) + the inherited-field tables, so a
;;; downstream lang — notably `#lang fhir/sd` — can read a base type's schema at compile time and
;;; derive a constrained profile from it. This is the reflection seam the profiling lang grows onto.

(require racket/contract
         "schema.rkt"
         (only-in "registry.rkt" type-schema-of type-registered?))

(provide
 (contract-out
  [full-field-specs (-> symbol? (listof field-spec?))]   ; inherited ⊕ own, as field-specs
  [type-parent-sym  (-> symbol? (or/c #f symbol?))]))    ; a type's framework parent

(define (type-parent-sym name)
  (let ([sch (type-schema-of name)]) (and sch (type-schema-parent sch))))

(define (full-field-specs name)
  (define sch (type-schema-of name))
  (unless sch (error 'full-field-specs "no registered schema for type ~a" name))
  (define parent (type-schema-parent sch))
  (append
   (for/list ([fn (in-list (inherited-field-names parent))])
     (field-spec fn (inherited-field-min fn) (inherited-field-max fn) (inherited-field-ftype fn) #f))
   (for/list ([f (in-list (type-schema-fields sch))])
     (field-spec (schema-field-name f) (schema-field-min f) (schema-field-max f)
                 (schema-field-ftype f) #f))))

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
  (check-equal? (type-parent-sym 'DemoQuantity) 'Element)
  (check-exn exn:fail? (lambda () (full-field-specs 'NoSuchType))))
