#lang racket/base

;;; terminology/operations.rkt — the terminology operations as operation values (fhir/operation):
;;; ValueSet/$expand, ValueSet/$validate-code, CodeSystem/$lookup, ConceptMap/$translate.
;;;
;;;   ($expand vs "filter" "heart" "count" 10)            a ValueSet (piped, or "url" / "valueSet")
;;;   ($validate-code vs "code" "male" "system" "http://hl7.org/fhir/administrative-gender")
;;;   ($lookup #f "system" "http://loinc.org" "code" "8867-4")
;;;   ($translate cm "sourceCode" "home" "system" "…")      R5 names; R4's `code` is accepted too
;;; Definitions resolve from the inputs, then the current data source's ValueSets / CodeSystems /
;;; ConceptMaps, then `current-sd-packages` (indexed once per package list). Results are FHIR JSON.

(require racket/list
         (only-in fhir/r5/operations expand-definition ValueSet-validate-code-definition
                  lookup-definition translate-definition)
         fhir/operation fhir/data-source
         (only-in fhir/sd/sd-index sd-context current-sd-packages)
         (only-in "service.rkt" packages->resolver resources->resolver
                  expand/json validate-code/json lookup/json translate/json))

(provide $expand $validate-code $lookup $translate current-terminology-resolver)

;; the packages' resolver, built once per package list (indexing a core package takes seconds)
(define package-resolvers (make-hash))
(define (packages-resolver)
  (define pkgs (sd-context))
  (hash-ref! package-resolvers pkgs (lambda () (packages->resolver pkgs))))

;; current-terminology-resolver : [extra-resources] -> (url [version] -> resource|#f)
(define (current-terminology-resolver [extra '()])
  (define local (resources->resolver
                 (append extra
                         (append-map (lambda (t) ((data-source-all (current-data-source)) t))
                                     '("ValueSet" "CodeSystem" "ConceptMap")))))
  (define packages (packages-resolver))
  (lambda (url [version #f]) (or (local url version) (packages url version))))

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
                                "includeDesignations" "property"))]
                  #:when (input in k))
         (values k (input in k))))
     (expand/json resolver url (input in "valueSetVersion") params))))

(define $validate-code
  (make-operation
   ValueSet-validate-code-definition
   (lambda (in subject)
     (define-values (url resolver) (target-valueset in subject "$validate-code"))
     (validate-code/json resolver url (input in "code") (input in "system")
                         #:coding (input in "coding") #:codeable-concept (input in "codeableConcept")
                         #:display (input in "display") #:valueset-version (input in "valueSetVersion")))))

(define $lookup
  (make-operation
   lookup-definition
   (lambda (in subject)
     (define coding (input in "coding"))
     (define system (or (input in "system") (and coding (hash-ref coding 'system #f)) (and subject (hash-ref subject 'url #f))))
     (define code (or (input in "code") (and coding (hash-ref coding 'code #f))))
     (unless (and system code) (operation-error "required" "$lookup needs a code and a system (or a coding)"))
     (lookup/json (current-terminology-resolver (if subject (list subject) '())) system code (input in "version")))))

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

(for-each register-operation! (list $expand $validate-code $lookup $translate))

(module+ test
  (require rackunit (only-in fhir/spec-package spec-package-path))
  (define core (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t))
  (when core
    (parameterize ([current-sd-packages (list core)])
      (define gender "http://hl7.org/fhir/ValueSet/administrative-gender")
      (define vs ($expand #f "url" gender))
      (check-equal? (hash-ref (hash-ref vs 'expansion) 'total) 4)
      ;; piped, and by reference with a filter
      (check-equal? (hash-ref (hash-ref (call-operation "ValueSet/$expand" vs "filter" "fem") 'expansion) 'total) 1)
      (define (result ps) (for/first ([p (in-list (hash-ref ps 'parameter))] #:when (equal? (hash-ref p 'name) "result")) (hash-ref p 'valueBoolean)))
      (check-true (result ($validate-code #f "url" gender "code" "male" "system" "http://hl7.org/fhir/administrative-gender")))
      (check-false (result ($validate-code #f "url" gender "code" "florp" "system" "http://hl7.org/fhir/administrative-gender")))
      (check-exn #rx"not in the data source or the packages" (lambda () ($expand #f "url" "http://example.org/nope")))
      ;; a ValueSet from the data source
      (define local (hasheq 'resourceType "ValueSet" 'url "http://example.org/vs"
                            'compose (hasheq 'include (list (hasheq 'system "http://hl7.org/fhir/administrative-gender"
                                                                    'concept (list (hasheq 'code "male")))))))
      (parameterize ([current-data-source (resources->data-source (list local))])
        (check-equal? (hash-ref (hash-ref ($expand #f "url" "http://example.org/vs") 'expansion) 'total) 1)))))
