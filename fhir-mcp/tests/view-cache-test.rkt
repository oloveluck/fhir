#lang racket/base

;;; view-cache-test.rkt — a view's rows are kept between calls (mcp/view-cache.rkt) and never stale.
;;;
;;; SQL over a view reads its rows from `.fhir-mcp/views.db` once they are made; they are made
;;; again when anything they depend on changes: a commit to the store, the view's text, another
;;; process's hub (the file is the workspace's, not the process's). Over a directory of files nothing
;;; is kept (a hub reads the files when it opens): each call reads what its hub read.

(require rackunit racket/file racket/string json db
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/tools tool-name tool-run))

(define (view name cols)
  (jsexpr->string
   (hasheq 'resourceType "ViewDefinition" 'name name 'status "active" 'resource "MedicationRequest"
           'select (list (hasheq 'column (for/list ([c (in-list cols)]) (hasheq 'name (car c) 'path (cdr c))))))))
(define (rx id code)
  (format "Instance: ~a\nInstanceOf: MedicationRequest\n* status = #active\n* intent = #order\n* subject = Reference(Patient/ann)\n* medicationCodeableConcept = http://www.nlm.nih.gov/research/umls/rxnorm#~a\n" id code))
(define ann "Instance: ann\nInstanceOf: Patient\n* name.given = \"Ann\"\n\n")

;; caller : hub -> (name args -> jsexpr)
(define ((caller h) name args)
  (define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (check-false err? (format "~a: ~a" name text))
  (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)))
(define (rows call sql) (hash-ref (call "query" (hasheq 'language "sql" 'text sql)) 'rows))
;; made : dir -> (listof (list name key))   what the cache holds
(define (made dir)
  (define f (build-path dir ".fhir-mcp" "views.db"))
  (if (file-exists? f)
      (let ([c (sqlite3-connect #:database f #:mode 'read-only)])
        (begin0 (map vector->list (query-rows c "SELECT name, key FROM kept ORDER BY name")) (disconnect c)))
      '()))

;; ---- over a store ----------------------------------------------------------------------------
(define dir (make-temporary-directory "view-cache-~a"))
(void (init-workspace! dir))
(define h (open-hub dir))
(define call (caller h))
(with-hub h
  (lambda ()
    (call "write" (hasheq 'path "meds.view.json" 'text (view "meds" '(("id" . "getResourceKey()") ("drug" . "medicationCodeableConcept.coding.first().code")))))
    (define st (call "stage" (hasheq 'fsh (string-append ann (rx "rx1" "860975")))))
    (call "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "intake"))
    (check-equal? (rows call "SELECT id, drug FROM meds") (list (hasheq 'id "rx1" 'drug "860975")))
    (define k1 (made dir))
    (check-equal? (length k1) 1 "the view's rows are kept")
    ;; asked again (and by its other name: the file's stem is `meds` too): the same rows, not made again
    (check-equal? (rows call "SELECT count(*) AS n FROM meds") (list (hasheq 'n 1)))
    (check-equal? (made dir) k1)
    ;; a commit: made again, the new row there
    (define st2 (call "stage" (hasheq 'fsh (rx "rx2" "197361"))))
    (call "commit" (hasheq 'stage (hash-ref st2 'stage) 'reason "second"))
    (check-equal? (rows call "SELECT id FROM meds ORDER BY id") (list (hasheq 'id "rx1") (hasheq 'id "rx2")))
    (check-not-equal? (made dir) k1)
    ;; the view's text changed: its new column
    (call "write" (hasheq 'path "meds.view.json" 'text (view "meds" '(("id" . "getResourceKey()") ("status" . "status")))))
    (check-equal? (rows call "SELECT id, status FROM meds ORDER BY id")
                  (list (hasheq 'id "rx1" 'status "active") (hasheq 'id "rx2" 'status "active")))
    (check-equal? (length (made dir)) 1 "one table per view: the old one is dropped")
    ;; every version too (meds_history): kept apart, the same way
    (check-equal? (rows call "SELECT count(*) AS n FROM meds_history") (list (hasheq 'n 2)))
    (check-equal? (length (made dir)) 2)))
;; another process (a hub opened afresh) reads the kept rows
(let ([before (made dir)] [h2 (open-hub dir)])
  (with-hub h2 (lambda () (check-equal? (length (rows (caller h2) "SELECT id FROM meds")) 2)))
  (check-equal? (made dir) before))
(delete-directory/files dir)

;; ---- over a directory of files: not kept ----------------------------------------------------------
(define fdir (make-temporary-directory "view-cache-files-~a"))
(make-directory (build-path fdir "data"))
(call-with-output-file (build-path fdir "workspace.yaml")
  (lambda (o) (void (write-string "fhirVersion: 4.0.1\ncanonical: http://example.org/fhir\ndata: data/\n" o))))
(define (write-rx! id)
  (call-with-output-file (build-path fdir "data" (string-append id ".json")) #:exists 'replace
    (lambda (o) (write-json (hasheq 'resourceType "MedicationRequest" 'id id 'status "active" 'intent "order"
                                    'subject (hasheq 'reference "Patient/ann")) o))))
(write-rx! "a")
(call-with-output-file (build-path fdir "meds.view.json")
  (lambda (o) (void (write-string (view "meds" '(("id" . "getResourceKey()"))) o))))
(define fh (open-hub fdir))
(with-hub fh
  (lambda ()
    (define call (caller fh))
    (check-equal? (rows call "SELECT id FROM meds") (list (hasheq 'id "a")))
    (void)))
;; a file added between two calls (another process: a hub reads a directory's data when it opens)
(write-rx! "b")
(let ([fh2 (open-hub fdir)])
  (with-hub fh2 (lambda () (check-equal? (rows (caller fh2) "SELECT id FROM meds ORDER BY id") (list (hasheq 'id "a") (hasheq 'id "b")))))
  (check-equal? (made fdir) '()))
(delete-directory/files fdir)
