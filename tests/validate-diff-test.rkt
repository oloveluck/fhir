#lang racket/base

;;; validate-diff-test.rkt — recall differential against the HL7 reference validator.
;;;
;;; For a curated R5, dependency-free subset of the official fhir-test-cases/validator corpus, compare
;;; our validator's ERROR verdict to the recorded Java reference OperationOutcome at the CASE level
;;; (clean vs dirty) — robust to the message/line-col/path differences a from-scratch validator can't
;;; reproduce. The hard gate is FALSE-POSITIVES = 0 (never flag a resource the reference accepts);
;;; recall (dirty cases we also flag) is a ratchet that should only rise.

(require rackunit
         racket/string racket/port
         racket/runtime-path
         json
         (only-in fhir/r5/schemas)
         (only-in fhir/serialize/read-json read-fhir-json read-fhir-json/duplicates)
         (only-in fhir/conformance/validate validate-issues issue-severity))

(define-runtime-path dir "vendor/validation")
(define recall-floor 17)                               ; ratchet: raise as coverage grows

;; a case may name SUPPORTING resources (3rd manifest column): the profiles/extensions it is
;; validated against. Only StructureDefinitions are passed as profiles; the rest are context the
;; reference resolves and we fail open on.
(define (our-error? js dups [profiles '()])
  (for/or ([i (in-list (validate-issues js #:profiles profiles #:duplicates dups))])
    (member (issue-severity i) '("error" "fatal"))))

(define (load-profiles names)
  (filter (lambda (p) (and (hash? p) (equal? (hash-ref p 'resourceType #f) "StructureDefinition")))
          (for/list ([n (in-list names)])
            (with-handlers ([exn:fail? (lambda (_) #f)])
              (call-with-input-file (build-path dir n) read-json)))))
(define (ref-error? oo)
  (for/or ([i (in-list (let ([v (hash-ref oo 'issue '())]) (if (list? v) v '())))])
    (member (hash-ref i 'severity #f) '("error" "fatal"))))

(define-values (agree caught missed fp skip)
  (for/fold ([agree 0] [caught 0] [missed 0] [fp 0] [skip 0])
            ([line (in-list (string-split (call-with-input-file (build-path dir "manifest.tsv") port->string) "\n"))]
             ;; 2 columns = case + java outcome; an optional 3rd names supporting profiles
             #:when (<= 2 (length (string-split line "\t"))))
    (define parts (string-split line "\t"))
    (define-values (js dups)
      (with-handlers ([exn:fail? (lambda (_) (values #f '()))])
        (call-with-input-file (build-path dir (car parts)) read-fhir-json/duplicates)))
    (cond
      [(not (hash? js)) (values agree caught missed fp (add1 skip))]   ; unparseable = parser-level test
      [else
       (define ref? (and (ref-error? (call-with-input-file (build-path dir "outcomes" (cadr parts)) read-json)) #t))
       (define supporting
         (if (>= (length parts) 3) (string-split (caddr parts) ",") '()))
       (define ours? (and (our-error? js dups (load-profiles supporting)) #t))
       (cond [(and (not ref?) (not ours?)) (values (add1 agree) caught missed fp skip)]
             [(and (not ref?) ours?)       (values agree caught missed (add1 fp) skip)]
             [(and ref? ours?)             (values agree (add1 caught) missed fp skip)]
             [else                         (values agree caught (add1 missed) fp skip)])])))

(printf "validator diff: clean-agree=~a caught=~a missed=~a FALSE-POSITIVE=~a skip=~a  (recall ~a/~a)\n"
        agree caught missed fp skip caught (+ caught missed))

(check-equal? fp 0 "the validator must never flag a resource the reference accepts")
(check-true (>= caught recall-floor) (format "recall regressed: caught ~a < floor ~a" caught recall-floor))
(check-true (>= agree 10) "clean cases stay clean")
