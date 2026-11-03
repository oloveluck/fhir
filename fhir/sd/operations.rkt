#lang racket/base

;;; sd/operations.rkt — StructureDefinition/$snapshot as an operation value (fhir/operation).
;;;
;;;   ($snapshot sd)                         the StructureDefinition with its snapshot generated
;;;   (apply-operation "$snapshot" #:url "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient")
;;; The base definitions resolve through `current-sd-packages` (fhir/sd/sd-index) and the current
;;; data source's StructureDefinitions (fhir/data-source), the data source first.

(require (only-in fhir/r5/operations snapshot-definition)
         fhir/operation fhir/data-source
         (only-in fhir/sd/sd-index resolve-sd-raw)
         (only-in fhir/sd/snapshot generate-snapshot))

(provide $snapshot resolve-structure-definition)

;; resolve-structure-definition : canonical -> SD | #f   the current data source, then the packages
(define (resolve-structure-definition url)
  (define u (car (regexp-split #rx"[|]" url)))
  (or (findf (lambda (sd) (equal? (hash-ref sd 'url #f) u))
             ((data-source-all (current-data-source)) "StructureDefinition"))
      (resolve-sd-raw u)))

(define $snapshot
  (make-operation
   snapshot-definition #:subject "definition"
   (lambda (in _)
     (define sd (or (input in "definition")
                    (let ([u (input in "url")]) (and u (resolve-structure-definition u)))
                    (operation-error "not-found" "$snapshot needs a definition, or the url of one it can find")))
     (hash-set sd 'snapshot (hasheq 'element (generate-snapshot (hash-remove sd 'snapshot)))))))

(register-operation! $snapshot)

(module+ test
  (require rackunit (only-in fhir/sd/sd-index sd-index-available?))
  (when (sd-index-available?)
    (define sd (hasheq 'resourceType "StructureDefinition" 'url "http://example.org/StructureDefinition/p"
                       'type "Patient" 'derivation "constraint"
                       'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
                       'differential (hasheq 'element (list (hasheq 'id "Patient.gender" 'path "Patient.gender" 'min 1)))))
    (define out ($snapshot sd))
    (define gender (findf (lambda (e) (equal? (hash-ref e 'id #f) "Patient.gender")) (hash-ref (hash-ref out 'snapshot) 'element)))
    (check-equal? (hash-ref gender 'min) 1)
    ;; by reference, by url (resolved from the packages)
    (check-true (pair? (hash-ref (hash-ref (apply-operation "http://hl7.org/fhir/OperationDefinition/StructureDefinition-snapshot"
                                                             #:url "http://hl7.org/fhir/StructureDefinition/Patient")
                                           'snapshot) 'element)))))
