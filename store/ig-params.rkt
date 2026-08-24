#lang racket/base

;;; ig-params.rkt — build the search-param catalog FROM an IG/core package's own SearchParameter
;;; resources (the package is the single source of truth: the same artifact that generates the type
;;; tower and drives validation now also drives search).
;;;
;;; A SearchParameter resource carries exactly what the engine needs:
;;;   code       -> the query parameter name
;;;   base       -> the resource types it applies to
;;;   type       -> token | reference | date | string | … (the engine INDEXES token+reference and
;;;                 handles _lastUpdated dates; other kinds are still cataloged so the
;;;                 CapabilityStatement can advertise them)
;;;   expression -> the FHIRPath — often multi-base ("Patient.name | Person.name"): for each base we
;;;                 keep only the UNION BRANCHES rooted at that type (or unrooted), by walking the
;;;                 parsed AST (fp-binop 'union) and printing the kept branches back — never string
;;;                 surgery.

(require racket/contract racket/string racket/list
         json file/gunzip file/untar
         "fhir-engine.rkt"
         (only-in "../fhirpath/parser/parse.rkt" parse-fhirpath)
         (only-in "../fhirpath/parser/ast.rkt" fp-binop fp-binop? fp-binop-op fp-binop-lhs fp-binop-rhs
                  fp-invoke fp-invoke? fp-invoke-target fp-invoke-name
                  fp-call fp-call? fp-call-target fp-call-name fp-call-args
                  fp-typeop? fp-typeop-op fp-typeop-operand)
         (only-in "../fml/fhirpath-print.rkt" fhirpath->string))

(provide
 (contract-out
  ;; package tgz [+ type filter] -> hash type-sym -> (listof search-param)
  [search-params-from-package
   (->* (path-string?) (#:types (or/c #f (listof symbol?))) (hash/c symbol? (listof search-param?)))]
  ;; merge catalogs (later entries win per (type, name))
  [merge-search-params (-> (hash/c symbol? list?) (hash/c symbol? list?) (hash/c symbol? list?))]))

;; ---- package streaming -------------------------------------------------------
(define sp-file-rx #px"^package/SearchParameter-.*\\.json$")

(define (search-params-from-package tgz #:types [types #f])
  (define catalog (make-hash))    ; type-sym -> reversed (listof search-param)
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate (thread (lambda ()
                            (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                            (close-output-port pout))))
  (untar pin #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define bs (if (= size 0) #"" (read-bytes size content)))
             (when (regexp-match? sp-file-rx (path->string name))
               (define sp (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bs)))
               (when (hash? sp) (add-search-parameter! catalog sp types))))
           '()))
  (thread-wait inflate)
  (for/hash ([(k v) (in-hash catalog)]) (values k (reverse v))))

;; one SearchParameter resource -> catalog entries (one per applicable base type)
(define (add-search-parameter! catalog sp types)
  (define code (hash-ref sp 'code #f))
  (define ptype (hash-ref sp 'type #f))
  (define expr (hash-ref sp 'expression #f))
  (define bases (let ([b (hash-ref sp 'base '())]) (if (list? b) b '())))
  (when (and (string? code) (string? ptype) (string? expr))
    (for ([base (in-list bases)] #:when (string? base))
      (define ty (string->symbol base))
      (when (or (not types) (memq ty types))
        (define e (expression-for-base expr base))
        (when e
          (hash-update! catalog ty
                        (lambda (l) (cons (search-param code (string->symbol ptype) e) l))
                        '()))))))

;; ---- multi-base expression filtering (AST-level) -----------------------------
;; keep the union branches applicable to `base`: rooted at the base type, or unrooted (lowercase
;; head — a relative path), or wrapped forms we can't classify (kept, fail-open)
(define (expression-for-base expr base)
  (define ast (with-handlers ([exn:fail? (lambda (_) #f)]) (parse-fhirpath expr)))
  (cond
    [(not ast) #f]
    [else
     (define kept (map drop-resolve-guard
                       (filter (lambda (b) (branch-applies? b base)) (union-branches ast))))
     (cond [(null? kept) #f]
           [else (fhirpath->string (foldr1 (lambda (l r) (fp-binop 'union l r)) kept))])]))

;; drop the trailing `.where(resolve() is Type)` guard reference params carry (e.g.
;; `Observation.subject.where(resolve() is Patient)`): at INDEX time the reference is stored with
;; its target type, so the type restriction is enforced by the search value (`Patient/id`), not by
;; resolving during extraction — resolving there would drop every reference to a not-loaded resource
(define (drop-resolve-guard b)
  (if (and (fp-call? b) (eq? (fp-call-name b) 'where)
           (pair? (fp-call-args b)) (resolve-is? (car (fp-call-args b))))
      (fp-call-target b)
      b))
(define (resolve-is? a)
  (and (fp-typeop? a) (eq? (fp-typeop-op a) 'is)
       (let ([op (fp-typeop-operand a)])
         (and (fp-call? op) (eq? (fp-call-name op) 'resolve) (null? (fp-call-args op))))))

(define (union-branches ast)
  (if (and (fp-binop? ast) (eq? (fp-binop-op ast) 'union))
      (append (union-branches (fp-binop-lhs ast)) (union-branches (fp-binop-rhs ast)))
      (list ast)))

;; the branch's chain-head member name: rooted (Capitalized type) or relative
(define (branch-applies? b base)
  (define head (chain-head b))
  (cond [(not head) #t]                                        ; unclassifiable -> keep (fail open)
        [(char-upper-case? (string-ref head 0)) (string=? head base)]
        [else #t]))
(define (chain-head b)
  (cond [(fp-invoke? b)
         (if (fp-invoke-target b) (chain-head (fp-invoke-target b)) (symbol->string (fp-invoke-name b)))]
        [(and (fp-call? b) (fp-call-target b)) (chain-head (fp-call-target b))]  ; f(...) wrapper, e.g. .where(…)
        [else #f]))

(define (foldr1 f xs) (if (null? (cdr xs)) (car xs) (f (car xs) (foldr1 f (cdr xs)))))

;; ---- catalog merge -----------------------------------------------------------
(define (merge-search-params base extra)
  (for/fold ([acc base]) ([(ty sps) (in-hash extra)])
    (hash-update acc ty
                 (lambda (old)
                   (define names (map search-param-name sps))
                   (append (filter (lambda (o) (not (member (search-param-name o) names))) old) sps))
                 '())))

(module+ test
  (require rackunit racket/runtime-path)
  (define-runtime-path r5 "../spec/hl7.fhir.r5.core.tgz")
  (define cat (search-params-from-package r5 #:types '(Patient Observation)))
  (define (names ty) (map search-param-name (hash-ref cat ty '())))
  ;; the core package's own SearchParameters drive the catalog
  (check-true (and (member "gender" (names 'Patient)) #t))
  (check-true (and (member "identifier" (names 'Patient)) #t))
  (check-true (and (member "code" (names 'Observation)) #t))
  (check-true (and (member "subject" (names 'Observation)) #t))
  ;; multi-base expressions keep only the branch for the base type
  (define pat-gender (findf (lambda (s) (equal? (search-param-name s) "gender")) (hash-ref cat 'Patient)))
  (check-equal? (search-param-kind pat-gender) 'token)
  (check-true (regexp-match? #px"^Patient" (search-param-path pat-gender)))
  (check-false (regexp-match? #px"Person" (search-param-path pat-gender)))
  ;; reference params: multi-base narrowed + `.where(resolve() is Patient)` guard dropped
  (define obs-patient (findf (lambda (s) (equal? (search-param-name s) "patient")) (hash-ref cat 'Observation)))
  (check-equal? (search-param-kind obs-patient) 'reference)
  (check-equal? (search-param-path obs-patient) "Observation.subject")
  ;; merge: extras win per name
  (define merged (merge-search-params cat (hash 'Patient (list (search-param "gender" 'token "gender")))))
  (check-equal? (search-param-path
                 (findf (lambda (s) (equal? (search-param-name s) "gender")) (hash-ref merged 'Patient)))
                "gender"))
