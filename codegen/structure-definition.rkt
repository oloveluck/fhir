#lang racket/base

;;; structure-definition.rkt — the StructureDefinition + ElementDefinition models.
;;;
;;; The profiling/typing "language" of FHIR: a StructureDefinition describes a type as an ordered
;;; list of ElementDefinitions (its snapshot). We model the header fields plus a trimmed projection
;;; of each element (path, cardinality, declared types, base path, content reference) — enough for
;;; the codegen to nest, expand, and emit.

(require racket/contract racket/string)

(provide (struct-out structure-definition)
         (struct-out element-definition)
         (contract-out
          [jsexpr->structure-definition (-> hash? structure-definition?)]
          [jsexpr->element-definition    (-> hash? element-definition?)]))

(struct structure-definition
  (url name kind type abstract? base-definition derivation elements)
  #:transparent)

(define (jsexpr->structure-definition js)
  (define snapshot (hash-ref js 'snapshot (hasheq)))
  (define raw-elements (hash-ref snapshot 'element '()))
  (structure-definition
   (hash-ref js 'url)
   (hash-ref js 'name)
   (hash-ref js 'kind #f)
   (hash-ref js 'type #f)
   (hash-ref js 'abstract #f)
   (hash-ref js 'baseDefinition #f)
   (hash-ref js 'derivation #f)
   (map jsexpr->element-definition raw-elements)))

;; path  : string  e.g. "Patient.name"
;; min   : exact-nonnegative-integer
;; max   : string  "0" | "1" | "*" | "n"
;; types : (listof string)  type codes, e.g. '("HumanName")
;; short : documentation string (or #f)
;; base-path : string|#f  the path this element was first defined at (for own-field detection)
;; content-reference : string|#f  e.g. "#Questionnaire.item" (recursive reuse)
;; binding : (cons strength-string vs-url)|#f  the terminology binding (url stripped of |version)
(struct element-definition
  (path min max types short base-path content-reference binding)
  #:transparent)

(define (jsexpr->element-definition js)
  (define ts (hash-ref js 'type '()))
  (element-definition
   (hash-ref js 'path)
   (hash-ref js 'min 0)
   (hash-ref js 'max "*")
   (filter values (for/list ([t (in-list ts)]) (hash-ref t 'code #f)))  ; some type[] entries omit code
   (hash-ref js 'short #f)
   (let ([b (hash-ref js 'base #f)]) (and (hash? b) (hash-ref b 'path #f)))
   (hash-ref js 'contentReference #f)
   (element-binding js)))

;; the element's terminology binding: (cons strength url-without-version) or #f
(define (element-binding js)
  (define b (hash-ref js 'binding #f))
  (define strength (and (hash? b) (hash-ref b 'strength #f)))
  (define vs (and (hash? b) (hash-ref b 'valueSet #f)))
  (and (string? strength) (string? vs)
       (cons strength (car (string-split vs "|")))))
