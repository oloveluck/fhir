#lang racket/base

;;; dependencies.rkt — what an artifact depends on, traced as CRMI says (2.0.0, Distribution,
;;; "Dependency Tracing"): per resource type, the elements that reference another artifact.
;;;
;;; The catalogue is DATA (`traced-paths`): for each type, CRMI's own list of paths, written as it
;;; writes them (`differential.element.type.profile`; `item..answerValueSet` for an element at any
;;; depth of nested items). A resource of any type also depends on the profiles it claims
;;; (`meta.profile`). Dependencies on the base specification are implied, as CRMI says ("should be
;;; considered implied"), and are not listed.
;;;
;;; A Dependency is (dependency canonical path): the reference as written (`url` or `url|version`)
;;; and the element it was found at.
;;;
;;; Pure over jsexpr: the closure takes the resolver as an argument, so it knows no store.

(require racket/contract racket/list racket/match racket/string json
         (only-in "artifacts.rkt" artifact?))

(provide
 (contract-out
  [struct dependency ([canonical string?] [path string?])]
  ;; traced-paths : (hash type -> (listof path))   CRMI's catalogue; "Resource" is every type's
  [traced-paths (hash/c string? (listof string?))]
  ;; direct-dependencies : resource -> (listof Dependency)   in the catalogue's order, each once
  [direct-dependencies (-> hash? (listof dependency?))]
  ;; dependency-closure : resource (canonical -> resource | #f) -> (listof (cons Dependency resource|#f))
  ;; the artifact's dependencies and theirs, each canonical once, in the order found (breadth
  ;; first); a dependency nothing here defines is listed with #f and not followed
  [dependency-closure (-> hash? (-> string? (or/c hash? #f)) (listof (cons/c dependency? (or/c hash? #f))))]
  ;; module-definition : artifact closure -> Library   CRMI's answer to $data-requirements: a
  ;; module-definition Library — a `depends-on` relatedArtifact per dependency (at the version it
  ;; resolved to) and the data requirements of the artifact and of every library it depends on
  [module-definition (-> hash? (listof (cons/c dependency? (or/c hash? #f))) hash?)]
  ;; dependency-rows : (listof resource) -> (listof row)   one row per dependency of each resource,
  ;; for SQL: type, id, url, version, path, target (the canonical without a version), target_version
  [dependency-rows (-> (listof hash?) (listof hash?))]
  [dependency-columns (listof string?)]))

(struct dependency (canonical path) #:transparent)

;; ---- the catalogue (CRMI 2.0.0, Distribution, "Dependency Tracing") -----------------------------
;; A path is its steps joined by `.`; an empty step (`item..definition`) means the step before it
;; at any depth of nesting. Every step fans out over a repeating element.
(define traced-paths
  (hash
   "Resource" '("meta.profile")
   "StructureDefinition" '("baseDefinition"
                           "differential.element.type.code" "differential.element.type.profile"
                           "differential.element.type.targetProfile" "differential.element.binding.valueSet"
                           "extension.url" "modifierExtension.url"
                           "differential.element.extension.url" "differential.element.modifierExtension.url")
   "StructureMap" '("structure.url" "import")
   "ValueSet" '("compose.include.valueSet" "compose.include.system" "compose.exclude.valueSet" "compose.exclude.system")
   "CodeSystem" '("supplements")
   ;; R4's elements, then R5's names for the same
   "ConceptMap" '("sourceCanonical" "targetCanonical" "sourceScopeCanonical" "targetScopeCanonical"
                  "group.source" "group.target" "group.element.target.dependsOn.system"
                  "group.element.target.product.system" "group.unmapped.url")
   "Questionnaire" '("derivedFrom" "item..definition" "item..answerValueSet")
   "ActivityDefinition" '("relatedArtifact.resource" "library" "profile" "transform")
   "PlanDefinition" '("relatedArtifact.resource" "library"
                      "action..trigger.dataRequirement.profile" "action..trigger.dataRequirement.codeFilter.valueSet"
                      "action..condition.expression.reference"
                      "action..input.profile" "action..input.codeFilter.valueSet"
                      "action..output.profile" "action..output.codeFilter.valueSet"
                      "action..definitionCanonical" "action..dynamicValue.expression.reference")
   "Library" '("relatedArtifact.resource" "dataRequirement.profile" "dataRequirement.codeFilter.valueSet")
   "Measure" '("relatedArtifact.resource" "library"
               "group.population.criteria.reference" "group.stratifier.criteria.reference"
               "group.stratifier.component.criteria.reference" "supplementalData.criteria.reference")
   ;; CRMI lists only an extension for a guide; these two are canonical elements ("if it is a
   ;; canonical reference … it is traced")
   "ImplementationGuide" '("global.profile" "dependsOn.uri")
   "OperationDefinition" '("base" "inputProfile" "outputProfile" "parameter.targetProfile" "parameter.binding.valueSet")
   "SearchParameter" '("derivedFrom")
   "CapabilityStatement" '("instantiates" "imports" "implementationGuide" "rest.resource.profile"
                           "rest.resource.supportedProfile" "rest.resource.searchParam.definition"
                           "rest.resource.operation.definition" "rest.operation.definition")))

;; values-at : jsexpr (listof step) -> (listof jsexpr)   the values a path reaches
(define (values-at json steps)
  (define (children j key)
    (define v (and (hash? j) (hash-ref j (string->symbol key) #f)))
    (cond [(not v) '()] [(list? v) v] [else (list v)]))
  (match steps
    ['() (list json)]
    [(list* key "" rest)                               ; `key..`: under key, at any depth of key
     (define here (children json key))
     (append (append-map (lambda (c) (values-at c rest)) here)
             (append-map (lambda (c) (values-at c steps)) here))]
    [(cons key rest) (append-map (lambda (c) (values-at c rest)) (children json key))]))

;; reference : string path -> canonical | #f   the value as a reference to an artifact: a type code
;; is its core definition (`Quantity`), an element definition loses its fragment
(define (reference v path)
  (cond [(not (string? v)) #f]
        [(regexp-match? #rx"type[.]code$" path)
         (if (regexp-match? #rx":" v) v (string-append "http://hl7.org/fhir/StructureDefinition/" v))]
        [(regexp-match? #rx"definition$" path) (car (regexp-split #rx"#" v))]
        [(regexp-match? #rx"^#" v) #f]                 ; a contained resource
        [else v]))

;; base-specification? : canonical -> boolean   defined by FHIR itself: implied, not listed
;; (http://hl7.org/fhir/<Type>/<id>, not a guide's http://hl7.org/fhir/uv/…, /us/…)
(define (base-specification? canonical)
  (regexp-match? #px"^http://hl7[.]org/fhir/(?:StructureDefinition|ValueSet|CodeSystem|SearchParameter|OperationDefinition|ConceptMap|CompartmentDefinition)/"
                 canonical))

(define (direct-dependencies r)
  (define paths (append (hash-ref traced-paths "Resource")
                        (if (artifact? r) (hash-ref traced-paths (hash-ref r 'resourceType "") '()) '())))
  (define own (let ([url (hash-ref r 'url #f)]) (if (string? url) (list url) '())))
  (remove-duplicates
   (for*/list ([path (in-list paths)]
               [v (in-list (values-at r (string-split path "." #:trim? #f)))]
               [c (in-value (reference v path))]
               #:when (and c (not (string=? c "")) (not (base-specification? c))
                           (not (member (car (regexp-split #rx"[|]" c)) own))))
     (dependency c path))
   #:key dependency-canonical))

;; ---- the closure -------------------------------------------------------------------------------
(define (url-of canonical) (car (regexp-split #rx"[|]" canonical)))

(define (dependency-closure root resolve)
  (let loop ([queue (direct-dependencies root)] [seen (list (hash-ref root 'url ""))] [found '()])
    (match queue
      ['() (reverse found)]
      [(cons d rest)
       #:when (member (url-of (dependency-canonical d)) seen)
       (loop rest seen found)]
      [(cons d rest)
       (define r (resolve (dependency-canonical d)))
       (loop (append rest (if r (direct-dependencies r) '()))
             (cons (url-of (dependency-canonical d)) seen)
             (cons (cons d r) found))])))

;; ---- $data-requirements ------------------------------------------------------------------------
(define library-type "http://terminology.hl7.org/CodeSystem/library-type")

(define (module-definition root closure)
  (define (versioned d r)
    (define v (and r (hash-ref r 'version #f)))
    (if (and (string? v) (not (regexp-match? #rx"[|]" (dependency-canonical d))))
        (string-append (dependency-canonical d) "|" v)
        (dependency-canonical d)))
  (define (label r) (and r (format "~a ~a" (hash-ref r 'resourceType "") (or (hash-ref r 'title #f) (hash-ref r 'name #f) (hash-ref r 'id "")))))
  (define requirements
    (remove-duplicates
     (for*/list ([r (in-list (cons root (filter-map cdr closure)))]
                 #:when (equal? (hash-ref r 'resourceType #f) "Library")
                 [dr (in-list (hash-ref r 'dataRequirement '()))])
       dr)))
  (define subject (format "~a~a" (hash-ref root 'url (format "~a/~a" (hash-ref root 'resourceType "") (hash-ref root 'id "")))
                          (let ([v (hash-ref root 'version #f)]) (if (string? v) (string-append "|" v) ""))))
  (for/fold ([lib (hasheq 'resourceType "Library"
                          'status "active"
                          'type (hasheq 'coding (list (hasheq 'system library-type 'code "module-definition")))
                          'description (format "The effective requirements of ~a: what it depends on, and the data it reads." subject)
                          'relatedArtifact (for/list ([dr (in-list closure)])
                                             (for/fold ([ra (hasheq 'type "depends-on" 'resource (versioned (car dr) (cdr dr)))])
                                                       ([display (in-value (label (cdr dr)))] #:when display)
                                               (hash-set ra 'display display))))])
            ([kv (in-list (list (cons 'dataRequirement requirements)))] #:when (pair? (cdr kv)))
    (hash-set lib (car kv) (cdr kv))))

;; ---- as a table --------------------------------------------------------------------------------
(define dependency-columns '("type" "id" "url" "version" "path" "target" "target_version"))

(define (dependency-rows resources)
  (define (cell v) (if (string? v) v (json-null)))
  (for*/list ([r (in-list resources)] [d (in-list (direct-dependencies r))])
    (define parts (regexp-split #rx"[|]" (dependency-canonical d)))
    (hasheq 'type (cell (hash-ref r 'resourceType #f)) 'id (cell (hash-ref r 'id #f))
            'url (cell (hash-ref r 'url #f)) 'version (cell (hash-ref r 'version #f))
            'path (dependency-path d)
            'target (car parts) 'target_version (cell (and (pair? (cdr parts)) (cadr parts))))))

(module+ test
  (require rackunit)
  (define lab
    (hasheq 'resourceType "StructureDefinition" 'id "lab" 'url "http://x/StructureDefinition/lab" 'version "0.2.0"
            'baseDefinition "http://x/StructureDefinition/result"
            'differential (hasheq 'element (list (hasheq 'path "Observation.code" 'binding (hasheq 'strength "required" 'valueSet "http://x/ValueSet/labs|1.0.0"))
                                                 (hasheq 'path "Observation.value[x]" 'type (list (hasheq 'code "Quantity")))
                                                 (hasheq 'path "Observation.subject"
                                                         'type (list (hasheq 'code "Reference" 'targetProfile (list "http://x/StructureDefinition/member"
                                                                                                                    "http://hl7.org/fhir/StructureDefinition/Group"))))))))
  ;; CRMI's paths, the base specification implied
  (check-equal? (direct-dependencies lab)
                (list (dependency "http://x/StructureDefinition/result" "baseDefinition")
                      (dependency "http://x/StructureDefinition/member" "differential.element.type.targetProfile")
                      (dependency "http://x/ValueSet/labs|1.0.0" "differential.element.binding.valueSet")))
  ;; any resource: the profiles it claims; a value set: what it includes, code systems too
  (check-equal? (direct-dependencies (hasheq 'resourceType "Observation" 'id "a1" 'meta (hasheq 'profile (list "http://x/StructureDefinition/lab"))))
                (list (dependency "http://x/StructureDefinition/lab" "meta.profile")))
  (define labs (hasheq 'resourceType "ValueSet" 'id "labs" 'url "http://x/ValueSet/labs" 'version "1.0.0"
                       'compose (hasheq 'include (list (hasheq 'system "http://loinc.org") (hasheq 'valueSet (list "http://x/ValueSet/chem"))))))
  (check-equal? (map dependency-canonical (direct-dependencies labs)) '("http://x/ValueSet/chem" "http://loinc.org"))
  ;; an element at any depth of nesting (`item..answerValueSet`), an element definition's fragment dropped
  (define q (hasheq 'resourceType "Questionnaire" 'id "q" 'url "http://x/Questionnaire/q"
                    'item (list (hasheq 'linkId "a" 'definition "http://x/StructureDefinition/lab#Observation.code"
                                        'item (list (hasheq 'linkId "a.1" 'answerValueSet "http://x/ValueSet/labs"
                                                            'item (list (hasheq 'linkId "a.1.1" 'answerValueSet "http://x/ValueSet/chem"))))))))
  (check-equal? (map dependency-canonical (direct-dependencies q))
                '("http://x/StructureDefinition/lab" "http://x/ValueSet/labs" "http://x/ValueSet/chem"))
  ;; the closure: each once, breadth first; what nothing defines is listed and not followed; a cycle ends
  (define a1c (hasheq 'resourceType "Library" 'id "A1c" 'url "http://x/Library/A1c" 'version "0.1.0"
                      'relatedArtifact (list (hasheq 'type "depends-on" 'resource "http://x/ValueSet/labs")
                                             (hasheq 'type "depends-on" 'resource "http://x/Library/A1c"))
                      'dataRequirement (list (hasheq 'type "Observation" 'profile (list "http://x/StructureDefinition/lab")
                                                     'codeFilter (list (hasheq 'path "code" 'valueSet "http://x/ValueSet/labs"))))))
  (define defined (list lab labs a1c (hasheq 'resourceType "StructureDefinition" 'id "result" 'url "http://x/StructureDefinition/result"
                                             'baseDefinition "http://x/StructureDefinition/lab")))
  (define (resolve c) (findf (lambda (r) (equal? (hash-ref r 'url) (url-of c))) defined))
  (define closure (dependency-closure a1c resolve))
  (check-equal? (for/list ([dr (in-list closure)]) (list (dependency-canonical (car dr)) (and (cdr dr) #t)))
                '(("http://x/ValueSet/labs" #t) ("http://x/StructureDefinition/lab" #t)
                  ("http://x/ValueSet/chem" #f) ("http://loinc.org" #f)
                  ("http://x/StructureDefinition/result" #t) ("http://x/StructureDefinition/member" #f)))
  ;; the module-definition Library: depends-on at the version resolved, the library's data requirements
  (define md (module-definition a1c closure))
  (check-equal? (hash-ref (hash-ref md 'type) 'coding) (list (hasheq 'system library-type 'code "module-definition")))
  (check-equal? (for/list ([ra (in-list (hash-ref md 'relatedArtifact))]) (hash-ref ra 'resource))
                '("http://x/ValueSet/labs|1.0.0" "http://x/StructureDefinition/lab|0.2.0" "http://x/ValueSet/chem" "http://loinc.org"
                  "http://x/StructureDefinition/result" "http://x/StructureDefinition/member"))
  (check-equal? (hash-ref md 'dataRequirement) (hash-ref a1c 'dataRequirement))
  ;; as rows
  (check-equal? (for/list ([row (in-list (dependency-rows (list lab)))]) (list (hash-ref row 'id) (hash-ref row 'path) (hash-ref row 'target) (hash-ref row 'target_version)))
                (list (list "lab" "baseDefinition" "http://x/StructureDefinition/result" (json-null))
                      (list "lab" "differential.element.type.targetProfile" "http://x/StructureDefinition/member" (json-null))
                      (list "lab" "differential.element.binding.valueSet" "http://x/ValueSet/labs" "1.0.0"))))
