#lang racket/base

;;; snapshot-conformance-test.rkt — the official snapshot-generation corpus (vendor/, see its
;;; SOURCE.txt) run against conformance/snapshot.rkt.
;;;
;;; For each executable case (JSON input AND JSON output — the rest are XML, out of scope here)
;;; we generate the snapshot from the differential and compare against the reference output on the
;;; properties we actually generate:
;;;   coverage    — every expected element path is present in ours (the structural obligation)
;;;   cardinality — min/max agree wherever the reference states them
;;;   types       — the element's type codes agree wherever the reference states them
;;; The reference emits many derived fields we deliberately don't (short/definition/comment/
;;; mapping/…); comparing those would measure documentation copying, not snapshot logic.
;;;
;;; Floors are RATCHETED: raise them when the generator improves, never lower them.

(require rackunit racket/runtime-path racket/list racket/string racket/file
         json
         (only-in fhir/r5/schemas)                       ; the R5 tower (sd-index resolves bases)
         (only-in fhir/conformance/snapshot generate-snapshot))

(define-runtime-path vendor "vendor/snapshot-generation")

;; ---- the executable cases (both sides JSON) --------------------------------------------------
;; (list name input-file output-file)
(define cases
  (list (list "encounter-legalStatus"
              "StructureDefinition-encounter-legalStatus-input.json"
              "StructureDefinition-encounter-legalStatus-output.json")
        (list "prov-fi" "prov-fi-input.json" "prov-fi-output.json")))

(define (read-case f) (call-with-input-file (build-path vendor f) read-json))

;; Elements are matched by `id` — which encodes slices as `path:slice`, so a slice's constraints
;; are never read as its base element's (matching by path alone conflated them, e.g. a slice's
;; max=1 appearing as the base agent's). Path is the fallback for elements without an id.
(define (by-key elements)
  (for/fold ([h (hash)]) ([e (in-list elements)])
    (define k (or (hash-ref e 'id #f) (hash-ref e 'path #f)))
    (if (and k (not (hash-has-key? h k))) (hash-set h k e) h)))

;; path coverage is still measured by PATH (the structural question: is every expected path there)
(define (by-path elements)
  (for/fold ([h (hash)]) ([e (in-list elements)])
    (define p (hash-ref e 'path #f))
    (if (and p (not (hash-has-key? h p))) (hash-set h p e) h)))

(define (type-codes e)
  (sort (filter values (for/list ([t (in-list (hash-ref e 'type '()))]) (hash-ref t 'code #f)))
        string<?))

;; ---- run ------------------------------------------------------------------------------------
(define totals (make-hash))
(define (bump! k n) (hash-update! totals k (lambda (v) (+ v n)) 0))

(for ([c (in-list cases)])
  (define name (first c))
  (define input (read-case (second c)))
  (define expected (hash-ref (hash-ref (read-case (third c)) 'snapshot) 'element))
  (define actual (generate-snapshot input))
  (check-true (pair? actual) (format "~a: generated no snapshot" name))
  (define ours (by-path actual))
  (define theirs (by-path expected))
  ;; 1. coverage: every reference path exists in ours
  (define covered (for/sum ([p (in-hash-keys theirs)]) (if (hash-has-key? ours p) 1 0)))
  (bump! 'paths-expected (hash-count theirs))
  (bump! 'paths-covered covered)
  ;; 2/3. cardinality + types on elements matched by ID (slice-aware)
  (define ours/id (by-key actual))
  (define theirs/id (by-key expected))
  (for ([(k te) (in-hash theirs/id)] #:when (hash-has-key? ours/id k))
    (define oe (hash-ref ours/id k))
    (when (hash-has-key? te 'min)
      (bump! 'card-checked 1)
      (when (equal? (hash-ref te 'min) (hash-ref oe 'min 'missing)) (bump! 'card-agree 1)))
    (when (hash-has-key? te 'max)
      (bump! 'card-checked 1)
      (when (equal? (hash-ref te 'max) (hash-ref oe 'max 'missing)) (bump! 'card-agree 1)))
    (when (pair? (hash-ref te 'type '()))
      (bump! 'types-checked 1)
      (when (equal? (type-codes te) (type-codes oe)) (bump! 'types-agree 1))))
  (printf "  ~a: ~a/~a paths\n" name covered (hash-count theirs)))

(define (score k-of k-total) (values (hash-ref totals k-of 0) (hash-ref totals k-total 0)))
(define-values (pc pe) (score 'paths-covered 'paths-expected))
(define-values (ca cc) (score 'card-agree 'card-checked))
(define-values (ta tc) (score 'types-agree 'types-checked))
(printf "snapshot conformance: paths ~a/~a  cardinality ~a/~a  types ~a/~a  (~a executable cases; XML cases skipped)\n"
        pc pe ca cc ta tc (length cases))

;; ---- ratcheted floors ------------------------------------------------------------------------
;; NEVER LOWER. Raise as the generator improves (reslicing + contentReference are the known gaps).
;; The residual disagreements are VERSION-INDUCED, not generator bugs: prov-fi declares
;; fhirVersion 4.0.1 while conformance/sd-index.rkt resolves base definitions from the R5 core
;; package, so core cardinalities that changed between versions differ (R4 `Provenance.recorded`
;; is 1..1, R5 0..1). Running it against an R4 resolver would need an R4 sd-index; until then
;; these are documented, not chased.
(check-true (>= pc 80) (format "path coverage regressed: ~a" pc))
(check-true (>= ca 143) (format "cardinality agreement regressed: ~a" ca))
(check-true (>= ta 70) (format "type agreement regressed: ~a" ta))
