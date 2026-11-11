#lang racket/base

;;; fhir-json.rkt — FHIR JSON text as FHIR writes it: `resourceType` first, then the elements in
;;; the order the type defines them (a Quantity's value, comparator, unit, system, code; a `_x`
;;; right after its `x`) when a FHIR tower is registered, else `id` and `meta` and the rest by name
;;; (a hash has no order, so `write-json` put `resourceType` wherever the hash did — last, often,
;;; which is not where a FHIR reader looks). Optionally indented.
;;;
;;;   (fhir-json->string (hasheq 'gender "female" 'resourceType "Patient" 'id "a"))
;;;   => "{\"resourceType\":\"Patient\",\"id\":\"a\",\"gender\":\"female\"}"

(require racket/contract racket/list racket/string json
         (only-in "../model/registry.rkt" type-schema-of)
         (only-in "../model/introspect.rkt" full-field-specs)
         (only-in "../model/schema.rkt" field-spec? field-spec-name field-spec-ftype ftype-type? ftype-type-name))

(provide
 (contract-out
  ;; key-order : (listof symbol) -> (listof symbol)   resourceType, id, meta first; the rest by name
  [key-order (-> (listof symbol?) (listof symbol?))]
  ;; fhir-json->string : jsexpr [#:indent n|#f] -> string   compact, or indented by n spaces
  [fhir-json->string (->* (jsexpr?) (#:indent (or/c #f exact-nonnegative-integer?)) string?)]
  ;; write-fhir-json : jsexpr [out] [#:indent n|#f] -> void
  [write-fhir-json (->* (jsexpr?) (output-port? #:indent (or/c #f exact-nonnegative-integer?)) void?)]))

(define leading '(resourceType id meta))

(define (key-order ks)
  (append (filter (lambda (k) (memq k ks)) leading)
          (sort (filter (lambda (k) (not (memq k leading))) ks) symbol<?)))

;; A Layout is a hasheq key -> (cons position child-type|#f): a registered type's elements in their
;; defined order, with the type of each complex element (to lay out what it holds).
;; layout-of : symbol|#f -> Layout|#f   #f when no tower registers the type (the fallback order)
(define layouts (make-hasheq))
(define (layout-of type)
  (and type
       (hash-ref! layouts type
                  (lambda ()
                    (and (type-schema-of type)
                         (with-handlers ([exn:fail? (lambda (e) #f)])
                           (for/hasheq ([fs (in-list (full-field-specs type))] [i (in-naturals)]
                                        #:when (field-spec? fs))
                             (define ft (field-spec-ftype fs))
                             (values (field-spec-name fs) (cons i (and (ftype-type? ft) (ftype-type-name ft)))))))))))

;; typed-order : Layout (listof symbol) -> (listof symbol)   resourceType, the type's elements in
;; order (each `_x` after its `x`), then keys the type does not define, by name
(define (typed-order lay ks)
  (define (base k) (let ([s (symbol->string k)]) (if (and (> (string-length s) 1) (char=? (string-ref s 0) #\_)) (string->symbol (substring s 1)) k)))
  (define (pos k) (let ([e (hash-ref lay (base k) #f)]) (and e (car e))))
  (define-values (known unknown) (partition pos (remq 'resourceType ks)))
  (append (if (memq 'resourceType ks) '(resourceType) '())
          (sort known < #:key (lambda (k) (+ (* 2 (pos k)) (if (eq? k (base k)) 0 1))))
          (sort unknown symbol<?)))

;; fhir-json->string : a structural recursion over the jsexpr: objects in their type's order (the
;; resourceType's, else the type the enclosing element declares) or key-order, arrays in order,
;; scalars as `jsexpr->string` writes them
(define (fhir-json->string v #:indent [indent #f])
  (define (pad depth) (if indent (string-append "\n" (make-string (* indent depth) #\space)) ""))
  (define sep (if indent ": " ":"))
  (let loop ([v v] [depth 0] [type #f])
    (cond
      [(hash? v)
       (define rt (hash-ref v 'resourceType #f))
       (define lay (layout-of (if (string? rt) (string->symbol rt) type)))
       (if (zero? (hash-count v)) "{}"
           (string-append
            "{"
            (string-join (for/list ([k (in-list (if lay (typed-order lay (hash-keys v)) (key-order (hash-keys v))))])
                           (define child (and lay (let ([e (hash-ref lay k #f)]) (and e (cdr e)))))
                           (string-append (pad (add1 depth)) (jsexpr->string (symbol->string k)) sep
                                          (loop (hash-ref v k) (add1 depth) child)))
                         ",")
            (pad depth) "}"))]
      [(list? v)
       (if (null? v) "[]"
           (string-append "["
                          (string-join (for/list ([x (in-list v)]) (string-append (pad (add1 depth)) (loop x (add1 depth) type))) ",")
                          (pad depth) "]"))]
      [else (jsexpr->string v)])))

(define (write-fhir-json v [out (current-output-port)] #:indent [indent #f])
  (write-string (fhir-json->string v #:indent indent) out)
  (void))

(module+ test
  (require rackunit)
  (define p (hasheq 'gender "female" 'resourceType "Patient" 'id "a" 'meta (hasheq 'versionId "1")
                    'name (list (hasheq 'given (list "Ann") 'family "Ng"))))
  ;; (the tower the second test loads orders `name` before `gender`; without one, by name)
  (check-equal? (fhir-json->string p)
                "{\"resourceType\":\"Patient\",\"id\":\"a\",\"meta\":{\"versionId\":\"1\"},\"name\":[{\"family\":\"Ng\",\"given\":[\"Ann\"]}],\"gender\":\"female\"}")
  (check-equal? (key-order '(gender name meta resourceType)) '(resourceType meta gender name))
  (check-equal? (string->jsexpr (fhir-json->string p #:indent 2)) p)
  (check-regexp-match #rx"^{\n  \"resourceType\": \"Patient\",\n  \"id\": \"a\"," (fhir-json->string p #:indent 2))
  (check-equal? (fhir-json->string (hasheq)) "{}")
  (check-equal? (fhir-json->string '()) "[]"))

;; with a tower: each element in the order its type defines (a Quantity's value, unit, system, code;
;; a Patient's name before its gender; `_birthDate` right after `birthDate`)
(module+ test
  (require (only-in "../r5/schemas.rkt"))
  (define obs (hasheq 'resourceType "Observation" 'subject (hasheq 'reference "Patient/a") 'status "final"
                      'code (hasheq 'text "x")
                      'valueQuantity (hasheq 'code "mg/dL" 'system "http://unitsofmeasure.org" 'unit "mg/dL" 'value 1.1)
                      'id "o1" 'zzz 1))
  (check-equal? (fhir-json->string obs)
                (string-append "{\"resourceType\":\"Observation\",\"id\":\"o1\",\"status\":\"final\",\"code\":{\"text\":\"x\"},"
                               "\"subject\":{\"reference\":\"Patient/a\"},"
                               "\"valueQuantity\":{\"value\":1.1,\"unit\":\"mg/dL\",\"system\":\"http://unitsofmeasure.org\",\"code\":\"mg/dL\"},"
                               "\"zzz\":1}"))
  (check-equal? (fhir-json->string (hasheq 'resourceType "Patient" '_birthDate (hasheq 'id "x") 'birthDate "2000" 'gender "male"
                                           'name (list (hasheq 'given '("A") 'family "B"))))
                "{\"resourceType\":\"Patient\",\"name\":[{\"family\":\"B\",\"given\":[\"A\"]}],\"gender\":\"male\",\"birthDate\":\"2000\",\"_birthDate\":{\"id\":\"x\"}}"))
