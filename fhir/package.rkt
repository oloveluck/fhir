#lang racket/base

;;; package.rkt — read a FHIR NPM package (.tgz): its manifest, its resources, its examples.
;;;
;;; A package is package/package.json (the manifest), package/*.json (conformance and definitional
;;; resources) and package/example/*.json (examples); `.index.json` files and anything else are
;;; skipped. One untar pass, streamed through a pipe (the tarballs reach tens of MB).
;;;
;;; read-package : tgz [#:exact-decimals? b #:select file->bool] -> (values manifest resources examples)
;;;   manifest  : jsexpr | #f
;;;   resources : (listof (cons file-name jsexpr))   package/*.json, in archive order
;;;   examples  : (listof (cons file-name jsexpr))   package/example/*.json, in archive order
;;; #:exact-decimals? reads decimals as their lexemes (fhir/serialize/read-json), for callers that
;;; validate or compare values; plain jsexprs otherwise. #:select keeps only the files whose name it
;;; accepts (`OperationDefinition-…json`) — the others are not parsed, which matters for core
;;; packages. Unparseable files are skipped.

(require racket/contract racket/list racket/string
         file/untar file/gunzip
         (only-in json bytes->jsexpr)
         (only-in "serialize/read-json.rkt" string->fhir-jsexpr))

(define entry/c (cons/c string? hash?))
(provide
 (contract-out
  [read-package (->* (path-string?) (#:exact-decimals? boolean? #:select (-> string? any/c))
                     (values (or/c hash? #f) (listof entry/c) (listof entry/c)))]))

(define (read-package tgz #:exact-decimals? [exact? #f] #:select [select? (lambda (_) #t)])
  (define manifest #f)
  (define resources '())
  (define examples '())
  (define (parse bs)
    (with-handlers ([exn:fail? (lambda (_) #f)])
      (if exact? (string->fhir-jsexpr (bytes->string/utf-8 bs #\?)) (bytes->jsexpr bs))))
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate (thread (lambda ()
                            (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                            (close-output-port pout))))
  (untar pin #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define n (path->string name))
             (define bs (if (= size 0) #"" (read-bytes size content)))
             (define file (last (string-split n "/")))
             (define (entry) (and (select? file) (let ([j (parse bs)]) (and (hash? j) (cons file j)))))
             (cond [(equal? n "package/package.json") (set! manifest (parse bs))]
                   [(regexp-match? #px"^package/[^./][^/]*\\.json$" n)
                    (define e (entry)) (when e (set! resources (cons e resources)))]
                   [(regexp-match? #px"^package/example/[^./][^/]*\\.json$" n)
                    (define e (entry)) (when e (set! examples (cons e examples)))]))
           '()))
  (thread-wait inflate)
  (values (and (hash? manifest) manifest) (reverse resources) (reverse examples)))

(module+ test
  (require rackunit (only-in "spec-package.rkt" spec-package-path))
  (define tgz (spec-package-path "hl7.fhir.uv.ips.tgz" #:optional? #t))
  (when tgz
    (define-values (m rs exs) (read-package tgz))
    (check-equal? (hash-ref m 'name) "hl7.fhir.uv.ips")
    (check-true (for/or ([r (in-list rs)]) (equal? (hash-ref (cdr r) 'resourceType #f) "StructureDefinition")))
    (check-true (pair? exs))
    (check-false (assoc "package.json" rs))
    (check-false (for/or ([r (in-list rs)]) (regexp-match? #rx"^[.]" (car r))))
    (define-values (_m sds _e) (read-package tgz #:select (lambda (f) (regexp-match? #rx"^StructureDefinition-" f))))
    (check-true (and (pair? sds) (for/and ([r (in-list sds)]) (equal? (hash-ref (cdr r) 'resourceType) "StructureDefinition"))))))
