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
;;;
;;; A lazy node may also be read A FIELD AT A TIME (a Reader, below): `fhir-ref` and `fhir-has?`
;;; then read the one field asked for, and the rest of the node's JSON is left as it is until
;;; `fhir-fields` (or anything that needs them all: equality, printing, writing it back) asks. A
;;; view that takes two of an Observation's elements parsed all of them — the status, the code,
;;; the date — for every resource; it reads the two now.

(require racket/contract)

;; `unchecked` is the same bindings without their contracts, for the reader that makes every node
;; (serialize/from-json.rkt): `lazy-fhir`'s contract wraps the thunk it is given, a wrapper made and
;; called for each node read — a quarter of a view's time over thousands of resources.
(provide fhir fhir? fhir-type
         (contract-out
          #:unprotected-submodule unchecked
          [fhir-fields  (-> fhir? hash?)]                         ; the fields (read now, if lazy)
          [lazy-fhir    (-> symbol? (or/c reader? (-> (values hash? list?))) fhir?)]
          [fhir-read?   (-> fhir? boolean?)]
          [fhir-drops   (-> fhir? list?)]
          ;; the fields read so far (all of them once the node is read), and what reading THOSE
          ;; left out: what a caller that asks "what did this expression read and not get" walks
          [fhir-fields-read (-> fhir? hash?)]
          [fhir-drops-read  (-> fhir? list?)]
          ;; make-reader : all one read drops -> Reader   (see the data definition)
          [make-reader (-> (-> (values hash? list?)) (-> symbol? any/c) (-> hash?) (-> list?) reader?)]
          [reader?      (-> any/c boolean?)]
          ;; no-field : what a Reader's `one` answers for a field the node does not hold
          [no-field     symbol?]
          [fhir-ref     (->* (fhir? symbol?) (any/c) any/c)]     ; a field value (or default)
          [fhir-has?    (-> fhir? symbol? boolean?)]
          [fhir-field-names (-> fhir? (listof symbol?))]))

;; A Node is (node type cell drops):
;;   type  : symbol
;;   cell  : hasheq — present fields only, each a value or a (listof value) — or a Pending, whose
;;           thunk answers (values fields Drops); it is replaced by the fields when read
;;   drops : Drops — (listof (cons key json)): the keys of the node's JSON the read left out, each
;;           with its JSON value (a `_key` sibling under its own key)
;; A Pending is (pending how): how is a thunk answering (values fields Drops), or a Reader.
;; A Reader is (reader all one read drops), four procedures over one node's JSON:
;;   all   : -> (values fields Drops)   every field, and what reading them left out
;;   one   : symbol -> value | no-field one field alone (answered the same however often asked)
;;   read  : -> hasheq                  the fields `one` has read so far
;;   drops : -> Drops                   what `one` left out so far
;; `all` answers, for a field `one` has read, the very value `one` answered.
(struct pending (thunk))
(struct reader (all one read drops))
(define (make-reader all one read drops) (reader all one read drops))
(define no-field (string->uninterned-symbol "no-field"))
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
         (define how (pending-thunk c))
         (define-values (fields drops) (if (reader? how) ((reader-all how)) (how)))
         (set-node-drops! n drops)
         (set-node-cell! n fields)
         fields]
        [else c]))
(define (fhir-read? n) (not (pending? (node-cell n))))
;; fhir-drops : Node -> Drops   what reading the node's fields left out (none for an eager node)
(define (fhir-drops n) (fhir-fields n) (node-drops n))

;; field-reader : Node -> (symbol -> value | no-field) | #f   how one field is read alone, for a node
;; that is not read yet and can be read so
(define (field-reader n)
  (define c (node-cell n))
  (and (pending? c) (let ([how (pending-thunk c)]) (and (reader? how) (reader-one how)))))

(define (fhir-ref n name [default #f])
  (define one (field-reader n))
  (if one
      (let ([v (one name)]) (if (eq? v no-field) default v))
      (hash-ref (fhir-fields n) name default)))

(define (fhir-has? n name)
  (define one (field-reader n))
  (if one
      (not (eq? (one name) no-field))
      (hash-has-key? (fhir-fields n) name)))

(define (fhir-fields-read n)
  (define c (node-cell n))
  (cond [(not (pending? c)) c]
        [(reader? (pending-thunk c)) ((reader-read (pending-thunk c)))]
        [else (hasheq)]))
(define (fhir-drops-read n)
  (define c (node-cell n))
  (cond [(not (pending? c)) (node-drops n)]
        [(reader? (pending-thunk c)) ((reader-drops (pending-thunk c)))]
        [else '()]))

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
  ;; a node read a field at a time: one field is read when asked, the rest when all are
  (let ()
    (define asked '())
    (define seen (make-hasheq))
    (define json (hasheq 'family "Chalmers" 'given '("Eve" "A")))
    (define (one name)
      (hash-ref! seen name (lambda () (set! asked (cons name asked)) (hash-ref json name no-field))))
    (define p (lazy-fhir 'HumanName
                         (make-reader (lambda () (set! asked (cons 'all asked)) (values json (list (cons 'nmae "x"))))
                                      one
                                      (lambda () (for/hasheq ([(k v) (in-hash seen)] #:unless (eq? v no-field)) (values k v)))
                                      (lambda () '()))))
    (check-equal? (fhir-fields-read p) (hasheq))
    (check-equal? (fhir-ref p 'family) "Chalmers")
    (check-equal? (fhir-ref p 'family) "Chalmers")
    (check-equal? (fhir-ref p 'use 'none) 'none)
    (check-true (fhir-has? p 'given))
    (check-false (fhir-has? p 'use))
    (check-false (fhir-read? p))
    (check-equal? (reverse asked) '(family use given))
    (check-equal? (fhir-fields-read p) json)
    (check-equal? (fhir-drops-read p) '())
    ;; anything that needs every field reads them all, once
    (check-equal? p n)
    (check-true (fhir-read? p))
    (check-equal? (reverse asked) '(family use given all))
    (check-equal? (fhir-ref p 'family) "Chalmers")
    (check-equal? (fhir-drops p) (list (cons 'nmae "x")))
    (check-equal? (fhir-drops-read p) (list (cons 'nmae "x")))
    (check-equal? (fhir-fields-read p) json)
    (check-equal? (length asked) 4))
  ;; a node made eagerly, or lazily by a thunk, has read all or nothing
  (check-equal? (fhir-fields-read n) (fhir-fields n))
  (check-equal? (fhir-fields-read (lazy-fhir 'HumanName (lambda () (values (hasheq) '())))) (hasheq))
  (define one (fhir 'HumanName (hasheq 'family "C")))
  (check-equal? (format "~s" one) "#(struct:fhir HumanName #hasheq((family . \"C\")))")
  (check-equal? (format "~a" one) "#(struct:fhir HumanName #hasheq((family . C)))")
  (check-equal? (format "~v" one) "(fhir 'HumanName '#hasheq((family . \"C\")))")
  (check-equal? (format "~v" (list one)) "(list (fhir 'HumanName '#hasheq((family . \"C\"))))"))
