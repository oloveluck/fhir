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

(require (only-in fhir/spec-package spec-package-path) (only-in fhir/serialize/jsexpr-util jref jlist))
(require json racket/contract
         file/gunzip
         file/untar
         (only-in net/uri-codec uri-decode)
         (only-in vcl/compile vcl->compose)
         racket/list
         racket/string
         racket/promise
         racket/runtime-path
         (only-in fhirpath/terminology tx-service)
         (only-in fhir/serialize/jsexpr-util drop-false)
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/result/result ok? ok-value))

;; A Resolver is (url [version] -> resource | #f): how a canonical becomes a resource — over the
;; packages' indexes, an explicit list of resources, or both.
(define resolver/c (->* (string?) ((or/c string? #f)) (or/c hash? #f)))
(provide
 (contract-out
  [make-terminology (-> path-string? tx-service?)]
  [make-r5-terminology (-> tx-service?)]
  [make-r4-terminology (-> tx-service?)]
  ;; a service over SEVERAL packages, searched in order (an IG first, then its core)
  [make-terminology/packages (-> (listof path-string?) tx-service?)]
  [packages->resolver (-> (listof path-string?) resolver/c)]
  ;; a service over an EXPLICIT list of resources (the tx-ecosystem conformance suite
  ;; ships its own CodeSystems/ValueSets as per-suite setup files)
  [make-terminology/resources (-> (listof hash?) tx-service?)]
  [resources->resolver (-> (listof hash?) resolver/c)]
  [make-terminology/resolver (-> resolver/c tx-service?)]
  ;; operations beyond the tx-service handle's three closures, used by the conformance
  ;; harness (and available to any caller): CodeSystem $lookup and CodeSystem-level
  ;; $validate-code — each takes the resolver and gives the operation as a procedure
  [make-lookup (-> resolver/c procedure?)]
  [make-cs-validate (-> resolver/c procedure?)]
  ;; server-level version parameters (system-version / force- / check-): canonicals with
  ;; |version, given singly or as lists
  [no-version-policy version-policy?]
  [policy-of (-> any/c any/c any/c version-policy?)]
  ;; a ValueSet whose compose names a code system the resolver cannot see is UNDECIDABLE
  ;; offline — the conformance harness skips such cases instead of guessing
  [make-undecidable? (-> resolver/c procedure?)]
  ;; the subsumption relation two codes of a system stand in (for $closure)
  [closure-relation (->* (resolver/c string? string? string?) ((or/c string? #f)) (or/c string? #f))]
  ;; the CodeSystems a package list holds, and what a server publishes about all this
  [packages->code-systems (-> (listof path-string?) (listof hash?))]
  [terminology-capabilities (->* ((listof hash?)) (#:url (or/c string? #f)) hash?)])
 (struct-out version-policy)
 ;; the same operations as FHIR JSON (no type tower needed), for terminology/operations:
 ;; resolver url ... -> ValueSet | Parameters jsexpr
 (rename-out [tx-expand expand/json] [tx-validate validate-code/json]
             [tx-lookup lookup/json] [tx-translate translate/json]
             [tx-cs-validate cs-validate-code/json] [tx-subsumes subsumes/json]
             [tx-find-matches find-matches/json]))

(define r5-core-tgz (spec-package-path "hl7.fhir.r5.core.tgz"))
(define r4-core-tgz (spec-package-path "hl7.fhir.r4.core.tgz"))

;; ---- loading / indexing ---------------------------------------------------------------------

;; a resource file we care about; the prefix filter skips the thousands of other files cheaply.
(define tx-file-rx #px"^package/(CodeSystem|ValueSet|ConceptMap)-.*\\.json$")

;; a core .tgz -> a VERSIONED index: url -> (listof jsexpr resource), so several versions of the
;; same canonical coexist (streamed gunzip -> untar, no disk extract).
(define (load-index tgz-path)
  (define table (make-hash))
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate
    (thread (lambda ()
              (call-with-input-file tgz-path (lambda (gz) (gunzip-through-ports gz pout)))
              (close-output-port pout))))
  (untar pin
         #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define bytes (if (= size 0) #"" (read-bytes size content)))  ; always consume `size`
             (when (regexp-match? tx-file-rx (path->string name))
               (define js (bytes->jsexpr bytes))
               (define url (and (hash? js) (hash-ref js 'url #f)))
               (when (string? url) (hash-update! table url (lambda (l) (cons js l)) '()))))
           '()))
  (thread-wait inflate)
  table)

;; ---- versioned canonical resolution ----------------------------------------------------------
;; A canonical may carry `|version`, and a request may pin one (systemVersion / valueSetVersion).
;; Resolution order: exact version, then a resource that states no version, then the LATEST
;; (highest version string). #f when the url is unknown or the pinned version is absent.
(define (index-resolve table url [version #f])
  (define-values (base inline-version) (split-canonical url))
  (define v (or version inline-version))
  (define candidates (hash-ref table base '()))
  (cond
    [(null? candidates) #f]
    ;; a pinned version may be a PATTERN with `x` wildcards ("1.x.x" matches 1.0.0 and 1.2.0)
    [v (or (for/or ([r (in-list candidates)]) (and (equal? (jref r 'version) v) r))
           (for/or ([r (in-list candidates)]) (and (version-matches? (jref r 'version) v) r)))]
    [else (or (for/or ([r (in-list candidates)]) (and (not (jref r 'version)) r))
              (car (sort candidates string>? #:key (lambda (r) (or (jref r 'version) "")))))]))

(define (wildcard-version? v)
  (and (string? v) (for/or ([seg (in-list (string-split v "."))]) (string-ci=? seg "x"))))

;; does a concrete version satisfy a (possibly wildcarded) pattern? "1.0.0" vs "1.x.x" -> #t
(define (version-matches? actual pattern)
  (and (string? actual) (string? pattern)
       (let ([a (string-split actual ".")] [p (string-split pattern ".")])
         (and (= (length a) (length p))
              (for/and ([x (in-list a)] [y (in-list p)])
                (or (string-ci=? y "x") (equal? x y)))))))

;; "http://x|2.0.0" -> (values "http://x" "2.0.0")
(define (split-canonical url)
  (define m (regexp-match #px"^([^|]*)\\|(.*)$" url))
  (if m (values (cadr m) (caddr m)) (values url #f)))

;; ---- small jsexpr helpers -------------------------------------------------------------------


;; ---- $expand --------------------------------------------------------------------------------

;; a member is (vector system code display version) — the VERSION matters: a compose.include may
;; pin a CodeSystem version, and validation of a versioned Coding must compare against it.
;; Expand a ValueSet url -> (listof member), applying
;; compose.include minus compose.exclude. An IMPLICIT VCL url (http://fhir.org/VCL?v1=...,
;; https://build.fhir.org/ig/FHIR/ig-guidance/vcl.html) synthesizes its ValueSet from the
;; percent-decoded expression -- the spec says processors SHALL percent-decode before interpreting.
(define (expand-members resource url [vs-version #f] [policy no-version-policy] [visited '()])
  (define vs (or (resource url vs-version) (implicit-vcl-valueset url)))
  (cond
    [(not vs) '()]
    [(member url visited) '()]            ; a value set that includes itself, however indirectly
    [else
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
          (define ms (include-members resource inc policy seen))
          (if keep-inactive? ms
              (let ([cs (let ([sys (jref inc 'system)]) (and (string? sys) (resource sys)))])
                (filter (lambda (m) (not (inactive-concept? cs (vector-ref m 1)))) ms))))
        (define included (append-map members (jlist compose 'include)))
        (define excluded (append-map members (jlist compose 'exclude)))
        (define ex-keys (for/hash ([m (in-list excluded)]) (values (member-key m) #t)))
        (dedup (filter (lambda (m) (not (hash-ref ex-keys (member-key m) #f))) included))])]))

;; expansion.contains (nested) -> members
(define (contains->members entries)
  (append-map (lambda (e)
                (cons (vector (jref e 'system) (jref e 'code) (jref e 'display) (jref e 'version))
                      (contains->members (jlist e 'contains))))
              entries))

;; expansions are memoised per resolver: a resolver over packages lives as long as the packages,
;; and the operations rebuild the one over a data source per request, so neither goes stale
(define expansion-caches (make-weak-hasheq))
(define (expand-members/cached resource url vs-version policy)
  (define cache (hash-ref! expansion-caches resource make-hash))
  (hash-ref! cache (list url vs-version policy)
             (lambda () (expand-members resource url vs-version policy))))

;; the spec's implicit-ValueSet form: decode ?v1= and compile the VCL expression to a compose
(define (implicit-vcl-valueset url)
  (define m (regexp-match #px"^https?://fhir\\.org/VCL\\?v1=(.*)$" url))
  (and m
       (let ([r (vcl->compose (uri-decode (cadr m)))])
         (and (ok? r) (hasheq 'resourceType "ValueSet" 'url url 'compose (ok-value r))))))

;; a compose.include/exclude entry -> (listof member): its explicit `concept`s, else the whole
;; CodeSystem named by `system`, else (system-less / valueSet-only) nothing.
(define (include-members resource inc [policy no-version-policy] [visited '()])
  (define system (jref inc 'system))
  ;; compose.include.valueSet: with a system, the include is narrowed to the codes in ALL the
  ;; named value sets; without one, it is their intersection (ValueSet.compose.include.valueSet)
  (define vs-lists
    (for/list ([u (in-list (jlist inc 'valueSet))])
      (expand-members resource u #f policy visited)))
  (define vs-sets
    (for/list ([ms (in-list vs-lists)])
      (for/hash ([m (in-list ms)]) (values (list (vector-ref m 0) (vector-ref m 1)) #t))))
  (define (in-all? m)
    (for/and ([s (in-list vs-sets)]) (hash-ref s (list (vector-ref m 0) (vector-ref m 1)) #f)))
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
  (define pinned (or forced (jref inc 'version) defaulted))
  (define concepts (jlist inc 'concept))
  (define filters (jlist inc 'filter))
  (define cs (and (string? system) (resource system pinned)))
  ;; a WILDCARD pin ("1.x.x") means the ValueSet accepts any matching version, so the pattern —
  ;; not the one concrete version we happened to resolve — is what a Coding is checked against
  (define version (if (wildcard-version? pinned) pinned (and cs (jref cs 'version))))
  (cond
    ;; a pinned version that does not resolve contributes nothing
    [(and pinned (not cs)) '()]
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
       (vector system (jref c 'code)
               (or (jref c 'display)
                   (and known (jref (hash-ref known (jref c 'code) (hasheq)) 'display)))
               version))]
    [(and (string? system) (pair? filters))
     ;; compose.include.filter: every filter must hold (AND), evaluated over the CodeSystem
     (for/list ([c (in-list (all-concepts (jlist cs 'concept)))]
                #:when (for/and ([f (in-list filters)]) (concept-passes? cs c f)))
       (vector system (jref c 'code) (jref c 'display) version))]
    [(string? system)
     (for/list ([c (in-list (all-concepts (jlist cs 'concept)))])
       (vector system (jref c 'code) (jref c 'display) version))]
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
                         (and v rx (regexp-match? rx v)))]
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

;; the value a filter's `property` names on a concept: the concept's own code/display, else the
;; matching CodeSystem property value
(define (concept-value cs concept prop)
  (cond
    [(equal? prop "concept") (jref concept 'code)]
    [(equal? prop "code") (jref concept 'code)]
    [(equal? prop "display") (jref concept 'display)]
    [else
     (for/or ([p (in-list (jlist concept 'property))]
              #:when (equal? (jref p 'code) prop))
       (or (jref p 'valueCode) (jref p 'valueString) (jref p 'valueCoding)
           (let ([b (jref p 'valueBoolean)]) (and (boolean? b) (if b "true" "false")))
           (let ([i (jref p 'valueInteger)]) (and i (number->string i)))))]))

;; ---- per-CodeSystem concept index ------------------------------------------------------------
;; A CsIndex is (csix by-code parent children): code -> concept, code -> parent code (#f at a
;; root), code -> (listof child code) in tree order. Built once per CodeSystem resource and kept
;; on it weakly, so a lookup or a hierarchy test is O(1) instead of a walk of the whole tree.
(struct csix (by-code parent children))
(define cs-indexes (make-weak-hasheq))
(define (cs-index cs)
  (hash-ref! cs-indexes cs
             (lambda ()
               (define by-code (make-hash))
               (define parent (make-hash))
               (define children (make-hash))
               (let walk ([concepts (jlist cs 'concept)] [par #f])
                 (for ([c (in-list concepts)])
                   (define code (jref c 'code))
                   (unless (hash-has-key? by-code code)
                     (hash-set! by-code code c)
                     (hash-set! parent code par))
                   (when par (hash-update! children par (lambda (l) (append l (list code))) '()))
                   (walk (jlist c 'concept) code)))
               (csix by-code parent children))))

;; the concept with `code` anywhere in a CodeSystem's (nested) concept tree
(define (find-concept cs code)
  (and cs (hash-ref (csix-by-code (cs-index cs)) code #f)))

;; is `code` a DIRECT child of `parent`?
(define (child-of? cs code parent)
  (and cs (equal? (hash-ref (csix-parent (cs-index cs)) code #f) parent)))

;; is `code` a proper descendant of `ancestor` in the CodeSystem's nested concept tree?
(define (descendant-of? cs code ancestor)
  (and cs
       (let ([parent (csix-parent (cs-index cs))])
         (let loop ([c (hash-ref parent code #f)])
           (cond [(not c) #f]
                 [(equal? c ancestor) #t]
                 [else (loop (hash-ref parent c #f))])))))

;; a concept with no children
(define (leaf-concept? cs code)
  (and cs (null? (hash-ref (csix-children (cs-index cs)) code '()))))

;; a concept the CodeSystem marks not-active (property `status` retired/deprecated/inactive, or
;; a boolean `inactive` property)
(define (inactive-concept? cs code)
  (define c (find-concept cs code))
  (and c (for/or ([p (in-list (jlist c 'property))])
           (case (jref p 'code)
             [("status") (member (jref p 'valueCode) '("retired" "deprecated" "inactive"))]
             [("inactive") (eq? (jref p 'valueBoolean) #t)]
             [else #f]))
       #t))

;; flatten a CodeSystem concept tree (concepts may nest via `concept`).
(define (all-concepts concepts)
  (append-map (lambda (c) (cons c (all-concepts (jlist c 'concept)))) concepts))

;; system+code+VERSION: two versions of one system are distinct members (the `overload` suite
;; expects both), and an exclusion pinned to one version must not remove the others
(define (member-key m) (list (vector-ref m 0) (vector-ref m 1) (vector-ref m 3)))
(define (dedup ms)
  (let loop ([ms ms] [seen (hash)] [acc '()])
    (cond
      [(null? ms) (reverse acc)]
      [(hash-ref seen (member-key (car ms)) #f) (loop (cdr ms) seen acc)]
      [else (loop (cdr ms) (hash-set seen (member-key (car ms)) #t) (cons (car ms) acc))])))

;; $expand with the operation's parameters (https://hl7.org/fhir/valueset-operation-expand.html).
;; `params` is a hash of parameter-name -> value:
;;   offset/count           page the member list (expansion.offset/.total describe the WHOLE set)
;;   activeOnly             drop concepts the CodeSystem marks inactive
;;   filter                 case-insensitive substring over code and display
;;   displayLanguage        prefer the designation in that language for `display`
;;   includeDesignations    emit contains.designation
;;   property               emit contains.property for the named properties
;; `excludeNested` is accepted and ignored: our expansion is already flat, which is what it asks for.
(define (tx-expand resource url [vs-version #f] [params (hash)] [policy no-version-policy])
  (define (p name [d #f]) (hash-ref params name d))
  (define all (expand-members/cached resource url vs-version policy))
  (define active (if (eq? (p "activeOnly") #t) (filter (lambda (m) (member-active? resource m)) all) all))
  (define filtered
    (let ([f (p "filter")])
      (if (and (string? f) (positive? (string-length f)))
          (filter (lambda (m) (member-matches-filter? m f)) active)
          active)))
  (define total (length filtered))
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
  (values
   (hasheq 'resourceType "ValueSet"
           'url url
           'expansion
           (drop-false
            (hasheq 'total total
                    'offset (and (> offset 0) offset)
                    'contains contains)))))

;; nest each entry under its parent concept when that parent is also in the expansion
(define (nest-contains resource members entries)
  (define by-code (for/hash ([m (in-list members)] [e (in-list entries)])
                    (values (vector-ref m 1) e)))
  (define parent-of                       ; code -> parent code, from the CodeSystem's tree
    (for/fold ([h (hash)]) ([m (in-list members)])
      (define cs (resource (vector-ref m 0) (vector-ref m 3)))
      (define par (and cs (hash-ref (csix-parent (cs-index cs)) (vector-ref m 1) #f)))
      (if par (hash-set h (vector-ref m 1) par) h)))
  (define present (for/hash ([m (in-list members)]) (values (vector-ref m 1) #t)))
  ;; build bottom-up: a child is attached to its parent's entry
  (define children                        ; parent code -> (listof child code), in member order
    (for/fold ([h (hash)]) ([m (in-list members)])
      (define code (vector-ref m 1))
      (define par (hash-ref parent-of code #f))
      (if (and par (hash-ref present par #f))
          (hash-update h par (lambda (l) (append l (list code))) '())
          h)))
  (define (build code)
    (define e (hash-ref by-code code))
    (define kids (hash-ref children code '()))
    (if (null? kids) e (hash-set e 'contains (for/list ([k (in-list kids)]) (build k)))))
  (for/list ([m (in-list members)]
             #:unless (let ([par (hash-ref parent-of (vector-ref m 1) #f)])
                        (and par (hash-ref present par #f))))
    (build (vector-ref m 1))))

;; one expansion member -> a contains entry, honouring displayLanguage / includeDesignations /
;; property
(define (member->contains resource m params)
  (define (p name [d #f]) (hash-ref params name d))
  (define cs (resource (vector-ref m 0) (vector-ref m 3)))
  (define concept (and cs (find-concept cs (vector-ref m 1))))
  (define lang (p "displayLanguage"))
  (define-values (sup-designations sup-properties)
    (supplement-parts resource (p "useSupplement") (vector-ref m 1)))
  (define designations (append (if concept (jlist concept 'designation) '()) sup-designations))
  (define properties (append (if concept (jlist concept 'property) '()) sup-properties))
  (define display
    (or (and lang (for/or ([d (in-list designations)])
                    (and (equal? (jref d 'language) lang) (jref d 'value))))
        (vector-ref m 2)))
  (drop-false
   (hasheq 'system (vector-ref m 0)
           'version (vector-ref m 3)
           'code (vector-ref m 1)
           'display display
           'designation (and (eq? (p "includeDesignations") #t) (pair? designations)
                             (for/list ([d (in-list designations)])
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
  (define cs (resource (vector-ref m 0) (vector-ref m 3)))
  (not (inactive-concept? cs (vector-ref m 1))))

;; the filter parameter is a case-insensitive substring match over code and display
(define (member-matches-filter? m f)
  (define needle (string-downcase f))
  (define (has? s) (and (string? s) (regexp-match? (regexp (regexp-quote needle))
                                                   (string-downcase s))))
  (or (has? (vector-ref m 1)) (has? (vector-ref m 2))))

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
(struct version-policy (default force check) #:transparent)
(define no-version-policy (version-policy (hash) (hash) (hash)))

;; "http://sys|1.0.x" -> (cons system version); anything else -> #f
(define (parse-versioned-canonical s)
  (define m (and (string? s) (regexp-match #px"^([^|]+)[|](.+)$" s)))
  (and m (cons (cadr m) (caddr m))))

(define (policy-of default-vs force-vs check-vs)
  (define (->hash vs)
    (for/fold ([h (hash)]) ([v (in-list (if (list? vs) vs (if vs (list vs) '())))])
      (define p (parse-versioned-canonical (format "~a" v)))
      (if p (hash-set h (car p) (cdr p)) h)))
  (version-policy (->hash default-vs) (->hash force-vs) (->hash check-vs)))

(define (tx-validate resource url [code #f] [system #f]
                     #:coding [coding #f] #:codeable-concept [cc #f]
                     #:display [display #f] #:lenient-display? [lenient? #f]
                     #:system-version [system-version #f] #:valueset-version [vs-version #f]
                     #:policy [policy no-version-policy])
  (define codings
    (cond [cc (jlist cc 'coding)]
          [coding (list coding)]
          [code (list (drop-false (hasheq 'system system 'code code 'display display)))]
          [else '()]))
  (define members (expand-members/cached resource url vs-version policy))
  ;; the first coding that is a member wins; otherwise report against the first coding
  (define checks (for/list ([c (in-list codings)])
                   (check-coding resource members c lenient? system-version policy)))
  ;; A coding naming an unknown CODE in a system we KNOW is an ERROR, and an error anywhere makes
  ;; the whole CodeableConcept invalid — even when a sibling coding is a member (proven by the
  ;; suite's bad-cc2 cases). "Not a member" and "unknown system" are not errors in that sense.
  (define error-check (for/or ([r (in-list checks)]) (and (hash-ref r 'error? #f) r)))
  (define valid-check (for/or ([r (in-list checks)]) (and (hash-ref r 'ok #f) r)))
  ;; the VERDICT comes from the error (if any), but the reported code/system/display describe the
  ;; coding that actually validated — the reference echoes the resolvable one
  (define outcome
    (cond
      [(and error-check valid-check)
       (hash-set* valid-check 'ok #f 'message (hash-ref error-check 'message #f))]
      [error-check error-check]
      [valid-check valid-check]
      [(pair? checks) (car checks)]
      [else (hasheq 'ok #f 'message "no code supplied")]))
  (values
   (hasheq 'resourceType "Parameters"
           'parameter
           (filter values
                   (list (hasheq 'name "result" 'valueBoolean (and (hash-ref outcome 'ok #f) #t))
                         (let ([c (hash-ref outcome 'code #f)])
                           (and c (hasheq 'name "code" 'valueCode c)))
                         (let ([s (hash-ref outcome 'system #f)])
                           (and s (hasheq 'name "system" 'valueUri s)))
                         (let ([d (hash-ref outcome 'display #f)])
                           (and d (hasheq 'name "display" 'valueString d)))
                         (let ([m (hash-ref outcome 'message #f)])
                           (and m (hasheq 'name "message" 'valueString m))))))))

;; one coding -> a hash of (ok? code system display message): membership first, then display
(define (check-coding resource members c lenient? [system-version #f] [policy no-version-policy])
  (define code (jref c 'code))
  (define system (jref c 'system))
  (define stated (jref c 'version))
  (define forced (and system (hash-ref (version-policy-force policy) system #f)))
  (define checked (and system (hash-ref (version-policy-check policy) system #f)))
  (define defaulted (and system (hash-ref (version-policy-default policy) system #f)))
  ;; force overrides what the Coding says; otherwise the stated version, else the request's
  ;; systemVersion, else the server default
  (define version (or forced stated system-version defaulted))
  (define supplied-display (jref c 'display))
  ;; a stated VERSION must resolve: the CodeSystem at that version must exist, else the coding is
  ;; invalid however well its code matches (the suite's `bad-version` cases)
  (define cs (and system (resource system version)))
  (define member?
    (and (or (not version) cs)
         (for/or ([m (in-list members)])
           (and (equal? (vector-ref m 1) code)
                (or (not system) (not (vector-ref m 0)) (equal? (vector-ref m 0) system))
                ;; when BOTH the coding and the expansion state a version, they must agree
                (or (not version) (not (vector-ref m 3))
                    (equal? version (vector-ref m 3))
                    (version-matches? version (vector-ref m 3)))
                m))))
  (define concept (and cs (find-concept cs code)))
  (define official (or (and concept (jref concept 'display))
                       (and member? (vector-ref member? 2))))
  (cond
    ;; check-system-version: a Coding that states a DIFFERENT version than the server requires
    [(and checked stated (not (equal? stated checked)) (not (version-matches? stated checked)))
     (hasheq 'ok #f 'error? #t 'code code 'system system
             'message (format "Version '~a' does not match the required '~a'" stated checked))]
    [(and version (not cs))
     (hasheq 'ok #f 'code code 'system system
             'message (format "Unknown version '~a' of code system '~a'" version system))]
    ;; the system is known AND COMPLETE but the code is not in it: an error, not merely a
    ;; non-member. A `fragment`/`not-present`/`example` CodeSystem does not list every code, so an
    ;; absent code there decides nothing.
    [(and cs (not concept) (complete-codesystem? cs))
     (hasheq 'ok #f 'error? #t 'code code 'system system
             'message (format "Unknown code '~a' in the CodeSystem '~a'" code system))]
    [(not member?)
     (hasheq 'ok #f 'code code 'system system
             'message (format "The code '~a' is not in the value set" code))]
    [(and supplied-display (not (display-matches? concept official supplied-display)))
     ;; a wrong display: an error, or a warning under lenient-display-validation
     (hasheq 'ok (and lenient? #t) 'code code 'system system 'display official
             'message (format "Wrong Display Name '~a'~a" supplied-display
                              (if official (format ", should be '~a'" official) "")))]
    [else (hasheq 'ok #t 'code code 'system system 'display official)]))

;; only a CodeSystem that claims to enumerate every code can prove a code does NOT exist
(define (complete-codesystem? cs)
  (member (jref cs 'content) '("complete" "supplement")))

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

;; ---- $lookup (CodeSystem) --------------------------------------------------------------------
;; https://hl7.org/fhir/codesystem-operation-lookup.html — the concept's name/display plus its
;; designations and properties.
(define (tx-lookup resource system code [version #f] #:supplements [supplements '()])
  (define cs (resource system version))
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
  (define cs (resource sys v))
  (define concept (and cs (find-concept cs c)))
  (define official (and concept (jref concept 'display)))
  (define outcome
    (cond
      [(not cs) (hasheq 'ok #f 'message (format "Unknown code system '~a'" sys))]
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
                 (for/list ([m (in-list matches)])
                   (hasheq 'name "match"
                           'part
                           (list (drop-false (hasheq 'name "relationship" 'valueCode (vector-ref m 0)))
                                 (hasheq 'name "concept"
                                         'valueCoding
                                         (drop-false (hasheq 'system (vector-ref m 1)
                                                             'code (vector-ref m 2)
                                                             'display (vector-ref m 3)))))))))))

;; ---- result construction --------------------------------------------------------------------

;; drop keys whose value is #f (absent optional fields) so from-json doesn't try to parse them.

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

;; packages->resolver : (listof tgz) -> resolver   each package indexed lazily, first match wins
;; one lazily built index per package file, shared by every resolver over it
(define package-indexes (make-hash))
(define (index-of tgz)
  (hash-ref! package-indexes (path->string (simplify-path (path->complete-path tgz)))
             (lambda () (delay (load-index tgz)))))

(define (packages->resolver tgzs)
  (define indexes (map index-of tgzs))
  (lambda (url [version #f])
    (for/or ([ix (in-list indexes)]) (index-resolve (force ix) url version))))

;; packages->code-systems : (listof tgz) -> (listof CodeSystem jsexpr)   every CodeSystem they hold
(define (packages->code-systems tgzs)
  (for*/list ([t (in-list tgzs)]
              [(url rs) (in-hash (force (index-of t)))]
              [r (in-list rs)]
              #:when (equal? (jref r 'resourceType) "CodeSystem"))
    r))
(define (make-terminology/packages tgzs) (make-terminology/resolver (packages->resolver tgzs)))

;; a service over an explicit LIST of resources (the conformance suite's per-suite setup files);
;; indexed the same versioned way as a package
;; resources -> a versioned RESOLVER (url [version] -> resource|#f). Exposed so a caller can build
;; the CodeSystem-level operations (make-lookup / make-cs-validate) over the same index.
(define (resources->resolver resources)
  (define table (make-hash))
  (for ([r (in-list resources)] #:when (string? (jref r 'url)))
    (hash-update! table (jref r 'url) (lambda (l) (cons r l)) '()))
  (lambda (url [version #f]) (index-resolve table url version)))

(define (make-terminology/resources resources)
  (make-terminology/resolver (resources->resolver resources)))

(define (make-terminology/resolver resource)
  (tx-service (lambda (url [vs-version #f] [params (hash)] [policy no-version-policy] . _)
                (node (tx-expand resource url vs-version params policy)))
              (make-validate resource)
              (lambda (url code . rest) (node (apply tx-translate resource url code rest)))))

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
            (and (or (not (string? sys)) (not (resource sys)))   ; probe WITHOUT a version pin
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
