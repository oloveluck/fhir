#lang racket/base

;;; node-build.rkt — the runtime sink a compiled form macro reduces to.
;;;
;;; A generated form macro (lang-gen/form-syntax.rkt) validates its s-expression tree at compile
;;; time and expands to `(node-build 'Type (list (list 'field 'kind (list v …)) …))`, where each v
;;; has ALREADY been produced: primitive leaves via `build-prim` (a validated newtype instance),
;;; nested datatype/resource forms via their own macros (a `fhir` node). So node-build is pure
;;; structural assembly by cardinality — the typed dual of stroma's jsexpr `kernel-build`.

(require racket/contract
         racket/match
         "../model/node.rkt"
         "../result/result.rkt"
         (only-in "../model/registry.rkt" constructor-of)
         ;; loading the catalogue registers every primitive constructor for `build-prim`.
         (only-in "../primitives/primitives.rkt"))

(provide
 (contract-out
  ;; node-build : type fields -> fhir
  ;;   fields : (listof (list field-name kind values)) ; kind ∈ {single optional list}.
  [node-build (-> symbol? (listof list?) fhir?)]
  ;; build-prim : primitive-code raw -> a validated primitive newtype instance (raises on error;
  ;;   compile-time literal checks make that unreachable for literals, but runtime values still
  ;;   validate here).
  [build-prim (-> string? any/c any/c)]))

(define (node-build type fields)
  (for/fold ([n (fhir type (hasheq))]) ([f (in-list fields)])
    (match-define (list fname kind vals) f)
    (node-add n fname kind vals)))

;; node-add : fhir field-name kind (listof value) -> fhir
;; Put one field's value(s) into the node, by cardinality. An absent optional/list field (no
;; values) is omitted; a list field keeps the array; a single/optional takes the one value.
(define (node-add n fname kind vals)
  (define flds (fhir-fields n))
  (match* (kind vals)
    [(_ '())          n]
    [('list _)        (fhir (fhir-type n) (hash-set flds fname vals))]
    [(_ (cons v _))   (fhir (fhir-type n) (hash-set flds fname v))]))

(define (build-prim code raw)
  (define ctor (constructor-of (string->symbol code)))
  (unless ctor (error 'build-prim "no primitive constructor registered for ~a" code))
  (ok-or-raise (ctor raw)))

(module+ test
  (require rackunit
           (only-in "../primitives/primitives.rkt" fhir-string? primitive->jsexpr))
  ;; a datatype node: single + list fields, absent omitted
  (define hn (node-build 'HumanName
                         (list (list 'family 'single (list (build-prim "string" "Chalmers")))
                               (list 'given 'list (list (build-prim "string" "Eve")
                                                        (build-prim "string" "A")))
                               (list 'use 'optional '()))))
  (check-equal? (fhir-type hn) 'HumanName)
  (check-equal? (primitive->jsexpr (fhir-ref hn 'family)) "Chalmers")
  (check-equal? (map primitive->jsexpr (fhir-ref hn 'given)) '("Eve" "A"))
  (check-false  (fhir-has? hn 'use))
  ;; build-prim validates
  (check-true (fhir-string? (build-prim "string" "x")))
  (check-exn exn:fail? (lambda () (build-prim "positiveInt" 0))))
