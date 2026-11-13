#lang racket/base

;;; export.rkt — the text export: what the store holds as definitions, written out as text for git.
;;;
;;; The store is the repository; git cannot diff or merge it. The export is its mirror as text —
;;; readable diffs, review, CI, a rebuild — in the directory workspace.yaml names (`export: export/`),
;;; rewritten when a commit changes a definition, never read back by the workspace (fhir/lang/
;;; workspace leaves the directory out of its sources).
;;;
;;; What is written (the Export of a hub, a list of ExportFiles):
;;;   - the files the commits KEPT — the author's own text, comments and RuleSets included: for each
;;;     source file a Provenance holds, its newest text, as long as it still states a resource the
;;;     store holds now;
;;;   - one file for each current definition no kept file states (loaded as JSON, staged as text in
;;;     a call, changed since by another source), written from the resource: the guide as
;;;     `sushi-config.yaml`, a library as its CQL, a map as the mapping language, the rest as FSH
;;;     (`<Type>-<id>.<ext>`), and likewise each example the guide lists.
;;; "Current" is every stored definition under its own id (a released version kept beside the next,
;;; `<id>-<version>`, is history: git has it) and the examples the stored guide lists.
;;;
;;; The law (tests/export-test.rkt): the export, put back as a workspace's files, compiles to what
;;; is stored — staged, it is "nothing to commit".

(require racket/contract racket/file racket/list racket/match racket/path racket/string json
         fhir/lang/workspace
         (only-in fhir/data-source data-source-all)
         "hub.rkt" "artifacts.rkt" "fsh-source.rkt" "describe.rkt")

(provide
 (contract-out
  ;; An ExportFile is (export-file name text): a path relative to the export directory, its text
  [struct export-file ([name string?] [text string?])]
  ;; export-directory : hub -> path | #f   the directory workspace.yaml's `export` names
  [export-directory (-> hub? (or/c path? #f))]
  ;; export-files : hub -> (listof ExportFile)   the Export, sorted by name (within `with-hub`)
  [export-files (-> hub? (listof export-file?))]
  ;; export! : hub -> jsexpr   the Export written: files whose text changed, files of an earlier
  ;; export that no longer belong removed; {directory, files, written, removed}
  [export! (-> hub? jsexpr?)]
  ;; export-drift : hub -> (listof string)   how the directory differs from the Export (for CI):
  ;; `missing <file>`, `differs <file>`, `stale <file>`; none when it is up to date
  [export-drift (-> hub? (listof string?))]))

(struct export-file (name text) #:transparent)

(define (export-directory h)
  (define d (ws-config-export (workspace-config (hub-ws h))))
  (and d (simplify-path (path->complete-path d (hub-root h)))))

;; ---- what is current ---------------------------------------------------------------------------
;; stored : hub type -> (listof resource)   every stored resource of a type, every version's instance
(define (stored h type) ((data-source-all (hub-data h)) type))

;; current-definitions : hub -> (listof artifact)   each stored definition under its own id
(define (current-definitions h)
  (for*/list ([type (in-list artifact-types)] [r (in-list (stored h type))]
              #:when (equal? (unarchived r) r))
    r))

;; listed-examples : hub (listof artifact) -> (listof resource)   the stored resources the guides
;; list that are not definitions (a guide's definition.resource names each as Type/id)
(define (listed-examples h definitions)
  (define refs
    (remove-duplicates
     (for*/list ([g (in-list definitions)] #:when (equal? (hash-ref g 'resourceType #f) "ImplementationGuide")
                 [entry (in-list (hash-ref (hash-ref g 'definition (hasheq)) 'resource '()))]
                 [ref (in-value (hash-ref (hash-ref entry 'reference (hasheq)) 'reference #f))]
                 #:when (string? ref))
       ref)))
  (for*/list ([ref (in-list refs)]
              [m (in-value (regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" ref))]
              #:when (and m (not (member (cadr m) artifact-types)))
              [r (in-value (findf (lambda (r) (equal? (hash-ref r 'id #f) (caddr m))) (stored h (cadr m))))]
              #:when r)
    r))

(define (key-of r) (format "~a/~a" (hash-ref r 'resourceType) (hash-ref r 'id "")))

;; ---- what the commits kept ---------------------------------------------------------------------
;; A Kept is (kept path language text recorded targets): a source file a Provenance holds — its
;; path as the trail names it, the workspace language of that name, the text, when it was recorded,
;; and the resources (Type/id) that commit made from it.
(struct kept (path language text recorded targets))

;; provenance-kept : Provenance -> Kept | #f   #f when its source is no file of a workspace language
;; inside the workspace (FSH written in a call, a result, a file from elsewhere)
(define (provenance-kept pv)
  (define path (for/first ([e (in-list (hash-ref pv 'entity '()))])
                 (hash-ref (hash-ref e 'what (hasheq)) 'display #f)))
  (define text (for*/first ([c (in-list (hash-ref pv 'contained '()))] [d (in-list (hash-ref c 'content '()))]
                            [a (in-value (hash-ref d 'attachment #f))]
                            #:when (and (hash? a) (string? (hash-ref a 'data #f))))
                 (text-answer-text (as-source pv))))
  (define language (and (string? path) (not (regexp-match? #rx"^([.][.]|/)" path)) (regexp-match? #rx"[.]" path)
                        (workspace-language-of path)))
  (and language text
       (kept path language text (hash-ref pv 'recorded "")
             (for*/list ([t (in-list (hash-ref pv 'target '()))]
                         [m (in-value (regexp-match #px"^([A-Z][A-Za-z]+/[A-Za-z0-9.-]+)" (hash-ref t 'reference "")))]
                         #:when m)
               (cadr m)))))

;; states? : Kept resource -> boolean   whether the kept text still states the resource: an FSH
;; file by an entity of that id; a file of a one-resource language when it was that resource's source
(define (states? k r)
  (define id (hash-ref r 'id ""))
  (if (equal? (kept-language k) "fsh")
      (and (or (definition-line (kept-text k) id) (instance-line (kept-text k) id)) #t)
      (and (member (key-of r) (kept-targets k)) #t)))

;; ---- the Export --------------------------------------------------------------------------------
(define (export-files h)
  (define definitions (current-definitions h))
  (define current (append definitions (listed-examples h definitions)))
  ;; every kept file, newest first; then the newest text of each path
  (define all-kept (sort (filter values (map provenance-kept (stored h "Provenance"))) string>? #:key kept-recorded))
  (define newest (for/fold ([seen '()] #:result (reverse seen)) ([k (in-list all-kept)])
                   (if (findf (lambda (s) (equal? (kept-path s) (kept-path k))) seen) seen (cons k seen))))
  ;; a resource is stated by the newest text of the file its own newest commit was made from
  (define (kept-for r)
    (define own (findf (lambda (k) (member (key-of r) (kept-targets k))) all-kept))
    (define k (and own (findf (lambda (n) (equal? (kept-path n) (kept-path own))) newest)))
    (and k (states? k r) k))
  (define-values (stated unstated) (partition kept-for current))
  (define used (remove-duplicates (map kept-for stated) eq?))
  (sort (append (for/list ([k (in-list used)]) (export-file (kept-path k) (kept-text k)))
                (for/list ([r (in-list unstated)]) (written-from h r)))
        string<? #:key export-file-name))

;; written-from : hub resource -> ExportFile   a current resource no kept file states, as the text
;; that states it: a definition as describe.rkt's edit writes it, an example as an FSH Instance
(define (written-from h r)
  (define-values (language text)
    (cond [(artifact? r) (let ([lt (artifact-text h r)]) (values (car lt) (cdr lt)))]
          [else (values "fsh" (text-answer-text (hub-describe h (key-of r) (hasheq 'as "fsh"))))]))
  (export-file (match language
                 ["ig" ig-file-name]
                 [_ (format "~a-~a.~a" (hash-ref r 'resourceType) (hash-ref r 'id)
                            (match language ["cql" "cql"] ["vcl" "vcl"] ["fml" "map"] [_ "fsh"]))])
               (if (regexp-match? #rx"\n$" text) text (string-append text "\n"))))

;; ---- writing it --------------------------------------------------------------------------------
;; The files of the last export are remembered in the workspace's state (.fhir-mcp/export.json), so
;; a file that no longer belongs is removed — and nothing else in the directory is ever touched.
(define (remembered-file h) (build-path (hub-root h) ".fhir-mcp" "export.json"))
(define (remembered h)
  (define f (remembered-file h))
  (with-handlers ([exn:fail? (lambda (_) '())])
    (if (file-exists? f) (filter string? (call-with-input-file f read-json)) '())))

(define (configured-directory h who)
  (define dir (or (export-directory h)
                  (error who "no export directory: set `export: export/` in workspace.yaml")))
  (when (equal? (path->directory-path dir) (path->directory-path (simplify-path (hub-root h))))
    (error who "`export` names the workspace itself: give it a directory of its own (export: export/)"))
  dir)

(define (current-text f) (and (file-exists? f) (file->string f)))

(define (export! h)
  (define dir (configured-directory h 'export))
  (define files (with-hub h (lambda () (export-files h))))
  (define names (map export-file-name files))
  (define written
    (for/list ([f (in-list files)]
               #:unless (equal? (current-text (build-path dir (export-file-name f))) (export-file-text f)))
      (define p (build-path dir (export-file-name f)))
      (make-directory* (path-only p))
      (call-with-output-file p #:exists 'truncate/replace (lambda (o) (write-string (export-file-text f) o)))
      (export-file-name f)))
  (define removed
    (for/list ([name (in-list (remembered h))]
               #:unless (member name names)
               #:when (file-exists? (build-path dir name)))
      (delete-file (build-path dir name))
      name))
  (make-directory* (path-only (remembered-file h)))
  (call-with-output-file (remembered-file h) #:exists 'truncate/replace (lambda (o) (write-json names o)))
  (for/fold ([answer (hasheq 'directory (path->string (find-relative-path (simplify-path (hub-root h)) dir))
                             'files (length files))])
            ([kv (in-list (list (cons 'written written) (cons 'removed removed)))] #:when (pair? (cdr kv)))
    (hash-set answer (car kv) (cdr kv))))

(define (export-drift h)
  (define dir (configured-directory h 'export))
  (define files (with-hub h (lambda () (export-files h))))
  (define names (map export-file-name files))
  (append (for/list ([f (in-list files)]
                     #:unless (equal? (current-text (build-path dir (export-file-name f))) (export-file-text f)))
            (format "~a ~a" (if (file-exists? (build-path dir (export-file-name f))) "differs" "missing") (export-file-name f)))
          (for/list ([name (in-list (remembered h))]
                     #:unless (member name names) #:when (file-exists? (build-path dir name)))
            (format "stale ~a" name))))

(module+ test
  (require rackunit)
  ;; a Provenance's source is a kept file when the trail names a workspace-language file inside the
  ;; workspace
  (define (pv path) (hasheq 'resourceType "Provenance" 'recorded "2026-01-01T00:00:00Z"
                            'target (list (hasheq 'reference "StructureDefinition/lab/_history/2") (hasheq 'reference "Patient/ann/_history/1"))
                            'entity (list (hasheq 'role "source" 'what (hasheq 'reference "#source" 'display path)))
                            'contained (list (hasheq 'resourceType "DocumentReference" 'id "source"
                                                     'content (list (hasheq 'attachment (hasheq 'contentType "text/fsh"
                                                                                                'data "UHJvZmlsZTogTGFiCklkOiBsYWIKCkluc3RhbmNlOiBhbm4KSW5zdGFuY2VPZjogUGF0aWVudAo=")))))))
  (define k (provenance-kept (pv "lab.fsh")))
  (check-equal? (list (kept-path k) (kept-language k) (kept-targets k)) '("lab.fsh" "fsh" ("StructureDefinition/lab" "Patient/ann")))
  (check-false (provenance-kept (pv "../elsewhere/lab.fsh")))
  (check-false (provenance-kept (pv "FSH written in the stage")))
  ;; an FSH file states a resource by an entity of its id
  (check-true (states? k (hasheq 'resourceType "StructureDefinition" 'id "lab")))
  (check-true (states? k (hasheq 'resourceType "Patient" 'id "ann")))
  (check-false (states? k (hasheq 'resourceType "Patient" 'id "bob"))))
