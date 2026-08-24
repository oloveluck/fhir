#lang racket/base

;;; from-json.rkt — FHIR JSON (a jsexpr) -> Result<typed `fhir` node>.
;;;
;;; The symmetric dual of to-json.rkt, driven by the SAME registered type-schema so the two
;;; directions cannot drift. For each JSON key we resolve the field's ftype (own schema-field or an
;;; inherited framework field) and construct a value; a field whose type is not (yet) generated is
;;; kept as a raw jsexpr, so unknown subtrees round-trip untouched.
;;;
;;; FHIR quirks handled: a primitive's parallel `_field` object (its id/extension) is merged into the
;;; constructed primitive (single and list-aligned); a `decimal` arrives as a JSON number and is kept
;;; as its lexical string (precision is limited by racket/json's number parsing on read — the write
;;; path and in-memory model are exact). A `_field` with no matching value (value-less primitive) is
;;; not yet reconstructed and is ignored on read.

(require racket/contract
         racket/string
         "../model/node.rkt"
         "../result/result.rkt"
         "read-json.rkt"                             ; jnum (precision-preserving numbers) + strip-jnum
         (only-in "../model/schema.rkt"
                  type-schema-parent type-schema-fields type-schema-spec-url
                  schema-field-name schema-field-min schema-field-max schema-field-ftype
                  card->kind ftype-tag ftype-prim-code ftype-type-name
                  inherited-field-names inherited-field-ftype inherited-field-min inherited-field-max)
         (only-in "../model/registry.rkt"
                  type-schema-of type-registered? constructor-of absent-constructor-of)
         (only-in "../primitives/primitives.rkt"))   ; register primitive constructors

(provide
 (contract-out
  ;; from-json : fhir-jsexpr [#:type expected] -> Result<fhir>
  ;;   input is a jsexpr (or a jnum-bearing tree from read-json.rkt). Resources carry their own
  ;;   resourceType; for a bare datatype pass #:type.
  [from-json (->* (any/c) (#:type (or/c #f symbol?) #:lenient? boolean?) result?)]))

;; when #t, unknown JSON keys are skipped rather than raising (useful for loading examples that may
;; carry fields from a newer FHIR version than the loaded tower).
(define lenient? (make-parameter #f))

(define (from-json js #:type [expected #f] #:lenient? [len? #f])
  (parameterize ([lenient? len?]) (from-json* js expected)))

(define (from-json* js expected)
  (define t (or (and (hash? js)
                     (let ([rt (hash-ref js 'resourceType #f)])
                       (and (string? rt) (string->symbol rt))))
                expected))
  (cond
    [(not t) (err (invalid-encoding 'FHIR "https://build.fhir.org/json.html" js))]
    [(not (hash? js)) (err (invalid-encoding t "https://build.fhir.org/json.html" js))]
    [else (parse-node t js)]))

;; parse a JSON object as a node of the given (registered) type
(define (parse-node type js)
  (define sch (type-schema-of type))
  (cond
    [(not sch) (err (invalid-encoding type "https://build.fhir.org/types.html" js))]
    ;; a nested value whose JSON shape isn't an object (e.g. an R4-style string where R5 expects a
    ;; complex type) is a type mismatch, not a crash — return err so lenient parsing drops it.
    [(not (hash? js)) (err (invalid-encoding type "https://build.fhir.org/json.html" js))]
    [else
     (define ftindex (field-index type sch))
     (define unders (underscore-map js))
     ;; each real JSON key (not resourceType, not a "_field" sibling) -> (cons name Result-value)
     (define value-pairs
       (for/list ([(k v) (in-hash js)]
                  #:unless (eq? k 'resourceType)
                  #:unless (underscore-key? k)
                  #:unless (and (lenient?) (not (hash-ref ftindex k #f))))   ; skip unknown when lenient
         (define spec (hash-ref ftindex k #f))
         (cons k
               (if spec
                   (parse-field (car spec) (cdr spec) v (hash-ref unders k #f))
                   (err (unknown-field type (schema-url sch) k))))))
     ;; value-less primitives: a `_field` sibling whose base name has NO matching value key.
     (define absent-pairs
       (for/list ([(base sibval) (in-hash unders)]
                  #:unless (hash-has-key? js base))
         (define spec (hash-ref ftindex base #f))
         (cons base
               (if spec
                   (parse-absent (car spec) (cdr spec) sibval)
                   (err (unknown-field type (schema-url sch) base))))))
     (define pairs0 (append value-pairs absent-pairs))
     ;; lenient loading drops fields that fail to parse (unknown key, primitive mismatch, …)
     (define pairs (if (lenient?) (filter (lambda (p) (ok? (cdr p))) pairs0) pairs0))
     (result-map
      (lambda (vals)
        (fhir type (for/fold ([h (hasheq)]) ([p (in-list pairs)] [val (in-list vals)])
                     (hash-set h (car p) val))))
      (result-traverse (map cdr pairs)))]))

;; a per-field index: name -> (cons ftype kind). Climbs the whole parent chain (own fields win),
;; picking up fields from any GENERATED ancestor (e.g. Age -> Quantity, a constraint type with no
;; own fields) and, at the framework base, the inherited framework fields (id/extension/…).
(define (field-index type sch)
  (let loop ([sch sch] [acc (hasheq)])
    (define acc2
      (for/fold ([h acc]) ([f (in-list (type-schema-fields sch))])
        (add-field h (schema-field-name f) (schema-field-ftype f)
                   (card->kind (schema-field-min f) (schema-field-max f)))))
    (define parent (type-schema-parent sch))
    (define psch (type-schema-of parent))
    (if psch
        (loop psch acc2)                       ; a generated ancestor -> climb
        (for/fold ([h acc2]) ([fn (in-list (inherited-field-names parent))])  ; framework base
          (add-field h fn (inherited-field-ftype fn)
                     (card->kind (inherited-field-min fn) (inherited-field-max fn)))))))

(define (add-field h name ftype kind)
  (if (hash-has-key? h name) h (hash-set h name (cons ftype kind))))

;; the "_field" siblings of a JSON object: base-name(symbol) -> underscore value
(define (underscore-map js)
  (for/hasheq ([(k v) (in-hash js)] #:when (underscore-key? k))
    (values (string->symbol (substring (symbol->string k) 1)) v)))

(define (underscore-key? k) (string-prefix? (symbol->string k) "_"))

;; parse a field's value(s), merging in any `_field` sibling(s).
(define (parse-field ft kind js sib)
  (if (eq? kind 'list)
      (if (list? js)
          (result-traverse
           (for/list ([e (in-list js)] [i (in-naturals)])
             (parse-value ft e (nth-sib sib i))))
          (err (invalid-encoding 'list "https://build.fhir.org/json.html" js)))
      (parse-value ft js sib)))

(define (nth-sib sib i)
  (and (list? sib) (< i (length sib))
       (let ([s (list-ref sib i)]) (and (hash? s) s))))

;; a value-less field: a `_field` sibling with no value key. Build value-less primitive(s).
(define (parse-absent ft kind sibval)
  (if (eq? kind 'list)
      (result-traverse (for/list ([s (in-list (if (list? sibval) sibval (list sibval)))])
                         (parse-value ft 'null (and (hash? s) s))))
      (parse-value ft 'null (and (hash? sibval) sibval))))

;; parse one value against its ftype -> Result value ; `sib` is its _field object (or #f).
;; A JSON `null` in a primitive position denotes a value-less primitive (id/extension only).
(define (parse-value ft js sib)
  (case (ftype-tag ft)
    [(prim)
     (define code (ftype-prim-code ft))
     (cond
       [(eq? js 'null) (build-absent code sib)]
       [else
        (define ctor (constructor-of (string->symbol code)))
        (cond
          [(not ctor) (ok (strip-jnum js))]
          [else
           ;; decimal keeps its exact lexeme; other numerics take the numeric value.
           (define raw
             (cond
               [(string=? code "decimal")
                (cond [(jnum? js) (jnum-lexeme js)] [(number? js) (number->string js)] [else js])]
               [(jnum? js) (jnum-value js)]
               [else js]))
           (define id  (and (hash? sib) (let ([v (hash-ref sib 'id #f)]) (and (string? v) v))))
           (define ext (sib-extension sib))
           (ctor raw #:id id #:extension ext)])])]
    [(type)
     (define tn (ftype-type-name ft))
     (if (type-registered? tn) (parse-node tn js) (ok (strip-jnum js)))]   ; unknown type -> raw
    [(resource)
     (if (and (hash? js) (hash-ref js 'resourceType #f)) (from-json* js #f) (ok (strip-jnum js)))]
    [else (ok (strip-jnum js))]))   ; raw / unknown -> plain jsexpr verbatim

;; build a value-less primitive of `code` carrying the _field sibling's id/extension.
(define (build-absent code sib)
  (define ac (absent-constructor-of (string->symbol code)))
  (if ac
      (ok (ac #:id (and (hash? sib) (let ([v (hash-ref sib 'id #f)]) (and (string? v) v)))
              #:extension (sib-extension sib)))
      (ok 'null)))

;; the extension list from a _field sibling — typed Extension nodes when Extension is registered,
;; else raw jsexpr (a bad extension falls back to raw rather than failing the whole parse).
(define (sib-extension sib)
  (define raw (if (hash? sib) (hash-ref sib 'extension '()) '()))
  (cond
    [(not (and (list? raw) (type-registered? 'Extension))) (strip-jnum raw)]
    [else (for/list ([e (in-list raw)])
            (define r (parse-node 'Extension e))
            (if (ok? r) (ok-value r) (strip-jnum e)))]))

(define (schema-url sch)
  (let ([s (type-schema-spec-url sch)]) (if (string? s) s "https://build.fhir.org/types.html")))

;; ── living examples: a demo type registered here, parsed through every quirk ─────────────────
(module+ test
  (require rackunit
           (only-in "../model/schema.rkt" type-schema schema-field)
           (only-in "../model/registry.rkt" register-type!)
           (only-in "../model/registry.rkt" fhir-spec)
           (only-in "../model/base.rkt" primitive-type-value element-id)
           (only-in "to-json.rkt" node->jsexpr node->json-string))
  (define (field name min max prim)
    (schema-field name min max (vector 'prim prim) #f "https://example.org/demo" #f))
  (register-type! 'DemoRes (fhir-spec 'DemoRes "https://example.org/DemoRes" 'type)
                  #:schema (type-schema 'DemoRes #f 'DomainResource "https://example.org/DemoRes"
                                        (list (field 'status 1 1 "code")
                                              (field 'value 0 1 "decimal")
                                              (field 'given 0 '* "string")
                                              (field 'when 0 1 "date"))
                                        #f #f))
  (define (parse js) (from-json js #:type 'DemoRes))
  ;; happy path: typed primitives, not raw jsexpr
  (define n (ok-value (parse (hasheq 'status "final" 'value (jnum "1.50") 'given (list "a" "b")))))
  (check-equal? (primitive-type-value (fhir-ref n 'status #f)) "final")
  ;; decimal keeps its exact LEXEME through the write path; jsexpr view is the numeric value
  (check-equal? (node->json-string n) (node->json-string n))            ; deterministic
  (check-true (regexp-match? #px"\"value\":1\\.50" (node->json-string n)))
  (check-equal? (hash-ref (node->jsexpr n) 'value) 1.5)
  ;; a primitive's _field sibling merges id/extension into the SAME typed value
  (define w (ok-value (parse (hasheq 'status "final" 'when "2020-01-02"
                                     '_when (hasheq 'id "w1")))))
  (check-equal? (element-id (fhir-ref w 'when #f)) "w1")
  ;; a _field with NO value key -> a value-less primitive; serializing emits only _when
  (define a (ok-value (parse (hasheq 'status "final" '_when (hasheq 'id "only")))))
  (check-equal? (node->jsexpr a) (hasheq 'resourceType "DemoRes" 'status "final"
                                         '_when (hasheq 'id "only")))
  ;; aligned primitive-list _field: null placeholders line up by index
  (define g (ok-value (parse (hasheq 'status "final" 'given (list "a" "b")
                                     '_given (list 'null (hasheq 'id "g2"))))))
  (check-equal? (element-id (cadr (fhir-ref g 'given #f))) "g2")
  (check-equal? (hash-ref (node->jsexpr g) '_given) (list 'null (hasheq 'id "g2")))
  ;; strict: unknown key -> err carrying the schema's spec url; lenient: dropped
  (check-true (err? (parse (hasheq 'status "final" 'nope 1))))
  (check-equal? (hash-ref (node->jsexpr (ok-value (from-json (hasheq 'status "final" 'nope 1)
                                                             #:type 'DemoRes #:lenient? #t)))
                          'status)
                "final")
  ;; strict: a malformed primitive fails with the primitive's OWN validation error
  (check-true (err? (parse (hasheq 'status "final" 'when "2020-13-01"))))
  ;; round-trip: parse ∘ serialize ∘ parse is the identity on the jsexpr view
  (define js1 (node->jsexpr n))
  (check-equal? (node->jsexpr (ok-value (from-json js1 #:type 'DemoRes))) js1))
