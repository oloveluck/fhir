#lang racket/base

;;; define-primitive.rkt — the macro that defines a FHIR primitive type.
;;;
;;; Each FHIR primitive is a true PrimitiveType element: it extends `primitive-type`
;;; (DataType → Element), so it carries `id` and `extension` alongside its `value` — exactly the
;;; FHIR model, where a primitive's id/extensions live in the JSON `_field` sibling.
;;;
;;; One call generates: a struct `fhir-<name>` (a primitive-type) carrying `prop:fhir-spec`; a
;;; validating constructor `make-<name>` (returns ok/err, with optional #:id / #:extension); a
;;; value accessor `fhir-<name>-value`; JSON read/write; and registration into both the primitive
;;; registry and the unified type registry.
;;;
;;; Validation strategy (mutually exclusive precedence #:pattern > #:range > #:parse > #:base):
;;;   #:pattern px   — raw is a string matching px            (string-like types)
;;;   #:range [lo hi]— raw is an exact integer in [lo,hi]     (positiveInt, integer, …)
;;;   #:parse  proc  — proc : (raw url) -> Result value       (temporal types)
;;;   #:base   pred? — raw satisfies pred?                    (boolean, decimal)
;;;   #:length n     — additional max-length check (strings)
;;;   #:spec-url url — REQUIRED; the FHIR definition URL.

(require (for-syntax racket/base
                     syntax/parse
                     racket/syntax)
         "../model/registry.rkt"
         "../result/result.rkt"
         "../model/base.rkt"
         (only-in "absent.rkt" absent)
         (only-in "temporal.rkt" temporal->string))

(provide define-fhir-primitive)

(define-syntax (define-fhir-primitive stx)
  (syntax-parse stx
    [(_ name:id
        (~alt (~optional (~seq #:base base))
              (~optional (~seq #:pattern pat))
              (~optional (~seq #:range [lo hi]))
              (~optional (~seq #:parse parser))
              (~optional (~seq #:length maxlen))
              (~once     (~seq #:spec-url url)))
        ...)
     (define/with-syntax sname (format-id #'name "fhir-~a" #'name))
     (define/with-syntax ctor  (format-id #'name "make-~a" #'name))
     (define/with-syntax rdr   (format-id #'name "read-~a" #'name))
     (define/with-syntax wtr   (format-id #'name "write-~a" #'name))
     (define/with-syntax pred  (format-id #'name "fhir-~a?" #'name))
     (define/with-syntax acc   (format-id #'name "fhir-~a-value" #'name))

     ;; the constraint stored in the spec record (evidence of validation)
     (define/with-syntax constraint
       (cond [(attribute pat)    #'pat]
             [(attribute lo)     #'(cons lo hi)]
             [(attribute parser) #''parsed]
             [else               #''base]))

     ;; the validating constructor: (raw [#:id] [#:extension]) -> Result
     (define/with-syntax make-fn
       (cond
         [(attribute pat)
          #`(lambda (raw #:id [id #f] #:extension [extension '()])
              (cond
                [(not (string? raw)) (err (invalid-encoding 'name url raw))]
                #,@(if (attribute maxlen)
                       (list #'[(> (string-length raw) maxlen)
                                (err (length-exceeded 'name url raw maxlen))])
                       '())
                [(regexp-match? pat raw) (ok (sname id extension raw))]
                [else (err (pattern-mismatch 'name url raw pat))]))]
         [(attribute lo)
          #'(lambda (raw #:id [id #f] #:extension [extension '()])
              (cond
                [(not (exact-integer? raw)) (err (invalid-encoding 'name url raw))]
                [(and (>= raw lo) (<= raw hi)) (ok (sname id extension raw))]
                [else (err (out-of-range 'name url raw lo hi))]))]
         [(attribute parser)
          #'(lambda (raw #:id [id #f] #:extension [extension '()])
              (result-map (lambda (v) (sname id extension v)) (parser raw url)))]
         [else
          #`(lambda (raw #:id [id #f] #:extension [extension '()])
              (if (#,(attribute base) raw)
                  (ok (sname id extension raw))
                  (err (invalid-encoding 'name url raw))))]))

     ;; write: temporal types render to their lexical form; others pass the value through.
     (define/with-syntax write-fn
       (if (attribute parser)
           #'(lambda (v) (temporal->string (acc v)))
           #'(lambda (v) (acc v))))

     #'(begin
         (struct sname primitive-type () #:transparent
           #:property prop:fhir-spec (fhir-spec 'name url constraint))
         (define (acc v) (primitive-type-value v))
         (define ctor make-fn)
         (define rdr ctor)            ; read a jsexpr (already correctly shaped) -> Result
         (define wtr write-fn)        ; a value -> jsexpr (just the primitive value)
         ;; a value-less instance: only id/extension, no value (bypasses value validation)
         (define (absent-ctor #:id [id #f] #:extension [extension '()]) (sname id extension absent))
         (register-primitive! 'name (fhir-spec 'name url constraint)
                              #:predicate pred #:constructor ctor #:absent-constructor absent-ctor)
         (register-type! 'name (fhir-spec 'name url constraint)
                         #:predicate pred #:constructor ctor)
         (provide (struct-out sname) acc ctor rdr wtr))]))
