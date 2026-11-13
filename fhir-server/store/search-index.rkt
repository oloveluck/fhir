#lang racket/base

;;; search-index.rkt — FHIR search, driven by each parameter's declared TYPE.
;;;
;;; The two halves of search (https://hl7.org/fhir/search.html), both pure — fhir-engine.rkt owns
;;; the SQL connection and the write transaction:
;;;   extraction  — the items a parameter's FHIRPath expression selects become index ROWS, one
;;;                 table per parameter type (rows-for)
;;;   compilation — one query parameter `name[:modifier]=value[,value…]` becomes ONE SQL boolean
;;;                 fragment over the current resource row `r` (compile-param)
;;;
;;; Data definitions
;;;   A Kind is one of: 'token 'reference 'string 'date 'number 'quantity 'uri
;;;     ('composite and 'special are cataloged but not indexed — searching on them is ignored)
;;;   A Row is one of:
;;;     (token-row system code)            system : string|#f
;;;     (reference-row target-type target-id)
;;;     (string-row norm exact)            norm : case- and accent-folded, for the default match
;;;     (date-row low high)                ISO-8601 instants padded to full precision, UTC where the
;;;                                        value carries a zone ("0001-…"/"9999-…" for open ends)
;;;     (number-row value)
;;;     (quantity-row value system code)
;;;   A Clause is (clause sql args) — a fragment usable as `… AND <sql>` over `fhir_resources r`.
;;;   An IndexClause is a Clause that is one index lookup, (index-clause sql args probe rank ids):
;;;     `ids` is the lookup itself (`SELECT x.resource_id FROM <index> x WHERE …`), `sql` finds the
;;;     resources by it (`r.id IN (<ids>)`), `probe` asks the same of ONE resource through the
;;;     index's rows for it (`EXISTS …`), and `rank` says how few resources such a lookup tends to
;;;     leave (1 a reference … 8 "has any value"). The engine counts what `ids` finds and chooses
;;;     between `sql` and `probe` for each clause of a search.
;;;
;;; Search semantics implemented (the rest is ignored, never mis-answered):
;;;   all kinds : comma = OR within one parameter; repeated parameters AND (the caller conjoins);
;;;               `:missing=true|false`
;;;   token     : `code`, `system|code`, `|code` (no system), `system|`; `:not`
;;;   reference : `id`, `Type/id`, an absolute URL ending in `Type/id`
;;;   string    : case- and accent-insensitive STARTS-WITH (default); `:exact`; `:contains`
;;;   uri       : exact match
;;;   date      : prefixes eq ne gt lt ge le sa eb ap over the value's implicit RANGE
;;;               (`2024` means the whole year), per the spec's range semantics
;;;   number    : the same prefixes; `eq` honours the value's precision (100 matches [99.5,100.5))
;;;   quantity  : `[prefix]number|system|code`, `number||code`, `number` (system/code optional)

(require racket/contract racket/list racket/string racket/match racket/math
         (only-in fhir/model/node fhir? fhir-ref fhir-type)
         (only-in fhir/model/base primitive-type? primitive-type-value)
         (only-in fhir/primitives/primitives primitive->jsexpr)
         (only-in fhir/model/leaf pv listify))

(provide
 (struct-out token-row) (struct-out reference-row) (struct-out string-row)
 (struct-out date-row) (struct-out number-row) (struct-out quantity-row)
 (struct-out clause) (struct-out index-clause)
 index-tables table-of owner-index
 (contract-out
  [indexed-kind?   (-> symbol? boolean?)]
  [rows-for        (-> symbol? list? list?)]
  [row-table+values (-> any/c (values string? list?))]
  [compile-param   (-> string? symbol? (or/c string? #f) string? (or/c clause? #f))]
  [clause-args/type (-> clause? string? list?)]
  ;; how a clause is asked of one resource, and how selective it tends to be (9: not one lookup)
  [clause-probe (-> clause? string?)]
  [clause-rank (-> clause? exact-nonnegative-integer?)]
  [fold-string     (-> string? string?)]
  [date-range      (-> string? (or/c (cons/c string? string?) #f))]))

(struct token-row (system code) #:transparent)
(struct reference-row (target-type target-id) #:transparent)
(struct string-row (norm exact) #:transparent)
(struct date-row (low high) #:transparent)
(struct number-row (value) #:transparent)
(struct quantity-row (value system code) #:transparent)
(struct clause (sql args) #:transparent)
(struct index-clause clause (probe rank ids) #:transparent)
(define (clause-probe c) (if (index-clause? c) (index-clause-probe c) (clause-sql c)))
(define (clause-rank c) (if (index-clause? c) (index-clause-rank c) 9))

(define indexed-kinds '(token reference string date number quantity uri))
(define (indexed-kind? k) (and (memq k indexed-kinds) #t))

;; table name + column list per row type (the schema lives in fhir-sqlite.rkt)
(define index-tables
  '(("fhir_token_index" system code)
    ("fhir_reference_index" target_type target_id)
    ("fhir_string_index" value_norm value_exact)
    ("fhir_date_index" low high)
    ("fhir_number_index" value)
    ("fhir_quantity_index" value system code)))

;; row-table+values : Row -> (values table (listof column-value))
(define (row-table+values row)
  (match row
    [(token-row s c)      (values "fhir_token_index" (list s c))]
    [(reference-row t i)  (values "fhir_reference_index" (list t i))]
    [(string-row n e)     (values "fhir_string_index" (list n e))]
    [(date-row l h)       (values "fhir_date_index" (list l h))]
    [(number-row v)       (values "fhir_number_index" (list v))]
    [(quantity-row v s c) (values "fhir_quantity_index" (list v s c))]))

(define (table-of kind)
  (case kind
    [(token uri) "fhir_token_index"] [(reference) "fhir_reference_index"]
    [(string) "fhir_string_index"] [(date) "fhir_date_index"]
    [(number) "fhir_number_index"] [(quantity) "fhir_quantity_index"]))

;; owner-index : table -> index name   the index that finds ONE resource's rows of a table
;; (resource_type, resource_id …): the store's schema names them (idx_<short>_owner; the dates',
;; which carries the values too, idx_date_own). A per-resource
;; lookup names it (`INDEXED BY`): left to itself SQLite took the by-value index for a sort key and
;; walked every date row of the type for each matched resource.
(define (owner-index table)
  (cdr (assoc table '(("fhir_token_index" . "idx_token_owner") ("fhir_reference_index" . "idx_ref_owner")
                      ("fhir_string_index" . "idx_string_owner") ("fhir_date_index" . "idx_date_own")
                      ("fhir_number_index" . "idx_number_owner") ("fhir_quantity_index" . "idx_quantity_owner")))))

;; ==== extraction ==============================================================================

;; scalar : item -> the item's JSON scalar (a string/number/boolean), or #f for complex items
(define (scalar it)
  (cond [(primitive-type? it) (let ([v (primitive->jsexpr it)]) (and (not (eq? v 'null)) v))]
        [(or (string? it) (number? it) (boolean? it)) it]   ; raw fields (Resource.id) and System values
        [else #f]))

(define (render v) (cond [(boolean? v) (if v "true" "false")] [(string? v) v] [else (format "~a" v)]))

(define (str-field n k) (let ([v (pv (fhir-ref n k #f))]) (and v (render v))))
(define (str-fields n k) (filter values (map (lambda (x) (let ([v (pv x)]) (and v (render v))))
                                             (listify (fhir-ref n k '())))))
(define (type-is? it t) (and (fhir? it) (eq? (fhir-type it) t)))

;; rows-for : Kind (listof item) -> (listof Row)
(define (rows-for kind items)
  (remove-duplicates
   (append-map
    (lambda (it)
      (case kind
        [(token)     (token-rows it)]
        [(uri)       (let ([s (scalar it)]) (if s (list (token-row #f (render s))) '()))]
        [(reference) (reference-rows it)]
        [(string)    (string-rows it)]
        [(date)      (date-rows it)]
        [(number)    (let ([s (scalar it)]) (if (real? s) (list (number-row (exact->inexact s))) '()))]
        [(quantity)  (quantity-rows it)]
        [else '()]))
    items)))

(define (token-rows it)
  (cond
    [(scalar it) => (lambda (s) (list (token-row #f (render s))))]
    [(type-is? it 'CodeableConcept) (append-map token-rows (listify (fhir-ref it 'coding '())))]
    [(type-is? it 'Coding)
     (let ([c (str-field it 'code)]) (if c (list (token-row (str-field it 'system) c)) '()))]
    [(type-is? it 'Identifier)
     (let ([v (str-field it 'value)]) (if v (list (token-row (str-field it 'system) v)) '()))]
    [(type-is? it 'ContactPoint)
     (let ([v (str-field it 'value)]) (if v (list (token-row #f v)) '()))]
    [else '()]))

(define (reference-rows it)
  (define ref
    (cond [(type-is? it 'Reference) (str-field it 'reference)]
          [(scalar it) => render]                          ; canonical / uri used as a reference
          [else #f]))
  (cond
    [(not ref) '()]
    [(regexp-match #px"(?:^|/)([A-Z][A-Za-z]+)/([A-Za-z0-9.-]{1,64})(?:/_history/[^/]+)?$" ref)
     => (lambda (m) (list (reference-row (cadr m) (caddr m))))]
    [else (list (reference-row #f ref))]))

;; fold-string : string -> string   lower-cased, accents stripped (NFD minus combining marks)
(define (fold-string s)
  (string-downcase (regexp-replace* #px"\\p{Mn}" (string-normalize-nfd s) "")))

(define (string-rows it)
  (define parts
    (cond
      [(scalar it) => (lambda (s) (list (render s)))]
      [(type-is? it 'HumanName)
       (append (filter values (list (str-field it 'family) (str-field it 'text)))
               (str-fields it 'given) (str-fields it 'prefix) (str-fields it 'suffix))]
      [(type-is? it 'Address)
       (append (str-fields it 'line)
               (filter values (map (lambda (k) (str-field it k)) '(city district state postalCode country text))))]
      [else '()]))
  (for/list ([p (in-list parts)]) (string-row (fold-string p) p)))

(define (date-rows it)
  (cond
    [(scalar it) => (lambda (s) (let ([r (and (string? s) (date-range s))])
                                  (if r (list (date-row (car r) (cdr r))) '())))]
    ;; a Period's bounds are read as FHIR writes them (`scalar`: the JSON text). They were read as
    ;; the parsed value printed (`#(struct:t-datetime …)`), which is no date: no Period was ever
    ;; indexed, so `Encounter?date=…` matched nothing and `_sort=date` sorted nothing
    [(type-is? it 'Period)
     (define (bound k) (let* ([f (fhir-ref it k #f)] [s (and f (scalar f))]) (and (string? s) (date-range s))))
     (define lo (bound 'start))
     (define hi (bound 'end))
     (if (or lo hi) (list (date-row (if lo (car lo) min-instant) (if hi (cdr hi) max-instant))) '())]
    [(type-is? it 'Timing) (append-map date-rows (listify (fhir-ref it 'event '())))]
    [else '()]))

(define (quantity-rows it)
  (cond
    [(or (type-is? it 'Quantity) (type-is? it 'Age) (type-is? it 'Duration)
         (type-is? it 'Distance) (type-is? it 'Count) (type-is? it 'SimpleQuantity) (type-is? it 'Money))
     (define v (let ([x (pv (fhir-ref it 'value #f))]) (and x (scalar (fhir-ref it 'value #f)))))
     (if (real? v)
         (list (quantity-row (exact->inexact v) (str-field it 'system)
                             (or (str-field it 'code) (str-field it 'unit) (str-field it 'currency))))
         '())]
    [else '()]))

;; ==== dates as ranges =========================================================================

(define min-instant "0001-01-01T00:00:00.000")
(define max-instant "9999-12-31T23:59:59.999")

(define (pad2 n) (if (< n 10) (format "0~a" n) (number->string n)))
(define (pad4 n) (let ([s (number->string n)]) (string-append (make-string (max 0 (- 4 (string-length s))) #\0) s)))
(define (days-in y m)
  (case m [(1 3 5 7 8 10 12) 31] [(4 6 9 11) 30]
    [else (if (and (zero? (modulo y 4)) (or (not (zero? (modulo y 100))) (zero? (modulo y 400)))) 29 28)]))

;; date-range : ISO-8601 date/dateTime/instant (any precision) -> (cons low high), or #f
;; low/high are "YYYY-MM-DDThh:mm:ss.fff"; a value with a zone is shifted to UTC.
(define (date-range s)
  (match (regexp-match #px"^(\\d{4})(?:-(\\d{2})(?:-(\\d{2})(?:T(\\d{2}):(\\d{2})(?::(\\d{2})(?:\\.(\\d+))?)?)?)?)?(Z|[+-]\\d{2}:\\d{2})?$" s)
    [#f #f]
    [(list _ y mo d h mi se fr tz)
     (define Y (string->number y))
     (define (n x dflt) (if x (string->number x) dflt))
     (define lo (list Y (n mo 1) (n d 1) (n h 0) (n mi 0) (n se 0)
                      (if fr (string->number (substring (string-append fr "000") 0 3)) 0)))
     (define hi
       (cond [(not mo) (list Y 12 31 23 59 59 999)]
             [(not d)  (list Y (n mo 1) (days-in Y (n mo 1)) 23 59 59 999)]
             [(not h)  (list Y (n mo 1) (n d 1) 23 59 59 999)]
             [(not se) (list Y (n mo 1) (n d 1) (n h 0) (n mi 0) 59 999)]
             [(not fr) (list Y (n mo 1) (n d 1) (n h 0) (n mi 0) (n se 0) 999)]
             [else lo]))
     (define off (match tz [(or #f "Z") 0]
                   [_ (let ([m (regexp-match #px"([+-])(\\d{2}):(\\d{2})" tz)])
                        (* (if (equal? (cadr m) "-") -1 1)
                           (+ (* 60 (string->number (caddr m))) (string->number (cadddr m)))))]))
     (cons (fmt (shift lo (- off))) (fmt (shift hi (- off))))]))

;; shift : components minutes -> components moved by `minutes` (carrying through the calendar)
(define (shift c minutes)
  (if (zero? minutes) c
      (match-let ([(list Y M D h mi s ms) c])
        (define total (+ (* h 60) mi minutes))
        (define day-delta (floor (/ total 1440)))
        (define rem (- total (* day-delta 1440)))
        (let loop ([Y Y] [M M] [D (+ D day-delta)])
          (cond [(< D 1) (let* ([M2 (if (= M 1) 12 (sub1 M))] [Y2 (if (= M 1) (sub1 Y) Y)])
                           (loop Y2 M2 (+ D (days-in Y2 M2))))]
                [(> D (days-in Y M)) (let* ([D2 (- D (days-in Y M))] [M2 (if (= M 12) 1 (add1 M))] [Y2 (if (= M 12) (add1 Y) Y)])
                                       (loop Y2 M2 D2))]
                [else (list Y M D (quotient rem 60) (remainder rem 60) s ms)])))))

(define (fmt c)
  (match-let ([(list Y M D h mi s ms) c])
    (format "~a-~a-~aT~a:~a:~a.~a" (pad4 Y) (pad2 M) (pad2 D) (pad2 h) (pad2 mi) (pad2 s)
            (let ([x (number->string ms)]) (string-append (make-string (- 3 (string-length x)) #\0) x)))))

;; ==== compilation =============================================================================

;; split-or : value -> (listof value)   comma-separated alternatives; `\,` is a literal comma
(define (split-or v)
  (map (lambda (s) (string-replace s "\u0000" ","))
       (string-split (string-replace v "\\," "\u0000") "," #:trim? #f)))

(define prefix-rx #px"^(eq|ne|gt|lt|ge|le|sa|eb|ap)(.*)$")
(define (split-prefix v)
  (match (regexp-match prefix-rx v) [(list _ p rest) (values (string->symbol p) rest)] [#f (values 'eq v)]))

;; exists-in : table name extra-sql extra-args -> Clause
;; "the resource has an index row of this parameter that …", written so that the store starts from
;; the INDEX: the ids of the rows that match, looked up among the resources. It was a correlated
;; EXISTS, which SQLite ran once per resource of the type, each time walking every index row of the
;; value — over a patient's 28,000 Observations among 813,000 that is 23 billion steps, and the
;; search did not come back; this form is the 28,000. The subquery names the resource type by a
;; bind value of its own (`the-resource-type` among the args, filled in by the engine), so nothing
;; in it depends on the outer row.
(define the-resource-type 'resource-type)
(define (exists-in table name sql args #:rank [rank (table-rank table)])
  (define condition (string-append " AND x.param_name=?" (if (string=? sql "") "" " AND ") sql))
  (define ids (string-append "SELECT x.resource_id FROM " table " x WHERE x.resource_type=?" condition))
  (index-clause (string-append "r.id IN (" ids ")")
                (list* the-resource-type name args)
                ;; the same, asked of the outer row: its own index rows, found by owner
                (string-append "EXISTS (SELECT 1 FROM " table " x INDEXED BY " (owner-index table)
                               " WHERE x.resource_id=r.id AND x.resource_type=?" condition ")")
                rank
                ids))

;; table-rank : table -> rank   how few resources a lookup in an index table tends to leave: a
;; reference (a patient's) fewest, then a code, a string, a number, a date range
(define (table-rank table)
  (case table
    [("fhir_reference_index") 1] [("fhir_token_index") 2] [("fhir_string_index") 3]
    [("fhir_number_index" "fhir_quantity_index") 5] [else 6]))

;; clause-args/type : Clause resource-type -> (listof bind-value)   the clause's values, the
;; resource type in its places
(define (clause-args/type c rtype)
  (for/list ([a (in-list (clause-args c))]) (if (eq? a the-resource-type) rtype a)))

(define (or-clauses cs)
  (define ok (filter values cs))
  (cond [(null? ok) #f]
        [(null? (cdr ok)) (car ok)]                    ; one value: the lookup itself
        [else (clause (string-append "(" (string-join (map clause-sql ok) " OR ") ")") (append-map clause-args ok))]))

;; compile-param : name Kind modifier value -> Clause | #f   (#f = unsupported, caller ignores it)
(define (compile-param name kind modifier value)
  (cond
    [(not (indexed-kind? kind)) #f]
    [(equal? modifier "missing")
     (define c (exists-in (table-of kind) name "" '() #:rank 8))
     (if (equal? value "true") (clause (string-append "NOT " (clause-sql c)) (clause-args c)) c)]
    [(and (eq? kind 'token) (equal? modifier "not"))
     (define c (or-clauses (map (lambda (v) (token-clause name v)) (split-or value))))
     (and c (clause (string-append "NOT " (clause-sql c)) (clause-args c)))]
    ;; a reference's [type] modifier: `subject:Patient=123` is `subject=Patient/123`
    [(and (eq? kind 'reference) modifier (regexp-match? #px"^[A-Z][A-Za-z]+$" modifier))
     (or-clauses (for/list ([v (in-list (split-or value))])
                   (if (regexp-match? #rx"/" v)
                       (and (regexp-match? (pregexp (string-append "(?:^|/)" modifier "/")) v) (reference-clause name v))
                       (exists-in "fhir_reference_index" name "x.target_type=? AND x.target_id=?" (list modifier v)))))]
    [(and modifier (not (member modifier (case kind [(string) '("exact" "contains")] [else '()])))) #f]
    [else
     (or-clauses
      (for/list ([v (in-list (split-or value))])
        (case kind
          [(token)     (token-clause name v)]
          [(uri)       (exists-in "fhir_token_index" name "x.code=?" (list v))]
          [(reference) (reference-clause name v)]
          [(string)    (string-clause name modifier v)]
          [(date)      (date-clause name v)]
          [(number)    (number-clause name v)]
          [(quantity)  (quantity-clause name v)])))]))

(define (token-clause name v)
  (match (regexp-match #px"^([^|]*)\\|(.*)$" v)
    [(list _ "" code) (exists-in "fhir_token_index" name "x.code=? AND x.system IS NULL" (list code))]
    [(list _ sys "")  (exists-in "fhir_token_index" name "x.system=?" (list sys) #:rank 6)]
    [(list _ sys code) (exists-in "fhir_token_index" name "x.code=? AND x.system=?" (list code sys))]
    [#f (exists-in "fhir_token_index" name "x.code=?" (list v))]))

(define (reference-clause name v)
  (match (regexp-match #px"(?:^|/)([A-Z][A-Za-z]+)/([A-Za-z0-9.-]{1,64})$" v)
    [(list _ t id) (exists-in "fhir_reference_index" name "x.target_type=? AND x.target_id=?" (list t id))]
    [#f (exists-in "fhir_reference_index" name "x.target_id=?" (list v))]))

(define (like-escape s) (regexp-replace* #px"([%_\\\\])" s "\\\\\\1"))
(define (string-clause name modifier v)
  (match modifier
    ["exact"    (exists-in "fhir_string_index" name "x.value_exact=?" (list v))]
    ["contains" (exists-in "fhir_string_index" name "x.value_norm LIKE ? ESCAPE '\\'"
                           (list (string-append "%" (like-escape (fold-string v)) "%")))]
    [_          (exists-in "fhir_string_index" name "x.value_norm LIKE ? ESCAPE '\\'"
                           (list (string-append (like-escape (fold-string v)) "%")))]))

;; the spec's range semantics, over [lo,hi] (target) vs [plo,phi] (search value)
(define (range-sql prefix)
  (case prefix
    [(eq) (values "x.~a >= ? AND x.~a <= ?" '(lo plo hi phi))]
    [(ne) (values "NOT (x.~a >= ? AND x.~a <= ?)" '(lo plo hi phi))]
    [(gt) (values "x.~a > ?" '(hi phi))]
    [(lt) (values "x.~a < ?" '(lo plo))]
    [(ge) (values "x.~a >= ?" '(hi plo))]
    [(le) (values "x.~a <= ?" '(lo phi))]
    [(sa) (values "x.~a > ?" '(lo phi))]
    [(eb) (values "x.~a < ?" '(hi plo))]
    [(ap) (values "x.~a <= ? AND x.~a >= ?" '(lo phi hi plo))]))

;; build : prefix target-column-names (lo . hi) search-range (plo . phi) -> (values sql args)
(define (build-range prefix lo-col hi-col plo phi)
  (define-values (template slots) (range-sql prefix))
  (define cols (for/list ([s (in-list slots)] #:when (memq s '(lo hi))) (if (eq? s 'lo) lo-col hi-col)))
  (define args (for/list ([s (in-list slots)] #:when (memq s '(plo phi))) (if (eq? s 'plo) plo phi)))
  (values (apply format template cols) args))

(define (date-clause name v)
  (define-values (p rest) (split-prefix v))
  (define r (date-range rest))
  (and r (let-values ([(sql args) (build-range p "low" "high" (car r) (cdr r))])
           (exists-in "fhir_date_index" name sql args))))

;; number-range : "100" -> (values 99.5 100.5); "1.5e2" etc. via the lexical precision
(define (number-range s)
  (define n (string->number s 10))
  (cond
    [(not (real? n)) (values #f #f)]
    [else
     (define frac (let ([m (regexp-match #px"\\.(\\d+)" s)]) (if m (string-length (cadr m)) 0)))
     (define half (* 1/2 (expt 10 (- frac))))
     (values (exact->inexact (- (inexact->exact n) half)) (exact->inexact (+ (inexact->exact n) half)))]))

;; number-bounds : prefix text -> (values lo hi)   the search value's range for eq/ne/ap (its
;; precision: 100 is [99.5, 100.5)); the exact value for the comparisons, which FHIR defines
;; "regardless of the precision" (gt8 matches 8.4: the range would have made it 8.5)
(define (number-bounds p s)
  (define-values (lo hi) (number-range s))
  (if (and lo (memq p '(gt lt ge le sa eb)))
      (let ([n (exact->inexact (string->number s 10))]) (values n n))
      (values lo hi)))

(define (number-clause name v)
  (define-values (p rest) (split-prefix v))
  (define-values (lo hi) (number-bounds p rest))
  (and lo (let-values ([(sql args) (if (eq? p 'eq)
                                         (values "x.value >= ? AND x.value < ?" (list lo hi))
                                         (build-range p "value" "value" lo hi))])
            (exists-in "fhir_number_index" name sql args))))

(define (quantity-clause name v)
  (match-define (list num sys code)
    (let ([parts (string-split v "|" #:trim? #f)])
      (list (car parts) (and (> (length parts) 1) (cadr parts)) (and (> (length parts) 2) (caddr parts)))))
  (define-values (p rest) (split-prefix num))
  (define-values (lo hi) (number-bounds p rest))
  (and lo
       (let*-values ([(sql args) (if (eq? p 'eq)
                                     (values "x.value >= ? AND x.value < ?" (list lo hi))
                                     (build-range p "value" "value" lo hi))]
                     [(sql args) (if (and sys (not (string=? sys ""))) (values (string-append sql " AND x.system=?") (append args (list sys))) (values sql args))]
                     [(sql args) (if (and code (not (string=? code ""))) (values (string-append sql " AND x.code=?") (append args (list code))) (values sql args))])
         (exists-in "fhir_quantity_index" name sql args))))

(module+ test
  (require rackunit)
  ;; numbers: eq at the value's precision, the comparisons against the exact value (FHIR search)
  (define (bounds p s) (call-with-values (lambda () (number-bounds p s)) list))
  (check-equal? (bounds 'eq "100") '(99.5 100.5))
  (check-equal? (bounds 'gt "8") '(8.0 8.0))                      ; gt8 matches 8.4
  (check-equal? (bounds 'le "8.0") '(8.0 8.0))
  (check-equal? (bounds 'ap "8") '(7.5 8.5))
  ;; dates are ranges at their own precision, shifted to UTC when zoned
  (check-equal? (date-range "2024") (cons "2024-01-01T00:00:00.000" "2024-12-31T23:59:59.999"))
  (check-equal? (date-range "2024-02") (cons "2024-02-01T00:00:00.000" "2024-02-29T23:59:59.999"))
  (check-equal? (date-range "2024-03-01T01:30:00+02:00") (cons "2024-02-29T23:30:00.000" "2024-02-29T23:30:00.999"))
  (check-equal? (date-range "1999-12-31T23:00:00-05:00") (cons "2000-01-01T04:00:00.000" "2000-01-01T04:00:00.999"))
  (check-false (date-range "not a date"))
  (check-equal? (fold-string "Bénédicte") "benedicte")
  ;; comma = OR; escaped comma is literal
  (check-equal? (split-or "a,b\\,c") '("a" "b,c"))
  ;; compilation picks the table from the KIND, not the value's shape
  (check-regexp-match #rx"fhir_string_index" (clause-sql (compile-param "family" 'string #f "Chal")))
  (check-equal? (clause-args/type (compile-param "family" 'string #f "Chal") "Patient") '("Patient" "family" "chal%"))
  (check-regexp-match #rx"^\\(r.id IN .* OR r.id IN" (clause-sql (compile-param "gender" 'token #f "male,female")))
  (check-regexp-match #rx"^NOT r.id IN" (clause-sql (compile-param "gender" 'token "missing" "true")))
  ;; the subquery stands alone: its resource type is a bind value, filled in by the engine
  (check-false (regexp-match? #rx"r[.]resource_type" (clause-sql (compile-param "gender" 'token #f "male"))))
  (check-equal? (clause-args/type (compile-param "gender" 'token #f "male") "Patient") '("Patient" "gender" "male"))
  (check-false (compile-param "x" 'composite #f "a$b"))
  (check-false (compile-param "family" 'string "text" "x"))               ; unsupported modifier
  ;; a reference's type modifier names the target type: subject:Patient=123 = subject=Patient/123
  (check-equal? (compile-param "subject" 'reference "Patient" "123") (or-clauses (list (reference-clause "subject" "Patient/123"))))
  (define-values (lo hi) (number-range "100"))
  (check-equal? (list lo hi) '(99.5 100.5)))
