#lang racket/base

;;; to-json.rkt — a typed `fhir` node -> FHIR JSON.
;;;
;;; Two views, one traversal (over an internal "ejson" — jsexpr plus a `raw-num` marker for
;;; decimals):
;;;   node->jsexpr      : a standard jsexpr (decimals become Racket numbers — the structured view,
;;;                       lossy on trailing zeros; used for equality/tests).
;;;   node->json-string : precise JSON text (decimals emitted as raw number tokens, so "1.50" and
;;;                       exponents survive the write path).
;;;
;;; FHIR's primitive `_field` sibling is handled here: a primitive value carrying an `id`/`extension`
;;; emits a parallel `_field` object (for a list, a `_field` array aligned by index with `null`
;;; placeholders). Serialization is value-dispatched; the only schema consultation is the
;;; resourceType decision (a node whose registered parent is a resource parent gets a resourceType).

(require racket/contract
         (only-in json jsexpr? jsexpr->string)
         "../model/node.rkt"
         (only-in "../model/base.rkt" primitive-type? primitive-type-value element-id element-extension)
         (only-in "../model/schema.rkt" type-schema-parent resource-parent?)
         (only-in "../model/registry.rkt" type-schema-of)
         (only-in "../primitives/absent.rkt" absent?)
         (only-in "../primitives/primitives.rkt"
                  fhir-decimal? t-date? t-time? t-datetime? temporal->string))

(provide
 (contract-out
  [node->jsexpr      (-> fhir? jsexpr?)]
  [node->json-string (-> fhir? string?)]))

;; a decimal token to emit verbatim in JSON (its lexical string, e.g. "1.50")
(struct raw-num (lexeme) #:transparent)

;; ---- node -> ejson (the shared traversal) ----------------------------------------------------
(define (node->ejson n)
  (define t (fhir-type n))
  (define parent (let ([sch (type-schema-of t)]) (and sch (type-schema-parent sch))))
  (define seed (if (and parent (resource-parent? parent))
                   (hasheq 'resourceType (symbol->string t))
                   (hasheq)))
  (for/fold ([h seed]) ([(k v) (in-hash (fhir-fields n))])
    (define-values (main under) (field->ejson v))
    (let ([h1 (if (eq? main 'omit) h (hash-set h k main))])   ; a lone value-less primitive: no main key
      (if under (hash-set h1 (underscore-key k) under) h1))))

;; a field value -> (values main-ejson underscore-ejson-or-#f) ; main may be 'omit (drop the key).
(define (field->ejson v)
  (cond
    [(and (pair? v) (list? v) (primitive-type? (car v)))
     ;; FHIR permits omitting trailing nulls in the aligned _field array.
     (define unders (trim-trailing-null (map (lambda (p) (or (prim->underscore p) 'null)) v)))
     (values (map prim->ejson-value v)                       ; absent element -> 'null
             (and (ormap hash? unders) unders))]
    [(list? v)           (values (map value->ejson v) #f)]  ; list of nodes / raw
    [(and (primitive-type? v) (absent? (primitive-type-value v)))
     (values 'omit (or (prim->underscore v) 'null))]        ; value-less: only the _field
    [(primitive-type? v) (values (prim->ejson-value v) (prim->underscore v))]
    [(fhir? v)           (values (node->ejson v) #f)]
    [else                (values v #f)]))                    ; raw subtree kept verbatim

(define (value->ejson v)
  (cond
    [(list? v)           (map value->ejson v)]
    [(fhir? v)           (node->ejson v)]
    [(primitive-type? v) (prim->ejson-value v)]
    [else                v]))

;; a primitive's JSON scalar (ejson): absent -> 'null, temporal -> lexical string, decimal ->
;; raw-num, else the value.
(define (prim->ejson-value p)
  (define v (primitive-type-value p))
  (cond
    [(absent? v) 'null]
    [(fhir-decimal? p) (raw-num v)]
    [(or (t-date? v) (t-time? v) (t-datetime? v)) (temporal->string v)]
    [else v]))

;; a primitive's `_field` object, or #f if it carries neither id nor extension.
(define (prim->underscore p)
  (define id (element-id p))
  (define ext (element-extension p))
  (cond
    [(and (not id) (or (not ext) (null? ext))) #f]
    [else (let* ([h (hasheq)]
                 [h (if id (hash-set h 'id id) h)]
                 ;; extension is a list of typed Extension nodes (or raw jsexpr) -> serialize each
                 [h (if (and ext (pair? ext)) (hash-set h 'extension (map value->ejson ext)) h)])
            h)]))

(define (underscore-key k) (string->symbol (string-append "_" (symbol->string k))))

;; drop trailing 'null entries from an aligned _field array
(define (trim-trailing-null xs)
  (reverse (let loop ([r (reverse xs)]) (if (and (pair? r) (eq? (car r) 'null)) (loop (cdr r)) r))))

;; ---- the two views --------------------------------------------------------------------------
(define (node->jsexpr n) (ejson->jsexpr (node->ejson n)))

;; ejson -> standard jsexpr: a decimal raw-num collapses to a Racket number (lossy on trailing 0s).
(define (ejson->jsexpr e)
  (cond
    [(raw-num? e) (string->number (raw-num-lexeme e))]
    [(list? e)    (map ejson->jsexpr e)]
    [(hash? e)    (for/hasheq ([(k v) (in-hash e)]) (values k (ejson->jsexpr v)))]
    [else e]))

(define (node->json-string n) (write-ejson (node->ejson n)))

;; write ejson as JSON text; raw-num is emitted verbatim so decimal precision survives.
(define (write-ejson e)
  (define out (open-output-string))
  (let loop ([e e])
    (cond
      [(raw-num? e) (write-string (raw-num-lexeme e) out)]
      [(hash? e)
       (write-string "{" out)
       (for ([(k v) (in-hash e)] [i (in-naturals)])
         (when (> i 0) (write-string "," out))
         (write-string (jsexpr->string (symbol->string k)) out)
         (write-string ":" out)
         (loop v))
       (write-string "}" out)]
      [(list? e)
       (write-string "[" out)
       (for ([v (in-list e)] [i (in-naturals)])
         (when (> i 0) (write-string "," out))
         (loop v))
       (write-string "]" out)]
      [else (write-string (jsexpr->string e) out)]))   ; string/number/bool/null via json
  (get-output-string out))
