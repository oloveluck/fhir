#lang racket/base

;;; registry.rkt — spec-linking: every FHIR type knows the spec that defines it.
;;;
;;; Two coordinated layers, both backed by one `fhir-spec` record:
;;;   1. prop:fhir-spec — a struct-type property, so any *value* can answer
;;;      "what spec defines me?" at zero per-instance cost.
;;;   2. registry      — runtime hashes (name -> entry) that the serializer, parser, and the
;;;      future FHIRPath / capability / IG langs read.
;;;
;;; Three registries share the `fhir-spec` vocabulary: primitives (name -> ctor/pred),
;;; information-model types (name -> type-schema + ctor/pred), and elements (path -> spec).

(require racket/contract/base
         (only-in "schema.rkt" type-schema?))

(provide (struct-out fhir-spec)
         prop:fhir-spec fhir-spec-property? value->fhir-spec
         (struct-out type-info)
         (contract-out
          ;; primitives
          [register-primitive! (->* (symbol? fhir-spec?)
                                    (#:predicate (or/c #f procedure?)
                                     #:constructor (or/c #f procedure?)
                                     #:absent-constructor (or/c #f procedure?))
                                    void?)]
          [spec-of        (-> symbol? (or/c #f fhir-spec?))]
          [predicate-of   (-> symbol? (or/c #f procedure?))]
          [constructor-of (-> symbol? (or/c #f procedure?))]
          [absent-constructor-of (-> symbol? (or/c #f procedure?))]
          [primitive-name? (-> symbol? boolean?)]
          [all-specs      (-> (listof fhir-spec?))]
          [registered-names (-> (listof symbol?))]
          ;; elements (path -> spec)
          [register-element! (-> string? fhir-spec? void?)]
          [element-spec-of   (-> string? (or/c #f fhir-spec?))]
          [all-element-specs (-> (listof fhir-spec?))]
          [registered-element-paths (-> (listof string?))]
          ;; information-model types (abstract types, datatypes, resources)
          [register-type! (->* (symbol? fhir-spec?)
                               (#:schema (or/c #f type-schema?) #:predicate (or/c #f procedure?)
                                #:constructor (or/c #f procedure?))
                               void?)]
          [type-spec-of        (-> symbol? (or/c #f fhir-spec?))]
          [type-schema-of      (-> symbol? (or/c #f type-schema?))]
          [type-predicate-of   (-> symbol? (or/c #f procedure?))]
          [type-constructor-of (-> symbol? (or/c #f procedure?))]
          [type-registered?    (-> symbol? boolean?)]
          [all-types           (-> (listof symbol?))]))

;; constraint is the validation evidence: a regexp, a (cons lo hi) range, 'parsed, or 'abstract/'type.
(struct fhir-spec (name url constraint) #:transparent)

;; Struct-type property: attach a fhir-spec to a struct *type* so its instances carry their link.
(define-values (prop:fhir-spec fhir-spec-property? prop-ref)
  (make-struct-type-property 'fhir-spec))

;; Read the fhir-spec off any value that carries the property (or #f).
(define (value->fhir-spec v)
  (and (fhir-spec-property? v) (prop-ref v)))

;; ── primitive registry: name -> prim-info ────────────────────────────────────────────────────
;; A PrimInfo is (prim-info fhir-spec pred|#f ctor|#f absent-ctor|#f) — the named sibling of
;; type-info below; one record shape per registry, never a bare vector.
(struct prim-info (spec predicate constructor absent-constructor) #:transparent)

(define registry (make-hasheq))

(define (register-primitive! name spec #:predicate [pred #f] #:constructor [ctor #f]
                             #:absent-constructor [ac #f])
  (hash-set! registry name (prim-info spec pred ctor ac))
  (void))

(define (entry name) (hash-ref registry name #f))
(define (spec-of name)        (let ([e (entry name)]) (and e (prim-info-spec e))))
(define (predicate-of name)   (let ([e (entry name)]) (and e (prim-info-predicate e))))
(define (constructor-of name) (let ([e (entry name)]) (and e (prim-info-constructor e))))
(define (absent-constructor-of name) (let ([e (entry name)]) (and e (prim-info-absent-constructor e))))
(define (primitive-name? name) (and (entry name) #t))
(define (all-specs) (for/list ([e (in-hash-values registry)]) (prim-info-spec e)))
(define (registered-names) (hash-keys registry))

;; ── element registry: ElementDefinition path (e.g. "Patient.name") -> fhir-spec ──────────────
(define element-registry (make-hash))

(define (register-element! path spec) (hash-set! element-registry path spec) (void))
(define (element-spec-of path) (hash-ref element-registry path #f))
(define (all-element-specs) (hash-values element-registry))
(define (registered-element-paths) (hash-keys element-registry))

;; ── type registry: information-model type name (symbol) -> type-info ─────────────────────────
(struct type-info (spec schema predicate constructor) #:transparent)

(define type-registry (make-hasheq))

(define (register-type! name spec #:schema [schema #f] #:predicate [pred #f] #:constructor [ctor #f])
  (hash-set! type-registry name (type-info spec schema pred ctor))
  (void))

(define (type-entry name) (hash-ref type-registry name #f))
(define (type-spec-of name)        (let ([e (type-entry name)]) (and e (type-info-spec e))))
(define (type-schema-of name)      (let ([e (type-entry name)]) (and e (type-info-schema e))))
(define (type-predicate-of name)   (let ([e (type-entry name)]) (and e (type-info-predicate e))))
(define (type-constructor-of name) (let ([e (type-entry name)]) (and e (type-info-constructor e))))
(define (type-registered? name) (and (type-entry name) #t))
(define (all-types) (hash-keys type-registry))

;; ── living examples ──────────────────────────────────────────────────────────────────────────
(module+ test
  (require rackunit)
  (define spec (fhir-spec 'demoPrim "https://example.org/demo" 'parsed))
  ;; primitive registry round-trip: register, then every accessor answers
  (register-primitive! 'demoPrim spec #:predicate number? #:constructor add1)
  (check-equal? (spec-of 'demoPrim) spec)
  (check-eq? (predicate-of 'demoPrim) number?)
  (check-eq? (constructor-of 'demoPrim) add1)
  (check-false (absent-constructor-of 'demoPrim))
  (check-true (primitive-name? 'demoPrim))
  (check-false (primitive-name? 'nope))
  (check-true (and (member spec (all-specs)) #t))
  ;; type registry round-trip
  (register-type! 'DemoType (fhir-spec 'DemoType "https://example.org/DemoType" 'type)
                  #:predicate list?)
  (check-true (type-registered? 'DemoType))
  (check-eq? (type-predicate-of 'DemoType) list?)
  (check-false (type-schema-of 'DemoType))
  (check-false (type-registered? 'NoSuchType))
  ;; element registry round-trip
  (register-element! "DemoType.field" spec)
  (check-equal? (element-spec-of "DemoType.field") spec)
  (check-false (element-spec-of "DemoType.other")))
