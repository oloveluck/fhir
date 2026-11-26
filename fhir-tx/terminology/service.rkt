#lang racket/base

;;; service.rkt — a real terminology service backed by a vendored FHIR core package.
;;;
;;; Lazily loads a core package `.tgz`, indexes every CodeSystem / ValueSet / ConceptMap by its
;;; canonical `url`, and implements $expand / $validate-code (against a ValueSet) / $translate. The
;;; source resources are navigated as plain jsexpr (hash-ref); only the *results* are built into typed
;;; `fhir` nodes (via from-json) so FHIRPath can navigate them.
;;;
;;; The core is version-NEUTRAL: `make-terminology` takes any core `.tgz`, and the result nodes are
;;; built against whatever type tower the CALLER has registered (require fhir/r5/schemas for R5,
;;; fhir/r4/schemas for R4). `make-r5-terminology` / `make-r4-terminology` are conveniences over the
;;; vendored packages. Algorithms are clean-room ports of fhir4s's TerminologyOps.scala.
;;;
;;; `make-terminology` returns a `tx-service` (fhirpath/terminology) whose three closures the
;;; FHIRPath engine dispatches on as the `%terminologies` handle.
;;;
;;; The sources — the package and resource indexes, versioned resolution, a CodeSystem's concept
;;; tree and the Member of an expansion — are index.rkt's; this module is the operations over them.

(require (only-in fhir/spec-package spec-package-path) (only-in fhir/serialize/jsexpr-util jref jlist))
(require json racket/contract
         (only-in net/uri-codec uri-decode)
         (only-in vcl/compile vcl->compose)
         racket/list
         racket/string
         (only-in fhirpath/terminology tx-service tx-service?)
         (only-in fhirpath/ucum ucum-valid? ucum-commensurable?)
         (only-in fhir/serialize/jsexpr-util drop-false)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/result/result ok? ok-value)
         "index.rkt")
(provide
 resolver/c
 (contract-out
  [make-terminology (-> path-string? tx-service?)]
  [make-r5-terminology (-> tx-service?)]
  [make-r4-terminology (-> tx-service?)]
  ;; a service over SEVERAL packages, searched in order (an IG first, then its core)
  [make-terminology/packages (-> (listof path-string?) tx-service?)]
  ;; a service over an EXPLICIT list of resources (the tx-ecosystem conformance suite
  ;; ships its own CodeSystems/ValueSets as per-suite setup files)
  [make-terminology/resources (-> (listof hash?) tx-service?)]
  [make-terminology/resolver (-> resolver/c tx-service?)]
  ;; operations beyond the tx-service handle's three closures, used by the conformance
  ;; harness (and available to any caller): CodeSystem $lookup and CodeSystem-level
  ;; $validate-code — each takes the resolver and gives the operation as a procedure
  [make-lookup (-> resolver/c procedure?)]
  [make-cs-validate (-> resolver/c procedure?)]
  ;; server-level version parameters (system-version / force- / check-): canonicals with
  ;; |version, given singly or as lists
  [no-version-policy version-policy?]
  [policy-of (->* (any/c any/c any/c) (any/c) version-policy?)]
  ;; a request refused (an unknown value set, a missing supplement, a forbidden version …): raised
  ;; where current-terminology-strict? is set, answered around elsewhere
  [current-terminology-strict? (parameter/c boolean?)]
  ;; a ValueSet whose compose names a code system the resolver cannot see is UNDECIDABLE
  ;; offline — the conformance harness skips such cases instead of guessing
  [make-undecidable? (-> resolver/c procedure?)]
  ;; the subsumption relation two codes of a system stand in (for $closure)
  [closure-relation (->* (resolver/c string? string? string?) ((or/c string? #f)) (or/c string? #f))]
  ;; the CodeSystems a package list holds, and what a server publishes about all this
  [terminology-capabilities (->* ((listof hash?)) (#:url (or/c string? #f)) hash?)]
  ;; the ValueSet an implicit VCL url (http://fhir.org/VCL?v1=<expression>) stands for, else #f
  [implicit-vcl-valueset (-> string? (or/c hash? #f))]
  ;; the code systems a value set selects from by rule whose content is not here: its expansion
  ;; is short of them (marked valueset-unclosed) and membership of their codes is undecided
  [rule-systems-without-content (->* (resolver/c string?) ((or/c string? #f) (listof string?)) (listof string?))])
 (struct-out version-policy)
 (struct-out exn:fail:terminology)
 ;; the index layer (index.rkt): resolvers over packages or resources, and what they hold
 packages->resolver resources->resolver packages->code-systems
 ;; the same operations as FHIR JSON (no type tower needed), for terminology/operations:
 ;; resolver url ... -> ValueSet | Parameters jsexpr
 (rename-out [tx-expand expand/json] [tx-validate validate-code/json]
             [tx-lookup lookup/json] [tx-translate translate/json]
             [tx-cs-validate cs-validate-code/json] [tx-subsumes subsumes/json]
             [tx-find-matches find-matches/json]))
(define r5-core-tgz (spec-package-path "hl7.fhir.r5.core.tgz"))
(define r4-core-tgz (spec-package-path "hl7.fhir.r4.core.tgz"))

;; ---- refusals -------------------------------------------------------------------------------
;; A Refusal is a request the service cannot answer as it was asked: a value set nothing defines,
;; a supplement that is not here, a code system version the definition pins and nothing holds, a
;; version the server's check forbids, a filter without a value, a value set that includes itself,
;; a display language that is none. It is (exn:fail:terminology message marks kind code):
;;   kind : 'valueset | 'import | 'system-version | 'version-check | 'supplement | 'filter
;;          | 'circular | 'language | 'too-costly      which rule refused
;;   code : the OperationOutcome issue code a server answers it with ("not-found", "exception", …)
;; It is RAISED only where `current-terminology-strict?` is set — the operations, the command line
;; and the conformance suite, whose callers are told. Elsewhere (the validator's bindings,
;; FHIRPath's %terminologies) the request is answered with what can be said without it (`fallback`:
;; no codes, the supplement left out): those callers must not fail on what they cannot decide.
(struct exn:fail:terminology exn:fail (kind code))
(define current-terminology-strict? (make-parameter #f))
;; refused : X symbol string format-string any ... -> X   raises when strict, else answers `fallback`
(define (refused fallback kind code fmt . args)
  (if (current-terminology-strict?)
      (raise (exn:fail:terminology (apply format fmt args) (current-continuation-marks) kind code))
      fallback))

;; the supplements a value set requires: its valueset-supplement extensions, as canonicals
(define supplement-extension "http://hl7.org/fhir/StructureDefinition/valueset-supplement")
(define (required-supplements vs)
  (for/list ([e (in-list (jlist vs 'extension))]
             #:when (equal? (jref e 'url) supplement-extension)
             #:when (string? (jref e 'valueCanonical)))
    (jref e 'valueCanonical)))
;; supplements-here : resolver (listof canonical) -> (listof canonical)   those that resolve; one
;; that does not is a refusal
(define (supplements-here resource urls)
  (for/list ([u (in-list urls)]
             #:when (or (and (string? u) (resource u))
                        (refused #f 'supplement "not-found" "Required supplement not found: ~a" u)))
    u))

;; a value an expansion parameter stated in the definition (compose.extension
;; valueset-expansion-parameter, parts `name` and `value`), else `default`
(define expansion-parameter-extension "http://hl7.org/fhir/StructureDefinition/valueset-expansion-parameter")
(define (expansion-parameter compose name [default #f])
  (or (for/or ([e (in-list (jlist compose 'extension))]
               #:when (equal? (jref e 'url) expansion-parameter-extension))
        (define parts (jlist e 'extension))
        (define (part n) (for/or ([q (in-list parts)] #:when (equal? (jref q 'url) n)) q))
        (and (part "name") (equal? (extension-value (part "name")) name)
             (part "value") (extension-value (part "value"))))
      default))
(define (extension-value e)
  (for/or ([(k v) (in-hash e)] #:when (regexp-match? #rx"^value" (symbol->string k))) v))

;; Two versions of one code system in one value set. Members are told apart BY VERSION when the
;; definition says so (its `versionsMatch` expansion parameter is false) or, when it says nothing,
;; when it includes more than one version of a system; otherwise a code is one member whatever
;; its version: the newest is kept, and excluding it from any version removes it.
(define (by-version? compose)
  (define stated (expansion-parameter compose "versionsMatch" 'unsaid))
  (cond
    [(member stated '("true" #t)) #f]
    [(member stated '("false" #f)) #t]
    [else
     (define versions                      ; system -> the distinct pins its includes carry
       (for/fold ([h (hash)]) ([inc (in-list (jlist compose 'include))]
                               #:when (string? (jref inc 'system)))
         (hash-update h (jref inc 'system) (lambda (vs) (remove-duplicates (cons (jref inc 'version) vs))) '())))
     (for/or ([(_ vs) (in-hash versions)]) (> (length vs) 1))]))
;; one member per (system, code): the newest version, where the code first stands
(define (newest-versions ms)
  (define (key m) (cons (member-system m) (member-code m)))
  (define (newer a b) (if (string>? (or (member-version b) "") (or (member-version a) "")) b a))
  (define best (for/fold ([h (hash)]) ([m (in-list ms)]) (hash-update h (key m) (lambda (o) (newer o m)) m)))
  (let loop ([ms ms] [seen (hash)] [acc '()])
    (cond [(null? ms) (reverse acc)]
          [(hash-ref seen (key (car ms)) #f) (loop (cdr ms) seen acc)]
          [else (loop (cdr ms) (hash-set seen (key (car ms)) #t) (cons (hash-ref best (key (car ms))) acc))])))

;; ---- $expand --------------------------------------------------------------------------------
;; a member is (vector system code display version) — the VERSION matters: a compose.include may
;; pin a CodeSystem version, and validation of a versioned Coding must compare against it.
;; Expand a ValueSet url -> (listof member), applying
;; compose.include minus compose.exclude. An IMPLICIT VCL url (http://fhir.org/VCL?v1=...,
;; https://build.fhir.org/ig/FHIR/ig-guidance/vcl.html) synthesizes its ValueSet from the
;; percent-decoded expression -- the spec says processors SHALL percent-decode before interpreting.
(define (expand-members resource url [vs-version #f] [policy no-version-policy] [visited '()])
  (define vs (or (resource url vs-version) (implicit-vcl-valueset url)))
  (if vs
      (valueset-members resource vs url policy visited)
      (refused '() (if (null? visited) 'valueset 'import) "not-found"
               "A definition for the value set '~a' could not be found"
               (if vs-version (format "~a|~a" url vs-version) url))))

;; valueset-members : resolver ValueSet url policy (listof url) -> (listof Member)
;; the members of a value set in hand, known by `url` (a contained one by `<container>#<id>`)
(define (valueset-members resource vs url policy visited)
  (cond
    ;; a value set that includes itself, however indirectly
    [(member url visited)
     (refused '() 'circular "processing" "The value set '~a' includes itself" url)]
    [else
     (supplements-here resource (required-supplements vs))
     (define compose (jref vs 'compose))
     (define seen (cons url visited))
     (cond
       ;; a pre-expanded ValueSet (an expansion, no compose) stands for its expansion
       [(and (not compose) (jref vs 'expansion))
        (dedup (contains->members (jlist (jref vs 'expansion) 'contains)))]
       [else
        ;; compose.inactive = false drops concepts the CodeSystem marks inactive/deprecated/retired.
        ;; ABSENT means "no constraint" — distinguish it from an explicit false (jref defaults to #f).
        (define keep-inactive? (not (eq? (jref compose 'inactive 'absent) #f)))
        (define (members inc)
          (define ms (include-members resource inc policy seen vs))
          (if keep-inactive? ms
              (let ([cs (let ([sys (jref inc 'system)]) (and (string? sys) (resource sys)))])
                (filter (lambda (m) (not (inactive-concept? cs (member-code m)))) ms))))
        (define included (append-map members (jlist compose 'include)))
        (define excluded (append-map members (jlist compose 'exclude)))
        (define versioned? (by-version? compose))
        (define (key m) (if versioned? (member-key m) (cons (member-system m) (member-code m))))
        (define ex-keys (for/hash ([m (in-list excluded)]) (values (key m) #t)))
        (define kept (filter (lambda (m) (not (hash-ref ex-keys (key m) #f))) included))
        (if versioned? (dedup kept) (newest-versions kept))])]))

;; expansion.contains (nested) -> members
(define (contains->members entries)
  (append-map (lambda (e)
                (cons (make-member (jref e 'system) (jref e 'code) (jref e 'display) (jref e 'version))
                      (contains->members (jlist e 'contains))))
              entries))

;; expansions are memoised per resolver: a resolver over packages lives as long as the packages,
;; and the operations rebuild the one over a data source per request, so neither goes stale
(define expansion-caches (make-weak-hasheq))
(define (expand-members/cached resource url vs-version policy)
  (define cache (hash-ref! expansion-caches resource make-hash))
  (hash-ref! cache (list url vs-version policy (current-terminology-strict?))
             (lambda () (expand-members resource url vs-version policy))))

;; the spec's implicit-ValueSet form: decode ?v1= and compile the VCL expression to a compose
(define (implicit-vcl-valueset url)
  (define m (regexp-match #px"^https?://fhir\\.org/VCL\\?v1=(.*)$" url))
  (and m
       (let ([r (vcl->compose (uri-decode (cadr m)))])
         (and (ok? r) (hasheq 'resourceType "ValueSet" 'url url 'compose (ok-value r))))))

;; a compose.include/exclude entry -> (listof member): its explicit `concept`s, else the whole
;; CodeSystem named by `system`, else (system-less / valueSet-only) nothing.
(define (include-members resource inc [policy no-version-policy] [visited '()] [container #f])
  (define system (jref inc 'system))
  ;; compose.include.valueSet: with a system, the include is narrowed to the codes in ALL the
  ;; named value sets; without one, it is their intersection (ValueSet.compose.include.valueSet)
  (define vs-lists
    (for/list ([u (in-list (jlist inc 'valueSet))])
      ;; an import that names no version takes the server's default for that value set, if any
      (define-values (base stated) (split-canonical u))
      (define contained                    ; `#id`: a value set the defining resource contains
        (and container (regexp-match? #rx"^#" u)
             (for/or ([r (in-list (jlist container 'contained))])
               (and (equal? (jref r 'resourceType) "ValueSet")
                    (equal? (jref r 'id) (substring u 1))
                    r))))
      (if contained
          (valueset-members resource contained (string-append (car visited) u) policy visited)
          (expand-members resource base (or stated (hash-ref (version-policy-valuesets policy) base #f))
                          policy visited))))
  (define vs-sets
    (for/list ([ms (in-list vs-lists)])
      (for/hash ([m (in-list ms)]) (values (list (member-system m) (member-code m)) #t))))
  (define (in-all? m)
    (for/and ([s (in-list vs-sets)]) (hash-ref s (list (member-system m) (member-code m)) #f)))
  (define base (include-base resource inc system policy))
  (cond
    [(and (not (string? system)) (pair? vs-lists)) (filter in-all? (car vs-lists))]
    [(pair? vs-lists) (filter in-all? base)]
    [else base]))

;; the include's own members: its explicit `concept`s, its filters, else the whole CodeSystem
(define (include-base resource inc system policy)
  ;; version precedence: the server's FORCE parameter overrides everything, then the include's own
  ;; pin, then the server's default (system-version)
  (define forced (and system (hash-ref (version-policy-force policy) system #f)))
  (define defaulted (and system (hash-ref (version-policy-default policy) system #f)))
  ;; check-system-version: the version to use where the definition names none, and the version
  ;; whatever it names must be
  (define checked (and system (hash-ref (version-policy-check policy) system #f)))
  (define pinned (or forced (jref inc 'version) checked defaulted))
  (define concepts (jlist inc 'concept))
  (define filters (jlist inc 'filter))
  (define cs (and (string? system) (resource system pinned)))
  (when (and cs checked (not forced)
             (not (equal? (jref cs 'version) checked)) (not (version-matches? (jref cs 'version) checked)))
    (refused (void) 'version-check "exception"
             "The version '~a' is not allowed for system '~a': required to be '~a' by a version-check parameter"
             (jref cs 'version) system checked))
  (for ([f (in-list filters)] #:unless (string? (jref f 'value)))
    (refused (void) 'filter "invalid" "The system ~a filter with property = ~a, op = ~a has no value"
             system (jref f 'property) (jref f 'op)))
  ;; a WILDCARD pin ("1.x.x") means the ValueSet accepts any matching version, so the pattern —
  ;; not the one concrete version we happened to resolve — is what a Coding is checked against
  (define version (if (wildcard-version? pinned) pinned (and cs (jref cs 'version))))
  (cond
    ;; a pinned version that does not resolve contributes nothing
    [(and pinned (not cs))
     (refused '() 'system-version "not-found"
              "A definition for CodeSystem '~a' version '~a' could not be found, so the value set cannot be expanded"
              system pinned)]
    [(pair? concepts)
     ;; an enumerated concept must EXIST in the code system when we can see ALL of it — the suite's
     ;; `enum-bad` case pins that a bogus code does not silently join the expansion. A code system
     ;; that is not complete here (the core packages' SNOMED / RxNorm placeholders are content
     ;; `not-present`; a fragment) cannot say a code is absent, so the enumeration stands.
     (define known (and cs (complete-codesystem? cs)
                        (for/hash ([c (in-list (all-concepts (jlist cs 'concept)))])
                          (values (jref c 'code) c))))
     (for/list ([c (in-list concepts)]
                #:when (or (not known) (hash-ref known (jref c 'code) #f)))
       (make-member system (jref c 'code)
                    (or (jref c 'display)
                        (and known (jref (hash-ref known (jref c 'code) (hasheq)) 'display)))
                    version))]
    [(and (string? system) (pair? filters))
     ;; compose.include.filter: every filter must hold (AND), evaluated over the CodeSystem
     (for/list ([c (in-list (all-concepts (jlist cs 'concept)))]
                #:when (for/and ([f (in-list filters)]) (concept-passes? cs c f)))
       (make-member system (jref c 'code) (jref c 'display) version))]
    [(string? system)
     (for/list ([c (in-list (all-concepts (jlist cs 'concept)))])
       (make-member system (jref c 'code) (jref c 'display) version))]
    [else '()]))

;; ---- filter evaluation (https://hl7.org/fhir/valueset-definitions.html#ValueSet.compose…filter)
;; Supported ops: is-a / is-not-a / descendent-of (hierarchy over the concept tree), = and in /
;; not-in (property or `concept` value), regex, exists. An op we cannot decide EXCLUDES nothing
;; by returning #t only when we understand it — an unknown op yields #f (the concept is left out)
;; rather than silently widening the value set.
(define (concept-passes? cs concept f)
  ;; (the ops the spec defines but this does not: none — `of` is not a filter operator)
  (define prop (jref f 'property))
  (define op (jref f 'op))
  (define val (or (jref f 'value) ""))
  (define code (jref concept 'code))
  (case op
    [("is-a")          (or (equal? code val) (descendant-of? cs code val))]
    [("descendent-of") (descendant-of? cs code val)]
    [("is-not-a")      (not (or (equal? code val) (descendant-of? cs code val)))]
    [("child-of")      (child-of? cs code val)]
    [("generalizes")   (or (equal? code val) (descendant-of? cs val code))]
    [("descendent-leaf") (and (descendant-of? cs code val) (leaf-concept? cs code))]
    [("regex")         (let ([v (concept-value cs concept prop)]
                             [rx (compile-filter-regex val)])
                         (and v rx (bounded-match? rx v)))]
    [("=")             (equal? (concept-value cs concept prop) val)]
    [("in")            (and (member (concept-value cs concept prop) (string-split val ",")) #t)]
    [("not-in")        (not (member (concept-value cs concept prop) (string-split val ",")))]
    [("exists")        (if (equal? val "false")
                           (not (concept-value cs concept prop))
                           (and (concept-value cs concept prop) #t))]
    [else #f]))

;; FHIR filter regexes are Java-flavoured. Racket's pregexp does NOT accept the whitespace escapes
;; inside a character class (the suite's `[^ \t\r\n\f]{4}[0-9]` is rejected outright), so
;; substitute the literal characters before compiling. A pattern that still will not compile
;; decides nothing — the concept is left out rather than raising.
(define (compile-filter-regex val)
  (define translated
    (regexp-replaces val (list (list #rx"\\\\t" "\t")
                               (list #rx"\\\\r" "\r")
                               (list #rx"\\\\n" "\n")
                               (list #rx"\\\\f" (string #\page))
                               (list #rx"\\\\a" (string #\u7))
                               (list #rx"\\\\e" (string #\u1B)))))
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (pregexp (string-append "^(?:" translated ")$"))))

;; bounded-match? : regexp string -> boolean
;; A filter's pattern is the definition's, and a backtracking matcher can take exponential time on
;; one (`(a+)+` against "aaa…X"). A match that does not finish within `match-seconds` is no
;; match: the code is left out, as the reference server leaves it out.
(define match-seconds 0.2)
(define (bounded-match? rx v)
  (if (< (string-length v) 24)                       ; short texts cannot take long
      (regexp-match? rx v)
      (let* ([answer 'unfinished]
             [t (thread (lambda () (set! answer (regexp-match? rx v))))])
        (cond [(sync/timeout match-seconds t) answer]
              [else (kill-thread t) #f]))))

;; $expand with the operation's parameters (https://hl7.org/fhir/valueset-operation-expand.html).
;; `params` is a hash of parameter-name -> value:
;;   offset/count           page the member list (expansion.offset/.total describe the WHOLE set)
;;   activeOnly             drop concepts the CodeSystem marks inactive
;;   filter                 case-insensitive substring over code and display
;;   displayLanguage        prefer the designation in that language for `display`
;;   includeDesignations    emit contains.designation
;;   property               emit contains.property for the named properties
;;   includeDefinition      the value set's compose comes with the expansion
;;   designation            which designations includeDesignations emits (a language, or a use)
;;   useSupplement          supplements whose designations and properties count (each must be here)
;; `excludeNested` is accepted and ignored: our expansion is already flat, which is what it asks for.
;; rule-systems-without-content : resolver url [version] -> (listof system-url)
;; The code systems this value set selects from BY RULE — a filter, or the whole system — whose
;; content is not here: no CodeSystem resource for it, or one that does not list every code
;; (SNOMED CT, LOINC and RxNorm are `not-present` placeholders in the core packages). Such an include
;; contributes nothing to an expansion made here, so the expansion is short of codes the definition
;; includes, and "not in the expansion" does not mean "not in the value set". An include that LISTS
;; its codes needs no content and is not counted. Imported value sets are followed.
(define (rule-systems-without-content resource url [version #f] [visited '()])
  (define vs (and (not (member url visited)) (or (resource url version) (implicit-vcl-valueset url))))
  (remove-duplicates
   (for*/list ([inc (in-list (if vs (jlist (jref vs 'compose) 'include) '()))]
               [found (in-list
                       (append
                        (let ([system (jref inc 'system)])
                          (if (and (string? system) (null? (jlist inc 'concept))
                                   (let ([cs (resource system (jref inc 'version))])
                                     (not (and cs (complete-codesystem? cs)))))
                              (list system)
                              '()))
                        (for*/list ([v (in-list (jlist inc 'valueSet))] #:when (string? v)
                                    [s (in-list (rule-systems-without-content resource v #f (cons url visited)))])
                          s)))])
     found)))

;; the standard marker of an expansion that is not every code of the value set
(define unclosed-extension
  (hasheq 'url "http://hl7.org/fhir/StructureDefinition/valueset-unclosed" 'valueBoolean #t))

(define (tx-expand resource url [vs-version #f] [params (hash)] [policy no-version-policy])
  (define (p name [d #f]) (hash-ref params name d))
  (supplements-here resource (let ([u (p "useSupplement" '())]) (if (list? u) u (list u))))
  (languages-asked (p "displayLanguage"))
  (define all (expand-members/cached resource url vs-version policy))
  (define active (if (eq? (p "activeOnly") #t) (filter (lambda (m) (member-active? resource m)) all) all))
  (define filtered
    (let ([f (p "filter")])
      (if (and (string? f) (positive? (string-length f)))
          (filter (lambda (m) (member-matches-filter? m f)) active)
          active)))
  (define total (length filtered))
  ;; a server may decline an expansion larger than it will make whole (its own threshold, given
  ;; as `too-costly-threshold`); a page of one is asked for with `count`
  (let ([most (p "too-costly-threshold")])
    (when (and (exact-integer? most) (> total most) (not (exact-integer? (p "count"))))
      (refused (void) 'too-costly "too-costly"
               "The value set '~a' expands to ~a codes, more than the ~a this server expands at once: ask for a page with count"
               url total most)))
  (define offset (let ([o (p "offset")]) (if (exact-integer? o) (max 0 o) 0)))
  (define after-offset (if (< offset total) (list-tail filtered offset) '()))
  (define page (let ([c (p "count")])
                 (if (exact-integer? c) (take after-offset (min c (length after-offset))) after-offset)))
  ;; The expansion is FLAT unless `excludeNested` is explicitly false, which asks for the
  ;; hierarchical form: a member whose parent is also in the expansion nests under it, so only
  ;; roots appear at top level.
  (define entries (for/list ([m (in-list page)]) (member->contains resource m params)))
  (define contains
    (if (eq? (p "excludeNested" 'absent) #f)
        (nest-contains resource page entries)
        entries))
  ;; includeDefinition: the value set's own definition comes with its expansion
  (define definition
    (and (eq? (p "includeDefinition") #t)
         (let ([vs (or (resource url vs-version) (implicit-vcl-valueset url))]) (and vs (jref vs 'compose)))))
  (values
   (drop-false
    (hasheq 'resourceType "ValueSet"
           'url url
           'compose definition
           'expansion
           (drop-false
            (hasheq 'extension (and (pair? (rule-systems-without-content resource url vs-version))
                                    (list unclosed-extension))
                    'total total
                    'offset (and (> offset 0) offset)
                    'contains contains))))))

;; nest each entry under its parent concept when that parent is also in the expansion
(define (nest-contains resource members entries)
  (define by-code (for/hash ([m (in-list members)] [e (in-list entries)])
                    (values (member-code m) e)))
  (define parent-of                       ; code -> parent code, from the CodeSystem's tree
    (for/fold ([h (hash)]) ([m (in-list members)])
      (define cs (resource (member-system m) (member-version m)))
      (define par (and cs (hash-ref (csix-parent (cs-index cs)) (member-code m) #f)))
      (if par (hash-set h (member-code m) par) h)))
  (define present (for/hash ([m (in-list members)]) (values (member-code m) #t)))
  ;; build bottom-up: a child is attached to its parent's entry
  (define children                        ; parent code -> (listof child code), in member order
    (for/fold ([h (hash)]) ([m (in-list members)])
      (define code (member-code m))
      (define par (hash-ref parent-of code #f))
      (if (and par (hash-ref present par #f))
          (hash-update h par (lambda (l) (append l (list code))) '())
          h)))
  (define (build code)
    (define e (hash-ref by-code code))
    (define kids (hash-ref children code '()))
    (if (null? kids) e (hash-set e 'contains (for/list ([k (in-list kids)]) (build k)))))
  (for/list ([m (in-list members)]
             #:unless (let ([par (hash-ref parent-of (member-code m) #f)])
                        (and par (hash-ref present par #f))))
    (build (member-code m))))

;; wanted-designations : (listof designation) (or/c #f token (listof token)) -> (listof designation)
;; the `designation` parameter: each token a language (`de`) or a use (`system|code`); a
;; designation is kept when it matches one, every designation when none is given
(define (wanted-designations designations tokens)
  (define ts (cond [(not tokens) '()] [(list? tokens) tokens] [else (list tokens)]))
  (if (null? ts)
      designations
      (filter (lambda (d)
                (for/or ([t (in-list ts)] #:when (string? t))
                  (define m (regexp-match #rx"^(.*)[|](.*)$" t))
                  (if m
                      (let ([use (jref d 'use)])
                        (and use (equal? (jref use 'system) (cadr m)) (equal? (jref use 'code) (caddr m))))
                      (language-fits? (jref d 'language) (list t)))))
              designations)))

;; one expansion member -> a contains entry, honouring displayLanguage / includeDesignations /
;; property
(define (member->contains resource m params)
  (define (p name [d #f]) (hash-ref params name d))
  (define cs (resource (member-system m) (member-version m)))
  (define concept (and cs (find-concept cs (member-code m))))
  (define lang (p "displayLanguage"))
  (define-values (sup-designations sup-properties)
    (supplement-parts resource (p "useSupplement") (member-code m)))
  (define designations (append (if concept (jlist concept 'designation) '()) sup-designations))
  (define properties (append (if concept (jlist concept 'property) '()) sup-properties))
  (define display
    (or (and lang (for/or ([d (in-list designations)])
                    (and (equal? (jref d 'language) lang) (jref d 'value))))
        (member-display m)))
  (drop-false
   (hasheq 'system (member-system m)
           'version (member-version m)
           'code (member-code m)
           'display display
           'designation (and (eq? (p "includeDesignations") #t) (pair? (wanted-designations designations (p "designation")))
                             (for/list ([d (in-list (wanted-designations designations (p "designation")))])
                               (drop-false (hasheq 'language (jref d 'language)
                                                   'use (jref d 'use)
                                                   'value (jref d 'value)))))
           'property (let ([wanted (p "property")])
                       (and wanted concept
                            (let ([names (if (list? wanted) wanted (list wanted))])
                              (let ([ps (for/list ([pr (in-list properties)]
                                                   #:when (member (jref pr 'code) names))
                                          pr)])
                                (and (pair? ps) ps))))))))
(define (member-active? resource m)
  (define cs (resource (member-system m) (member-version m)))
  (not (inactive-concept? cs (member-code m))))

;; the filter parameter is a case-insensitive substring match over code and display
(define (member-matches-filter? m f)
  (define needle (string-downcase f))
  (define (has? s) (and (string? s) (regexp-match? (regexp (regexp-quote needle))
                                                   (string-downcase s))))
  (or (has? (member-code m)) (has? (member-display m))))

;; ---- $validate-code (against a ValueSet) ----------------------------------------------------

;; $validate-code — the operation's three input shapes (https://hl7.org/fhir/valueset-operation-
;; validate-code.html): a bare `code` (+ optional system), a `Coding`, or a `CodeableConcept`
;; (valid when ANY of its codings is). A supplied DISPLAY must match the concept's display or one
;; of its designations; a mismatch fails unless `lenient-display-validation` is set, in which case
;; it is a warning and the result stays true. The response echoes the resolved code/system/display
;; so a caller can see WHICH coding matched.
;;
;; The positional (url code [system]) arity is preserved: fhirpath's validateVS and
;; conformance/validate.rkt's binding check both call it that way.
;; A VersionPolicy is (version-policy default force check), each a hash system -> version taken
;; from the server-level `system-version` / `force-system-version` / `check-system-version`
;; parameters (https://hl7.org/fhir/valueset-operation-validate-code.html):
;;   default : the version to assume when a Coding states none
;;   force   : the version to USE regardless of what the Coding states
;;   check   : the version the Coding must agree with (a mismatch is an error)
;;   valuesets : value set url -> the version an import that names none means (default-valueset-version)
(struct version-policy (default force check valuesets) #:transparent)
(define no-version-policy (version-policy (hash) (hash) (hash) (hash)))

;; "http://sys|1.0.x" -> (cons system version); anything else -> #f
(define (parse-versioned-canonical s)
  (define m (and (string? s) (regexp-match #px"^([^|]+)[|](.+)$" s)))
  (and m (cons (cadr m) (caddr m))))
(define (policy-of default-vs force-vs check-vs [valueset-vs '()])
  (define (->hash vs)
    (for/fold ([h (hash)]) ([v (in-list (if (list? vs) vs (if vs (list vs) '())))])
      (define p (parse-versioned-canonical (format "~a" v)))
      (if p (hash-set h (car p) (cdr p)) h)))
  (version-policy (->hash default-vs) (->hash force-vs) (->hash check-vs) (->hash valueset-vs)))
;; An Asked is what a request asks a coding to be held to, beyond membership:
;;   lenient?        a wrong display is a warning, not an error
;;   system-version  the version a bare code's system is in (systemVersion)
;;   policy          the server's version parameters
;;   active-only?    an inactive code is not a member
;;   abstract?       #f: an abstract (not selectable) code is not acceptable
;;   languages       #f | (listof tag): the languages a display may be in
;;   supplements     (listof canonical): the supplements whose designations count
;;   whole-systems   (listof system): the systems the value set takes whole
;;   ucum            (listof (listof filter)): the value set's includes of UCUM by rule, each its filters
;;   infer?          a bare code's system must be the only one the value set has the code in
;;   coding?         the code came as a Coding, which names its system
(struct asked (lenient? system-version policy active-only? abstract? languages supplements
                        whole-systems ucum infer? coding?))

(define (tx-validate resource url [code #f] [system #f]
                     #:coding [coding #f] #:codeable-concept [cc #f]
                     #:display [display #f] #:lenient-display? [lenient? #f]
                     #:system-version [system-version #f] #:valueset-version [vs-version #f]
                     #:policy [policy no-version-policy]
                     #:active-only? [active-only? #f] #:abstract? [abstract? #t]
                     #:display-language [display-language #f] #:infer-system? [infer-system? #f]
                     #:supplements [supplements '()])
  (define codings
    (cond [cc (jlist cc 'coding)]
          [coding (list coding)]
          [code (list (drop-false (hasheq 'system system 'code code 'display display)))]
          [else '()]))
  ;; for a validation three refusals are the answer "no", with their reason: an import, a pinned
  ;; code system version or a checked version that is not right
  ;; (the checked version is held coding by coding below: a coding that states a version the
  ;; check allows is fine where the definition's pin takes several; so the members are those
  ;; under the check as a default only)
  (define relaxed
    (struct-copy version-policy policy
                 [check (hash)]
                 [default (for/fold ([h (version-policy-default policy)])
                                    ([(system v) (in-hash (version-policy-check policy))])
                            (if (hash-has-key? h system) h (hash-set h system v)))]))
  (define-values (members soft)
    (with-handlers ([(lambda (e) (and (exn:fail:terminology? e)
                                      (memq (exn:fail:terminology-kind e) '(import system-version))))
                     (lambda (e) (values '() (exn-message e)))])
      (values (expand-members/cached resource url vs-version relaxed) #f)))
  (define vs (or (resource url vs-version) (implicit-vcl-valueset url)))
  (define compose (if vs (jref vs 'compose) (hasheq)))
  (define settings
    (asked lenient? system-version policy active-only? abstract?
           (or (languages-asked display-language)
               (languages-asked (expansion-parameter compose "displayLanguage"))
               (languages-asked (and vs (jref vs 'language))))
           (append (if vs (required-supplements vs) '()) (supplements-here resource supplements))
           (for/list ([inc (in-list (jlist compose 'include))]
                      #:when (string? (jref inc 'system))
                      #:when (null? (jlist inc 'concept)) #:when (null? (jlist inc 'filter))
                      #:when (null? (jlist inc 'valueSet)))
             (jref inc 'system))
           (for/list ([inc (in-list (jlist compose 'include))]
                      #:when (equal? (jref inc 'system) ucum-system)
                      #:when (null? (jlist inc 'concept)))
             (jlist inc 'filter))
           infer-system? (and (or cc coding) #t)))
  ;; the first coding that is a member wins; otherwise report against the first coding
  (define checks (for/list ([c (in-list codings)]) (check-coding resource members c settings)))
  ;; A coding naming an unknown CODE in a system we KNOW is an ERROR, and an error anywhere makes
  ;; the whole CodeableConcept invalid — even when a sibling coding is a member (proven by the
  ;; suite's bad-cc2 cases). "Not a member" and "unknown system" are not errors in that sense.
  (define error-check (for/or ([r (in-list checks)]) (and (hash-ref r 'error? #f) r)))
  (define valid-check (for/or ([r (in-list checks)]) (and (hash-ref r 'ok #f) r)))
  ;; a coding that IS a member, whatever else is wrong with it (its display): the one to describe
  (define member-check (for/or ([r (in-list checks)]) (and (hash-ref r 'member? #f) r)))
  ;; the VERDICT comes from the error (if any), but the reported code/system/display describe the
  ;; coding that actually validated — the reference echoes the resolvable one
  (define outcome
    (cond
      [(and soft (pair? codings))
       (drop-false (hasheq 'ok #f 'code (jref (car codings) 'code) 'system (jref (car codings) 'system)
                           'message soft))]
      [(and error-check (or valid-check member-check))
       (hash-set* (or valid-check member-check) 'ok #f 'message (hash-ref error-check 'message #f))]
      [error-check error-check]
      [valid-check valid-check]
      [member-check member-check]
      [(pair? checks) (car checks)]
      [else (hasheq 'ok #f 'message "no code supplied")]))
  ;; "not in the expansion" decides nothing for a code of a system the value set selects from by
  ;; rule while that system's content is not here: said in the message, and named as the reference
  ;; server names it (x-caused-by-unknown-system), so a caller can tell "no" from "cannot say"
  (define undecided
    (and (not (hash-ref outcome 'ok #f)) (not (hash-ref outcome 'error? #f)) (hash-ref outcome 'code #f)
         (not soft)
         (let ([absent (remove ucum-system (rule-systems-without-content resource url vs-version))]
               [system (hash-ref outcome 'system #f)])
           (cond [(null? absent) #f]
                 [(not system) (car absent)]
                 [(member system absent) system]
                 [else #f]))))
  (define verdict
    (if undecided
        (hash-set outcome 'message
                  (format "Whether '~a' is in the value set cannot be decided here: the value set selects from ~a by rule, and that code system's content is not in the packages"
                          (hash-ref outcome 'code) undecided))
        outcome))
  (values
   (hasheq 'resourceType "Parameters"
           'parameter
           (filter values
                   (list (hasheq 'name "result" 'valueBoolean (and (hash-ref verdict 'ok #f) #t))
                         (let ([c (hash-ref verdict 'code #f)])
                           (and c (hasheq 'name "code" 'valueCode c)))
                         (let ([s (hash-ref verdict 'system #f)])
                           (and s (hasheq 'name "system" 'valueUri s)))
                         (let ([v (hash-ref verdict 'version #f)])
                           (and v (hasheq 'name "version" 'valueString v)))
                         (let ([d (hash-ref verdict 'display #f)])
                           (and d (hasheq 'name "display" 'valueString d)))
                         (let ([n (hash-ref verdict 'normalized #f)])
                           (and n (hasheq 'name "normalized-code" 'valueCode n)))
                         (let ([m (hash-ref verdict 'message #f)])
                           (and m (hasheq 'name "message" 'valueString m)))
                         (and undecided (hasheq 'name "x-caused-by-unknown-system" 'valueCanonical undecided)))))))

;; check-coding : resolver (listof Member) Coding Asked -> (hash ok code system display message …)
;; one coding held to the value set's members and to what the request asks: the version rules,
;; membership, then whether the code may be used (active, selectable), then its display.
;; `error?` marks a verdict that makes a whole CodeableConcept invalid; `member?` a coding that is
;; in the value set whatever else is wrong with it.
(define (check-coding resource members c a)
  (define code (jref c 'code))
  (define system (jref c 'system))
  (define policy (asked-policy a))
  (define stated (or (jref c 'version) (asked-system-version a)))
  (define forced (and system (hash-ref (version-policy-force policy) system #f)))
  (define checked (and system (hash-ref (version-policy-check policy) system #f)))
  (define defaulted (and system (hash-ref (version-policy-default policy) system #f)))
  ;; force overrides what the Coding says; otherwise the stated version, else the server default
  (define version (or forced stated defaulted))
  (define supplied-display (jref c 'display))
  ;; a code system that says its codes are not case sensitive
  (define folded? (let ([any (and system (resource system))])
                    (and any (eq? (jref any 'caseSensitive 'unsaid) #f))))
  (define (code=? x) (if folded? (and (string? x) (string? code) (string-ci=? x code)) (equal? x code)))
  (define (version-fits? m)
    (or (not version) (not (member-version m))
        (equal? version (member-version m))
        ;; either may be a pattern: a wildcard pin in the definition, a forced `1.0.x`
        (version-matches? version (member-version m))
        (version-matches? (member-version m) version)))
  ;; the members this coding could be, the newest version first
  (define candidates
    (sort (for/list ([m (in-list members)]
                     #:when (code=? (member-code m))
                     #:when (or (not system) (not (member-system m)) (equal? (member-system m) system))
                     #:when (version-fits? m))
            m)
          string>? #:key (lambda (m) (or (member-version m) ""))))
  (define systems (remove-duplicates (filter values (map member-system candidates))))
  (define system* (or system (and (= (length systems) 1) (car systems))))
  ;; the code system a member is of: where the definition's pin is a pattern, the version the
  ;; coding names, else the newest the pattern takes
  (define (system-of m)
    (and (member-system m)
         (resource (member-system m)
                   (if (and stated (wildcard-version? (member-version m))) stated (member-version m)))))
  ;; the code system the concept is read from: the member's own version, else the one named
  (define cs (if (pair? candidates) (system-of (car candidates)) (and system (resource system version))))
  (define concept (and cs (find-concept cs code)))
  (define official (or (and concept (jref concept 'display))
                       (and (pair? candidates) (member-display (car candidates)))))
  (define (answer ok . more)
    (drop-false (apply hash-set* (hasheq 'ok ok 'code code 'system system*
                                         'version (and cs (jref cs 'version)))
                       more)))
  (define (displays-of m)
    (define m-cs (system-of m))
    (acceptable-displays resource m-cs (and m-cs (find-concept m-cs code)) code
                         (asked-supplements a) (asked-languages a)))
  (cond
    ;; check-system-version: a Coding that states a DIFFERENT version than the server requires
    [(and checked stated (not (equal? stated checked)) (not (version-matches? stated checked)))
     (answer #f 'error? #t 'message (format "Version '~a' does not match the required '~a'" stated checked))]
    [(and (asked-coding? a) (not system))
     (answer #f 'message "Coding has no system. A code with no system has no defined meaning, and it cannot be validated")]
    ;; a stated VERSION must resolve — also when the server forces another: the CodeSystem at that
    ;; version must exist, else the coding is invalid however well its code matches
    [(and system stated (not (resource system stated)))
     (answer #f 'message (format "Unknown version '~a' of code system '~a'" stated system))]
    [(and version (not cs) (null? candidates))
     (answer #f 'message (format "Unknown version '~a' of code system '~a'" version system))]
    [(and (not system) (asked-infer? a) (> (length systems) 1))
     (answer #f 'message (format "The system could not be determined for the code '~a': the value set has it in ~a"
                                 code (string-join systems " and ")))]
    [(pair? candidates)
     (cond
       ;; check-system-version: the version the code is read in must be the one required
       [(and checked cs (jref cs 'version)
             (not (equal? (jref cs 'version) checked)) (not (version-matches? (jref cs 'version) checked)))
        (answer #f 'error? #t 'member? #t 'display official
                'message (format "The version '~a' is not allowed for system '~a': required to be '~a' by a version-check parameter"
                                 (jref cs 'version) system checked))]
       [(and (asked-active-only? a) (inactive-concept? cs code))
        (answer #f 'member? #t 'display official
                'message (format "The concept '~a' is valid but is not active" code))]
       [(and (not (asked-abstract? a)) (abstract-concept? cs code))
        (answer #f 'member? #t 'display official
                'message (format "Code '~a' is abstract, and not allowed in this context" code))]
       [(and supplied-display
             (not (for/or ([m (in-list candidates)]) (member supplied-display (displays-of m)))))
        ;; a wrong display: an error, or a warning under lenient-display-validation
        (answer (and (asked-lenient? a) #t) 'member? #t 'display official
                'message (format "Wrong Display Name '~a'~a" supplied-display
                                 (if official (format ", should be '~a'" official) "")))]
       [else
        ;; described by the version whose display is the one given, when one was
        (define described
          (or (and supplied-display
                   (for/or ([m (in-list candidates)]) (and (member supplied-display (displays-of m)) m)))
              (car candidates)))
        (define d-cs (system-of described))
        (define d-concept (and d-cs (find-concept d-cs code)))
        (answer #t 'member? #t
                'version (or (and d-cs (jref d-cs 'version)) (and cs (jref cs 'version)))
                'display (or (and d-concept (jref d-concept 'display)) (member-display described))
                'normalized (and d-concept (not (equal? (jref d-concept 'code) code)) (jref d-concept 'code)))])]
    ;; UCUM has no list of its codes: a value set that takes it by rule has the valid units its
    ;; filters take
    [(and (equal? system ucum-system) (not cs) (pair? (asked-ucum a)))
     (cond
       [(not (ucum-valid? code))
        (answer #f 'error? #t 'message (format "Unknown code '~a' in the CodeSystem '~a'" code system))]
       [(for/or ([filters (in-list (asked-ucum a))]) (ucum-passes? code filters))
        (answer #t 'member? #t 'display code)]
       [else (answer #f 'display code 'message (format "The code '~a' is not in the value set" code))])]
    ;; the system is known AND COMPLETE but the code is not in it: an error, not merely a
    ;; non-member
    [(and cs (not concept) (complete-codesystem? cs))
     (answer #f 'error? #t 'message (format "Unknown code '~a' in the CodeSystem '~a'" code system))]
    ;; a FRAGMENT does not list every code: of a value set that takes the system whole, a code the
    ;; fragment lacks cannot be called invalid
    [(and cs (not concept) (equal? (jref cs 'content) "fragment") (member system (asked-whole-systems a)))
     (answer #t 'member? #t
             'message (format "Unknown Code '~a' in the CodeSystem '~a' version '~a' - note that the code system is labeled as a fragment, so the code may be valid in some other fragment"
                              code system (jref cs 'version)))]
    [else (answer #f 'display official 'message (format "The code '~a' is not in the value set" code))]))

;; a concept the code system marks as not for selection (the notSelectable property, by its
;; code or by its uri)
(define not-selectable-uri "http://hl7.org/fhir/concept-properties#notSelectable")
(define (abstract-concept? cs code)
  (define concept (and cs (find-concept cs code)))
  (define names
    (cons "notSelectable"
          (for/list ([p (in-list (if cs (jlist cs 'property) '()))]
                     #:when (equal? (jref p 'uri) not-selectable-uri))
            (jref p 'code))))
  (and concept
       (for/or ([p (in-list (jlist concept 'property))])
         (and (member (jref p 'code) names) (eq? (jref p 'valueBoolean) #t)))
       #t))

;; languages-asked : (or/c string #f) -> (or/c (listof tag) #f)
;; A displayLanguage (or an Accept-Language header): tags by preference, weights left out; #f
;; when none is asked for. A tag that is no language tag is a refusal.
(define (languages-asked text)
  (define tags
    (if (string? text)
        (for*/list ([part (in-list (string-split text ","))]
                    [tag (in-value (string-trim (car (string-split (string-append part ";") ";"))))]
                    #:unless (string=? tag ""))
          tag)
        '()))
  (for ([t (in-list tags)]
        #:unless (regexp-match? #px"^([A-Za-z]{1,8}(-[A-Za-z0-9]{1,8})*|\\*)$" t))
    (refused (void) 'language "processing" "Invalid displayLanguage: '~a'" t))
  (and (pair? tags) (not (member "*" tags)) tags))
;; is a display written in `language` acceptable where `wanted` are asked for? (en serves en-AU
;; and the reverse; a display that states no language serves any)
(define (language-fits? language wanted)
  (or (not wanted) (not (string? language))
      (for/or ([w (in-list wanted)])
        (or (string-ci=? w language)
            (string-prefix? (string-downcase language) (string-append (string-downcase w) "-"))
            (string-prefix? (string-downcase w) (string-append (string-downcase language) "-"))))))

;; acceptable-displays : resolver CodeSystem|#f concept|#f code (listof canonical) languages -> (listof string)
;; what a code may be displayed as: its display (in the code system's language) and its
;; designations, and those its supplements add — those in the languages asked for, when some are
;; asked for and the code has a display in one of them
(define (acceptable-displays resource cs concept code supplements languages)
  (define (of-concept language c)
    (append (if (jref c 'display) (list (cons language (jref c 'display))) '())
            (for/list ([d (in-list (jlist c 'designation))])
              (cons (or (jref d 'language) language) (jref d 'value)))))
  (define own (if concept (of-concept (and cs (jref cs 'language)) concept) '()))
  (define added
    (for*/list ([u (in-list supplements)]
                [sup (in-value (and (string? u) (resource u)))] #:when sup
                [c (in-value (find-concept sup code))] #:when c
                [pair (in-list (of-concept (jref sup 'language) c))])
      pair))
  (define all (append own added))
  (define fitting (filter (lambda (pair) (language-fits? (car pair) languages)) all))
  ;; a code with no display in the languages asked for is displayed as it can be
  (map cdr (if (null? fitting) all fitting)))

;; the supplied display must equal the concept's display or one of its designations
(define (display-matches? concept official supplied)
  (or (equal? supplied official)
      (for/or ([d (in-list (concept-designations concept))]) (equal? supplied d))))
(define (concept-designations concept)
  (for/list ([d (in-list (jlist concept 'designation))]) (jref d 'value)))

;; what the supplements named by `useSupplement` add to a concept: designations and properties
;; (https://hl7.org/fhir/codesystem.html#supplements); urls that do not resolve add nothing
(define (supplement-parts resource urls code)
  (define sups (filter values (for/list ([u (in-list (if (list? urls) urls (if urls (list urls) '())))])
                                (and (string? u) (resource u)))))
  (define concepts (filter values (for/list ([s (in-list sups)]) (find-concept s code))))
  (values (append-map (lambda (c) (jlist c 'designation)) concepts)
          (append-map (lambda (c) (jlist c 'property)) concepts)))

;; UCUM (https://ucum.org) is a grammar, not a list: no CodeSystem resource holds its codes. A code
;; is one when it is a valid unit; its display is itself.
(define ucum-system "http://unitsofmeasure.org")
;; ucum-passes? : code (listof filter) -> boolean   a valid unit held to an include's filters: the
;; property `canonical` (= a unit: the code measures what it measures); any other filter is one
;; this cannot decide, and takes nothing
(define (ucum-passes? code filters)
  (for/and ([f (in-list filters)])
    (and (equal? (jref f 'property) "canonical") (equal? (jref f 'op) "=")
         (string? (jref f 'value))
         (ucum-commensurable? code (jref f 'value)))))

;; ---- $lookup (CodeSystem) --------------------------------------------------------------------
;; https://hl7.org/fhir/codesystem-operation-lookup.html — the concept's name/display plus its
;; designations and properties.
(define (tx-lookup resource system code [version #f] #:supplements [supplements '()])
  (supplements-here resource (if (list? supplements) supplements (list supplements)))
  (define cs (or (resource system version)
                 (and (equal? system ucum-system) (ucum-valid? code)
                      (hasheq 'resourceType "CodeSystem" 'url ucum-system 'name "UCUM"
                              'concept (list (hasheq 'code code 'display code))))))
  (define concept (and cs (find-concept cs code)))
  (define-values (sup-designations sup-properties) (supplement-parts resource supplements code))
  (define designations (append (if concept (jlist concept 'designation) '()) sup-designations))
  (define properties (append (if concept (jlist concept 'property) '()) sup-properties))
  (values
   (hasheq 'resourceType "Parameters"
           'parameter
           (filter values
                   (append
                    (list (and cs (hasheq 'name "name" 'valueString (or (jref cs 'name) (jref cs 'title) "")))
                          (and cs (jref cs 'version)
                               (hasheq 'name "version" 'valueString (jref cs 'version)))
                          (and concept (hasheq 'name "display"
                                               'valueString (or (jref concept 'display) "")))
                          (and concept (jref concept 'definition)
                               (hasheq 'name "definition" 'valueString (jref concept 'definition))))
                    (for/list ([d (in-list designations)])
                      (hasheq 'name "designation"
                              'part (filter values
                                            (list (and (jref d 'language)
                                                       (hasheq 'name "language" 'valueCode (jref d 'language)))
                                                  (and (jref d 'use)
                                                       (hasheq 'name "use" 'valueCoding (jref d 'use)))
                                                  (hasheq 'name "value" 'valueString (or (jref d 'value) ""))))))
                    (for/list ([pr (in-list properties)])
                      (hasheq 'name "property"
                              'part (list (hasheq 'name "code" 'valueCode (or (jref pr 'code) ""))
                                          (drop-false
                                           (hasheq 'name "value"
                                                   'valueCode (jref pr 'valueCode)
                                                   'valueString (jref pr 'valueString)
                                                   'valueBoolean (jref pr 'valueBoolean)
                                                   'valueCoding (jref pr 'valueCoding)
                                                   'valueInteger (jref pr 'valueInteger)
                                                   'valueDecimal (jref pr 'valueDecimal)
                                                   'valueDateTime (jref pr 'valueDateTime)))))))))))

;; ---- $subsumes, $find-matches, TerminologyCapabilities --------------------------------------

;; closure-relation : resolver system codeA codeB -> relationship | #f   how A relates to B
;; (ConceptMapRelationship: equivalent, source-is-broader-than-target, source-is-narrower-than-target);
;; unknown codes raise
(define (closure-relation resource system a b [version #f])
  (case (subsumption resource system a b version)
    [("equivalent") "equivalent"]
    [("subsumes") "source-is-broader-than-target"]
    [("subsumed-by") "source-is-narrower-than-target"]
    [else #f]))

;; subsumption : resolver system codeA codeB [version] -> "equivalent" | "subsumes" | "subsumed-by"
;; | "not-subsumed" (the $subsumes outcome codes); an unknown system or code raises
(define (subsumption resource system a b [version #f])
  (define cs (resource system version))
  (unless cs (error 'subsumes "unknown code system ~a" system))
  (for ([c (in-list (list a b))])
    (unless (find-concept cs c) (error 'subsumes "unknown code ~a in ~a" c system)))
  (cond [(equal? a b) "equivalent"]
        [(descendant-of? cs b a) "subsumes"]
        [(descendant-of? cs a b) "subsumed-by"]
        [else "not-subsumed"]))

;; https://hl7.org/fhir/codesystem-operation-subsumes.html
(define (tx-subsumes resource system a b [version #f])
  (hasheq 'resourceType "Parameters"
          'parameter (list (hasheq 'name "outcome" 'valueCode (subsumption resource system a b version)))))

;; https://hl7.org/fhir/codesystem-operation-find-matches.html: the concepts whose properties
;; carry every (property . value) given; `exact?` #f matches a value as a substring
(define (tx-find-matches resource system props [version #f] [exact? #t])
  (define cs (resource system version))
  (unless cs (error 'find-matches "unknown code system ~a" system))
  (define (matches? v wanted)
    (and (string? v)
         (if exact? (equal? v wanted)
             (regexp-match? (regexp (regexp-quote (string-downcase wanted))) (string-downcase v)))))
  (hasheq 'resourceType "Parameters"
          'parameter
          (for/list ([c (in-list (all-concepts (jlist cs 'concept)))]
                     #:when (for/and ([p (in-list props)])
                              (matches? (concept-value cs c (car p)) (cdr p))))
            (hasheq 'name "match"
                    'part (list (hasheq 'name "code"
                                        'valueCoding (drop-false (hasheq 'system system
                                                                         'code (jref c 'code)
                                                                         'display (jref c 'display)))))))))

;; terminology-capabilities : (listof CodeSystem) [#:url] -> TerminologyCapabilities jsexpr
;; what this service does, over the code systems it holds (https://hl7.org/fhir/terminologycapabilities.html)
(define (terminology-capabilities code-systems #:url [url #f])
  (define by-url
    (for/fold ([h (hash)]) ([cs (in-list code-systems)] #:when (string? (jref cs 'url)))
      (hash-update h (jref cs 'url) (lambda (l) (append l (list cs))) '())))
  (define d (seconds->date (current-seconds) #f))
  (define (p2 n) (if (< n 10) (format "0~a" n) (number->string n)))
  (drop-false
   (hasheq 'resourceType "TerminologyCapabilities"
           'url url
           'status "active"
           'kind "instance"
           'date (format "~a-~a-~a" (date-year d) (p2 (date-month d)) (p2 (date-day d)))
           'codeSystem
           (for/list ([(u css) (in-hash by-url)])
             (define versions (filter values (map (lambda (cs) (jref cs 'version)) css)))
             (drop-false
              (hasheq 'uri u
                      'content (or (jref (car css) 'content) "not-present")
                      'version (and (pair? versions)
                                    (for/list ([v (in-list versions)] [i (in-naturals)])
                                      (hasheq 'code v 'isDefault (= i 0)))))))
           'expansion (hasheq 'hierarchical #t 'paging #t 'incomplete #f
                              'parameter (for/list ([n (in-list '("filter" "count" "offset" "activeOnly" "excludeNested"
                                                                  "displayLanguage" "includeDesignations" "property"
                                                                  "useSupplement" "system-version" "force-system-version"
                                                                  "check-system-version"))])
                                           (hasheq 'name n)))
           'codeSearch "in-compose-or-expansion"
           'validateCode (hasheq 'translations #f)
           'translation (hasheq 'needsMap #t)
           'closure (hasheq 'translation #f))))

;; ---- $validate-code against a CODE SYSTEM (no ValueSet) --------------------------------------
(define (tx-cs-validate resource system code [version #f]
                        #:coding [coding #f] #:display [display #f]
                        #:lenient-display? [lenient? #f])
  (define sys (or system (and coding (jref coding 'system))))
  (define c (or code (and coding (jref coding 'code))))
  (define v (or version (and coding (jref coding 'version))))
  (define disp (or display (and coding (jref coding 'display))))
  (define cs (or (resource sys v)
                 (and (equal? sys ucum-system) (string? c) (ucum-valid? c)
                      (hasheq 'resourceType "CodeSystem" 'url ucum-system 'name "UCUM"
                              'concept (list (hasheq 'code c 'display c))))))
  (define concept (and cs (find-concept cs c)))
  (define official (and concept (jref concept 'display)))
  (define outcome
    (cond
      [(not cs) (hasheq 'ok #f 'message (format "Unknown code system '~a'" sys))]
      ;; a supplement adds to another code system's codes: it is no system a code can be in
      [(equal? (jref cs 'content) "supplement")
       (hasheq 'ok #f 'code c 'system sys
               'message (format "CodeSystem ~a is a supplement, so can't be used as a value in Coding.system" sys))]
      [(not concept) (hasheq 'ok #f 'code c 'system sys
                             'message (format "Unknown code '~a' in '~a'" c sys))]
      [(and disp (not (display-matches? concept official disp)))
       (hasheq 'ok (and lenient? #t) 'code c 'system sys 'display official
               'message (format "Wrong Display Name '~a'" disp))]
      [else (hasheq 'ok #t 'code c 'system sys 'display official)]))
  (values
   (hasheq 'resourceType "Parameters"
           'parameter
           (filter values
                   (list (hasheq 'name "result" 'valueBoolean (and (hash-ref outcome 'ok #f) #t))
                         (let ([x (hash-ref outcome 'code #f)]) (and x (hasheq 'name "code" 'valueCode x)))
                         (let ([x (hash-ref outcome 'system #f)]) (and x (hasheq 'name "system" 'valueUri x)))
                         (let ([x (hash-ref outcome 'display #f)]) (and x (hasheq 'name "display" 'valueString x)))
                         (let ([x (hash-ref outcome 'message #f)]) (and x (hasheq 'name "message" 'valueString x))))))))

;; ---- $translate -----------------------------------------------------------------------------

;; a match is (vector relationship target-system target-code target-display).
(define (translate-matches resource url code [system #f])
  (define cm (resource url))
  (append-map
   (lambda (g)
     (define src (jref g 'source))
     (define tgt-system (jref g 'target))
     (if (and system src (not (equal? src system)))
         '()
         (append-map
          (lambda (e)
            (if (equal? (jref e 'code) code)
                (for/list ([t (in-list (jlist e 'target))])
                  (vector (or (jref t 'relationship) (jref t 'equivalence))
                          tgt-system (jref t 'code) (jref t 'display)))
                '()))
          (jlist g 'element))))
   (jlist cm 'group)))
(define (tx-translate resource url code [system #f])
  (define matches (translate-matches resource url code system))
  (values
   (hasheq 'resourceType "Parameters"
           'parameter
           (cons (hasheq 'name "result" 'valueBoolean (pair? matches))
                 (for/list ([mt (in-list matches)])
                   (hasheq 'name "match"
                           'part
                           (list (drop-false (hasheq 'name "relationship" 'valueCode (vector-ref mt 0)))
                                 (hasheq 'name "concept"
                                         'valueCoding
                                         (drop-false (hasheq 'system (vector-ref mt 1)
                                                             'code (vector-ref mt 2)
                                                             'display (vector-ref mt 3)))))))))))

;; ---- result construction --------------------------------------------------------------------

;; build a jsexpr resource into a typed node -> a one-element FHIRPath collection (or empty on failure).
;; The tx-* functions answer FHIR JSON; the tx-service closures (FHIRPath's %terminologies) wrap it.
(define (node js)
  (define r (from-json js #:lenient? #t))
  (if (ok? r) (list (ok-value r)) '()))

;; ---- the service ----------------------------------------------------------------------------

;; make-terminology : core .tgz -> tx-service. The index is loaded once, lazily, on first tx call
;; (by when the caller's type tower is registered). The caller must have the matching tower loaded
;; (require fhir/r5/schemas or fhir/r4/schemas) so the result ValueSet/Parameters nodes build.
(define (make-terminology tgz-path) (make-terminology/resolver (packages->resolver (list tgz-path))))
(define (make-terminology/packages tgzs) (make-terminology/resolver (packages->resolver tgzs)))
(define (make-terminology/resources resources)
  (make-terminology/resolver (resources->resolver resources)))
(define (make-terminology/resolver resource)
  (tx-service (lambda (url [vs-version #f] [params (hash)] [policy no-version-policy] . _)
                (node (tx-expand resource url vs-version params policy)))
              (make-validate resource)
              (lambda (url code . rest) (node (apply tx-translate resource url code rest)))
              ;; FHIRPath's subsumes(): how code a stands to code b in a system, #f when either is unknown
              (lambda (system a b [version #f])
                (with-handlers ([exn:fail? (lambda (_) #f)])
                  (define ps (tx-subsumes resource system a b version))
                  (hash-ref (car (hash-ref ps 'parameter)) 'valueCode)))))

;; #t when expanding/validating this ValueSet would require a code system we do not have
(define ((make-undecidable? resource) url [version #f])
  (define vs (resource url version))
  (cond
    [(not vs) #f]                       ; an unknown ValueSet is a legitimate "not found" answer
    [else
     (define includes (jlist (jref vs 'compose) 'include))
     ;; undecidable only when NOTHING in the definition is resolvable: every include names a code
     ;; system we do not have (SNOMED/LOINC/OHDSI) and imports nothing we can see. A ValueSet with
     ;; one missing system among several is still answerable for the systems we do have.
     (and (pair? includes)
          (for/and ([inc (in-list includes)])
            (define sys (jref inc 'system))
            (and (or (not (string? sys))
                     (and (not (resource sys)) (not (equal? sys ucum-system))))   ; probe WITHOUT a version pin
                 (for/and ([v (in-list (jlist inc 'valueSet))])
                   ((make-undecidable? resource) v)))))]))

;; the CodeSystem-level operations are exposed as closures over the same resolver
(define ((make-lookup resource) system code [version #f]) (node (tx-lookup resource system code version)))
(define ((make-cs-validate resource) system code [version #f]
                                     #:coding [coding #f] #:display [display #f]
                                     #:lenient-display? [lenient? #f])
  (node (tx-cs-validate resource system code version
                        #:coding coding #:display display #:lenient-display? lenient?)))

;; the validate closure accepts BOTH the positional (url code [system]) form its in-repo callers
;; use and the operation's keyword surface (coding / codeableConcept / display / lenient)
(define ((make-validate resource) url [code #f] [system #f]
                                  #:coding [coding #f] #:codeable-concept [cc #f]
                                  #:display [display #f] #:lenient-display? [lenient? #f]
                                  #:system-version [system-version #f] #:valueset-version [vs-version #f]
                                  #:policy [policy no-version-policy])
  (node (tx-validate resource url code system #:coding coding #:codeable-concept cc
                     #:display display #:lenient-display? lenient?
                     #:system-version system-version #:valueset-version vs-version
                     #:policy policy)))
(define (make-r5-terminology) (make-terminology r5-core-tgz))
(define (make-r4-terminology) (make-terminology r4-core-tgz))
;; ---- living examples ------------------------------------------------------------------------

(module+ test
  (require rackunit
           (only-in fhir/r5/schemas)                    ; the R5 tower for building result nodes
           (only-in fhirpath/parser/parse parse-fhirpath)
           (only-in fhirpath/eval eval-fhirpath)
           (only-in fhirpath/value item->system)
           (only-in fhir/serialize/from-json from-json)
           (only-in fhir/result/result ok-value))
  (define tx (make-r5-terminology))
  (define pat (ok-value (from-json (hasheq 'resourceType "Patient" 'gender "male"
                                           'address (list (hasheq 'use "home"))))))
  (define (T s) (map item->system
                     (eval-fhirpath (parse-fhirpath s) (list pat)
                                    #:externals (hash "terminologies" (list tx)))))
  (check-equal? (T "%terminologies.expand('http://hl7.org/fhir/ValueSet/administrative-gender').expansion.contains.count()") '(4))
  (check-equal? (T "%terminologies.validateVS('http://hl7.org/fhir/ValueSet/administrative-gender', $this.gender).parameter.where(name = 'result').value") '(#t))
  (check-equal? (T "%terminologies.translate('http://hl7.org/fhir/ConceptMap/cm-address-use-v2', $this.address.use).parameter.where(name = 'match').part.where(name = 'concept').value.code") '("H"))
  ;; a hierarchy: a > b > c; includes by value set, a pre-expanded value set, the leaf filter,
  ;; subsumption, matches by property, and what a server says about itself
  (define cs (hasheq 'resourceType "CodeSystem" 'url "http://x/cs" 'version "1" 'content "complete"
                     'concept (list (hasheq 'code "a" 'display "A"
                                            'property (list (hasheq 'code "kind" 'valueCode "root"))
                                            'concept (list (hasheq 'code "b" 'display "B"
                                                                   'concept (list (hasheq 'code "c" 'display "C"))))))))
  (define (vs url . compose) (hasheq 'resourceType "ValueSet" 'url url 'compose (apply hasheq compose)))
  (define (inc . kv) (apply hasheq kv))
  (define r (resources->resolver
             (list cs
                   (vs "http://x/leaf" 'include (list (inc 'system "http://x/cs" 'filter (list (hasheq 'property "concept" 'op "descendent-leaf" 'value "a")))))
                   (vs "http://x/gen" 'include (list (inc 'system "http://x/cs" 'filter (list (hasheq 'property "concept" 'op "generalizes" 'value "c")))))
                   (vs "http://x/ab" 'include (list (inc 'system "http://x/cs" 'concept (list (hasheq 'code "a") (hasheq 'code "b")))))
                   (vs "http://x/bc" 'include (list (inc 'system "http://x/cs" 'concept (list (hasheq 'code "b") (hasheq 'code "c")))))
                   (vs "http://x/both" 'include (list (inc 'valueSet (list "http://x/ab" "http://x/bc"))))
                   (vs "http://x/narrowed" 'include (list (inc 'system "http://x/cs" 'valueSet (list "http://x/bc"))))
                   (vs "http://x/self" 'include (list (inc 'valueSet (list "http://x/self"))))
                   (hasheq 'resourceType "ValueSet" 'url "http://x/pre"
                           'expansion (hasheq 'contains (list (hasheq 'system "http://x/cs" 'code "c" 'display "C")))))))
  (define (codes url) (map (lambda (e) (hash-ref e 'code)) (hash-ref (hash-ref (tx-expand r url) 'expansion) 'contains)))
  ;; a value set that selects by rule from a code system whose content is not here: its expansion
  ;; is marked as not every code, and a code of that system is "cannot say", named as the reference
  ;; server names it — an include that LISTS its codes needs no content and is decided
  (let* ([absent "http://absent.example/cs"]
         [r (resources->resolver
             (list cs
                   (vs "http://x/by-rule" 'include (list (inc 'system "http://x/cs" 'concept (list (hasheq 'code "a")))
                                                         (inc 'system absent 'filter (list (hasheq 'property "concept" 'op "is-a" 'value "1")))))
                   (vs "http://x/imports" 'include (list (inc 'valueSet (list "http://x/by-rule"))))
                   (vs "http://x/listed" 'include (list (inc 'system absent 'concept (list (hasheq 'code "1")))))))]
         [param (lambda (ps name) (for/or ([q (in-list (hash-ref ps 'parameter))]) (and (equal? (hash-ref q 'name) name) q)))])
    (check-equal? (rule-systems-without-content r "http://x/by-rule") (list absent))
    (check-equal? (rule-systems-without-content r "http://x/imports") (list absent))
    (check-equal? (rule-systems-without-content r "http://x/listed") '())
    (check-equal? (rule-systems-without-content r "http://x/ab") '())
    (check-equal? (hash-ref (hash-ref (tx-expand r "http://x/by-rule") 'expansion) 'extension) (list unclosed-extension))
    (check-false (hash-ref (hash-ref (tx-expand r "http://x/listed") 'expansion) 'extension #f))
    (define undecided (tx-validate r "http://x/by-rule" "2" absent))
    (check-false (hash-ref (param undecided "result") 'valueBoolean))
    (check-equal? (hash-ref (param undecided "x-caused-by-unknown-system") 'valueCanonical) absent)
    (check-regexp-match #rx"cannot be decided here" (hash-ref (param undecided "message") 'valueString))
    ;; a code of the system that IS here is decided, either way, with no such marker
    (check-true (hash-ref (param (tx-validate r "http://x/by-rule" "a" "http://x/cs") "result") 'valueBoolean))
    (check-false (param (tx-validate r "http://x/by-rule" "b" "http://x/cs") "x-caused-by-unknown-system"))
    (check-false (param (tx-validate r "http://x/listed" "2" absent) "x-caused-by-unknown-system")))
  (check-equal? (codes "http://x/leaf") '("c"))
  (check-equal? (codes "http://x/gen") '("a" "b" "c"))
  (check-equal? (codes "http://x/both") '("b"))
  (check-equal? (codes "http://x/narrowed") '("b" "c"))
  (check-equal? (codes "http://x/self") '())
  (check-equal? (codes "http://x/pre") '("c"))
  (define (outcome ps) (hash-ref (car (hash-ref ps 'parameter)) 'valueCode))
  (check-equal? (outcome (tx-subsumes r "http://x/cs" "a" "c")) "subsumes")
  (check-equal? (outcome (tx-subsumes r "http://x/cs" "c" "a")) "subsumed-by")
  (check-equal? (outcome (tx-subsumes r "http://x/cs" "b" "b")) "equivalent")
  (check-exn #rx"unknown code z" (lambda () (tx-subsumes r "http://x/cs" "a" "z")))
  (check-equal? (closure-relation r "http://x/cs" "c" "a") "source-is-narrower-than-target")
  (check-equal? (map (lambda (m) (hash-ref (hash-ref (car (hash-ref m 'part)) 'valueCoding) 'code))
                     (hash-ref (tx-find-matches r "http://x/cs" '(("kind" . "root"))) 'parameter))
                '("a"))
  (define tc (terminology-capabilities (list cs) #:url "http://x/tx"))
  (check-equal? (hash-ref tc 'resourceType) "TerminologyCapabilities")
  (check-equal? (hash-ref (car (hash-ref tc 'codeSystem)) 'uri) "http://x/cs"))

;; the rules the tx-ecosystem suite holds a server to (tests/tx-harness.rkt runs the suite itself)
(module+ test
  (require rackunit)
  (let ()
  (define (cs* url version content . concepts)
    (drop-false (hasheq 'resourceType "CodeSystem" 'url url 'version version 'content content 'concept concepts)))
  (define (c code [display #f] . more) (apply hash-set* (drop-false (hasheq 'code code 'display display)) more))
  (define (vs* url compose . more) (apply hash-set* (hasheq 'resourceType "ValueSet" 'url url 'compose compose) more))
  (define (inc system [version #f] . more) (apply hash-set* (drop-false (hasheq 'system system 'version version)) more))
  (define v1 (cs* "http://t/ov" "1.0.0" "complete" (c "a" "A") (c "b" "B 1") (c "c" "C")))
  (define v2 (cs* "http://t/ov" "2.0.0" "complete" (c "a" "A") (c "b" "B 2") (c "d" "D")))
  (define r
    (resources->resolver
     (list v1 v2
           (vs* "http://t/all" (hasheq 'include (list (inc "http://t/ov" "1.0.0") (inc "http://t/ov" "2.0.0"))))
           (vs* "http://t/excl" (hasheq 'include (list (inc "http://t/ov" "2.0.0"))
                                        'exclude (list (inc "http://t/ov" "1.0.0"))))
           (vs* "http://t/pin9" (hasheq 'include (list (inc "http://t/ov" "9.0.0"))))
           (vs* "http://t/import" (hasheq 'include (list (hasheq 'valueSet (list "http://t/nothing")))))
           (vs* "http://t/sup" (hasheq 'include (list (inc "http://t/ov")))
                'extension (list (hasheq 'url supplement-extension 'valueCanonical "http://t/no-supplement")))
           (hash-set (cs* "http://t/ci" "1" "complete" (c "code1" "One")) 'caseSensitive #f)
           (vs* "http://t/ci-all" (hasheq 'include (list (inc "http://t/ci"))))
           (cs* "http://t/frag" "1" "fragment" (c "x" "X"))
           (vs* "http://t/frag-all" (hasheq 'include (list (inc "http://t/frag"))))
           (cs* "http://t/dep" "1" "complete"
                (c "old" "Old" 'property (list (hasheq 'code "status" 'valueCode "deprecated")))
                (c "gone" "Gone" 'property (list (hasheq 'code "status" 'valueCode "retired"))))
           (vs* "http://t/dep-all" (hasheq 'include (list (inc "http://t/dep"))))
           (vs* "http://t/mass" (hasheq 'include (list (inc "http://unitsofmeasure.org" #f
                                                           'filter (list (hasheq 'property "canonical" 'op "=" 'value "g")))))))))
  (define (codes url [params (hash)]) (map (lambda (e) (cons (hash-ref e 'code) (hash-ref e 'version #f)))
                                           (hash-ref (hash-ref (tx-expand r url #f params) 'expansion) 'contains '())))
  (define (result ps) (hash-ref (for/first ([p (hash-ref ps 'parameter)] #:when (equal? (hash-ref p 'name) "result")) p) 'valueBoolean))
  (define (strict thunk) (parameterize ([current-terminology-strict? #t]) (thunk)))
  ;; two versions included: a code is a member in each
  (check-equal? (length (codes "http://t/all")) 6)
  ;; one version included, another excluded: a code is one member, removed by either version
  (check-equal? (codes "http://t/excl") '(("d" . "2.0.0")))
  ;; refusals: raised when strict, answered around otherwise
  (check-exn exn:fail:terminology? (lambda () (strict (lambda () (tx-expand r "http://t/nope")))))
  (check-equal? (codes "http://t/pin9") '())
  (check-exn #rx"version '9.0.0' could not be found" (lambda () (strict (lambda () (tx-expand r "http://t/pin9")))))
  (check-exn #rx"Required supplement not found" (lambda () (strict (lambda () (tx-expand r "http://t/sup")))))
  (check-equal? (exn:fail:terminology-code
                 (with-handlers ([values values]) (strict (lambda () (tx-expand r "http://t/import")))))
                "not-found")
  ;; a validation against a value set whose import is not here is "no", with the reason
  (check-false (result (strict (lambda () (tx-validate r "http://t/import" "a" "http://t/ov")))))
  ;; check-system-version refuses an expansion that takes another version
  (check-exn #rx"not allowed for system"
             (lambda () (strict (lambda () (tx-expand r "http://t/all" #f (hash) (policy-of '() '() '("http://t/ov|1.0.x")))))))
  ;; a display matches the version it is the display of
  (check-true (result (tx-validate r "http://t/all" "b" "http://t/ov" #:display "B 1")))
  (check-false (result (tx-validate r "http://t/all" "b" "http://t/ov" #:display "B 3")))
  ;; a code system that is not case sensitive takes a code in any case, and says the right one
  (define ci (tx-validate r "http://t/ci-all" "CODE1" "http://t/ci"))
  (check-true (result ci))
  (check-equal? (hash-ref (for/first ([p (hash-ref ci 'parameter)] #:when (equal? (hash-ref p 'name) "normalized-code")) p) 'valueCode) "code1")
  ;; a fragment cannot say a code it lacks is no code
  (check-true (result (tx-validate r "http://t/frag-all" "y" "http://t/frag")))
  ;; deprecated is still active; retired is not
  (check-equal? (map car (codes "http://t/dep-all" (hash "activeOnly" #t))) '("old"))
  (check-false (result (tx-validate r "http://t/dep-all" "gone" "http://t/dep" #:active-only? #t)))
  ;; UCUM by rule: a valid unit, held to the include's canonical
  (check-true (result (tx-validate r "http://t/mass" "kg" "http://unitsofmeasure.org")))
  (check-false (result (tx-validate r "http://t/mass" "mL" "http://unitsofmeasure.org")))
  ;; a Coding with no system cannot be validated
  (check-false (result (tx-validate r "http://t/all" #:coding (hasheq 'code "a"))))
  ;; a pattern that backtracks without end decides "no", in bounded time
  (check-false (bounded-match? (pregexp "^(?:(a+)+)$") (string-append (make-string 40 #\a) "X")))
  (check-true (bounded-match? (pregexp "^(?:(a+)+)$") (make-string 40 #\a)))
  ;; designations by language or use
  (define ds (list (hasheq 'language "de" 'value "Eins") (hasheq 'language "en" 'value "One")))
  (check-equal? (wanted-designations ds "de") (list (car ds)))
  (check-equal? (wanted-designations ds #f) ds)
  ;; display languages: tags by preference; one that is no tag is refused
  (check-equal? (languages-asked "en, en-AU; q=0.4") '("en" "en-AU"))
  (check-exn #rx"Invalid displayLanguage" (lambda () (strict (lambda () (languages-asked "-")))))))
