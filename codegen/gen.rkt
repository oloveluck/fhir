#lang racket/base

;;; gen.rkt — generate a FHIR type tower for a target (R6, R4, …) from its vendored spec package.
;;;
;;; For each concrete StructureDefinition (filtered by the target whitelist): nest → expand to the
;;; IR, then emit a form-macro module (the compile-time authoring path) AND a schema-data module
;;; (the runtime serialize/parse + spec-link path). Then emit the tower index (types.rkt), the
;;; module language (main.rkt), the reader (#lang fhir/<out-root>), and the version pin. Generation
;;; is deterministic (sorted names, ~s on data), so `raco fhir check` can byte-diff a regen.

(require racket/file
         racket/path
         racket/list
         racket/string
         racket/contract
         racket/runtime-path
         (only-in json jsexpr->string)
         "load-spec.rkt"
         "structure-definition.rkt"
         "type-registry.rkt"
         "nest.rkt"
         "expand.rkt"
         "emit-form.rkt"
         "emit-schema.rkt"
         "target.rkt")

(provide
 (contract-out
  ;; generate-tower : gen-target -> (list version datatype-count resource-count)
  [generate-tower (-> gen-target? (list/c (or/c string? #f)
                                          exact-nonnegative-integer? exact-nonnegative-integer?))]
  ;; tower-files : gen-target -> (values files version dt rs)  — pure: computes every emitted file
  ;;   as (relpath . content) WITHOUT writing (the determinism guard diffs these vs disk).
  [tower-files (-> gen-target? (values (listof (cons/c (listof string?) string?))
                                       (or/c string? #f)
                                       exact-nonnegative-integer? exact-nonnegative-integer?))]
  ;; committed-path : relpath -> absolute path under the fhir collection root
  [committed-path (-> (listof string?) path?)]))

(define-runtime-path here ".")
(define fhir-root (build-path here 'up))   ; the `fhir` collection root

(define (committed-path relpath) (apply build-path fhir-root relpath))

(define (write-file! relpath content)
  (define p (committed-path relpath))
  (make-directory* (path-only p))
  (call-with-output-file p #:exists 'replace (lambda (o) (display content o))))

;; should this StructureDefinition become a component? (concrete, non-abstract, schema-bearing,
;; and — if the target has a whitelist — named in it). kind=logical is an IG's logical model
;; (e.g. an OMOP CDM table) — same snapshot shape as a complex type, generated the same way, but
;; ONLY when a whitelist names it explicitly: the core packages carry pattern logical models
;; (FiveWs, Event, …) that a full sweep must not pick up.
(define (keep? sd whitelist)
  (and (not (structure-definition-abstract? sd))
       (not (abstract-type? (structure-definition-name sd)))
       (or (member (structure-definition-kind sd) '("complex-type" "resource"))
           (and (equal? (structure-definition-kind sd) "logical") whitelist))
       (not (equal? (structure-definition-derivation sd) "constraint"))
       (pair? (structure-definition-elements sd))
       (or (not whitelist)
           (memq (string->symbol (structure-definition-name sd)) whitelist))))

;; ---- target rename (the IG name seam) -----------------------------
;; rename-path : rewrite the ROOT segment of a dotted path ("Person.person_id" -> "person.person_id")
(define (rename-path p old new)
  (cond [(not (string? p)) p]
        [(string=? p old) new]
        [(string-prefix? p (string-append old ".")) (string-append new (substring p (string-length old)))]
        [else p]))

;; rename-sd : apply the target's rename to the SD name + every element path/base-path root segment,
;; so nesting, own-field detection, and emission all see the renamed type consistently
(define (rename-sd sd rn)
  (define old (structure-definition-name sd))
  (define new (rn old))
  (struct-copy structure-definition sd
    [name new]
    [elements (for/list ([e (in-list (structure-definition-elements sd))])
                (struct-copy element-definition e
                  [path (rename-path (element-definition-path e) old new)]
                  [base-path (rename-path (element-definition-base-path e) old new)]))]))

;; tower-files — compute every emitted file as (relpath . content), plus counts (no writing).
(define (tower-files t)
  (define pkg (load-package (gen-target-package-file t)))
  (define raw-sds (package-contents-sds pkg))
  (define package-ods (package-contents-operations pkg))
  (define version (package-contents-version pkg))
  (define sds (let ([rn (gen-target-rename t)])
                (if rn (map (lambda (sd) (rename-sd sd rn)) raw-sds) raw-sds)))
  (define out-root (gen-target-out-root t))
  (define doc-base (gen-target-doc-base t))
  (define forms? (gen-target-forms? t))
  (define kept (filter (lambda (sd) (keep? sd (gen-target-whitelist t))) sds))
  ;; the banner's provenance stamp: the true package, not a hardcoded "core"
  (define provenance (format "~a#~a" (gen-target-package-name t) (or version "?")))
  ;; per-type schema (always) + form module (only when forms?); collect (name . kind) for the index.
  (define per-type
    (for/list ([sd (in-list kept)])
      (define orig (nest sd))
      (define node (expand orig))
      (define name (sanitize (structure-definition-name sd)))
      (define kind (structure-definition-kind sd))
      (define subdir (if (equal? kind "resource") "resources" "datatypes"))
      (list (cons name subdir)
            (cons (list out-root "schema" (string-append name ".rkt"))
                  (emit-schema-module node orig kind provenance doc-base))
            (and forms?
                 (cons (list out-root subdir (string-append name ".rkt"))
                       (emit-form-module node orig provenance))))))
  (define entries (sort (map car per-type) string<? #:key car))
  (define per-type-files
    (append-map (lambda (pt) (filter values (cdr pt))) per-type))
  ;; a schema-only tower (forms? #f) gets a `schemas.rkt` index (require-for-effect); a full tower
  ;; gets the authoring index/main/reader. Both get the version pin. A DELEGATING (IG) tower requires
  ;; its base tower's index first, so every core type the IG's fields reference is registered/in
  ;; scope before the IG's own modules load — the IG emits only its whitelisted types.
  (define delegate (let ([b (gen-target-delegate-base t)])
                     (and b (string-append "fhir/" (gen-target-out-root b)
                                           (if (gen-target-forms? b) "/types" "/schemas")))))
  ;; the package's TERMINOLOGY becomes part of the language: every REQUIRED-bound ValueSet on a
  ;; kept type that expands OFFLINE from the package's own CodeSystems registers its codes
  ;; (model/binding.rkt) — the form macros then reject out-of-set literal codes at COMPILE time.
  (define binding-expansions (required-binding-expansions kept pkg t))
  (define tly? (pair? binding-expansions))
  (define index-files
    (if forms?
        (list (cons (list out-root "types.rkt")         (types-source entries delegate tly?))
              (cons (list out-root "main.rkt")          (main-source out-root))
              (cons (list out-root "lang" "reader.rkt") (reader-source out-root)))
        (list (cons (list out-root "schemas.rkt")       (schemas-source entries delegate tly?)))))
  ;; a package that ships OperationDefinitions gets generated operation SCAFFOLDING: the ODs as
  ;; data + one constructor per operation binding everything but the handler (the only hand-written
  ;; part). The core packages ship the standard operations ($expand, $validate-code, …), the SOF IG
  ;; ships $sql-run/$sql-export — every tower's operations generate the same way.
  (define operation-files
    (if (pair? package-ods)
        (list (cons (list out-root "operations.rkt") (operations-source package-ods)))
        '()))
  (define terminology-files
    (if tly?
        (list (cons (list out-root "terminology.rkt") (terminology-source binding-expansions)))
        '()))
  (define files
    (append per-type-files index-files operation-files terminology-files
            (list (cons (list out-root "fhir-version.rkt") (version-source version)))))
  (define dt (length (filter (lambda (e) (equal? (cdr e) "datatypes")) entries)))
  (define rs (length (filter (lambda (e) (equal? (cdr e) "resources")) entries)))
  (values files version dt rs))

(define (generate-tower t)
  (define-values (files version dt rs) (tower-files t))
  (for ([f (in-list files)]) (write-file! (car f) (cdr f)))
  (printf "generated fhir/~a from ~a#~a: ~a datatypes, ~a resources\n"
          (gen-target-out-root t) (gen-target-package-name t) (or version "?") dt rs)
  (list version dt rs))

;; ---- generated boilerplate ----------------------------------------
(define banner ";;; GENERATED — DO NOT EDIT (verified by raco fhir check).")

;; types.rkt : require every schema module (registration side effects) + every form module; provide
;; every form macro. Schema-first so registration is done before any use. A delegating tower
;; requires (and re-provides) its base tower's index first.
(define (types-source entries [delegate #f] [terminology? #f])
  (define (rel e) (format "~s" (string-append (cdr e) "/" (car e) ".rkt")))
  (define (sch e) (format "~s" (string-append "schema/" (car e) ".rkt")))
  (string-append
   "#lang racket/base\n" banner "\n"
   ;; terminology registers at BOTH phases: for-syntax so the form macros (phase 1) can enforce
   ;; required bindings at compile time, and normally for runtime readers of the same catalogue
   (if terminology?
       "(require \"terminology.rkt\" (for-syntax \"terminology.rkt\"))\n"
       "")
   "(require " (if delegate (string-append delegate "\n         ") "")
   (string-join (map sch entries) "\n         ")
   "\n         " (string-join (map rel entries) "\n         ") ")\n"
   "(provide " (if delegate (format "(all-from-out ~a)\n         " delegate) "")
   (string-join (for/list ([e (in-list entries)]) (format "(all-from-out ~a)" (rel e)))
                            "\n         ") ")\n"))

;; schemas.rkt : a schema-only tower's index — require every schema module for its registration
;; side effects (no form macros, no #lang). Used by FHIRPath to make every type parseable.
(define (schemas-source entries [delegate #f] [terminology? #f])
  (define (sch e) (format "~s" (string-append "schema/" (car e) ".rkt")))
  (string-append
   "#lang racket/base\n" banner "\n"
   (if terminology? "(require \"terminology.rkt\")\n" "")
   "(require " (if delegate (string-append delegate "\n         ") "")
   (string-join (map sch entries) "\n         ") ")\n"))

;; main.rkt : the module language — the foundation base + every type macro in scope.
(define (main-source out-root)
  (string-append
   "#lang racket/base\n" banner "\n"
   "(require fhir/foundation/base \"types.rkt\")\n"
   "(provide (all-from-out fhir/foundation/base) (all-from-out \"types.rkt\"))\n"))

;; the reader for #lang fhir/<out-root>
(define (reader-source out-root)
  (define mod (string-append "fhir/" out-root "/main"))
  (string-append
   "#lang s-exp syntax/module-reader\n\n"
   ";;; GENERATED — reader: wrap each top form as (fhir-resource-form <form>); the module\n"
   ";;; language " mod " (via fhir/kernel/kit) builds it to a typed node.\n\n"
   mod "\n"
   "#:read        lang-read\n"
   "#:read-syntax lang-read-syntax\n"
   "#:whole-body-readers? #t\n\n"
   "(define (lang-read-syntax src in)\n"
   "  (let loop ([acc '()])\n"
   "    (define form (read in))\n"
   "    (if (eof-object? form)\n"
   "        (reverse acc)\n"
   "        (loop (cons (datum->syntax #f (list 'fhir-resource-form form)) acc)))))\n\n"
   "(define (lang-read in)\n"
   "  (map syntax->datum (lang-read-syntax #f in)))\n"))

(define (version-source version)
  (string-append
   "#lang racket/base\n" banner "\n"
   "(provide fhir-version)\n"
   "(define fhir-version " (format "~s" (or version "unknown")) ")\n"))

;; ---- operation scaffolding ----------------------------------------
;; operations.rkt : the package's OperationDefinitions as data + one scaffold constructor per
;; operation. The scaffold binds level/code/target from the OD; the caller supplies ONLY the
;; handler. ODs embed as canonical JSON strings (sorted keys) so the emission is deterministic —
;; a hash literal's print order is not.

;; jsexpr->canonical-string : jsexpr -> PRETTY JSON text with object keys sorted (recursive) —
;; sorted keys keep the emission deterministic; the indentation keeps the generated file readable
(define (jsexpr->canonical-string js [depth 0])
  (define pad (make-string (* 2 (add1 depth)) #\space))
  (define close-pad (make-string (* 2 depth) #\space))
  (cond
    [(and (hash? js) (zero? (hash-count js))) "{}"]
    [(hash? js)
     (string-append
      "{\n"
      (string-join
       (for/list ([k (in-list (sort (hash-keys js) symbol<?))])
         (string-append pad (format "~s" (symbol->string k)) ": "
                        (jsexpr->canonical-string (hash-ref js k) (add1 depth))))
       ",\n")
      "\n" close-pad "}")]
    [(null? js) "[]"]
    [(list? js)
     (string-append
      "[\n"
      (string-join (for/list ([e (in-list js)])
                     (string-append pad (jsexpr->canonical-string e (add1 depth))))
                   ",\n")
      "\n" close-pad "]")]
    [(string? js) (jsexpr->string js)]
    [(boolean? js) (if js "true" "false")]
    [(eq? js 'null) "null"]
    [else (jsexpr->string js)]))

;; a Racket string literal with REAL newlines (readable in the generated file); only \ and " escape
(define (multiline-string-literal s)
  (string-append "\"" (string-replace (string-replace s "\\" "\\\\") "\"" "\\\"") "\""))

;; ---- terminology (offline binding expansions) ---------------------
;; the REQUIRED-bound ValueSet urls referenced by the kept types' code elements, each expanded
;; offline where possible -> sorted (listof (cons url (listof code))). Resolution consults the
;; target's package AND every delegate-base package up the chain — an IG's elements bind mostly
;; to CORE ValueSets (ViewDefinition.status -> publication-status), which live in the base.
(define (required-binding-expansions kept pkg t)
  (define pkgs (cons pkg (for/list ([b (in-list (delegate-chain t))])
                           (load-package (gen-target-package-file b)))))
  (define cs-by-url
    (for*/hash ([p (in-list (reverse pkgs))]          ; the target's own package WINS on collision
                [cs (in-list (package-contents-codesystems p))]
                #:when (string? (hash-ref cs 'url #f)))
      (values (hash-ref cs 'url) cs)))
  (define vs-by-url
    (for*/hash ([p (in-list (reverse pkgs))]
                [vs (in-list (package-contents-valuesets p))]
                #:when (string? (hash-ref vs 'url #f)))
      (values (hash-ref vs 'url) vs)))
  (define urls
    (remove-duplicates
     (for*/list ([sd (in-list kept)]
                 [e (in-list (structure-definition-elements sd))]
                 [b (in-value (element-definition-binding e))]
                 #:when (and b (equal? (car b) "required")
                             (equal? (element-definition-types e) '("code"))))
       (cdr b))))
  (sort (for*/list ([u (in-list urls)]
                    [codes (in-value (vs-offline-codes u vs-by-url cs-by-url))]
                    #:when codes)
          (cons u codes))
        string<? #:key car))

;; the target's delegate ancestry, nearest first
(define (delegate-chain t)
  (let loop ([b (gen-target-delegate-base t)])
    (if b (cons b (loop (gen-target-delegate-base b))) '())))

;; vs-offline-codes : url -> (listof code)|#f. Supported: compose.include with an enumerated
;; `concept` list, or a whole `system` resolvable to a package CodeSystem (concept tree flattened).
;; Anything else — filters, imports, excludes, unresolvable systems — makes the WHOLE ValueSet
;; not-offline-expandable (#f): consumers fail open rather than enforce a partial set.
(define (vs-offline-codes url vs-by-url cs-by-url)
  (define vs (hash-ref vs-by-url url #f))
  (define compose (and vs (hash-ref vs 'compose #f)))
  (define includes (and (hash? compose) (hash-ref compose 'include #f)))
  (cond
    [(or (not includes) (not (list? includes)) (null? includes)) #f]
    [(pair? (and (hash? compose) (hash-ref compose 'exclude '()))) #f]
    [else
     (define per-include
       (for/list ([inc (in-list includes)])
         (cond
           [(not (hash? inc)) #f]
           [(or (hash-ref inc 'filter #f) (hash-ref inc 'valueSet #f)) #f]
           [(list? (hash-ref inc 'concept #f))
            (filter string? (for/list ([c (in-list (hash-ref inc 'concept))])
                              (and (hash? c) (hash-ref c 'code #f))))]
           [(hash-ref inc 'system #f)
            => (lambda (sys) (let ([cs (hash-ref cs-by-url sys #f)])
                               (and cs (cs-all-codes cs))))]
           [else #f])))
     (and (andmap values per-include)
          (sort (remove-duplicates (append* per-include)) string<?))]))

;; every code in a CodeSystem's (possibly hierarchical) concept tree
(define (cs-all-codes cs)
  (let walk ([concepts (hash-ref cs 'concept '())])
    (append*
     (for/list ([c (in-list concepts)] #:when (hash? c))
       (cons (hash-ref c 'code "") (walk (hash-ref c 'concept '())))))))

;; terminology.rkt : one register-binding-expansion! per offline-expandable required binding
(define (terminology-source expansions)
  (string-append
   "#lang racket/base\n" banner "\n"
   ";; REQUIRED-bound ValueSets expanded OFFLINE from this package's own CodeSystems. Required\n"
   ";; both normally and for-syntax by the tower index, so form macros enforce these at compile\n"
   ";; time and runtime consumers can read the same catalogue. Absent urls fail open.\n"
   "(require fhir/model/binding)\n"
   (apply string-append
          (for/list ([e (in-list expansions)])
            (format "(register-binding-expansion! ~s\n  '~s)\n" (car e) (cdr e))))))

;; od-basename : identifiers are named by CODE when it is unique in the package, by ID when several
;; ODs share a code (e.g. the core package's PlanDefinition/$apply and ActivityDefinition/$apply)
(define (od-basename od ods)
  (define code (hash-ref od 'code))
  (if (= 1 (for/sum ([o (in-list ods)] #:when (equal? (hash-ref o 'code) code)) 1))
      code
      (hash-ref od 'id)))

;; one OD -> (values code definition-id constructor-id entry-constructions)
(define (od-parts od ods)
  (define code (hash-ref od 'code))
  (define base (od-basename od ods))
  (define targets (let ([r (hash-ref od 'resource '())]) (if (list? r) r '())))
  (define entries
    (append
     (if (eq? (hash-ref od 'system #f) #t) (list "(operation-entry 'system code #f handler)") '())
     (if (eq? (hash-ref od 'type #f) #t)
         (for/list ([r (in-list targets)]) (format "(operation-entry 'type code ~s handler)" r))
         '())
     (if (eq? (hash-ref od 'instance #f) #t)
         (for/list ([r (in-list targets)]) (format "(operation-entry 'instance code ~s handler)" r))
         '())))
  (values code (format "~a-definition" base) (format "~a-operation" base) entries))

(define (operations-source ods)
  (string-append
   "#lang racket/base\n" banner "\n"
   ";; The package's OperationDefinitions as data + scaffold constructors: each\n"
   ";; <code>-operation takes ONLY the handler `(in req) -> node` and yields the\n"
   ";; operation-entry list for build-app's #:operations (levels/targets from the OD).\n"
   "(require json (only-in fhir/capability/runtime operation-entry))\n"
   "(provide operation-definitions\n"
   (string-join (for/list ([od (in-list ods)])
                  (define-values (_c def-id ctor-id _e) (od-parts od ods))
                  (format "         ~a ~a" def-id ctor-id))
                "\n")
   ")\n"
   (apply string-append
          (for/list ([od (in-list ods)])
            (define-values (code def-id ctor-id entries) (od-parts od ods))
            (string-append
             "(define " def-id "\n"
             "  (string->jsexpr\n   " (multiline-string-literal (jsexpr->canonical-string od)) "))\n"
             "(define (" ctor-id " handler)\n"
             "  (define code " (format "~s" code) ")\n"
             "  (list " (string-join entries "\n        ") "))\n")))
   "(define operation-definitions\n  (list "
   (string-join (for/list ([od (in-list ods)])
                  (define-values (_c def-id _i _e) (od-parts od ods))
                  def-id)
                " ")
   "))\n"))
