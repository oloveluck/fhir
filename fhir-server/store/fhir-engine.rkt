#lang racket/base

;;; fhir-engine.rkt — FHIR CRUD + search over the SQLite store.
;;;
;;; A SearchParam is (search-param name kind path):
;;;   kind : 'token | 'reference | 'string | 'date | 'number | 'quantity | 'uri  (the SearchParameter's
;;;          `type`; 'composite/'special are cataloged but not indexed)   path : a FHIRPath expression
;;; The per-type catalog is DATA (`default-search-params`, or the IG's SearchParameters via
;;; ig-params.rkt) — the indexer parses each stored resource leniently into a typed node, evaluates
;;; every declared param's path with the repo's FHIRPath engine, and turns the items into index rows
;;; by the param's KIND (search-index.rkt). All index tables are rebuilt for a resource inside the
;;; SAME transaction as the write, so the indexes can never drift from the store.
;;;
;;; Search: each query parameter is compiled by its catalog KIND (search-index.rkt documents the
;;; supported grammar: modifiers, comma-OR, prefixes, date ranges). Built in: `_id`, `_lastUpdated`.
;;; Parameters the catalog doesn't know, or uses an unsupported modifier on, are IGNORED (the FHIR
;;; default "lenient" handling) and reported by `fhir-search/ignored`. Multiple parameters AND.

(require racket/contract racket/string racket/list racket/random racket/match
         db json file/sha1
         "fhir-sqlite.rkt"
         "search-index.rkt"
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/result/result ok? ok-value)
         (only-in fhirpath/parser/parse parse-fhirpath)
         (only-in fhirpath/eval eval-fhirpath)
         (only-in fhir/model/node fhir? fhir-ref fhir-type)
         (only-in fhir/model/base primitive-type? primitive-type-value)
         (only-in fhir/model/leaf pv listify))

(provide
 (struct-out search-param)
 (contract-out
  [default-search-params (hash/c symbol? (listof search-param?))]
  [fhir-create!  (->* (fhir-store? jsexpr?) (#:search-params hash?)
                      (values string? string? exact-positive-integer?))]
  [fhir-read     (-> fhir-store? string? string? (or/c jsexpr? #f))]
  [fhir-update!  (->* (fhir-store? jsexpr?) (#:search-params hash?) exact-positive-integer?)]
  [fhir-history  (->* (fhir-store? string? string?) (#:since (or/c string? #f) #:count (or/c exact-nonnegative-integer? #f))
                      (listof jsexpr?))]
  [fhir-history-type (->* (fhir-store? string?) (#:since (or/c string? #f) #:count (or/c exact-nonnegative-integer? #f))
                          (listof jsexpr?))]
  [fhir-vread    (-> fhir-store? string? string? exact-positive-integer? (or/c jsexpr? #f))]
  [fhir-delete!  (-> fhir-store? string? string? boolean?)]
  [fhir-search   (->* (fhir-store? string? (listof (cons/c string? string?)))
                      (#:search-params hash?) (listof jsexpr?))]
  ;; the resources a search's _include / _revinclude parameters pull in, for the given matches
  [fhir-includes (-> fhir-store? string? (listof jsexpr?) (listof (cons/c string? string?)) (listof jsexpr?))]
  ;; the same search, also returning the query parameters that were IGNORED (unknown/unsupported)
  [fhir-search/ignored (->* (fhir-store? string? (listof (cons/c string? string?)))
                            (#:search-params hash?) (values (listof jsexpr?) (listof string?)))]
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
(define (fhir-history store rtype id #:since [since #f] #:count [count #f])
  (history-query store "resource_type=? AND id=?" (list rtype id) since count))

;; fhir-history-type : every version of every resource of a type, newest first (type-level history)
(define (fhir-history-type store rtype #:since [since #f] #:count [count #f])
  (history-query store "resource_type=?" (list rtype) since count))

;; since : an instant (versions changed AT OR AFTER it; compared to the second) ; count : page size
(define (history-query store where args since count)
  (call-with-store-connection store
    (lambda (c)
      (define sql (string-append "SELECT raw_resource FROM fhir_history WHERE " where
                                 (if since " AND substr(last_updated,1,19) >= ?" "")
                                 " ORDER BY last_updated DESC, version_id DESC"
                                 (if (exact-nonnegative-integer? count) (format " LIMIT ~a" count) "")))
      (define since-key (and since (let ([r (date-range since)]) (and r (substring (car r) 0 19)))))
      (for/list ([raw (in-list (apply query-list c sql (append args (if since (list (or since-key since)) '()))))])
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
;; rebuild every index table for one resource (runs inside the write transaction)
(define (reindex! c rtype id stored sps)
  (for ([t (in-list index-tables)])
    (query-exec c (format "DELETE FROM ~a WHERE resource_type=? AND resource_id=?" (car t)) rtype id))
  (define node (let ([r (from-json stored #:lenient? #t)]) (and (ok? r) (ok-value r))))
  (when node
    (for ([sp (in-list (hash-ref sps (string->symbol rtype) '()))]
          #:when (indexed-kind? (search-param-kind sp)))
      (define items (with-handlers ([exn:fail? (lambda (_) '())])
                      (eval-fhirpath (parse-fhirpath (search-param-path sp)) (list node) #:strict? #f)))
      (for ([row (in-list (rows-for (search-param-kind sp) items))])
        (define-values (table vals) (row-table+values row))
        (define cols (cdr (assoc table index-tables)))
        (apply query-exec c
               (format "INSERT INTO ~a (resource_type,resource_id,param_name,~a) VALUES (?,?,?,~a)"
                       table (string-join (map symbol->string cols) ",")
                       (string-join (map (lambda (_) "?") cols) ","))
               rtype id (search-param-name sp)
               (map (lambda (v) (or v sql-null)) vals))))))

;; ---- search -----------------------------------------------------------------
(define (fhir-search store rtype query-params #:search-params [sps default-search-params])
  (define-values (rs _ignored) (fhir-search/ignored store rtype query-params #:search-params sps))
  rs)

(define (fhir-search/ignored store rtype query-params #:search-params [sps default-search-params])
  (define catalog (hash-ref sps (string->symbol rtype) '()))
  (define-values (clauses ignored)
    (for/fold ([cs '()] [ig '()]) ([qp (in-list query-params)])
      (define c (param->clause catalog (car qp) (cdr qp)))
      (if c (values (cons c cs) ig) (values cs (cons (car qp) ig)))))
  (define count (let ([c (assoc "_count" query-params)]) (and c (string->number (cdr c)))))
  (define sql
    (string-append "SELECT raw_resource FROM fhir_resources r WHERE r.resource_type=?"
                   (apply string-append (for/list ([c (in-list (reverse clauses))])
                                          (string-append " AND " (clause-sql c))))
                   " ORDER BY r.last_updated, r.id"
                   (if (exact-nonnegative-integer? count) (format " LIMIT ~a" count) "")))
  (values
   (call-with-store-connection store
     (lambda (c)
       (for/list ([raw (in-list (apply query-list c sql rtype (append-map clause-args (reverse clauses))))])
         (string->jsexpr raw))))
   (filter (lambda (n) (not (member n '("_count" "_include" "_revinclude")))) (reverse ignored))))

;; ---- _include / _revinclude ----------------------------------------------------
;; Both follow the REFERENCE INDEX (so they need the reference parameter in the catalog at index
;; time, as search does). Values: `Source:param` or `Source:param:Target`; `*` and :iterate are not
;; supported (ignored). Included resources already among the matches are not repeated.
(define (fhir-includes store rtype matches query-params)
  (define match-ids (for/list ([m (in-list matches)]) (hash-ref m 'id #f)))
  (define seen (make-hash (for/list ([id (in-list match-ids)]) (cons (cons rtype id) #t))))
  (define (fresh! t id) (and (not (hash-ref seen (cons t id) #f)) (hash-set! seen (cons t id) #t) #t))
  (define (spec v) (match (string-split v ":") [(list s p) (list s p #f)] [(list s p t) (list s p t)] [_ #f]))
  (call-with-store-connection store
    (lambda (c)
      (append*
       (for/list ([qp (in-list query-params)] #:when (member (car qp) '("_include" "_revinclude")))
         (match (spec (cdr qp))
           [#f '()]
           [(list source param target)
            (cond
              [(and (equal? (car qp) "_include") (equal? source rtype))
               (for*/list ([id (in-list match-ids)] #:when id
                           [row (in-list (apply query-rows c
                                                (string-append
                                                 "SELECT target_type, target_id FROM fhir_reference_index
                                                  WHERE resource_type=? AND resource_id=? AND param_name=?"
                                                 (if target " AND target_type=?" ""))
                                                rtype id param (if target (list target) '())))]
                           #:when (string? (vector-ref row 0))
                           #:when (fresh! (vector-ref row 0) (vector-ref row 1))
                           [js (in-value (fhir-read store (vector-ref row 0) (vector-ref row 1)))]
                           #:when js)
                 js)]
              [(and (equal? (car qp) "_revinclude") (or (not target) (equal? target rtype)) (pair? match-ids))
               (for*/list ([raw (in-list (apply query-list c
                                                (string-append
                                                 "SELECT r.raw_resource FROM fhir_resources r WHERE r.resource_type=? AND EXISTS
                                                  (SELECT 1 FROM fhir_reference_index x WHERE x.resource_type=r.resource_type
                                                   AND x.resource_id=r.id AND x.param_name=? AND x.target_type=? AND x.target_id IN ("
                                                 (string-join (map (lambda (_) "?") match-ids) ",") "))")
                                                source param rtype match-ids))]
                           [js (in-value (string->jsexpr raw))]
                           #:when (fresh! source (hash-ref js 'id #f)))
                 js)]
              [else '()])]))))))

;; param->clause : catalog name value -> Clause | #f   (#f = ignore: unknown or unsupported)
(define (param->clause catalog full-name value)
  (define-values (name modifier)
    (match (regexp-match #px"^([^:]+)(?::(.+))?$" full-name)
      [(list _ n m) (values n m)] [#f (values full-name #f)]))
  (cond
    [(equal? name "_count") #f]
    [(equal? name "_id")
     (clause (string-append "r.id IN (" (string-join (map (lambda (_) "?") (string-split value ",")) ",") ")")
             (string-split value ","))]
    [(equal? name "_lastUpdated")
     ;; reads the row's own column (stored to the second, e.g. "…T10:00:00Z"): compare the
     ;; 19-character second-precision prefix of both sides
     (match (regexp-match #px"^(eq|ne|gt|lt|ge|le|sa|eb|ap)?(.+)$" value)
       [(list _ p v)
        (define rng (date-range v))
        (define lo (and rng (substring (car rng) 0 19)))
        (define hi (and rng (substring (cdr rng) 0 19)))
        (define col "substr(r.last_updated,1,19)")
        (and rng
             (case (string->symbol (or p "eq"))
               [(gt sa) (clause (string-append col " > ?") (list hi))]
               [(ge)    (clause (string-append col " >= ?") (list lo))]
               [(lt eb) (clause (string-append col " < ?") (list lo))]
               [(le)    (clause (string-append col " <= ?") (list hi))]
               [(ne)    (clause (string-append "NOT (" col " >= ? AND " col " <= ?)") (list lo hi))]
               [else    (clause (string-append col " >= ? AND " col " <= ?") (list lo hi))]))]
       [#f #f])]
    [(findf (lambda (sp) (equal? (search-param-name sp) name)) catalog)
     => (lambda (sp) (compile-param name (search-param-kind sp) modifier value))]
    [else #f]))

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

  ;; ---- type-driven search semantics: what must NOT match matters as much as what must ----
  (define cat
    (hash 'Patient (list (search-param "family" 'string "name.family")
                         (search-param "name" 'string "name")
                         (search-param "birthdate" 'date "birthDate")
                         (search-param "gender" 'token "gender")
                         (search-param "active" 'token "active"))
          'Observation (list (search-param "value-quantity" 'quantity "value.ofType(Quantity)")
                             (search-param "date" 'date "effective"))))
  (define (pat family given birth [extra (hasheq)])
    (define-values (_t i _v)
      (fhir-create! store (for/fold ([h (hasheq 'resourceType "Patient" 'birthDate birth
                                               'name (list (hasheq 'family family 'given (list given))))])
                                    ([(k v) (in-hash extra)]) (hash-set h k v))
                    #:search-params cat))
    i)
  (define chalmers (pat "Chalmers" "Peter" "1974-12-25" (hasheq 'gender "male" 'active #t)))
  (define marche (pat "du Marché" "Bénédicte" "1974" (hasheq 'gender "female")))
  (define windsor (pat "Windsor" "Charles" "1948-11-14"))
  (define (ids q) (sort (for/list ([js (in-list (fhir-search store "Patient" q #:search-params cat))])
                          (hash-ref js 'id)) string<?))
  (define (only . xs) (sort xs string<?))
  ;; string: case/accent-insensitive STARTS-WITH by default; :contains; :exact
  (check-equal? (ids '(("family" . "chal"))) (only chalmers))
  (check-equal? (ids '(("family" . "almers"))) '())                       ; not a prefix
  (check-equal? (ids '(("family:contains" . "almers"))) (only chalmers))
  (check-equal? (ids '(("family:exact" . "chalmers"))) '())               ; exact is case-sensitive
  (check-equal? (ids '(("family:exact" . "Chalmers"))) (only chalmers))
  (check-equal? (ids '(("name" . "benedicte"))) (only marche))            ; accents folded; given counts
  ;; token: comma = OR; :not; boolean tokens render as true/false
  (check-equal? (ids '(("gender" . "male,female"))) (only chalmers marche))
  (check-equal? (ids '(("gender:not" . "male"))) (only marche windsor))   ; :not includes the unset
  (check-equal? (ids '(("active" . "true"))) (only chalmers))
  ;; :missing
  (check-equal? (ids '(("gender:missing" . "true"))) (only windsor))
  (check-equal? (ids '(("gender:missing" . "false"))) (only chalmers marche))
  ;; date: implicit ranges and prefixes (du Marché's birthDate is the whole of 1974)
  (check-equal? (ids '(("birthdate" . "1974"))) (only chalmers marche))
  (check-equal? (ids '(("birthdate" . "1974-12-25"))) (only chalmers))    ; 1974 is not WITHIN that day
  (check-equal? (ids '(("birthdate" . "ap1974-12-25"))) (only chalmers marche)) ; but overlaps it
  (check-equal? (ids '(("birthdate" . "lt1950"))) (only windsor))
  (check-equal? (ids '(("birthdate" . "ge1974-06"))) (only chalmers marche))
  (check-equal? (ids '(("birthdate" . "sa1974"))) '())
  (check-equal? (ids '(("birthdate" . "eb1974"))) (only windsor))
  ;; AND across parameters; unknown parameters are ignored and reported
  (check-equal? (ids '(("gender" . "male") ("birthdate" . "1974"))) (only chalmers))
  (define-values (_r ignored)
    (fhir-search/ignored store "Patient" '(("nonsense" . "x") ("family:text" . "y")) #:search-params cat))
  (check-equal? ignored '("nonsense" "family:text"))
  ;; _id and _count
  (check-equal? (ids (list (cons "_id" (string-append chalmers "," windsor)))) (only chalmers windsor))
  (check-equal? (length (fhir-search store "Patient" '(("_count" . "1")) #:search-params cat)) 1)
  ;; quantity: precision-aware eq, prefixes, system|code
  (define-values (_q qid _qv)
    (fhir-create! store (hasheq 'resourceType "Observation" 'status "final" 'code (hasheq 'text "wt")
                                'valueQuantity (hasheq 'value 72.4 'system "http://unitsofmeasure.org" 'code "kg"))
                  #:search-params cat))
  (define (obs q) (length (fhir-search store "Observation" q #:search-params cat)))
  (check-equal? (obs '(("value-quantity" . "72.4|http://unitsofmeasure.org|kg"))) 1)
  (check-equal? (obs '(("value-quantity" . "72|http://unitsofmeasure.org|kg"))) 1)   ; 72 means [71.5,72.5)
  (check-equal? (obs '(("value-quantity" . "72.0|http://unitsofmeasure.org|kg"))) 0) ; [71.95,72.05)
  (check-equal? (obs '(("value-quantity" . "gt70||kg"))) 1)
  (check-equal? (obs '(("value-quantity" . "72.4||g"))) 0)
  (close-fhir-store store)
  (delete-file tmp))
