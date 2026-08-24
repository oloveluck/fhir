#lang racket/base

;;; fhir-engine.rkt — FHIR CRUD + search over the SQLite store.
;;;
;;; A SearchParam is (search-param name kind path):
;;;   kind : 'token | 'reference   path : a FHIRPath expression over the resource
;;; The per-type catalog is DATA (`default-search-params`, extensible via #:search-params) — the
;;; indexer parses each stored resource leniently into a typed node and evaluates every declared
;;; param's path with the repo's FHIRPath engine, decomposing the items into index rows:
;;;   token     : CodeableConcept -> each coding's (system, code); Coding -> (system, code);
;;;               Identifier -> (system, value); a bare code/string -> (#f, value)
;;;   reference : Reference.reference "Type/id" -> (target_type, target_id)
;;; Both index tables are rebuilt for a resource inside the SAME transaction as the write, so the
;;; indexes can never drift from the store.
;;;
;;; Search grammar (the supported subset):
;;;   token     : `code=system|value` | `code=|value` (no system) | `code=value` (any system)
;;;   reference : `patient=Patient/123` | `patient=123`
;;;   date      : `_lastUpdated=ge2024-01-01` (prefixes ge/gt/le/lt/eq over ISO-8601, which
;;;               compares lexicographically)
;;; Multiple parameters AND together (each an EXISTS subquery against its index).

(require racket/contract racket/string racket/list racket/random
         db json file/sha1
         "fhir-sqlite.rkt"
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../result/result.rkt" ok? ok-value)
         (only-in "../fhirpath/parser/parse.rkt" parse-fhirpath)
         (only-in "../fhirpath/eval.rkt" eval-fhirpath)
         (only-in "../model/node.rkt" fhir? fhir-ref fhir-type)
         (only-in "../model/base.rkt" primitive-type? primitive-type-value)
         (only-in "../model/leaf.rkt" pv listify))

(provide
 (struct-out search-param)
 (contract-out
  [default-search-params (hash/c symbol? (listof search-param?))]
  [fhir-create!  (->* (fhir-store? jsexpr?) (#:search-params hash?)
                      (values string? string? exact-positive-integer?))]
  [fhir-read     (-> fhir-store? string? string? (or/c jsexpr? #f))]
  [fhir-update!  (->* (fhir-store? jsexpr?) (#:search-params hash?) exact-positive-integer?)]
  [fhir-history  (-> fhir-store? string? string? (listof jsexpr?))]
  [fhir-vread    (-> fhir-store? string? string? exact-positive-integer? (or/c jsexpr? #f))]
  [fhir-delete!  (-> fhir-store? string? string? boolean?)]
  [fhir-search   (-> fhir-store? string? (listof (cons/c string? string?)) (listof jsexpr?))]
  ;; connection-taking write variants: compose several writes into ONE transaction
  ;; (call-with-store-transaction + these = an atomic FHIR transaction Bundle)
  [create-in!    (-> connection? jsexpr? hash? (values string? string? exact-positive-integer?))]
  [update-in!    (-> connection? jsexpr? hash? exact-positive-integer?)]
  [delete-in!    (-> connection? string? string? boolean?)]))

(struct search-param (name kind path) #:transparent)

(define default-search-params
  (hash 'Patient     (list (search-param "identifier" 'token "identifier")
                           (search-param "gender"     'token "gender"))
        'Observation (list (search-param "code"       'token "code")
                           (search-param "status"     'token "status")
                           (search-param "patient"    'reference "subject")
                           (search-param "subject"    'reference "subject"))
        'Condition   (list (search-param "code"       'token "code")
                           (search-param "patient"    'reference "subject")
                           (search-param "subject"    'reference "subject"))))

;; ---- CRUD -------------------------------------------------------------------
;; Each public write opens its own transaction; the `-in!` variants take an open connection so a
;; COMPOSITE write (a FHIR transaction Bundle — store/bundle.rkt) is one atomic transaction.
(define (fhir-create! store resource #:search-params [sps default-search-params])
  (call-with-store-transaction store (lambda (c) (create-in! c resource sps))))

(define (create-in! c resource sps)
  (define rtype (hash-ref resource 'resourceType
                          (lambda () (error 'fhir-create! "resource has no resourceType"))))
  (define id (or (hash-ref resource 'id #f) (fresh-id)))
  (define now (now-iso))
  (when (query-maybe-value c "SELECT 1 FROM fhir_resources WHERE resource_type=? AND id=?" rtype id)
    (error 'fhir-create! "~a/~a already exists (use fhir-update!)" rtype id))
  ;; a re-create after delete CONTINUES the version chain (history is immutable, so v1 may exist)
  (define prev (query-maybe-value c "SELECT MAX(version_id) FROM fhir_history WHERE resource_type=? AND id=?"
                                  rtype id))
  (define vid (add1 (if (exact-integer? prev) prev 0)))
  (define stored (stamp-meta (hash-set resource 'id id) vid now))
  (write-version! c rtype id vid now stored)
  (reindex! c rtype id stored sps)
  (values rtype id vid))

(define (fhir-read store rtype id)
  (define raw (call-with-store-connection store
                (lambda (c) (query-maybe-value c "SELECT raw_resource FROM fhir_resources WHERE resource_type=? AND id=?"
                                               rtype id))))
  (and raw (string->jsexpr raw)))

(define (fhir-update! store resource #:search-params [sps default-search-params])
  (call-with-store-transaction store (lambda (c) (update-in! c resource sps))))

(define (update-in! c resource sps)
  (define rtype (hash-ref resource 'resourceType
                          (lambda () (error 'fhir-update! "resource has no resourceType"))))
  (define id (hash-ref resource 'id (lambda () (error 'fhir-update! "resource has no id"))))
  (define now (now-iso))
  ;; version from HISTORY, not the current row: an update-after-delete (upsert) must continue
  ;; the immutable chain rather than colliding with it
  (define prev (query-maybe-value c "SELECT MAX(version_id) FROM fhir_history WHERE resource_type=? AND id=?"
                                  rtype id))
  (define vid (add1 (if (exact-integer? prev) prev 0)))
  (define stored (stamp-meta resource vid now))
  (write-version! c rtype id vid now stored)
  (reindex! c rtype id stored sps)
  vid)

;; fhir-history : every version, NEWEST first
(define (fhir-history store rtype id)
  (call-with-store-connection store
    (lambda (c)
      (for/list ([raw (in-list (query-list c "SELECT raw_resource FROM fhir_history
                                              WHERE resource_type=? AND id=? ORDER BY version_id DESC"
                                           rtype id))])
        (string->jsexpr raw)))))

;; fhir-vread : one specific version from the immutable history
(define (fhir-vread store rtype id vid)
  (define raw (call-with-store-connection store
                (lambda (c) (query-maybe-value c "SELECT raw_resource FROM fhir_history
                                                  WHERE resource_type=? AND id=? AND version_id=?"
                                               rtype id vid))))
  (and raw (string->jsexpr raw)))

;; fhir-delete! : remove the CURRENT resource + its indexes (history is immutable and remains);
;; -> #t when something was deleted
(define (fhir-delete! store rtype id)
  (call-with-store-transaction store (lambda (c) (delete-in! c rtype id))))

(define (delete-in! c rtype id)
  (define existed? (and (query-maybe-value c "SELECT 1 FROM fhir_resources WHERE resource_type=? AND id=?"
                                           rtype id) #t))
  (query-exec c "DELETE FROM fhir_resources WHERE resource_type=? AND id=?" rtype id)
  (query-exec c "DELETE FROM fhir_token_index WHERE resource_type=? AND resource_id=?" rtype id)
  (query-exec c "DELETE FROM fhir_reference_index WHERE resource_type=? AND resource_id=?" rtype id)
  existed?)

;; write the current row + the immutable history row (inside the caller's transaction)
(define (write-version! c rtype id vid now stored)
  (define text (jsexpr->string stored))
  (define hash (sha1 (open-input-bytes (string->bytes/utf-8 text))))
  (query-exec c "INSERT INTO fhir_resources (resource_type,id,version_id,last_updated,raw_resource)
                 VALUES (?,?,?,?,?)
                 ON CONFLICT(resource_type,id) DO UPDATE
                 SET version_id=excluded.version_id, last_updated=excluded.last_updated,
                     raw_resource=excluded.raw_resource"
              rtype id vid now text)
  (query-exec c "INSERT INTO fhir_history (resource_type,id,version_id,last_updated,content_hash,raw_resource)
                 VALUES (?,?,?,?,?,?)" rtype id vid now hash text))

(define (stamp-meta resource vid now)
  (define meta (let ([m (hash-ref resource 'meta (hash))])
                 (hash-set* (if (hash? m) m (hash))
                            'versionId (number->string vid) 'lastUpdated now)))
  (hash-set resource 'meta meta))

(define (fresh-id) (bytes->hex-string (crypto-random-bytes 16)))
(define (now-iso)
  (define d (seconds->date (current-seconds) #f))
  (define (p2 n) (if (< n 10) (format "0~a" n) (number->string n)))
  (format "~a-~a-~aT~a:~a:~aZ" (date-year d) (p2 (date-month d)) (p2 (date-day d))
          (p2 (date-hour d)) (p2 (date-minute d)) (p2 (date-second d))))

;; ---- indexing ---------------------------------------------------------------
;; rebuild both index tables for one resource (runs inside the write transaction)
(define (reindex! c rtype id stored sps)
  (query-exec c "DELETE FROM fhir_token_index WHERE resource_type=? AND resource_id=?" rtype id)
  (query-exec c "DELETE FROM fhir_reference_index WHERE resource_type=? AND resource_id=?" rtype id)
  (define node (let ([r (from-json stored #:lenient? #t)]) (and (ok? r) (ok-value r))))
  (when node
    (for ([sp (in-list (hash-ref sps (string->symbol rtype) '()))])
      (define items (with-handlers ([exn:fail? (lambda (_) '())])
                      (eval-fhirpath (parse-fhirpath (search-param-path sp)) (list node) #:strict? #f)))
      (case (search-param-kind sp)
        ;; uri params (canonical urls, e.g. ViewDefinition.url) index like system-less tokens —
        ;; `tokens-of` already renders a bare primitive as (#f . value)
        [(token uri)
         (for ([(sys code) (in-parallel (map car (tokens-of items)) (map cdr (tokens-of items)))])
           (query-exec c "INSERT INTO fhir_token_index (resource_type,resource_id,param_name,system,code)
                          VALUES (?,?,?,?,?)" rtype id (search-param-name sp) (or sys sql-null) code))]
        [(reference)
         (for ([tgt (in-list (references-of items))])
           (query-exec c "INSERT INTO fhir_reference_index (resource_type,resource_id,param_name,target_type,target_id)
                          VALUES (?,?,?,?,?)"
                       rtype id (search-param-name sp) (or (car tgt) sql-null) (cdr tgt)))]))))

;; tokens-of : items -> (Listof (cons system|#f code))   decompose token-typed items
(define (tokens-of items)
  (append*
   (for/list ([it (in-list items)])
     (cond
       [(primitive-type? it) (list (cons #f (format "~a" (primitive-type-value it))))]
       [(and (fhir? it) (eq? (fhir-type it) 'CodeableConcept))
        (append* (for/list ([cd (in-list (listify (fhir-ref it 'coding '())))]) (coding->tokens cd)))]
       [(and (fhir? it) (eq? (fhir-type it) 'Coding)) (coding->tokens it)]
       [(and (fhir? it) (eq? (fhir-type it) 'Identifier))
        (let ([sys (pv (fhir-ref it 'system #f))] [val (pv (fhir-ref it 'value #f))])
          (if val (list (cons sys val)) '()))]
       [else '()]))))
(define (coding->tokens cd)
  (let ([sys (pv (fhir-ref cd 'system #f))] [code (pv (fhir-ref cd 'code #f))])
    (if code (list (cons sys code)) '())))

;; references-of : items -> (Listof (cons target-type|#f target-id))
(define (references-of items)
  (append*
   (for/list ([it (in-list items)])
     (cond
       [(and (fhir? it) (eq? (fhir-type it) 'Reference))
        (define ref (pv (fhir-ref it 'reference #f)))
        (cond [(and ref (regexp-match #px"^([A-Za-z]+)/(.+)$" ref))
               => (lambda (m) (list (cons (cadr m) (caddr m))))]
              [ref (list (cons #f ref))]
              [else '()])]
       [else '()]))))


;; ---- search -----------------------------------------------------------------
(define (fhir-search store rtype query-params)
  (define-values (clauses args)
    (for/fold ([cs '()] [as '()]) ([qp (in-list query-params)])
      (define-values (c a) (param->clause rtype (car qp) (cdr qp)))
      (values (cons c cs) (append as a))))
  (define sql
    (string-append "SELECT raw_resource FROM fhir_resources r WHERE r.resource_type=?"
                   (apply string-append (for/list ([c (in-list (reverse clauses))]) (string-append " AND " c)))))
  (call-with-store-connection store
    (lambda (c)
      (for/list ([raw (in-list (apply query-list c sql rtype args))])
        (string->jsexpr raw)))))

;; param->clause : one query parameter -> (values sql-fragment args)
(define (param->clause rtype name value)
  (cond
    [(equal? name "_lastUpdated")
     (define m (regexp-match #px"^(ge|gt|le|lt|eq)?(.+)$" value))
     (define op (case (cadr m) [("ge") ">="] [("gt") ">"] [("le") "<="] [("lt") "<"] [else "="]))
     (values (format "r.last_updated ~a ?" op) (list (caddr m)))]
    [(regexp-match #px"^([^|]*)\\|(.+)$" value)
     => (lambda (m)   ; token with system: `system|code` (empty system = "no system")
          (define sys (cadr m)) (define code (caddr m))
          (if (string=? sys "")
              (values "EXISTS (SELECT 1 FROM fhir_token_index t WHERE t.resource_type=r.resource_type
                       AND t.resource_id=r.id AND t.param_name=? AND t.code=? AND t.system IS NULL)"
                      (list name code))
              (values "EXISTS (SELECT 1 FROM fhir_token_index t WHERE t.resource_type=r.resource_type
                       AND t.resource_id=r.id AND t.param_name=? AND t.code=? AND t.system=?)"
                      (list name code sys))))]
    [(regexp-match #px"^([A-Z][A-Za-z]+)/(.+)$" value)
     => (lambda (m)   ; reference: Type/id
          (values "EXISTS (SELECT 1 FROM fhir_reference_index f WHERE f.resource_type=r.resource_type
                   AND f.resource_id=r.id AND f.param_name=? AND f.target_type=? AND f.target_id=?)"
                  (list name (cadr m) (caddr m))))]
    [else            ; bare value: token any-system OR reference by id — try both indexes
     (values "(EXISTS (SELECT 1 FROM fhir_token_index t WHERE t.resource_type=r.resource_type
               AND t.resource_id=r.id AND t.param_name=? AND t.code=?)
               OR EXISTS (SELECT 1 FROM fhir_reference_index f WHERE f.resource_type=r.resource_type
               AND f.resource_id=r.id AND f.param_name=? AND f.target_id=?))"
             (list name value name value))]))

(module+ test
  (require rackunit racket/file (only-in fhir/r5/schemas))
  (define tmp (make-temporary-file "fhir-engine-~a.db"))
  (define store (open-fhir-store tmp))
  ;; create + read + meta stamping
  (define-values (rt id vid)
    (fhir-create! store (hasheq 'resourceType "Patient" 'gender "female"
                                'identifier (list (hasheq 'system "urn:mrn" 'value "123")))))
  (check-equal? (list rt vid) '("Patient" 1))
  (define read-back (fhir-read store "Patient" id))
  (check-equal? (hash-ref read-back 'gender) "female")
  (check-equal? (hash-ref (hash-ref read-back 'meta) 'versionId) "1")
  ;; update bumps version + history preserves both
  (check-equal? (fhir-update! store (hash-set read-back 'gender "male")) 2)
  (check-equal? (map (lambda (r) (hash-ref r 'gender)) (fhir-history store "Patient" id))
                '("male" "female"))
  ;; token + reference + date search
  (define-values (_o oid _v)
    (fhir-create! store (hasheq 'resourceType "Observation" 'status "final"
                                'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code "883-9")))
                                'subject (hasheq 'reference (string-append "Patient/" id)))))
  (check-equal? (length (fhir-search store "Observation" (list (cons "code" "http://loinc.org|883-9")))) 1)
  (check-equal? (length (fhir-search store "Observation" (list (cons "code" "http://loinc.org|999-9")))) 0)
  (check-equal? (length (fhir-search store "Observation" (list (cons "patient" (string-append "Patient/" id))))) 1)
  (check-equal? (length (fhir-search store "Observation" (list (cons "status" "final")
                                                               (cons "patient" (string-append "Patient/" id))))) 1)
  (check-equal? (length (fhir-search store "Patient" (list (cons "identifier" "urn:mrn|123")))) 1)
  (check-equal? (length (fhir-search store "Patient" (list (cons "_lastUpdated" "ge2000-01-01")))) 1)
  (check-equal? (length (fhir-search store "Patient" (list (cons "_lastUpdated" "lt2000-01-01")))) 0)
  ;; vread reaches into the immutable history; delete removes current + indexes but not history
  (check-equal? (hash-ref (fhir-vread store "Patient" id 1) 'gender) "female")
  (check-equal? (hash-ref (fhir-vread store "Patient" id 2) 'gender) "male")
  (check-false (fhir-vread store "Patient" id 3))
  (check-true (fhir-delete! store "Patient" id))
  (check-false (fhir-read store "Patient" id))
  (check-equal? (length (fhir-search store "Patient" (list (cons "identifier" "urn:mrn|123")))) 0)
  (check-equal? (length (fhir-history store "Patient" id)) 2)  ; history survives delete
  (check-false (fhir-delete! store "Patient" id))              ; second delete -> nothing to do
  (close-fhir-store store)
  (delete-file tmp))
