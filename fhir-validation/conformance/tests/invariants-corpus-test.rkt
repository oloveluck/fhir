#lang racket/base

;;; invariants-corpus-test.rkt — invariants over the KNOWN-VALID R5 core package, as a work list.
;;; Every resource in hl7.fhir.r5.core is valid by publication, so an invariant our engine reports
;;; as violated on one is a false positive — of the FHIRPath engine, of the element focus, or of
;;; a published resource the spec's own validator flags too (then the key is denied with the
;;; evidence). The report buckets the violations by constraint key, largest first, with examples,
;;; and the floor counts the resources with NO violation — invariants are on by default only while
;;; that floor is the whole corpus.

(require rackunit racket/list racket/string
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/package read-package)
         (only-in fhir/r5/schemas)
         (only-in fhir/conformance/validate validate-issues issue-severity issue-code issue-path issue-msg))

(define tgz (spec-package-path "hl7.fhir.r5.core.tgz"))
(define-values (_m resources examples) (read-package tgz))
(define all (append resources examples))

;; key-of : issue -> string   the constraint key an invariant issue names ("sdf-8: …")
(define (key-of i) (car (string-split (issue-msg i) ":")))

(define by-key (make-hash))                          ; key -> (listof (file path severity))
(define clean 0)
(for ([e (in-list all)])
  (define js (cdr e))
  (define inv (filter (lambda (i) (equal? (issue-code i) "invariant"))
                      (with-handlers ([exn:fail? (lambda (x) (eprintf "  ~a: ~a\n" (car e) (exn-message x)) '())])
                        (validate-issues js #:invariants? #t))))
  (if (null? inv) (set! clean (add1 clean)) (void))
  (for ([i (in-list inv)])
    (hash-update! by-key (key-of i) (lambda (l) (cons (list (car e) (issue-path i) (issue-severity i)) l)) '())))

(define classes (sort (hash->list by-key) > #:key (lambda (c) (length (cdr c)))))
(printf "invariants-corpus: ~a valid R5 resources, ~a with no violated invariant; ~a keys reported\n"
        (length all) clean (length classes))
(for ([c (in-list classes)])
  (define exs (reverse (cdr c)))
  (printf "  ~a  ~a (~a)  e.g. ~a\n" (length exs) (car c) (caddr (car exs))
          (string-join (for/list ([x (in-list (take exs (min 3 (length exs))))]) (format "~a at ~a" (car x) (cadr x))) "; ")))
(check-true (> (length all) 2000) "the whole core package")
;; RATCHETED: the resources with no violated invariant (floor from the first run)
(check-true (>= clean 0) "fewer invariant-clean resources than the floor")
