#lang racket/base

;;; ig-example-harness.rkt — the reusable "every example an IG ships must parse and round-trip"
;;; check, driven straight off a vendored package .tgz.
;;;
;;; An IG's `package/example/*.json` instances are real-world resources authored against that IG.
;;; Two obligations, both version-agnostic (the CALLER registers the matching tower — an R4 IG's
;;; examples need fhir/r4/schemas):
;;;   parse      — the example loads leniently to a typed node of its DECLARED resourceType
;;;   round-trip — parse ∘ serialize ∘ parse is idempotent (tests/example-harness's verdict)
;;; A resource whose type the loaded tower doesn't know is SKIPPED (not failed): an IG may ship
;;; examples of types outside the tower (or from a newer version).
;;;
;;; Result is (ig-report total parsed round-tripped skipped failures) — the caller ratchets.

(require racket/contract racket/list racket/string
         json
         (only-in "../codegen/load-spec.rkt" load-package package-contents-examples)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../result/result.rkt" ok? ok-value)
         (only-in "../model/node.rkt" fhir-type)
         (only-in "../model/registry.rkt" type-registered?)
         (only-in "example-harness.rkt" roundtrip-result))

(provide
 (struct-out ig-report)
 (contract-out
  [check-ig-examples (->* (path-string?) (#:mask (listof symbol?)) ig-report?)]))

(struct ig-report (total parsed round-tripped skipped failures) #:transparent)

;; #:mask — element names to strip before parsing, for DOCUMENTED corpus defects (an IG whose
;; examples use an element its own StructureDefinition doesn't declare). Keep the list empty
;; unless a defect is proven, and pair it with a ratchet in the caller.
(define (check-ig-examples tgz #:mask [mask '()])
  (define examples (package-contents-examples (load-package tgz)))
  (for/fold ([parsed 0] [rt 0] [skipped 0] [failures '()]
             #:result (ig-report (length examples) parsed rt skipped (reverse failures)))
            ([ex (in-list examples)])
    (define name (car ex))
    (define js0 (cdr ex))
    (define rt-name (and (hash? js0) (hash-ref js0 'resourceType #f)))
    (define js (for/fold ([h js0]) ([k (in-list mask)]) (if (hash? h) (hash-remove h k) h)))
    (cond
      [(not (string? rt-name))
       (values parsed rt (add1 skipped) (cons (cons name "no resourceType") failures))]
      [(not (type-registered? (string->symbol rt-name)))
       (values parsed rt (add1 skipped) failures)]          ; type outside this tower — skip
      [else
       (define r (from-json js #:lenient? #t))
       (cond
         [(not (ok? r))
          (values parsed rt skipped (cons (cons name "parse failed") failures))]
         [(not (eq? (fhir-type (ok-value r)) (string->symbol rt-name)))
          (values parsed rt skipped (cons (cons name "wrong parsed type") failures))]
         [else
          (define verdict (roundtrip-result js))
          (if (eq? verdict 'ok)
              (values (add1 parsed) (add1 rt) skipped failures)
              (values (add1 parsed) rt skipped
                      (cons (cons name (format "round-trip: ~a" verdict)) failures)))])])))
