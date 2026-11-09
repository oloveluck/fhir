#lang racket/base

;;; terminology/operations.rkt — the terminology operations as operation values (fhir/operation):
;;; ValueSet/$expand, ValueSet/$validate-code, CodeSystem/$lookup, ConceptMap/$translate.
;;;
;;;   ($expand vs #:filter "heart" #:count 10)             a ValueSet (the subject, or #:url / #:valueSet)
;;;   ($validate-code vs #:code "male" #:system "http://hl7.org/fhir/administrative-gender")
;;;   ($lookup #:system "http://loinc.org" #:code "8867-4")
;;;   ($translate cm #:sourceCode "home" #:system "…")     R5 names; R4's #:code is accepted too
;;; Definitions resolve from the inputs, then the current data source's ValueSets / CodeSystems /
;;; ConceptMaps, then `current-sd-packages` (indexed once per package list). Results are FHIR JSON.

(require racket/contract racket/list (only-in fhir/registry registered-resources)
         (only-in fhir/r5/operations expand-definition ValueSet-validate-code-definition
                  CodeSystem-validate-code-definition lookup-definition translate-definition
                  subsumes-definition find-matches-definition closure-definition)
         fhir/operation fhir/data-source
         (only-in fhir/sd/sd-index sd-context current-sd-packages)
         (only-in fhir/serialize/jsexpr-util drop-false)
         (only-in "service.rkt" packages->resolver resources->resolver packages->code-systems
                  expand/json validate-code/json cs-validate-code/json lookup/json translate/json
                  subsumes/json find-matches/json closure-relation terminology-capabilities policy-of
                  implicit-vcl-valueset))

(provide
 (contract-out
  ;; the terminology operations as fhir/operation values, over current-data-source then the packages
  [$expand operation?] [$validate-code operation?] [$cs-validate-code operation?] [$lookup operation?]
  [$subsumes operation?] [$find-matches operation?] [$translate operation?] [$closure operation?]
  ;; every terminology operation, in the order a server lists them
  [terminology-operations (listof operation?)]
  ;; what a server over the current packages says about itself: a TerminologyCapabilities jsexpr
  [current-terminology-capabilities (->* () (#:url (or/c string? #f)) hash?)]
  ;; the resolver of the moment: the data source's resources (and any extra), then the packages
  [current-terminology-resolver (->* () ((listof hash?)) procedure?)]))

;; the packages' resolver, built once per package list (indexing a core package takes seconds)
(define package-resolvers (make-hash))
(define (packages-resolver)
  (define pkgs (sd-context))
  (hash-ref! package-resolvers pkgs (lambda () (packages->resolver pkgs))))

;; current-terminology-resolver : [extra-resources] -> (url [version] -> resource|#f)
(define terminology-types '("ValueSet" "CodeSystem" "ConceptMap"))
(define (current-terminology-resolver [extra '()])
  (define ds (current-data-source))
  (define search (data-source-search ds))
  (define given (resources->resolver extra))
  (define local
    (if search
        ;; a data source that searches (a store) is asked for the url, not scanned
        (lambda (url [version #f])
          (define base (car (regexp-split #rx"[|]" url)))
          ((resources->resolver (append-map (lambda (t) (search t (list (cons "url" base)))) terminology-types))
           url version))
        (resources->resolver (append-map (lambda (t) ((data-source-all ds) t)) terminology-types))))
  ;; what required modules defined (fhir/registry): a #lang vcl value set, an FSH code system
  (define registered (resources->resolver (append-map registered-resources terminology-types)))
  (define packages (packages-resolver))
  ;; last, an implicit VCL url (http://fhir.org/VCL?v1=…) is the ValueSet its expression defines
  (lambda (url [version #f])
    (or (given url version) (local url version) (registered url version) (packages url version)
        (implicit-vcl-valueset url))))

;; current-terminology-capabilities : [#:url] -> TerminologyCapabilities jsexpr   over the packages
(define (current-terminology-capabilities #:url [url #f])
  (terminology-capabilities (packages->code-systems (sd-context)) #:url url))

;; the ValueSet an operation is about: piped (instance), `valueSet`, or `url` -> (values url resolver)
(define (target-valueset in subject what)
  (define inline (or subject (input in "valueSet")))
  ;; a definition (compose) is used as given; an expansion (no compose) stands for its url
  (define inline* (and inline (hash-ref inline 'compose #f)
                       (if (hash-ref inline 'url #f) inline (hash-set inline 'url "urn:fhir:inline-valueset"))))
  (define url (or (and inline (hash-ref inline 'url #f)) (and inline* (hash-ref inline* 'url)) (input in "url")
                  (operation-error "required" "~a needs a ValueSet (piped), valueSet, or url" what)))
  (define resolver (current-terminology-resolver (if inline* (list inline*) '())))
  (unless (resolver url (input in "valueSetVersion"))
    (operation-error "not-found" "~a: ValueSet ~a is not in the data source or the packages" what url))
  (values url resolver))

(define $expand
  (make-operation
   expand-definition
   (lambda (in subject)
     (define-values (url resolver) (target-valueset in subject "$expand"))
     (define params
       (for/hash ([k (in-list '("filter" "count" "offset" "activeOnly" "excludeNested" "displayLanguage"
                                "includeDesignations"))]
                  #:when (input in k))
         (values k (input in k))))
     (define params*                       ; the repeatable ones, as lists
       (for/fold ([h params]) ([k (in-list '("property" "useSupplement"))])
         (define vs (hash-ref in k '()))
         (if (pair? vs) (hash-set h k vs) h)))
     (define policy (policy-of (hash-ref in "system-version" '()) (hash-ref in "force-system-version" '())
                               (hash-ref in "check-system-version" '())))
     (expand/json resolver url (input in "valueSetVersion") params* policy))))

(define $validate-code
  (make-operation
   ValueSet-validate-code-definition
   (lambda (in subject)
     (define-values (url resolver) (target-valueset in subject "$validate-code"))
     (validate-code/json resolver url (input in "code") (input in "system")
                         #:coding (input in "coding") #:codeable-concept (input in "codeableConcept")
                         #:display (input in "display") #:valueset-version (input in "valueSetVersion")
                         #:system-version (input in "systemVersion")))))

;; CodeSystem/$validate-code: the code system is the subject, `codeSystem`, `url`, or the coding's
(define $cs-validate-code
  (make-operation
   CodeSystem-validate-code-definition
   (lambda (in subject)
     (define cs (or subject (input in "codeSystem")))
     (define coding (or (input in "coding")
                        (let ([cc (input in "codeableConcept")])
                          (and cc (let ([cs (hash-ref cc 'coding '())]) (and (pair? cs) (car cs)))))))
     (define system (or (input in "url") (and cs (hash-ref cs 'url #f)) (and coding (hash-ref coding 'system #f))))
     (define code (or (input in "code") (and coding (hash-ref coding 'code #f))))
     (unless (and system code)
       (operation-error "required" "CodeSystem/$validate-code needs a code and a code system url (or a coding)"))
     (cs-validate-code/json (current-terminology-resolver (if cs (list cs) '())) system code
                            (or (input in "version") (and coding (hash-ref coding 'version #f)))
                            #:display (or (input in "display") (and coding (hash-ref coding 'display #f)))))))

(define $subsumes
  (make-operation
   subsumes-definition
   (lambda (in subject)
     (define a (input in "codingA"))
     (define b (input in "codingB"))
     (define system (or (input in "system") (and subject (hash-ref subject 'url #f)) (and a (hash-ref a 'system #f))))
     (define code-a (or (input in "codeA") (and a (hash-ref a 'code #f))))
     (define code-b (or (input in "codeB") (and b (hash-ref b 'code #f))))
     (unless (and system code-a code-b)
       (operation-error "required" "$subsumes needs codeA, codeB and a system (or codingA and codingB)"))
     (define version (or (input in "version") (and a (hash-ref a 'version #f))))
     (define answer
       (with-handlers ([exn:fail? (lambda (e) (lambda () (operation-error "not-found" "~a" (exn-message e))))])
         (define ps (subsumes/json (current-terminology-resolver (if subject (list subject) '())) system code-a code-b version))
         (lambda () ps)))
     (answer))))

(define $find-matches
  (make-operation
   find-matches-definition
   (lambda (in subject)
     (define system (or (input in "system") (and subject (hash-ref subject 'url #f))
                        (operation-error "required" "$find-matches needs a system")))
     ;; each `property` input is a parameter with parts `code` and `value`
     (define (part-value q) (for/first ([(k v) (in-hash q)] #:when (regexp-match? #rx"^value" (symbol->string k))) v))
     (define props
       (for/list ([p (in-list (hash-ref in "property" '()))] #:when (hash? p))
         (define parts (filter hash? (hash-ref p 'part '())))
         (define (part name) (for/first ([q (in-list parts)] #:when (equal? (hash-ref q 'name #f) name)) (part-value q)))
         (cons (part "code") (let ([v (part "value")]) (if (string? v) v (format "~a" v))))))
     (define answer
       (with-handlers ([exn:fail? (lambda (e) (lambda () (operation-error "not-found" "~a" (exn-message e))))])
         (define ps (find-matches/json (current-terminology-resolver (if subject (list subject) '())) system props
                                       (input in "version") (not (eq? (input in "exact") #f))))
         (lambda () ps)))
     (answer))))

;; $closure keeps a named table of the concepts a client has sent and answers each addition with
;; the subsumption relations between the new concepts and the table, as a ConceptMap
;; (https://hl7.org/fhir/conceptmap-operation-closure.html); no concepts (re)initialise the table
(define closure-tables (make-hash))     ; name -> (listof Coding jsexpr), oldest first
(define $closure
  (make-operation
   closure-definition
   (lambda (in subject)
     (define name (or (input in "name") (operation-error "required" "$closure needs a name")))
     (define new (filter hash? (hash-ref in "concept" '())))
     (define old (hash-ref closure-tables name '()))
     (hash-set! closure-tables name (if (null? new) '() (append old new)))
     (define resolver (current-terminology-resolver))
     (define (relation a b)
       (define sys (hash-ref a 'system #f))
       (and sys (equal? sys (hash-ref b 'system #f))
            (with-handlers ([exn:fail? (lambda (_) #f)])
              (closure-relation resolver sys (hash-ref a 'code #f) (hash-ref b 'code #f)))))
     (define by-system                   ; system -> elements
       (for*/fold ([h (hash)]) ([a (in-list new)] [b (in-list (append old new))]
                                #:unless (eq? a b)
                                [rel (in-value (relation a b))] #:when rel)
         (hash-update h (hash-ref a 'system)
                      (lambda (l) (append l (list (hasheq 'code (hash-ref a 'code #f)
                                                          'target (list (hasheq 'code (hash-ref b 'code #f)
                                                                                'relationship rel))))))
                      '())))
     (drop-false
      (hasheq 'resourceType "ConceptMap" 'name name 'status "active" 'version (input in "version")
              'group (and (positive? (hash-count by-system))
                          (for/list ([(sys els) (in-hash by-system)])
                            (hasheq 'source sys 'target sys 'element els))))))))

(define $lookup
  (make-operation
   lookup-definition
   (lambda (in subject)
     (define coding (input in "coding"))
     (define system (or (input in "system") (and coding (hash-ref coding 'system #f)) (and subject (hash-ref subject 'url #f))))
     (define code (or (input in "code") (and coding (hash-ref coding 'code #f))))
     (unless (and system code) (operation-error "required" "$lookup needs a code and a system (or a coding)"))
     (lookup/json (current-terminology-resolver (if subject (list subject) '())) system code (input in "version")
                  #:supplements (hash-ref in "useSupplement" '())))))

(define $translate
  (make-operation
   (hash-update translate-definition 'parameter
                (lambda (ps) (append ps (list (hasheq 'name "code" 'use "in" 'min 0 'max "1" 'type "code")))))
   (lambda (in subject)
     (define cm (or subject (input in "conceptMap")))
     (define url (or (and cm (hash-ref cm 'url #f)) (input in "url")
                     (operation-error "required" "$translate needs a ConceptMap (piped), conceptMap, or url")))
     (define code (or (input in "sourceCode") (input in "code")
                      (let ([c (input in "sourceCoding")]) (and c (hash-ref c 'code #f)))
                      (operation-error "required" "$translate needs sourceCode or sourceCoding")))
     (translate/json (current-terminology-resolver (if cm (list cm) '())) url code
                     (or (input in "system") (let ([c (input in "sourceCoding")]) (and c (hash-ref c 'system #f))))))))

(define terminology-operations
  (list $expand $validate-code $cs-validate-code $lookup $subsumes $find-matches $translate $closure))
(for-each register-operation! terminology-operations)

(module+ test
  (require rackunit (only-in fhir/spec-package spec-package-path))
  (define core (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t))
  (when core
    (parameterize ([current-sd-packages (list core)])
      (define gender "http://hl7.org/fhir/ValueSet/administrative-gender")
      (define vs ($expand #:url gender))
      (check-equal? (hash-ref (hash-ref vs 'expansion) 'total) 4)
      ;; piped, and by reference with a filter
      (check-equal? (hash-ref (hash-ref (apply-operation "ValueSet/$expand" vs #:filter "fem") 'expansion) 'total) 1)
      (check-equal? (hash-ref (hash-ref (~> vs ($expand #:filter "fem") ($expand)) 'expansion) 'total) 4)
      (define (result ps) (for/first ([p (in-list (hash-ref ps 'parameter))] #:when (equal? (hash-ref p 'name) "result")) (hash-ref p 'valueBoolean)))
      (check-true (result ($validate-code #:url gender #:code "male" #:system "http://hl7.org/fhir/administrative-gender")))
      (check-false (result ($validate-code #:url gender #:code "florp" #:system "http://hl7.org/fhir/administrative-gender")))
      (check-exn #rx"not in the data source or the packages" (lambda () ($expand #:url "http://example.org/nope")))
      ;; an implicit VCL url needs no registered ValueSet: it is the value set its expression defines
      (define vcl-url "http://fhir.org/VCL?v1=(http://hl7.org/fhir/administrative-gender)(male;female)")
      (check-equal? (hash-ref (hash-ref ($expand #:url vcl-url) 'expansion) 'total) 2)
      (check-true (result ($validate-code #:url vcl-url #:code "male" #:system "http://hl7.org/fhir/administrative-gender")))
      (check-false (result ($validate-code #:url vcl-url #:code "other" #:system "http://hl7.org/fhir/administrative-gender")))
      (check-true (result ($cs-validate-code #:url "http://hl7.org/fhir/administrative-gender" #:code "male")))
      (check-false (result ($cs-validate-code #:url "http://hl7.org/fhir/administrative-gender" #:code "florp")))
      (check-equal? (hash-ref (car (hash-ref ($subsumes #:system "http://hl7.org/fhir/administrative-gender" #:codeA "male" #:codeB "male") 'parameter)) 'valueCode) "equivalent")
      (check-equal? (hash-ref (current-terminology-capabilities) 'resourceType) "TerminologyCapabilities")
      (check-equal? (hash-ref ($closure #:name "t") 'resourceType) "ConceptMap")
      ;; a ValueSet from the data source
      (define local (hasheq 'resourceType "ValueSet" 'url "http://example.org/vs"
                            'compose (hasheq 'include (list (hasheq 'system "http://hl7.org/fhir/administrative-gender"
                                                                    'concept (list (hasheq 'code "male")))))))
      (parameterize ([current-data-source (resources->data-source (list local))])
        (check-equal? (hash-ref (hash-ref ($expand #:url "http://example.org/vs") 'expansion) 'total) 1)))))
