#lang racket/base

;;; conformance/operations.rkt — Resource/$validate as an operation value (fhir/operation).
;;;
;;;   ($validate resource)                         against its base type and its meta.profile
;;;   ($validate resource #:profile canonical)     … and that profile (an OperationOutcome either way)
;;;   (ensure-valid resource [#:profile canonical]) the resource itself when valid, else
;;;                                                exn:fail:operation carrying the outcome — a
;;;                                                pipeline step: (~> r … (ensure-valid) …)
;;; Profiles resolve through the current data source (fhir/data-source) and `current-sd-packages`;
;;; a StructureDefinition in the data source that the resource claims in meta.profile is applied too.
;;; Required bindings are checked against the value sets of the data source and the packages (the
;;; terminology service); a value set nothing can expand stays undecided (fail-open).

(require racket/list
         (only-in fhir/r5/operations validate-definition)
         fhir/operation fhir/data-source
         (only-in fhir/sd/operations resolve-structure-definition)
         (only-in fhir/registry registered-resources)
         (only-in fhir/serialize/read-json strip-jnum)
         (only-in fhir/conformance/validate validate-issues issue-severity issue-code issue-path issue-msg)
         (only-in fhir/terminology/operations current-terminology-resolver)
         (only-in fhir/terminology/service make-terminology/resolver))

(provide $validate ensure-valid)

;; issues->outcome : (listof issue) -> OperationOutcome
(define (issues->outcome issues)
  (hasheq 'resourceType "OperationOutcome"
          'issue (if (null? issues)
                     (list (hasheq 'severity "information" 'code "informational" 'diagnostics "All OK"))
                     (for/list ([i (in-list issues)])
                       (hasheq 'severity (issue-severity i) 'code (issue-code i)
                               'diagnostics (issue-msg i) 'expression (list (issue-path i)))))))

(define $validate
  (make-operation
   validate-definition #:subject "resource"
   (lambda (in _)
     (define r (or (input in "resource") (operation-error "required" "$validate needs a resource")))
     (define profile
       (let ([u (input in "profile")])
         (and u (or (resolve-structure-definition u)
                    (operation-error "not-found" "$validate: profile ~a is not in the data source or the packages" u)))))
     ;; the data source's and the registered modules' own profiles that the resource claims (the
     ;; packages' resolve by themselves)
     (define claimed
       (let ([urls (let ([m (hash-ref r 'meta #f)]) (if (hash? m) (hash-ref m 'profile '()) '()))])
         (filter (lambda (sd) (member (hash-ref sd 'url #f) urls))
                 (append ((data-source-all (current-data-source)) "StructureDefinition")
                         (registered-resources "StructureDefinition")))))
     (issues->outcome (validate-issues (strip-jnum r) #:profiles (remove-duplicates (append (if profile (list profile) '()) claimed))
                                       #:terminology (make-terminology/resolver (current-terminology-resolver)))))))

;; ensure-valid : resource [#:profile canonical] -> resource   or exn:fail:operation with the outcome
(define (ensure-valid r #:profile [profile #f])
  (define oo (if profile ($validate r #:profile profile) ($validate r)))
  (if (outcome-errors? oo)
      (raise (exn:fail:operation
              (format "invalid ~a: ~a" (hash-ref r 'resourceType "resource")
                      (for/first ([i (in-list (hash-ref oo 'issue))] #:when (member (hash-ref i 'severity) '("error" "fatal")))
                        (format "~a ~a" (car (hash-ref i 'expression '(""))) (hash-ref i 'diagnostics ""))))
              (current-continuation-marks) oo))
      r))

(register-operation! $validate)

(module+ test
  (require rackunit (only-in fhir/r5/schemas))
  (define ok (hasheq 'resourceType "Patient" 'gender "male"))
  (define bad (hasheq 'resourceType "Patient" 'gender "male" 'nmae "x"))
  (check-false (outcome-errors? ($validate ok)))
  (check-true (outcome-errors? ($validate bad)))
  (check-equal? (ensure-valid ok) ok)
  (check-exn #rx"invalid Patient: Patient.nmae" (lambda () (ensure-valid bad)))
  (check-equal? (~> ok (ensure-valid) ($validate) (outcome-errors?)) #f)
  ;; a profile from the data source, by reference
  (define sd (hasheq 'resourceType "StructureDefinition" 'url "http://example.org/StructureDefinition/named"
                     'type "Patient" 'derivation "constraint" 'kind "resource" 'abstract #f
                     'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient"
                     'differential (hasheq 'element (list (hasheq 'id "Patient" 'path "Patient")
                                                          (hasheq 'id "Patient.name" 'path "Patient.name" 'min 1)))))
  (parameterize ([current-data-source (resources->data-source (list sd))])
    (check-true (outcome-errors? (apply-operation "$validate" ok #:profile "http://example.org/StructureDefinition/named")))
    (check-false (outcome-errors? (apply-operation "Resource/$validate" (hash-set ok 'name (list (hasheq 'family "X")))
                                                   #:profile "http://example.org/StructureDefinition/named")))))
