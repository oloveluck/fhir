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

(require racket/list
         racket/string
         racket/contract
         "sd-index.rkt")

(provide
 (contract-out
  [generate-snapshot (-> hash? list?)]      ; an SD jsexpr -> its snapshot elements
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

(define (expand-once elements)
  ;; by ID, so a slice's children (`agent:X.role.coding`) expand under the slice, not the base
  (define (eid e) (hash-ref e 'id (lambda () (hash-ref e 'path ""))))
  (define dived                     ; ids the profile has descended into
    (for/fold ([s (hash)]) ([e (in-list elements)])
      (define id (eid e))
      (define dot (for/last ([c (in-string id)] [i (in-naturals)] #:when (char=? c #\.)) i))
      (if dot (hash-set s (substring id 0 dot) #t) s)))
  (for/fold ([result elements])
            ([e (in-list elements)]
             #:when (hash-ref dived (eid e) #f))
    (define t (element-type-code e))
    (cond
      [(or (not t) (not (complex-datatype? t))) result]
      [else
       (define path (hash-ref e 'path))
       (define id (eid e))
       (for/fold ([r result]) ([k (in-list (cdr (base-type-snapshot t)))]   ; cdr drops the type's root
                               ;; only DIRECT children — deeper levels appear only if dived into
                               #:when (and (direct-child? t (hash-ref k 'path "")) (not (hash-ref k 'sliceName #f))))
         (define seg (substring (hash-ref k 'path) (add1 (string-length t))))
         (define kid (hash-set* k 'path (string-append path "." seg) 'id (string-append id "." seg)))
         (define at (for/or ([x (in-list r)] [i (in-naturals)]) (and (equal? (eid x) (hash-ref kid 'id)) i)))
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
  (define template (or (for/or ([e (in-list result)]) (and (equal? (hash-ref e 'id #f) sliced) e)) (hasheq)))
  (define el (hash-set* (hash-remove template 'slicing)
                        'id id 'path path 'sliceName (cadr (regexp-match #rx":([^.:]+)$" id)) 'min 0))
  (insert-under result sliced el))

;; insert-under : result parent-id element -> result   after the last element of the parent's subtree
;; (its children and its slices)
(define (insert-under result parent el)
  (define pos (for/fold ([pos #f]) ([e (in-list result)] [i (in-naturals)])
                (define x (hash-ref e 'id (lambda () (hash-ref e 'path ""))))
                (if (or (equal? x parent) (string-prefix? x (string-append parent "."))
                        (string-prefix? x (string-append parent ":")))
                    (add1 i) pos)))
  (if pos (append (take result pos) (list el) (drop result pos)) (append result (list el))))

;; existing keys win; the datatype definition supplies the rest
(define (fill-missing e defn)
  (for/fold ([h e]) ([(k v) (in-hash defn)])
    (if (hash-has-key? h k) h (hash-set h k v))))

(define (direct-child? parent p)
  (and (string-prefix? p (string-append parent "."))
       (not (string-contains? (substring p (add1 (string-length parent))) "."))))

;; a complex datatype resolves to an SD whose own snapshot has children (primitives/opaques don't)
(define (complex-datatype? t)
  (and (regexp-match? #px"^[A-Z]" t)
       (not (member t '("Resource" "DomainResource" "Element" "BackboneElement" "Extension")))
       (pair? (base-type-snapshot t))))

;; a parent's snapshot, generating it recursively if absent
(define (snapshot-of sd)
  (define s (elements-of sd 'snapshot))
  (if (pair? s) s (generate-snapshot sd)))

(define (elements-of sd key)
  (define o (hash-ref sd key #f))
  (if (hash? o) (hash-ref o 'element '()) '()))

;; -------------------------------------------------------------------
;; re-rooting (parent type prefix -> this type prefix)
;; -------------------------------------------------------------------
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
  (define parent-id (string-join (drop-right (string-split id ".") 1) "."))
  (define result
    (if (and (regexp-match? #rx":" parent-id)
             (not (for/or ([e (in-list result0)]) (equal? (hash-ref e 'id #f) parent-id))))
        (let ([pp (string-join (drop-right (string-split (hash-ref d 'path) ".") 1) ".")])
          (if (inside-slice? parent-id)
              (apply-in-slice result0 (hasheq 'id parent-id 'path pp) parent-id)
              (apply-slice-stub result0 parent-id pp)))
        result0))
  (define at (for/or ([e (in-list result)] [i (in-naturals)]) (and (equal? (hash-ref e 'id #f) id) i)))
  (cond
    [at (list-set result at (merge-element (list-ref result at) d))]
    [else
     (define template (or (for/or ([e (in-list result)]) (and (equal? (hash-ref e 'id #f) (strip-slices id)) e))
                          (with-base d)))
     (define merged (merge-element template d))
     ;; a slice (of a choice, a reslice) is optional unless the diff says otherwise
     (define el (if (and (hash-ref d 'sliceName #f) (not (hash-has-key? d 'min))) (hash-set merged 'min 0) merged))
     (insert-under result (string-join (drop-right (string-split id ".") 1) ".") el)]))

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

(define base-type-cache (make-hash))
(define (base-type-snapshot t)
  (hash-ref! base-type-cache t
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

;; insert a new element after the last existing element under its parent path (keeps order)
(define (insert-element result d)
  (define parent (parent-path (hash-ref d 'path)))
  (define pos
    (for/fold ([pos #f]) ([e (in-list result)] [i (in-naturals)])
      (define p (hash-ref e 'path))
      (if (or (string=? p parent) (string-prefix? p (string-append parent ".")))
          (add1 i) pos)))
  (cond [pos (append (take result pos) (list d) (drop result pos))]
        [else (append result (list d))]))

(define (parent-path p)
  (define segs (string-split p "."))
  (if (> (length segs) 1) (string-join (reverse (cdr (reverse segs))) ".") p))

;; id defaults to the path (slices append :sliceName); base records the origin cardinality
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
  (check-equal? (hash-ref (caddr snap) 'short) "the x"))            ; slice inherits the base template
