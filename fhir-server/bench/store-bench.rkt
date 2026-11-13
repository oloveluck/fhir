#lang racket/base

;;; store-bench.rkt — how fast the store loads bulk data and answers, measured the same way each time.
;;;
;;;   racket store-bench.rkt sample <ndjson-dir> <out-dir> [--per-file N]
;;;       a repeatable sample of a bulk export: the first N lines of each .ndjson[.gz] file
;;;       (default 4000), written as plain .ndjson — the dataset the other commands are run on
;;;   racket store-bench.rkt load <ndjson-dir> [--db file] [--json out.json]
;;;       the phases of a load, each timed on its own over the same files:
;;;         read    the files gunzipped, split into lines, each line parsed as JSON
;;;         index   every resource's index rows extracted, in this process (no store)
;;;         load    `raco fhir-server load`'s own path into a fresh store (what a user waits for)
;;;   racket store-bench.rkt query <store.db> [--runs N] [--json out.json]
;;;       a fixed set of searches and SQL statements over a loaded store, the median of N runs each
;;;       (default 5). The patient, code and date they ask about are chosen from the store itself:
;;;       the patient with the most observations, that patient's commonest code, their earliest date.
;;;
;;; The numbers are wall-clock milliseconds on the machine it runs on: compare runs on one machine,
;;; with nothing else running. `--json` writes them for a later comparison (compare.rkt is not
;;; needed: two files of numbers read side by side).
;;;
;;; The dataset the family's numbers are recorded on (TESTING.md) is the MIMIC-IV Clinical Database
;;; Demo on FHIR 2.1.0 (PhysioNet, ODbL): 30 files, 928,935 resources. It is not vendored.

(require racket/list racket/string racket/file racket/match racket/port racket/path json db
         (only-in file/gunzip gunzip-through-ports)
         fhir/store/fhir-sqlite fhir/store/fhir-engine fhir/store/load
         (only-in fhir/store/ig-params search-params-from-package merge-search-params)
         (only-in fhir/spec-package spec-package-path))

;; ---- time ------------------------------------------------------------------------------------
;; timed : (-> a) -> (values a ms)
(define (timed thunk)
  (define t (current-inexact-milliseconds))
  (define v (thunk))
  (values v (- (current-inexact-milliseconds) t)))

;; median-ms : Nat (-> any) -> ms   the median wall time of n runs
(define (median-ms n thunk)
  (define times (sort (for/list ([_ (in-range n)]) (let-values ([(_v ms) (timed thunk)]) ms)) <))
  (list-ref times (quotient (length times) 2)))

(define (round1 x) (/ (round (* 10.0 x)) 10.0))

;; ---- files -----------------------------------------------------------------------------------
;; bulk-files : dir -> (listof path)   the .ndjson and .ndjson.gz files of a directory, by name
(define (bulk-files dir)
  (sort (for/list ([f (in-list (directory-list dir #:build? #t))]
                   #:when (regexp-match? #rx"[.]ndjson(?:[.]gz)?$" (path->string f)))
          f)
        string<? #:key path->string))

;; call-with-lines : path (input-port -> a) -> a   the file's text, gunzipped when it is .gz
(define (call-with-lines f proc)
  (cond [(regexp-match? #rx"[.]gz$" (path->string f))
         (call-with-input-file f
           (lambda (in)
             (define-values (text-in text-out) (make-pipe (* 4 1024 1024)))
             (define pump (thread (lambda () (gunzip-through-ports in text-out) (close-output-port text-out))))
             (begin0 (proc text-in) (kill-thread pump))))]
        [else (call-with-input-file f proc)]))

;; sample! : dir dir Nat -> Nat   the first n lines of each bulk file, as plain .ndjson; the count
(define (sample! from to n)
  (make-directory* to)
  (for/sum ([f (in-list (bulk-files from))])
    (define name (regexp-replace #rx"[.]gz$" (path->string (file-name-from-path f)) ""))
    (call-with-lines f
      (lambda (in)
        (call-with-output-file (build-path to name) #:exists 'truncate
          (lambda (out)
            (for/sum ([line (in-lines in)] [_ (in-range n)])
              (write-string line out) (newline out) 1)))))))

;; ---- the catalogue (as `raco fhir-server load --fhir-version 4.0.1` builds it) ------------------
(define tower 'fhir/r4/schemas)
(define (catalog)
  (define core (spec-package-path "hl7.fhir.r4.core.tgz" #:optional? #t))
  (if core (merge-search-params default-search-params (search-params-from-package core)) default-search-params))

;; ---- load ------------------------------------------------------------------------------------
;; read-all : (listof path) -> (listof jsexpr)   every resource of the files
(define (read-all files)
  (for*/list ([f (in-list files)]
              [js (in-list (call-with-lines f
                             (lambda (in) (for/list ([line (in-lines in)] #:when (regexp-match? #rx"^[ \t]*{" line))
                                            (string->jsexpr line)))))])
    js))

;; bench-load : dir db-path -> hash   the phases of loading dir, in ms, and the rates they give
(define (bench-load dir db-path)
  (dynamic-require tower #f)
  (define files (bulk-files dir))
  (define sps (catalog))
  (define-values (resources read-ms) (timed (lambda () (read-all files))))
  (define n (length resources))
  (define by-type (make-hash))
  (define-values (_rows index-ms)
    (timed (lambda ()
             (for ([r (in-list resources)])
               (define type (hash-ref r 'resourceType ""))
               (define-values (rows ms) (timed (lambda () (index-rows r (indexed-entries sps type)))))
               (hash-update! by-type type (lambda (p) (cons (+ (car p) 1) (+ (cdr p) ms))) (cons 0 0.0))))))
  (for ([suffix '("" "-wal" "-shm")])
    (define f (string-append db-path suffix))
    (when (file-exists? f) (delete-file f)))
  (define store (open-fhir-store db-path))
  (define-values (loaded load-ms) (timed (lambda () (load-files! store dir #:search-params sps #:tower tower))))
  (close-fhir-store store)
  (define (rate ms) (if (zero? ms) 0 (round (/ n (/ ms 1000.0)))))
  (hasheq 'resources n
          'files (length files)
          'read_ms (round read-ms) 'read_per_s (rate read-ms)
          'index_ms (round index-ms) 'index_per_s (rate index-ms)
          'load_ms (round load-ms) 'load_per_s (rate load-ms)
          'store_bytes (file-size db-path)
          'index_us_by_type
          (for/hasheq ([(type p) (in-hash by-type)])
            (values (string->symbol type) (hasheq 'resources (car p) 'us_each (round (/ (* 1000.0 (cdr p)) (car p))))))))

;; ---- query -----------------------------------------------------------------------------------
;; subject : store -> (values patient-id code date)   what the fixed questions ask about
(define (subject store)
  (call-with-store-connection store
    (lambda (c)
      (define pid (query-value c "SELECT target_id FROM fhir_reference_index WHERE resource_type='Observation' AND param_name='patient' GROUP BY target_id ORDER BY COUNT(*) DESC, target_id LIMIT 1"))
      (define code (query-value c (string-append
                                   "SELECT t.code FROM fhir_token_index t WHERE t.resource_type='Observation' AND t.param_name='code' AND t.resource_id IN "
                                   "(SELECT resource_id FROM fhir_reference_index WHERE resource_type='Observation' AND param_name='patient' AND target_id=?) "
                                   "GROUP BY t.code ORDER BY COUNT(*) DESC, t.code LIMIT 1")
                               pid))
      (define date (query-value c (string-append
                                   "SELECT MIN(d.low) FROM fhir_date_index d WHERE d.resource_type='Observation' AND d.param_name='date' AND d.resource_id IN "
                                   "(SELECT resource_id FROM fhir_reference_index WHERE resource_type='Observation' AND param_name='patient' AND target_id=?)")
                               pid))
      (values pid code (substring date 0 10)))))

;; bench-query : db-path Nat -> hash   name -> (hasheq 'ms median 'answer what-came-back)
(define (bench-query db-path runs)
  (dynamic-require tower #f)
  (define sps (catalog))
  (define store (open-fhir-store db-path))
  (define-values (pid code date) (subject store))
  (define patient (string-append "Patient/" pid))
  (define (search type . params)
    (lambda ()
      (define-values (rs _ignored total)
        (fhir-search/page store type (let loop ([ps params]) (if (null? ps) '() (cons (cons (car ps) (cadr ps)) (loop (cddr ps)))))
                          #:search-params sps))
      (format "~a of ~a" (length rs) total)))
  (define (sql text . args)
    (lambda () (call-with-store-connection store (lambda (c) (format "~a" (apply query-value c text args))))))
  (define questions
    (list
     (cons "a patient's observations, first 10"            (search "Observation" "patient" patient "_count" "10"))
     (cons "a patient's observations of one code"          (search "Observation" "patient" patient "code" code))
     (cons "a patient's observations from a date, sorted"  (search "Observation" "patient" patient "date" (string-append "ge" date) "_sort" "date" "_count" "10"))
     (cons "a patient's latest observation"                (search "Observation" "patient" patient "_sort" "-date" "_count" "1"))
     (cons "a patient's latest observation of one code"    (search "Observation" "patient" patient "code" code "_sort" "-date" "_count" "1"))
     (cons "a patient's encounters"                        (search "Encounter" "patient" patient))
     (cons "a patient's encounters in a period, sorted"    (search "Encounter" "patient" patient "date" (string-append "ge" date) "_sort" "date"))
     (cons "a patient's prescriptions with medications"    (search "MedicationRequest" "patient" patient "_include" "MedicationRequest:medication"))
     (cons "every observation of one code, counted"        (search "Observation" "code" code "_count" "0"))
     (cons "SQL: a patient's observations by JSON path"
           (sql "SELECT COUNT(*) FROM fhir_resources WHERE resource_type='Observation' AND resource ->> '$.subject.reference' = ?" patient))
     (cons "SQL: a patient's observations through the index"
           (sql (string-append "SELECT COUNT(*) FROM fhir_resources r WHERE r.resource_type='Observation' AND r.id IN "
                               "(SELECT resource_id FROM fhir_reference_index WHERE resource_type='Observation' AND param_name='patient' AND target_type='Patient' AND target_id=?)")
                pid))
     (cons "SQL: a patient's observations grouped by code"
           (sql (string-append "SELECT COUNT(*) FROM (SELECT r.resource ->> '$.code.coding[0].code' AS code, COUNT(*) FROM fhir_resources r WHERE r.resource_type='Observation' AND r.id IN "
                               "(SELECT resource_id FROM fhir_reference_index WHERE resource_type='Observation' AND param_name='patient' AND target_type='Patient' AND target_id=?) GROUP BY 1)")
                pid))
     (cons "SQL: every observation counted by status"
           (sql "SELECT COUNT(*) FROM (SELECT resource ->> '$.status', COUNT(*) FROM fhir_resources WHERE resource_type='Observation' GROUP BY 1)"))))
  (define results
    (for/list ([q (in-list questions)])
      (define answer ((cdr q)))                          ; once to warm, and for what came back
      (define ms (median-ms runs (cdr q)))
      (hasheq 'question (car q) 'ms (round1 ms) 'answer answer)))
  (close-fhir-store store)
  (hasheq 'patient pid 'code code 'date date 'runs runs 'questions results))

;; ---- reports ---------------------------------------------------------------------------------
(define (print-load r)
  (printf "~a resources in ~a files\n" (hash-ref r 'resources) (hash-ref r 'files))
  (for ([phase '(read index load)])
    (printf "  ~a ~a ms  ~a resources/s\n" (pad (symbol->string phase) 6)
            (pad-left (hash-ref r (string->symbol (format "~a_ms" phase))) 9)
            (pad-left (hash-ref r (string->symbol (format "~a_per_s" phase))) 7)))
  (printf "  store ~a MB\n" (round1 (/ (hash-ref r 'store_bytes) 1048576.0)))
  (printf "  index extraction by type (µs a resource):\n")
  (for ([(type v) (in-hash (hash-ref r 'index_us_by_type))])
    (printf "    ~a ~a   (~a resources)\n" (pad (symbol->string type) 26) (pad-left (hash-ref v 'us_each) 7) (hash-ref v 'resources))))

(define (print-query r)
  (printf "patient ~a, code ~a, from ~a; the median of ~a runs\n" (hash-ref r 'patient) (hash-ref r 'code) (hash-ref r 'date) (hash-ref r 'runs))
  (for ([q (in-list (hash-ref r 'questions))])
    (printf "  ~a ms  ~a  -> ~a\n" (pad-left (hash-ref q 'ms) 9) (pad (hash-ref q 'question) 46) (hash-ref q 'answer))))

(define (pad s n) (string-append s (make-string (max 0 (- n (string-length s))) #\space)))
(define (pad-left v n) (let ([s (format "~a" (if (and (real? v) (integer? v)) (inexact->exact v) v))])
                         (string-append (make-string (max 0 (- n (string-length s))) #\space) s)))

;; ---- command line ----------------------------------------------------------------------------
;; option : (listof string) flag default -> string   the value after a flag
(define (option args flag default)
  (match (member flag args) [(list _ v _ ...) v] [_ default]))

(define (write-json-file r file)
  (when file (call-with-output-file file #:exists 'truncate (lambda (o) (write-json r o) (newline o)))))

(module+ main
  (match (vector->list (current-command-line-arguments))
    [(list "sample" from to rest ...)
     (define n (string->number (option rest "--per-file" "4000")))
     (printf "~a resources written to ~a\n" (sample! from to n) to)]
    [(list "load" dir rest ...)
     (define db (option rest "--db" (path->string (build-path (find-system-path 'temp-dir) "store-bench.db"))))
     (define r (bench-load dir db))
     (print-load r)
     (write-json-file r (option rest "--json" #f))]
    [(list "query" db rest ...)
     (define r (bench-query db (string->number (option rest "--runs" "5"))))
     (print-query r)
     (write-json-file r (option rest "--json" #f))]
    [_ (eprintf "usage: racket store-bench.rkt sample <ndjson-dir> <out-dir> [--per-file N]\n       racket store-bench.rkt load <ndjson-dir> [--db file] [--json out.json]\n       racket store-bench.rkt query <store.db> [--runs N] [--json out.json]\n")
       (exit 2)]))

(module+ test
  (require rackunit)
  (check-equal? (option '("--db" "x.db" "--json" "o.json") "--json" #f) "o.json")
  (check-equal? (option '("--db" "x.db") "--json" #f) #f)
  (check-equal? (pad-left 12.0 5) "   12")
  (check-equal? (round1 3.14159) 3.1)
  ;; a sample is the first lines of each file, gunzipped names
  (define from (make-temporary-directory "bench-from-~a"))
  (define to (make-temporary-directory "bench-to-~a"))
  (display-lines-to-file '("{\"resourceType\":\"Patient\",\"id\":\"a\"}" "{\"resourceType\":\"Patient\",\"id\":\"b\"}" "{\"resourceType\":\"Patient\",\"id\":\"c\"}")
                         (build-path from "Patient.ndjson"))
  (check-equal? (sample! from to 2) 2)
  (check-equal? (length (file->lines (build-path to "Patient.ndjson"))) 2)
  (check-equal? (map (lambda (r) (hash-ref r 'id)) (read-all (bulk-files to))) '("a" "b"))
  (delete-directory/files from)
  (delete-directory/files to))
