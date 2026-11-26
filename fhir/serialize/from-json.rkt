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
         (except-in fhir/model/node lazy-fhir make-reader)
         (only-in (submod fhir/model/node unchecked) lazy-fhir make-reader)   ; made for every node read: see node.rkt
         fhir/result/result
         "read-json.rkt"                             ; jnum (precision-preserving numbers) + strip-jnum
         (only-in fhir/model/schema
                  type-schema-parent type-schema-fields type-schema-spec-url
                  schema-field-name schema-field-min schema-field-max schema-field-ftype
                  card->kind ftype-tag ftype-prim-code ftype-type-name
                  inherited-field-names inherited-field-ftype inherited-field-min inherited-field-max)
         (only-in fhir/model/registry
                  type-schema-of type-registered? constructor-of absent-constructor-of)
         (only-in fhir/primitives/primitives))   ; register primitive constructors

(provide
 (contract-out
  ;; from-json : fhir-jsexpr [#:type expected] -> Result<fhir>
  ;;   input is a jsexpr (or a jnum-bearing tree from read-json.rkt). Resources carry their own
  ;;   resourceType; for a bare datatype pass #:type.
  [from-json (->* (any/c) (#:type (or/c #f symbol?) #:lenient? boolean?) result?)]))

;; lenient? (an argument threaded through the read): when #t, unknown JSON keys and values that do
;; not read are left out rather than failing the read (useful for loading examples that may carry
;; fields from a newer FHIR version than the loaded tower); the nodes are then lazy (parse-node).
(define (from-json js #:type [expected #f] #:lenient? [len? #f])
  (from-json* js expected len?))

(define (from-json* js expected lenient?)
  (define t (or (and (hash? js)
                     (let ([rt (hash-ref js 'resourceType #f)])
                       (and (string? rt) (string->symbol rt))))
                expected))
  (cond
    [(not t) (err (invalid-encoding 'FHIR "https://build.fhir.org/json.html" js))]
    [(not (hash? js)) (err (invalid-encoding t "https://build.fhir.org/json.html" js))]
    [else (parse-node t js lenient?)]))

;; parse a JSON object as a node of the given (registered) type. Read leniently, the node is LAZY
;; (model/node.rkt): its fields are read when first asked, its nested nodes lazy in turn, and what
;; the read leaves out is recorded on it (`fhir-drops`). A lenient read of an object never fails
;; (every field that does not read is dropped), so reading it later gives the node reading it now
;; would. Read strictly, every field is read now, for its errors.
(define (parse-node type js lenient?)
  (define sch (type-schema-of type))
  (cond
    [(not sch) (err (invalid-encoding type "https://build.fhir.org/types.html" js))]
    ;; a nested value whose JSON shape isn't an object (e.g. an R4-style string where R5 expects a
    ;; complex type) is a type mismatch, not a crash — return err so lenient parsing drops it.
    [(not (hash? js)) (err (invalid-encoding type "https://build.fhir.org/json.html" js))]
    [lenient? (ok (lazy-fhir type (lenient-reader type sch js)))]
    [else
     (define pairs (field-pairs type sch js #f))
     (result-map
      (lambda (vals)
        (fhir type (for/fold ([h (hasheq)]) ([p (in-list pairs)] [val (in-list vals)])
                     (hash-set h (field-pair-key p) val))))
      (result-traverse (map field-pair-value pairs)))]))

;; A FieldPair is (field-pair key value sibling?): a field of the node and its Result value; key
;; is the element's name, sibling? says it was read from a value-less `_key` sibling alone.
(struct field-pair (key value sibling?))

;; field-pairs : type schema object -> (listof FieldPair)   every field of the object, read (a key
;; the type does not have is an error; leniently it is left out here and recorded by lenient-fields)
(define (field-pairs type sch js lenient?)
  (define ftindex (field-index type sch))
  (define unders (underscore-map js))
  ;; each real JSON key (not resourceType, not a "_field" sibling)
  (define value-pairs
    (for/list ([(k v) (in-hash js)]
               #:unless (eq? k 'resourceType)
               #:unless (underscore-key? k)
               #:unless (and lenient? (not (hash-ref ftindex k #f))))   ; skip unknown when lenient
      (define spec (hash-ref ftindex k #f))
      (field-pair k
                  (if spec
                      (parse-field (car spec) (cdr spec) v (hash-ref unders k #f) lenient?)
                      (err (unknown-field type (schema-url sch) k)))
                  #f)))
  ;; value-less primitives: a `_field` sibling whose base name has NO matching value key.
  (define absent-pairs
    (for/list ([(base sibval) (in-hash unders)]
               #:unless (hash-has-key? js base))
      (define spec (hash-ref ftindex base #f))
      (field-pair base
                  (if spec
                      (parse-absent (car spec) (cdr spec) sibval lenient?)
                      (err (unknown-field type (schema-url sch) base)))
                  #t)))
  (append value-pairs absent-pairs))

;; ---- a node read a field at a time ----------------------------------------------------------------
;; lenient-reader : type schema object -> Reader (model/node.rkt)   how a lenient node's fields are
;; read: one alone when one is asked for (`fhir-ref`: a path's step), all when all are (`fhir-fields`).
;;   seen   : what `one` has answered — name -> value | no-field — so a field is read once, and
;;            `all` hands on the very values `one` answered (lenient-fields takes them)
;;   failed : the Drops of the asked fields that did not read
;; What reading those left out is `failed` and the keys the type does not have at all (asked for
;; or not: a path cannot name them) — once any field has been asked of the node; a node nothing
;; was asked of has read nothing and left nothing out.
(define unasked (string->uninterned-symbol "unasked"))
(define (lenient-reader type sch js)
  (define seen (make-hasheq))
  (define failed '())
  (define (sibling-of k) (let ([u (underscore-of k)]) (if (hash-has-key? js u) (list (cons u (hash-ref js u))) '())))
  ;; read : name -> value | no-field   the field read from the object, as lenient-fields reads it
  (define (read name)
    (define v (hash-ref js name unasked))
    (cond
      [(eq? name 'resourceType) no-field]
      [(not (eq? v unasked))
       (define spec (hash-ref (field-index type sch) name #f))
       (define r (and spec (parse-field (car spec) (cdr spec) v (hash-ref js (underscore-of name) #f) #t)))
       (cond [(not spec) no-field]                 ; a key the type lacks: among `left-out`
             [(ok? r) (ok-value r)]
             [else (set! failed (append failed (cons (cons name v) (sibling-of name)))) no-field])]
      ;; a value-less primitive: a `_name` sibling with no `name`
      [(hash-has-key? js (underscore-of name))
       (define spec (hash-ref (field-index type sch) name #f))
       (define r (and spec (parse-absent (car spec) (cdr spec) (hash-ref js (underscore-of name)) #t)))
       (cond [(and r (ok? r)) (ok-value r)]
             [else (set! failed (append failed (list (cons (underscore-of name) (hash-ref js (underscore-of name)))))) no-field])]
      [else no-field]))
  (define (one name)
    (define kept (hash-ref seen name unasked))
    (cond [(not (eq? kept unasked)) kept]
          [else (define v (read name)) (hash-set! seen name v) v]))
  ;; the keys the type does not have, each with its `_key` sibling
  (define (unknown-keys)
    (define ftindex (field-index type sch))
    (for*/list ([(k v) (in-hash js)]
                #:unless (eq? k 'resourceType)
                #:unless (underscore-key? k)
                #:unless (hash-ref ftindex k #f)
                [d (in-list (cons (cons k v) (sibling-of k)))])
      d))
  (define (any-unknown-key?)
    (define ftindex (field-index type sch))
    (for/or ([k (in-hash-keys js)])
      (not (or (hash-ref ftindex k #f) (eq? k 'resourceType) (underscore-key? k)))))
  (make-reader (lambda () (lenient-fields type sch js seen))
               one
               (lambda () (for/hasheq ([(k v) (in-hash seen)] #:unless (eq? v no-field)) (values k v)))
               ;; (nearly every object has only keys its type has and no value that failed: said
               ;; without a list made — this is asked of every node a view read, after it ran)
               (lambda () (if (or (zero? (hash-count seen)) (and (null? failed) (not (any-unknown-key?))))
                              '()
                              (filter (lambda (d) (not (eq? (cdr d) 'null))) (append (unknown-keys) failed))))))

;; lenient-fields : type schema object -> (values fields Drops)   the fields that read, and the keys
;; of the object left out with their JSON (a key the type does not have, a value that does not
;; read, with its `_key` sibling; a value-less `_key` that does not read). A JSON null is not data.
;; One pass over the object (it is what every lenient read of every node runs): what `field-pairs`
;; answers leniently, sorted as it is read into the fields, the keys the type lacks and the values
;; that failed — in the order the passes over its pairs gave them (`lenient-fields/pairs`, kept
;; below as the definition; the test holds the two equal). `seen` holds the fields a Reader has read
;; alone (name -> value | no-field, for one that did not read): they are taken as they were read.
(define (lenient-fields type sch js [seen #f])
  ;; read-as : name (-> Result) -> Result | 'failed   the field as it was read alone, else read now
  (define (read-as name read)
    (define kept (if seen (hash-ref seen name unasked) unasked))
    (cond [(eq? kept unasked) (read)]
          [(eq? kept no-field) 'failed]
          [else (ok kept)]))
  (define ftindex (field-index type sch))
  (define unders (underscore-map js))
  (define (sibling-of k) (let ([u (underscore-of k)]) (if (hash-has-key? js u) (list (cons u (hash-ref js u))) '())))
  ;; the object's own keys: a field that reads, a key the type lacks, a value that does not read
  (define-values (fields unknown failed)
    (for/fold ([fields (hasheq)] [unknown '()] [failed '()])
              ([(k v) (in-hash js)]
               #:unless (eq? k 'resourceType)
               #:unless (underscore-key? k))
      (define spec (hash-ref ftindex k #f))
      (cond
        [(not spec) (values fields (append (reverse (cons (cons k v) (sibling-of k))) unknown) failed)]
        [else
         (define r (read-as k (lambda () (parse-field (car spec) (cdr spec) v (hash-ref unders k #f) #t))))
         (if (and (not (eq? r 'failed)) (ok? r))
             (values (hash-set fields k (ok-value r)) unknown failed)
             (values fields unknown (append (reverse (cons (cons k v) (sibling-of k))) failed)))])))
  ;; value-less primitives: a `_field` sibling whose base name has NO matching value key
  (define-values (fields* failed*)
    (for/fold ([fields fields] [failed failed])
              ([(base sibval) (in-hash unders)]
               #:unless (hash-has-key? js base))
      (define spec (hash-ref ftindex base #f))
      (define r (and spec (read-as base (lambda () (parse-absent (car spec) (cdr spec) sibval #t)))))
      (if (and r (not (eq? r 'failed)) (ok? r))
          (values (hash-set fields base (ok-value r)) failed)
          (values fields (cons (cons (underscore-of base) (hash-ref js (underscore-of base))) failed)))))
  (values fields* (filter (lambda (d) (not (eq? (cdr d) 'null))) (append (reverse unknown) (reverse failed*)))))

;; lenient-fields/pairs : the same, as passes over `field-pairs`: the definition lenient-fields is
;; held to
(define (lenient-fields/pairs type sch js)
  (define pairs (field-pairs type sch js #t))
  (define ftindex (field-index type sch))
  (define fields
    (for/fold ([h (hasheq)]) ([p (in-list pairs)] #:when (ok? (field-pair-value p)))
      (hash-set h (field-pair-key p) (ok-value (field-pair-value p)))))
  (define (sibling-of k) (let ([u (underscore-of k)]) (if (hash-has-key? js u) (list (cons u (hash-ref js u))) '())))
  (define unknown
    (for*/list ([(k v) (in-hash js)]
                #:unless (eq? k 'resourceType)
                #:unless (underscore-key? k)
                #:unless (hash-ref ftindex k #f)
                [d (in-list (cons (cons k v) (sibling-of k)))])
      d))
  (define failed
    (for*/list ([p (in-list pairs)] #:when (err? (field-pair-value p))
                [d (in-list (if (field-pair-sibling? p)
                                (list (cons (underscore-of (field-pair-key p)) (hash-ref js (underscore-of (field-pair-key p)))))
                                (cons (cons (field-pair-key p) (hash-ref js (field-pair-key p))) (sibling-of (field-pair-key p)))))])
      d))
  (values fields (filter (lambda (d) (not (eq? (cdr d) 'null))) (append unknown failed))))

;; underscore-of : symbol -> symbol   'birthDate -> '_birthDate (memoised)
(define underscored (make-weak-hasheq))
(define (underscore-of k)
  (hash-ref! underscored k (lambda () (string->symbol (string-append "_" (symbol->string k))))))

;; a per-field index: name -> (cons ftype kind). Climbs the whole parent chain (own fields win),
;; picking up fields from any GENERATED ancestor (e.g. Age -> Quantity, a constraint type with no
;; own fields) and, at the framework base, the inherited framework fields (id/extension/…).
;; It depends only on the schema, so it is built once per schema (it was rebuilt for every node).
(define field-indexes (make-weak-hasheq))
(define (field-index type sch) (hash-ref! field-indexes sch (lambda () (build-field-index sch))))
(define (build-field-index sch)
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
    (values (underscore-base k) v)))

;; underscore-base : symbol -> symbol|#f   `_birthDate` -> 'birthDate; #f for a key without the `_`.
;; Memoised per key: every object of every resource asks it of every key.
(define underscore-bases (make-weak-hasheq))
(define (underscore-base k)
  (hash-ref! underscore-bases k
             (lambda () (let ([s (symbol->string k)])
                          (and (string-prefix? s "_") (string->symbol (substring s 1)))))))
(define (underscore-key? k) (and (underscore-base k) #t))

;; parse a field's value(s), merging in any `_field` sibling(s).
(define (parse-field ft kind js sib lenient?)
  (if (eq? kind 'list)
      (if (list? js)
          (result-traverse
           (for/list ([e (in-list js)] [i (in-naturals)])
             (parse-value ft e (nth-sib sib i) lenient?)))
          (err (invalid-encoding 'list "https://build.fhir.org/json.html" js)))
      (parse-value ft js sib lenient?)))

(define (nth-sib sib i)
  (and (list? sib) (< i (length sib))
       (let ([s (list-ref sib i)]) (and (hash? s) s))))

;; a value-less field: a `_field` sibling with no value key. Build value-less primitive(s).
(define (parse-absent ft kind sibval lenient?)
  (if (eq? kind 'list)
      (result-traverse (for/list ([s (in-list (if (list? sibval) sibval (list sibval)))])
                         (parse-value ft 'null (and (hash? s) s) lenient?)))
      (parse-value ft 'null (and (hash? sibval) sibval) lenient?)))

;; parse one value against its ftype -> Result value ; `sib` is its _field object (or #f).
;; A JSON `null` in a primitive position denotes a value-less primitive (id/extension only).
(define (parse-value ft js sib lenient?)
  (case (ftype-tag ft)
    [(prim)
     (define code (ftype-prim-code ft))
     (cond
       [(eq? js 'null) (build-absent code sib lenient?)]
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
           (define ext (sib-extension sib lenient?))
           (ctor raw #:id id #:extension ext)])])]
    [(type)
     (define tn (ftype-type-name ft))
     (if (type-registered? tn) (parse-node tn js lenient?) (ok (strip-jnum js)))]   ; unknown type -> raw
    [(resource)
     (if (and (hash? js) (hash-ref js 'resourceType #f)) (from-json* js #f lenient?) (ok (strip-jnum js)))]
    [else (ok (strip-jnum js))]))   ; raw / unknown -> plain jsexpr verbatim

;; build a value-less primitive of `code` carrying the _field sibling's id/extension.
(define (build-absent code sib lenient?)
  (define ac (absent-constructor-of (string->symbol code)))
  (if ac
      (ok (ac #:id (and (hash? sib) (let ([v (hash-ref sib 'id #f)]) (and (string? v) v)))
              #:extension (sib-extension sib lenient?)))
      (ok 'null)))

;; the extension list from a _field sibling — typed Extension nodes when Extension is registered,
;; else raw jsexpr (a bad extension falls back to raw rather than failing the whole parse).
(define (sib-extension sib lenient?)
  (define raw (if (hash? sib) (hash-ref sib 'extension '()) '()))
  (cond
    [(not (and (list? raw) (type-registered? 'Extension))) (strip-jnum raw)]
    [else (for/list ([e (in-list raw)])
            (define r (parse-node 'Extension e lenient?))
            (if (ok? r) (ok-value r) (strip-jnum e)))]))

(define (schema-url sch)
  (let ([s (type-schema-spec-url sch)]) (if (string? s) s "https://build.fhir.org/types.html")))

;; ── living examples: a demo type registered here, parsed through every quirk ─────────────────
(module+ test
  (require rackunit
           (only-in fhir/model/schema type-schema schema-field)
           (only-in fhir/model/registry register-type!)
           (only-in fhir/model/registry fhir-spec)
           (only-in fhir/model/base primitive-type-value element-id)
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
  (check-equal? (node->jsexpr (ok-value (from-json js1 #:type 'DemoRes))) js1)
  ;; the one-pass lenient reader answers what the passes over field-pairs do: the same fields and
  ;; the same drops in the same order — for a key the type lacks (with its `_` sibling), a value
  ;; that does not read (with its sibling), a value-less `_key` that reads and one that names no
  ;; element, a JSON null, and nothing wrong at all
  (define demo (type-schema-of 'DemoRes))
  (for ([js (in-list (list (hasheq 'status "final" 'given (list "a" "b") 'value (jnum "1.50"))
                           (hasheq 'status "final" 'nope 1 '_nope (hasheq 'id "n") 'zzz (hasheq 'a 1) 'aaa 'null)
                           (hasheq 'status "final" 'when "2020-13-01" '_when (hasheq 'id "w") 'value "x")
                           (hasheq 'status "final" '_when (hasheq 'id "only") '_nowhere (hasheq 'id "x") '_given (list 'null))
                           (hasheq 'resourceType "DemoRes" 'status 'null 'given "not a list" '_given (list (hasheq 'id "g")))
                           (hasheq)))])
    (define-values (fields drops) (lenient-fields 'DemoRes demo js))
    (define-values (fields/pairs drops/pairs) (lenient-fields/pairs 'DemoRes demo js))
    (check-equal? fields fields/pairs)
    (check-equal? drops drops/pairs)))
