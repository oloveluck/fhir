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
;;; `make-terminology` returns a `tx-service` (fhir/fhirpath/terminology) whose three closures the
;;; FHIRPath engine dispatches on as the `%terminologies` handle.

(require json
         file/gunzip
         file/untar
         (only-in net/uri-codec uri-decode)
         (only-in "../vcl/compile.rkt" vcl->compose)
         racket/list
         racket/string
         racket/promise
         racket/runtime-path
         (only-in "../fhirpath/terminology.rkt" tx-service)
         (only-in "../serialize/jsexpr-util.rkt" drop-false)
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../result/result.rkt" ok? ok-value))

(provide make-terminology make-r5-terminology make-r4-terminology
         ;; a service over an EXPLICIT list of resources (the tx-ecosystem conformance suite
         ;; ships its own CodeSystems/ValueSets as per-suite setup files)
         make-terminology/resources resources->resolver make-terminology/resolver
         ;; operations beyond the tx-service handle's three closures, used by the conformance
         ;; harness (and available to any caller): CodeSystem $lookup and CodeSystem-level
         ;; $validate-code
         make-lookup make-cs-validate
         ;; server-level version parameters (system-version / force- / check-)
         (struct-out version-policy) no-version-policy policy-of
         ;; a ValueSet whose compose names a code system the resolver cannot see is UNDECIDABLE
         ;; offline — the conformance harness skips such cases instead of guessing
         make-undecidable?)

(define-runtime-path r5-core-tgz "../spec/hl7.fhir.r5.core.tgz")
(define-runtime-path r4-core-tgz "../spec/hl7.fhir.r4.core.tgz")

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

(define (jref h k [d #f]) (if (hash? h) (hash-ref h k d) d))
(define (jlist h k) (let ([v (jref h k '())]) (if (list? v) v '())))

;; ---- $expand --------------------------------------------------------------------------------

;; a member is (vector system code display version) — the VERSION matters: a compose.include may
;; pin a CodeSystem version, and validation of a versioned Coding must compare against it.
;; Expand a ValueSet url -> (listof member), applying
;; compose.include minus compose.exclude. An IMPLICIT VCL url (http://fhir.org/VCL?v1=...,
;; https://build.fhir.org/ig/FHIR/ig-guidance/vcl.html) synthesizes its ValueSet from the
;; percent-decoded expression -- the spec says processors SHALL percent-decode before interpreting.
(define (expand-members resource url [vs-version #f] [policy no-version-policy])
  (define vs (or (resource url vs-version) (implicit-vcl-valueset url)))
  (cond
    [(not vs) '()]
    [else
     (define compose (jref vs 'compose))
     ;; compose.inactive = false drops concepts the CodeSystem marks inactive/deprecated/retired.
     ;; ABSENT means "no constraint" — distinguish it from an explicit false (jref defaults to #f).
     (define keep-inactive? (not (eq? (jref compose 'inactive 'absent) #f)))
     (define (members inc)
       (define ms (include-members resource inc policy))
       (if keep-inactive? ms
           (let ([cs (resource (jref inc 'system))])
             (filter (lambda (m) (not (inactive-concept? cs (vector-ref m 1)))) ms))))
     (define included (append-map members (jlist compose 'include)))
     (define excluded (append-map members (jlist compose 'exclude)))
     (define ex-keys (for/hash ([m (in-list excluded)]) (values (member-key m) #t)))
     (dedup (filter (lambda (m) (not (hash-ref ex-keys (member-key m) #f))) included))]))

;; the spec's implicit-ValueSet form: decode ?v1= and compile the VCL expression to a compose
(define (implicit-vcl-valueset url)
  (define m (regexp-match #px"^https?://fhir\\.org/VCL\\?v1=(.*)$" url))
  (and m
       (let ([r (vcl->compose (uri-decode (cadr m)))])
         (and (ok? r) (hasheq 'resourceType "ValueSet" 'url url 'compose (ok-value r))))))

;; a compose.include/exclude entry -> (listof member): its explicit `concept`s, else the whole
;; CodeSystem named by `system`, else (system-less / valueSet-only) nothing.
(define (include-members resource inc [policy no-version-policy])
  (define system (jref inc 'system))
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
     ;; an enumerated concept must EXIST in the code system (when we can see it) — the suite's
     ;; `enum-bad` case pins that a bogus code does not silently join the expansion
     (define known (and cs (for/hash ([c (in-list (all-concepts (jlist cs 'concept)))])
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
  (define prop (jref f 'property))
  (define op (jref f 'op))
  (define val (or (jref f 'value) ""))
  (define code (jref concept 'code))
  (case op
    [("is-a")          (or (equal? code val) (descendant-of? cs code val))]
    [("descendent-of") (descendant-of? cs code val)]
    [("is-not-a")      (not (or (equal? code val) (descendant-of? cs code val)))]
    [("child-of")      (child-of? cs code val)]
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

;; is `code` a DIRECT child of `parent`?
(define (child-of? cs code parent)
  (define (find concepts)
    (for/or ([c (in-list concepts)])
      (cond [(equal? (jref c 'code) parent) c]
            [else (find (jlist c 'concept))])))
  (define p (find (jlist cs 'concept)))
  (and p (for/or ([d (in-list (jlist p 'concept))]) (equal? (jref d 'code) code))))

;; a concept the CodeSystem marks not-active (property `status` retired/deprecated/inactive, or
;; a boolean `inactive` property)
(define (inactive-concept? cs code)
  (define c (and cs (for/or ([x (in-list (all-concepts (jlist cs 'concept)))])
                      (and (equal? (jref x 'code) code) x))))
  (and c (for/or ([p (in-list (jlist c 'property))])
           (case (jref p 'code)
             [("status") (member (jref p 'valueCode) '("retired" "deprecated" "inactive"))]
             [("inactive") (eq? (jref p 'valueBoolean) #t)]
             [else #f]))
       #t))

;; is `code` a proper descendant of `ancestor` in the CodeSystem's nested concept tree?
(define (descendant-of? cs code ancestor)
  (define (find concepts)
    (for/or ([c (in-list concepts)])
      (cond [(equal? (jref c 'code) ancestor) c]
            [else (find (jlist c 'concept))])))
  (define anc (find (jlist cs 'concept)))
  (and anc (for/or ([d (in-list (all-concepts (jlist anc 'concept)))])
             (equal? (jref d 'code) code))))

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
  (define all (expand-members resource url vs-version policy))
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
  (node
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
      (if cs (hash-union-parents h (jlist cs 'concept) #f) h)))
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

;; walk a CodeSystem concept tree accumulating code -> parent code
(define (hash-union-parents h concepts parent)
  (for/fold ([h (if parent h h)]) ([c (in-list concepts)])
    (define code (jref c 'code))
    (define h1 (if parent (hash-set h code parent) h))
    (hash-union-parents h1 (jlist c 'concept) code)))

;; one expansion member -> a contains entry, honouring displayLanguage / includeDesignations /
;; property
(define (member->contains resource m params)
  (define (p name [d #f]) (hash-ref params name d))
  (define cs (resource (vector-ref m 0) (vector-ref m 3)))
  (define concept (and cs (find-concept cs (vector-ref m 1))))
  (define lang (p "displayLanguage"))
  (define designations (if concept (jlist concept 'designation) '()))
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
                              (let ([ps (for/list ([pr (in-list (jlist concept 'property))]
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
  (define members (expand-members resource url vs-version policy))
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
  (node
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

;; the concept with `code` anywhere in a CodeSystem's (nested) concept tree
(define (find-concept cs code)
  (for/or ([c (in-list (all-concepts (jlist cs 'concept)))])
    (and (equal? (jref c 'code) code) c)))

;; ---- $lookup (CodeSystem) --------------------------------------------------------------------
;; https://hl7.org/fhir/codesystem-operation-lookup.html — the concept's name/display plus its
;; designations and properties.
(define (tx-lookup resource system code [version #f])
  (define cs (resource system version))
  (define concept (and cs (find-concept cs code)))
  (node
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
                    (if concept
                        (for/list ([d (in-list (jlist concept 'designation))])
                          (hasheq 'name "designation"
                                  'part (filter values
                                                (list (and (jref d 'language)
                                                           (hasheq 'name "language" 'valueCode (jref d 'language)))
                                                      (hasheq 'name "value" 'valueString (or (jref d 'value) ""))))))
                        '())
                    (if concept
                        (for/list ([pr (in-list (jlist concept 'property))])
                          (hasheq 'name "property"
                                  'part (list (hasheq 'name "code" 'valueCode (or (jref pr 'code) ""))
                                              (drop-false
                                               (hasheq 'name "value"
                                                       'valueCode (jref pr 'valueCode)
                                                       'valueString (jref pr 'valueString)
                                                       'valueBoolean (jref pr 'valueBoolean))))))
                        '()))))))

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
  (node
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
  (node
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

;; build a jsexpr resource into a typed node -> a one-element FHIRPath collection (or empty on failure)
(define (node js)
  (define r (from-json js #:lenient? #t))
  (if (ok? r) (list (ok-value r)) '()))

;; ---- the service ----------------------------------------------------------------------------

;; make-terminology : core .tgz -> tx-service. The index is loaded once, lazily, on first tx call
;; (by when the caller's type tower is registered). The caller must have the matching tower loaded
;; (require fhir/r5/schemas or fhir/r4/schemas) so the result ValueSet/Parameters nodes build.
(define (make-terminology tgz-path)
  (define index (delay (load-index tgz-path)))
  (define (resource url [version #f]) (index-resolve (force index) url version))
  (tx-service (lambda (url . _)         (tx-expand resource url))
              (make-validate resource)
              (lambda (url code . rest) (apply tx-translate resource url code rest))))

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
                (tx-expand resource url vs-version params policy))
              (make-validate resource)
              (lambda (url code . rest) (apply tx-translate resource url code rest))))

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
(define ((make-lookup resource) system code [version #f]) (tx-lookup resource system code version))
(define ((make-cs-validate resource) system code [version #f]
                                     #:coding [coding #f] #:display [display #f]
                                     #:lenient-display? [lenient? #f])
  (tx-cs-validate resource system code version
                  #:coding coding #:display display #:lenient-display? lenient?))

;; the validate closure accepts BOTH the positional (url code [system]) form its in-repo callers
;; use and the operation's keyword surface (coding / codeableConcept / display / lenient)
(define ((make-validate resource) url [code #f] [system #f]
                                  #:coding [coding #f] #:codeable-concept [cc #f]
                                  #:display [display #f] #:lenient-display? [lenient? #f]
                                  #:system-version [system-version #f] #:valueset-version [vs-version #f]
                                  #:policy [policy no-version-policy])
  (tx-validate resource url code system #:coding coding #:codeable-concept cc
               #:display display #:lenient-display? lenient?
               #:system-version system-version #:valueset-version vs-version
               #:policy policy))

(define (make-r5-terminology) (make-terminology r5-core-tgz))
(define (make-r4-terminology) (make-terminology r4-core-tgz))

;; ---- living examples ------------------------------------------------------------------------

(module+ test
  (require rackunit
           (only-in fhir/r5/schemas)                    ; the R5 tower for building result nodes
           (only-in fhir/fhirpath/parser/parse parse-fhirpath)
           (only-in fhir/fhirpath/eval eval-fhirpath)
           (only-in fhir/fhirpath/value item->system)
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
  (check-equal? (T "%terminologies.translate('http://hl7.org/fhir/ConceptMap/cm-address-use-v2', $this.address.use).parameter.where(name = 'match').part.where(name = 'concept').value.code") '("H")))
