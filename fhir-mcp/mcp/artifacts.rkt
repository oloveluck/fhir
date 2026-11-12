#lang racket/base

;;; artifacts.rkt — a workspace's definitions as CRMI artifacts: what a staged one takes from its
;;; collection, what its lifecycle allows, and which stored version a canonical means.
;;;
;;; CRMI is HL7's Canonical Resource Management Infrastructure guide (2.0.0; the fhir repo's
;;; docs/store-as-codebase.md). Its rules here, by their numbers in its Artifact Lifecycle page:
;;;   3.1  an active artifact SHALL NOT go back to draft, a retired one SHALL NOT go back to active
;;;        or draft: a new version is required
;;;   3.3  an artifact SHALL have a version
;;;   3.4  under the strict policy no element changes without a new version (id, meta, status and
;;;        lastReviewDate aside)
;;;   3.5  an artifact authored in a collection SHOULD have the collection's version
;;; and from its repository page: each business version of an artifact is a different resource
;;; instance; Submit and Revise hold an artifact to its Shareable profile.
;;;
;;; An Artifact is a FHIR resource that defines (one of `artifact-types`), as a jsexpr.
;;; Its collection is the workspace's implementation guide, as its sushi-config.yaml states it (an
;;; ig-config, fhir/ig-config).
;;; Pure: no store, no files.

(require racket/contract racket/list racket/string
         (only-in net/base64 base64-decode)
         (only-in fhir/ig-config ig-config? ig-config-version ig-config-status ig-config-publisher ig-config-experimental))

(provide
 (contract-out
  [artifact-types (listof string?)]
  ;; artifact? : resource -> boolean   a resource of a defining type
  [artifact? (-> hash? boolean?)]
  ;; in-collection : artifact guide stored|#f -> artifact   the artifact as a component of its
  ;; collection. Its status is the collection's (the repository page: a component's status SHALL be
  ;; consistent with its parent's; draft when the guide states none; one already retired stays so);
  ;; the version, experimental flag and publisher it does not state itself are the collection's
  ;; (3.5). One that states a version of its own (a CQL library's header) is not carried along:
  ;; released under that version, it stays as it is stored while the collection drafts its next.
  [in-collection (-> hash? ig-config? (or/c hash? #f) hash?)]
  ;; with-derived-labels : artifact -> artifact   a title from the name and a description (a
  ;; library's leading comment, else the title) for an artifact written in a language with no place
  ;; for them
  [with-derived-labels (-> hash? hash?)]
  ;; lifecycle-errors : stored|#f staged -> (listof string)   what 3.1 and 3.4 refuse
  [lifecycle-errors (-> (or/c hash? #f) hash? (listof string?))]
  ;; archive-of : stored|#f staged -> artifact|#f   the stored released version (active or retired)
  ;; as an instance of its own, when the staged one begins another version under the same id
  [archive-of (-> (or/c hash? #f) hash? (or/c hash? #f))]
  [archival-id (-> string? string? string?)]
  ;; shareable-profile : type -> url   CRMI's Shareable profile of a type
  [shareable-profile (-> string? string?)]
  ;; shareable-minimum-errors : artifact -> (listof string)   the Shareable minimum checked directly
  ;; (where CRMI's R4 profiles cannot be applied): url, version, title, status, experimental,
  ;; description
  [shareable-minimum-errors (-> hash? (listof string?))]
  ;; with-authoring-hint : message language -> message   where a missing element is written
  [with-authoring-hint (-> string? (or/c string? #f) string?)]
  ;; current-versions : (listof artifact) -> (listof artifact)   one per url — what an unversioned
  ;; canonical means among stored versions: the active one of the highest version, else the highest
  [current-versions (-> (listof hash?) (listof hash?))]
  [version<? (-> string? string? boolean?)]))

;; CRMI's operations name these (its capability statements name five and say the rest follow the
;; same pattern); ViewDefinition is treated by that pattern
(define artifact-types
  '("ActivityDefinition" "CapabilityStatement" "CodeSystem" "CompartmentDefinition" "ConceptMap"
    "ExampleScenario" "GraphDefinition" "ImplementationGuide" "Library" "Measure" "MessageDefinition"
    "NamingSystem" "OperationDefinition" "PlanDefinition" "Questionnaire" "SearchParameter"
    "StructureDefinition" "StructureMap" "TerminologyCapabilities" "TestScript" "ValueSet" "ViewDefinition"))

(define (artifact? r) (and (member (hash-ref r 'resourceType #f) artifact-types) #t))

(define (str v) (and (string? v) (not (string=? v "")) v))
(define (label r) (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id "?")))

;; ---- a component of its collection (3.5) ----------------------------------------------------------
(define (in-collection r guide stored)
  (define (fill r key value) (if (and value (not (hash-has-key? r key))) (hash-set r key value) r))
  (define version (or (str (hash-ref r 'version #f)) (ig-config-version guide)))
  (define released-on-its-own?
    (and stored version
         (not (equal? version (ig-config-version guide)))
         (equal? version (str (hash-ref stored 'version #f)))
         (member (hash-ref stored 'status #f) '("active" "retired"))))
  (let* ([r (fill r 'version version)]
         [r (hash-set r 'status
                      (cond [released-on-its-own? (hash-ref stored 'status)]
                            [(equal? (hash-ref r 'status #f) "retired") "retired"]
                            ;; a compiler's default status (SUSHI's is active) is not the author's word
                            [else (or (ig-config-status guide) "draft")]))]
         [r (if (boolean? (hash-ref r 'experimental 'none)) r (hash-set r 'experimental (eq? #t (ig-config-experimental guide))))]
         [r (fill r 'publisher (ig-config-publisher guide))])
    r))

;; humanized : "LatestA1c" -> "Latest A1c"
(define (humanized name)
  (string-trim (regexp-replace* #px"([a-z0-9])([A-Z])" (regexp-replace* #rx"[_-]+" name " ") "\\1 \\2")))

;; leading-comment : cql-text -> string|#f   the comment a library opens with
(define (leading-comment text)
  (define t (string-trim text))
  (cond [(regexp-match #px"^/\\*+(.*?)\\*/" t)
         => (lambda (m) (str (string-normalize-spaces (regexp-replace* #px"(?m:^\\s*\\*+)" (cadr m) " "))))]
        [(regexp-match #px"^((?://[^\n]*\n?)+)" t)
         => (lambda (m) (str (string-normalize-spaces (regexp-replace* #px"(?m:^\\s*//+)" (cadr m) " "))))]
        [else #f]))
(define (library-comment r)
  (for/or ([c (in-list (let ([cs (hash-ref r 'content '())]) (if (list? cs) cs '())))])
    (and (hash? c) (equal? (hash-ref c 'contentType #f) "text/cql") (string? (hash-ref c 'data #f))
         (with-handlers ([exn:fail? (lambda (_) #f)])
           (leading-comment (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (hash-ref c 'data))) #\?))))))

(define (with-derived-labels r)
  (define title (or (str (hash-ref r 'title #f))
                    (let ([n (or (str (hash-ref r 'name #f)) (str (hash-ref r 'id #f)))]) (and n (humanized n)))))
  (define description (or (str (hash-ref r 'description #f)) (library-comment r) title))
  (let* ([r (if title (hash-set r 'title title) r)]
         [r (if description (hash-set r 'description description) r)])
    r))

;; ---- the lifecycle (3.1, 3.4) ----------------------------------------------------------------------
;; content : artifact -> artifact   what a version's content is: not its id, meta, status, date,
;; lastReviewDate or narrative
(define (content r) (for/fold ([r r]) ([k (in-list '(id meta status date lastReviewDate text))]) (hash-remove r k)))
(define (version-of r) (str (hash-ref r 'version #f)))
(define (new-version? stored staged) (not (equal? (version-of stored) (version-of staged))))

(define (lifecycle-errors stored staged)
  (cond
    [(not stored) '()]
    [(new-version? stored staged) '()]                       ; another version: the stored one is kept (archive-of)
    [else
     (define was (hash-ref stored 'status #f))
     (define is (hash-ref staged 'status #f))
     (define v (or (version-of stored) "no version"))
     (define same? (equal? (content stored) (content staged)))
     (define how "a new version is required (CRMI 3.1): raise `version` in sushi-config.yaml")
     (cond
       [(and (equal? was "active") (equal? is "draft"))
        (list (format "~a (~a) is active: an active artifact does not go back to draft — ~a" (label staged) v how))]
       [(and (equal? was "retired") (not (equal? is "retired")))
        (list (format "~a (~a) is retired: a retired artifact does not go back to ~a — ~a" (label staged) v (or is "use") how))]
       [(and (member was '("active" "retired")) (not same?))
        (list (format "~a (~a) is ~a: its content does not change — ~a" (label staged) v was how))]
       [else '()])]))

(define (archival-id id version)
  (define s (string-append id "-" (regexp-replace* #rx"[^A-Za-z0-9.-]" version "-")))
  (if (> (string-length s) 64) (substring s (- (string-length s) 64)) s))

(define (archive-of stored staged)
  (and stored
       (member (hash-ref stored 'status #f) '("active" "retired"))
       (version-of stored)
       (new-version? stored staged)
       (string? (hash-ref stored 'id #f))
       (hash-remove (hash-set stored 'id (archival-id (hash-ref stored 'id) (version-of stored))) 'meta)))

;; ---- Shareable -------------------------------------------------------------------------------------
(define (shareable-profile type)
  (string-append "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareable" (string-downcase type)))

(define (shareable-minimum-errors r)
  (define type (hash-ref r 'resourceType "?"))
  (for/list ([k (in-list '(url version title status experimental description))]
             #:unless (let ([v (hash-ref r k 'none)]) (or (boolean? v) (str v))))
    (format "~a.~a: minimum required = 1, but found 0" type k)))

(define (with-authoring-hint message language)
  (define m (regexp-match #px"[.](title|description|version|experimental|status|url|name): minimum required" message))
  (define element (and m (cadr m)))
  (define hint
    (cond [(not element) #f]
          [(equal? element "version") "an artifact has its guide's version: `version:` in sushi-config.yaml"]
          [(equal? language "fsh") (case element
                                     [("title") "add `Title: \"…\"` to its FSH"]
                                     [("description") "add `Description: \"…\"` to its FSH"]
                                     [else #f])]
          [(equal? language "ig") (format "add `~a:` to sushi-config.yaml" element)]
          [else #f]))
  (if hint (format "~a (~a)" message hint) message))

;; ---- which version a canonical means ---------------------------------------------------------------
;; version<? : by dot- and dash-separated parts, numbers as numbers (1.10.0 after 1.9.0)
(define (version<? a b)
  (let loop ([as (regexp-split #rx"[.-]" a)] [bs (regexp-split #rx"[.-]" b)])
    (cond [(null? bs) #f]
          [(null? as) #t]
          [else (define x (string->number (car as)))
                (define y (string->number (car bs)))
                (cond [(and x y) (cond [(< x y) #t] [(> x y) #f] [else (loop (cdr as) (cdr bs))])]
                      [(equal? (car as) (car bs)) (loop (cdr as) (cdr bs))]
                      [else (string<? (car as) (car bs))])])))

(define (current-versions rs)
  (define (newest l) (car (sort l (lambda (a b) (version<? (or (version-of b) "") (or (version-of a) ""))))))
  (define-values (named unnamed) (partition (lambda (r) (string? (hash-ref r 'url #f))) rs))
  (append
   (for/list ([group (in-list (group-by (lambda (r) (hash-ref r 'url)) named))])
     (define active (filter (lambda (r) (equal? (hash-ref r 'status #f) "active")) group))
     (newest (if (pair? active) active group)))
   unnamed))

(module+ test
  (require rackunit (only-in net/base64 base64-encode) (only-in fhir/ig-config parse-ig-config))
  (define sd (hasheq 'resourceType "StructureDefinition" 'id "lab" 'url "http://x/StructureDefinition/lab" 'name "Lab"))
  (check-true (artifact? sd))
  (check-false (artifact? (hasheq 'resourceType "Observation" 'id "a")))
  ;; the collection's facts fill what the artifact does not say; its own version is kept
  (define (guide . lines) (parse-ig-config (string-join lines "\n")))
  (define draft (guide "id: example.clinic" "version: 0.1.0" "status: draft" "publisher:" "  name: Example Clinic"))
  (check-equal? (in-collection sd draft #f)
                (hash-set* sd 'version "0.1.0" 'status "draft" 'experimental #f 'publisher "Example Clinic"))
  (check-equal? (hash-ref (in-collection (hash-set* sd 'version "9.9.9" 'experimental #t) draft #f) 'version) "9.9.9")
  (check-equal? (hash-ref (in-collection (hash-set sd 'experimental #t) draft #f) 'experimental) #t)
  (check-equal? (hash-ref (in-collection sd (guide "id: x" "experimental: true") #f) 'experimental) #t)
  (check-false (hash-has-key? (in-collection sd (guide "id: x") #f) 'version))
  ;; the status is the collection's, whatever a compiler defaulted; draft when it states none; a
  ;; retired artifact stays retired
  (check-equal? (hash-ref (in-collection (hash-set sd 'status "active") draft #f) 'status) "draft")
  (check-equal? (hash-ref (in-collection (hash-set sd 'status "active") (guide "id: x") #f) 'status) "draft")
  (check-equal? (hash-ref (in-collection (hash-set sd 'status "draft") (guide "id: x" "status: active") #f) 'status) "active")
  (check-equal? (hash-ref (in-collection (hash-set sd 'status "retired") (guide "id: x" "status: active") #f) 'status) "retired")
  ;; its own version, released: the collection's draft status does not reach it
  (let ([lib (hasheq 'resourceType "Library" 'id "A1c" 'version "0.1.0" 'status "draft")]
        [next (guide "id: x" "version: 0.2.0" "status: draft")])
    (check-equal? (hash-ref (in-collection lib next (hash-set lib 'status "active")) 'status) "active")
    (check-equal? (hash-ref (in-collection lib next (hash-set lib 'status "draft")) 'status) "draft")
    (check-equal? (hash-ref (in-collection lib next #f) 'status) "draft")
    ;; a new version of its own, or the collection's version: the collection's status
    (check-equal? (hash-ref (in-collection (hash-set lib 'version "0.3.0") next (hash-set lib 'status "active")) 'status) "draft")
    (check-equal? (hash-ref (in-collection (hash-set lib 'version "0.2.0") next (hash-set* lib 'version "0.2.0" 'status "active")) 'status) "draft"))
  ;; labels for a language with no place for them
  (define (cql text) (hasheq 'resourceType "Library" 'id "LatestA1c" 'name "LatestA1c"
                             'content (list (hasheq 'contentType "text/cql" 'data (bytes->string/utf-8 (base64-encode (string->bytes/utf-8 text) #""))))))
  (check-equal? (hash-ref (with-derived-labels (cql "library LatestA1c version '1.0'\n")) 'title) "Latest A1c")
  (check-equal? (hash-ref (with-derived-labels (cql "library LatestA1c version '1.0'\n")) 'description) "Latest A1c")
  (check-equal? (hash-ref (with-derived-labels (cql "/* The latest HbA1c\n * of each patient. */\nlibrary LatestA1c\n")) 'description)
                "The latest HbA1c of each patient.")
  (check-equal? (hash-ref (with-derived-labels (cql "// Latest HbA1c\n// per patient\nlibrary LatestA1c\n")) 'description) "Latest HbA1c per patient")
  (check-equal? (hash-ref (with-derived-labels (hash-set sd 'title "A lab result")) 'title) "A lab result")
  ;; the lifecycle
  (define (v status version . more) (apply hash-set* sd 'status status 'version version more))
  (check-equal? (lifecycle-errors #f (v "draft" "0.1.0")) '())
  (check-equal? (lifecycle-errors (v "draft" "0.1.0") (v "draft" "0.1.0" 'title "changed")) '())
  (check-equal? (lifecycle-errors (v "draft" "0.1.0") (v "active" "0.1.0")) '())
  (check-regexp-match #rx"StructureDefinition/lab [(]0.1.0[)] is active: an active artifact does not go back to draft"
                      (car (lifecycle-errors (v "active" "0.1.0") (v "draft" "0.1.0"))))
  (check-regexp-match #rx"is retired: a retired artifact does not go back to active" (car (lifecycle-errors (v "retired" "0.1.0") (v "active" "0.1.0"))))
  (check-regexp-match #rx"is active: its content does not change" (car (lifecycle-errors (v "active" "0.1.0") (v "active" "0.1.0" 'title "changed"))))
  ;; retiring changes the status alone; a date or a new meta is not content
  (check-equal? (lifecycle-errors (v "active" "0.1.0") (v "retired" "0.1.0" 'date "2026-11-12" 'meta (hasheq 'versionId "3"))) '())
  (check-equal? (length (lifecycle-errors (v "active" "0.1.0") (v "retired" "0.1.0" 'title "changed"))) 1)
  ;; another version begins: allowed, and the released one is kept as its own instance
  (check-equal? (lifecycle-errors (v "active" "0.1.0") (v "draft" "0.2.0" 'title "changed")) '())
  (check-equal? (hash-ref (archive-of (v "active" "0.1.0" 'meta (hasheq 'versionId "3")) (v "draft" "0.2.0")) 'id) "lab-0.1.0")
  (check-false (hash-has-key? (archive-of (v "active" "0.1.0" 'meta (hasheq 'versionId "3")) (v "draft" "0.2.0")) 'meta))
  (check-false (archive-of (v "draft" "0.1.0") (v "draft" "0.2.0")))
  (check-false (archive-of (v "active" "0.1.0") (v "active" "0.1.0")))
  (check-false (archive-of #f (v "draft" "0.1.0")))
  (check-equal? (archival-id "lab" "1.0.0+build 7") "lab-1.0.0-build-7")
  (check-equal? (string-length (archival-id (make-string 70 #\a) "1.0.0")) 64)
  ;; Shareable
  (check-equal? (shareable-profile "StructureDefinition") "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareablestructuredefinition")
  (check-equal? (shareable-minimum-errors (hash-set* sd 'version "1" 'title "t" 'status "draft" 'experimental #f 'description "d")) '())
  (check-equal? (shareable-minimum-errors sd)
                '("StructureDefinition.version: minimum required = 1, but found 0" "StructureDefinition.title: minimum required = 1, but found 0"
                  "StructureDefinition.status: minimum required = 1, but found 0" "StructureDefinition.experimental: minimum required = 1, but found 0"
                  "StructureDefinition.description: minimum required = 1, but found 0"))
  (check-equal? (with-authoring-hint "StructureDefinition.title: minimum required = 1, but found 0" "fsh")
                "StructureDefinition.title: minimum required = 1, but found 0 (add `Title: \"…\"` to its FSH)")
  (check-regexp-match #rx"add `description:` to sushi-config.yaml" (with-authoring-hint "ImplementationGuide.description: minimum required = 1, but found 0" "ig"))
  (check-regexp-match #rx"its guide's version" (with-authoring-hint "ValueSet.version: minimum required = 1, but found 0" "vcl"))
  (check-equal? (with-authoring-hint "Observation.subject: minimum required = 1, but found 0" "fsh") "Observation.subject: minimum required = 1, but found 0")
  ;; which version a canonical means
  (check-true (version<? "1.9.0" "1.10.0"))
  (check-false (version<? "1.10.0" "1.9.0"))
  (check-true (version<? "0.1.0" "0.1.0-draft"))
  (check-equal? (map (lambda (r) (hash-ref r 'id))
                     (current-versions (list (hash-set (v "active" "0.1.0") 'id "lab-0.1.0") (v "draft" "0.2.0")
                                             (hasheq 'resourceType "ValueSet" 'id "a" 'url "http://x/ValueSet/a" 'version "2.0.0" 'status "draft")
                                             (hasheq 'resourceType "ValueSet" 'id "b" 'url "http://x/ValueSet/a" 'version "10.0.0" 'status "draft"))))
                '("lab-0.1.0" "b")))
