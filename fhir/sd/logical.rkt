#lang racket/base

;;; logical.rkt — a StructureDefinition registered at RUN time.
;;;
;;; The towers register the core types when they load. A logical model (an IG's own data model, the
;;; FML tutorial's TLeft/TRight) is a StructureDefinition the towers never saw: this module reads its
;;; elements and registers the same kind of `type-schema` codegen would have emitted, so from-json,
;;; FHIRPath navigation, the validator and the languages treat its instances as typed nodes.
;;;
;;; register-structure-definition! : SD jsexpr [#:resolve] -> type symbol
;;;   the SD's `type` becomes a type; an element with children becomes a nested type named
;;;   <Type><Child> (as the towers name backbone elements); a child typed by another logical model
;;;   (type.profile, or a canonical as the code) is resolved (#:resolve: url -> SD | #f, by default the
;;;   current data source then the packages) and registered first. An already registered type is left
;;;   as it is (a profile adds no fields). Returns the type symbol.
;;; An ElementType is read as: a primitive code -> #(prim code); a FHIRPath System type -> its
;;; primitive; BackboneElement/Element with children -> the nested type; a registered complex type or
;;; resource -> #(type Name); Resource -> #(resource); anything else -> #(unknown).

(require racket/contract racket/list racket/string
         (only-in fhir/model/registry register-type! register-element! type-registered? primitive-name? fhir-spec)
         (only-in fhir/model/schema type-schema schema-field max-of)
         (only-in fhir/sd/sd-index resolve-sd-raw)
         (only-in fhir/data-source current-data-source data-source-all))

(provide (contract-out
          [register-structure-definition! (->* (hash?) (#:resolve (-> string? (or/c hash? #f))) (or/c symbol? #f))]
          ;; structure-definition-type : SD -> its type symbol (without registering)
          [structure-definition-type (-> hash? (or/c symbol? #f))]
          ;; resolve-structure-definition/data : url -> SD | #f   the current data source, then the packages
          [resolve-structure-definition/data (-> string? (or/c hash? #f))]))

(define (jref h k [d #f]) (if (hash? h) (hash-ref h k d) d))
(define (jlist h k) (let ([v (jref h k '())]) (if (list? v) v '())))

(define (structure-definition-type sd)
  (define t (jref sd 'type))
  (and (string? t) (string->symbol (last (string-split t "/")))))

(define (resolve-structure-definition/data url)
  (define u (car (regexp-split #rx"[|]" url)))
  (or (findf (lambda (sd) (equal? (jref sd 'url) u))
             ((data-source-all (current-data-source)) "StructureDefinition"))
      (resolve-sd-raw u)))

(define (register-structure-definition! sd #:resolve [resolve resolve-structure-definition/data])
  (define sym (structure-definition-type sd))
  (cond
    [(not sym) #f]
    [(type-registered? sym) sym]
    [else
     (define elements (let ([s (jref sd 'snapshot)] [d (jref sd 'differential)])
                        (or (and s (jlist s 'element)) (and d (jlist d 'element)) '())))
     (define root-path (if (pair? elements) (jref (car elements) 'path) (symbol->string sym)))
     ;; children : path -> the elements directly under it, in order
     (define children
       (for/fold ([h (hash)]) ([e (in-list elements)])
         (define p (jref e 'path))
         (define segs (string-split p "."))
         (if (> (length segs) 1)
             (hash-update h (string-join (drop-right segs 1) ".") (lambda (l) (append l (list e))) '())
             h)))
     (define url (jref sd 'url))
     (define logical? (equal? (jref sd 'kind) "logical"))
     (define (spec-url path) (format "~a#~a" (or url "") path))
     ;; register-node! : type-sym path parent-sym -> void   the type for the elements under `path`
     (define (register-node! tsym path parent)
       (define fields
         (append*
          (for/list ([e (in-list (hash-ref children path '()))])
            (define name (last (string-split (jref e 'path) ".")))
            (define min (let ([m (jref e 'min 0)]) (if (exact-nonnegative-integer? m) m 0)))
            (define max (max-of (let ([m (jref e 'max "1")]) (if (string? m) m "1"))))
            (define types (jlist e 'type))
            (cond
              ;; a choice element: one field per type, keyed value<Type>
              [(regexp-match? #rx"\\[x\\]$" name)
               (define base (substring name 0 (- (string-length name) 3)))
               (for/list ([t (in-list types)])
                 (define code (type-leaf (jref t 'code)))
                 (schema-field (string->symbol (string-append base (capitalize code))) min max
                               (ftype-of tsym base t (jref e 'path)) (string->symbol base) (spec-url (jref e 'path)) #f))]
              [else
               (list (schema-field (string->symbol name) min max
                                   (if (pair? types) (ftype-of tsym name (car types) (jref e 'path)) (vector 'unknown))
                                   #f (spec-url (jref e 'path)) #f))]))))
       (register-type! tsym (fhir-spec tsym (or url (symbol->string tsym)) 'type)
                       #:schema (type-schema tsym #f parent (or url (symbol->string tsym)) fields #f #f))
       (for ([e (in-list (hash-ref children path '()))])
         (register-element! (jref e 'path) (fhir-spec (string->symbol (jref e 'path)) (spec-url (jref e 'path)) 'element))))
     ;; ftype-of : owner-sym element-name type-entry path -> Ftype
     (define (ftype-of owner name t path)
       (define code (jref t 'code))
       (define profiles (jlist t 'profile))
       (define target (and (pair? profiles) (string? (car profiles)) (car profiles)))
       (cond
         [(and (string? code) (regexp-match? #rx"^http://hl7.org/fhirpath/System\\." code))
          (define sys (regexp-replace #rx"^.*System\\." code ""))
          (define prim (case sys
                         [("String") "string"] [("Integer") "integer"] [("Decimal") "decimal"]
                         [("Boolean") "boolean"] [("Date") "date"] [("DateTime") "dateTime"] [("Time") "time"]
                         [else #f]))
          (if prim (vector 'prim prim) (vector 'unknown))]
         [(and (member code '("BackboneElement" "Element")) (pair? (hash-ref children path '())))
          (define nested (string->symbol (string-append (symbol->string owner) (capitalize name))))
          (unless (type-registered? nested) (register-node! nested path 'Element))
          (vector 'type nested)]
         [(and (string? code) (primitive-name? (string->symbol code))) (vector 'prim code)]
         [(and (string? code) (member code '("Resource" "DomainResource"))) (vector 'resource)]
         [(and target (not (type-registered? (string->symbol (type-leaf target)))))
          (define other (resolve target))
          (define osym (and other (register-structure-definition! other #:resolve resolve)))
          (if osym (vector 'type osym) (vector 'unknown))]
         [target (vector 'type (string->symbol (type-leaf target)))]
         [(and (string? code) (type-registered? (string->symbol (type-leaf code)))) (vector 'type (string->symbol (type-leaf code)))]
         [(and (string? code) (regexp-match? #rx"^https?://" code))
          (define other (resolve code))
          (define osym (and other (register-structure-definition! other #:resolve resolve)))
          (if osym (vector 'type osym) (vector 'unknown))]
         [else (vector 'unknown)]))
     ;; a logical model serializes without resourceType (its JSON may still carry one, which
     ;; from-json reads as the type); a specialization keeps its base
     (register-node! sym root-path (if logical? 'Element (string->symbol (type-leaf (or (jref sd 'baseDefinition) "Element")))))
     sym]))

(define (type-leaf s) (last (string-split s "/")))
(define (capitalize s) (if (zero? (string-length s)) s (string-append (string-upcase (substring s 0 1)) (substring s 1))))

(module+ test
  (require rackunit json
           (only-in fhir/r5/schemas)
           (only-in fhir/serialize/from-json from-json)
           (only-in fhir/serialize/to-json node->jsexpr)
           (only-in fhir/model/node fhir-ref fhir-type)
           (only-in fhir/model/leaf pv listify)
           (only-in fhir/result/result ok? ok-value))
  (define (sd type . elems)
    (hasheq 'resourceType "StructureDefinition" 'url (string-append "http://x/" type) 'kind "logical" 'type type
            'baseDefinition "http://hl7.org/fhir/StructureDefinition/Base"
            'differential (hasheq 'element (cons (hasheq 'path type 'min 1 'max "1") elems))))
  (define (el path min max . codes)
    (hasheq 'path path 'min min 'max max 'type (for/list ([c codes]) (if (pair? c) (hasheq 'code (car c) 'profile (list (cdr c))) (hasheq 'code c)))))
  ;; a flat model, a backbone element, a choice, and a reference to another logical model
  (define inner (sd "TInner" (el "TInner.ab" 1 "1" "string")))
  (define left (sd "TLeft" (el "TLeft.a" 1 "1" "string") (el "TLeft.n" 0 "*" "integer")
                   (el "TLeft.aa" 0 "*" "BackboneElement") (el "TLeft.aa.ab" 1 "1" "string")
                   (el "TLeft.value[x]" 0 "1" "string" "Quantity")
                   (el "TLeft.in" 0 "*" (cons "TInner" "http://x/TInner"))))
  (define resolve (lambda (u) (and (equal? u "http://x/TInner") inner)))
  (check-equal? (register-structure-definition! left #:resolve resolve) 'TLeft)
  (define r (from-json (hasheq 'resourceType "TLeft" 'a "hi" 'n (list 1 2) 'aa (list (hasheq 'ab "x"))
                               'valueQuantity (hasheq 'value 3 'unit "kg") 'in (list (hasheq 'ab "deep")))))
  (check-true (ok? r))
  (define n (ok-value r))
  (check-equal? (fhir-type n) 'TLeft)
  (check-equal? (pv (fhir-ref n 'a)) "hi")
  (check-equal? (map pv (listify (fhir-ref n 'n))) '(1 2))
  (check-equal? (fhir-type (car (listify (fhir-ref n 'aa)))) 'TLeftAa)
  (check-equal? (fhir-type (car (listify (fhir-ref n 'in)))) 'TInner)
  (check-equal? (node->jsexpr n) (hasheq 'a "hi" 'n (list 1 2) 'aa (list (hasheq 'ab "x"))
                                         'valueQuantity (hasheq 'value 3 'unit "kg") 'in (list (hasheq 'ab "deep"))))
  ;; strict parsing still rejects what the model does not define
  (check-false (ok? (from-json (hasheq 'resourceType "TLeft" 'nope 1))))
  ;; a registered type is left alone
  (check-equal? (register-structure-definition! (sd "Patient" (el "Patient.zzz" 0 "1" "string"))) 'Patient))
