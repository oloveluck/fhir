#lang racket/base

;;; crmi.rkt — operations of HL7's Canonical Resource Management Infrastructure (CRMI 2.0.0), as
;;; fhir/operation values on the guide's own OperationDefinitions (read from its package in
;;; fhir-spec; without the package nothing is registered).
;;;
;;;   $resolve   a canonical reference resolved to the resource it means: the version it names, else
;;;              the version the manifest parameters pin, else the latest — here the working copy a
;;;              workspace file defines, the stored version in force, the packages.
;;;
;;; The operation reads the repository through parameters, so it knows no hub: `current-repository`
;;; (every stored version), `current-manifest` (the pins in force), fhir/registry (working copies),
;;; `current-sd-packages`.

(require racket/list racket/match
         (only-in fhir/operation make-operation register-operation! input operation-error)
         (only-in fhir/package read-package)
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/registry registered-resource)
         (only-in fhir/data-source data-source-all)
         (only-in fhir/sd/sd-index resolve-canonical-raw sd-index-available?)
         "artifacts.rkt"
         (only-in "hub.rkt" current-repository current-manifest))

(provide resolve-canonical)

;; crmi-definition : file-name -> OperationDefinition | #f   one of the guide's, from its package
(define (crmi-definition name)
  (define tgz (spec-package-path "hl7.fhir.uv.crmi-2.0.0.tgz" #:optional? #t))
  (and tgz
       (let-values ([(_manifest resources _examples) (read-package tgz #:select (lambda (n) (equal? n name)))])
         (match resources
           [(cons (cons _ (? hash? od)) _) od]
           [(cons (? hash? od) _) od]
           [_ #f]))))

;; resolve-canonical : canonical type|#f manifest|#f -> (listof resource)   what a reference means
;; (CRMI, "Determining Latest Version"): `url|version` is that version; `url` is the version the
;; manifest pins, else the workspace's working copy, else the stored version in force, else the
;; packages'. With no type given every defining type is asked.
(define (resolve-canonical canonical type manifest)
  (define-values (url version)
    (match (regexp-match #rx"^([^|]+)(?:[|](.+))?$" canonical)
      [(list _ url version) (values url version)]
      [_ (values canonical #f)]))
  (define (versioned v r) (and r (equal? (hash-ref r 'version #f) v) r))
  (define (stored type) (let ([repository (current-repository)])
                          (if repository
                              (filter (lambda (r) (equal? (hash-ref r 'url #f) url)) ((data-source-all repository) type))
                              '())))
  (define (packaged type ref) (and (sd-index-available?) (with-handlers ([exn:fail? (lambda (_) #f)]) (resolve-canonical-raw type ref))))
  ;; of-version : type version -> resource | #f   the working copy, a stored instance, or a package's
  (define (of-version type v)
    (or (versioned v (registered-resource type url))
        (findf (lambda (r) (equal? (hash-ref r 'version #f) v)) (stored type))
        (versioned v (packaged type (string-append url "|" v)))))
  (define (resolved type)
    (define pin (and (not version) (pinned-version manifest type url)))
    (cond [version (of-version type version)]
          [(and pin (of-version type pin))]
          [(registered-resource type url)]
          [(let ([mine (stored type)]) (and (pair? mine) (car (versions-in-force manifest mine))))]
          [else (packaged type url)]))
  (filter-map resolved (if type (list type) artifact-types)))

;; inputs-manifest : inputs -> manifest | #f   the pins the request gives: `manifestParameters`,
;; and the version parameters given directly, which are the same pins unwrapped
(define pin-parameters
  '("default-canonical-version" "force-canonical-version" "default-valueset-version" "force-valueset-version"
    "default-system-version" "force-system-version" "system-version"))
(define (inputs-manifest in)
  (define given (input in "manifestParameters"))
  (define direct
    (for*/list ([name (in-list pin-parameters)] [v (in-list (hash-ref in name '()))] #:when (string? v))
      (hasheq 'name name 'valueCanonical v)))
  (cond [(and (null? direct) (hash? given)) given]
        [(null? direct) #f]
        [else (hasheq 'resourceType "Parameters"
                      'parameter (append direct (if (hash? given) (hash-ref given 'parameter '()) '())))]))

(define $resolve
  (let ([definition (crmi-definition "OperationDefinition-crmi-resolve.json")])
    (and definition
         (make-operation
          definition
          (lambda (in _subject)
            (define canonical (or (input in "canonical") (operation-error "required" "$resolve needs `canonical`: the reference to resolve")))
            (when (input in "manifest")
              (operation-error "not-supported" "$resolve takes the pins as `manifestParameters` (a Parameters resource); a manifest library by canonical is not read yet"))
            (match (resolve-canonical canonical (input in "resourceType") (or (inputs-manifest in) (current-manifest)))
              ['() (operation-error "not-found" "nothing here defines ~a" canonical)]
              [(list r) r]
              [rs (hasheq 'resourceType "Parameters"
                          'parameter (for/list ([r (in-list rs)]) (hasheq 'name "return" 'resource r)))]))))))

(when $resolve (register-operation! $resolve))

(module+ test
  (require rackunit (only-in fhir/data-source resources->data-source))
  (define (lab version status [id "lab"])
    (hasheq 'resourceType "StructureDefinition" 'id id 'url "http://x/StructureDefinition/lab" 'version version 'status status))
  (define (pins . url+versions)
    (hasheq 'resourceType "Parameters"
            'parameter (for/list ([v (in-list url+versions)]) (hasheq 'name "default-canonical-version" 'valueCanonical v))))
  (define (versions rs) (map (lambda (r) (hash-ref r 'version)) rs))
  (parameterize ([current-repository (resources->data-source (list (lab "0.1.0" "active" "lab-0.1.0") (lab "0.2.0" "draft")))])
    ;; unversioned: the version in force (the active one); pinned: the pin's; versioned: that version
    (check-equal? (versions (resolve-canonical "http://x/StructureDefinition/lab" "StructureDefinition" #f)) '("0.1.0"))
    (check-equal? (versions (resolve-canonical "http://x/StructureDefinition/lab" #f (pins "http://x/StructureDefinition/lab|0.2.0"))) '("0.2.0"))
    (check-equal? (versions (resolve-canonical "http://x/StructureDefinition/lab|0.2.0" #f #f)) '("0.2.0"))
    (check-equal? (resolve-canonical "http://x/StructureDefinition/lab|9.9.9" "StructureDefinition" #f) '())
    (check-equal? (resolve-canonical "http://x/StructureDefinition/nope" "StructureDefinition" #f) '())
    ;; the operation, when CRMI's package is at hand: by its definition's parameters
    (when $resolve
      (check-equal? (hash-ref ($resolve #:canonical "http://x/StructureDefinition/lab") 'version) "0.1.0")
      (check-equal? (hash-ref ($resolve #:canonical "http://x/StructureDefinition/lab" #:default-canonical-version "http://x/StructureDefinition/lab|0.2.0") 'version)
                    "0.2.0")
      (check-equal? (hash-ref ($resolve #:canonical "http://x/StructureDefinition/lab" #:manifestParameters (pins "http://x/StructureDefinition/lab|0.2.0")) 'version)
                    "0.2.0")
      (check-exn #rx"nothing here defines" (lambda () ($resolve #:canonical "http://x/StructureDefinition/nope"))))))
