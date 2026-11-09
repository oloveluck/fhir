#lang racket/base

;;; snapshot.rkt — generate a StructureDefinition snapshot from its differential + parent.
;;;
;;; A port of FHIR's ProfileUtilities-style algorithm (build.fhir.org/profiling.html):
;;;   - base = the parent's snapshot, re-rooted from the parent's type to this type;
;;;   - each differential element is matched to a base element by (path, sliceName) and merged
;;;     (the differential's set keys win); unmatched differential elements (specialization-added
;;;     children, or slices) are inserted in order under their parent;
;;;   - choice [x] constraints set `type` (the path stays value[x]); contentReference expands;
;;;   - each element gets `id` and `base` (origin path/min/max).
;;; Maximal-faithful is the target; residual fields are documented by the comparison test.
;;;
;;; An Element is an ElementDefinition jsexpr; a Result is the (listof Element) under construction,
;;; in snapshot order. Elements are found by id (`element-id`: the id, else the path — ids encode
;;; slices, `component:systolic.code`) or by (path, sliceName) (`find-elem`), and inserted after the
;;; last element of their parent's subtree (`insert-after-subtree`), so order is kept.

(require racket/list
         racket/string
         racket/contract
         "sd-index.rkt")

(provide
 (contract-out
  [generate-snapshot (-> hash? list?)]      ; an SD jsexpr -> its snapshot elements
  ;; the snapshot elements an SD carries (#f when it carries none: generate one)
  [shipped-snapshot  (-> hash? (or/c #f (listof hash?)))]
  ;; the framework types no snapshot describes usefully (Resource, Element, Extension, …)
  [opaque-type?      (-> string? boolean?)]
  [snapshot-paths    (-> list? list?)]))    ; elements -> their paths

;; sd-jsexpr -> (listof element-jsexpr)
(define (generate-snapshot sd)
  (define my-type (hash-ref sd 'type))
  (define base-url (hash-ref sd 'baseDefinition #f))
  (define diff (elements-of sd 'differential))
  (cond
    [(not base-url) diff]                       ; no parent (Base) -> differential is the snapshot
    [else
     (define parent (resolve-sd-raw base-url))
     (cond
       [(not parent) diff]                      ; parent unresolvable -> best effort
       [else
        (define base (reroot (snapshot-of parent) (hash-ref parent 'type) my-type))
        (expand-dived-datatypes (apply-differential base diff))])]))

;; ---- datatype expansion (ProfileUtilities' "walk into the datatype") ------------------------
;; Where a profile DIVES INTO a complex-typed element (constrains `Provenance.meta.profile`), the
;; reference snapshot carries that datatype's WHOLE element set re-rooted under the path
;; (Provenance.meta.id/.extension/.versionId/…), not just the constrained child. For every element
;; that (a) has exactly one complex type and (b) has at least one descendant in the result, fill in
;; the datatype's missing children. Fail-open: an unresolvable type expands to nothing.
;; iterated to a FIXED POINT: expanding `agent.who` (a Reference) exposes `agent.who.identifier`,
;; which the profile may itself have dived into and which must then expand as an Identifier
(define (expand-dived-datatypes elements0)
  (let loop ([elements elements0] [fuel 8])
    (define next (expand-once elements))
    (if (or (zero? fuel) (= (length next) (length elements))) next (loop next (sub1 fuel)))))

;; expand-once : Result -> Result   one round of the datatype expansion
(define (expand-once elements)
  ;; by ID, so a slice's children (`agent:X.role.coding`) expand under the slice, not the base
  (define dived                     ; ids the profile has descended into
    (for/fold ([s (hash)]) ([e (in-list elements)] #:when (string-contains? (element-id e) "."))
      (hash-set s (drop-last-segment (element-id e)) #t)))
  (for/fold ([result elements])
            ([e (in-list elements)]
             #:when (hash-ref dived (element-id e) #f))
    (define t (element-type-code e))
    (cond
      [(or (not t) (not (complex-datatype? t))) result]
      [else
       (define path (hash-ref e 'path))
       (define id (element-id e))
       (for/fold ([r result]) ([k (in-list (cdr (base-type-snapshot t)))]   ; cdr drops the type's root
                               ;; only DIRECT children — deeper levels appear only if dived into
                               #:when (and (direct-child? t (hash-ref k 'path "")) (not (hash-ref k 'sliceName #f))))
         (define seg (substring (hash-ref k 'path) (add1 (string-length t))))
         (define kid (hash-set* k 'path (string-append path "." seg) 'id (string-append id "." seg)))
         (define at (index-of-id r (hash-ref kid 'id)))
         (cond
           ;; the profile already constrains this child, but a DIFFERENTIAL element states only
           ;; what it changes — fill in the datatype's definition for every key it omits (notably
           ;; `type`, without which we could not dive further)
           [at (list-set r at (fill-missing (list-ref r at) kid))]
           [else (insert-under r id (with-base kid))]))])))

;; apply-slice-stub : result slice-id path -> result   a slice named only through its children
;; (`c:b.code` without `c:b`): the unsliced element's definition, optional, after the sliced element
(define (apply-slice-stub result id path)
  (define sliced (regexp-replace #rx":[^.:]+$" id ""))
  (define template (or (element-by-id result sliced) (hasheq)))
  (define el (hash-set* (hash-remove template 'slicing)
                        'id id 'path path 'sliceName (cadr (regexp-match #rx":([^.:]+)$" id)) 'min 0))
  (insert-under result sliced el))

;; ---- finding and placing elements -------------------------------------------------------------
;; element-id : Element -> String   the id, else the path (ids encode slices)
(define (element-id e) (hash-ref e 'id (lambda () (hash-ref e 'path ""))))
;; index-of-id : Result String -> Nat | #f ; element-by-id : Result String -> Element | #f
(define (index-of-id result id)
  (for/or ([e (in-list result)] [i (in-naturals)]) (and (equal? (element-id e) id) i)))
(define (element-by-id result id)
  (for/or ([e (in-list result)]) (and (equal? (hash-ref e 'id #f) id) e)))
;; drop-last-segment : String -> String   "A.b.c" -> "A.b" (an id or a path); a bare name stays
(define (drop-last-segment s)
  (define segs (string-split s "."))
  (if (> (length segs) 1) (string-join (drop-right segs 1) ".") s))

;; insert-after-subtree : Result (Element -> Boolean) Element -> Result
;; after the last element of the subtree `in?` recognises; at the end when there is none
(define (insert-after-subtree result in? el)
  (define pos (for/fold ([pos #f]) ([e (in-list result)] [i (in-naturals)]) (if (in? e) (add1 i) pos)))
  (if pos (append (take result pos) (list el) (drop result pos)) (append result (list el))))
;; insert-under : Result parent-id Element -> Result   under the parent's subtree BY ID (its
;; children and its slices)
(define (insert-under result parent el)
  (insert-after-subtree result
                        (lambda (e) (let ([x (element-id e)])
                                      (or (equal? x parent) (string-prefix? x (string-append parent "."))
                                          (string-prefix? x (string-append parent ":")))))
                        el))
;; insert-element : Result Element -> Result   under its parent's subtree BY PATH
(define (insert-element result d)
  (define parent (drop-last-segment (hash-ref d 'path)))
  (insert-after-subtree result
                        (lambda (e) (let ([p (hash-ref e 'path)])
                                      (or (string=? p parent) (string-prefix? p (string-append parent ".")))))
                        d))

;; fill-missing : Element Element -> Element   existing keys win; the datatype definition supplies the rest
(define (fill-missing e defn)
  (for/fold ([h e]) ([(k v) (in-hash defn)])
    (if (hash-has-key? h k) h (hash-set h k v))))

;; direct-child? : String String -> Boolean   is p one segment below parent?
(define (direct-child? parent p)
  (and (string-prefix? p (string-append parent "."))
       (not (string-contains? (substring p (add1 (string-length parent))) "."))))

;; a complex datatype resolves to an SD whose own snapshot has children (primitives/opaques don't)
(define (complex-datatype? t)
  (and (regexp-match? #px"^[A-Z]" t)
       (not (opaque-type? t))
       (pair? (base-type-snapshot t))))

;; opaque-type? : type-code -> boolean   a framework type: a jump into it finds nothing to check
(define opaque-types '("Resource" "DomainResource" "Element" "BackboneElement" "Extension"))
(define (opaque-type? code) (and (member code opaque-types) #t))

;; shipped-snapshot : SD -> (listof Element) | #f   the snapshot the SD carries, when it has elements
(define (shipped-snapshot sd)
  (define s (hash-ref sd 'snapshot #f))
  (define es (and (hash? s) (hash-ref s 'element #f)))
  (and (list? es) (pair? es) es))

;; snapshot-of : SD -> (listof Element)   a parent's snapshot, generated (recursively) when it ships none
(define (snapshot-of sd) (or (shipped-snapshot sd) (generate-snapshot sd)))

;; elements-of : SD 'snapshot|'differential -> (listof Element)
(define (elements-of sd key)
  (define o (hash-ref sd key #f))
  (if (hash? o) (hash-ref o 'element '()) '()))

;; -------------------------------------------------------------------
;; re-rooting (parent type prefix -> this type prefix)
;; -------------------------------------------------------------------
;; reroot : (listof Element) String String -> (listof Element)   the type prefix of path and id rewritten
(define (reroot elements from to)
  (for/list ([e (in-list elements)])
    (define e1 (hash-set e 'path (reroot-path (hash-ref e 'path) from to)))
    (if (hash-has-key? e1 'id)
        (hash-set e1 'id (reroot-path (hash-ref e1 'id) from to))
        e1)))

(define (reroot-path p from to)
  (cond [(string=? p from) to]
        [(string-prefix? p (string-append from ".")) (string-append to (substring p (string-length from)))]
        [else p]))

;; -------------------------------------------------------------------
;; apply the differential onto the (re-rooted) base snapshot
;; -------------------------------------------------------------------
;; apply-differential : Result (listof Element) -> Result   each differential element merged in or placed
(define (apply-differential base diff)
  (for/fold ([result base]) ([d (in-list diff)])
    (define idx (find-elem result (hash-ref d 'path) (hash-ref d 'sliceName #f)))
    (define id (hash-ref d 'id #f))
    (cond
      ;; an element INSIDE a slice (`component:a.code`) shares its path with the unsliced element
      ;; (`component.code`): it is matched by id, and a new one is the unsliced element's definition
      ;; overlaid by the diff, placed under its slice — never merged into the unsliced element
      [(and id (inside-slice? id)) (apply-in-slice result d id)]
      [idx (list-set result idx (merge-element (list-ref result idx) d))]
      ;; a named slice with no existing match: re-root from the base element at the same path so the
      ;; slice inherits the full base datatype definition (type/short/constraint), then overlay the diff
      [(and (hash-ref d 'sliceName #f) (base-elem-at result (hash-ref d 'path)))
       => (lambda (template)
            ;; a slice inherits the base element's definition, but NOT its min: a slice is
            ;; optional unless the differential says otherwise (the base's min constrains the
            ;; SUM over slices, not each one). Without this a slice of a required element would
            ;; be reported as itself required.
            (define merged (merge-element template d))
            (define sliced (if (hash-has-key? d 'min) merged (hash-set merged 'min 0)))
            (insert-element result (with-id sliced)))]
      [else
       ;; new element: insert it, then expand the inherited children of a BackboneElement/Element
       (define r1 (insert-element result (with-id (with-base d))))
       (for/fold ([r r1]) ([kid (in-list (backbone-children (hash-ref d 'path) (element-type-code d)))])
         (insert-element r (with-id (with-base kid))))])))

;; inside-slice? : id -> boolean   an ancestor segment of the id names a slice
(define (inside-slice? id)
  (define segs (string-split id "."))
  (for/or ([seg (in-list (drop-right segs 1))]) (regexp-match? #rx":" seg)))
(define (strip-slices id) (regexp-replace* #rx":[^.]+" id ""))

;; apply-in-slice : result diff-element id -> result
;; a differential may skip ancestors (`agent:X.who.identifier` without `agent:X.who`): those inside
;; the slice are created first, from the unsliced element, so the datatype expansion can descend
(define (apply-in-slice result0 d id)
  (define parent-id (drop-last-segment id))
  (define result
    (if (and (regexp-match? #rx":" parent-id) (not (element-by-id result0 parent-id)))
        (let ([pp (drop-last-segment (hash-ref d 'path))])
          (if (inside-slice? parent-id)
              (apply-in-slice result0 (hasheq 'id parent-id 'path pp) parent-id)
              (apply-slice-stub result0 parent-id pp)))
        result0))
  (define at (for/or ([e (in-list result)] [i (in-naturals)]) (and (equal? (hash-ref e 'id #f) id) i)))
  (cond
    [at (list-set result at (merge-element (list-ref result at) d))]
    [else
     (define template (or (element-by-id result (strip-slices id)) (with-base d)))
     (define merged (merge-element template d))
     ;; a slice (of a choice, a reslice) is optional unless the diff says otherwise
     (define el (if (and (hash-ref d 'sliceName #f) (not (hash-has-key? d 'min))) (hash-set merged 'min 0) merged))
     (insert-under result parent-id el)]))

;; the base (non-slice) element at `path` in the current result, or #f
(define (base-elem-at result path)
  (for/or ([e (in-list result)])
    (and (equal? (hash-ref e 'path) path) (not (hash-ref e 'sliceName #f)) e)))

;; the single FHIR type code of a differential element (or #f)
(define (element-type-code d)
  (define ts (hash-ref d 'type #f))
  (and (list? ts) (pair? ts) (hash-ref (car ts) 'code #f)))

;; the inherited child elements (id/extension[/modifierExtension]) for a BackboneElement or
;; Element-typed element, re-rooted under `path`
(define (backbone-children path type-code)
  (define base-type
    (cond [(equal? type-code "BackboneElement") "BackboneElement"]
          [(equal? type-code "Element") "Element"]
          [else #f]))
  (cond
    [(not base-type) '()]
    [else (reroot (cdr (base-type-snapshot base-type)) base-type path)]))   ; cdr drops the root

;; base-type-snapshot : type-code -> elements   the type's snapshot in the current package context
;; (keyed by the context too: R4 and R5 define the same codes differently, and a process — a server,
;; fhir-mcp, `fsh check` — can change packages between calls; keyed by the code alone, the first
;; context's snapshot was served to every later one)
(define base-type-cache (make-hash))
(define (base-type-snapshot t)
  (hash-ref! base-type-cache (cons (sd-context) t)
             (lambda ()
               (define sd (resolve-sd-raw t))
               (if sd (snapshot-of sd) '()))))

;; index of the element matching (path, sliceName), or #f
(define (find-elem result path slice)
  (for/or ([e (in-list result)] [i (in-naturals)])
    (and (string=? (hash-ref e 'path) path)
         (equal? (hash-ref e 'sliceName #f) slice)
         i)))

;; differential overrides the base for every key it sets; base keeps the rest. `constraint` is the
;; exception — a differential may add invariants without restating inherited ones, so it ACCUMULATES
;; (base ++ diff, order-preserving) rather than replacing.
(define (merge-element base diff)
  (for/fold ([b base]) ([(k v) (in-hash diff)])
    (if (and (eq? k 'constraint) (list? (hash-ref base 'constraint #f)))
        (hash-set b 'constraint (append (hash-ref base 'constraint) (if (list? v) v (list v))))
        (hash-set b k v))))

;; id defaults to the path (slices append :sliceName); base records the origin cardinality
;; with-id / with-base : Element -> Element
(define (with-id d)
  (if (hash-has-key? d 'id) d
      (hash-set d 'id (let ([p (hash-ref d 'path)] [s (hash-ref d 'sliceName #f)])
                        (if s (string-append p ":" s) p)))))
(define (with-base d)
  (if (hash-has-key? d 'base) d
      (hash-set d 'base (hasheq 'path (hash-ref d 'path)
                                'min (hash-ref d 'min 0) 'max (hash-ref d 'max "*")))))

;; -------------------------------------------------------------------
;; convenience: the ordered list of element paths (for tests/inspection)
;; -------------------------------------------------------------------
(define (snapshot-paths elements) (map (lambda (e) (hash-ref e 'path)) elements))

;; ── living examples: the pure merge mechanics on synthetic elements ──────────────────────────
(module+ test
  (require rackunit)
  ;; re-rooting rewrites the type prefix on path and id, and nothing else
  (check-equal? (reroot-path "Base" "Base" "MyProfile") "MyProfile")
  (check-equal? (reroot-path "Base.field" "Base" "MyProfile") "MyProfile.field")
  (check-equal? (reroot-path "Other.field" "Base" "MyProfile") "Other.field")
  ;; merge: differential keys WIN, base keeps the rest...
  (check-equal? (merge-element (hasheq 'path "T.a" 'min 0 'short "base")
                               (hasheq 'min 1))
                (hasheq 'path "T.a" 'min 1 'short "base"))
  ;; ...except constraint, which ACCUMULATES (inherited invariants are never lost)
  (check-equal? (hash-ref (merge-element (hasheq 'constraint (list (hasheq 'key "b-1")))
                                         (hasheq 'constraint (list (hasheq 'key "d-1"))))
                          'constraint)
                (list (hasheq 'key "b-1") (hasheq 'key "d-1")))
  ;; find-elem matches on (path, sliceName) — a slice never shadows its base element
  (define elems (list (hasheq 'path "T") (hasheq 'path "T.x")
                      (hasheq 'path "T.x" 'sliceName "s1")))
  (check-equal? (find-elem elems "T.x" #f) 1)
  (check-equal? (find-elem elems "T.x" "s1") 2)
  (check-false (find-elem elems "T.x" "s2"))
  ;; insertion lands AFTER the last element under the parent (snapshot order preserved)
  (check-equal? (snapshot-paths
                 (insert-element (list (hasheq 'path "T") (hasheq 'path "T.a") (hasheq 'path "T.z"))
                                 (hasheq 'path "T.a.kid")))
                '("T" "T.a" "T.a.kid" "T.z"))
  ;; ids default to path, slices to path:sliceName
  (check-equal? (hash-ref (with-id (hasheq 'path "T.x" 'sliceName "mrn")) 'id) "T.x:mrn")
  ;; end-to-end on a synthetic pair: re-root + override + slice inheriting the base template
  (define base-sd
    (hasheq 'type "T" 'url "urn:T"
            'snapshot (hasheq 'element (list (hasheq 'path "T" 'min 0 'max "*")
                                             (hasheq 'path "T.x" 'min 0 'max "*" 'short "the x")))))
  (define snap (apply-differential
                (reroot (hash-ref (hash-ref base-sd 'snapshot) 'element) "T" "P")
                (list (hasheq 'path "P.x" 'min 1)
                      (hasheq 'path "P.x" 'sliceName "s1" 'min 1))))
  (check-equal? (snapshot-paths snap) '("P" "P.x" "P.x"))
  ;; an element INSIDE a slice shares its path with the unsliced element but is its own element:
  ;; matched by id, built from the unsliced definition, placed under the slice (a missing in-slice
  ;; ancestor is created first) — the unsliced element is left alone
  (define in-slice
    (apply-differential
     (list (hasheq 'id "P" 'path "P") (hasheq 'id "P.c" 'path "P.c" 'max "*")
           (hasheq 'id "P.c.code" 'path "P.c.code" 'min 1 'max "1") (hasheq 'id "P.c.v" 'path "P.c.v" 'max "1"))
     (list (hasheq 'id "P.c:a" 'path "P.c" 'sliceName "a")
           (hasheq 'id "P.c:a.code" 'path "P.c.code" 'patternCode "x")
           (hasheq 'id "P.c:b.code" 'path "P.c.code" 'patternCode "y"))))
  (check-equal? (map (lambda (e) (hash-ref e 'id)) in-slice)
                '("P" "P.c" "P.c.code" "P.c.v" "P.c:a" "P.c:a.code" "P.c:b" "P.c:b.code"))
  (check-false (hash-ref (list-ref in-slice 2) 'patternCode #f))    ; the unsliced code is untouched
  (check-equal? (hash-ref (list-ref in-slice 5) 'min) 1)             ; inherited from P.c.code
  (check-equal? (hash-ref (cadr snap) 'min) 1)                      ; narrowed
  (check-equal? (hash-ref (cadr snap) 'short) "the x")              ; inherited
  (check-equal? (hash-ref (caddr snap) 'sliceName) "s1")
  (check-equal? (hash-ref (caddr snap) 'short) "the x")             ; slice inherits the base template
  ;; a datatype a profile dives into is expanded from the CURRENT package context: R5's Attachment
  ;; has `height`, R4's does not (the cache was keyed by the type code alone, so whichever version
  ;; came first was served to both)
  (define r4 ((dynamic-require 'fhir/spec-package 'spec-package-path) "hl7.fhir.r4.core.tgz" #:optional? #t))
  (define r5 ((dynamic-require 'fhir/spec-package 'spec-package-path) "hl7.fhir.r5.core.tgz" #:optional? #t))
  (when (and r4 r5)
    (define dives (hasheq 'resourceType "StructureDefinition" 'type "DocumentReference" 'derivation "constraint"
                          'baseDefinition "http://hl7.org/fhir/StructureDefinition/DocumentReference"
                          'differential (hasheq 'element (list (hasheq 'id "DocumentReference.content.attachment.url"
                                                                       'path "DocumentReference.content.attachment.url" 'min 1)))))
    (define (has-height? pkg)
      (parameterize ([current-sd-packages (list pkg)])
        (and (member "DocumentReference.content.attachment.height" (snapshot-paths (generate-snapshot dives))) #t)))
    (check-true (has-height? r5))
    (check-false (has-height? r4))
    (check-true (has-height? r5))))
