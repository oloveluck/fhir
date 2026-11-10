#lang racket/base

;;; fhir-json.rkt — FHIR JSON text as FHIR writes it: `resourceType` first, then `id` and `meta`, the
;;; other keys after them (a hash has no order, so `write-json` put `resourceType` wherever the hash
;;; did — last, often, which is not where a FHIR reader looks). Optionally indented.
;;;
;;;   (fhir-json->string (hasheq 'gender "female" 'resourceType "Patient" 'id "a"))
;;;   => "{\"resourceType\":\"Patient\",\"id\":\"a\",\"gender\":\"female\"}"

(require racket/contract racket/list racket/string json)

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

;; fhir-json->string : a structural recursion over the jsexpr: objects in key-order, arrays in order,
;; scalars as `jsexpr->string` writes them
(define (fhir-json->string v #:indent [indent #f])
  (define (pad depth) (if indent (string-append "\n" (make-string (* indent depth) #\space)) ""))
  (define sep (if indent ": " ":"))
  (let loop ([v v] [depth 0])
    (cond
      [(hash? v)
       (if (zero? (hash-count v)) "{}"
           (string-append
            "{"
            (string-join (for/list ([k (in-list (key-order (hash-keys v)))])
                           (string-append (pad (add1 depth)) (jsexpr->string (symbol->string k)) sep
                                          (loop (hash-ref v k) (add1 depth))))
                         ",")
            (pad depth) "}"))]
      [(list? v)
       (if (null? v) "[]"
           (string-append "["
                          (string-join (for/list ([x (in-list v)]) (string-append (pad (add1 depth)) (loop x (add1 depth)))) ",")
                          (pad depth) "]"))]
      [else (jsexpr->string v)])))

(define (write-fhir-json v [out (current-output-port)] #:indent [indent #f])
  (write-string (fhir-json->string v #:indent indent) out)
  (void))

(module+ test
  (require rackunit)
  (define p (hasheq 'gender "female" 'resourceType "Patient" 'id "a" 'meta (hasheq 'versionId "1")
                    'name (list (hasheq 'given (list "Ann") 'family "Ng"))))
  (check-equal? (fhir-json->string p)
                "{\"resourceType\":\"Patient\",\"id\":\"a\",\"meta\":{\"versionId\":\"1\"},\"gender\":\"female\",\"name\":[{\"family\":\"Ng\",\"given\":[\"Ann\"]}]}")
  (check-equal? (string->jsexpr (fhir-json->string p #:indent 2)) p)
  (check-regexp-match #rx"^{\n  \"resourceType\": \"Patient\",\n  \"id\": \"a\"," (fhir-json->string p #:indent 2))
  (check-equal? (fhir-json->string (hasheq)) "{}")
  (check-equal? (fhir-json->string '()) "[]"))
