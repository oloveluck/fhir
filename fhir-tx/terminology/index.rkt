#lang racket/base

;;; index.rkt — the terminology service's view of its sources: packages and resources indexed by
;;; canonical, versioned resolution, and one CodeSystem's concepts as a tree you can ask questions of.
;;;
;;; Data definitions
;;;   A Resolver is (url [version] -> resource | #f): how a canonical becomes a resource — over the
;;;   packages' indexes, an explicit list of resources, or both (resolver/c).
;;;   An Index is (hash url -> (listof resource)): every version of a canonical, newest resolved
;;;   last (index-resolve picks exact, then unversioned, then the latest).
;;;   A CsIndex is (csix by-code parent children) over one CodeSystem's nested `concept` tree:
;;;   code -> concept, code -> parent code (#f at a root), code -> (listof child code) in order.
;;;   A Member is (make-member system code display version) — one concept in an expansion; the
;;;   VERSION matters: a compose.include may pin a CodeSystem version, and validation of a versioned
;;;   Coding must compare against it. (Represented as a vector; only the accessors read it.)

(require racket/contract racket/list racket/string racket/promise
         json file/gunzip file/untar
         (only-in fhir/serialize/jsexpr-util jref jlist))

(provide resolver/c
         (contract-out
          [packages->resolver (-> (listof path-string?) resolver/c)]
          [resources->resolver (-> (listof hash?) resolver/c)]
          [packages->code-systems (-> (listof path-string?) (listof hash?))]
          [make-member (-> any/c any/c any/c any/c member?)]
          [member? (-> any/c boolean?)])
         member-system member-code member-display member-version member-key dedup
         index-resolve version-matches? wildcard-version? split-canonical
         cs-index csix-by-code csix-parent csix-children
         find-concept child-of? descendant-of? leaf-concept? inactive-concept? all-concepts
         complete-codesystem? concept-value)

;; ---- Member ---------------------------------------------------------------------------------
(define (make-member system code display version) (vector system code display version))
(define (member? x) (and (vector? x) (= (vector-length x) 4)))
(define (member-system m) (vector-ref m 0))
(define (member-code m) (vector-ref m 1))
(define (member-display m) (vector-ref m 2))
(define (member-version m) (vector-ref m 3))

;; A Resolver is (url [version] -> resource | #f): how a canonical becomes a resource — over the
;; packages' indexes, an explicit list of resources, or both.
(define resolver/c (->* (string?) ((or/c string? #f)) (or/c hash? #f)))

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
(define (member-key m) (list (member-system m) (member-code m) (member-version m)))
(define (dedup ms)
  (let loop ([ms ms] [seen (hash)] [acc '()])
    (cond
      [(null? ms) (reverse acc)]
      [(hash-ref seen (member-key (car ms)) #f) (loop (cdr ms) seen acc)]
      [else (loop (cdr ms) (hash-set seen (member-key (car ms)) #t) (cons (car ms) acc))])))

;; only a CodeSystem that claims to enumerate every code can prove a code does NOT exist
(define (complete-codesystem? cs)
  (and (member (jref cs 'content) '("complete" "supplement")) #t))

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

;; a service over an explicit LIST of resources (the conformance suite's per-suite setup files);
;; indexed the same versioned way as a package
;; resources -> a versioned RESOLVER (url [version] -> resource|#f). Exposed so a caller can build
;; the CodeSystem-level operations (make-lookup / make-cs-validate) over the same index.
(define (resources->resolver resources)
  (define table (make-hash))
  (for ([r (in-list resources)] #:when (string? (jref r 'url)))
    (hash-update! table (jref r 'url) (lambda (l) (cons r l)) '()))
  (lambda (url [version #f]) (index-resolve table url version)))

;; ---- living examples ----------------------------------------------------------------------------
(module+ test
  (require rackunit (only-in fhir/spec-package spec-package-path))
  (check-true (version-matches? "1.0.0" "1.x.x")) (check-false (version-matches? "2.0.0" "1.x.x"))
  (check-true (wildcard-version? "1.x")) (check-false (wildcard-version? "1.0"))
  (let-values ([(u v) (split-canonical "http://x|2.0")]) (check-equal? (list u v) '("http://x" "2.0")))
  (let-values ([(u v) (split-canonical "http://x")]) (check-equal? (list u v) '("http://x" #f)))
  ;; versioned resolution: exact, then unversioned, then the latest; a wildcard pin
  (define (cs v . concepts) (hasheq 'resourceType "CodeSystem" 'url "http://x/cs" 'version v 'content "complete" 'concept concepts))
  (define (c code . kids) (hasheq 'code code 'display (string-upcase code) 'concept kids))
  (define v1 (cs "1.0.0" (c "a" (c "b" (c "c")))))
  (define v2 (cs "2.0.0" (c "a")))
  (define unversioned (hash-remove (cs "x" (c "z")) 'version))
  (define r (resources->resolver (list v1 v2)))
  (check-equal? (r "http://x/cs") v2)
  (check-equal? (r "http://x/cs" "1.0.0") v1)
  (check-equal? (r "http://x/cs|1.0.0") v1)
  (check-equal? (r "http://x/cs" "1.x.x") v1)
  (check-false (r "http://x/cs" "3.0.0"))
  (check-false (r "http://nope"))
  (check-equal? ((resources->resolver (list v1 unversioned)) "http://x/cs") unversioned)
  ;; the concept tree
  (check-equal? (map (lambda (x) (jref x 'code)) (all-concepts (jlist v1 'concept))) '("a" "b" "c"))
  (check-equal? (jref (find-concept v1 "c") 'display) "C")
  (check-false (find-concept v1 "q"))
  (check-true (descendant-of? v1 "c" "a")) (check-false (descendant-of? v1 "a" "c"))
  (check-true (child-of? v1 "b" "a")) (check-false (child-of? v1 "c" "a"))
  (check-true (leaf-concept? v1 "c")) (check-false (leaf-concept? v1 "a"))
  (check-equal? (hash-ref (csix-children (cs-index v1)) "a") '("b"))
  (check-true (complete-codesystem? v1))
  (check-false (complete-codesystem? (hash-set v1 'content "fragment")))
  (define retired (hasheq 'code "r" 'property (list (hasheq 'code "status" 'valueCode "retired"))))
  (define with-retired (cs "9" retired (c "ok")))
  (check-true (inactive-concept? with-retired "r")) (check-false (inactive-concept? with-retired "ok"))
  (check-equal? (concept-value with-retired retired "status") "retired")
  (check-equal? (concept-value with-retired retired "concept") "r")
  (check-false (concept-value with-retired retired "nope"))
  ;; Members: equal by system, code AND version
  (define m1 (make-member "http://x/cs" "a" "A" "1.0.0"))
  (check-true (member? m1)) (check-equal? (member-code m1) "a") (check-equal? (member-version m1) "1.0.0")
  (check-equal? (dedup (list m1 (make-member "http://x/cs" "a" "other display" "1.0.0") (make-member "http://x/cs" "a" "A" "2.0.0")))
                (list m1 (make-member "http://x/cs" "a" "A" "2.0.0")))
  ;; a package index, when fhir-spec is there: the R5 core's administrative-gender
  (define core (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t))
  (when core
    (define pr (packages->resolver (list core)))
    (check-equal? (jref (pr "http://hl7.org/fhir/ValueSet/administrative-gender") 'resourceType) "ValueSet")
    (check-equal? (jref (pr "http://hl7.org/fhir/administrative-gender") 'resourceType) "CodeSystem")
    (check-true (pair? (packages->code-systems (list core))))))
