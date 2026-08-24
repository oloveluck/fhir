#lang racket/base

;;; validate.rkt — validate a FHIR resource (raw jsexpr) against its StructureDefinition / profiles.
;;;
;;; Architecture (after fhir4s): a structural recursion over the raw JSON against the target's snapshot
;;; element index, applying pure rule functions per child element (cardinality, unknown-element, choice,
;;; primitive format, fixed/pattern, required binding, basic value/pattern slicing), plus an invariant
;;; pass that evaluates each element's constraint.expression with the FHIRPath engine over the typed
;;; node. The governing rule is FAIL-OPEN: never report an issue when anything is undecidable
;;; (unresolvable type/profile/ValueSet, unparseable expression, unknown discriminator). Result is an
;;; OperationOutcome node. Validate the RAW jsexpr (lenient parsing would hide unknown elements); the
;;; typed node is used only for invariants.

(require racket/contract
         racket/string
         racket/list
         (only-in "sd-index.rkt" resolve-sd-raw)
         (only-in "element-index.rkt"
                  make-element-index element-index? index-elements index-root child-elements slices-of
                  index-by-id type-index opaque-type?)
         (only-in "../model/leaf.rkt" listify)
         (only-in "../model/binding.rkt" binding-expansion)
         (only-in "snapshot.rkt" generate-snapshot)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../serialize/to-json.rkt" node->jsexpr)
         (only-in "../serialize/read-json.rkt" jnum? jnum-lexeme jnum-value)
         (only-in "../result/result.rkt" ok? ok-value ok-or-raise err)
         (only-in "../model/registry.rkt" constructor-of)
         (only-in "../fhirpath/eval.rkt" eval-fhirpath)
         (only-in "../fhirpath/parser/parse.rkt" parse-fhirpath)
         (only-in "../fhirpath/value.rkt" item->system)
         (only-in "../serialize/jsexpr-util.rkt" drop-false)
         (only-in "../fhirpath/terminology.rkt" tx-service-validate tx-service-expand))

(provide
 (struct-out issue)
 (contract-out
  [validate-issues (->* (hash?) (#:profiles (listof hash?) #:terminology any/c #:invariants? boolean? #:duplicates (listof string?)) (listof issue?))]
  [validate-json   (->* (hash?) (#:profiles (listof hash?) #:terminology any/c #:invariants? boolean? #:duplicates (listof string?)) any/c)]))

(struct issue (severity code path msg) #:transparent)

;; ---- entry -----------------------------------------------------------------------------------
;; Invariants are OFF by default: our FHIRPath engine (TCK-complete, but not identical to the Java
;; reference on every real constraint) mis-evaluates some base invariants (ele-1, sdf-8, csd-1) and
;; would over-report. Structural + binding checks are proven fail-open-clean on valid R5 resources.
(define (validate-json json #:profiles [profiles '()] #:terminology [tx #f] #:invariants? [inv? #f] #:duplicates [dups '()])
  (issues->outcome (validate-issues json #:profiles profiles #:terminology tx #:invariants? inv? #:duplicates dups)))

;; `duplicates` are dotted paths of collapsed duplicate JSON keys (from read-fhir-json/duplicates) —
;; a fact the reader observed, so reporting them is never a false positive. Each is one error issue.
(define (validate-issues json #:profiles [profiles '()] #:terminology [tx #f] #:invariants? [inv? #f] #:duplicates [dups '()])
  ;; keep the jnum-bearing tree: decimals must be validated on their exact lexeme (a stripped number
  ;; loses the precision the FHIR decimal regex is about). Per-check helpers strip where needed.
  (define dup-issues
    (for/list ([p (in-list dups)])
      (issue "error" "invalid" p (format "duplicate JSON property '~a'" p))))
  (define rt (and (hash? json) (hash-ref json 'resourceType #f)))
  (cond
    [(not (string? rt)) (append dup-issues (list (issue "error" "structure" #f "resource has no resourceType")))]
    [else
     ;; targets: the base type (cached index) + any resolvable meta.profile + supplied profiles
     (define indexes (target-indexes rt json profiles))
     (cond
       [(null? indexes) dup-issues]                   ; unknown type / unresolvable -> fail-open (dups still real)
       [else
        (define node (let ([r (from-json json #:lenient? #t)]) (and (ok? r) (ok-value r))))
        (define seen (make-hash))
        (for/fold ([acc (reverse dup-issues)] #:result (reverse acc))
                  ([i (in-list indexes)] #:when i)
          (define issues (append (walk i rt json tx) (if inv? (invariant-issues i rt node) '())))
          (for/fold ([acc acc]) ([is (in-list issues)])
            (define k (list (issue-code is) (issue-path is) (issue-msg is)))
            (if (hash-ref seen k #f) acc (begin (hash-set! seen k #t) (cons is acc)))))])]))

;; element indexes to validate against: the base type via the cached `type-index`, plus meta.profile +
;; supplied profiles whose `type` matches (their snapshots generated on demand)
(define (target-indexes rt json profiles)
  (define metaprofs
    (let ([m (hash-ref json 'meta #f)]) (if (hash? m) (let ([p (hash-ref m 'profile '())]) (if (list? p) p '())) '())))
  (define profile-sds
    (filter (lambda (sd) (and sd (equal? (hash-ref sd 'type #f) rt)))
            (append (filter-map resolve-sd-raw metaprofs) profiles)))
  (filter values (cons (type-index rt) (map idx-of profile-sds))))

;; a target's element index: its shipped snapshot, else one generated from its differential.
;; FAIL OPEN on a snapshot we could not really build: when a profile's baseDefinition is not
;; resolvable (an IG profile deriving from another IG profile), generation yields little more than
;; the differential, and validating against THAT would report every unmentioned element as
;; undefined. An index whose root has no children is unusable — discard it.
(define (idx-of sd)
  (define shipped (let ([s (hash-ref sd 'snapshot #f)]) (and (hash? s) (hash-ref s 'element #f))))
  (define snap (cond [(and (list? shipped) (pair? shipped)) shipped]
                     [(hash-ref sd 'differential #f) (generate-snapshot sd)]
                     [else #f]))
  (define idx (and (list? snap) (pair? snap) (make-element-index snap)))
  (and idx (usable-index? idx) idx))

;; usable when the root element actually has children to validate against
(define (usable-index? idx)
  (define root (index-root idx))
  (and root (pair? (child-elements idx (hash-ref root 'path "")))))

;; ---- structural walk -------------------------------------------------------------------------
;; walk the JSON object `obj` sitting at snapshot `path`, against element-index `idx`
(define (walk idx path obj tx)
  (cond
    [(not (hash? obj)) '()]
    [else
     (define children (child-elements idx path))
     (append
      ;; a resource's id must match the FHIR id grammar (checked at each resource boundary)
      (if (string? (hash-ref obj 'resourceType #f))
          (append (resource-id-issues path obj) (contained-id-issues path obj))
          '())
      (unknown-element-issues path obj children)
      (append-map (lambda (ce) (child-issues idx path ce obj tx)) children))]))

(define id-rx #px"^[A-Za-z0-9.-]{1,64}$")
(define (resource-id-issues path obj)
  (define id (hash-ref obj 'id #f))
  (if (and (string? id) (not (regexp-match? id-rx id)))
      (list (issue "error" "invalid" (string-append path ".id") (format "invalid resource id '~a'" id)))
      '()))

;; every contained resource must have an id, and those ids must be UNIQUE within the container
;; (they are the targets of that resource's internal `#id` references). Purely structural — a
;; duplicate is unambiguously invalid, so this can never be a false positive.
(define (contained-id-issues path obj)
  (define contained (let ([c (hash-ref obj 'contained #f)]) (if (list? c) c '())))
  (define ids (for/list ([c (in-list contained)] #:when (hash? c)) (hash-ref c 'id #f)))
  (define dups
    (for/fold ([seen (hash)] [out '()] #:result (reverse out)) ([id (in-list ids)])
      (cond [(not (string? id)) (values seen out)]
            [(hash-ref seen id #f) (values seen (cons id out))]
            [else (values (hash-set seen id #t) out)])))
  (for/list ([id (in-list (remove-duplicates dups))])
    (issue "error" "invalid" (string-append path ".contained")
           (format "duplicate contained resource id '~a'" id))))

(define (child-issues idx path ce obj tx)
  (define leaf (elem-leaf ce path))
  ;; keys aimed at this element with an ALLOWED variant (a disallowed choice variant is left for
  ;; unknown-element-issues and is not counted toward cardinality)
  (define matched (for/list ([k (in-list (hash-keys obj))] #:when (allowed-key? leaf ce k)) k))
  (define instances (append-map (lambda (k) (instances-of (hash-ref obj k))) matched))
  (append
   ;; an empty JSON array is never valid — the property should be absent if it has no values
   (for/list ([k (in-list matched)] #:when (null? (hash-ref obj k)))
     (issue "error" "structure" (child-loc path leaf) "array cannot be empty"))
   (cardinality-issues ce path leaf (length instances))
   (append-map (lambda (k)
                 (define tc (matched-type leaf ce k))     ; the concrete (narrowed) type of this variant
                 (append-map (lambda (v) (value-issues idx ce tc (child-loc path leaf) v tx))
                             (instances-of (hash-ref obj k)))) matched)
   (slice-issues idx path ce obj)))

;; per-instance value checks, against the element's concrete (narrowed) type `tc`
(define (value-issues idx ce tc loc v tx)
  (append (fixed-pattern-issues ce loc v)
          (primitive-issues tc loc v)
          (binding-issues ce loc v tx)
          (recurse-issues idx ce tc loc v tx)))

;; recurse into a complex value (of concrete type `tc`): nested resource | backbone | datatype jump
(define (recurse-issues idx ce tc loc v tx)
  (cond
    [(list? v) (append-map (lambda (x) (recurse-issues idx ce tc loc x tx)) v)]
    [(not (hash? v)) '()]
    [(string? (hash-ref v 'resourceType #f))          ; an inlined independent resource
     (let ([ti (type-index (hash-ref v 'resourceType))])
       (if ti (walk ti (hash-ref v 'resourceType) v tx) '()))]
    [(pair? (child-elements idx (hash-ref ce 'path)))  ; a backbone element (inline children)
     (walk idx (hash-ref ce 'path) v tx)]
    [else                                               ; a complex datatype -> jump to its own SD
     (cond [(or (not tc) (opaque-type? tc)) '()]
           [(type-index tc) => (lambda (ti) (walk ti tc v tx))]
           [else '()])]))

;; ---- rule functions --------------------------------------------------------------------------
(define (cardinality-issues ce path leaf count)
  (define minv (hash-ref ce 'min 0))
  (define maxv (hash-ref ce 'max "*"))
  (append
   (if (and (integer? minv) (> minv 0) (< count minv))
       (list (issue "error" "required" (child-loc path leaf)
                    (format "minimum required = ~a, but found ~a" minv count))) '())
   (if (and (not (equal? maxv "*")) (string->number maxv) (> count (string->number maxv)))
       (list (issue "error" "structure" (child-loc path leaf)
                    (format "maximum allowed = ~a, but found ~a" maxv count))) '())))

(define (unknown-element-issues path obj children)
  (for/list ([k (in-list (hash-keys obj))]
             #:unless (or (eq? k 'resourceType)
                          (char=? (string-ref (symbol->string k) 0) #\_)   ; primitive _field sibling
                          ;; a disallowed choice variant (allowed-key? #f) is NOT known -> flagged here
                          (for/or ([ce (in-list children)]) (allowed-key? (elem-leaf ce path) ce k))))
    (issue "error" "structure" (string-append path "." (symbol->string k))
           (format "element '~a' is not defined at ~a" k path))))

;; fixed[x] must equal; pattern[x] must be contained (recursive subset)
(define (fixed-pattern-issues ce loc v)
  (append
   (cond [(choice-value ce "fixed") => (lambda (fx) (if (equal? (prune fx) (prune v)) '()
                                                        (list (issue "error" "value" loc "value does not match fixed value"))))]
         [else '()])
   (cond [(choice-value ce "pattern") => (lambda (pt) (if (json-contains? (prune pt) (prune v)) '()
                                                         (list (issue "error" "value" loc "value does not match required pattern"))))]
         [else '()])))

;; the JSON representation a FHIR primitive must use (https://build.fhir.org/json.html#primitive):
;; numbers for the numeric types, a JSON boolean for boolean, a JSON string for everything else.
;; A decimal written as "1" (a string) is invalid JSON FHIR however well the lexeme parses — a
;; fact about the DOCUMENT, so reporting it can never be a false positive.
(define (json-shape-issue tc loc v)
  (define expected
    (cond [(member tc '("decimal" "integer" "integer64" "positiveInt" "unsignedInt")) 'number]
          [(equal? tc "boolean") 'boolean]
          [else 'string]))
  (define actual
    (cond [(jnum? v) 'number] [(number? v) 'number] [(boolean? v) 'boolean]
          [(string? v) 'string] [else 'other]))
  (if (or (eq? actual 'other) (eq? actual expected))
      '()
      (list (issue "error" "invalid" loc
                   (format "~a must be a JSON ~a, not a ~a" tc expected actual)))))

(define (primitive-issues tc loc v)
  (cond
    [(or (not tc) (not (primitive-code? tc)) (hash? v) (list? v)) '()]   ; only scalar primitives
    [(pair? (json-shape-issue tc loc v)) (json-shape-issue tc loc v)]
    [else
     ;; decimals validate on a string LEXEME (make-decimal rejects Racket numbers): the exact jnum
     ;; lexeme when available (read-fhir-json), else the plain number's printed form; others on the value
     (define input (cond [(and (equal? tc "decimal") (jnum? v)) (jnum-lexeme v)]
                         [(and (equal? tc "decimal") (number? v)) (number->string v)]
                         [(jnum? v) (jnum-value v)]
                         [else v]))
     (define ctor (constructor-of (string->symbol tc)))
     (cond [(not ctor) '()]
           [(let ([r (with-handlers ([exn:fail? (lambda (_) (err #f))]) (ctor input))]) (and (not (ok? r))))
            (list (issue "error" "invalid" loc (format "'~a' is not a valid ~a" input tc)))]
           ;; a canonical reference must not end in '|' (a version separator with no version)
           [(and (equal? tc "canonical") (string? input) (regexp-match? #rx"[|]$" input))
            (list (issue "error" "invalid" loc "canonical URL cannot end in '|'"))]
           [else '()])]))

;; required binding: a bound `code`/coded value must be a member of the ValueSet. Membership comes
;; from the tx-service when one is supplied, else from the GENERATED offline expansions
;; (model/binding.rkt — populated by the loaded tower's terminology.rkt); both are exact, so a
;; 'no is never a false positive, and everything else stays fail-open.
(define (binding-issues ce loc v tx)
  (define b (hash-ref ce 'binding #f))
  (cond
    [(or (not (hash? b)) (not (equal? (hash-ref b 'strength #f) "required"))) '()]
    [else
     ;; the binding valueSet often carries a |version suffix; resolve against the canonical
     (define vs (let ([u (hash-ref b 'valueSet #f)]) (and (string? u) (car (string-split u "|")))))
     (define codes (coded-values ce v))               ; (listof (cons system code))
     (cond
       [(or (not vs) (null? codes)) '()]
       [(for/and ([c (in-list codes)]) (eq? (member? tx vs (cdr c) (car c)) 'no))
        (list (issue "error" "code-invalid" loc (format "code not in required value set ~a" vs)))]
       [else '()])]))                                  ; any yes/unknown -> fail-open

;; -> 'yes | 'no | 'unknown. tx first when present; the offline expansion decides otherwise.
(define (member? tx vs code system)
  (define via-tx (if tx (tx-member? tx vs code system) 'unknown))
  (cond
    [(not (eq? via-tx 'unknown)) via-tx]
    [else
     (define exp (binding-expansion vs))
     (cond [(not exp) 'unknown]                        ; not offline-expandable -> undecidable
           [(hash-ref exp code #f) 'yes]
           [else 'no])]))

;; value/pattern discriminator slicing: each declared slice with min>=1 must have >=min matching
;; instances. Fail-open at every step: a slicing whose discriminators aren't all value/pattern, a
;; slice whose pinned value can't be resolved, or an undecidable per-instance match -> skip.
(define (slice-issues idx path ce obj)
  (define slices (slices-of idx (hash-ref ce 'path)))
  (define discs (discriminator-paths ce))
  (cond
    [(or (null? slices) (not discs)) '()]
    [else
     (define leaf (elem-leaf ce path))
     (define instances (append-map (lambda (k) (instances-of (hash-ref obj k)))
                                   (for/list ([k (in-list (hash-keys obj))] #:when (key-targets-leaf? leaf k)) k)))
     (append-map
      (lambda (sl)
        (define minv (hash-ref sl 'min 0))
        (define pins (slice-pins idx sl discs))          ; (listof (list disc-path kind value)) | #f
        (cond
          [(or (not pins) (not (integer? minv)) (= minv 0)) '()]   ; undecidable / optional -> skip
          [else
           (define n (for/sum ([inst (in-list instances)] #:when (slice-match? pins inst)) 1))
           (if (< n minv)
               (list (issue "error" "required" (child-loc path leaf)
                            (format "slice '~a' requires ~a, found ~a" (hash-ref sl 'sliceName) minv n))) '())]))
      slices)]))

;; the base element's discriminator paths — (listof path-string), but ONLY when every declared
;; discriminator is value/pattern (any other kind makes the whole slicing undecidable for us)
(define (discriminator-paths ce)
  (define slicing (hash-ref ce 'slicing #f))
  (define ds (and (hash? slicing) (hash-ref slicing 'discriminator #f)))
  (and (list? ds) (pair? ds)
       (let ([paths (for/list ([d (in-list ds)])
                      (and (hash? d) (member (hash-ref d 'type #f) '("value" "pattern"))
                           (let ([p (hash-ref d 'path #f)]) (and (string? p) p))))])
         (and (andmap values paths) paths))))

;; a slice's pinned value per discriminator: fixed[x]/pattern[x] on the slice element itself
;; ("$this") or on its child element at <slice-id>.<disc-path>. #f when any pin is unresolvable.
(define (slice-pins idx sl discs)
  (define pins
    (for/list ([dp (in-list discs)])
      (define elem (if (equal? dp "$this")
                       sl
                       (let ([id (hash-ref sl 'id #f)])
                         (and (string? id) (index-by-id idx (string-append id "." dp))))))
      (define pin (and (hash? elem)
                       (cond [(choice-value elem "fixed") => (lambda (v) (list 'fixed v))]
                             [(choice-value elem "pattern") => (lambda (v) (list 'pattern v))]
                             [else #f])))
      (and pin (cons dp pin))))
  (and (andmap values pins) pins))

;; does the instance match EVERY pinned discriminator? fixed -> equality, pattern -> subset,
;; both on pruned values; a dotted path navigates the raw jsexpr (a list step matches any element)
(define (slice-match? pins inst)
  (for/and ([pin (in-list pins)])
    (define dp (car pin))
    (define kind (cadr pin))
    (define pinned (prune (caddr pin)))
    (define targets (if (equal? dp "$this") (list inst) (json-at inst (string-split dp "."))))
    (for/or ([t (in-list targets)])
      (case kind
        [(fixed) (equal? pinned (prune t))]
        [else (json-contains? pinned (prune t))]))))

;; all values at a dotted path within a raw jsexpr (lists fan out)
(define (json-at v segs)
  (cond [(null? segs) (list v)]
        [(list? v) (append-map (lambda (x) (json-at x segs)) v)]
        [(hash? v) (let ([nxt (hash-ref v (string->symbol (car segs)) #f)])
                     (if nxt (json-at nxt (cdr segs)) '()))]
        [else '()]))

;; ---- invariants (FHIRPath) -------------------------------------------------------------------
(define (invariant-issues idx type node)
  (cond
    [(not node) '()]
    [else
     (append-map
      (lambda (e)
        (define cs (hash-ref e 'constraint '()))
        (cond
          [(null? cs) '()]
          [else
           (define rel (rel-path (hash-ref e 'path)))
           (define foci (focus-items rel node))
           (append-map (lambda (c) (append-map (lambda (f) (check-constraint c f (hash-ref e 'path))) foci)) cs)]))
      (index-elements idx))]))

;; the universal base invariants (Element/DomainResource/Extension) — structural, ubiquitous, and
;; sensitive to exact children()/hasValue() semantics. Our structural checks approximate them; skip
;; them here to stay strictly fail-open (only profile/datatype-specific invariants run).
(define universal-invariants '("ele-1" "ext-1" "dom-1" "dom-2" "dom-3" "dom-4" "dom-5" "dom-6"))

(define (check-constraint c focus path)
  (define expr (hash-ref c 'expression #f))
  (cond
    [(not expr) '()]
    [(member (hash-ref c 'key #f) universal-invariants) '()]
    [else
     (define result (with-handlers ([exn:fail? (lambda (_) 'skip)])
                      (map item->system (eval-fhirpath (parse-fhirpath expr) (list focus)))))
     ;; violated ONLY on a singleton #f; empty/true/unevaluable -> holds (fail-open)
     (if (equal? result (list #f))
         (list (issue (if (equal? (hash-ref c 'severity #f) "warning") "warning" "error")
                      "invariant" path
                      (format "~a: ~a" (hash-ref c 'key "?") (hash-ref c 'human ""))))
         '())]))

;; the focus node(s) for an element's relative path (""=root)
(define (focus-items rel node)
  (cond [(equal? rel "") (list node)]
        [else (with-handlers ([exn:fail? (lambda (_) '())]) (eval-fhirpath (parse-fhirpath rel) (list node)))]))

;; ---- terminology helper ----------------------------------------------------------------------
;; -> 'yes | 'no | 'unknown. Fail-open: return 'no ONLY when the ValueSet demonstrably expands to a
;; non-empty set offline (so we truly know its members) and the code is absent; otherwise 'unknown.
(define (tx-member? tx vs code system)
  (with-handlers ([exn:fail? (lambda (_) 'unknown)])
    (define exp ((tx-service-expand tx) vs))
    (define members (and (pair? exp)
                         (let ([e (hash-ref (node->jsexpr (car exp)) 'expansion #f)])
                           (and (hash? e) (let ([c (hash-ref e 'contains #f)]) (and (list? c) (length c)))))))
    (cond
      [(or (not members) (= members 0)) 'unknown]     ; VS unresolvable/empty -> undecidable
      [else
       (define out ((tx-service-validate tx) vs code system))
       (define params (if (pair? out) (let ([p (hash-ref (node->jsexpr (car out)) 'parameter '())])
                                        (if (list? p) p '())) '()))
       (define result (for/or ([p (in-list params)]) (and (equal? (hash-ref p 'name #f) "result")
                                                          (hash-ref p 'valueBoolean 'none))))
       (cond [(eq? result #t) 'yes] [(eq? result #f) 'no] [else 'unknown])])))

;; ---- small helpers ---------------------------------------------------------------------------
(define (elem-leaf ce parent)
  (define p (hash-ref ce 'path))
  (if (string-prefix? p (string-append parent ".")) (substring p (add1 (string-length parent))) p))
(define (child-loc path leaf) (string-append path "." leaf))
(define (choice-leaf? leaf) (string-suffix? leaf "[x]"))
;; does JSON key `key` aim at the element whose leaf is `leaf` (a plain name, or a `value[x]` base +
;; any Capitalized suffix)? This is only the NAME match — variant-type checks the suffix is allowed.
(define (key-targets-leaf? leaf key)
  (define k (symbol->string key))
  (cond [(choice-leaf? leaf)
         (define base (substring leaf 0 (- (string-length leaf) 3)))
         (and (string-prefix? k base) (> (string-length k) (string-length base))
              (char-upper-case? (string-ref k (string-length base))))]
        [else (string=? k leaf)]))

;; for a choice element, the concrete type behind a matched key -> a type-code string (allowed
;; variant), 'any (element declares no types -> accept, fail-open), or #f (suffix not a declared type)
(define (variant-type leaf ce key)
  (define base (substring leaf 0 (- (string-length leaf) 3)))
  (define suffix (substring (symbol->string key) (string-length base)))
  (define types (filter values (elem-type-codes ce)))
  (cond [(null? types) 'any]
        [else (for/or ([tc (in-list types)]) (and (string=? suffix (capitalize tc)) tc))]))

;; the concrete type for a matched key (choice -> its variant; non-choice -> the single type), or #f
(define (matched-type leaf ce key)
  (cond [(choice-leaf? leaf) (let ([vt (variant-type leaf ce key)]) (and (string? vt) vt))]
        [else (single-type-code ce)]))

;; a key that aims at a choice element but whose suffix is not a declared type is a disallowed variant
(define (allowed-key? leaf ce key)
  (and (key-targets-leaf? leaf key) (or (not (choice-leaf? leaf)) (and (variant-type leaf ce key) #t))))

(define (capitalize s)
  (if (= 0 (string-length s)) s (string-append (string-upcase (substring s 0 1)) (substring s 1))))
(define instances-of listify)   ; a repeating property read -> always a list (model/leaf)

;; element type codes (from raw SD element.type[].code)
(define (elem-type-codes ce) (for/list ([t (in-list (hash-ref ce 'type '()))]) (hash-ref t 'code #f)))
(define (single-type-code ce) (let ([ts (elem-type-codes ce)]) (and (pair? ts) (null? (cdr ts)) (car ts))))
(define (primitive-code? tc) (and (string? tc) (> (string-length tc) 0) (char-lower-case? (string-ref tc 0))))

;; a fixed[x]/pattern[x] value on an element: scan keys prefixed "fixed"/"pattern"
(define (choice-value ce prefix)
  (for/or ([(k v) (in-hash ce)])
    (define ks (symbol->string k))
    (and (string-prefix? ks prefix) (> (string-length ks) (string-length prefix))
         (char-upper-case? (string-ref ks (string-length prefix))) v)))

;; coded values for binding: 'code scalar -> (#f . code); Coding -> (system . code); CodeableConcept -> its codings
(define (coded-values ce v)
  (define tc (single-type-code ce))
  (cond
    [(and (equal? tc "code") (string? v)) (list (cons #f v))]
    [(and (hash? v) (list? (hash-ref v 'coding #f)))       ; CodeableConcept
     (for/list ([c (in-list (hash-ref v 'coding))] #:when (hash? c)) (cons (hash-ref c 'system #f) (hash-ref c 'code #f)))]
    [(and (hash? v) (hash-ref v 'code #f))                 ; Coding
     (list (cons (hash-ref v 'system #f) (hash-ref v 'code)))]
    [else '()]))

;; an element path relative to its resource root ("" = the root itself)
(define (rel-path p)
  (define segs (string-split p "."))
  (if (> (length segs) 1) (string-join (cdr segs) ".") ""))

;; strip JSON nulls and empty arrays (and unwrap jnum -> its number) for fixed/pattern comparison.
;; JSON `false` is a VALUE and must survive — dropping it would make a fixed/pattern boolean false
;; unverifiable.
(define (prune v)
  (cond [(jnum? v) (jnum-value v)]
        [(hash? v) (for/hash ([(k x) (in-hash v)]
                              #:unless (or (eq? x 'null) (null? x)))
                     (values k (prune x)))]
        [(list? v) (map prune v)]
        [else v]))
;; every key/elt of `pat` present+matching in `v` (recursive subset)
(define (json-contains? pat v)
  (cond [(and (hash? pat) (hash? v)) (for/and ([(k pv) (in-hash pat)]) (and (hash-has-key? v k) (json-contains? pv (hash-ref v k))))]
        [(and (list? pat) (list? v)) (for/and ([p (in-list pat)]) (for/or ([x (in-list v)]) (json-contains? p x)))]
        [else (equal? pat v)]))

(define (issues->outcome issues)
  (ok-or-raise
   (from-json
    (hasheq 'resourceType "OperationOutcome"
            'issue (if (null? issues)
                       (list (hasheq 'severity "information" 'code "informational"
                                     'details (hasheq 'text "All OK")))
                       (for/list ([i (in-list issues)])
                         (drop-false (hasheq 'severity (issue-severity i) 'code (issue-code i)
                                             'diagnostics (issue-msg i)
                                             'expression (and (issue-path i) (list (issue-path i)))))))))))

;; ── living examples: the pure rule helpers + slicing on a synthetic snapshot ─────────────────
(module+ test
  (require rackunit)
  ;; prune: nulls and empty arrays vanish; false SURVIVES (it is a value)
  (check-equal? (prune (hasheq 'a 'null 'b '() 'c #f 'd 1)) (hash 'c #f 'd 1))
  ;; json-contains?: recursive subset — pattern keys must all be present and match
  (check-true  (json-contains? (hash 'code "x") (hash 'code "x" 'display "X")))
  (check-false (json-contains? (hash 'code "x") (hash 'display "X")))
  (check-true  (json-contains? (list (hash 'a 1)) (list (hash 'b 2) (hash 'a 1))))
  ;; choice keys: valueQuantity targets value[x]; valueBad is a disallowed variant
  (check-true  (key-targets-leaf? "value[x]" 'valueQuantity))
  (check-false (key-targets-leaf? "value[x]" 'value))
  (define choice-ce (hasheq 'path "Observation.value[x]"
                            'type (list (hasheq 'code "Quantity") (hasheq 'code "boolean"))))
  (check-equal? (variant-type "value[x]" choice-ce 'valueQuantity) "Quantity")
  (check-false  (variant-type "value[x]" choice-ce 'valueRange))
  (check-true   (allowed-key? "value[x]" choice-ce 'valueBoolean))
  (check-false  (allowed-key? "value[x]" choice-ce 'valueRange))
  ;; coded-values: code scalar / Coding / CodeableConcept all decompose
  (check-equal? (coded-values (hasheq 'type (list (hasheq 'code "code"))) "male") '((#f . "male")))
  (check-equal? (coded-values (hasheq) (hasheq 'system "s" 'code "c")) '(("s" . "c")))
  ;; json-at: dotted navigation over raw jsexpr, lists fan out
  (check-equal? (json-at (hasheq 'coding (list (hasheq 'code "a") (hasheq 'code "b"))) '("coding" "code"))
                '("a" "b"))
  ;; ---- slicing end-to-end on a synthetic snapshot -------------------------------------------
  ;; DemoR.item is sliced by value discriminator on `kind`; slice "alpha" pins kind="A", min 1
  (define snap
    (list (hasheq 'id "DemoR" 'path "DemoR" 'min 0 'max "*")
          (hasheq 'id "DemoR.item" 'path "DemoR.item" 'min 0 'max "*"
                  'slicing (hasheq 'discriminator (list (hasheq 'type "value" 'path "kind"))))
          (hasheq 'id "DemoR.item:alpha" 'path "DemoR.item" 'sliceName "alpha" 'min 1 'max "*")
          (hasheq 'id "DemoR.item:alpha.kind" 'path "DemoR.item.kind" 'fixedString "A")))
  (define idx (make-element-index snap))
  (define base-ce (car (child-elements idx "DemoR")))
  ;; an instance carrying a kind="A" item satisfies the slice -> no issues
  (check-equal? (slice-issues idx "DemoR" base-ce
                              (hasheq 'item (list (hasheq 'kind "A") (hasheq 'kind "B"))))
                '())
  ;; no kind="A" item -> the slice minimum is violated
  (check-equal? (length (slice-issues idx "DemoR" base-ce (hasheq 'item (list (hasheq 'kind "B"))))) 1)
  ;; FAIL-OPEN: an unresolvable discriminator kind (profile) reports nothing
  (define snap2 (list (car snap)
                      (hash-set (cadr snap) 'slicing
                                (hasheq 'discriminator (list (hasheq 'type "profile" 'path "kind"))))
                      (caddr snap) (cadddr snap)))
  (define idx2 (make-element-index snap2))
  (check-equal? (slice-issues idx2 "DemoR" (car (child-elements idx2 "DemoR"))
                              (hasheq 'item (list (hasheq 'kind "B"))))
                '())
  ;; FAIL-OPEN: a slice with no pinned value at the discriminator path reports nothing
  (define snap3 (list (car snap) (cadr snap) (caddr snap)
                      (hasheq 'id "DemoR.item:alpha.kind" 'path "DemoR.item.kind")))
  (define idx3 (make-element-index snap3))
  (check-equal? (slice-issues idx3 "DemoR" (car (child-elements idx3 "DemoR"))
                              (hasheq 'item (list (hasheq 'kind "B"))))
                '()))
