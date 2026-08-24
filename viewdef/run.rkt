#lang racket/base

;;; run.rkt — the $sql-run engine (and a synchronous $sql-export) behind the SOF IG's generated
;;; operation scaffolding (viewdef/operations.rkt).
;;;
;;; $sql-run per the IG's OperationDefinition:
;;;   subject      : EXACTLY ONE of subjectCanonical (url[|version] of a stored ViewDefinition),
;;;                  subjectReference ("ViewDefinition/id" on this server), subjectResource
;;;                  (inline). None or several -> invalid (400).
;;;   data         : inline `resource` parameters when supplied (a Bundle is UNWRAPPED to its
;;;                  entry resources), else the server's resources of view.resource's type;
;;;                  `patient` restricts to resources referencing (or being) those patients;
;;;                  `_since` keeps resources with meta.lastUpdated > instant.
;;;   _format      : ndjson (DEFAULT) | json | csv (+ `header`, default true) | fhir | parquet.
;;;                  parquet is not supported (not-supported OperationOutcome); fhir returns a
;;;                  Parameters resource; the rest return a Binary node whose contentType/data the
;;;                  HTTP layer streams RAW (the spec's "raw binary stream", not a Binary envelope).
;;;   _limit       : caps the ROW count after evaluation.
;;;
;;; $sql-export here is the synchronous-completion profile: every subject runs immediately and the
;;; manifest comes back completed, one `output` part per subject with the result inline as a
;;; contained Binary. No job store, no polling, no cancel.
;;;
;;; The handlers are closed over two capabilities the SERVER supplies (store/serve.rkt):
;;;   resolve-view : ('canonical|'reference) × string -> ViewDefinition node | #f
;;;   resources-of : type-string -> (listof fhir?)     (current server data of that type)

(require racket/contract racket/list racket/string racket/match
         json net/base64
         "schema/ViewDefinition.rkt"              ; registers ViewDefinition (vs any core tower)
         (only-in "eval.rkt" eval-view view-columns)
         (only-in "../model/node.rkt" fhir? fhir-type fhir-ref)
         (only-in "../model/base.rkt" primitive-type? primitive-type-value)
         (only-in "../model/leaf.rkt" pv listify node-str)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../serialize/to-json.rkt" node->jsexpr)
         (only-in "../result/result.rkt" ok? ok-value ok-or-raise))

(provide
 (contract-out
  [make-sql-run-handler
   (-> #:resolve-view (-> symbol? string? (or/c fhir? #f))
       #:resources-of (-> string? (listof fhir?))
       (-> hash? any/c any/c))]
  [make-sql-export-handler
   (-> #:resolve-view (-> symbol? string? (or/c fhir? #f))
       #:resources-of (-> string? (listof fhir?))
       (-> hash? any/c any/c))]
  ;; pure row formatters (exposed for tests)
  [rows->csv    (->* ((listof symbol?) (listof list?)) (#:header? boolean?) string?)]
  [rows->ndjson (-> (listof list?) string?)]
  [rows->json   (-> (listof list?) string?)]))

;; ---- small helpers (pv/listify/node-str from model/leaf) ---------------------
(define (one in name) (match (hash-ref in name '()) [(list v) v] [_ #f]))

(define (oo severity code diag)
  (ok-or-raise (from-json (hasheq 'resourceType "OperationOutcome"
                                  'issue (list (hasheq 'severity severity 'code code
                                                       'diagnostics diag))))))
(define (invalid diag) (oo "error" "invalid" diag))

;; ---- subject resolution -----------------------------------------------------
;; -> ViewDefinition node | OperationOutcome node (the caller pattern-matches on fhir-type)
(define (resolve-subject in resolve-view)
  (define canonical (one in "subjectCanonical"))
  (define reference (one in "subjectReference"))
  (define inline (one in "subjectResource"))
  (define supplied (length (filter values (list canonical reference inline))))
  (cond
    [(not (= supplied 1))
     (invalid (format "exactly one of subjectCanonical, subjectReference and subjectResource must be supplied; got ~a" supplied))]
    [inline (if (and (fhir? inline) (eq? (fhir-type inline) 'ViewDefinition))
                inline
                (invalid "subjectResource must be a ViewDefinition"))]
    [canonical (or (resolve-view 'canonical (format "~a" canonical))
                   (invalid (format "no ViewDefinition with canonical ~a" canonical)))]
    [else
     ;; a Reference node or a plain string; take its reference string
     (define ref (if (fhir? reference) (node-str reference 'reference) (format "~a" reference)))
     (or (and ref (resolve-view 'reference ref))
         (invalid (format "cannot resolve subjectReference ~a" (or ref reference))))]))

;; ---- data gathering ---------------------------------------------------------
;; inline `resource` params (Bundles unwrapped), else the server's data for the view's type
(define (gather-resources in view resources-of)
  (define inline (hash-ref in "resource" '()))
  (define base
    (cond
      [(pair? inline)
       (append* (for/list ([r (in-list inline)])
                  (cond [(and (fhir? r) (eq? (fhir-type r) 'Bundle))
                         (filter values (for/list ([e (in-list (listify (fhir-ref r 'entry '())))])
                                          (fhir-ref e 'resource #f)))]
                        [(fhir? r) (list r)]
                        [else '()])))]
      [else (resources-of (format "~a" (pv (fhir-ref view 'resource #f))))]))
  (filter-since (filter-patients base (hash-ref in "patient" '())) (one in "_since")))

;; keep resources belonging to one of the given patients: subject/patient reference match, or the
;; resource IS one of the patients
(define (filter-patients rs patients)
  (cond
    [(null? patients) rs]
    [else
     (define wanted
       (filter values (for/list ([p (in-list patients)])
                        (if (fhir? p) (node-str p 'reference) (format "~a" p)))))
     (for/list ([r (in-list rs)]
                #:when (or (patient-of? r wanted)
                           (and (eq? (fhir-type r) 'Patient)
                                (member (string-append "Patient/" (or (node-str r 'id) "")) wanted))))
       r)]))
(define (patient-of? r wanted)
  (for/or ([key (in-list '(subject patient))])
    (define ref (let ([v (fhir-ref r key #f)]) (and v (fhir? v) (node-str v 'reference))))
    (and ref (member ref wanted) #t)))

;; meta.lastUpdated > _since (ISO-8601 compares lexicographically)
(define (filter-since rs since)
  (cond
    [(not since) rs]
    [else (define s (format "~a" since))
          (for/list ([r (in-list rs)]
                     #:when (let* ([meta (fhir-ref r 'meta #f)]
                                   [lu (and meta (node-str meta 'lastUpdated))])
                              (and lu (string>? lu s))))
            r)]))

;; ---- formatting -------------------------------------------------------------
;; A Row is eval-view's ordered (Listof (cons col jsexpr)).
(define (row->hash row) (for/hasheq ([c (in-list row)]) (values (car c) (cdr c))))

(define (rows->json rows) (jsexpr->string (map row->hash rows)))
(define (rows->ndjson rows)
  (string-append (string-join (for/list ([r (in-list rows)]) (jsexpr->string (row->hash r))) "\n")
                 (if (null? rows) "" "\n")))

;; RFC-4180: quote fields containing comma/quote/CR/LF; a quote doubles
(define (csv-field v)
  (define s (cond [(eq? v 'null) ""] [(boolean? v) (if v "true" "false")]
                  [(list? v) (jsexpr->string v)] [else (format "~a" v)]))
  (if (regexp-match? #px"[\",\r\n]" s)
      (string-append "\"" (string-replace s "\"" "\"\"") "\"")
      s))
(define (rows->csv cols rows #:header? [header? #t])
  (define lines
    (append (if header? (list (string-join (map symbol->string cols) ",")) '())
            (for/list ([r (in-list rows)])
              (string-join (for/list ([c (in-list cols)])
                             (csv-field (cond [(assq c r) => cdr] [else 'null])))
                           ","))))
  (string-append (string-join lines "\r\n") (if (null? lines) "" "\r\n")))

;; rows -> a FHIR Parameters resource (one `row` parameter, one part per non-null column)
(define (rows->parameters rows)
  (ok-or-raise
   (from-json
    (hasheq 'resourceType "Parameters"
            'parameter (for/list ([r (in-list rows)])
                         (hasheq 'name "row"
                                 'part (filter values (map cell->part r))))))))
(define (cell->part cell)
  (match-define (cons col v) cell)
  (define name (symbol->string col))
  (cond [(eq? v 'null) #f]
        [(boolean? v) (hasheq 'name name 'valueBoolean v)]
        [(exact-integer? v) (hasheq 'name name 'valueInteger v)]
        [(real? v) (hasheq 'name name 'valueDecimal v)]
        [(list? v) (hasheq 'name name 'valueString (jsexpr->string v))]
        [else (hasheq 'name name 'valueString (format "~a" v))]))

;; make-binary : content-type × string -> a Binary node (the HTTP layer streams it raw)
(define (make-binary content-type body)
  (ok-or-raise
   (from-json (hasheq 'resourceType "Binary" 'contentType content-type
                      'data (bytes->string/utf-8
                             (base64-encode (string->bytes/utf-8 body) #""))))))

;; ---- $sql-run ---------------------------------------------------------------
(define (make-sql-run-handler #:resolve-view resolve-view #:resources-of resources-of)
  (lambda (in req)
    (define subject (resolve-subject in resolve-view))
    (cond
      [(eq? (fhir-type subject) 'OperationOutcome) subject]
      [else
       (define fmt (or (and (one in "_format") (format "~a" (one in "_format"))) "ndjson"))
       (define rows-all (eval-view subject (gather-resources in subject resources-of)))
       (define rows (let ([lim (one in "_limit")])
                      (if (and (exact-integer? lim) (>= lim 0)) (take rows-all (min lim (length rows-all)))
                          rows-all)))
       (match fmt
         ["ndjson" (make-binary "application/x-ndjson" (rows->ndjson rows))]
         ["json"   (make-binary "application/json" (rows->json rows))]
         ["csv"    ;; absent -> #t; explicit false arrives as #f (POST Parameters) or "false" (GET query)
                   (define header? (not (member (hash-ref in "header" '()) '((#f) ("false")))))
                   (make-binary "text/csv" (rows->csv (view-columns subject) rows #:header? header?))]
         ["fhir"   (rows->parameters rows)]
         ["parquet" (oo "error" "not-supported" "parquet output is not supported")]
         [_ (invalid (format "unknown _format ~a" fmt))])])))

;; ---- $sql-export (synchronous completion) -----------------------------------
;; every subject runs NOW; the manifest returns completed with one output part per subject,
;; the result inline as a Binary. exportId is a content-independent counter per process.
(define export-counter (box 0))
(define (make-sql-export-handler #:resolve-view resolve-view #:resources-of resources-of)
  (lambda (in req)
    (define subjects (hash-ref in "subject" '()))
    (cond
      [(null? subjects) (invalid "at least one subject is required")]
      [else
       (define fmt (or (and (one in "_format") (format "~a" (one in "_format"))) "ndjson"))
       (define outputs
         (for/list ([s (in-list subjects)])
           (define view
             (cond [(and (fhir? s) (eq? (fhir-type s) 'ViewDefinition)) s]
                   [(fhir? s) (let ([ref (node-str s 'reference)])
                                (and ref (resolve-view 'reference ref)))]
                   [else (resolve-view 'canonical (format "~a" s))]))
           (cond
             [(not view) (hasheq 'name "output"
                                 'part (list (hasheq 'name "error"
                                                     'valueString (format "unresolvable subject ~a" s))))]
             [else
              (define rows (eval-view view (gather-resources in view resources-of)))
              (define body (match fmt
                             ["csv" (rows->csv (view-columns view) rows)]
                             ["json" (rows->json rows)]
                             [_ (rows->ndjson rows)]))
              (hasheq 'name "output"
                      'part (list (hasheq 'name "name"
                                          'valueString (or (node-str view 'name) "view"))
                                  (hasheq 'name "result"
                                          'resource (node->jsexpr (make-binary
                                                                   (match fmt
                                                                     ["csv" "text/csv"]
                                                                     ["json" "application/json"]
                                                                     [_ "application/x-ndjson"])
                                                                   body)))))])))
       (define id (begin (set-box! export-counter (add1 (unbox export-counter)))
                         (format "export-~a" (unbox export-counter))))
       (ok-or-raise
        (from-json
         (hasheq 'resourceType "Parameters"
                 'parameter (append
                             (list (hasheq 'name "exportId" 'valueString id)
                                   (hasheq 'name "status" 'valueCode "completed")
                                   (hasheq 'name "location"
                                           'valueUri (format "urn:sql-export:~a" id)))
                             (let ([t (one in "clientTrackingId")])
                               (if t (list (hasheq 'name "clientTrackingId"
                                                   'valueString (format "~a" t))) '()))
                             outputs))))])))

(module+ test
  (require rackunit fhir/r5/schemas "schema/ViewDefinition.rkt")
  (define (mk js) (ok-value (from-json js #:lenient? #t)))
  (define view-js
    (hasheq 'resourceType "ViewDefinition" 'name "pts" 'status "active" 'resource "Patient"
            'url "http://example.org/ViewDefinition/pts"
            'select (list (hasheq 'column (list (hasheq 'name "id" 'path "getResourceKey()")
                                                (hasheq 'name "gender" 'path "gender"))))))
  (define view (ok-value (from-json view-js)))
  (define pts (list (mk (hasheq 'resourceType "Patient" 'id "1" 'gender "female"))
                    (mk (hasheq 'resourceType "Patient" 'id "2" 'gender "male"))))
  (define (resolve kind v)
    (and (or (and (eq? kind 'canonical) (equal? v "http://example.org/ViewDefinition/pts"))
             (and (eq? kind 'reference) (equal? v "ViewDefinition/pts")))
         view))
  (define run (make-sql-run-handler #:resolve-view resolve
                                    #:resources-of (lambda (t) (if (equal? t "Patient") pts '()))))
  (define (bin-body b)   ; decode a Binary node's data
    (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (format "~a" (pv (fhir-ref b 'data #f)))))))
  ;; exactly-one rule
  (check-eq? (fhir-type (run (hash) #f)) 'OperationOutcome)
  (check-eq? (fhir-type (run (hash "subjectCanonical" '("http://example.org/ViewDefinition/pts")
                                   "subjectReference" '("ViewDefinition/pts"))
                             #f))
             'OperationOutcome)
  ;; default = ndjson, 2 lines
  (define nd (run (hash "subjectCanonical" '("http://example.org/ViewDefinition/pts")) #f))
  (check-eq? (fhir-type nd) 'Binary)
  (check-equal? (format "~a" (pv (fhir-ref nd 'contentType #f))) "application/x-ndjson")
  (check-equal? (length (string-split (bin-body nd) "\n")) 2)
  ;; csv with and without header
  (define csv (run (hash "subjectCanonical" '("http://example.org/ViewDefinition/pts")
                         "_format" '("csv")) #f))
  (check-equal? (car (string-split (bin-body csv) "\r\n")) "id,gender")
  (define csv2 (run (hash "subjectCanonical" '("http://example.org/ViewDefinition/pts")
                          "_format" '("csv") "header" '(#f)) #f))
  (check-equal? (car (string-split (bin-body csv2) "\r\n")) "1,female")
  ;; json round-trips; _limit caps rows
  (define j (run (hash "subjectResource" (list view) "_format" '("json") "_limit" '(1)) #f))
  (check-equal? (length (string->jsexpr (bin-body j))) 1)
  ;; fhir format -> a Parameters resource
  (define p (run (hash "subjectCanonical" '("http://example.org/ViewDefinition/pts")
                       "_format" '("fhir")) #f))
  (check-eq? (fhir-type p) 'Parameters)
  ;; inline resources override server data; Bundle unwraps
  (define bundle (mk (hasheq 'resourceType "Bundle" 'type "collection"
                             'entry (list (hasheq 'resource (hasheq 'resourceType "Patient" 'id "9"
                                                                    'gender "other"))))))
  (define ji (run (hash "subjectResource" (list view) "resource" (list bundle) "_format" '("json")) #f))
  (check-equal? (map (lambda (h) (hash-ref h 'id)) (string->jsexpr (bin-body ji))) '("9"))
  ;; patient filter: only resources of/being that patient
  (define obs-view
    (ok-value (from-json (hasheq 'resourceType "ViewDefinition" 'name "ov" 'status "active"
                                 'resource "Observation"
                                 'select (list (hasheq 'column (list (hasheq 'name "oid" 'path "getResourceKey()"))))))))
  (define obss (list (mk (hasheq 'resourceType "Observation" 'id "o1" 'status "final"
                                 'subject (hasheq 'reference "Patient/1")))
                     (mk (hasheq 'resourceType "Observation" 'id "o2" 'status "final"
                                 'subject (hasheq 'reference "Patient/2")))))
  (define run2 (make-sql-run-handler #:resolve-view resolve
                                     #:resources-of (lambda (t) (if (equal? t "Observation") obss '()))))
  (define jp (run2 (hash "subjectResource" (list obs-view) "_format" '("json")
                         "patient" '("Patient/1")) #f))
  (check-equal? (map (lambda (h) (hash-ref h 'oid)) (string->jsexpr (bin-body jp))) '("o1"))
  ;; export: synchronous completion manifest
  (define export (make-sql-export-handler #:resolve-view resolve
                                          #:resources-of (lambda (t) (if (equal? t "Patient") pts '()))))
  (define manifest (export (hash "subject" '("http://example.org/ViewDefinition/pts")) #f))
  (check-eq? (fhir-type manifest) 'Parameters)
  (define mjs (node->jsexpr manifest))
  (define (param name) (findf (lambda (p) (equal? (hash-ref p 'name) name)) (hash-ref mjs 'parameter)))
  (check-equal? (hash-ref (param "status") 'valueCode) "completed")
  (check-true (string? (hash-ref (param "exportId") 'valueString)))
  (check-true (hash? (param "output"))))
