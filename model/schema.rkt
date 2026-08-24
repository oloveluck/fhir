#lang racket/base

;;; schema.rkt — the field-schema that generated types register and embed.
;;;
;;; The generator emits, per type, a `type-schema` describing its fields (name, cardinality,
;;; referenced type, spec URL). The serializer (serialize/) and parser interpret these schemas
;;; for JSON read/write and spec-linking, so the generated code stays thin and the tricky logic
;;; lives in one tested place. The same field data also embeds — as prefab `field-spec` structs —
;;; inside the compile-time form macros (lang-gen/form-syntax.rkt).

(require racket/contract
         (only-in "../contracts.rkt" discriminator/c ftype/c))

(provide (struct-out type-schema)
         (struct-out schema-field)
         (struct-out field-spec)
         (struct-out choice-group)
         field-spec/c choice-group/c schema-entry/c
         (contract-out
          ;; ftype selectors (the tagged-vector data definition below)
          [ftype-tag       (-> vector? symbol?)]
          [ftype-prim-code (-> vector? string?)]
          [ftype-type-name (-> vector? symbol?)]
          [ftype-prim?     (-> vector? boolean?)]
          [ftype-type?     (-> vector? boolean?)]
          [ftype-resource? (-> vector? boolean?)]
          [ftype-raw?      (-> vector? boolean?)]
          ;; field-spec accessors (over the prefab struct). NATIVE cardinality is the primitive;
          ;; kind/req are DERIVED views; fs-choice? distinguishes the two schema-entry kinds by TYPE.
          [fs-name   (-> field-spec? symbol?)]
          [fs-min    (-> field-spec? exact-nonnegative-integer?)]
          [fs-max    (-> field-spec? (or/c exact-nonnegative-integer? '*))]
          [fs-ftype  (-> field-spec? vector?)]
          [fs-extra  (-> field-spec? (or/c #f list?))]
          [fs-kind   (-> field-spec? (or/c 'single 'optional 'list))]   ; derived view of (min,max)
          [fs-req    (-> field-spec? boolean?)]                          ; derived: min ≥ 1
          [fs-choice? (-> any/c boolean?)]                               ; = choice-group?
          [choice-min     (-> choice-group? exact-integer?)]
          [choice-max     (-> choice-group? (or/c exact-integer? #f))]
          [choice-members (-> choice-group? (listof symbol?))]
          ;; cardinality helpers + inherited-field tables
          [max-of     (-> string? (or/c exact-nonnegative-integer? '*))]   ; FHIR max "*"/"5" -> '*/5
          [card->kind (-> exact-nonnegative-integer? (or/c exact-nonnegative-integer? '*)
                          (or/c 'single 'optional 'list))]                 ; the (min,max) -> kind view
          [schema-field-kind (-> schema-field? (or/c 'single 'optional 'list))]  ; derived view
          [resource-parent?        (-> symbol? boolean?)]
          [inherited-field-names   (-> symbol? (listof symbol?))]
          [inherited-field-default (-> symbol? any/c)]
          [inherited-field-ftype   (-> symbol? vector?)]
          [inherited-field-kind    (-> symbol? (or/c 'single 'optional 'list))]
          [inherited-field-min     (-> symbol? exact-nonnegative-integer?)]
          [inherited-field-max     (-> symbol? (or/c exact-nonnegative-integer? '*))]))

;; name        : symbol   FHIR type name (e.g. 'Coding, 'Patient, 'PatientContact)
;; struct-name : symbol|#f (reserved; #f in this model — we use one generic node)
;; parent      : symbol   base parent ('DataType 'DomainResource 'BackboneElement …)
;; spec-url    : string
;; fields      : (listof schema-field)   OWN fields (inherited handled by parent table)
;; builder/predicate : reserved hooks (#f here)
(struct type-schema (name struct-name parent spec-url fields builder predicate) #:transparent)

;; name        : symbol   field name
;; min         : nat      FHIR min cardinality
;; max         : nat|'*   FHIR max cardinality ('* = unbounded). kind is the derived view.
;; ftype       : Ftype (see below)
;; choice-base : symbol|#f  the value[x] base (e.g. 'value) for an expanded choice member
;; spec-url    : string
;; accessor    : reserved (#f)
(struct schema-field (name min max ftype choice-base spec-url accessor) #:transparent)
(define (schema-field-kind sf) (card->kind (schema-field-min sf) (schema-field-max sf)))

;; -------------------------------------------------------------------
;; Ftype — a field's referenced type, as a tagged vector. One of:
;;   #(prim <code-string>)   a primitive (the FHIR primitive code, e.g. "uri")
;;   #(type <type-symbol>)   a complex type (e.g. 'Coding)
;;   #(resource)             a contained/polymorphic resource
;;   #(raw)                  a plain string field on a base struct (id/language/…)
;;   #(unknown)              unresolved
;; Always use these accessors — never (vector-ref ftype n).
;; -------------------------------------------------------------------
(define (ftype-tag ft)       (vector-ref ft 0))
(define (ftype-prim-code ft) (vector-ref ft 1))   ; valid when (ftype-prim? ft)
(define (ftype-type-name ft) (vector-ref ft 1))   ; valid when (ftype-type? ft)
(define (ftype-prim? ft)     (eq? (ftype-tag ft) 'prim))
(define (ftype-type? ft)     (eq? (ftype-tag ft) 'type))
(define (ftype-resource? ft) (eq? (ftype-tag ft) 'resource))
(define (ftype-raw? ft)      (eq? (ftype-tag ft) 'raw))

;; -------------------------------------------------------------------
;; field-spec / choice-group — the two kinds of constraint-schema entry, embedded in generated
;; form macros. PREFAB structs: they serialize as `#s(field-spec …)` / `#s(choice-group …)`
;; literals in generated code and read back WITHOUT the definition, so the form macro consumes
;; them at compile time. NATIVE FHIR cardinality is the primitive; kind/req are derived views.
;;   field-spec  : name(symbol) min(nat) max(nat|'*) ftype(Ftype) extra(assoc-list|#f)
;;   choice-group: min(nat) max(nat|#f) members(listof symbol) — the value[x] choice group
;; A schema list mixes both, distinguished by TYPE (fs-choice? = choice-group?), not a magic name.
;; -------------------------------------------------------------------
(struct field-spec (name min max ftype extra) #:prefab)
(struct choice-group (min max members) #:prefab)

(define fs-name  field-spec-name)
(define fs-min   field-spec-min)
(define fs-max   field-spec-max)
(define fs-ftype field-spec-ftype)
(define fs-extra field-spec-extra)
(define (fs-req fs)  (>= (fs-min fs) 1))
(define (fs-kind fs) (card->kind (fs-min fs) (fs-max fs)))
(define fs-choice? choice-group?)                  ; distinguish the two entry kinds by TYPE

(define choice-min     choice-group-min)
(define choice-max     choice-group-max)
(define choice-members choice-group-members)

;; the entry contracts (the data definitions above)
(define field-spec/c
  (struct/c field-spec symbol? exact-nonnegative-integer? (or/c exact-nonnegative-integer? '*)
            ftype/c (or/c #f list?)))
(define choice-group/c
  (struct/c choice-group exact-nonnegative-integer? (or/c exact-integer? #f) (listof symbol?)))
(define schema-entry/c (or/c field-spec/c choice-group/c))

;; card->kind : the single/optional/list VIEW of a (min,max) pair (max>1 or '* ⇒ list, then
;; required-single vs optional). The native (min,max) remains the source of truth.
(define (card->kind min max)
  (cond [(eq? max '*) 'list]
        [(> max 1)    'list]
        [(>= min 1)   'single]
        [else         'optional]))

;; max-of : a FHIR max string ("*" or a numeral) -> '* or a nat. The min comes through as a nat.
(define (max-of s) (if (equal? s "*") '* (or (string->number s) 1)))

;; -------------------------------------------------------------------
;; framework parents
;; -------------------------------------------------------------------
;; the framework parents whose instances are resources (carry resourceType in JSON)
(define resource-parents '(Resource DomainResource CanonicalResource MetadataResource))
(define (resource-parent? parent) (and (memq parent resource-parents) #t))

;; inherited fields per base parent (name order matches base.rkt's structs)
(define inherited
  (hash 'DomainResource  '(id meta implicitRules language text contained extension modifierExtension)
        'Resource        '(id meta implicitRules language)
        'BackboneElement '(id extension modifierExtension)
        'BackboneType    '(id extension modifierExtension)
        'DataType        '(id extension)
        'Element         '(id extension)))

(define (inherited-field-names parent) (hash-ref inherited parent '()))

;; default value for an inherited field
(define (inherited-field-default name)
  (case name
    [(extension contained modifierExtension) '()]
    [else #f]))

;; ftype of an inherited field (for read/write). id/implicitRules/language are plain strings.
(define (inherited-field-ftype name)
  (case name
    [(id implicitRules language) (vector 'raw)]
    [(meta)              (vector 'type 'Meta)]
    [(text)              (vector 'type 'Narrative)]
    [(contained)         (vector 'resource)]
    [(extension modifierExtension) (vector 'type 'Extension)]
    [else                (vector 'unknown)]))

;; cardinality of an inherited field. All are min 0; list-valued ones are 0..*, the rest 0..1.
(define (inherited-field-max name)
  (case name [(extension contained modifierExtension) '*] [else 1]))
(define (inherited-field-min name) 0)
(define (inherited-field-kind name) (card->kind (inherited-field-min name) (inherited-field-max name)))

;; ── examples (living documentation) ────────────────────────────────────────────────────────
(module+ test
  (require rackunit)
  ;; ftype selectors
  (check-equal? (ftype-tag #(prim "uri"))       'prim)
  (check-equal? (ftype-prim-code #(prim "uri")) "uri")
  (check-equal? (ftype-type-name #(type Coding)) 'Coding)
  (check-true   (ftype-prim? #(prim "code")))
  (check-false  (ftype-prim? #(type Coding)))
  (check-true   (ftype-raw? #(raw)))
  ;; FHIR max string -> native max; (min,max) -> kind view
  (check-equal? (max-of "1") 1)
  (check-equal? (max-of "*") '*)
  (check-equal? (max-of "5") 5)
  (check-equal? (card->kind 1 1) 'single)
  (check-equal? (card->kind 0 1) 'optional)
  (check-equal? (card->kind 0 '*) 'list)
  (check-equal? (card->kind 1 '*) 'list)
  ;; resource parents
  (check-true  (resource-parent? 'DomainResource))
  (check-false (resource-parent? 'DataType))
  ;; field-spec carries native (min,max); kind/req are derived; choice-group is a distinct type
  (let ([gender (field-spec 'gender 1 1 #(prim "code") #f)])
    (check-equal? (fs-name gender) 'gender)
    (check-equal? (cons (fs-min gender) (fs-max gender)) '(1 . 1))
    (check-equal? (fs-kind gender) 'single)
    (check-true   (fs-req  gender))
    (check-equal? (fs-ftype gender) #(prim "code"))
    (check-false  (fs-choice? gender)))
  (check-equal? (fs-kind (field-spec 'use 0 1 #(prim "code") #f)) 'optional)
  (let ([given (field-spec 'given 1 '* #(prim "string") #f)])     ; required list 1..*
    (check-equal? (cons (fs-min given) (fs-max given)) '(1 . *))
    (check-equal? (fs-kind given) 'list))
  ;; a choice-group entry is distinguished by type, not a magic name
  (check-true  (fs-choice? (choice-group 1 1 '(valueString valueQuantity))))
  (check-equal? (choice-members (choice-group 1 1 '(valueString valueQuantity)))
                '(valueString valueQuantity))
  ;; prefab round-trips through read/write without the struct definition
  (check-equal? (read (open-input-string "#s(field-spec given 1 * #(prim \"string\") #f)"))
                (field-spec 'given 1 '* #(prim "string") #f)))
