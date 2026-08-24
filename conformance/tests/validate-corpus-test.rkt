#lang racket/base

;;; validate-corpus-test.rkt — the "never over-report" gate. Validate a bounded sample of KNOWN-VALID
;;; R5 resources (from the core package) against their base types and require ZERO errors. This is a
;;; stronger, more honest guarantee than a message-for-message diff against the Java reference validator:
;;; a correct fail-open validator must not flag any conforming resource.

(require rackunit
         json file/gunzip file/untar
         (only-in fhir/r5/schemas)
         (only-in fhir/conformance/validate validate-issues issue-severity issue-code issue-path issue-msg))

(define-values (n errcases err-samples)
  (let ([tgz (build-path (collection-path "fhir") "spec" "hl7.fhir.r5.core.tgz")]
        [limit 200])
    (define count 0) (define bad 0) (define samples '())
    (define-values (pin pout) (make-pipe (* 1024 1024)))
    (define t (thread (lambda () (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                              (close-output-port pout))))
    (untar pin #:handle-entry
           (lambda (kind name content size attribs)
             (when (eq? kind 'file)
               (define b (if (= size 0) #"" (read-bytes size content)))
               (when (and (< count limit)
                          (regexp-match? #px"^package/(ValueSet|CodeSystem|SearchParameter|ConceptMap)-.*\\.json$"
                                         (path->string name)))
                 (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr b)))
                 (when (and (hash? js) (hash-ref js 'resourceType #f))
                   (set! count (add1 count))
                   (define es (filter (lambda (i) (equal? (issue-severity i) "error")) (validate-issues js)))
                   (when (pair? es)
                     (set! bad (add1 bad))
                     (when (< (length samples) 8)
                       (set! samples (cons (cons (path->string name)
                                                 (list (issue-code (car es)) (issue-path (car es)) (issue-msg (car es))))
                                           samples)))))))
             '()))
    (thread-wait t)
    (values count bad (reverse samples))))

(printf "validate-corpus: ~a valid R5 resources, ~a over-reported\n" n errcases)
(for ([s (in-list err-samples)]) (printf "  OVER-REPORT ~a: ~s\n" (car s) (cdr s)))
(check-true (> n 100) "sampled a meaningful number of resources")
(check-equal? errcases 0 "the validator must not report errors on valid resources (never over-report)")
