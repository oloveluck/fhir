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

(require (only-in fhir/canonical canonical-url)
         racket/contract racket/list racket/string
         (only-in fhir/model/registry register-type! register-element! type-registered? type-spec-of
                  primitive-name? fhir-spec fhir-spec-url fhir-spec-constraint)
         (only-in fhir/model/schema type-schema schema-field max-of)
         (only-in fhir/sd/sd-index resolve-sd-raw)
         (only-in fhir/serialize/jsexpr-util jref jlist)
         (only-in fhir/data-source current-data-source data-source-all)
         (only-in fhir/registry registered-resource))

(provide (contract-out
          [register-structure-definition! (->* (hash?) (#:resolve (-> string? (or/c hash? #f))) (or/c symbol? #f))]
          ;; structure-definition-type : SD -> its type symbol (without registering)
          [structure-definition-type (-> hash? (or/c symbol? #f))]
          ;; resolve-structure-definition/data : url -> SD | #f   the current data source, the registered
          ;; resources, then the packages
          [resolve-structure-definition/data (-> string? (or/c hash? #f))]))


(define (structure-definition-type sd)
  (define t (jref sd 'type))
  (and (string? t) (string->symbol (last (string-split t "/")))))

(define (resolve-structure-definition/data url)
  (define u (canonical-url url))
  (or (findf (lambda (sd) (equal? (jref sd 'url) u))
             ((data-source-all (current-data-source)) "StructureDefinition"))
      (registered-resource "StructureDefinition" u)            ; what a required module defined
      (resolve-sd-raw u)))

;; A Reg is (reg url children resolve replace?): one StructureDefinition being registered — its url
;; (the spec url of what it defines), `children` : path -> the elements directly under it, in order,
;; how a canonical another element names resolves, and whether nested types already registered are
;; redefined (a redefinition of the same logical type)
(struct reg (url children resolve replace?))

(define (register-structure-definition! sd #:resolve [resolve resolve-structure-definition/data])
  (define sym (structure-definition-type sd))
  (cond
    [(not sym) #f]
    [(and (type-registered? sym) (not (redefines? sd sym))) sym]
    [else
     (define elements (sd-elements sd))
     (define root-path (if (pair? elements) (jref (car elements) 'path) (symbol->string sym)))
     (define r (reg (jref sd 'url) (children-index elements) resolve (and (type-registered? sym) #t)))
     ;; a logical model serializes without resourceType (its JSON may still carry one, which
     ;; from-json reads as the type); a specialization keeps its base
     (register-node! r sym root-path
                     (if (equal? (jref sd 'kind) "logical")
                         'Element
                         (string->symbol (type-leaf (or (jref sd 'baseDefinition) "Element")))))
     sym]))

;; redefines? : sd type-sym -> boolean   the same type name defined by ANOTHER StructureDefinition
;; (a tutorial's TLeft, one per step) replaces the earlier registration — only one this module made
;; (kind 'logical): a tower type is never replaced, and a profile (derivation constraint) never
;; redefines its base type
(define (redefines? sd sym)
  (define spec (type-spec-of sym))
  (and spec (eq? (fhir-spec-constraint spec) 'logical)
       (not (equal? (jref sd 'derivation) "constraint"))
       (string? (jref sd 'url)) (not (equal? (fhir-spec-url spec) (jref sd 'url)))))

;; sd-elements : sd -> elements   the snapshot's, else the differential's
(define (sd-elements sd)
  (let ([s (jref sd 'snapshot)] [d (jref sd 'differential)])
    (or (and s (jlist s 'element)) (and d (jlist d 'element)) '())))

;; children-index : elements -> (hash path -> elements directly under it, in order)
(define (children-index elements)
  (for/fold ([h (hash)]) ([e (in-list elements)])
    (define segs (string-split (jref e 'path) "."))
    (if (> (length segs) 1)
        (hash-update h (string-join (drop-right segs 1) ".") (lambda (l) (append l (list e))) '())
        h)))

(define (spec-url r path) (format "~a#~a" (or (reg-url r) "") path))
(define (children r path) (hash-ref (reg-children r) path '()))

;; register-node! : reg type-sym path parent-sym -> void   the type for the elements under `path`
(define (register-node! r tsym path parent)
  (define fields (append* (for/list ([e (in-list (children r path))]) (element-fields r tsym e))))
  (register-type! tsym (fhir-spec tsym (or (reg-url r) (symbol->string tsym)) 'logical)
                  #:schema (type-schema tsym #f parent (or (reg-url r) (symbol->string tsym)) fields #f #f))
  (for ([e (in-list (children r path))])
    (register-element! (jref e 'path) (fhir-spec (string->symbol (jref e 'path)) (spec-url r (jref e 'path)) 'element))))

;; element-fields : reg owner-sym element -> (listof schema-field)
;; one field, or one per type of a choice element (`value[x]` -> valueString, valueQuantity …)
(define (element-fields r owner e)
  (define path (jref e 'path))
  (define name (last (string-split path ".")))
  (define min (let ([m (jref e 'min 0)]) (if (exact-nonnegative-integer? m) m 0)))
  (define max (max-of (let ([m (jref e 'max "1")]) (if (string? m) m "1"))))
  (define types (jlist e 'type))
  (cond
    [(regexp-match? #rx"\\[x\\]$" name)
     (define base (substring name 0 (- (string-length name) 3)))
     (for/list ([t (in-list types)])
       (schema-field (string->symbol (string-append base (capitalize (type-leaf (jref t 'code))))) min max
                     (element-ftype r owner base t path) (string->symbol base) (spec-url r path) #f))]
    [else
     (list (schema-field (string->symbol name) min max
                         (if (pair? types) (element-ftype r owner name (car types) path) (vector 'unknown))
                         #f (spec-url r path) #f))]))

;; element-ftype : reg owner-sym element-name type-entry path -> Ftype   (the header's reading)
(define (element-ftype r owner name t path)
  (define code (jref t 'code))
  (define profiles (jlist t 'profile))
  (define target (and (pair? profiles) (string? (car profiles)) (car profiles)))
  (define (registered-from url)                           ; another StructureDefinition, by canonical
    (define other ((reg-resolve r) url))
    (define osym (and other (register-structure-definition! other #:resolve (reg-resolve r))))
    (if osym (vector 'type osym) (vector 'unknown)))
  (cond
    [(and (string? code) (regexp-match? #rx"^http://hl7.org/fhirpath/System\\." code))
     (define prim (hash-ref system-primitives (regexp-replace #rx"^.*System\\." code "") #f))
     (if prim (vector 'prim prim) (vector 'unknown))]
    [(and (member code '("BackboneElement" "Element")) (pair? (children r path)))
     (define nested (string->symbol (string-append (symbol->string owner) (capitalize name))))
     (when (or (reg-replace? r) (not (type-registered? nested))) (register-node! r nested path 'Element))
     (vector 'type nested)]
    [(and (string? code) (primitive-name? (string->symbol code))) (vector 'prim code)]
    [(and (string? code) (member code '("Resource" "DomainResource"))) (vector 'resource)]
    [(and target (not (type-registered? (string->symbol (type-leaf target))))) (registered-from target)]
    [target (vector 'type (string->symbol (type-leaf target)))]
    [(and (string? code) (type-registered? (string->symbol (type-leaf code)))) (vector 'type (string->symbol (type-leaf code)))]
    [(and (string? code) (regexp-match? #rx"^https?://" code)) (registered-from code)]
    [else (vector 'unknown)]))

;; FHIRPath's System types, as FHIR primitives
(define system-primitives
  (hash "String" "string" "Integer" "integer" "Decimal" "decimal" "Boolean" "boolean"
        "Date" "date" "DateTime" "dateTime" "Time" "time"))

(define (type-leaf s) (last (string-split s "/")))
(define (capitalize s) (if (zero? (string-length s)) s (string-append (string-upcase (substring s 0 1)) (substring s 1))))

(module+ test
  (require rackunit json (only-in fhir/model/introspect full-field-specs) (only-in fhir/model/schema fs-name)
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
  ;; a tower type is left alone, whatever StructureDefinition names it
  (check-equal? (register-structure-definition! (sd "Patient" (el "Patient.zzz" 0 "1" "string"))) 'Patient)
  (check-false (memq 'zzz (map fs-name (full-field-specs 'Patient))))
  ;; the same logical type from ANOTHER definition replaces the first (a tutorial's TLeft per step);
  ;; the same definition again is a no-op
  (define left2 (hash-set (sd "TLeft" (el "TLeft.b" 1 "1" "string") (el "TLeft.aa" 0 "*" "BackboneElement")
                              (el "TLeft.aa.ac" 1 "1" "integer"))
                          'url "http://x/TLeft-2"))
  (check-equal? (register-structure-definition! left2) 'TLeft)
  (check-equal? (map fs-name (full-field-specs 'TLeft)) '(id extension b aa))
  (check-equal? (map fs-name (full-field-specs 'TLeftAa)) '(id extension ac))
  (check-true (ok? (from-json (hasheq 'resourceType "TLeft" 'b "x" 'aa (list (hasheq 'ac 1))))))
  (check-false (ok? (from-json (hasheq 'resourceType "TLeft" 'a "hi"))))
  (check-equal? (register-structure-definition! left2) 'TLeft)
  ;; a profile of it does not redefine it
  (check-equal? (register-structure-definition! (hash-set* (sd "TLeft" (el "TLeft.q" 0 "1" "string"))
                                                           'url "http://x/TLeft-profile" 'derivation "constraint"))
                'TLeft)
  (check-equal? (map fs-name (full-field-specs 'TLeft)) '(id extension b aa)))
