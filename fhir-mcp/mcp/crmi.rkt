#lang racket/base

;;; crmi.rkt — operations of HL7's Canonical Resource Management Infrastructure (CRMI 2.0.0), as
;;; fhir/operation values on the guide's own OperationDefinitions (read from its package in
;;; fhir-spec; without the package nothing is registered).
;;;
;;;   $resolve   a canonical reference resolved to the resource it means: the version it names, else
;;;              the version the manifest parameters pin, else the latest — here the working copy a
;;;              workspace file defines, the stored version in force, the packages.
;;;   $data-requirements   what an artifact needs: a module-definition Library listing every
;;;              artifact it depends on, directly and through those (dependencies.rkt: CRMI's
;;;              "Dependency Tracing" paths), each resolved as $resolve resolves it, and the data
;;;              its libraries retrieve.
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
         "artifacts.rkt" "dependencies.rkt"
         (only-in "hub.rkt" current-repository current-manifest))

(provide resolve-canonical data-requirements)

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

;; ---- $data-requirements ------------------------------------------------------------------------
;; data-requirements : artifact manifest|#f -> Library   the artifact's effective requirements: its
;; dependencies traced to the end, each resolved under the pins, as a module-definition Library
(define (data-requirements root manifest)
  (module-definition root (dependency-closure root (lambda (canonical)
                                                     (match (resolve-canonical canonical #f manifest)
                                                       [(cons r _) r]
                                                       [_ #f])))))

;; version-manifest : inputs -> manifest | #f   the operation's own version parameters as pins:
;; `artifactVersion` gives a version to a reference that names none, `forceArtifactVersion` to any
(define (version-manifest in)
  (define pins
    (append (for/list ([v (in-list (hash-ref in "artifactVersion" '()))] #:when (string? v))
              (hasheq 'name "default-canonical-version" 'valueCanonical v))
            (for/list ([v (in-list (hash-ref in "forceArtifactVersion" '()))] #:when (string? v))
              (hasheq 'name "force-canonical-version" 'valueCanonical v))))
  (and (pair? pins) (hasheq 'resourceType "Parameters" 'parameter pins)))

;; by-id : id -> artifact | #f   a stored definition by its logical id (the type-level `id` input)
(define (by-id id)
  (define repository (current-repository))
  (and repository
       (for*/first ([type (in-list artifact-types)] [r (in-list ((data-source-all repository) type))]
                    #:when (equal? (hash-ref r 'id #f) id))
         r)))

(define $data-requirements
  (let ([definition (crmi-definition "OperationDefinition-crmi-data-requirements.json")])
    (and definition
         (make-operation
          definition
          (lambda (in subject)
            (for ([unread (in-list '("manifest" "expression" "parameters" "checkArtifactVersion"))] #:when (input in unread))
              (operation-error "not-supported" "$data-requirements does not read `~a` yet (pins are given as `artifactVersion`: url|version)" unread))
            (define manifest (or (version-manifest in) (current-manifest)))
            (define url (input in "url"))
            (define root
              (or (and (hash? subject) (hash-ref subject 'resourceType #f) subject)
                  (and url (match (resolve-canonical (let ([v (input in "version")]) (if v (format "~a|~a" url v) url)) #f manifest)
                             [(cons r _) r]
                             [_ (operation-error "not-found" "nothing here defines ~a" url)]))
                  (let ([id (input in "id")])
                    (and id (or (by-id id) (operation-error "not-found" "no stored definition has the id ~a (give `url`, a canonical)" id))))
                  (operation-error "required" "$data-requirements needs the artifact: `url` (its canonical), or `id`")))
            (data-requirements root manifest))))))

(when $data-requirements (register-operation! $data-requirements))

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
      (check-exn #rx"nothing here defines" (lambda () ($resolve #:canonical "http://x/StructureDefinition/nope")))))
  ;; $data-requirements: the artifact by url, its dependencies resolved as $resolve does (the pin's
  ;; version of the profile), what nothing defines listed all the same
  (define a1c (hasheq 'resourceType "Library" 'id "A1c" 'url "http://x/Library/A1c" 'version "0.1.0" 'status "active"
                      'relatedArtifact (list (hasheq 'type "depends-on" 'resource "http://loinc.org"))
                      'dataRequirement (list (hasheq 'type "Observation" 'profile (list "http://x/StructureDefinition/lab")))))
  (parameterize ([current-repository (resources->data-source (list (lab "0.1.0" "active" "lab-0.1.0") (lab "0.2.0" "draft") a1c))])
    (define (depends-on lib) (for/list ([ra (in-list (hash-ref lib 'relatedArtifact))]) (hash-ref ra 'resource)))
    (check-equal? (depends-on (data-requirements a1c #f)) '("http://loinc.org" "http://x/StructureDefinition/lab|0.1.0"))
    (when $data-requirements
      (define answered ($data-requirements #:url "http://x/Library/A1c"))
      (check-equal? (hash-ref (car (hash-ref (hash-ref answered 'type) 'coding)) 'code) "module-definition")
      (check-equal? (depends-on answered) '("http://loinc.org" "http://x/StructureDefinition/lab|0.1.0"))
      (check-equal? (hash-ref answered 'dataRequirement) (hash-ref a1c 'dataRequirement))
      (check-equal? (depends-on ($data-requirements #:url "http://x/Library/A1c" #:artifactVersion "http://x/StructureDefinition/lab|0.2.0"))
                    '("http://loinc.org" "http://x/StructureDefinition/lab|0.2.0"))
      (check-equal? (depends-on ($data-requirements #:id "A1c")) '("http://loinc.org" "http://x/StructureDefinition/lab|0.1.0"))
      (check-exn #rx"nothing here defines" (lambda () ($data-requirements #:url "http://x/Library/nope")))
      (check-exn #rx"needs the artifact" (lambda () ($data-requirements))))))
