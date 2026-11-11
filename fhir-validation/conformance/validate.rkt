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

(require (only-in fhir/canonical canonical-url)
         (only-in fhir/suggest did-you-mean)
         racket/contract (only-in json jsexpr->string string->jsexpr)
         racket/string
         racket/list
         (only-in fhir/sd/sd-index resolve-sd-raw current-sd-packages sd-context)
         (only-in fhir/sd/element-index
                  make-element-index index-elements index-root child-elements slices-of
                  index-by-id type-index opaque-type?)
         (only-in fhir/model/leaf listify)
         (only-in fhir/model/binding binding-expansion binding-expansion-codes)
         (only-in fhir/sd/snapshot generate-snapshot shipped-snapshot)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/serialize/read-json jnum? jnum-lexeme jnum-value)
         (only-in fhir/result/result ok? ok-value ok-or-raise err)
         (only-in fhir/model/registry constructor-of all-types type-registered?)
         (only-in fhirpath/eval eval-fhirpath)
         (only-in fhirpath/parser/parse parse-fhirpath)
         (only-in fhirpath/parser/ast fp-invoke fp-invoke? fp-invoke-target fp-invoke-name fp-call fp-call? fp-call-target fp-lit? fp-lit-value
                  fp-call-name fp-call-args fp-binop? fp-binop-op fp-binop-lhs fp-binop-rhs fp-unop? fp-unop-operand
                  fp-typeop? fp-typeop-operand fp-index? fp-index-target fp-var?)
         (only-in fhirpath/print fhirpath->string)
         (only-in fhir/model/node fhir?)
         (only-in fhirpath/value item->system)
         (only-in fhirpath/ucum ucum-valid? ucum-suggestion)
         (only-in fhir/serialize/jsexpr-util drop-false)
         (only-in fhir/primitives/temporal calendar-problem)
         (only-in fhirpath/terminology tx-service-validate tx-service-expand))

(provide
 (struct-out issue)
 (contract-out
  [validate-issues (->* (hash?) (#:profiles (listof hash?) #:terminology any/c #:invariants? boolean? #:duplicates (listof string?)) (listof issue?))]
  [validate-json   (->* (hash?) (#:profiles (listof hash?) #:terminology any/c #:invariants? boolean? #:duplicates (listof string?)) any/c)]
  ;; the error-severity issues of a resource given as JSON text, validated over the named
  ;; packages, as rows — what a worker process (fhir/parallel) can be handed and can answer
  [write-errors/rows (-> (list/c string? (listof string?)) (listof (list/c string? string? (or/c string? #f) string?)))]))

;; ---- data -----------------------------------------------------------------------------------
;; An Issue is (issue severity code path msg): severity "error" | "warning" | "fatal"; code an
;; OperationOutcome issue-type code ("structure", "required", "value", "invalid", "code-invalid",
;; "invariant"); path the dotted element path ("Observation.component.value[x]") or #f; msg a sentence.
;; An ElementDef is a snapshot ElementDefinition as raw jsexpr (path, id, min, max, type, fixed[x],
;; pattern[x], binding, slicing, constraint, …); an Index is fhir/sd/element-index's element-index
;; over a snapshot (children by path, slices, by id).
;; A Pin is (list disc-path kind value): a slice's pinned value for one discriminator, kind 'fixed
;; or 'pattern (see slice-pins). A Membership is 'yes | 'no | 'unknown (a code in a value set;
;; 'unknown is fail-open).
(struct issue (severity code path msg) #:transparent)

;; write-errors/rows : (list json-text (listof package-path)) -> (listof (list severity code path msg))
;; the issues a write must refuse on (error or fatal), each as a row; the packages are the
;; validation context (an IG, its dependencies, the core), as current-sd-packages takes them
(define (write-errors/rows item)
  (parameterize ([current-sd-packages (cadr item)])
    (for/list ([i (in-list (validate-issues (string->jsexpr (car item))))]
               #:when (member (issue-severity i) '("error" "fatal")))
      (list (issue-severity i) (issue-code i) (issue-path i) (issue-msg i)))))

;; ---- entry -----------------------------------------------------------------------------------
;; validate-json : jsexpr [#:profiles #:terminology #:invariants? #:duplicates] -> OperationOutcome
;; Invariants are ON by default (since 2026-11-05): each runs at its element with %resource,
;; %rootResource and %context bound; the universal base keys (ele-1, ext-1, dom-*) and constraints on
;; slices are left out, and anything that does not evaluate holds (fail-open).
(define (validate-json json #:profiles [profiles '()] #:terminology [tx #f] #:invariants? [inv? #t] #:duplicates [dups '()])
  (issues->outcome (validate-issues json #:profiles profiles #:terminology tx #:invariants? inv? #:duplicates dups)))

;; `duplicates` are dotted paths of collapsed duplicate JSON keys (from read-fhir-json/duplicates) —
;; a fact the reader observed, so reporting them is never a false positive. Each is one error issue.
;; validate-issues : jsexpr [#:profiles #:terminology #:invariants? #:duplicates] -> (listof Issue)
(define (validate-issues json #:profiles [profiles '()] #:terminology [tx #f] #:invariants? [inv? #t] #:duplicates [dups '()])
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
       ;; a resourceType the packages do not define, while they define the types (an index is
       ;; there): decided, not undecidable — `Observaton` would otherwise pass as clean
       [(and (null? indexes) (unknown-resource-type? rt))
        (append dup-issues (list (issue "error" "structure" rt
                                        (format "`~a` is not a resource type~a" rt
                                                (did-you-mean rt (map symbol->string (all-types)))))))]
       [(null? indexes) dup-issues]                   ; unresolvable -> fail-open (dups still real)
       [else
        (define node (let ([r (from-json json #:lenient? #t)]) (and (ok? r) (ok-value r))))
        (define seen (make-hash))
        (for/fold ([acc (reverse dup-issues)] #:result (reverse acc))
                  ([i (in-list indexes)] #:when i)
          (define issues (append (walk i rt json tx) (if inv? (invariant-issues i rt node) '())))
          (for/fold ([acc acc]) ([is (in-list issues)])
            (define k (list (issue-code is) (issue-path is) (issue-msg is)))
            (if (hash-ref seen k #f) acc (begin (hash-set! seen k #t) (cons is acc)))))])]))

;; unknown-resource-type? : string -> boolean   a plain name that neither the packages in context (which
;; do define the base types) nor the registered towers and logical models know
(define (unknown-resource-type? rt)
  (and (regexp-match? #px"^[A-Za-z][A-Za-z0-9_]*$" rt)
       (resolve-sd-raw "Resource")
       (not (resolve-sd-raw rt))
       (not (type-registered? (string->symbol rt)))))

;; element indexes to validate against: the base type via the cached `type-index`, plus meta.profile +
;; supplied profiles whose `type` matches (their snapshots generated on demand)
;; target-indexes : type-code jsexpr (listof SD) -> (listof Index)
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
;; idx-of : SD -> element-index | #f   memoised per SD (by identity) and package context: a profile
;; that many resources claim had its snapshot generated again for every one of them
(define profile-indexes (make-weak-hasheq))
(define (idx-of sd)
  (define by-context (hash-ref! profile-indexes sd make-hash))
  (hash-ref! by-context (sd-context) (lambda () (build-idx sd))))
;; build-idx : SD -> Index | #f
(define (build-idx sd)
  (define snap (or (shipped-snapshot sd) (and (hash-ref sd 'differential #f) (generate-snapshot sd))))
  (define idx (and (list? snap) (pair? snap) (make-element-index snap)))
  (and idx (usable-index? idx) idx))

;; usable when the root element actually has children to validate against
;; usable-index? : Index -> boolean
(define (usable-index? idx)
  (define root (index-root idx))
  (and root (pair? (child-elements idx (hash-ref root 'path "")))))

;; ---- structural walk -------------------------------------------------------------------------
;; walk the JSON object `obj` sitting at snapshot `path`, against element-index `idx`
;; walk : Index path jsexpr tx -> (listof Issue)
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
;; resource-id-issues : path jsexpr -> (listof Issue)   a resource id must match the FHIR id grammar
(define (resource-id-issues path obj)
  (define id (hash-ref obj 'id #f))
  (if (and (string? id) (not (regexp-match? id-rx id)))
      (list (issue "error" "invalid" (string-append path ".id") (format "invalid resource id '~a'" id)))
      '()))

;; every contained resource must have an id, and those ids must be UNIQUE within the container
;; (they are the targets of that resource's internal `#id` references). Purely structural — a
;; duplicate is unambiguously invalid, so this can never be a false positive.
;; contained-id-issues : path jsexpr -> (listof Issue)
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

;; child-issues : Index path ElementDef jsexpr tx -> (listof Issue)   one child element of `obj`: its
;; matched keys (choice variants narrowed), cardinality, empty arrays, values, and the slicing on it
(define (child-issues idx path ce obj tx)
  (define leaf (elem-leaf ce path))
  ;; keys aimed at this element with an ALLOWED variant (a disallowed choice variant is left for
  ;; unknown-element-issues and is not counted toward cardinality)
  (define matched (for/list ([k (in-list (hash-keys obj))] #:when (allowed-key? leaf ce k)) k))
  (define instances (append-map (lambda (k) (instances-of (hash-ref obj k))) matched))
  ;; a primitive carried ONLY by its `_name` sibling (extensions, no value — e.g. a data-absent-reason
  ;; on `_performedDateTime`) is PRESENT for cardinality (https://hl7.org/fhir/json.html#primitive)
  (define extension-only
    (for*/list ([k (in-list (hash-keys obj))]
                [n (in-value (symbol->string k))]
                #:when (and (> (string-length n) 1) (char=? (string-ref n 0) #\_))
                [base (in-value (string->symbol (substring n 1)))]
                #:when (and (not (hash-has-key? obj base)) (allowed-key? leaf ce base)))
      (hash-ref obj k)))
  (define present (+ (length instances) (for/sum ([v (in-list extension-only)]) (length (instances-of v)))))
  (append
   ;; an empty JSON array is never valid — the property should be absent if it has no values
   (for/list ([k (in-list matched)] #:when (null? (hash-ref obj k)))
     (issue "error" "structure" (child-loc path leaf) "array cannot be empty"))
   (cardinality-issues ce path leaf present)
   (append-map (lambda (k)
                 (define tc (matched-type leaf ce k))     ; the concrete (narrowed) type of this variant
                 (append-map (lambda (v) (value-issues idx ce tc (child-loc path leaf) v tx))
                             (instances-of (hash-ref obj k)))) matched)
   (slice-issues idx path ce obj tx)))

;; per-instance value checks, against the element's concrete (narrowed) type `tc`
;; value-issues : Index ElementDef type-code loc value tx -> (listof Issue)
(define (value-issues idx ce tc loc v tx)
  (append (fixed-pattern-issues ce loc v)
          (primitive-issues tc loc v)
          (ucum-issues tc loc v)
          (binding-issues ce loc v tx)
          (recurse-issues idx ce tc loc v tx)))

;; ucum-issues : type-code loc value -> (listof Issue)   a Quantity coded in UCUM must carry a UCUM
;; code: `mmHg` is not one (`mm[Hg]` is), and a unit nobody can convert breaks every comparison made
;; on it. A warning, not an error: HL7's own published examples write `m^2` (mCODE's body surface
;; area), and they must validate; the nearest common clinical unit is suggested.
(define quantity-types '("Quantity" "SimpleQuantity" "Age" "Duration" "Distance" "Count" "MoneyQuantity"))
(define (ucum-issues tc loc v)
  (cond
    [(and (member tc quantity-types) (hash? v)
          (equal? (hash-ref v 'system #f) "http://unitsofmeasure.org")
          (string? (hash-ref v 'code #f))
          (not (ucum-valid? (hash-ref v 'code))))
     (define code (hash-ref v 'code))
     ;; a warning: published examples write `m^2` (mCODE), and the never-over-report gate holds
     (list (issue "warning" "code-invalid" (string-append loc ".code")
                  (format "`~a` is not a UCUM unit~a" code (ucum-suggestion code))))]
    [else '()]))
;; recurse into a complex value (of concrete type `tc`): nested resource | backbone | datatype jump
;; recurse-issues : Index ElementDef type-code loc value tx -> (listof Issue)
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
;; cardinality-issues : ElementDef path leaf count -> (listof Issue)
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

;; unknown-element-issues : path jsexpr (listof ElementDef) -> (listof Issue)   keys no child
;; element (nor a `_` sibling of one) accounts for
(define (unknown-element-issues path obj children)
  (for/list ([k (in-list (hash-keys obj))]
             #:unless (or (eq? k 'resourceType)
                          (char=? (string-ref (symbol->string k) 0) #\_)   ; primitive _field sibling
                          ;; a disallowed choice variant (allowed-key? #f) is NOT known -> flagged here
                          (for/or ([ce (in-list children)]) (allowed-key? (elem-leaf ce path) ce k))))
    (issue "error" "structure" (string-append path "." (symbol->string k))
           (format "element '~a' is not defined at ~a~a" k path
                   (did-you-mean (symbol->string k)
                                 (for/list ([ce (in-list children)]) (regexp-replace #rx"\\[x\\]$" (elem-leaf ce path) "")))))))

;; fixed[x] must equal; pattern[x] must be contained (recursive subset)
;; fixed-pattern-issues : ElementDef loc value -> (listof Issue)
(define (fixed-pattern-issues ce loc v)
  (append
   (cond [(choice-value ce "fixed") => (lambda (fx) (if (equal? (prune fx) (prune v)) '()
                                                        (list (issue "error" "value" loc (format "value does not match fixed value ~a" (compact fx))))))]
         [else '()])
   (cond [(choice-value ce "pattern") => (lambda (pt) (if (json-contains? (prune pt) (prune v)) '()
                                                         (list (issue "error" "value" loc (format "value does not match required pattern ~a" (compact pt))))))]
         [else '()])))

;; compact : jsexpr -> string   the expected value, as JSON, in the message (what a reader — or a
;; model fixing its output — needs to see); long values are cut
(define (compact v)
  (define s (with-handlers ([exn:fail? (lambda (_) (format "~a" v))]) (jsexpr->string (prune v))))
  (if (> (string-length s) 300) (string-append (substring s 0 300) "…") s))

;; the JSON representation a FHIR primitive must use (https://build.fhir.org/json.html#primitive):
;; numbers for the numeric types, a JSON boolean for boolean, a JSON string for everything else.
;; A decimal written as "1" (a string) is invalid JSON FHIR however well the lexeme parses — a
;; fact about the DOCUMENT, so reporting it can never be a false positive.
;; json-shape-issue : type-code loc value -> (listof Issue)
(define (json-shape-issue tc loc v)
  (define expected
    (case tc
      [("decimal" "integer" "integer64" "positiveInt" "unsignedInt") 'number]
      [("boolean") 'boolean]
      [else 'string]))
  (define actual
    (cond [(jnum? v) 'number] [(number? v) 'number] [(boolean? v) 'boolean]
          [(string? v) 'string] [else 'other]))
  (if (or (eq? actual 'other) (eq? actual expected))
      '()
      (list (issue "error" "invalid" loc
                   (format "~a must be a JSON ~a, not a ~a" tc expected actual)))))

;; primitive-issues : type-code|#f loc value -> (listof Issue)   a scalar primitive value: its JSON
;; shape, then its lexical form
(define (primitive-issues tc loc v)
  (cond
    [(or (not tc) (not (primitive-code? tc)) (hash? v) (list? v)) '()]   ; only scalar primitives
    [else
     (define shape (json-shape-issue tc loc v))
     (if (pair? shape) shape (lexical-issues tc loc v))]))

;; lexical-issues : type-code loc value -> (listof issue)   the value against its primitive's
;; validating constructor (the JSON shape already right)
(define (lexical-issues tc loc v)
  (cond
    [else
     ;; decimals validate on a string LEXEME (make-decimal rejects Racket numbers): the exact jnum
     ;; lexeme when available (read-fhir-json), else the plain number's printed form; others on the value
     (define input (cond [(and (equal? tc "decimal") (jnum? v)) (jnum-lexeme v)]
                         [(and (equal? tc "decimal") (number? v)) (number->string v)]
                         [(jnum? v) (jnum-value v)]
                         [else v]))
     (define ctor (primitive-constructor tc))
     (cond [(not ctor) '()]
           [(let ([r (with-handlers ([exn:fail? (lambda (_) (err #f))]) (ctor input))]) (and (not (ok? r))))
            (define why (and (member tc '("date" "dateTime" "instant")) (string? input)
                             (calendar-problem input)))
            (list (issue "error" "invalid" loc
                         (if why
                             (format "'~a' is not a valid ~a (~a)" input tc why)
                             (format "'~a' is not a valid ~a" input tc))))]
           ;; a canonical reference must not end in '|' (a version separator with no version)
           [(and (equal? tc "canonical") (string? input) (regexp-match? #rx"[|]$" input))
            (list (issue "error" "invalid" loc "canonical URL cannot end in '|'"))]
           [else '()])]))

;; primitive-constructor : type-code -> constructor|#f   by code string (interned once per code;
;; only a found constructor is kept, so a lookup made before a tower registers stays open)
(define primitive-ctors (make-hash))
(define (primitive-constructor tc)
  (or (hash-ref primitive-ctors tc #f)
      (let ([c (constructor-of (string->symbol tc))])
        (when c (hash-set! primitive-ctors tc c))
        c)))

;; required binding: a bound `code`/coded value must be a member of the ValueSet. Membership comes
;; from the tx-service when one is supplied, else from the GENERATED offline expansions
;; (model/binding.rkt — populated by the loaded tower's terminology.rkt); both are exact, so a
;; 'no is never a false positive, and everything else stays fail-open.
;; binding-issues : ElementDef loc value tx -> (listof Issue)
(define (binding-issues ce loc v tx)
  (define b (hash-ref ce 'binding #f))
  (cond
    [(or (not (hash? b)) (not (equal? (hash-ref b 'strength #f) "required"))) '()]
    [else
     ;; the binding valueSet often carries a |version suffix; resolve against the canonical
     (define vs (let ([u (hash-ref b 'valueSet #f)]) (and (string? u) (canonical-url u))))
     (define codes (coded-values ce v))               ; (listof (cons system code))
     (cond
       [(or (not vs) (null? codes)) '()]
       [(for/and ([c (in-list codes)]) (eq? (member? tx vs (cdr c) (car c)) 'no))
        ;; the code found, quoted (`femme`): the message named the value set, never the value
        (list (issue "error" "code-invalid" loc (format "code ~a not in required value set ~a~a"
                                                        (string-join (map (lambda (c) (format "`~a`" (cdr c))) codes) ", ")
                                                        vs (code-hint vs codes))))]
       [else '()])]))                                  ; any yes/unknown -> fail-open

;; code-hint : value-set-url (listof (cons system code)) -> string   what the value set does hold, from
;; its offline expansion: the closest codes, and every code when there are at most 20 ("" otherwise)
(define (code-hint vs codes)
  (define members (binding-expansion-codes vs))
  (cond
    [(not (and members (pair? codes) (string? (cdr (car codes))))) ""]
    [else
     (define near (did-you-mean (cdr (car codes)) members))
     (if (<= (length members) 20)
         (format "~a; it holds ~a" near (string-join members ", "))
         near)]))

;; -> 'yes | 'no | 'unknown. tx first when present; the offline expansion decides otherwise.
;; member? : tx|#f value-set-url code system|#f -> Membership
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
;; slice-issues : Index path ElementDef jsexpr [tx] -> (listof Issue)
(define (slice-issues idx path ce obj [tx #f])
  (define slices (slices-of idx (hash-ref ce 'path)))
  (define discs (discriminator-paths ce))
  (cond
    [(or (null? slices) (not discs)) '()]
    [else
     (define leaf (elem-leaf ce path))
     (define instances (append-map (lambda (k) (instances-of (hash-ref obj k)))
                                   (for/list ([k (in-list (hash-keys obj))] #:when (key-targets-leaf? leaf k)) k)))
     (define pinned (for/list ([sl (in-list slices)]) (cons sl (slice-pins idx sl discs))))
     (append
      (append-map
       (lambda (sp)
         (define sl (car sp))
         (define minv (hash-ref sl 'min 0))
         (define pins (cdr sp))                          ; (listof (list disc-path kind value)) | #f
         (cond
           [(or (not pins) (not (integer? minv)) (= minv 0)) '()]   ; undecidable / optional -> skip
           [else
            (define n (for/sum ([inst (in-list instances)] #:when (slice-match? pins inst)) 1))
            (if (< n minv)
                (list (issue "error" "required" (child-loc path leaf)
                             (format "slice '~a' requires ~a, found ~a" (hash-ref sl 'sliceName) minv n))) '())]))
       pinned)
      ;; an entry that matches exactly ONE slice is held to that slice's own children too. Every
      ;; slice must be decidable, except one that constrains nothing at its discriminator paths (no
      ;; value, required binding or profile there), which claims no entry; an ambiguous match, or a
      ;; slice whose constraint we cannot read, -> skip (fail-open)
      (if (for/and ([sp (in-list pinned)]) (or (cdr sp) (slice-unconstrained? idx (car sp) discs)))
          (append-map
           (lambda (inst)
             (define hits (for/list ([sp (in-list pinned)] #:when (cdr sp) #:when (and (hash? inst) (slice-match? (cdr sp) inst))) (car sp)))
             (if (= (length hits) 1) (slice-member-issues idx (car hits) (child-loc path leaf) inst tx) '()))
           instances)
          '()))]))

;; slice-unconstrained? : idx slice (listof disc-path) -> boolean
;; does the slice leave every discriminator path open — no fixed/pattern value, no required or
;; extensible binding and no type profile on the slice ($this) or on any element at or below
;; <slice-id>.<disc-path>? Such a slice cannot be told by its discriminator, so it claims no entry.
(define (slice-unconstrained? idx sl discs)
  (define id (hash-ref sl 'id #f))
  (define (constrains? ce)
    (or (choice-value ce "fixed") (choice-value ce "pattern")
        (let ([b (hash-ref ce 'binding #f)])
          (and (hash? b) (member (hash-ref b 'strength #f) '("required" "extensible")) #t))
        (for/or ([t (in-list (hash-ref ce 'type '()))])
          (and (hash? t) (pair? (hash-ref t 'profile '()))))))
  (and (string? id)
       (for/and ([dp (in-list discs)])
         (if (equal? dp "$this")
             (not (constrains? sl))
             (let ([at (string-append id "." dp)])
               (for/and ([ce (in-list (index-elements idx))])
                 (define cid (hash-ref ce 'id #f))
                 (not (and (string? cid)
                           (or (equal? cid at) (string-prefix? cid (string-append at ".")) (string-prefix? cid (string-append at ":")))
                           (constrains? ce)))))))))

;; slice-member-issues : idx slice loc entry tx -> issues
;; the slice's direct children (ids `<slice-id>.<leaf>`) against the entry: cardinality, fixed /
;; pattern values and required bindings on what is present, and choice variants the slice does not
;; allow. Recursion into the entry's values is the unsliced walk's (no issue twice).
(define (slice-member-issues idx sl loc inst tx)
  (define prefix (string-append (hash-ref sl 'id "") "."))
  (define name (hash-ref sl 'sliceName ""))
  (append*
   (for/list ([ce (in-list (index-elements idx))]
              #:when (let ([id (hash-ref ce 'id #f)])
                       (and (string? id) (string-prefix? id prefix)
                            (not (regexp-match? #rx"[.:]" (substring id (string-length prefix)))))))
     (define leaf (substring (hash-ref ce 'id) (string-length prefix)))
     (define matched (for/list ([k (in-list (hash-keys inst))] #:when (allowed-key? leaf ce k)) k))
     (define stray (for/list ([k (in-list (hash-keys inst))]
                              #:when (and (choice-leaf? leaf) (key-targets-leaf? leaf k) (not (allowed-key? leaf ce k))
                                          (pair? (elem-type-codes ce))))
                     k))
     (define here (string-append loc "." leaf))
     (append
      (for/list ([i (in-list (cardinality-issues ce loc leaf (for/sum ([k (in-list matched)]) (length (instances-of (hash-ref inst k))))))])
        (issue (issue-severity i) (issue-code i) (issue-path i) (format "~a (slice '~a')" (issue-msg i) name)))
      (for/list ([k (in-list stray)])
        (issue "error" "structure" here
               (format "~a is not allowed in slice '~a' (~a: ~a)" k name leaf (string-join (elem-type-codes ce) " | "))))
      (append-map (lambda (k)
                    (append-map (lambda (v) (append (fixed-pattern-issues ce here v) (binding-issues ce here v tx)))
                                (instances-of (hash-ref inst k))))
                  matched)))))

;; the base element's discriminator paths — (listof path-string), but ONLY when every declared
;; discriminator is value/pattern (any other kind makes the whole slicing undecidable for us)
;; discriminator-paths : ElementDef -> (listof path-string) | #f
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
;; slice-pins : Index ElementDef (listof path-string) -> (listof Pin) | #f
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
;; slice-match? : (listof Pin) jsexpr -> boolean
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

;; all values at a dotted path within a raw jsexpr (lists fan out — also at the END of the path: a
;; discriminator on a repeating element, `category.coding`, matches when ANY coding does; returning the
;; list itself compared the pattern against the list and rejected every valid instance)
;; json-at : jsexpr (listof string) -> (listof jsexpr)
(define (json-at v segs)
  (cond [(null? segs) (if (list? v) v (list v))]
        [(list? v) (append-map (lambda (x) (json-at x segs)) v)]
        [(hash? v) (let ([nxt (hash-ref v (string->symbol (car segs)) #f)])
                     (if nxt (json-at nxt (cdr segs)) '()))]
        [else '()]))

;; ---- invariants (FHIRPath) -------------------------------------------------------------------
;; An InvariantSite is (site path rel constraints): an element of an index that carries constraints
;; worth evaluating — its path, the path relative to the resource ("" = the root) and its
;; constraints with an expression and not universal. Which elements those are depends only on the
;; index, so the list is built once per index; a resource then evaluates just those sites (it used
;; to re-split and re-filter every element of the index for every resource).
(struct site (path rel constraints))
(define index-sites (make-weak-hasheq))
;; invariant-sites : Index -> (listof InvariantSite)
(define (invariant-sites idx)
  (hash-ref! index-sites idx
             (lambda ()
               (for*/list ([e (in-list (index-elements idx))]
                           ;; a constraint on a SLICE (id `Organization.identifier:NPI`) binds that
                           ;; slice's members only; evaluated at the element's path it would hold every
                           ;; repetition to it (US Core's us-core-16 "NPI must be 10 digits" on every
                           ;; Organization identifier). Slice membership is not decided here, so slice
                           ;; constraints are left unchecked — fail-open.
                           #:unless (regexp-match? #rx":" (hash-ref e 'id ""))
                           [cs (in-value (filter checked-constraint? (hash-ref e 'constraint '())))]
                           #:when (pair? cs))
                 (site (hash-ref e 'path) (rel-path (hash-ref e 'path)) cs)))))

;; checked-constraint? : constraint -> boolean   has an expression and is not a universal invariant
(define (checked-constraint? c)
  (and (hash-ref c 'expression #f) (not (member (hash-ref c 'key #f) universal-invariants)) #t))

;; invariant-issues : index type node|#f -> (listof issue)
(define (invariant-issues idx type node)
  (cond
    [(not node) '()]
    [else
     (append-map
      (lambda (st)
        (define foci (focus-items (site-rel st) node))
        (append-map (lambda (c) (append-map (lambda (f) (check-constraint c f (site-path st) node)) foci))
                    (site-constraints st)))
      (invariant-sites idx))]))

;; the universal base invariants (Element/DomainResource/Extension) — structural, ubiquitous, and
;; sensitive to exact children()/hasValue() semantics. Our structural checks approximate them; skip
;; them here to stay strictly fail-open (only profile/datatype-specific invariants run).
(define universal-invariants '("ele-1" "ext-1" "dom-1" "dom-2" "dom-3" "dom-4" "dom-5" "dom-6"))

;; the constraint's FHIRPath runs on the focus with %resource/%rootResource = the resource and
;; %context = the focus (sdf-8 compares an element path with %resource.type; without the binding the
;; variable fell to the focus and 593 of the core package's own StructureDefinitions "failed")
;; check-constraint : constraint focus path root -> (listof Issue)
(define (check-constraint c focus path root)
  (define expr (hash-ref c 'expression #f))
  (cond
    [(not expr) '()]
    [else
     (define result (with-handlers ([exn:fail? (lambda (_) 'skip)])
                      (map item->system (eval-fhirpath (parse-fhirpath expr) (list focus)
                                                       #:externals (hash "resource" (list root) "rootResource" (list root)
                                                                         "context" (list focus))))))
     ;; violated ONLY on a singleton #f; empty/true/unevaluable -> holds (fail-open)
     (if (equal? result (list #f))
         (list (issue (if (equal? (hash-ref c 'severity #f) "warning") "warning" "error")
                      "invariant" path
                      (format "~a: ~a~a" (hash-ref c 'key "?") (hash-ref c 'human "")
                              (found-text expr focus root))))
         '())]))

;; ---- what a broken invariant found ---------------------------------------------------------
;; A refusal that quotes only the rule ("A heart rate is between 20 and 250 /min") leaves the reader
;; to find the value. `found-text` says what the rule found, following the rule's own structure
;; (structural recursion over the FHIRPath AST, `evidence`), on the parts that are FALSE:
;;   A implies B           -> B's evidence (A held, or the rule would hold)
;;   A and B               -> the evidence of each part that is false
;;   A or B                -> both
;;   X.where(c).exists()   -> X's values when they are values (`valueQuantity = 300 '/min'`), else
;;   X.exists(c)              "no component matching '8462-4'" (the condition's literals)
;;   X.exists()            -> "no subject"
;;   X[.where(c)].all(p)   -> p's evidence on each item it fails, named by its index when X is an
;;                            element (`component[0].valueQuantity = 20 'kPa'`)
;;   anything else         -> the focus-rooted selections it compares, with their values
;; A selection is named as the JSON names it (`value.ofType(Quantity)` is `valueQuantity`), so the
;; reader — and the stage, tracing the line — finds the rule that wrote it. Nothing is said when
;; nothing is found or the expression does not parse: the rule's own words stand alone.

;; Evidence is a string: "valueQuantity = 300 '/min'" | "no component matching '8462-4'"

;; tests : the calls that test a collection rather than select from it
(define tests '(exists empty all allTrue anyTrue allFalse anyFalse count not hasValue))

;; rooted? : AST -> boolean   a selection from the focus (a chain of steps, calls and indexes)
(define (rooted? a)
  (cond [(fp-invoke? a) (or (not (fp-invoke-target a)) (rooted? (fp-invoke-target a)))]
        [(fp-call? a) (and (fp-call-target a) (rooted? (fp-call-target a)))]
        [(fp-index? a) (rooted? (fp-index-target a))]
        [else #f]))

;; selection : AST -> AST   a rooted chain without its trailing tests (and the where they test)
(define (selection a)
  (cond [(and (fp-call? a) (memq (fp-call-name a) tests) (fp-call-target a))
         (define t (fp-call-target a))
         (if (and (memq (fp-call-name a) '(exists empty)) (null? (fp-call-args a))
                  (fp-call? t) (eq? (fp-call-name t) 'where) (fp-call-target t))
             (selection (fp-call-target t))
             (selection t))]
        [else a]))

;; label : AST -> string   a selection as JSON names it: `value.ofType(Quantity)` -> valueQuantity,
;; `name.family` -> name.family; anything else as FHIRPath prints it
(define (label a)
  (define (step-name a)
    (cond [(and (fp-invoke? a) (not (fp-invoke-target a))) (symbol->string (fp-invoke-name a))]
          [(fp-invoke? a) (let ([t (step-name (fp-invoke-target a))]) (and t (string-append t "." (symbol->string (fp-invoke-name a)))))]
          [(and (fp-call? a) (eq? (fp-call-name a) 'ofType) (= 1 (length (fp-call-args a))))
           (define t (step-name (fp-call-target a)))
           (define ty (let ([x (car (fp-call-args a))]) (and (fp-invoke? x) (not (fp-invoke-target x)) (symbol->string (fp-invoke-name x)))))
           (and t ty (string-append t (string-upcase (substring ty 0 1)) (substring ty 1)))]
          [else #f]))
  (or (step-name a) (fhirpath->string a)))

;; literals : AST -> (listof string)   the string literals of a condition, urls left out when others remain
(define (literals a)
  (define all
    (let walk ([a a])
      (cond [(and (fp-lit? a) (string? (fp-lit-value a))) (list (fp-lit-value a))]
            [(fp-binop? a) (append (walk (fp-binop-lhs a)) (walk (fp-binop-rhs a)))]
            [(fp-unop? a) (walk (fp-unop-operand a))]
            [(fp-call? a) (append (if (fp-call-target a) (walk (fp-call-target a)) '()) (append-map walk (fp-call-args a)))]
            [(fp-invoke? a) (if (fp-invoke-target a) (walk (fp-invoke-target a)) '())]
            [else '()])))
  (define plain (filter (lambda (s) (not (regexp-match? #rx"://" s))) all))
  (remove-duplicates (if (null? plain) all plain)))

;; evidence : AST focus root prefix -> (listof Evidence)
(define (evidence a focus root prefix)
  (define (ev x [f focus]) (eval-fhirpath x (list f) #:externals (hash "resource" (list root) "rootResource" (list root) "context" (list f))))
  (define (false? x [f focus]) (equal? (map item->system (ev x f)) (list #f)))
  (define (values-of x vs)
    (format "~a~a = ~a" prefix (label x)
            (clip (string-join (map compact-item (take vs (min 3 (length vs)))) ", ") (if (> (length vs) 3) ", …" ""))))
  (define (leafy? vs) (andmap (lambda (v) (not (regexp-match? #rx"^{" (compact-item v)))) vs))
  ;; X matching c found nothing: X's values when they are values, else "no X matching …"
  (define (none x c)
    (define xs (ev x))
    (cond [(and (pair? xs) (leafy? xs)) (list (values-of x xs))]
          ;; there, but not what c asks: what it holds, not "no X" (a Quantity without its unit was
          ;; reported as missing, at the instance's header rather than at the rule that wrote it)
          [(and (pair? xs) (typed-value? x)) (list (values-of x xs))]
          [else (list (format "no ~a~a~a" prefix (label x)
                              (if c (let ([ls (literals c)])
                                      (if (null? ls) (format " matching ~a" (fhirpath->string c))
                                          (format " matching ~a" (string-join (map (lambda (l) (format "'~a'" l)) ls) ", "))))
                                  "")))]))
  ;; typed-value? : a selection of one typed value (`value.ofType(Quantity)`), not a list of elements
  ;; (`component`), whose items not matching are best said as "no component matching …"
  (define (typed-value? x) (and (fp-call? x) (memq (fp-call-name x) '(ofType as)) #t))
  (cond
    [(and (fp-binop? a) (eq? (fp-binop-op a) 'implies)) (evidence (fp-binop-rhs a) focus root prefix)]
    [(and (fp-binop? a) (eq? (fp-binop-op a) 'and))
     (define parts (filter (lambda (x) (false? x)) (list (fp-binop-lhs a) (fp-binop-rhs a))))
     (append-map (lambda (x) (evidence x focus root prefix)) (if (null? parts) (list (fp-binop-lhs a) (fp-binop-rhs a)) parts))]
    [(and (fp-binop? a) (eq? (fp-binop-op a) 'or))
     (append (evidence (fp-binop-lhs a) focus root prefix) (evidence (fp-binop-rhs a) focus root prefix))]
    ;; X.where(c).exists(), X.exists(c), X.exists()
    [(and (fp-call? a) (eq? (fp-call-name a) 'exists) (fp-call-target a) (rooted? (fp-call-target a)))
     (define t (fp-call-target a))
     (cond [(pair? (fp-call-args a)) (none t (car (fp-call-args a)))]
           [(and (fp-call? t) (eq? (fp-call-name t) 'where) (fp-call-target t) (pair? (fp-call-args t)))
            (none (fp-call-target t) (car (fp-call-args t)))]
           [else (none t #f)])]
    ;; X[.where(c)].all(p): p's evidence on each item that fails it
    [(and (fp-call? a) (eq? (fp-call-name a) 'all) (fp-call-target a) (= 1 (length (fp-call-args a))) (rooted? (fp-call-target a)))
     (define t (fp-call-target a))
     (define-values (base c)
       (if (and (fp-call? t) (eq? (fp-call-name t) 'where) (fp-call-target t) (pair? (fp-call-args t)))
           (values (fp-call-target t) (car (fp-call-args t)))
           (values t #f)))
     (define p (car (fp-call-args a)))
     ;; an element of the focus (`component`) names its items by index, as the JSON does
     (define element? (and (fp-invoke? base) (not (fp-invoke-target base))))
     (define items (ev base))
     (append*
      (for/list ([it (in-list items)] [i (in-naturals)]
                 #:when (or (not c) (equal? (map item->system (ev c it)) (list #t)))
                 #:when (false? p it))
        (evidence p it root (if element? (format "~a~a[~a]." prefix (label base) i) (format "~a~a." prefix (label base))))))]
    [else
     ;; the selections it compares, with what they hold
     (define (paths a)
       (cond [(rooted? a) (list (selection a))]
             [(fp-binop? a) (append (paths (fp-binop-lhs a)) (paths (fp-binop-rhs a)))]
             [(fp-unop? a) (paths (fp-unop-operand a))]
             [(fp-typeop? a) (paths (fp-typeop-operand a))]
             [(and (fp-call? a) (fp-call-target a)) (paths (fp-call-target a))]
             [else '()]))
     (for*/list ([x (in-list (remove-duplicates (paths a)))] [vs (in-value (ev x))] #:when (pair? vs))
       (values-of x vs))]))

;; found-text : expression focus root -> string   "" or " (found p = v; no q matching 'c')"
(define (found-text expr focus root)
  (with-handlers ([exn:fail? (lambda (_) "")])
    (define parts (remove-duplicates (evidence (parse-fhirpath expr) focus root "")))
    (if (null? parts) "" (format " (found ~a)" (string-join (take parts (min 4 (length parts))) "; ")))))

;; clip : string suffix -> string   at most 100 characters
(define (clip s more) (if (> (string-length s) 100) (string-append (substring s 0 99) "…") (string-append s more)))

;; compact-item : item -> string   a FHIRPath item as a reader writes it
(define (compact-item it)
  (define v (item->system it))
  (cond [(fhir? v) (compact-json (node->jsexpr v))]
        [(fhir? it) (compact-json (node->jsexpr it))]
        [(string? v) v]
        [(boolean? v) (if v "true" "false")]
        [else (let ([o (open-output-string)]) (display (if (number? v) v (compact-system v)) o) (get-output-string o))]))
(define (compact-system v)
  (with-handlers ([exn:fail? (lambda (_) (format "~a" v))])
    ((dynamic-require 'fhirpath/render 'item->text) v)))

;; compact-json : jsexpr -> string   a Quantity `300 '/min'`, a Coding `system#code`, a
;; CodeableConcept its codings (else its text), a Reference `Reference(Type/id)`, an object
;; `{key: value, …}` without ids and extensions
(define (compact-json j)
  (cond
    [(hash? j)
     (define (has k) (hash-ref j k #f))
     (cond
       [(and (has 'value) (or (has 'unit) (has 'code)) (not (has 'coding)) (number-ish? (has 'value)))
        (format "~a '~a'" (compact-json (has 'value)) (or (has 'code) (has 'unit)))]
       ;; a Quantity that is only a number: said so (`{value: 120}` read as nothing in particular)
       [(and (has 'value) (number-ish? (has 'value)) (= (hash-count j) 1))
        (format "~a (no unit)" (compact-json (has 'value)))]
       ;; a UCUM Quantity with its unit and no number (it printed as a Coding, `…unitsofmeasure.org#mm[Hg]`)
       [(and (not (has 'value)) (not (has 'display)) (or (has 'code) (has 'unit))
             (or (has 'unit) (equal? (has 'system) "http://unitsofmeasure.org")))
        (format "'~a' (no number)" (or (has 'code) (has 'unit)))]
       [(and (has 'code) (string? (has 'code)) (or (has 'system) (has 'display)) (not (has 'value)))
        (format "~a#~a" (or (has 'system) "") (has 'code))]
       [(list? (has 'coding)) (string-join (map compact-json (has 'coding)) ", ")]
       [(and (has 'text) (= (hash-count j) 1)) (format "~a" (has 'text))]
       [(string? (has 'reference)) (format "Reference(~a)" (has 'reference))]
       [else (format "{~a}" (string-join (for/list ([k (in-list (sort (hash-keys j) symbol<?))]
                                                    #:unless (memq k '(id extension modifierExtension)))
                                           (format "~a: ~a" k (compact-json (hash-ref j k))))
                                         ", "))])]
    [(list? j) (string-join (map compact-json j) ", ")]
    [(string? j) j]
    [(boolean? j) (if j "true" "false")]
    [(jnum? j) (jnum-lexeme j)]
    [else (format "~a" j)]))
(define (number-ish? v) (or (number? v) (jnum? v)))

;; the focus node(s) for an element's relative path (""=root)
;; focus-items : relative-path node -> (listof node)
(define (focus-items rel node)
  (cond [(equal? rel "") (list node)]
        [else (with-handlers ([exn:fail? (lambda (_) '())]) (eval-fhirpath (parse-fhirpath rel) (list node)))]))

;; ---- terminology helper ----------------------------------------------------------------------
;; -> 'yes | 'no | 'unknown. Fail-open: return 'no ONLY when the ValueSet demonstrably expands to a
;; non-empty set offline (so we truly know its members) and the code is absent; otherwise 'unknown.
;; tx-member? : tx value-set-url code system|#f -> Membership
(define (tx-member? tx vs code system)
  (with-handlers ([exn:fail? (lambda (_) 'unknown)])
    (define exp ((tx-service-expand tx) vs))
    (define contains (and (pair? exp)
                          (let ([e (hash-ref (node->jsexpr (car exp)) 'expansion #f)])
                            (and (hash? e) (let ([c (hash-ref e 'contains #f)]) (and (list? c) c))))))
    (define members (and contains (length contains)))
    (cond
      [(or (not members) (= members 0)) 'unknown]     ; VS unresolvable/empty -> undecidable
      ;; a code whose system the expansion does not reach (a value set only partly expandable here)
      ;; is undecidable, not absent
      [(and system (not (for/or ([c (in-list contains)]) (equal? (hash-ref c 'system #f) system)))) 'unknown]
      [else
       (define out ((tx-service-validate tx) vs code system))
       (define params (if (pair? out) (let ([p (hash-ref (node->jsexpr (car out)) 'parameter '())])
                                        (if (list? p) p '())) '()))
       (define result (for/or ([p (in-list params)]) (and (equal? (hash-ref p 'name #f) "result")
                                                          (hash-ref p 'valueBoolean 'none))))
       (cond [(eq? result #t) 'yes] [(eq? result #f) 'no] [else 'unknown])])))

;; ---- small helpers ---------------------------------------------------------------------------
;; elem-leaf : ElementDef parent-path -> leaf   the element's own step ("value[x]")
(define (elem-leaf ce parent)
  (define p (hash-ref ce 'path))
  (if (string-prefix? p (string-append parent ".")) (substring p (add1 (string-length parent))) p))
;; child-loc : path leaf -> path
(define (child-loc path leaf) (string-append path "." leaf))
;; choice-leaf? : leaf -> boolean
(define (choice-leaf? leaf) (string-suffix? leaf "[x]"))
;; does JSON key `key` aim at the element whose leaf is `leaf` (a plain name, or a `value[x]` base +
;; any Capitalized suffix)? This is only the NAME match — variant-type checks the suffix is allowed.
;; key-targets-leaf? : leaf symbol -> boolean
(define (key-targets-leaf? leaf key)
  (define k (symbol->string key))
  (cond [(choice-leaf? leaf)
         (define base (substring leaf 0 (- (string-length leaf) 3)))
         (and (string-prefix? k base) (> (string-length k) (string-length base))
              (char-upper-case? (string-ref k (string-length base))))]
        [else (string=? k leaf)]))

;; for a choice element, the concrete type behind a matched key -> a type-code string (allowed
;; variant), 'any (element declares no types -> accept, fail-open), or #f (suffix not a declared type)
;; variant-type : leaf ElementDef symbol -> type-code | 'any | #f
(define (variant-type leaf ce key)
  (define base (substring leaf 0 (- (string-length leaf) 3)))
  (define suffix (substring (symbol->string key) (string-length base)))
  (define types (filter values (elem-type-codes ce)))
  (cond [(null? types) 'any]
        [else (for/or ([tc (in-list types)]) (and (string=? suffix (capitalize tc)) tc))]))

;; the concrete type for a matched key (choice -> its variant; non-choice -> the single type), or #f
;; matched-type : leaf ElementDef symbol -> type-code | #f
(define (matched-type leaf ce key)
  (cond [(choice-leaf? leaf) (let ([vt (variant-type leaf ce key)]) (and (string? vt) vt))]
        [else (single-type-code ce)]))

;; a key that aims at a choice element but whose suffix is not a declared type is a disallowed variant
;; allowed-key? : leaf ElementDef symbol -> boolean
(define (allowed-key? leaf ce key)
  (and (key-targets-leaf? leaf key) (or (not (choice-leaf? leaf)) (and (variant-type leaf ce key) #t))))

;; capitalize : string -> string   first character upper-cased
(define (capitalize s)
  (if (= 0 (string-length s)) s (string-append (string-upcase (substring s 0 1)) (substring s 1))))
(define instances-of listify)   ; a repeating property read -> always a list (model/leaf)

;; element type codes (from raw SD element.type[].code)
;; elem-type-codes : ElementDef -> (listof type-code|#f)
(define (elem-type-codes ce) (for/list ([t (in-list (hash-ref ce 'type '()))]) (hash-ref t 'code #f)))
;; single-type-code : ElementDef -> type-code | #f   the code when the element declares exactly one
(define (single-type-code ce) (let ([ts (elem-type-codes ce)]) (and (pair? ts) (null? (cdr ts)) (car ts))))
;; primitive-code? : any -> boolean   a FHIR primitive type code (lower-case first letter)
(define (primitive-code? tc) (and (string? tc) (> (string-length tc) 0) (char-lower-case? (string-ref tc 0))))

;; a fixed[x]/pattern[x] value on an element: scan keys prefixed "fixed"/"pattern"
;; choice-value : ElementDef prefix -> jsexpr | #f
(define (choice-value ce prefix)
  (for/or ([(k v) (in-hash ce)])
    (define ks (symbol->string k))
    (and (string-prefix? ks prefix) (> (string-length ks) (string-length prefix))
         (char-upper-case? (string-ref ks (string-length prefix))) v)))

;; coded values for binding: 'code scalar -> (#f . code); Coding -> (system . code); CodeableConcept -> its codings
;; coded-values : ElementDef value -> (listof (cons system|#f code))
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
;; rel-path : path -> path
(define (rel-path p)
  (define segs (string-split p "."))
  (if (> (length segs) 1) (string-join (cdr segs) ".") ""))

;; strip JSON nulls and empty arrays (and unwrap jnum -> its number) for fixed/pattern comparison.
;; JSON `false` is a VALUE and must survive — dropping it would make a fixed/pattern boolean false
;; unverifiable.
;; prune : jsexpr -> jsexpr
(define (prune v)
  (cond [(jnum? v) (jnum-value v)]
        [(hash? v) (for/hash ([(k x) (in-hash v)]
                              #:unless (or (eq? x 'null) (null? x)))
                     (values k (prune x)))]
        [(list? v) (map prune v)]
        [else v]))
;; every key/elt of `pat` present+matching in `v` (recursive subset)
;; json-contains? : pattern jsexpr -> boolean
(define (json-contains? pat v)
  (cond [(and (hash? pat) (hash? v)) (for/and ([(k pv) (in-hash pat)]) (and (hash-has-key? v k) (json-contains? pv (hash-ref v k))))]
        [(and (list? pat) (list? v)) (for/and ([p (in-list pat)]) (for/or ([x (in-list v)]) (json-contains? p x)))]
        [else (equal? pat v)]))

;; issues->outcome : (listof Issue) -> OperationOutcome node
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
                '())
  ;; a slice that constrains nothing at the discriminator claims no entry: an entry of "alpha" is
  ;; still held to alpha's children (value[x] only Quantity); one whose constraint we cannot read
  ;; (a required binding at kind) leaves the match undecided -> nothing
  (define (snap4 beta-kind)
    (append (list (car snap) (cadr snap) (caddr snap) (cadddr snap)
                  (hasheq 'id "DemoR.item:alpha.value[x]" 'path "DemoR.item.value[x]" 'min 0 'max "1"
                          'type (list (hasheq 'code "Quantity")))
                  (hasheq 'id "DemoR.item:beta" 'path "DemoR.item" 'sliceName "beta" 'min 0 'max "*"))
            beta-kind))
  (define stray-entry (hasheq 'item (list (hasheq 'kind "A" 'valueString "x"))))
  (define idx4 (make-element-index (snap4 '())))
  (check-equal? (map issue-msg (slice-issues idx4 "DemoR" (car (child-elements idx4 "DemoR")) stray-entry))
                '("valueString is not allowed in slice 'alpha' (value[x]: Quantity)"))
  (define idx5 (make-element-index
                (snap4 (list (hasheq 'id "DemoR.item:beta.kind" 'path "DemoR.item.kind"
                                     'binding (hasheq 'strength "required" 'valueSet "http://example.org/vs"))))))
  (check-equal? (slice-issues idx5 "DemoR" (car (child-elements idx5 "DemoR")) stray-entry) '()))

(module+ test
  ;; evidence: a Quantity with a unit and no number is said so, not printed as a Coding
  (check-equal? (compact-json (hasheq 'system "http://unitsofmeasure.org" 'code "mm[Hg]")) "'mm[Hg]' (no number)")
  (check-equal? (compact-json (hasheq 'value 120)) "120 (no unit)")
  (check-equal? (compact-json (hasheq 'system "http://loinc.org" 'code "8480-6")) "http://loinc.org#8480-6"))

(module+ test
  ;; a common clinical spelling names the UCUM code it means
  (define (warn code) (issue-msg (car (ucum-issues "Quantity" "x" (hasheq 'value 1 'system "http://unitsofmeasure.org" 'code code)))))
  (check-regexp-match #rx"`msec` is not a UCUM unit [(]did you mean `ms`[?][)]" (warn "msec"))
  (check-regexp-match #rx"`bpm` is not a UCUM unit [(]did you mean `/min`[?][)]" (warn "bpm"))
  (check-regexp-match #rx"mercury is written mm\\[Hg\\]" (warn "mmHg")))
