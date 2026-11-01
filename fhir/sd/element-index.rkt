#lang racket/base

;;; element-index.rkt — fast lookups over a StructureDefinition snapshot's ElementDefinition list, the
;;; backbone of the validator's walk. From a snapshot we index elements by path and id, expose the
;;; direct children of a path (and the slices at a path), and resolve a type code to its own snapshot
;;; index (the "datatype jump") — resolving via the R5 core package and generating a snapshot on demand.
;;; `opaque-types` (Resource/Element/…) are not descended into.

(require racket/contract
         racket/string
         racket/list
         (only-in "sd-index.rkt" resolve-sd-raw)
         (only-in "snapshot.rkt" generate-snapshot))

(provide
 (contract-out
  [make-element-index (-> (listof hash?) element-index?)]
  [element-index?     (-> any/c boolean?)]
  [index-elements     (-> element-index? (listof hash?))]
  [index-root         (-> element-index? (or/c hash? #f))]
  [child-elements     (-> element-index? string? (listof hash?))]   ; direct, non-slice children of a path
  [slices-of          (-> element-index? string? (listof hash?))]   ; the named slices at a path
  [index-by-id        (-> element-index? string? (or/c hash? #f))]
  [type-index         (-> string? (or/c element-index? #f))]        ; a type code -> its snapshot index
  [opaque-type?       (-> string? boolean?)]))

(struct element-index (elements by-path by-id children slices) #:transparent)

(define (make-element-index elements)
  (define by-path (make-hash))       ; path -> first (non-slice) element at that path
  (define by-id (make-hash))
  (define children (make-hash))      ; parent-path -> reversed list of direct non-slice children
  (define slices (make-hash))        ; path -> reversed list of named slices
  (for ([e (in-list elements)])
    (define id (hash-ref e 'id #f))
    (when (and id (not (hash-has-key? by-id id))) (hash-set! by-id id e))
    (define p (hash-ref e 'path #f))
    (cond
      [(and p (hash-ref e 'sliceName #f)) (hash-update! slices p (lambda (l) (cons e l)) '())]
      [p
       (unless (hash-has-key? by-path p) (hash-set! by-path p e))
       (define dot (for/last ([c (in-string p)] [i (in-naturals)] #:when (char=? c #\.)) i))
       (when dot (hash-update! children (substring p 0 dot) (lambda (l) (cons e l)) '()))]))
  ;; freeze to forward-order immutable lists
  (element-index elements by-path by-id
                 (for/hash ([(k v) (in-hash children)]) (values k (reverse v)))
                 (for/hash ([(k v) (in-hash slices)]) (values k (reverse v)))))

(define (index-elements idx) (element-index-elements idx))
(define (index-by-id idx id) (hash-ref (element-index-by-id idx) id #f))

;; the root element (shortest path — the type itself)
(define (index-root idx)
  (define els (element-index-elements idx))
  (and (pair? els) (car els)))

;; direct non-slice children of `path`, in snapshot order — O(1) hash lookup
(define (child-elements idx path) (hash-ref (element-index-children idx) path '()))

;; the named slices declared at `path` — O(1) hash lookup
(define (slices-of idx path) (hash-ref (element-index-slices idx) path '()))

;; ---- type -> element-index (datatype jump), cached ------------------------------------------
(define opaque-types '("Resource" "DomainResource" "Element" "BackboneElement" "Extension"))
(define (opaque-type? code) (and (member code opaque-types) #t))

(define type-index-cache (make-hash))
(define (type-index code)
  (cond
    [(opaque-type? code) #f]
    [else
     (hash-ref! type-index-cache code
                (lambda ()
                  (define sd (resolve-sd-raw code))
                  (cond
                    [(not sd) #f]
                    [else
                     (define shipped (let ([s (hash-ref sd 'snapshot #f)]) (and (hash? s) (hash-ref s 'element #f))))
                     (define snap (if (and (list? shipped) (pair? shipped)) shipped (generate-snapshot sd)))
                     (and (list? snap) (pair? snap) (make-element-index snap))])))]))

(module+ test
  (require rackunit (only-in "sd-index.rkt" resolve-sd-raw))
  (define pat (make-element-index (hash-ref (hash-ref (resolve-sd-raw "Patient") 'snapshot) 'element)))
  (check-equal? (hash-ref (index-root pat) 'path) "Patient")
  (check-true (> (length (child-elements pat "Patient")) 10))
  (check-true (and (index-by-id pat "Patient.name") #t))
  ;; datatype jump: HumanName resolves to its own snapshot index
  (define hn (type-index "HumanName"))
  (check-true (and hn #t))
  (check-true (and (member "HumanName.family" (map (lambda (e) (hash-ref e 'path)) (child-elements hn "HumanName"))) #t))
  (check-false (type-index "BackboneElement")))       ; opaque -> not descended
