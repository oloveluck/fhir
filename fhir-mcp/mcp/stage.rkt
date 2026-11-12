#lang racket/base

;;; stage.rkt — the verbs stage and commit: resources (given, written as FSH, a result's, a file's,
;;; the whole implementation guide) validated and diffed against the data as a stage; a stage without
;;; errors written as one change, with its trail (trail.rkt). Definitions the workspace's languages
;;; wrote enter as CRMI artifacts (artifacts.rkt).

(require racket/list racket/string racket/file racket/match racket/set json fhir/lang/workspace
         (only-in fhir/suggest closest-names)
         (only-in fhir/registry registered-source registered-by)
         (only-in fhir/data-source current-data-source data-source-all data-source-read bundle-resources)
         (only-in fhir/spec-package spec-package-path) (only-in fhir/rest-data-source rest-write! rest-url?)
         (only-in fhir/sd/sd-index current-sd-packages resolve-sd-raw sd-index-available?) "artifacts.rkt"
         "trail.rkt" "fsh-source.rkt" "calls.rkt" "json-diff.rkt" "hub.rkt" "data.rkt" "run.rkt"
         "describe.rkt")

;; Contracted in workspace.rkt.
(provide hub-stage! hub-commit!)

;; ---- what is staged ----------------------------------------------------------------------------
(define instance? (lambda (r) (not (member (hash-ref r 'resourceType #f) (append conformance-kinds '("Library" "OperationDefinition" "SearchParameter" "CapabilityStatement" "ImplementationGuide" "ViewDefinition"))))))

;; collection-resources : hub -> (listof resource)   the workspace's implementation guide first (as a
;; CRMI publishable bundle has it), then what it lists: every resource the FSH, CQL, FML, VCL and
;; JSON files define — its artifacts and its examples. (A capability app's statement is R6 and a
;; ViewDefinition is no resource of the workspace's FHIR version: not staged yet.)
(define (collection-resources h)
  (define guide (registered-by (lambda (s) (equal? s (list 'workspace "ig")))))
  (when (null? guide) (error 'stage "sushi-config.yaml does not compile to an implementation guide: check it"))
  (append guide
          (registered-by (lambda (s) (and (pair? s) (eq? (car s) 'workspace) (pair? (cdr s))
                                          (member (cadr s) '("fsh" "cql" "fml" "vcl" "fhir")) #t)))))

;; staged-resources : hub args -> (listof resource)
(define (staged-resources h args)
  ;; definitions:=true stages what an FSH text or file DEFINES too (profiles, value sets …); without
  ;; it, its instances alone — data, as before
  (define definitions? (eq? (hash-ref args 'definitions #f) #t))
  (define (kept rs) (if definitions? rs (filter instance? rs)))
  (define given (hash-ref args 'resources #f))
  (define path (hash-ref args 'path #f))
  (define result (hash-ref args 'result #f))
  (define fsh (hash-ref args 'fsh #f))
  (cond
    ;; FSH Instances written in the call: the compact way to state coded data (a line per coding)
    [(string? fsh)
     ;; FSH compiles as a file of the workspace's project (its profiles in context): a temporary
     ;; file, removed (and the workspace refreshed) whatever happens
     (define tmp (build-path (hub-root h) (format "_stage-~a.fsh" (current-milliseconds))))
     (dynamic-wind
      (lambda () (call-with-output-file tmp (lambda (o) (write-string fsh o)) #:exists 'truncate/replace) (refresh! h))
      (lambda ()
        (define r (execute h "fsh" tmp fsh (hasheq)))
        ;; the text's own parse and compile errors refuse the stage, every one by its line in the text
        ;; (an entity that does not compile would otherwise be dropped from the stage without a word;
        ;; validation issues are the stage's own report, per resource)
        (define own (for/list ([p (in-list (hash-ref (run-result-summary r) 'problems '()))]
                               #:when (and (equal? (hash-ref p 'severity #f) "error")
                                           (not (equal? (hash-ref p 'phase #f) "validate"))
                                           (equal? (hash-ref p 'source #f) (path->string tmp))))
                      (format "~a:~a:~a error: ~a" (or (argument-file args 'fsh h) "fsh") (hash-ref p 'line "?") (hash-ref p 'column "?") (hash-ref p 'message ""))))
        (when (pair? own) (error 'stage (string-join own "\n")))
        (define rs (kept (map (lambda (row) (hash-ref row 'resource)) (run-result-rows r))))
        (when (null? rs) (error 'stage (if definitions? "the FSH defines nothing" "the FSH defines no instance (its definitions are staged with definitions:=true)")))
        rs)
      (lambda () (when (file-exists? tmp) (delete-file tmp)) (refresh! h)))]
    [(list? given) (append-map (lambda (r) (if (hash? r) (bundle-resources r) (error 'stage "each resource is a JSON object"))) given)]
    [(string? result)
     (define st (or (result-of h result) (error 'stage (format "no result ~a" result))))
     (define rs (for/list ([row (in-list (run-result-rows (stored-result st)))] #:when (and (hash? row) (hash? (hash-ref row 'resource #f)))) (hash-ref row 'resource)))
     (when (null? rs) (error 'stage (format "~a holds no resources (an FML or FSH run does)" result)))
     (filter instance? rs)]
    [(string? path)
     (define full (inside h path))
     (match (workspace-language-of full)
       ["fhir" (bundle-resources (call-with-input-file full read-json))]
       ["fsh" (define r (execute h "fsh" full (file->string full) (hasheq)))
              (kept (map (lambda (row) (hash-ref row 'resource)) (run-result-rows r)))]
       ;; the implementation guide: the collection — the guide and everything it lists
       ["ig" (collection-resources h)]
       [_ (error 'stage "stage takes resources, a result of a run, an FSH file's instances, a JSON file, or sushi-config.yaml (the whole guide)")])]
    [else (error 'stage "stage takes `resources`, `fsh`, `result` or `path`")]))


;; stage-source : hub args -> Source   what a stage's resources are made from (trail.rkt)
(define (stage-source h args)
  (define fsh (hash-ref args 'fsh #f))
  (define path (hash-ref args 'path #f))
  (define result (hash-ref args 'result #f))
  (cond
    [(string? fsh) (let ([src (hasheq 'kind "fsh" 'language "fsh" 'text fsh)]
                         [from (argument-source args 'fsh h)])
                     (if from (hash-set src 'path from) src))]
    [(string? result)
     (define st (result-of h result))
     (if st
         (for/fold ([src (hasheq 'kind "result" 'result result 'language (stored-language st))])
                   ([kv (in-list (list (cons 'path (and (stored-path st) (rel h (stored-path st))))
                                       (cons 'text (stored-text st))
                                       (cons 'entry (hash-ref (stored-options st) 'entry #f))))]
                    #:when (string? (cdr kv)))
           (hash-set src (car kv) (cdr kv)))
         (hasheq 'kind "result" 'result result))]
    [(string? path)
     (define full (inside h path))
     (hasheq 'kind "file" 'path path 'language (or (workspace-language-of full) "fhir")
             'text (if (file-exists? full) (file->string full) ""))]
    [else (hasheq 'kind "resources")]))

;; ---- artifacts on their way in (CRMI, artifacts.rkt) -------------------------------------------
;; The CRMI authoring rules (artifacts.rkt) are for what the workspace's own languages WROTE: a
;; definition given as JSON, or taken from a run's result, is somebody's published artifact and is
;; staged as it is, like any resource.
(define authoring-languages '("fsh" "cql" "fml" "vcl" "ig"))

;; authored-language : hub resource args -> language | #f   the workspace language that wrote a staged
;; artifact: the staged FSH text's, the staged file's — for the guide file, each artifact's own, as
;; the hub registered it; #f for a resource that is no artifact or that no language here wrote
(define (authored-language h r args)
  (define path (hash-ref args 'path #f))
  (define (registered)
    (define src (and (string? (hash-ref r 'url #f)) (registered-source (hash-ref r 'resourceType "") (hash-ref r 'url))))
    (and (pair? src) (eq? (car src) 'workspace) (pair? (cdr src)) (cadr src)))
  (define language
    (cond [(string? (hash-ref args 'fsh #f)) "fsh"]
          [(not (string? path)) #f]
          [else (match (workspace-language-of path) ["ig" (registered)] [l l])]))
  (and (artifact? r) (member language authoring-languages) language))

;; authored-artifact : artifact language guide stored|#f -> artifact   as a component of the
;; workspace's collection (CRMI 3.5). FSH and the guide's own file have a place for a title and a
;; description; an artifact of another language gets them from its name and its leading comment.
(define (authored-artifact r language guide stored)
  (define component (in-collection r guide stored))
  (if (member language '("fsh" "ig")) component (with-derived-labels component)))

;; artifact-errors : hub artifact language -> (listof string)   the artifact held to its base type
;; and to CRMI's Shareable profile of it (R4, with the CRMI package at hand), else to the Shareable
;; minimum checked directly; a missing element says where it is written
(define (artifact-errors h r language)
  (define crmi (and (workspace-r4? (hub-ws h)) (spec-package-path "hl7.fhir.uv.crmi-2.0.0.tgz" #:optional? #t)))
  (define profile (shareable-profile (hash-ref r 'resourceType "")))
  (define errors
    (or (and crmi
             (parameterize ([current-sd-packages (cons crmi (hub-packages h))])
               (and (sd-index-available?) (resolve-sd-raw profile)
                    (validation-issues r '("error" "fatal") #:profile profile))))
        (append (validation-errors r) (shareable-minimum-errors r))))
  (map (lambda (e) (with-authoring-hint e language)) (remove-duplicates errors)))

;; ---- stage -------------------------------------------------------------------------------------
(define (hub-stage! h args)
  (match (hash-ref args 'drop #f)
    ["all" (for ([id (in-list (pending-stage-ids h))]) (drop-stage! h id))      ; every stage not committed
           (hasheq 'dropped "all" 'stages (pending-stage-ids h))]
    ["latest" (let ([ids (pending-stage-ids h)])                                ; as commit takes it
                (if (null? ids) (error 'stage "no stage to drop") (drop-stage! h (last ids))))]
    ["refused" (let ([ids (for/list ([id (in-list (pending-stage-ids h))]           ; the ones with errors
                                    #:when (let ([st (stage-of h id)])
                                             (and st (for/or ([c (in-list (staged-changes st))]) (pair? (change-errors c))))))
                           id)])
                 (for ([id (in-list ids)]) (drop-stage! h id))
                 (hasheq 'dropped ids 'stages (pending-stage-ids h)))]
    [(? string? id) (drop-stage! h id)]
    [_ (stage! h args)]))

;; drop-stage! : hub id -> jsexpr   a stage discarded (one not committed)
(define (drop-stage! h id)
  (unless (stage-of h id)
    (error 'stage (format "no stage ~a to drop~a" id (let ([ids (pending-stage-ids h)]) (if (null? ids) "" (format " (stages: ~a)" (string-join ids ", ")))))))
  (hash-remove! (hub-stages h) id)
  ;; kept as dropped-stage-N, as a commit keeps committed-stage-N: its number is never handed out
  ;; again (a script still holding the id cannot commit other data under it)
  (let ([f (build-path (state-dir h "stages") (string-append id ".json"))])
    (when (file-exists? f) (rename-file-or-directory f (build-path (state-dir h "stages") (string-append "dropped-" id ".json")) #t)))
  (hasheq 'dropped id 'stages (pending-stage-ids h)))

(define (stage! h args)
  (refresh! h)
  (with-hub h
    (lambda ()
      (define given (staged-resources h args))
      (define guide (workspace-implementation-guide (hub-ws h)))
      (define read-stored (data-source-read (current-data-source)))
      (define (stored r) (and (hash-ref r 'id #f) (read-stored (hash-ref r 'resourceType) (hash-ref r 'id))))
      ;; the language that wrote an artifact here, #f for any other resource (its url and type, which
      ;; decide it, are the same before and after it is prepared)
      (define (authored r) (authored-language h r args))
      (when (and (not guide) (ormap authored given))
        (error 'stage "definitions are staged as part of the workspace's implementation guide, whose version is theirs: write sushi-config.yaml (id, canonical, version) first"))
      (define rs
        (for/list ([r (in-list given)])
          (define language (authored r))
          (if language (authored-artifact r language guide (stored r)) (with-profiles h r))))
      (define source (stage-source h args))
      ;; FSH written in the stage: each resource's errors name its instance's line in that text
      (define (at-line r errors)
        (define fsh (and (equal? (hash-ref source 'kind #f) "fsh") (hash-ref source 'text #f)))
        (define line (and fsh (hash-ref r 'id #f) (instance-line fsh (hash-ref r 'id))))
        ;; at the rule that wrote the element the error is about, when the instance has one; else at
        ;; the instance's header (a missing element has no rule to point at)
        ;; a list missing an item (`found no component matching '8462-4'`) is at the last rule writing
        ;; that list, where the item goes (it was the header: "add after line 8" took a second look)
        (define (missing-line e)
          (define m (regexp-match #px"[(]found no ([A-Za-z]+) matching " e))
          (and m (last-rule-line fsh line (cadr m))))
        (if line
            (map (lambda (e) (define after (missing-line e))
                   (format "~a:~a: ~a" (or (argument-file args 'fsh) "fsh")   ; the file as the user named it
                           (or after (rule-line fsh line (error-element e)) line) (with-missing-hint e (and after #t))))
                 (remove-duplicates errors))
            (map with-missing-hint (remove-duplicates errors))))
      (when (null? rs) (error 'stage "nothing to stage"))
      (define warned (make-hasheq))                   ; resource -> its validation warnings, at their lines
      ;; change-of : resource -> change   against what is stored under its id
      (define (change-of r)
        (define current (stored r))
        (define paths (if current (json-diff current r) '()))
        (define language (authored r))
        ;; a definition's own codes (an element's type, a filter's property) are not codings
        (hash-set! warned r (append (at-line r (append (validation-issues r '("warning")) (if (artifact? r) '() (systemless-codes r))))
                                    (let ([w (and current (pair? paths) (not language) (reverted-correction h current r))]) (if w (list w) '()))))
        (define errors (if language
                           ;; held to its Shareable profile, and to what its lifecycle allows (CRMI 3.1)
                           (append (artifact-errors h r language) (if (pair? paths) (lifecycle-errors current r) '()))
                           (validation-errors r)))
        (change r (cond [(not current) 'create] [(null? paths) 'unchanged] [else 'update]) paths (at-line r errors)))
      ;; archive-change : change -> change | #f   a released version (active or retired) is kept as an
      ;; instance of its own when another version of the artifact begins under its id: each version
      ;; is a different resource (CRMI)
      (define (archive-change c)
        (define r (change-resource c))
        (define kept (and (authored r) (eq? (change-action c) 'update) (null? (change-errors c))
                          (archive-of (stored r) r)))
        (and kept (not (stored kept)) (change kept 'create '() '())))
      (define changes (let ([own (map change-of rs)]) (append own (filter-map archive-change own))))
      (define errors (for/sum ([c (in-list changes)]) (length (change-errors c))))
      (define dangling (dangling-references h rs))
      ;; nothing would change: no stage (one with nothing to commit was made, and numbered)
      (define nothing? (and (zero? errors) (andmap (lambda (c) (eq? (change-action c) 'unchanged)) changes)))
      ;; keep:=false checks only: the answer without a stage (a refusal shown on purpose needed a
      ;; second call to drop the stage it left)
      (define keep? (not (eq? (hash-ref args 'keep #t) #f)))
      (define id (if (or nothing? (not keep?)) 'null (format "stage-~a" (next-number h "stages" "stage-" (hub-stages h)))))
      (unless (or nothing? (not keep?))
        (hash-set! (hub-stages h) id (staged changes source))
        (save-state! h "stages" id (lambda () (staged->jsexpr (staged changes source)))))
      (define unchanged-count (count (lambda (c) (eq? (change-action c) 'unchanged)) changes))
      (define answer
       (hasheq 'stage id
              ;; what changes, and how many are stored as they are (each listed buried the one change)
              ;; (one stored as it is that no longer passes — a rule changed under it — is listed with its errors)
              'changes (for/list ([c (in-list changes)] #:unless (and (eq? (change-action c) 'unchanged) (not nothing?) (null? (change-errors c))))
                         (define base0 (hasheq 'resource (format "~a/~a" (hash-ref (change-resource c) 'resourceType) (hash-ref (change-resource c) 'id "(new id)"))
                                              ;; checked only: what WOULD happen (a refusal demo's "create" read as staged)
                                              'action (if (or keep? (eq? (change-action c) 'unchanged)) (symbol->string (change-action c)) (format "would ~a" (change-action c)))))
                         ;; errors only where there are some (`"errors": []` on every clean change was noise)
                         (define base1 (if (null? (change-errors c)) base0 (hash-set base0 'errors (change-errors c))))
                         ;; what an update changes; a create's `action` says it all (`changed: "created"` repeated it)
                         (define base (if (memq (change-action c) '(create unchanged)) base1
                                          (hash-set base1 'changed (take (change-paths c) (min 30 (length (change-paths c)))))))
                         ;; a change refused for its errors says those alone: its references are
                         ;; checked again when it is staged clean (a refusal demo read as noise)
                         ;; — when only checking (keep:=false), they are said once for the whole stage
                         ;; (`references`, after the errors): each reading repeated the same patient
                         (define ws (append (hash-ref warned (change-resource c) '())
                                            (if (and (null? (change-errors c)) keep?) (hash-ref dangling (change-resource c) '()) '())))
                         (if (null? ws) base (hash-set base 'warnings ws)))
              'errors errors
              'next (cond [nothing? (format "nothing to commit: the ~a resource(s) are stored as they are" (length changes))]
                          [(not keep?) (if (zero? errors)
                                           "checked only (keep:=false): nothing was staged; stage it again without keep to commit it"
                                           "checked only (keep:=false): nothing was staged — fix the errors and check again")]
                          [(zero? errors) (format "~a writes the ~a change(s) to ~a" (call-text "commit" (list (cons 'stage id))) (count (lambda (c) (not (eq? (change-action c) 'unchanged))) changes)
                                                  (let ([p (data-store-path h)]) (if p (format "the store ~a" (shown-path h (path->string (path->complete-path p)))) (hub-data-label h))))]
                          [else (format "fix the errors, then stage again: a stage with errors is not committed (~a discards this one)" (call-text "stage" (list (cons 'drop id))))])))
      ;; a refused resource says its errors alone (two reruns' agents read `Patient/pat-a is neither in
      ;; the data nor in this stage` beside a rule's refusal as noise); the references of the resources
      ;; that pass are named, refused neighbours or not (hiding them all cost a second check)
      (define refs (if keep? '() (remove-duplicates (append* (for/list ([c (in-list changes)] #:when (null? (change-errors c)))
                                                               (hash-ref dangling (change-resource c) '()))))))
      (define answer1 (if (pair? refs) (hash-set answer 'references refs) answer))
      (if (and (positive? unchanged-count) (not nothing?)) (hash-set answer1 'unchanged unchanged-count) answer1))))

;; ---- what a stage warns of ---------------------------------------------------------------------
;; systemless-codes : resource -> (listof string)   a warning for each coding with a code and no
;; system: a rule keyed on the system (`implies` over `system = 'http://loinc.org'`), a view and a
;; token search all pass it by, so a blood pressure coded `#85354-9` escaped its rule and dropped out of
;; the summary without a word. The system a code's shape suggests is named (LOINC: digits-digit).
(define (systemless-codes r)
  (define (system-for code)
    (cond [(regexp-match? #px"^[0-9]{1,7}-[0-9]$" code) " (a LOINC code: `http://loinc.org`, in FSH `$LOINC#…` or `http://loinc.org#…`)"]
          [(regexp-match? #px"^[0-9]{6,18}$" code) " (a SNOMED CT code? `http://snomed.info/sct`)"]
          [else ""]))
  (let walk ([v r] [path (hash-ref r 'resourceType "")])
    (cond
      [(hash? v)
       (append
        (if (and (string? (hash-ref v 'code #f)) (not (hash-ref v 'system #f))
                 (regexp-match? #rx"[.]coding[[]" path))
            (list (format "~a: the code `~a` has no system: rules, views and searches matched on its system pass it by — add it~a"
                          path (hash-ref v 'code) (system-for (hash-ref v 'code))))
            '())
        (append* (for/list ([(k x) (in-hash v)] #:unless (memq k '(text div))) (walk x (format "~a.~a" path k)))))]
      [(list? v) (append* (for/list ([x (in-list v)] [i (in-naturals)]) (walk x (format "~a[~a]" path i))))]
      [else '()])))

;; reverted-correction : hub current staged -> string | #f   an update that puts back the values the
;; newest commit changed — staging the original file again after a correction would quietly undo it
;; (a rerun's agent saw `140 → 150` with nothing saying it reversed a committed typo fix). Said with
;; the version and the reason it undoes; undecidable (no store, one version) says nothing.
(define (reverted-correction h current staged)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (define type (hash-ref current 'resourceType))
    (define id (hash-ref current 'id))
    (define p (data-store-path h))
    (define-values (store _catalog) (if p (open-store p (hub-packages h)) (values #f #f)))
    (define versions (if store ((dynamic-require 'fhir/store/fhir-engine 'fhir-history) store type id) '()))   ; newest first
    (and (>= (length versions) 2)
         (let* ([prev (cadr versions)]
                [changed-names (λ (lines) (for/list ([l (in-list lines)]) (car (regexp-split #rx": " l))))]
                [last-change (changed-names (json-diff prev current))]
                [still-differs (changed-names (json-diff prev staged))])
           (and (pair? last-change)
                (not (ormap (lambda (n) (member n still-differs)) last-change))
                (let* ([newest (car (hash-ref (describe-history h type id) 'versions))]
                       [v (hash-ref newest 'version "?")])
                  (format "this puts back version ~a's values (~a), undoing version ~a~a: stage the corrected text (~a) to keep it, or commit with a reason to undo it on purpose"
                          (sub1 (or (string->number (format "~a" v)) 2)) (string-join last-change ", ") v
                          (let ([r (hash-ref newest 'reason #f)]) (if (string? r) (format " (\"~a\")" r) ""))
                          (call-text "describe" (list (cons 'ref (format "~a/~a" type id)) (cons 'as "source"))))))))))

;; dangling-references : hub (listof resource) -> (hash resource -> (listof string))   each literal
;; reference (`Patient/pat-a`) to a resource neither in the data nor in this stage: a warning, not an
;; error (the patient may come in a later stage), so a typo in an id is seen before it is committed
(define (dangling-references h rs)
  (define staged-keys (for/set ([r (in-list rs)] #:when (hash-ref r 'id #f))
                        (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id))))
  (define read (data-source-read (current-data-source)))
  (define known (make-hash))
  (define (exists? ref)
    (hash-ref! known ref
               (lambda ()
                 (or (set-member? staged-keys ref)
                     (let ([m (regexp-match #px"^([A-Z][A-Za-z]+)/([A-Za-z0-9.-]+)$" ref)])
                       (or (not m)                                     ; not a literal Type/id reference: not ours to judge
                           (with-handlers ([exn:fail? (lambda (_) #t)]) (and (read (cadr m) (caddr m)) #t))))))))
  ;; a bare name (`Reference(pat-c)` with no instance pat-c compiles to `pat-c`) is no reference FHIR
  ;; can follow: said like a dangling one, with the staged or stored id it most likely meant
  (define (bare? r) (not (regexp-match? #rx"[/:#]" r)))
  (define (refs v path)
    (cond [(hash? v)
           (append (let ([r (hash-ref v 'reference #f)]) (if (and (string? r) (or (bare? r) (not (exists? r)))) (list (cons path r)) '()))
                   (append* (for/list ([(k x) (in-hash v)] #:unless (eq? k 'contained))
                              (refs x (if (string=? path "") (symbol->string k) (format "~a.~a" path k))))))]
          [(list? v) (append* (for/list ([x (in-list v)] [i (in-naturals)]) (refs x (format "~a[~a]" path i))))]
          [else '()]))
  ;; the ids a misspelt one may have meant: the type's stored and staged ids
  (define (ids-of type)
    (append (for/list ([k (in-set staged-keys)] #:when (string-prefix? k (string-append type "/"))) (substring k (add1 (string-length type))))
            (with-handlers ([exn:fail? (lambda (_) '())])
              (let ([all ((data-source-all (current-data-source)) type)])
                (for/list ([x (in-list all)] [_ (in-range 5000)] #:when (string? (hash-ref x 'id #f))) (hash-ref x 'id))))))
  (define (suggestion ref)
    (define m (regexp-match #px"^([A-Z][A-Za-z]+)/(.+)$" ref))
    (define near (if m (closest-names (caddr m) (ids-of (cadr m))) '()))
    (if (null? near) "" (format " (did you mean ~a?)" (string-join (map (lambda (n) (format "`~a/~a`" (cadr m) n)) near) " or "))))
  ;; a bare name's nearest: among this stage's resources and the stored Patients, as Type/id
  (define (bare-suggestion name)
    (define keys (append (set->list staged-keys) (map (lambda (i) (string-append "Patient/" i)) (ids-of "Patient"))))
    ;; an id that IS the name comes first, alone: `Reference(pat-a)` with Patient/pat-a stored meant it
    ;; (the nearest OTHER id, `pat-b`, was suggested — following it filed the reading under another patient)
    (define exact (filter (lambda (k) (string-suffix? k (string-append "/" name))) keys))
    (define near (if (pair? exact) (list name) (closest-names name (map (lambda (k) (regexp-replace #rx"^[^/]*/" k "")) keys))))
    (define full (for*/list ([n (in-list near)] [k (in-list keys)] #:when (string-suffix? k (string-append "/" n))) k))
    ;; every near one (`pat-c` is as near `pat-a` as `pat-b`: naming one of them was a guess)
    (define shown (let ([u (remove-duplicates full)]) (take u (min 3 (length u)))))
    (if (null? shown) "" (format " (did you mean ~a?)" (string-join (map (lambda (k) (format "`~a`" k)) shown) " or "))))
  (for/hash ([r (in-list rs)])
    (values r (for/list ([pr (in-list (refs r ""))])
                (if (bare? (cdr pr))
                    (format "~a: `~a` names no resource: a reference is Type/id, and FSH writes Reference(x) as one only when an instance x is in the same stage or project~a"
                            (car pr) (cdr pr) (bare-suggestion (cdr pr)))
                    (format "~a: ~a is neither in the data nor in this stage~a" (car pr) (cdr pr) (suggestion (cdr pr))))))))

;; ---- commit ------------------------------------------------------------------------------------
(define (hub-commit! h id0 [reason #f] #:agent [agent-asked #f])
  ;; `latest`: the newest stage not committed (from the shell, a stage's id is in its own answer)
  (define id (if (equal? id0 "latest")
                 (let ([ids (pending-stage-ids h)]) (if (null? ids) (error 'commit "no stage to commit (stage something first)") (last ids)))
                 id0))
  (define st (or (stage-of h id)
                 (error 'commit (format "no stage ~a~a" id
                                        (let ([ids (filter (lambda (n) (regexp-match? #rx"^stage-" n)) (saved-names h "stages"))])
                                          (if (null? ids) " (stage something first)" (format " (stages: ~a)" (string-join ids ", "))))))))
  (define changes (staged-changes st))
  (define errors (for/sum ([c (in-list changes)]) (length (change-errors c))))
  ;; the errors themselves, not a count to scroll back for
  (unless (zero? errors)
    (define listed (append* (for/list ([c (in-list changes)]) (change-errors c))))
    (error 'commit (format "~a has ~a validation error(s); fix them and stage again (~a discards it):\n~a"
                           id errors (call-text "stage" (list (cons 'drop id)))
                           (string-join (map (lambda (e) (format "  ~a" e)) (take listed (min 10 (length listed)))) "\n"))))
  (define todo (filter (lambda (c) (not (eq? (change-action c) 'unchanged))) changes))
  (define c (workspace-config (hub-ws h)))
  (define d (ws-config-data c))
  (define written
    (cond
      [(not d) (error 'commit "there is no data to write to: set `data` in workspace.yaml")]
      [(rest-url? d)
       (unless (ws-config-allow-remote-writes? c)
         (error 'commit (format "~a is read-only for this workspace: set allowRemoteWrites: true in workspace.yaml to write to it" d)))
       (define auth (getenv "FHIR_AUTHORIZATION"))
       (for/list ([ch (in-list todo)])
         (define-values (status body) (rest-write! d (change-resource ch) #:headers (if auth (list (string-append "Authorization: " auth)) '())))
         (hasheq 'resource (format "~a/~a" (hash-ref (change-resource ch) 'resourceType) (hash-ref (change-resource ch) 'id "(new)"))
                 'status status 'ok (<= 200 status 299)))]
      [(store-file? d) (commit-to-store h todo)]
      [else
       (define dir (simplify-path (path->complete-path d (hub-root h))))
       (unless (directory-exists? dir) (error 'commit (format "data ~a is a file, not a directory: commit writes to a SQLite store, a directory or a FHIR server" d)))
       (define where (resource-files dir))
       ;; every target decided before anything is written
       (define plan
         (for/list ([ch (in-list todo)])
           (define r (change-resource ch))
           (define r* (if (hash-ref r 'id #f) r (hash-set r 'id (new-id))))
           (define key (cons (hash-ref r* 'resourceType) (hash-ref r* 'id)))
           (define f (hash-ref where key #f))
           (when (and f (eq? (cdr f) 'bundle))
             (error 'commit (format "~a/~a sits in the Bundle ~a: change it there" (car key) (cdr key) (car f))))
           (cons r* (if f (car f) (build-path dir (format "~a-~a.json" (car key) (cdr key)))))))
       (for/list ([p (in-list plan)])
         (call-with-output-file (cdr p) (lambda (o) (write-json (car p) o)) #:exists 'truncate/replace)
         (hasheq 'resource (format "~a/~a" (hash-ref (car p) 'resourceType) (hash-ref (car p) 'id)) 'file (path-string (cdr p)) 'ok #t))]))
  (hash-remove! (hub-stages h) id)
  ;; kept as committed-stage-N: its number is never handed out again
  (let ([f (build-path (state-dir h "stages") (string-append id ".json"))])
    (when (file-exists? f) (rename-file-or-directory f (build-path (state-dir h "stages") (string-append "committed-" id ".json")) #t)))
  ;; the trail: a Provenance and an AuditEvent in the data, naming the versions written
  ;; each target with the line of the source that wrote it (`patients.fsh:30`: an FSH Instance's
  ;; first line), so SQL's `trail` answers it per row
  (define src (staged-source st))
  ;; a correction (an update) is said at the first rule that changed (`* component[0].valueQuantity
  ;; = 140 …`), a new resource at its Instance's first line
  (define (source-at ch)
    (define r (change-resource ch))
    (define text (and (equal? (hash-ref src 'kind #f) "fsh") (hash-ref src 'text #f)))
    (define line (and text (hash-ref r 'id #f) (instance-line text (hash-ref r 'id))))
    (define changed-path (and line (eq? (change-action ch) 'update)
                              (for/first ([p (in-list (change-paths ch))]) (car (regexp-split #rx":" p)))))
    ;; a reading written through a RuleSet has its values on its `* insert` line, a create's and a
    ;; correction's alike (a correction pointed at the Instance header)
    ;; a create's value is at the rule writing it (`* valueQuantity = 9.6 '%'`, else the first
    ;; component), not at the Instance header ("where did this value come from" is that line)
    (define at (or (and changed-path (rule-line text line changed-path))
                   (and line (insert-line text line))
                   (and line (eq? (change-action ch) 'create)
                        (or (rule-line text line "value") (rule-line text line "component")))
                   line))
    (and at (format "~a:~a" (hash-ref src 'path "fsh") at)))
  (define targets (for/list ([w (in-list written)] [ch (in-list todo)] #:when (hash-ref w 'ok #f))
                    (list (hash-ref w 'version (hash-ref w 'resource)) (if (eq? (change-action ch) 'create) 'create 'update)
                          (source-at ch))))
  ;; who the trail names: the `agent` asked for, else the client (FHIR_MCP_AGENT from the shell)
  (define agent (or agent-asked (unbox current-agent)))
  (define trail (if (null? targets) '() (write-trail! h (list (provenance (ws-config-fhir-version c) targets src reason agent (now-instant))
                                                               (commit-audit (ws-config-fhir-version c) targets agent (now-instant))))))
  (configure! h (hub-root h))                              ; the data read again
  ;; each write with the version it made (`Observation/bp-a1/_history/2`), so a correction's v2 is seen
  ;; and the reason it recorded beside the agent, as the trail will say them
  (define answer0 (hasheq 'stage id 'written written
                          'provenance (if (pair? trail) (car trail) 'null) 'agent agent))
  (define answer (if (and (string? reason) (not (string=? reason ""))) (hash-set answer0 'reason reason) answer0))
  (if (member agent '("raco fhir-mcp call" "raco fhir-mcp batch"))
      (hash-set answer 'note (format "the trail names the agent ~s; name who is writing with commit(agent: …) or FHIR_MCP_AGENT" agent))
      answer))

;; commit-to-store : hub changes -> written   one FHIR transaction: a resource with an id is PUT (its
;; id kept, a new version if it exists), one without is POSTed (the store gives it an id); all or none
(define (commit-to-store h todo)
  (define-values (store catalog) (open-store (data-store-path h) (hub-packages h)))
  (define bundle
    (hasheq 'resourceType "Bundle" 'type "transaction"
            'entry (for/list ([ch (in-list todo)])
                     (define r (change-resource ch))
                     (hasheq 'resource r
                             'request (if (hash-ref r 'id #f)
                                          (hasheq 'method "PUT" 'url (format "~a/~a" (hash-ref r 'resourceType) (hash-ref r 'id)))
                                          (hasheq 'method "POST" 'url (hash-ref r 'resourceType)))))))
  (define resp ((dynamic-require 'fhir/store/bundle 'process-bundle!) store bundle #:search-params catalog
                #:tower (if (workspace-r4? (hub-ws h)) 'fhir/r4/schemas 'fhir/r5/schemas)))
  (for/list ([e (in-list (hash-ref resp 'entry '()))] [ch (in-list todo)])
    (define r (hash-ref e 'response (hasheq)))
    (define status (hash-ref r 'status ""))
    (define loc (hash-ref r 'location #f))
    (define ref (if (string? loc) (regexp-replace #rx"/_history/.*$" loc "")
                    (format "~a/~a" (hash-ref (change-resource ch) 'resourceType) (hash-ref (change-resource ch) 'id "(new)"))))
    (hasheq 'resource ref 'version (if (string? loc) loc ref)
            'status status 'ok (regexp-match? #rx"^2" status))))

;; resource-files : dir -> (hash (cons type id) -> (cons file 'resource|'bundle))
(define (resource-files dir)
  (for*/fold ([acc (hash)]) ([f (in-directory dir)] #:when (regexp-match? #rx"[.]json$" (path->string f))
                             [js (in-value (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))]
                             #:when (hash? js))
    (define bundle? (equal? (hash-ref js 'resourceType #f) "Bundle"))
    (for/fold ([acc acc]) ([r (in-list (bundle-resources js))] #:when (and (hash-ref r 'resourceType #f) (hash-ref r 'id #f)))
      (hash-set acc (cons (hash-ref r 'resourceType) (hash-ref r 'id)) (cons f (if bundle? 'bundle 'resource))))))
