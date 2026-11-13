#lang racket/base

;;; bulk-test.rkt — a bulk load stores what writing each resource stores.
;;;
;;; `raco fhir-server load` reads .ndjson through store/bulk.rkt: worker processes prepare the
;;; resources (stamped text, hash, index rows) and one process writes them, index rows many to a
;;; statement, the search indexes built at the end when the store was empty. This holds that path
;;; to the engine's own (`fhir-update!` per resource, `fhir-create!` for one without an id): US
;;; Core's examples loaded both ways give two stores with the same resources, the same history
;;; and the same index rows — and, loaded a SECOND time, the same second versions. The instant a
;;; resource was written at (meta.lastUpdated) is the one thing that differs, and is left out.

(require rackunit racket/file racket/list racket/string json db
         (only-in fhir/r4/schemas)
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/package read-package)
         (only-in fhir/model/registry type-registered?)
         fhir/store/fhir-sqlite fhir/store/fhir-engine fhir/store/load
         (only-in fhir/store/ig-params search-params-from-package merge-search-params))

(define catalog (merge-search-params default-search-params
                                     (search-params-from-package (spec-package-path "hl7.fhir.r4.core.tgz"))))

;; the examples: resources of types the tower knows, each with an id; one more without
(define examples
  (let-values ([(_m rs exs) (read-package (spec-package-path "hl7.fhir.us.core.tgz"))])
    (for/list ([r (in-list (append rs exs))]
               #:when (let ([t (hash-ref (cdr r) 'resourceType #f)])
                        (and (string? t) (type-registered? (string->symbol t)) (string? (hash-ref (cdr r) 'id #f)))))
      (cdr r))))
(check-true (> (length examples) 200))

(define stores (make-temporary-directory "bulk-stores-~a"))
(define dir (make-temporary-directory "bulk-data-~a"))
;; two files (a run of .ndjson files is one bulk load), with a blank line and a line that is no
;; resource among them
(define-values (first-half second-half) (split-at examples (quotient (length examples) 2)))
(define (write-ndjson name resources extra)
  (call-with-output-file (build-path dir name)
    (lambda (o) (for ([r (in-list resources)]) (write-json r o) (newline o)) (for ([l (in-list extra)]) (write-string l o) (newline o)))))
(write-ndjson "a.ndjson" first-half '("" "not a resource"))
(write-ndjson "b.ndjson" second-half '())

;; ---- the two ways ------------------------------------------------------------------------------
(define (fresh-store name) (open-fhir-store (build-path stores name)))
(define by-engine (fresh-store "engine.db"))
(define by-bulk (fresh-store "bulk.db"))
(define by-bulk-here (fresh-store "bulk-here.db"))

(define (load-by-engine!) (for ([r (in-list examples)]) (fhir-update! by-engine r #:search-params catalog)))
;; with workers (the R4 tower named), and prepared in this process (no tower)
(define (load-by-bulk!) (load-files! by-bulk dir #:search-params catalog #:tower 'fhir/r4/schemas))
(define (load-by-bulk-here!) (load-files! by-bulk-here dir #:search-params catalog))

(load-by-engine!)
(check-equal? (map cdr (load-by-bulk!)) (list (length first-half) (length second-half)))
(check-equal? (apply + (map cdr (load-by-bulk-here!))) (length examples))

;; ---- what a store holds, without the instants --------------------------------------------------
;; without-instant : json-text -> jsexpr   a stored resource without meta.lastUpdated
(define (without-instant text)
  (define js (string->jsexpr text))
  (hash-set js 'meta (hash-remove (hash-ref js 'meta) 'lastUpdated)))

;; contents : store -> hash   table -> its rows, sorted (the resource tables without instants and
;; hashes, which follow the instant)
(define (contents store)
  (call-with-store-connection store
    (lambda (c)
      (define (rows sql) (sort (map vector->list (query-rows c sql)) string<? #:key (lambda (r) (format "~s" r))))
      (hash 'resources (for/list ([r (in-list (rows "SELECT resource_type, id, version_id, json(resource) FROM fhir_resources"))])
                         (list (car r) (cadr r) (caddr r) (without-instant (cadddr r))))
            'history (for/list ([r (in-list (rows "SELECT resource_type, id, version_id, json(resource) FROM fhir_history"))])
                       (list (car r) (cadr r) (caddr r) (without-instant (cadddr r))))
            'tokens (rows "SELECT resource_type, resource_id, param_name, system, code FROM fhir_token_index")
            'references (rows "SELECT resource_type, resource_id, param_name, target_type, target_id FROM fhir_reference_index")
            'strings (rows "SELECT resource_type, resource_id, param_name, value_norm, value_exact FROM fhir_string_index")
            'dates (rows "SELECT resource_type, resource_id, param_name, low, high FROM fhir_date_index")
            'numbers (rows "SELECT resource_type, resource_id, param_name, value FROM fhir_number_index")
            'quantities (rows "SELECT resource_type, resource_id, param_name, value, system, code FROM fhir_quantity_index")
            'indexes (rows "SELECT name FROM sqlite_master WHERE type='index' AND sql IS NOT NULL")))))

(define (check-same-stores label)
  (define expected (contents by-engine))
  (for ([store (in-list (list by-bulk by-bulk-here))] [way '("workers" "this process")])
    (define got (contents store))
    (for ([(table rows) (in-hash expected)])
      (check-equal? (length (hash-ref got table)) (length rows) (format "~a, ~a: ~a row count" label way table))
      (check-equal? (hash-ref got table) rows (format "~a, ~a: ~a" label way table)))))

;; once: version 1 of everything, the same index rows, and the search indexes back in place
(check-same-stores "first load")
(check-true (> (length (hash-ref (contents by-bulk) 'tokens)) 1000))
(check-true (>= (length (hash-ref (contents by-bulk) 'indexes)) 12))

;; the hash kept with a version is the stored text's
(call-with-store-connection by-bulk
  (lambda (c)
    (for ([r (in-list (query-rows c "SELECT content_hash, json(resource) FROM fhir_history LIMIT 20"))])
      (check-equal? (string-length (vector-ref r 0)) 40))))

;; again: every resource has a second version, its index rows replaced, not doubled
(load-by-engine!)
(void (load-by-bulk!))
(void (load-by-bulk-here!))
(check-same-stores "second load")
(check-equal? (call-with-store-connection by-bulk (lambda (c) (query-value c "SELECT COUNT(*) FROM fhir_history WHERE version_id = 2")))
              (length examples))

;; ---- reindex -----------------------------------------------------------------------------------
;; A store whose index rows are wrong (here: every date and half the tokens gone, a stray row
;; added) has them again after `reindex!` — the rows the engine writes, no more — and its search
;; indexes are in place.
(require (only-in fhir/store/bulk make-bulk-loader close-bulk-loader reindex!))
(call-with-store-connection by-bulk
  (lambda (c)
    (query-exec c "DELETE FROM fhir_date_index")
    (query-exec c "DELETE FROM fhir_token_index WHERE rowid % 2 = 0")
    (query-exec c "INSERT INTO fhir_token_index (resource_type, resource_id, param_name, system, code) VALUES ('Patient','nobody','gender',NULL,'stray')")))
(check-not-equal? (hash-ref (contents by-bulk) 'tokens) (hash-ref (contents by-engine) 'tokens))
(for ([tower (in-list (list 'fhir/r4/schemas #f))])       ; over workers, and in this process
  (define loader (make-bulk-loader catalog tower))
  (check-equal? (reindex! loader by-bulk) (length examples))
  (close-bulk-loader loader)
  (check-same-stores (format "reindexed (~a)" (if tower "workers" "this process"))))

;; a resource without an id is created with one (the engine's fhir-create!)
(define no-id (make-temporary-directory "bulk-more-~a"))
(call-with-output-file (build-path no-id "c.ndjson")
  (lambda (o) (write-json (hasheq 'resourceType "Patient" 'gender "female") o) (newline o)))
(check-equal? (map cdr (load-files! by-bulk no-id #:search-params catalog #:tower 'fhir/r4/schemas)) '(1))
(check-equal? (length (fhir-search by-bulk "Patient" '(("gender" . "female")) #:search-params catalog))
              (add1 (length (fhir-search by-engine "Patient" '(("gender" . "female")) #:search-params catalog)))
              "found by search, beside the others")

(for ([s (in-list (list by-engine by-bulk by-bulk-here))]) (close-fhir-store s))
(for ([d (in-list (list dir stores no-id))]) (delete-directory/files d))
