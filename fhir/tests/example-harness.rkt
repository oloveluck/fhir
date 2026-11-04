#lang racket/base

;;; example-harness.rkt — a broad conformance corpus: round-trip every real FHIR resource we can find
;;; through the type towers + serializer. For each resource: parse leniently (from-json), serialize
;;; (node->jsexpr), re-parse, and require the serializer be idempotent (a stable, re-parseable JSON
;;; view). Lenient parsing means unmodelled corners are dropped rather than failing — the test is that
;;; nothing crashes and the round-trip is stable. Drives the vendored fhir-test-cases examples AND
;;; (streaming) every resource in a vendored core package .tgz. The caller loads the matching tower
;;; and names it (`#:tower`) so the worker places that share the work can load it too
;;; (fhir/parallel: every core, results in corpus order); without a tower the run is sequential.

(require racket/contract racket/file racket/list
         json
         (only-in fhir/parallel parallel-map default-workers)
         file/gunzip
         file/untar
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/serialize/read-json read-fhir-json)
         (only-in fhir/result/result ok? ok-value)
         (only-in fhir/model/registry type-registered?))

(provide
 (contract-out
  [roundtrip-result (-> any/c symbol?)]                 ; 'ok | 'parse-fail | 'reparse-fail | 'not-idempotent
  [run-dir          (->* (path-string?) (#:tower (or/c module-path? #f)) (values exact-integer? (listof (cons/c string? symbol?))))]
  [run-package      (->* (path-string?) (#:tower (or/c module-path? #f)) (values exact-integer? (listof (cons/c string? symbol?))))]
  [verdict          (-> any/c symbol?)]
  ;; what the worker processes run (fhir/parallel): one file, one shard of a package
  [file-finding     (-> list? (or/c list? #f))]
  [package-shard    (-> list? list?)]))

;; one resource jsexpr -> a round-trip verdict
(define (roundtrip-result js)
  (define r1 (from-json js #:lenient? #t))
  (cond
    [(not (ok? r1)) 'parse-fail]
    [else
     (define j1 (node->jsexpr (ok-value r1)))
     (define r2 (from-json j1 #:lenient? #t))
     (cond
       [(not (ok? r2)) 'reparse-fail]
       [(equal? (node->jsexpr (ok-value r2)) j1) 'ok]
       [else 'not-idempotent])]))

;; fhir-resource? : Any -> Boolean   a resource whose type this tower models (unknown types — e.g. a
;; resource renamed across versions — are skipped, not failed)
(define (fhir-resource? js)
  (and (hash? js)
       (let ([rt (hash-ref js 'resourceType #f)])
         (and (string? rt) (type-registered? (string->symbol rt))))))

;; verdict : jsexpr -> Symbol   roundtrip-result, an exception counting as the verdict 'exn
(define (verdict js) (with-handlers ([exn:fail? (lambda (_) 'exn)]) (roundtrip-result js)))

;; A Finding is (list ordinal name verdict): one resource's verdict, with its place in the corpus.
;; count : (listof Finding) -> (values passes failures)   in corpus order
(define (count findings)
  (for/fold ([pass 0] [fails '()] #:result (values pass (reverse fails)))
            ([f (in-list (sort findings < #:key car))])
    (if (eq? (caddr f) 'ok) (values (add1 pass) fails) (values pass (cons (cons (cadr f) (caddr f)) fails)))))

;; workers : module-path|#f -> Nat   every core when a tower is named (the workers must load it)
(define (workers tower) (if tower (default-workers) 1))

;; run-dir : directory [#:tower] -> (values passes failures)   every *.json FHIR resource in it;
;; each worker reads its own files (only paths and verdicts cross to it)
(define (run-dir dir #:tower [tower #f])
  (define files (sort (for/list ([p (in-list (directory-list dir))]
                                 #:when (regexp-match? #rx"[.]json$" (path->string p)))
                        (path->string p))
                      string<?))
  (define findings
    (parallel-map '(fhir/tests/example-harness file-finding)
                  (for/list ([f (in-list files)] [i (in-naturals)]) (list i f (path->string (build-path dir f))))
                  #:workers (workers tower) #:setup tower))
  (count (filter values findings)))

;; file-finding : (list ordinal name path) -> Finding | #f   #f when the file is not a FHIR resource
(define (file-finding item)
  (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr (file->string (caddr item)))))
  (and (fhir-resource? js) (list (car item) (cadr item) (verdict js))))

;; run-package : core .tgz [#:tower] -> (values passes failures)   every conformance resource it
;; holds. The archive is streamed (gunzip -> untar, no disk extract) by EACH worker, which keeps
;; every k-th resource: the package is ~100 MB of JSON, far more than its verdicts, so the data
;; stays where it is read and only (ordinal name verdict) crosses back.
(define (run-package tgz #:tower [tower #f])
  (define k (workers tower))
  (define shards (parallel-map '(fhir/tests/example-harness package-shard)
                               (for/list ([i (in-range k)]) (list (path->string (simplify-path (path->complete-path tgz))) i k))
                               #:workers k #:setup tower))
  (count (append* shards)))

;; package-shard : (list tgz-path i k) -> (listof Finding)   the i-th of every k resources' verdicts
(define (package-shard item)
  (define tgz (car item)) (define i (cadr item)) (define k (caddr item))
  (define findings '())
  (define ordinal 0)
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate (thread (lambda () (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                                 (close-output-port pout))))
  (untar pin
         #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define bytes (if (= size 0) #"" (read-bytes size content)))
             (when (regexp-match? #px"^package/.*\\.json$" (path->string name))
               (when (= (modulo ordinal k) i)
                 (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bytes)))
                 (when (fhir-resource? js)
                   (set! findings (cons (list ordinal (path->string name) (verdict js)) findings))))
               (set! ordinal (add1 ordinal))))
           '()))
  (thread-wait inflate)
  (reverse findings))
