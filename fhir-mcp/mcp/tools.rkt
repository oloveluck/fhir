#lang racket/base

;;; tools.rkt — what a tool is, and the lookups the workspace's tools share.
;;;
;;; A Tool is (tool name description input-schema run):
;;;   name         : ^[a-zA-Z0-9_-]{1,64}$ (the protocol's rule)
;;;   description  : for the model that calls it
;;;   input-schema : a JSON Schema object for the arguments
;;;   run          : arguments(hash) -> (values text error?)
;;; The lookups: the operation modules loaded so their operations register (`load-operations!`), an
;;; operation applied to JSON inputs (`apply-json`), an element of a type or profile in the packages
;;; (`element-info`), and definitions found by a fragment of their name (`find-definitions`).

(require racket/contract racket/string racket/list json
         (only-in fhir/operation operation? operation-subject invoke)
         (only-in fhir/sd/sd-index resolve-sd-raw resolve-canonical-raw sd-index-available? sd-context)
         (only-in fhir/package read-package))

(provide
 (struct-out tool)
 (contract-out
  [tool->jsexpr      (-> tool? hash?)]
  [call-tool         (-> tool? hash? (values string? boolean?))]
  [load-operations!  (-> (listof symbol?))]
  ;; apply-json : operation inputs resource|#f -> resource   inputs by name (a list for several
  ;; values); the resource is what the operation applies to (its subject input, or itself)
  [apply-json        (-> operation? hash? (or/c hash? #f) hash?)]
  ;; element-info : type-or-profile path|#f -> (listof element summary) | string   a string says why not
  [element-info      (-> string? (or/c string? #f) (or/c list? string?))]
  ;; find-definitions : fragment resourceType|#f limit -> summaries   over the packages in context
  [find-definitions  (-> string? (or/c string? #f) exact-positive-integer? list?)]))

(struct tool (name description input-schema run) #:transparent)

(define (tool->jsexpr t)
  (hasheq 'name (tool-name t) 'description (tool-description t) 'inputSchema (tool-input-schema t)))

;; call-tool : tool arguments -> (values text error?)   never raises
(define (call-tool t args)
  (with-handlers ([exn:fail? (lambda (e) (values (exn-message e) #t))])
    ((tool-run t) args)))

;; ---- operations ---------------------------------------------------------------------------------
;; the modules that register operations, each loaded when its package is installed
(define operation-modules
  '(fhir/sd/operations fhir/conformance/operations fhir/terminology/operations
    fml/operations cql/measure sql-on-fhir/operations))
(define (load-operations!)
  (for/list ([m (in-list operation-modules)]
             #:when (with-handlers ([exn:fail? (lambda (_) #f)]) (dynamic-require m #f) #t))
    m))

(define (apply-json o inputs resource)
  (define subject-input (operation-subject o))
  (define given (for/hash ([(k v) (in-hash inputs)]) (values (format "~a" k) (if (list? v) v (list v)))))
  (cond [(and resource subject-input) (invoke o #f (hash-set given subject-input (list resource)))]
        [else (invoke o resource given)]))

;; ---- definitions in the packages ------------------------------------------------------------------
(define (element-info type path)
  (cond
    [(not (sd-index-available?)) "no FHIR packages are in context"]
    [else
     (define sd (or (resolve-sd-raw type) (resolve-canonical-raw "StructureDefinition" type)))
     (define els (and (hash? sd) (hash-ref (hash-ref sd 'snapshot (hasheq)) 'element #f)))
     (cond
       [(not (list? els)) (format "no StructureDefinition with a snapshot for ~a" type)]
       [else
        (define root (hash-ref (car els) 'path type))
        (define want (if path (string-append root "." path) root))
        (define depth (length (string-split want ".")))
        (define picked
          (if path
              (filter (lambda (e) (or (equal? (hash-ref e 'path "") want) (equal? (hash-ref e 'id "") want)
                                      (choice-of? (hash-ref e 'path "") want)))
                      els)
              (filter (lambda (e) (= (length (string-split (hash-ref e 'path "") ".")) (add1 depth))) els)))
        (if (null? picked) (format "~a has no element ~a" type path) (map element-summary picked))])]))

;; element-summary : ElementDefinition -> jsexpr   the parts an author needs
(define (element-summary e)
  (for/hasheq ([k '(id path min max type short definition binding sliceName fixedUri patternCodeableConcept)]
               #:when (hash-has-key? e k))
    (values k (hash-ref e k))))
;; choice-of? : element-path wanted -> boolean   "Observation.value[x]" answers for "Observation.valueQuantity"
(define (choice-of? el-path want)
  (and (regexp-match? #rx"\\[x\\]$" el-path)
       (let ([stem (substring el-path 0 (- (string-length el-path) 3))])
         (and (string-prefix? want stem) (> (string-length want) (string-length stem))
              (char-upper-case? (string-ref want (string-length stem)))))))

;; find-definitions : query type|#f limit -> (listof summary)   over every package in context, by the
;; resource file name (Type-id.json), then the resource's name, title and url
(define (find-definitions q rt limit)
  (define rx (regexp (regexp-quote (string-downcase q))))
  (define (hit? s) (and (string? s) (regexp-match? rx (string-downcase s))))
  (define kinds '("StructureDefinition" "ValueSet" "CodeSystem" "OperationDefinition" "SearchParameter" "CapabilityStatement" "ConceptMap"))
  (let/ec done
    (define found '())
    (for ([pkg (in-list (sd-context))])
      (define-values (_m rs _ex)
        (read-package pkg #:select (lambda (name)
                                     (define t (car (string-split name "-")))
                                     (and (member t kinds) (or (not rt) (equal? t rt)) (hit? name)))))
      (for ([fr (in-list rs)] #:when (and (pair? fr) (hash? (cdr fr))))     ; read-package gives (file . resource)
        (define r (cdr fr))
        (set! found (cons (for/hasheq ([k '(resourceType id url name title type kind derivation status)] #:when (hash-has-key? r k)) (values k (hash-ref r k))) found))
        (when (>= (length found) limit) (done (reverse found)))))
    (reverse found)))

(module+ test
  (require rackunit (only-in fhir/operation make-operation)
           (only-in fhir/sd/sd-index current-sd-packages) (only-in fhir/spec-package spec-package-path))
  ;; an operation applied to JSON: inputs as lists; a resource fills the subject input, or is the subject
  (define od (hasheq 'resourceType "OperationDefinition" 'url "http://example.org/OperationDefinition/greet" 'code "greet"
                     'system #t 'type #f 'instance #f
                     'parameter (list (hasheq 'name "name" 'use "in" 'min 1 'max "1" 'type "string")
                                      (hasheq 'name "return" 'use "out" 'min 1 'max "1" 'type "Parameters"))))
  (define $greet (make-operation od (lambda (in subject)
                                      (hasheq 'resourceType "Parameters"
                                              'parameter (list (hasheq 'name "result" 'valueString (format "hello ~a" (car (hash-ref in "name")))))))))
  (check-regexp-match #rx"hello Ann" (jsexpr->string (apply-json $greet (hasheq 'name "Ann") #f)))
  (check-exn exn:fail? (lambda () (apply-json $greet (hasheq) #f)))
  (define t (tool "t" "boom" (hasheq) (lambda (a) (error "bad"))))
  (define-values (txt err?) (call-tool t (hasheq)))
  (check-true err?)
  (check-true (jsexpr? (tool->jsexpr t)))
  ;; the definitions, over the R5 core when fhir-spec is installed
  (define core (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t))
  (when core
    (parameterize ([current-sd-packages (list core)])
      (check-equal? (hash-ref (car (element-info "Observation" "component.code")) 'path) "Observation.component.code")
      (check-equal? (hash-ref (car (element-info "Observation" "valueQuantity")) 'path) "Observation.value[x]")
      (check-true (> (length (element-info "Observation" #f)) 10))
      (check-regexp-match #rx"has no element" (element-info "Observation" "nope"))
      (check-true (ormap (lambda (r) (equal? (hash-ref r 'id #f) "administrative-gender"))
                         (find-definitions "administrative-gender" "ValueSet" 10))))))
