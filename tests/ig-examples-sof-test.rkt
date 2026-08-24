#lang racket/base

;;; ig-examples-sof-test.rkt — every example the SQL-on-FHIR IG ships must parse.
;;;
;;; The package's `package/example/*.json` instances load through the SOF tower (+ its R6 base):
;;; instances of tower-generated types (ViewDefinition) must parse STRICTLY — the generated schema
;;; is the validator — and every other example must at least parse leniently to a typed node of its
;;; declared resourceType. A new vendored IG version that breaks its own examples fails here.

(require rackunit racket/runtime-path racket/string
         fhir/viewdef/types                                  ; the SOF tower + its R6 base
         (only-in fhir/codegen/load-spec load-package package-contents-examples)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/result/result ok? ok-value err-error)
         (only-in fhir/model/node fhir-type)
         (only-in fhir/model/registry type-registered?))

(define-runtime-path sof-tgz "../spec/hl7.fhir.uv.sql-on-fhir.tgz")
(define strict-types '(ViewDefinition))                      ; the tower's own types

(define examples (package-contents-examples (load-package sof-tgz)))
(check-true (>= (length examples) 15))                       ; the IG ships a real example set

;; DOCUMENTED corpus defect (3.0.0-ballot): every ViewDefinition example carries
;; `resourceDefinition`, an element the IG's OWN StructureDefinition does not declare. The strict
;; parser rejecting it is CORRECT — the schema doubles as the validator and catches the IG's
;; internal inconsistency. It is masked here (and ONLY here); the ratchet below fails the day the
;; IG fixes its examples, so the mask gets removed rather than rotting.
(define known-extra-fields '(resourceDefinition))
(define (mask-known js) (for/fold ([h js]) ([k (in-list known-extra-fields)]) (hash-remove h k)))

(for ([ex (in-list examples)])
  (define name (car ex))
  (define js (cdr ex))
  (define rt (and (hash? js) (hash-ref js 'resourceType #f)))
  (check-true (string? rt) (format "~a: no resourceType" name))
  (when (and (string? rt) (type-registered? (string->symbol rt)))
    (cond
      [(memq (string->symbol rt) strict-types)
       ;; the IG's own resources: STRICT parse — unknown/malformed fields are failures
       (define r (from-json (mask-known js)))
       (check-true (ok? r) (format "~a: strict parse failed: ~a" name (and (not (ok? r)) (err-error r))))]
      [else
       ;; other examples (Libraries, Bundles, Patients…): lenient parse must yield the right type
       (define r (from-json js #:lenient? #t))
       (check-true (ok? r) (format "~a: lenient parse failed" name))
       (when (ok? r)
         (check-equal? (symbol->string (fhir-type (ok-value r))) rt name))])))

;; the ratchet: the defect is still present in the vendored package — when this fails, the IG has
;; fixed its examples and `known-extra-fields` must be emptied
(check-true (for/or ([ex (in-list examples)])
              (and (equal? (hash-ref (cdr ex) 'resourceType #f) "ViewDefinition")
                   (hash-has-key? (cdr ex) 'resourceDefinition))))
