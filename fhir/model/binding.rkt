#lang racket/base

;;; binding.rkt — the required-binding expansion registry.
;;;
;;; A generated tower's terminology.rkt registers, per REQUIRED-bound ValueSet it could expand
;;; OFFLINE from its own package (whole-system / enumerated includes only), the set of valid codes.
;;; Two readers:
;;;   - lang-gen/form-syntax (PHASE 1): a literal code in a form whose field carries a required
;;;     binding is checked at COMPILE time — `(gender "florp")` is a syntax error;
;;;   - anything at runtime that wants the same catalogue.
;;; The registry is instantiated per phase; the tower index requires terminology.rkt both normally
;;; and for-syntax so both instantiations are populated. Unregistered urls mean "not offline-
;;; expandable" — every consumer FAILS OPEN on them.

(require racket/contract)

(provide
 (contract-out
  [register-binding-expansion! (-> string? (listof string?) void?)]
  [binding-expansion           (-> string? (or/c #f (hash/c string? boolean?)))]
  [binding-expansion-codes     (-> string? (or/c #f (listof string?)))]
  ;; the codes the tower loaded LAST registered for the url, whatever is pinned: for a reader whose
  ;; resources are of that tower's own model (below)
  [latest-binding-expansion    (-> string? (or/c #f (hash/c string? boolean?)))]
  ;; the expansions registered now are kept against later registrations (model/registry's
  ;; pin-registered-types! and unpin-registered-types! call these: one pin for a tower)
  [pin-binding-expansions!     (-> void?)]
  [unpin-binding-expansions!   (-> void?)]))

(define expansions (make-hash))    ; vs-url -> hash code -> #t (set semantics, O(1) member)

;; A value set is registered by its URL, which is the same in every FHIR version, and a process may
;; load two towers (a workspace's R4, and the R6 a ViewDefinition's model is built over): the
;; later tower replaced the earlier's codes, so an R4 process said of a wrong Observation.status
;; that the value set "holds amended, appended, cannot-be-obtained, … specimen-in-process" — R6's
;; codes — and where nothing else decided, decided by them. Pinned, the urls registered now keep
;; their codes IN FORCE (`expansions`: what data is validated by); a url that is new is still added.
;; Every registration is also kept as the LATEST for its url: the model loaded after the pin has
;; resources of its own (a ViewDefinition's `fhirVersion` takes "4.0", which R6's value set holds
;; and R4's does not), and what checks those asks for the latest.
(define pinned (make-hash))
(define latest (make-hash))        ; vs-url -> hash code -> #t, as registered last

(define (register-binding-expansion! url codes)
  (define expansion (for/hash ([c (in-list codes)]) (values c #t)))
  (hash-set! latest url expansion)
  (unless (hash-ref pinned url #f) (hash-set! expansions url expansion))
  (void))

(define (pin-binding-expansions!)
  (for ([url (in-list (hash-keys expansions))]) (hash-set! pinned url #t)))
(define (unpin-binding-expansions!) (hash-clear! pinned))

(define (latest-binding-expansion url) (hash-ref latest url #f))
(define (binding-expansion url) (hash-ref expansions url #f))
(define (binding-expansion-codes url)
  (define h (binding-expansion url))
  (and h (sort (hash-keys h) string<?)))

(module+ test
  (require rackunit)
  (register-binding-expansion! "urn:demo-vs" '("a" "b"))
  (check-true (hash-ref (binding-expansion "urn:demo-vs") "a" #f))
  (check-false (hash-ref (binding-expansion "urn:demo-vs") "z" #f))
  (check-equal? (binding-expansion-codes "urn:demo-vs") '("a" "b"))
  (check-false (binding-expansion "urn:not-registered"))   ; unknown -> fail open
  ;; pinned, a url keeps the codes it has; a new url is added; unpinned, a registration replaces again
  (pin-binding-expansions!)
  (register-binding-expansion! "urn:demo-vs" '("z"))
  (check-equal? (binding-expansion-codes "urn:demo-vs") '("a" "b"))
  (check-equal? (hash-keys (latest-binding-expansion "urn:demo-vs")) '("z"))   ; the later tower's own
  (check-false (latest-binding-expansion "urn:not-registered"))
  (register-binding-expansion! "urn:demo-new" '("n"))
  (check-equal? (binding-expansion-codes "urn:demo-new") '("n"))
  (unpin-binding-expansions!)
  (register-binding-expansion! "urn:demo-vs" '("z"))
  (check-equal? (binding-expansion-codes "urn:demo-vs") '("z")))
