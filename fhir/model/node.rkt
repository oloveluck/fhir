#lang racket/base

;;; node.rkt — the canonical in-memory FHIR value: a single generic typed node.
;;;
;;; The pivotal design decision (see the plan): rather than stroma's "JSON jsexpr is the only
;;; value" or a per-type struct explosion, every FHIR value is ONE generic tagged record:
;;;
;;;   (fhir type fields)   type   : symbol       — the FHIR type name (e.g. 'Patient)
;;;                        fields : hasheq        — name(symbol) -> value | (listof value)
;;;
;;; A leaf value is a primitive newtype instance (fhir-date, fhir-string, …) or a raw string (for
;;; base `id`/`language`-style fields); a nested value is another `fhir` node. So every value
;;; carries its FHIR type tag — exactly what FHIRPath/CQL type operators (is/as/ofType), choice
;;; discrimination, and polymorphic navigation will need — while jsexpr becomes a *derived* view
;;; produced by the schema-driven serializer (serialize/to-json.rkt).
;;;
;;; A node may be LAZY (`lazy-fhir`, made by a lenient read — serialize/from-json.rkt): it holds a
;;; thunk that reads its fields from its JSON the first time `fhir-fields` asks, and its nested
;;; nodes are lazy in turn, so an expression that reads `subject.reference` reads two objects of
;;; the resource, not all of it. A lazy node is the node an eager read would make: the same fields
;;; once read, equal to it (`equal?` reads them), printed as it. What the read left out is recorded
;;; on the node (`fhir-drops`), and `fhir-read?` says whether its fields have been read.

(require racket/contract)

;; `unchecked` is the same bindings without their contracts, for the reader that makes every node
;; (serialize/from-json.rkt): `lazy-fhir`'s contract wraps the thunk it is given, a wrapper made and
;; called for each node read — a quarter of a view's time over thousands of resources.
(provide fhir fhir? fhir-type
         (contract-out
          #:unprotected-submodule unchecked
          [fhir-fields  (-> fhir? hash?)]                         ; the fields (read now, if lazy)
          [lazy-fhir    (-> symbol? (-> (values hash? list?)) fhir?)]
          [fhir-read?   (-> fhir? boolean?)]
          [fhir-drops   (-> fhir? list?)]
          [fhir-ref     (->* (fhir? symbol?) (any/c) any/c)]     ; a field value (or default)
          [fhir-has?    (-> fhir? symbol? boolean?)]
          [fhir-field-names (-> fhir? (listof symbol?))]))

;; A Node is (node type cell drops):
;;   type  : symbol
;;   cell  : hasheq — present fields only, each a value or a (listof value) — or a Pending, whose
;;           thunk answers (values fields Drops); it is replaced by the fields when read
;;   drops : Drops — (listof (cons key json)): the keys of the node's JSON the read left out, each
;;           with its JSON value (a `_key` sibling under its own key)
(struct pending (thunk))
(struct node (type [cell #:mutable] [drops #:mutable])
  #:property prop:equal+hash
  (list (lambda (a b recur) (and (eq? (node-type a) (node-type b)) (recur (fhir-fields a) (fhir-fields b))))
        (lambda (a recur) (+ (recur (node-type a)) (* 3 (recur (fhir-fields a)))))
        (lambda (a recur) (recur (fhir-fields a))))
  ;; printed as the transparent struct it was: #(struct:fhir Patient #hasheq(…)) written or
  ;; displayed, (fhir 'Patient '#hasheq(…)) printed
  #:property prop:custom-print-quotable 'never
  #:property prop:custom-write
  (lambda (n port mode)
    (cond
      [(memq mode '(#t #f))
       (define recur (if mode write display))
       (write-string "#(struct:fhir " port)
       (recur (node-type n) port)
       (write-string " " port)
       (recur (fhir-fields n) port)
       (write-string ")" port)]
      [else
       (write-string "(fhir " port)
       (print (node-type n) port 0)
       (write-string " " port)
       (print (fhir-fields n) port 0)
       (write-string ")" port)])))

;; fhir : symbol hash -> Node   an eager node
(define (fhir type fields) (node type fields '()))
(define (fhir? v) (node? v))
(define (fhir-type n) (node-type n))
;; lazy-fhir : symbol (-> (values fields Drops)) -> Node   a node whose fields are read when asked
(define (lazy-fhir type thunk) (node type (pending thunk) '()))

;; fhir-fields : Node -> hash   (a lazy node's fields are read the first time, then kept)
(define (fhir-fields n)
  (define c (node-cell n))
  (cond [(pending? c)
         (define-values (fields drops) ((pending-thunk c)))
         (set-node-drops! n drops)
         (set-node-cell! n fields)
         fields]
        [else c]))
(define (fhir-read? n) (not (pending? (node-cell n))))
;; fhir-drops : Node -> Drops   what reading the node's fields left out (none for an eager node)
(define (fhir-drops n) (fhir-fields n) (node-drops n))

(define (fhir-ref n name [default #f])
  (hash-ref (fhir-fields n) name default))

(define (fhir-has? n name)
  (hash-has-key? (fhir-fields n) name))

(define (fhir-field-names n)
  (hash-keys (fhir-fields n)))

(module+ test
  (require rackunit)
  (define n (fhir 'HumanName (hasheq 'family "Chalmers" 'given '("Eve" "A"))))
  (check-equal? (fhir-type n) 'HumanName)
  (check-equal? (fhir-ref n 'family) "Chalmers")
  (check-equal? (fhir-ref n 'given) '("Eve" "A"))
  (check-equal? (fhir-ref n 'use 'none) 'none)
  (check-true   (fhir-has? n 'family))
  (check-false  (fhir-has? n 'use))
  ;; a lazy node is read once, when asked, and is then the eager node
  (define reads 0)
  (define l (lazy-fhir 'HumanName (lambda () (set! reads (add1 reads))
                                    (values (hasheq 'family "Chalmers" 'given '("Eve" "A")) (list (cons 'nmae "x"))))))
  (check-false (fhir-read? l))
  (check-equal? reads 0)
  (check-equal? l n)
  (check-equal? (equal-hash-code l) (equal-hash-code n))
  (check-true (fhir-read? l))
  (check-equal? (fhir-ref l 'family) "Chalmers")
  (check-equal? reads 1)
  (check-equal? (fhir-drops l) (list (cons 'nmae "x")))
  (check-equal? (fhir-drops n) '())
  (check-equal? (format "~s" l) (format "~s" n))
  (define one (fhir 'HumanName (hasheq 'family "C")))
  (check-equal? (format "~s" one) "#(struct:fhir HumanName #hasheq((family . \"C\")))")
  (check-equal? (format "~a" one) "#(struct:fhir HumanName #hasheq((family . C)))")
  (check-equal? (format "~v" one) "(fhir 'HumanName '#hasheq((family . \"C\")))")
  (check-equal? (format "~v" (list one)) "(list (fhir 'HumanName '#hasheq((family . \"C\"))))"))
