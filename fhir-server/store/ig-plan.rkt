#lang racket/base

;;; ig-plan.rkt — reading an Implementation Guide package as the specification of a server.
;;;
;;; The IG is read, nothing is built: package.json picks the FHIR version (the type tower and the
;;; core package), the IG's server CapabilityStatement (rest.mode = server) says which types, which
;;; interactions, which search parameters and which profiles, and package.json's `dependencies`
;;; name the packages the IG builds on. ig-server.rkt builds the server from the plan.
;;;
;;; Data definitions
;;;   An IgPlan is (ig-plan name version fhir-version tower core-tgz ig-cs resources)
;;;     tower     : the module to instantiate for the FHIR version ('fhir/r4/schemas …)
;;;     core-tgz  : the core package's path
;;;     ig-cs     : the server CapabilityStatement, as jsexpr, with search implied where the IG
;;;                 lists parameters without the interaction (`with-implied-search`)
;;;     resources : (listof IgResource)
;;;   An IgResource is (ig-resource type interactions search-params profiles)
;;;     interactions  : (listof (cons code expectation))   e.g. ("read" . "SHALL")
;;;     search-params : (listof (list name type expectation))
;;;     profiles      : (listof canonical)   the resource's profile and supportedProfiles, unversioned
;;;   An Expectation is "SHALL" | "SHOULD" | "MAY" | "SHOULD-NOT" — the capabilitystatement-expectation
;;;   extension on an element, "MAY" when there is none.

(require racket/contract racket/list racket/string racket/match
         (only-in fhir/package read-package)
         (only-in fhir/spec-package spec-package-path current-package-directories))

(provide
 (struct-out ig-plan) (struct-out ig-resource)
 (contract-out
  [package-manifest     (-> path-string? (or/c hash? #f))]
  [ig-package-path      (-> string? path?)]
  [plan-ig-server       (->* (path-string?) ((or/c string? #f)) ig-plan?)]
  [expectation-of       (-> hash? string?)]
  [server-rest          (-> hash? (or/c hash? #f))]
  [dependency-packages  (-> path-string? (listof path?))]
  [version-matches?     (-> string? string? boolean?)]))

(struct ig-plan (name version fhir-version tower core-tgz ig-cs resources) #:transparent)
(struct ig-resource (type interactions search-params profiles) #:transparent)

(define expectation-url "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation")

;; ---- the package ------------------------------------------------------------------------------

;; package-manifest : path -> jsexpr | #f   the package's package.json
(define (package-manifest tgz) (let-values ([(m _r _e) (read-package tgz #:select (lambda (_) #f))]) m))

;; ig-package-path : "hl7.fhir.us.core" | "x.tgz" | a path -> the package file
(define (ig-package-path s)
  (cond [(file-exists? s) (string->path s)]
        [(regexp-match? #rx"[.]tgz$" s) (spec-package-path s)]
        [else (spec-package-path (string-append s ".tgz"))]))

;; tower-for : fhir-version -> (values tower-module core-package-file)
(define (tower-for v)
  (match v
    [(regexp #rx"^4[.]0") (values 'fhir/r4/schemas "hl7.fhir.r4.core.tgz")]
    [(regexp #rx"^5[.]0") (values 'fhir/r5/schemas "hl7.fhir.r5.core.tgz")]
    [(regexp #rx"^6[.]") (values 'fhir/r6/types "hl7.fhir.r6.core.tgz")]
    [_ (raise-user-error 'fhir "unsupported FHIR version ~a (expected 4.0.x, 5.0.x or 6.x)" v)]))

;; jlist : jsexpr -> list   a field that may be absent or not a list, as a list
(define (jlist x) (if (list? x) x '()))

;; ---- the CapabilityStatement --------------------------------------------------------------------

;; expectation-of : jsexpr -> Expectation   the element's capabilitystatement-expectation, or MAY
(define (expectation-of h)
  (or (for/or ([e (in-list (jlist (hash-ref h 'extension '())))])
        (and (equal? (hash-ref e 'url #f) expectation-url) (hash-ref e 'valueCode #f)))
      "MAY"))

;; server-rest : CapabilityStatement -> rest | #f   its rest entry with mode = server
(define (server-rest cs)
  (findf (lambda (r) (equal? (hash-ref r 'mode #f) "server")) (jlist (hash-ref cs 'rest '()))))

;; server-capability-statement : (listof (cons file jsexpr)) (or/c string #f) -> jsexpr | #f
;; the package's server CapabilityStatement; `capability` chooses one by id or url when the IG
;; ships several (CQF Measures ships four), #f takes the first
(define (server-capability-statement resources capability)
  (for/or ([r (in-list resources)])
    (define js (cdr r))
    (and (equal? (hash-ref js 'resourceType #f) "CapabilityStatement")
         (or (not capability) (equal? (hash-ref js 'id #f) capability) (equal? (hash-ref js 'url #f) capability))
         (server-rest js)
         js)))

;; plan-ig-server : path [capability] -> IgPlan   read the package as the specification of a server
(define (plan-ig-server tgz [capability #f])
  (define-values (manifest resources _examples) (read-package tgz))
  (define fv (let ([vs (and manifest (hash-ref manifest 'fhirVersions #f))])
               (cond [(and (list? vs) (pair? vs)) (car vs)]
                     [else (raise-user-error 'fhir "~a: package.json declares no fhirVersions" tgz)])))
  (define-values (tower core-file) (tower-for fv))
  (define server-cs0 (server-capability-statement resources capability))
  (unless server-cs0
    (raise-user-error 'fhir "~a ships no server CapabilityStatement (rest.mode = server)~a" tgz
                      (if capability (format " with id or url ~a" capability) "")))
  (define server-cs (with-implied-search server-cs0))
  (ig-plan (and manifest (hash-ref manifest 'name #f)) (and manifest (hash-ref manifest 'version #f))
           fv tower (spec-package-path core-file) server-cs
           (map resource-plan (hash-ref (server-rest server-cs) 'resource '()))))

;; resource-plan : rest.resource -> IgResource
(define (resource-plan res)
  (ig-resource (hash-ref res 'type)
               (for/list ([i (in-list (hash-ref res 'interaction '()))]) (cons (hash-ref i 'code) (expectation-of i)))
               (for/list ([sp (in-list (hash-ref res 'searchParam '()))])
                 (list (hash-ref sp 'name) (hash-ref sp 'type #f) (expectation-of sp)))
               (map (lambda (p) (car (string-split p "|")))
                    (append (let ([p (hash-ref res 'profile #f)]) (if (string? p) (list p) '()))
                             (hash-ref res 'supportedProfile '())))))

;; with-implied-search : CapabilityStatement -> CapabilityStatement
;; a server resource that lists search parameters or includes but not the search-type interaction
;; is read as searchable: the parameters mean nothing otherwise, and IGs do omit it (mCODE lists
;; Patient `_id` on a read-only Patient, IPA includes on PractitionerRole, SDC dozens of
;; parameters). The interaction added takes the resource's own expectation.
(define (with-implied-search cs)
  (hash-set cs 'rest
            (for/list ([r (in-list (jlist (hash-ref cs 'rest '())))])
              (if (equal? (hash-ref r 'mode #f) "server")
                  (hash-set r 'resource (map imply-search (hash-ref r 'resource '())))
                  r))))

;; imply-search : rest.resource -> rest.resource
(define (imply-search res)
  (define codes (for/list ([i (in-list (hash-ref res 'interaction '()))]) (hash-ref i 'code #f)))
  (if (and (not (member "search-type" codes))
           (for/or ([k (in-list '(searchParam searchInclude searchRevInclude))]) (pair? (hash-ref res k '()))))
      (hash-set res 'interaction
                (append (hash-ref res 'interaction '())
                        (list (hasheq 'code "search-type"
                                      'extension (list (hasheq 'url expectation-url 'valueCode (expectation-of res)))))))
      res))

;; ---- dependencies -------------------------------------------------------------------------------

;; dependency-packages : tgz -> (listof path)
;; package.json `dependencies`, transitively (nearest first, each once), located as
;; <name>-<version>.tgz (or <name>.tgz when that IS the version) in `current-package-directories` or
;; fhir-spec; a version may be a pattern (`3.3.x`). Core packages and ones not found are left out
;; (the core is added separately; a missing one only narrows validation)
(define (dependency-packages tgz)
  (let loop ([todo (direct-dependencies tgz)] [seen '()])
    (cond [(null? todo) (reverse seen)]
          [(member (car todo) seen) (loop (cdr todo) seen)]
          [else (loop (append (cdr todo) (direct-dependencies (car todo))) (cons (car todo) seen))])))

;; direct-dependencies : tgz -> (listof path)   the dependencies named in its package.json and found
(define (direct-dependencies tgz)
  (define m (package-manifest tgz))
  (define ds (if (and m (hash? (hash-ref m 'dependencies #f))) (hash-ref m 'dependencies) (hash)))
  (for*/list ([(name version) (in-hash ds)]
              #:unless (core-package-name? (symbol->string name))
              [p (in-value (find-package (symbol->string name) version))]
              #:when p)
    p))

;; core-package-name? : String -> Boolean   a core, terminology or extensions package (never a dependency)
(define (core-package-name? name)
  (regexp-match? #px"^hl7[.]fhir[.]r[0-9]+b?[.]core$|^hl7[.]terminology|[.]extensions" name))

;; find-package : name version-or-pattern -> path | #f
(define (find-package name version)
  (define (version-ok? q) (let ([qm (package-manifest q)])
                            (and qm (version-matches? (hash-ref qm 'version "") version))))
  (or (spec-package-path (format "~a-~a.tgz" name version) #:optional? #t)
      (for*/first ([d (in-list (current-package-directories))]
                   #:when (directory-exists? d)
                   [f (in-list (sort (directory-list d) string>? #:key path->string))]   ; newest first
                   #:when (regexp-match? (pregexp (format "^~a-[^-]+[.]tgz$" (regexp-quote name))) (path->string f))
                   #:when (version-ok? (build-path d f)))
        (build-path d f))
      (let ([q (spec-package-path (format "~a.tgz" name) #:optional? #t)])
        (and q (version-ok? q) q))))

;; version-matches? : "3.3.2" "3.3.x" -> Boolean   (x / * stand for any one part)
(define (version-matches? v pattern)
  (define ps (string-split pattern "."))
  (define vs (string-split v "."))
  (and (= (length ps) (length vs))
       (for/and ([p (in-list ps)] [x (in-list vs)]) (or (member p '("x" "X" "*")) (equal? p x)))
       #t))

;; ---- living examples ----------------------------------------------------------------------------
(module+ test
  (require rackunit)
  (check-true (version-matches? "3.3.2" "3.3.x"))
  (check-true (version-matches? "3.3.2" "3.3.2"))
  (check-false (version-matches? "3.4.2" "3.3.x"))
  (check-false (version-matches? "3.3" "3.3.x"))
  (check-true (core-package-name? "hl7.fhir.r4.core"))
  (check-true (core-package-name? "hl7.terminology.r4"))
  (check-false (core-package-name? "hl7.fhir.us.core"))
  (let-values ([(tower core) (tower-for "4.0.1")]) (check-equal? (list tower core) '(fhir/r4/schemas "hl7.fhir.r4.core.tgz")))
  (check-exn #rx"unsupported FHIR version" (lambda () (tower-for "3.0.2")))

  (define shall (hasheq 'url expectation-url 'valueCode "SHALL"))
  (check-equal? (expectation-of (hasheq 'code "read" 'extension (list shall))) "SHALL")
  (check-equal? (expectation-of (hasheq 'code "read")) "MAY")

  ;; a resource with parameters but no search-type gets the interaction, at its own expectation
  (define cs (hasheq 'resourceType "CapabilityStatement"
                     'rest (list (hasheq 'mode "client")
                                 (hasheq 'mode "server"
                                         'resource (list (hasheq 'type "Patient" 'extension (list shall)
                                                                 'interaction (list (hasheq 'code "read"))
                                                                 'searchParam (list (hasheq 'name "_id" 'type "token")))
                                                         (hasheq 'type "Observation"
                                                                 'interaction (list (hasheq 'code "read"))))))))
  (define implied (with-implied-search cs))
  (define patient (car (hash-ref (server-rest implied) 'resource)))
  (check-equal? (map (lambda (i) (cons (hash-ref i 'code) (expectation-of i))) (hash-ref patient 'interaction))
                '(("read" . "MAY") ("search-type" . "SHALL")))
  (check-equal? (hash-ref (cadr (hash-ref (server-rest implied) 'resource)) 'interaction)
                (list (hasheq 'code "read")))
  (check-equal? (resource-plan patient)
                (ig-resource "Patient" '(("read" . "MAY") ("search-type" . "SHALL")) '(("_id" "token" "MAY")) '()))
  (check-equal? (ig-resource-profiles (resource-plan (hasheq 'type "Patient" 'profile "http://x/P|1.0"
                                                             'supportedProfile '("http://x/Q"))))
                '("http://x/P" "http://x/Q"))
  (check-false (server-capability-statement (list (cons "a.json" cs)) "other-id"))
  (check-equal? (server-capability-statement (list (cons "a.json" cs)) #f) cs)

  ;; a published IG, when fhir-spec has it: US Core's plan
  (define us-core (spec-package-path "hl7.fhir.us.core.tgz" #:optional? #t))
  (when us-core
    (define plan (plan-ig-server us-core))
    (check-equal? (ig-plan-fhir-version plan) "4.0.1")
    (check-equal? (ig-plan-tower plan) 'fhir/r4/schemas)
    (check-true (and (findf (lambda (r) (equal? (ig-resource-type r) "Patient")) (ig-plan-resources plan)) #t))
    (check-equal? (dependency-packages us-core) '())))      ; US Core depends on core and extensions only
