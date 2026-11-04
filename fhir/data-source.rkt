#lang racket/base

;;; data-source.rkt — where an operation's FHIR data comes from, independent of any server.
;;;
;;; A DataSource is (data-source all read of-patient search)
;;;   all        : type -> (listof resource)               every resource of a type
;;;   read       : type id -> resource | #f
;;;   of-patient : type patient-id -> (listof resource)    a patient's resources of a type
;;;   search     : (type (listof (cons name value)) -> (listof resource)) | #f
;;;                FHIR search, when the source can execute it (the SQLite store); #f otherwise
;;; Resources are FHIR JSON (jsexpr). Three sources ship: in memory (`resources->data-source`, which
;;; also takes Bundles), a directory of JSON files (`directory->data-source`), and the store
;;; (fhir-server's `store->data-source`). `current-data-source` is what operations read.
;;;
;;; A patient's resources are found by reference: `Patient/<id>` in the resource's patient, subject,
;;; beneficiary or individual (the elements CQL's patient context and the core compartment use), and
;;; the Patient itself by id.

(require racket/contract racket/list racket/string racket/file
         (only-in json read-json))

(provide
 (struct-out data-source)
 (contract-out
  [resources->data-source (-> (listof hash?) data-source?)]
  [directory->data-source (-> path-string? data-source?)]
  [empty-data-source data-source?]
  [current-data-source (parameter/c data-source?)]
  [patient-reference-of (-> hash? (listof string?))]
  [bundle-resources (-> hash? (listof hash?))]))

(struct data-source (all read of-patient search))

;; bundle-resources : resource -> (listof resource)   a Bundle's entries (nested Bundles flattened),
;; any other resource as itself
(define (bundle-resources r)
  (if (equal? (hash-ref r 'resourceType #f) "Bundle")
      (append* (for/list ([e (in-list (hash-ref r 'entry '()))] #:when (hash? (hash-ref e 'resource #f)))
                 (bundle-resources (hash-ref e 'resource))))
      (list r)))

;; patient-reference-of : resource -> (listof "Patient/id")   the patient references it carries
(define patient-elements '(patient subject beneficiary individual))
(define (patient-reference-of r)
  (for*/list ([k (in-list patient-elements)]
              [v (in-value (hash-ref r k #f))] #:when v
              [ref (in-list (if (list? v) v (list v)))]
              #:when (and (hash? ref) (string? (hash-ref ref 'reference #f))
                          (regexp-match? #rx"^Patient/" (hash-ref ref 'reference))))
    (hash-ref ref 'reference)))

;; resources->data-source : (listof resource) -> data-source   Bundles contribute their entries
(define (resources->data-source rs0)
  (define rs (append-map bundle-resources rs0))
  (define by-type (group-by (lambda (r) (hash-ref r 'resourceType #f)) rs))
  (define table (for/hash ([g (in-list by-type)]) (values (hash-ref (car g) 'resourceType #f) g)))
  (define (all type) (hash-ref table type '()))
  (data-source all
               (lambda (type id) (findf (lambda (r) (equal? (hash-ref r 'id #f) id)) (all type)))
               (lambda (type pid)
                 (if (equal? type "Patient")
                     (filter (lambda (r) (equal? (hash-ref r 'id #f) pid)) (all type))
                     (let ([ref (string-append "Patient/" pid)])
                       (filter (lambda (r) (member ref (patient-reference-of r))) (all type)))))
               #f))

;; directory->data-source : dir -> data-source   every *.json under it (recursively), read once
(define (directory->data-source dir)
  (resources->data-source
   (for*/list ([f (in-directory dir)]
               #:when (regexp-match? #rx"[.]json$" (path->string f))
               [js (in-value (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))]
               #:when (and (hash? js) (string? (hash-ref js 'resourceType #f))))
     js)))

(define empty-data-source (resources->data-source '()))
(define current-data-source (make-parameter empty-data-source))

(module+ test
  (require rackunit)
  (define p (hasheq 'resourceType "Patient" 'id "p1"))
  (define o (hasheq 'resourceType "Observation" 'id "o1" 'subject (hasheq 'reference "Patient/p1")))
  (define o2 (hasheq 'resourceType "Observation" 'id "o2" 'subject (hasheq 'reference "Patient/p2")))
  (define ds (resources->data-source
              (list (hasheq 'resourceType "Bundle" 'entry (list (hasheq 'resource p) (hasheq 'resource o)))
                    o2)))
  (check-equal? (length ((data-source-all ds) "Observation")) 2)
  (check-equal? ((data-source-read ds) "Patient" "p1") p)
  (check-equal? ((data-source-of-patient ds) "Observation" "p1") (list o))
  (check-equal? ((data-source-of-patient ds) "Patient" "p1") (list p))
  (check-false (data-source-search ds)))
