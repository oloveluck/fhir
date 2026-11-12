#lang racket/base

;;; describe.rkt — the verb describe: a result (paged, as CSV, diffed against another), a stored
;;; resource (as JSON, as FSH, as the source that wrote it), its history, a type's trail, a
;;; definition by canonical, an element, an operation, the stages not committed.

(require racket/list racket/string racket/match fhir/lang/workspace (only-in fhir/suggest did-you-mean)
         (only-in net/base64 base64-decode)
         (only-in fhir/registry registered-resource registered-resources registered-kinds)
         (only-in fhir/data-source current-data-source data-source-all data-source-read)
         (only-in db sqlite3-connect query-value disconnect)
         (only-in fhir/sd/sd-index resolve-canonical-raw sd-index-available?)
         (only-in fhir/operation operation operation-definition operation-code operation-url operation-levels
                  operation-resource-types)
         "sql.rkt" "trail.rkt" "views.rkt" "fsh-source.rkt" "tools.rkt" "calls.rkt" "json-diff.rkt"
         "results.rkt" "hub.rkt" "data.rkt" "run.rkt" "check.rkt" "artifacts.rkt"
         (only-in fhir/ig-config parse-ig-config ig-config-version ig-config-id))

;; Contracted in workspace.rkt; stage reads a history and the definition kinds.
(provide conformance-kinds (struct-out text-answer) hub-describe describe-history hub-edit!)

(define conformance-kinds '("StructureDefinition" "ValueSet" "CodeSystem" "ConceptMap" "StructureMap"))

;; ---- answers that are text ---------------------------------------------------------------------
;; A TextAnswer is (text-answer string): an answer that is text, not JSON (an FSH rendering), sent
;; as it is (as JSON every newline would be escaped)
(struct text-answer (text))
;; as-fsh : resource -> TextAnswer   the resource as an FSH Instance (fsh/decompile, loaded on demand:
;; fhir-mcp does not depend on fsh) — a third shorter than its JSON for coded data, and the form FSH files use
(define (as-fsh r [stamped '()])
  (define fhir->fsh (with-handlers ([exn:fail? (lambda (_) (error 'describe "as \"fsh\" needs the fsh package"))])
                      (dynamic-require 'fsh/decompile 'fhir->fsh)))
  ;; `Usage: #example` is what an Instance means without it: not said; nor the store's bookkeeping
  ;; (meta.versionId, meta.lastUpdated — describe as JSON shows them), nor the profiles staging claims
  ;; by itself (workspace.yaml's `profiles`: a correction staged again gets them again)
  (define meta (let ([m (hash-ref r 'meta #f)])
                 (and (hash? m)
                      (let* ([m (hash-remove (hash-remove m 'versionId) 'lastUpdated)]
                             [ps (let ([p (hash-ref m 'profile '())]) (if (list? p) (filter (lambda (u) (not (member u stamped))) p) p))])
                        (if (null? ps) (hash-remove m 'profile) (hash-set m 'profile ps))))))
  (define r* (cond [(not meta) r] [(zero? (hash-count meta)) (hash-remove r 'meta)] [else (hash-set r 'meta meta)]))
  (text-answer (regexp-replace #rx"\nUsage: #example(?=\n|$)" (fhir->fsh r*) "")))

;; as-source : resource -> text-answer   the text a resource carries as an attachment: the source a
;; commit's Provenance holds (a contained DocumentReference, base64), a DocumentReference's, a Binary's
(define (as-source r)
  (define (attachments x)
    (match (hash-ref x 'resourceType #f)
      ["Binary" (list (hasheq 'data (hash-ref x 'data "") 'contentType (hash-ref x 'contentType "")))]
      ["DocumentReference" (for/list ([c (in-list (hash-ref x 'content '()))] #:when (hash? (hash-ref c 'attachment #f))) (hash-ref c 'attachment))]
      [_ (append-map attachments (filter hash? (hash-ref x 'contained '())))]))
  (define a (for/first ([a (in-list (attachments r))] #:when (string? (hash-ref a 'data #f))) a))
  (unless a (error 'describe (format "~a/~a carries no source text (as: \"source\" reads a commit's Provenance, a DocumentReference or a Binary)"
                                     (hash-ref r 'resourceType "?") (hash-ref r 'id "?"))))
  (text-answer (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (hash-ref a 'data))) #\?)))

;; ---- describe ----------------------------------------------------------------------------------
(define (hub-describe h ref args)
  (define fsh? (equal? (hash-ref args 'as #f) "fsh"))
  (define source? (equal? (hash-ref args 'as #f) "source"))
  (define (shown r) (cond [(and fsh? (hash? r) (string? (hash-ref r 'resourceType #f)))
                                (as-fsh r (hash-ref (ws-config-profiles (workspace-config (hub-ws h))) (hash-ref r 'resourceType) '()))]
                          [(and source? (hash? r)) (as-source r)]
                          [else r]))
  (define offset (let ([o (hash-ref args 'offset 0)]) (if (exact-nonnegative-integer? o) o 0)))
  (define limit (let ([l (hash-ref args 'limit 20)]) (if (exact-positive-integer? l) l 20)))
  (define against (let ([a (hash-ref args 'against #f)]) (and (string? a) a)))
  (with-hub h
    (lambda ()
      (cond
        [(and (regexp-match? #rx"^result://" ref) (equal? (hash-ref args 'as #f) "csv") (not against))
         (result-csv h ref offset (let ([l (hash-ref args 'limit #f)]) (if (exact-positive-integer? l) l 1000))
                     #:columns (column-list (hash-ref args 'columns #f))
                     #:sort (let ([v (hash-ref args 'sort #f)]) (and (string? v) v)))]
        [(regexp-match? #rx"^result://" ref) (describe-result h ref offset limit against)]
        [(equal? ref "stages") (describe-stages h)]
        [(regexp-match #px"^(?:([A-Za-z]+)/)?[$]([A-Za-z-]+)$" ref) (describe-operation ref)]
        [(regexp-match? #rx"/OperationDefinition/" ref) (describe-operation ref)]
        ;; where each stored value came from, for a type: its current version with who, when, why and
        ;; from which file and line (a join copied from deep in the guide answered it before)
        ;; (`describe ref=Observation as=trail`), or every version of one (`ref=Observation/a1/_history
        ;; as=trail`, as=csv too), with its value; `columns`/`sort` as for any table
        [(and (member (hash-ref args 'as #f) '("trail" "csv"))
              (or (and (equal? (hash-ref args 'as #f) "trail") (regexp-match #px"^([A-Z][A-Za-z]+)$" ref))
                  (regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)/_history$" ref)))
         => (lambda (m)
              (define name (if (pair? (cddr m))
                               (string-append (string-downcase (cadr m)) "_" (string-replace (caddr m) "-" "_") "_history")
                               (string-append (string-downcase (cadr m)) "_trail")))
              (define uri (hash-ref (parameterize ([current-extra-tables (apply trail-tables h (cdr m))])
                                      (hub-query h "sql" (apply trail-sql h (cdr m)) (hasheq 'name name)))
                                    'result))
              ;; called from elsewhere, a source file and its line read from where the call was made
              ;; (`patients.fsh:22`, not the workspace's `../patients.fsh:22`): this answer is for
              ;; opening; SQL's `trail` keeps the one form
              (unless (at-root? h) (paths-from-here! h uri))
              (define csv (hub-describe h uri
                                        (for/hasheq ([k (in-list '(as columns sort limit))] #:when (hash-ref args k #f))
                                          (values k (if (eq? k 'as) "csv" (hash-ref args k))))))
              ;; CSV only (a `#` note line after it was a junk row in a CSV tool); `source`/`at` are the
              ;; trail's own paths, relative to the workspace — the skill and history's `paths` say so
              csv)]
        ;; a definition as the text that states it, to edit (`write path=… ref=…` saves it as a file)
        [(and source? (artifact-of h ref)) => (lambda (r) (text-answer (cdr (artifact-text h r))))]
        ;; the source text a stored resource was written from, read through its newest Provenance —
        ;; no id to copy (`describe ref=Observation/a1/_history as=source`, or the resource itself)
        [(and source? (let ([m (regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)(?:/_history)?$" ref)])
                        (and m (not (member (cadr m) '("Provenance" "DocumentReference" "Binary"))) m)))
         => (lambda (m)
              (define pv (let ([vs (hash-ref (describe-history h (cadr m) (caddr m)) 'versions '())])
                           (for/first ([v (in-list vs)] #:when (hash-ref v 'provenance #f)) (hash-ref v 'provenance))))
              (unless pv (error 'describe (format "~a was not written by a commit: no Provenance holds its source" ref)))
              (define whole (as-source ((data-source-read (current-data-source)) "Provenance" (cadr (regexp-match #rx"^Provenance/(.+)$" pv)))))
              ;; this resource's own Instance, not the whole file it came in (six instances answered
              ;; for one); `describe ref=<the Provenance> as=source` gives the whole text
              (define block (instance-block (text-answer-text whole) (caddr m)))
              (if block (text-answer block) whole))]
        [(regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)/_history$" ref)
         => (lambda (m) (history-from-here h (describe-history h (cadr m) (caddr m))))]
        [(regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" ref)
         => (lambda (m) (shown (or ((data-source-read (current-data-source)) (cadr m) (caddr m))
                                   (registered-resource (cadr m) (caddr m))
                                   (error 'describe (format "no ~a in the data or the workspace" ref)))))]
        [(regexp-match? #rx"://" ref)
         ;; a canonical: the version asked for among the stored ones (`url|0.1.0`), else the
         ;; workspace's working copy, the store's current version, the packages
         (define r (or (and (regexp-match? #rx"[|]" ref) (stored-artifact h ref))
                       (for/or ([k (in-list (registered-kinds))]) (registered-resource k ref))
                       (stored-artifact h ref)
                       (and (sd-index-available?) (for/or ([k (in-list conformance-kinds)]) (resolve-canonical-raw k ref)))))
         (if r (shown (trim-definition r)) (error 'describe (format "no definition ~a in the workspace, the store or the packages" ref)))]
        [(regexp-match #px"^([A-Z][A-Za-z]+)(?:[.](.+))?$" ref)
         => (lambda (m) (describe-element (cadr m) (caddr m) ref))]
        [else (search-definitions ref)]))))

;; ---- a definition as its text (edit) ------------------------------------------------------------
;; The store holds each definition as a resource; the languages are how it is read and written. A
;; stored definition comes back as the text that states it, so a working file deleted, or never
;; here, is one call away.

;; artifact-of : hub ref -> artifact | #f   the stored definition a canonical (`url`, `url|version`)
;; or a Type/id names; else the one a workspace file defines
(define (artifact-of h ref)
  (define r
    (match ref
      [(pregexp #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" (list _ type id))
       (and (member type artifact-types) ((data-source-read (current-data-source)) type id))]
      [(regexp #rx"://") (or (stored-artifact h ref) (for/or ([k (in-list artifact-types)]) (registered-resource k ref)))]
      [_ #f]))
  (and (hash? r) (artifact? r) r))

;; artifact-text : hub artifact -> (cons language string)   the language a definition is written in
;; and its text: a library's CQL (FHIR keeps it as the library's content), the guide's
;; sushi-config.yaml (the file a commit kept, when that states this version; else written from the
;; resource), FSH for the rest (decompiled). An archived version is written under its own id.
(define (artifact-text h stored)
  (define r (unarchived stored))
  (match (hash-ref r 'resourceType #f)
    ["ImplementationGuide" (cons "ig" (or (kept-guide-text h stored) (guide-text r)))]
    ["Library" (cond [(library-cql r) => (lambda (cql) (cons "cql" cql))]
                     [else (cons "fsh" (definition-fsh r))])]
    ["StructureMap" (error 'describe (format "~a/~a: a stored StructureMap is not written back as FML yet (describe it as JSON, or as=fsh)"
                                             (hash-ref r 'resourceType) (hash-ref r 'id "?")))]
    [_ (cons "fsh" (definition-fsh r))]))

;; library-cql : Library -> string | #f   its CQL, when it carries one
(define (library-cql r)
  (for/first ([c (in-list (hash-ref r 'content '()))]
              #:when (and (hash? c) (equal? (hash-ref c 'contentType #f) "text/cql") (string? (hash-ref c 'data #f))))
    (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (hash-ref c 'data))) #\?)))

;; definition-fsh : artifact -> string   as FSH, without what its collection gives it (version,
;; status, experimental flag, publisher — artifacts.rkt): stated in the text, they would no longer
;; follow the guide
(define (definition-fsh r)
  (text-answer-text (as-fsh (for/fold ([r r]) ([k (in-list '(version status experimental publisher))]) (hash-remove r k)))))

(define (guide-text g)
  ((with-handlers ([exn:fail? (lambda (_) (error 'describe "an implementation guide is written back as sushi-config.yaml by the fsh package"))])
     (dynamic-require 'fsh/ig 'implementation-guide->config-text))
   g))

;; kept-guide-text : hub guide -> string | #f   the sushi-config.yaml the newest commit of this
;; resource kept (its Provenance's source: comments, pages and menus included), when it is the file
;; of this version of this guide
(define (kept-guide-text h g)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (define text (kept-source h "ImplementationGuide" (hash-ref g 'id)))
    (define c (and text (parse-ig-config text)))
    (and c
         (equal? (ig-config-version c) (hash-ref g 'version #f))
         (equal? (ig-config-id c) (or (hash-ref g 'packageId #f) (hash-ref g 'id #f)))
         text)))

;; kept-source : hub type id -> string | #f   the whole source text the newest commit of a stored
;; resource kept
(define (kept-source h type id)
  (define pv (for/first ([v (in-list (hash-ref (describe-history h type id) 'versions '()))] #:when (hash-ref v 'provenance #f))
               (hash-ref v 'provenance)))
  (and pv (text-answer-text (as-source ((data-source-read (current-data-source)) "Provenance" (cadr (regexp-match #rx"^Provenance/(.+)$" pv)))))))

;; hub-edit! : hub path ref -> jsexpr   a stored definition written into the workspace as the file
;; that states it (write's answer: its problems), under a path of its language
(define (hub-edit! h p ref)
  (define-values (language text)
    (with-hub h (lambda ()
                  (define r (or (artifact-of h ref)
                                (error 'write (format "no definition ~a in the store or the workspace (`ref` is a canonical, or the Type/id of a definition)" ref))))
                  (define lt (artifact-text h r))
                  (values (car lt) (cdr lt)))))
  (unless (equal? (workspace-language-of (inside h p)) language)
    (error 'write (format "~a is written as ~a" ref
                          (match language ["ig" (format "the workspace's ~a" ig-file-name)] ["cql" "CQL: a .cql file"] [_ "FSH: a .fsh file"]))))
  (hash-set (hub-write! h p text) 'from ref))

;; ---- history -----------------------------------------------------------------------------------
;; describe-history : hub type id -> jsexpr   every version of a stored resource, newest first: when,
;; what changed since the one before, and the Provenance that wrote it (who, why, from what)
(define (describe-history h type id)
  (define p (or (data-store-path h) (error 'describe "history is kept by the workspace's store: data: fhir.db")))
  (define-values (store catalog) (open-store p (hub-packages h)))
  (define versions (reverse ((dynamic-require 'fhir/store/fhir-engine 'fhir-history) store type id)))   ; oldest first
  (when (null? versions) (error 'describe (format "no ~a/~a in the store" type id)))
  (define (vid r) (hash-ref (hash-ref r 'meta (hasheq)) 'versionId "?"))
  ;; the Provenances naming this resource, by the version they name
  (define provs
    (for*/hash ([pv (in-list ((dynamic-require 'fhir/store/fhir-engine 'fhir-search) store "Provenance"
                                                                                    (list (cons "target" (format "~a/~a" type id)))
                                                                                    #:search-params catalog))]
                [t (in-list (hash-ref pv 'target '()))]
                [m (in-value (regexp-match #px"^([A-Za-z]+)/([^/]+)/_history/([^/]+)$" (hash-ref t 'reference "")))]
                #:when (and m (equal? (cadr m) type) (equal? (caddr m) id)))
      (values (cadddr m) pv)))
  (define entries
    (for/list ([cur (in-list versions)] [prev (in-list (cons #f versions))])
      (define pv (hash-ref provs (vid cur) #f))
      (for/fold ([e (hasheq 'version (vid cur)
                            'recorded (hash-ref (hash-ref cur 'meta (hasheq)) 'lastUpdated "?")
                            'changed (if prev (json-diff prev cur) "created"))])
                ([kv (in-list (if pv
                                  (list (cons 'provenance (format "Provenance/~a" (hash-ref pv 'id "?")))
                                        ;; the commit's time, as the trail and the Provenance say it
                                        (cons 'recorded (hash-ref pv 'recorded #f))
                                        (cons 'agent (let ([a (hash-ref pv 'agent '())]) (and (pair? a) (let ([w (hash-ref (car a) 'who (hasheq))]) (or (hash-ref w 'display #f) (hash-ref w 'reference #f))))))
                                        (cons 'reason (or (let ([r (hash-ref pv 'reason '())]) (and (pair? r) (hash-ref (car r) 'text #f)))
                                                          (hash-ref pv 'why #f)))
                                        ;; the source as the trail keeps it (relative to the workspace), its
                                        ;; SHA-1 apart, and where in it this version was written — the same
                                        ;; values as SQL's `trail` (one form everywhere)
                                        (cons 'source (provenance-display pv))
                                        (cons 'sha1 (provenance-sha1 pv))
                                        (cons 'at (or (target-at pv (format "~a/~a/_history/~a" type id (vid cur))) (source-line pv id))))
                                  '()))]
                 #:when (cdr kv))
        (hash-set e (car kv) (cdr kv)))))
  ;; `source`/`at` are the trail's own paths (relative to the workspace, as SQL's `trail` has them):
  ;; say where that is when the call was made from elsewhere (a rerun's agent, in the folder above)
  (hasheq 'resource (format "~a/~a" type id) 'versions (reverse entries)))

;; history-from-here : hub history -> history   what `describe … /_history` answers: called from another
;; folder, each version's `source` and `at` read from there, as the trail CSV's do (the JSON said
;; `../bp-a1.fsh` and the CSV beside it `bp-a1.fsh`); SQL's `trail` keeps the workspace's form
(define (history-from-here h hist)
  (if (at-root? h)
      hist
      (hash-set hist 'versions
                (for/list ([v (in-list (hash-ref hist 'versions '()))])
                  (for/fold ([v v]) ([k '(source at)] #:when (string? (hash-ref v k #f)))
                    (hash-set v k (path-from-here h (hash-ref v k))))))))

;; source-line : Provenance id -> "file:line" | #f   the line of the FSH a commit's source holds where
;; the Instance with this id begins (a batch file of many resources: which lines made this one)
(define (source-line pv id [h #f])
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (define text (text-answer-text (as-source pv)))
    (define line (instance-line text id))
    (define title (for*/first ([c (in-list (hash-ref pv 'contained '()))]
                               [d (in-list (hash-ref c 'content '()))]
                               [t (in-value (hash-ref (hash-ref d 'attachment (hasheq)) 'title #f))] #:when (string? t))
                    t))
    (and line (format "~a:~a" (if (and title (not (equal? title "fsh"))) (if h (shown-path h title) title) "fsh") line))))

;; provenance-display : Provenance -> string|#f   its source, as written (`../src/a.fsh`)
(define (provenance-display pv)
  (let ([en (hash-ref pv 'entity '())]) (and (pair? en) (hash-ref (hash-ref (car en) 'what (hasheq)) 'display #f))))
;; provenance-sha1 : Provenance -> string|#f   the source's SHA-1, its identifier (as the trail view reads it)
(define (provenance-sha1 pv)
  (let* ([en (hash-ref pv 'entity '())]
         [id (and (pair? en) (hash-ref (hash-ref (car en) 'what (hasheq)) 'identifier #f))])
    (and (hash? id) (equal? (hash-ref id 'system #f) sha1-system) (hash-ref id 'value #f))))
;; target-at : Provenance Type/id/_history/v -> string|#f   the source line the commit wrote this version from
(define (target-at pv ref)
  (for*/first ([t (in-list (hash-ref pv 'target '()))]
               #:when (equal? (hash-ref t 'reference #f) ref)
               [e (in-list (hash-ref t 'extension '()))]
               #:when (equal? (hash-ref e 'url #f) source-line-url))
    (hash-ref e 'valueString #f)))

;; paths-from-here! : hub uri -> void   the result's `source` and `at` cells (a file the trail keeps
;; relative to the workspace, `../patients.fsh:22`) as seen from the current directory, when the file
;; is there to open
(define (paths-from-here! h uri)
  (define st (hash-ref (hub-results h) uri #f))
  (when st
    (define (here v) (path-from-here h v))
    (define r (stored-result st))
    (define rows (for/list ([row (in-list (run-result-rows r))])
                   (if (hash? row)
                       (for/fold ([row row]) ([k '(source at)] #:when (hash-has-key? row k))
                         (hash-set row k (here (hash-ref row k))))
                       row)))
    (hash-set! (hub-results h) uri (struct-copy stored st [result (run-result (run-result-kind r) (run-result-columns r) rows (run-result-summary r))]))))

;; ---- definitions, elements, operations ---------------------------------------------------------
;; trim-definition : resource -> resource   a StructureDefinition without its snapshot (the elements
;; are a describe of Type.path away); the narrative dropped
(define (trim-definition r)
  (define r1 (hash-remove r 'text))
  (if (and (equal? (hash-ref r 'resourceType #f) "StructureDefinition") (hash-has-key? r 'snapshot))
      (hash-set (hash-remove r1 'snapshot) 'snapshot (format "~a elements: ~a" (length (hash-ref (hash-ref r 'snapshot) 'element '())) (call-text "describe" (list (cons 'ref (format "~a.<path>" (hash-ref r 'type "Type")))))))
      r1))

(define (describe-element type path ref)
  (define r (element-info type path))
  (if (string? r) (search-definitions ref) r))

(define (search-definitions q)
  (define rx (regexp (regexp-quote (string-downcase q))))
  (define (hit? s) (and (string? s) (regexp-match? rx (string-downcase s))))
  (define own (for*/list ([k (in-list (registered-kinds))] [r (in-list (registered-resources k))]
                          #:when (or (hit? (hash-ref r 'id #f)) (hit? (hash-ref r 'name #f)) (hit? (hash-ref r 'url #f))))
                (for/hasheq ([key '(resourceType id url name title)] #:when (hash-has-key? r key)) (values key (hash-ref r key)))))
  (hasheq 'query q 'workspace own 'packages (if (sd-index-available?) (find-definitions q #f 30) '())))

(define (describe-operation ref)
  (define o (with-handlers ([exn:fail? (lambda (e) (error 'describe (format "no operation ~a (~a)" ref (exn-message e))))]) (operation ref)))
  (define od (operation-definition o))
  (hasheq 'operation (string-append "$" (operation-code o)) 'url (or (operation-url o) 'null)
          'levels (map symbol->string (operation-levels o)) 'types (operation-resource-types o)
          'title (hash-ref od 'title 'null)
          'inputs (for/list ([p (in-list (hash-ref od 'parameter '()))] #:when (equal? (hash-ref p 'use #f) "in"))
                    (hasheq 'name (hash-ref p 'name) 'type (hash-ref p 'type 'null) 'min (hash-ref p 'min 0) 'max (hash-ref p 'max "1")
                            'documentation (let ([d (hash-ref p 'documentation "")]) (if (> (string-length d) 240) (string-append (substring d 0 240) "…") d))))))

;; ---- results -----------------------------------------------------------------------------------
;; result-csv : hub uri offset limit -> text-answer   a result's rows as CSV, a header line first: the
;; compact form of a table (JSON rows repeat every column name); a last line says what is left
;; #:columns: only these, in this order (a CQL run's table of the defines a person reads: `columns=
;; "Name,Latest Number,Latest Date"`); a name the result lacks is an error listing its columns
;; #:sort: a column to order the rows by (`-Name` descending), numbers as numbers, nulls last
(define (result-csv h uri offset limit #:columns [wanted #f] #:sort [sort-by #f])
  (define st (or (result-of h uri) (error 'describe (format "no result ~a (results: ~a)" uri (result-listing h)))))
  (define r (stored-result st))
  (define all-cols (map (lambda (c) (format "~a" c)) (run-result-columns r)))
  (define cols
    (cond [(not wanted) all-cols]
          [else (for ([c (in-list wanted)] #:unless (member c all-cols))
                  (error 'describe (format "~a has no column ~s~a (columns: ~a)" uri c (did-you-mean c all-cols) (string-join all-cols ", "))))
                wanted]))
  (define rows (sorted-rows (run-result-rows r) sort-by all-cols uri))
  (define page (take (drop rows (min offset (length rows))) (min limit (max 0 (- (length rows) offset)))))
  (define (line cells) (string-join (map csv-cell cells) ","))
  (text-answer
   (string-append
    (string-join (cons (line cols)
                       (for/list ([row (in-list page)])
                         (line (for/list ([c (in-list cols)]) (if (hash? row) (hash-ref row (string->symbol c) 'null) row)))))
                 "\n")
    (let ([next (+ offset (length page))])
      (if (< next (length rows)) (format "\n… ~a more rows: ~a" (- (length rows) next) (call-text "describe" (list (cons 'ref uri) (cons 'as "csv") (cons 'offset next)))) "")))))

(define (describe-result h uri offset limit against)
  (define st (or (result-of h uri) (error 'describe (format "no result ~a (results: ~a)" uri (result-listing h)))))
  (define r (stored-result st))
  (cond
    [against
     (define other (or (result-of h against) (error 'describe (format "no result ~a" against))))
     (diff-results (stored-result other) r against uri)]
    [else
     (define rows (run-result-rows r))
     (define page (take (drop rows (min offset (length rows))) (min limit (max 0 (- (length rows) offset)))))
     (hasheq 'result uri 'kind (run-result-kind r) 'columns (run-result-columns r) 'total (length rows)
             'offset offset 'rows page 'summary (run-result-summary r)
             'source (result-source h st))]))

;; result-source : hub stored -> jsexpr   what a result came from: the file (or query), its hash, the
;; options, and the data it ran over (the store's latest write) — enough to run it again and compare
(define (result-source h st)
  (for/fold ([src (hasheq 'language (stored-language st) 'sha1 (text-sha1 (stored-text st)))])
            ([kv (in-list (list (cons 'file (or (and (stored-path st) (rel h (stored-path st)))
                                                (let ([f (hash-ref (stored-options st) 'textFile #f)]) (and f (shown-path h f)))))
                                (cons 'reads (hash-ref (stored-options st) 'reads #f))
                                (cons 'entry (hash-ref (stored-options st) 'entry #f))
                                (cons 'over (hash-ref (stored-options st) 'over #f))
                                (cons 'data (hub-data-label h))
                                (cons 'dataAsOf (store-as-of h))))]
             #:when (or (string? (cdr kv)) (pair? (cdr kv))))
    (hash-set src (car kv) (cdr kv))))

;; store-as-of : hub -> string | #f   the instant of the store's latest write
(define (store-as-of h)
  (define p (data-store-path h))
  (and p (file-exists? p)
       (with-handlers ([exn:fail? (lambda (_) #f)])
         (define c (sqlite3-connect #:database p #:mode 'read-only))
         (begin0 (let ([v (query-value c "SELECT max(last_updated) FROM fhir_history")]) (and (string? v) v))
                 (disconnect c)))))

;; ---- the trail of a type -----------------------------------------------------------------------
;; trail-tables : hub type [id] -> (listof (cons name thunk))   what trail-sql joins, each a
;; ViewDefinition's rows: `trail_values` (values-view: the type's subject, value and date — over the
;; current resources, or every version of one), `patient_names` (names-view)
(define (trail-tables h type [id #f])
  (define resources
    (if id
        (filter (lambda (r) (equal? (hash-ref r 'id #f) id))
                (if (data-store-path h) (history-resources (data-store-path h) type)
                    ((data-source-all (hub-data h)) type)))
        ((data-source-all (hub-data h)) type)))
  (list (cons "trail_values" (lambda () (view-table (values-view type (element? type)) resources)))
        (cons "patient_names" (lambda () (view-table (names-view) ((data-source-all (hub-data h)) "Patient"))))))

;; trail-sql : hub type [id] -> sql   each stored resource of the type at its current version, with the
;; trail (who, when, why, from which file and line) — or, given an id, every version of that one
;; resource, newest first. The columns are views' (views.rkt): `value` reads a value[x], else the
;; components' values in order (a blood pressure: `120 mm[Hg] / 80 mm[Hg]`); `name` is the subject's
;; (a Patient's own name for a Patient). Only what the type has is a column.
(define (trail-sql h type [id #f])
  (define has? (element? type))
  (define patient? (equal? type "Patient"))
  (define subject? (or (has? 'subject) (has? 'patient)))
  (string-append
   "SELECT v.id, "
   (if subject? "v.subject, " "")
   (cond [patient? "v.name, "] [subject? "n.name, "] [else ""])
   (if (or (has? 'value) (has? 'component)) "v.value, " "")
   (if (for/or ([e '(effective issued authoredOn recordedDate birthDate)]) (has? e)) "v.date, " "")
   "CAST(v.versionId AS INTEGER) AS versionId, t.recorded, t.agent, t.reason, t.source, t.at, t.provenance "
   "FROM trail_values v "
   (if (and subject? (not patient?)) "LEFT JOIN patient_names n ON v.subject = 'Patient/' || n.id " "")
   (format "LEFT JOIN trail t ON t.type = '~a' AND t.id = v.id AND t.versionId = CAST(v.versionId AS INTEGER) " (string-replace type "'" "''"))
   (if id "ORDER BY CAST(v.versionId AS INTEGER) DESC" "ORDER BY v.id")))

;; ---- stages ------------------------------------------------------------------------------------
;; describe-stages : hub -> jsexpr   each stage not committed: its changes, errors and source
(define (describe-stages h)
  (define all
    (for/list ([id (in-list (pending-stage-ids h))] #:when (stage-of h id))
      (define st (stage-of h id))
      (define cs (staged-changes st))
      (hasheq 'stage id
              'changes (length cs)
              'errors (for/sum ([c (in-list cs)]) (length (change-errors c)))
              'resources (for/list ([c (in-list cs)])
                           (format "~a ~a/~a" (change-action c) (hash-ref (change-resource c) 'resourceType "?") (hash-ref (change-resource c) 'id "(new id)")))
              'source (let ([src (staged-source st)]) (or (hash-ref src 'path #f) (hash-ref src 'kind "resources"))))))
  ;; a stage with errors can never be committed: listed apart, with the call that discards them
  ;; (a rerun's agent found its refused stage among the ones waiting to be committed)
  (define-values (refused open) (partition (lambda (s) (positive? (hash-ref s 'errors))) all))
  (define base (hasheq 'stages open))
  (if (null? refused)
      base
      (hash-set* base 'refused refused
                 'next (call-text "stage" (list (cons 'drop (if (= 1 (length refused)) (hash-ref (car refused) 'stage) "refused")))))))
