#lang racket/base

;;; serialize-extras-test.rkt — the FHIR JSON quirks: precision-preserving decimals and the
;;; primitive `_field` (id/extension) sibling, both directions.

(require rackunit
         racket/string
         fhir/model/node
         fhir/model/schema
         fhir/model/registry
         fhir/result/result
         fhir/serialize/to-json
         fhir/serialize/from-json
         (only-in fhir/serialize/read-json string->fhir-jsexpr)
         fhir/r6/types                       ; registers HumanName/Extension schemas + macros
         (only-in fhir/model/base element-extension)
         (only-in fhir/primitives/primitives make-string make-decimal))

;; ================= decimals =================
;; a tiny type with a decimal field (Quantity-like), registered so from-json can parse it.
(define Q-URL "https://build.fhir.org/datatypes.html#Quantity")
(register-type! 'Qty (fhir-spec 'Qty Q-URL 'type)
  #:schema (type-schema 'Qty #f 'DataType Q-URL
             (list (schema-field 'value 0 1 #(prim "decimal") #f (string-append Q-URL ".value") #f)
                   (schema-field 'unit  0 1 #(prim "string")  #f (string-append Q-URL ".unit")  #f))
             #f #f))

(define q (fhir 'Qty (hasheq 'value (ok-value (make-decimal "1.50"))
                             'unit  (ok-value (make-string "mg")))))

;; the model preserves the lexical form, and the precise text view emits a RAW number token.
(check-true (string-contains? (node->json-string q) "\"value\":1.50"))
;; the structured jsexpr view is a Racket number (lossy on trailing zeros — documented).
(check-equal? (hash-ref (node->jsexpr q) 'value) 1.5)

;; read: a decimal given as a JSON string is preserved exactly; as a JSON number it is value-kept.
(check-equal? (result-map (lambda (n) (fhir-ref n 'value))
                          (from-json (hasheq 'value "1.50" 'unit "mg") #:type 'Qty))
              (ok (ok-value (make-decimal "1.50"))))
(check-equal? (result-map node->json-string (from-json (hasheq 'value "1.50" 'unit "mg") #:type 'Qty))
              (ok (node->json-string q)))

;; ================= primitive _field (id / TYPED extension) =================
;; the extension is a typed Extension node (not raw jsexpr), authored via the R6 Extension macro.
(define ext (list (Extension (url "http://example.org/x") (valueString "hi"))))
(define ext-json (list (hasheq 'url "http://example.org/x" 'valueString "hi")))
(define fam (ok-value (make-string "Chalmers" #:id "fam1")))
(define g1  (ok-value (make-string "Eve" #:id "n1" #:extension ext)))
(define g2  (ok-value (make-string "A")))
(define hn  (fhir 'HumanName (hasheq 'family fam 'given (list g1 g2))))

(define j (node->jsexpr hn))
;; the id sits in the parallel _field object; a list gets a _field array with a null placeholder.
(check-equal? (hash-ref j 'family) "Chalmers")
(check-equal? (hash-ref j '_family) (hasheq 'id "fam1"))
(check-equal? (hash-ref j 'given) '("Eve" "A"))
(check-equal? (hash-ref j '_given) (list (hasheq 'id "n1" 'extension ext-json)))  ; trailing null trimmed

;; round-trip: id + TYPED extension survive; the parsed extension is a typed Extension fhir node.
(check-equal? (from-json j #:type 'HumanName) (ok hn))
(check-equal? (fhir-type (car (element-extension g1))) 'Extension)

;; ================= precision-preserving decimal READ =================
;; a decimal read from JSON text keeps its exact lexeme (trailing zero survives).
(check-equal? (result-map (lambda (n) (fhir-ref n 'value))
                          (from-json (string->fhir-jsexpr "{\"value\":1.50,\"unit\":\"mg\"}")
                                     #:type 'Qty))
              (ok (ok-value (make-decimal "1.50"))))
(check-equal? (result-map node->json-string
                          (from-json (string->fhir-jsexpr "{\"value\":1.50,\"unit\":\"mg\"}")
                                     #:type 'Qty))
              (ok (node->json-string q)))

;; ================= value-less primitives (_field with no value) =================
;; single: only id/extension, no value key
(define vl1 (hasheq 'resourceType "Patient" '_birthDate (hasheq 'id "abc")))
(check-equal? (result-map node->jsexpr (from-json vl1)) (ok vl1))
;; list: a null value slot aligned with a _field entry
(define vl2 (hasheq 'given (list "Eve" 'null) '_given (list 'null (hasheq 'id "n2"))))
(check-equal? (result-map node->jsexpr (from-json vl2 #:type 'HumanName)) (ok vl2))
