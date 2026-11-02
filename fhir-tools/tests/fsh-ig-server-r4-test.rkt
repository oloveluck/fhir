#lang racket/base

;;; fsh-ig-server-r4-test.rkt — spec in, server out: an IG's FSH sources (mCODE 4.0.0, from the fsh
;;; package's corpus) compiled and PACKED by this toolchain (fsh/project), then a FHIR server
;;; generated from that package (store/ig-server) — its sender CapabilityStatement, its dependencies
;;; (US Core 6.1.0, Genomics Reporting 2.0.0) resolved from fhir-spec — and the IG's own examples
;;; loaded through write validation against the IG's own profiles.
;;;
;;; Two oracles, ratcheted:
;;;   - the PUBLISHED mCODE package (SUSHI + IG Publisher) loads 283/283: the validator never rejects
;;;     an example the IG published as valid (this caught a slice-matching bug: a discriminator path
;;;     ending at a repeating element, category.coding, was compared as a list)
;;;   - OUR package: every example our compiler emits that does not validate against the profiles it
;;;     also compiled is an FSH compile gap (the same sources validate when SUSHI compiles them)

(require rackunit racket/file racket/list
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         fhir/store/ig-server
         fsh/project)

(define mcode-fsh (collection-file-path "tests/vendor/mcode-4.0.0/fsh" "fsh"))
(define cs "mcode-sender-patients-in-group")

(define (serve-and-load tgz)
  (define db (make-temporary-file "fsh-ig-~a.db"))
  (define store (open-fhir-store db))
  (define srv (make-ig-server store tgz #:capability cs))
  (define-values (accepted rejected) (load-ig-examples! srv))    ; accepted count, rejected list
  (close-fhir-store store) (delete-file db)
  (values srv accepted rejected))

(cond
  [(not (spec-package-path "hl7.fhir.us.mcode-4.0.0.tgz" #:optional? #t))
   (printf "  FSH -> package -> server: skipped (needs fhir-spec)\n")]
  [else
   ;; the published package: the validator's never-over-report oracle
   (define-values (psrv pn prejected) (serve-and-load (spec-package-path "hl7.fhir.us.mcode-4.0.0.tgz")))
   (for ([r (in-list prejected)]) (eprintf "  published example rejected ~a: ~a\n" (car r) (cdr r)))
   (check-equal? (length prejected) 0)
   (check-true (>= pn 283))
   ;; our package
   (define p (compile-project mcode-fsh))
   (check-equal? (project-diagnostics p) '())
   (define tgz (make-temporary-file "mcode-~a.tgz"))
   (pack-project! p tgz)
   (define-values (srv n rejected) (serve-and-load tgz))
   (check-equal? (ig-server-gaps srv) '())
   (check-equal? (length (ig-server-sd-packages srv)) 4)                ; mCODE, its 2 dependencies, R4 core
   (printf "  FSH -> package -> server (mCODE): 0 unmet requirements; ~a/~a of our compiled examples validate against our compiled profiles (published package: ~a/~a)\n"
           n (+ n (length rejected)) pn (+ pn (length prejected)))
   (check-true (>= n 283) "fewer of our examples validate than the floor")
   (delete-file tgz)])
