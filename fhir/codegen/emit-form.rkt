#lang racket/base

;;; emit-form.rkt — emit a self-contained FHIR form MODULE: one macro per type (and per nested
;;; backbone), each validating its tree at compile time and reducing to a typed node.
;;;
;;; A form macro is the base of the tower: (build-fhir-form stx 'Name SCHEMA #:parent 'Framework).
;;; The module is self-contained — nested datatype/resource forms resolve at the USE site (the
;;; composing #lang), not here, so no cross-form requires are needed.

(require racket/contract
         racket/string
         "ir.rkt"
         (only-in "emit-schema.rkt" macro-schema-lines flatten-nodes sanitize))

(provide
 (contract-out
  ;; emit-form-module : expanded-node orig-node provenance -> module source
  ;;   provenance stamps the banner with the true source, e.g. "hl7.fhir.r6.core#6.0.0-ballot4"
  [emit-form-module    (-> type-node? (or/c type-node? #f) (or/c string? #f) string?)]
  ;; the macro names a form module provides (the type + its backbones)
  [form-module-exports (-> type-node? (listof string?))]))

(define (form-module-exports node)
  (for/list ([n (in-list (flatten-nodes node))]) (sanitize (type-node-name n))))

(define (emit-form-module node orig provenance)
  (define nodes (flatten-nodes node))
  (define orig-nodes (if orig (flatten-nodes orig) (map (lambda (_) #f) nodes)))
  (define out (open-output-string))
  (define (line . xs) (for ([x (in-list xs)]) (display x out)) (newline out))
  (line "#lang racket/base")
  (line ";;; GENERATED from " (or provenance "?") " — DO NOT EDIT (verified by raco fhir check).")
  (line "(require (for-syntax racket/base fhir/lang-gen/form-syntax))")
  (line "(provide " (string-join (form-module-exports node) " ") ")")
  (for ([n (in-list nodes)] [on (in-list orig-nodes)])
    (define entries (macro-schema-lines n on))       ; one field-spec/choice-group per line
    (line "(define-syntax (" (sanitize (type-node-name n)) " stx)")
    (line "  (build-fhir-form stx '" (sanitize (type-node-name n)))
    (cond
      [(null? entries) (line "    '()")]
      [else (line "    '(" (car entries))
            (for ([e (in-list (cdr entries))]) (line "      " e))
            (line "      )")])
    (line "    #:parent '" (type-node-parent n) "))"))
  (get-output-string out))
