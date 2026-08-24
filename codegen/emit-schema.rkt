#lang racket/base

;;; emit-schema.rkt — render a type-node tree as a runtime SCHEMA-DATA module, and host the shared
;;; emit helpers (ftype resolution, macro-schema, flatten, sanitize) reused by emit-form.rkt.
;;;
;;; The schema module registers, per type, a `type-schema` carrying its OWN field schema
;;; (name/cardinality/ftype + spec URL) plus a `register-element!` per field. serialize/from-json
;;; read this registry; inherited framework fields are supplied by the parent table (model/schema),
;;; so only own fields are registered here. This is the runtime dual of the compile-time form macro.

(require racket/string
         racket/list
         racket/contract
         "ir.rkt"
         "type-registry.rkt"
         (only-in "expand.rkt" choice-groups-of)
         (only-in "../model/schema.rkt" field-spec choice-group max-of
                  inherited-field-names inherited-field-min inherited-field-max inherited-field-ftype))

(provide
 (contract-out
  [emit-schema-module (-> type-node? (or/c type-node? #f) string? (or/c string? #f) string? string?)]
  ;; the form-macro field schema, one printed entry per line (field-specs then choice-groups)
  [macro-schema-lines (-> type-node? (or/c type-node? #f) (listof string?))]
  [flatten-nodes  (-> type-node? (listof type-node?))]
  [sanitize       (-> string? string?)]
  [doc-base-for   (-> string? string? string? string?)]
  [field-def->ftype (-> string? field-def? vector?)]))

;; ---- name helpers --------------------------------------------------
(define (sanitize name) (string-replace name "." ""))   ; "Patient.Contact" -> "PatientContact"
(define (max->src m) (if (eq? m '*) "'*" (number->string m)))

;; doc-base-for : prefix kind name -> the type's own doc URL. `prefix` is the target's spec base
;; (e.g. "https://build.fhir.org/" for R6, "https://hl7.org/fhir/R4/" for R4).
(define (doc-base-for prefix kind name)
  (cond
    [(equal? kind "resource") (string-append prefix (string-downcase name) ".html")]
    [else (string-append prefix "datatypes.html")]))

;; ---- per-field ftype resolution (single source of truth) -----------
(define (field-def->ftype enclosing-name f)
  (cond
    [(field-def-ref f) (vector 'type (string->symbol (sanitize (field-def-ref f))))]
    [(backbone-field? f)
     (vector 'type (string->symbol
                    (sanitize (string-append enclosing-name "." (capitalize (field-def-name f))))))]
    [else
     (define r (resolve-type (car (field-def-types f))))
     (cond
       [(not r) (vector 'unknown)]
       [(string=? r "Resource") (vector 'resource)]
       [(primitive-type-code? r) (vector 'prim r)]
       [else (vector 'type (string->symbol r))])]))

(define (backbone-field? f)
  (and (not (field-def-ref f))
       (let ([ts (field-def-types f)])
         (or (null? ts) (not (resolve-type (car ts)))))))

;; render an Ftype as a CONSTRUCTOR expression (for the schema module)
(define (ftype->ctor ft)
  (case (vector-ref ft 0)
    [(type)     (format "(vector 'type '~a)" (vector-ref ft 1))]
    [(prim)     (format "(vector 'prim ~s)" (vector-ref ft 1))]
    [(resource) "(vector 'resource)"]
    [else       "(vector 'unknown)"]))

;; the base name of a (possibly choice) element path's last segment, minus a trailing [x]
(define (choice-base-text f)
  (if (string-suffix? (field-def-path f) "[x]")
      (format "'~a" (field-name (field-def-path f)))
      "#f"))

;; ---- flatten the tree (root first, then backbones) -----------------
(define (flatten-nodes node)
  (cons node (append-map flatten-nodes (type-node-backbones node))))

;; ---- the compile-time form macro's field schema (a prefab literal) --
;; inherited ⊕ own field-specs, plus a choice-group per value[x] group (computed from the ORIGINAL,
;; pre-expansion node so the members can be enforced as "at most one of"). Each entry is emitted
;; via ~s on its own line, so the generated macro reads like a schema table.
(define (macro-schema-lines n orig-n)
  (define inh
    (for/list ([fn (in-list (inherited-field-names (string->symbol (type-node-parent n))))])
      (field-spec fn (inherited-field-min fn) (inherited-field-max fn) (inherited-field-ftype fn) #f)))
  (define own
    (for/list ([f (in-list (type-node-fields n))])
      (field-spec (string->symbol (field-def-name f)) (field-def-min f) (max-of (field-def-max f))
                  (field-def->ftype (type-node-name n) f) (binding-extra f))))
  (define groups
    (if orig-n
        (for/list ([g (in-list (choice-groups-of orig-n))])
          (choice-group (car g) 1 (cadr g)))
        '()))
  (for/list ([e (in-list (append inh own groups))]) (format "~s" e)))

;; the field-spec extra slot: (list 'required vs-url) for a REQUIRED-bound `code` field — the
;; compile-time binding check's hook (form-syntax check-binding); everything else stays #f
(define (binding-extra f)
  (define b (field-def-binding f))
  (and b (equal? (car b) "required") (equal? (field-def-types f) '("code"))
       (list 'required (cdr b))))

;; ---- emit the schema module ---------------------------------------
;; node : expanded root ; orig : pre-expansion root (for choice groups; unused here but symmetric)
;; kind : "resource"|"complex-type" ; version : the pinned package version ; doc-prefix : spec base.
(define (emit-schema-module node orig kind version doc-prefix)
  (define doc-base (doc-base-for doc-prefix kind (type-node-name node)))
  (define nodes (flatten-nodes node))
  (define out (open-output-string))
  (define (line . xs) (for ([x (in-list xs)]) (display x out)) (newline out))
  (line "#lang racket/base")
  (line ";;; GENERATED from " (or version "?") " — DO NOT EDIT (verified by raco fhir check).")
  (line "(require fhir/model/schema fhir/model/registry)")
  (line)
  (for ([n (in-list nodes)]) (emit-registrations n doc-base line))
  (get-output-string out))

(define (emit-registrations n doc-base line)
  (define name (type-node-name n))
  (define sym (sanitize name))
  (define type-url (string-append doc-base "#" (type-node-path n)))
  (define field-texts
    (for/list ([f (in-list (type-node-fields n))])
      (define url (string-append doc-base "#" (field-def-path f)))
      (format "    (schema-field '~a ~a ~a ~a ~a ~s #f)"
              (field-def-name f) (field-def-min f) (max->src (max-of (field-def-max f)))
              (ftype->ctor (field-def->ftype name f)) (choice-base-text f) url)))
  (line "(register-type! '" sym " (fhir-spec '" sym " " (format "~s" type-url) " 'type)")
  (line "  #:schema (type-schema '" sym " #f '" (type-node-parent n) " " (format "~s" type-url))
  (line "             (list")
  (for ([t (in-list field-texts)]) (line t))
  (line "             ) #f #f))")
  (for ([f (in-list (type-node-fields n))])
    (define url (string-append doc-base "#" (field-def-path f)))
    (line "(register-element! " (format "~s" (field-def-path f))
          " (fhir-spec (string->symbol " (format "~s" (field-def-path f)) ") "
          (format "~s" url) " 'element))"))
  (line))
