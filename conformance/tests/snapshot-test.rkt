#lang racket/base

;;; snapshot-test.rkt — property-based snapshot generation checks (the spirit of the official
;;; snapshot-generation manifest rules, asserted against the R5 core base snapshots).

(require rackunit
         racket/list
         (only-in fhir/conformance/snapshot generate-snapshot)
         (only-in fhir/conformance/sd-index resolve-sd-raw))

(define (snap-elements sd) (hash-ref (hash-ref sd 'snapshot) 'element))
(define (paths els) (map (lambda (e) (hash-ref e 'path)) els))
(define (by-path els p) (findf (lambda (e) (equal? (hash-ref e 'path) p)) els))

(define patient-base (snap-elements (resolve-sd-raw "Patient")))
(define observation-base (snap-elements (resolve-sd-raw "Observation")))

(define (profile type diff-elements)
  (hasheq 'resourceType "StructureDefinition" 'type type
          'baseDefinition (string-append "http://hl7.org/fhir/StructureDefinition/" type)
          'derivation "constraint"
          'differential (hasheq 'element diff-elements)))

;; ---- no-op profile: snapshot == base (same elements, same order) ----------------------------
(let ([snap (generate-snapshot (profile "Patient" '()))])
  (check-equal? (paths snap) (paths patient-base) "no-op keeps every base element in order"))

;; ---- cardinality: only the constrained element changes; count/order preserved ---------------
(let ([snap (generate-snapshot (profile "Patient"
                                        (list (hasheq 'id "Patient.identifier" 'path "Patient.identifier" 'min 1))))])
  (check-equal? (paths snap) (paths patient-base) "cardinality keeps element set/order")
  (check-equal? (hash-ref (by-path snap "Patient.identifier") 'min) 1 "identifier.min narrowed to 1")
  ;; the full base definition is preserved on the constrained element
  (check-true (hash-has-key? (by-path snap "Patient.identifier") 'base) "base[] preserved")
  (check-equal? (hash-ref (by-path snap "Patient.name") 'min)
                (hash-ref (by-path patient-base "Patient.name") 'min) "other elements untouched"))

;; ---- constraint accumulation: a differential invariant is ADDED to inherited ones ----------
(let* ([base-id-constraints (hash-ref (by-path patient-base "Patient.identifier") 'constraint '())]
       [snap (generate-snapshot (profile "Patient"
                                         (list (hasheq 'id "Patient.identifier" 'path "Patient.identifier"
                                                       'constraint (list (hasheq 'key "my-1" 'severity "error"
                                                                                 'human "x" 'expression "true"))))))]
       [cs (hash-ref (by-path snap "Patient.identifier") 'constraint '())])
  (check-true (> (length cs) (length base-id-constraints)) "differential constraint accumulates")
  (check-true (and (member "my-1" (map (lambda (c) (hash-ref c 'key)) cs)) #t) "new invariant present"))

;; ---- named slice: base element + the slice, re-rooted from the base at that path ------------
(let ([snap (generate-snapshot
             (profile "Observation"
                      (list (hasheq 'id "Observation.component" 'path "Observation.component" 'min 1)
                            (hasheq 'id "Observation.component:systolic" 'path "Observation.component"
                                    'sliceName "systolic" 'min 1 'max "1"))))])
  (define slice (findf (lambda (e) (equal? (hash-ref e 'id #f) "Observation.component:systolic")) snap))
  (check-true (and slice #t) "the slice element is present in the snapshot")
  (check-equal? (hash-ref slice 'sliceName) "systolic")
  ;; the slice inherits the base component definition (type Observation.component backbone)
  (check-true (hash-has-key? slice 'type) "slice re-rooted from the base element (carries type)"))
