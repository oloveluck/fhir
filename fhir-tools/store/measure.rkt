#lang racket/base

;;; measure.rkt — CQL over the store: Measure evaluation ($evaluate-measure) and library runs.
;;;
;;; Everything comes from the store, the way a measure-processing server holds it:
;;;   - the Measure's Library (Measure.library canonical -> Library.url) and the libraries it includes
;;;     (by CQL library name = Library.name), their CQL in Library.content (text/cql, base64)
;;;   - value sets: stored ValueSets (expansion, else enumerated compose), then `#:valuesets`
;;   - each patient's data: per type, the resources whose patient / subject reference is the patient
;;     (through the type's search parameter; a full scan filtered by reference when it has none)
;;; A MeasureReport is `individual` for one subject, `summary` (population counts over every stored
;;; Patient, and the proportion score) without one. Proportion scoring, patient-based (cql/run).

(require racket/contract racket/list racket/string racket/match json net/base64
         (only-in cql/parser/parse parse-cql parse-cql-expr)
         (only-in cql/parser/ast cql-library?)
         (only-in cql/compile compile-expr)
         (only-in cql/interp eval-elm make-ienv)
         (only-in cql/value current-evaluation-offset render)
         (only-in cql/error cql-error? cql-error-string)
         cql/run
         (only-in fhir/result/result ok? ok-value err-error)
         "fhir-sqlite.rkt" "fhir-engine.rkt")

(provide
 (contract-out
  [evaluate-measure (->* (fhir-store? hash? string? string?)
                         (#:subject (or/c string? #f) #:search-params hash? #:valuesets procedure?
                          #:offset (or/c exact-integer? #f))
                         hash?)]
  [store-library    (-> fhir-store? string? (or/c cql-library? #f))]
  [store-patient-data (->* (fhir-store? string?) (#:search-params hash?) procedure?)]
  [store-valuesets  (-> fhir-store? procedure?)]
  [measurement-period (-> string? string? (or/c exact-integer? #f) any/c)]))

;; ---- libraries ------------------------------------------------------------------------------
;; library-cql : Library jsexpr -> string|#f   its text/cql content
(define (library-cql lib)
  (for/or ([c (in-list (hash-ref lib 'content '()))])
    (and (regexp-match? #rx"^text/cql" (hash-ref c 'contentType ""))
         (hash-ref c 'data #f)
         (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (hash-ref c 'data)))))))
(define (parse-library lib)
  (define src (library-cql lib))
  (and src (let ([r (parse-cql src)])
             (if (ok? r) (ok-value r)
                 (error 'evaluate-measure "Library ~a: ~a" (hash-ref lib 'url (hash-ref lib 'id ""))
                        (cql-error-string (err-error r)))))))
;; store-library : store canonical|name -> cql-library|#f   by url (|version ignored), else by name
(define (store-library store key)
  (define k (car (string-split key "|")))
  (define libs (fhir-search store "Library" '()))
  ;; by url; else the library NAMED like the canonical's last segment (CQL loaded locally for a
  ;; published Measure)
  (define last-seg (last (string-split k "/")))
  (define hit (or (findf (lambda (l) (equal? (hash-ref l 'url #f) k)) libs)
                  (findf (lambda (l) (equal? (hash-ref l 'name #f) k)) libs)
                  (findf (lambda (l) (equal? (hash-ref l 'name #f) last-seg)) libs)))
  (and hit (parse-library hit)))
;; include resolver: the stored Library named like the CQL library (version preferred)
(define ((store-resolver store) name version)
  (define libs (filter (lambda (l) (equal? (hash-ref l 'name #f) (symbol->string name))) (fhir-search store "Library" '())))
  (define hit (or (findf (lambda (l) (equal? (hash-ref l 'version #f) version)) libs) (and (pair? libs) (car libs))))
  (and hit (parse-library hit)))

;; ---- terminology ----------------------------------------------------------------------------
;; store-valuesets : store -> (url -> members|#f)   from the stored ValueSets
(define (store-valuesets store) (valuesets->terminology (fhir-search store "ValueSet" '())))

;; ---- patient data ---------------------------------------------------------------------------
;; store-patient-data : store patient-id -> (type -> (listof resource))
(define (store-patient-data store pid #:search-params [sps default-search-params])
  (define ref (string-append "Patient/" pid))
  (define cache (make-hash))
  (lambda (type)
    (hash-ref! cache type
               (lambda ()
                 (cond
                   [(equal? type "Patient") (let ([p (fhir-read store "Patient" pid)]) (if p (list p) '()))]
                   [else
                    (or (for/or ([param (in-list '("patient" "subject" "beneficiary"))])
                          (define-values (rs ignored) (fhir-search/ignored store type (list (cons param ref)) #:search-params sps))
                          (and (not (member param ignored)) rs))
                        ;; no patient search parameter: scan and match the reference
                        (filter (lambda (r) (for/or ([k (in-list '(subject patient beneficiary))])
                                              (let ([v (hash-ref r k #f)]) (and (hash? v) (equal? (hash-ref v 'reference #f) ref)))))
                                (fhir-search store type '() #:search-params sps)))])))))

;; ---- evaluation -----------------------------------------------------------------------------
;; measurement-period : periodStart periodEnd offset -> Interval<DateTime>   whole days, end inclusive
(define (measurement-period start end offset)
  (define (day s) (substring s 0 (min 10 (string-length s))))
  (parameterize ([current-evaluation-offset offset])
    (eval-elm (ok-value (compile-expr (ok-value (parse-cql-expr
                                                 (format "Interval[@~aT00:00:00.000, @~aT23:59:59.999]" (day start) (day end))))))
              (make-ienv))))

;; evaluate-measure : store Measure periodStart periodEnd … -> MeasureReport jsexpr
(define (evaluate-measure store measure start end #:subject [subject #f] #:search-params [sps default-search-params]
                          #:valuesets [extra-vs (lambda (u) #f)] #:offset [offset #f])
  (define lib-url (let ([l (hash-ref measure 'library '())]) (and (pair? l) (car l))))
  (define lib (or (and lib-url (store-library store lib-url))
                  (error 'evaluate-measure "Measure ~a: its Library ~a is not in the store" (hash-ref measure 'id "") lib-url)))
  (define stored-vs (store-valuesets store))
  (define (valuesets url) (or (stored-vs url) (extra-vs url)))
  (define mp (measurement-period start end offset))
  (define (populations pid)
    (define rl (load-runtime-library lib #:resolver (store-resolver store) #:data (store-patient-data store pid #:search-params sps)
                                     #:valuesets valuesets #:parameters (hash "Measurement Period" mp) #:offset offset))
    (with-handlers ([cql-error? (lambda (e) (error 'evaluate-measure "Patient/~a: ~a" pid (cql-error-string e)))])
      (measure-populations measure rl)))
  (define pids (if subject
                   (list (regexp-replace #rx"^Patient/" subject ""))
                   (for/list ([p (in-list (fhir-search store "Patient" '()))]) (hash-ref p 'id))))
  (define counts
    (for/fold ([acc (hash)]) ([pid (in-list pids)])
      (for/fold ([acc acc]) ([(k v) (in-hash (populations pid))]) (hash-update acc k (lambda (n) (+ n v)) 0))))
  (measure-report measure counts start end subject))

(define population-order '("initial-population" "denominator" "denominator-exclusion" "denominator-exception" "numerator"))
(define (measure-report measure counts start end subject)
  (define (c k) (hash-ref counts k 0))
  (define denom (- (c "denominator") (c "denominator-exclusion") (c "denominator-exception")))
  (define group
    (hasheq 'population (for/list ([k (in-list population-order)] #:when (hash-has-key? counts k))
                          (hasheq 'code (hasheq 'coding (list (hasheq 'system "http://terminology.hl7.org/CodeSystem/measure-population"
                                                                      'code k)))
                                  'count (c k)))))
  (define group* (if (and (not subject) (> denom 0))
                     (hash-set group 'measureScore (hasheq 'value (exact->inexact (/ (c "numerator") denom))))
                     group))
  (define base (hasheq 'resourceType "MeasureReport" 'status "complete"
                       'type (if subject "individual" "summary")
                       'measure (or (hash-ref measure 'url #f) (string-append "Measure/" (hash-ref measure 'id "")))
                       'period (hasheq 'start start 'end end)
                       'group (list group*)))
  (if subject (hash-set base 'subject (hasheq 'reference (if (regexp-match? #rx"/" subject) subject (string-append "Patient/" subject)))) base))
