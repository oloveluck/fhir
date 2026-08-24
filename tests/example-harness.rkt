#lang racket/base

;;; example-harness.rkt — a broad conformance corpus: round-trip every real FHIR resource we can find
;;; through the type towers + serializer. For each resource: parse leniently (from-json), serialize
;;; (node->jsexpr), re-parse, and require the serializer be idempotent (a stable, re-parseable JSON
;;; view). Lenient parsing means unmodelled corners are dropped rather than failing — the test is that
;;; nothing crashes and the round-trip is stable. Drives the vendored fhir-test-cases examples AND
;;; (streaming) every resource in a vendored core package .tgz. The caller loads the matching tower.

(require racket/contract
         json
         file/gunzip
         file/untar
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../serialize/to-json.rkt" node->jsexpr)
         (only-in "../serialize/read-json.rkt" read-fhir-json)
         (only-in "../result/result.rkt" ok? ok-value)
         (only-in "../model/registry.rkt" type-registered?))

(provide
 (contract-out
  [roundtrip-result (-> any/c symbol?)]                 ; 'ok | 'parse-fail | 'reparse-fail | 'not-idempotent
  [run-dir          (-> path-string? (values exact-integer? (listof (cons/c string? symbol?))))]
  [run-package      (-> path-string? (values exact-integer? (listof (cons/c string? symbol?))))]))

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

;; a resource whose type this tower models (unknown types — e.g. a resource renamed across versions —
;; are skipped, not failed)
(define (fhir-resource? js)
  (and (hash? js)
       (let ([rt (hash-ref js 'resourceType #f)])
         (and (string? rt) (type-registered? (string->symbol rt))))))

;; round-trip every *.json FHIR resource in a directory
(define (run-dir dir)
  (define files (sort (for/list ([p (in-list (directory-list dir))]
                                 #:when (regexp-match? #rx"[.]json$" (path->string p)))
                        (path->string p))
                      string<?))
  (define pass 0) (define fails '())
  (for ([f (in-list files)])
    (define js (with-handlers ([exn:fail? (lambda (_) #f)])
                 (call-with-input-file (build-path dir f) read-fhir-json)))
    (when (fhir-resource? js)
      (define v (with-handlers ([exn:fail? (lambda (_) 'exn)]) (roundtrip-result js)))
      (if (eq? v 'ok) (set! pass (add1 pass)) (set! fails (cons (cons f v) fails)))))
  (values pass (reverse fails)))

;; stream a core package .tgz and round-trip every conformance resource it holds
(define (run-package tgz)
  (define pass 0) (define fails '())
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate (thread (lambda () (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                                 (close-output-port pout))))
  (untar pin
         #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define bytes (if (= size 0) #"" (read-bytes size content)))
             (when (regexp-match? #px"^package/.*\\.json$" (path->string name))
               (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bytes)))
               (when (fhir-resource? js)
                 (define v (with-handlers ([exn:fail? (lambda (_) 'exn)]) (roundtrip-result js)))
                 (if (eq? v 'ok) (set! pass (add1 pass))
                     (set! fails (cons (cons (path->string name) v) fails))))))
           '()))
  (thread-wait inflate)
  (values pass (reverse fails)))
