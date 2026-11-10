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

(require racket/list racket/string
         (only-in fhir/r5/operations validate-definition)
         fhir/operation fhir/data-source
         (only-in fhir/sd/operations resolve-structure-definition)
         (only-in fhir/sd/sd-index current-sd-packages)
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
                     (list (hasheq 'severity "information" 'code "informational"
                                  ;; which FHIR it was held to (an R6 server's "All OK" for data written as R4)
                                  'diagnostics (let ([v (validated-in)]) (if v (format "All OK (FHIR ~a)" v) "All OK"))))
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
      ;; every error, one per line: a resource missing two required elements says both
      (raise (exn:fail:operation
              (format "invalid ~a~a:~a" (hash-ref r 'resourceType "resource") (against-what r profile)
                      (apply string-append
                             (for/list ([i (in-list (hash-ref oo 'issue))] #:when (member (hash-ref i 'severity) '("error" "fatal")))
                               (format "\n  ~a ~a" (car (hash-ref i 'expression '(""))) (hash-ref i 'diagnostics "")))))
              (current-continuation-marks) oo))
      r))

;; against-what : resource profile -> string   which profiles held it: the one asked for, the claimed
(define (against-what r profile)
  (define asked (cond [(string? profile) (list profile)]
                      [(hash? profile) (list (hash-ref profile 'url (hash-ref profile 'id "a profile")))]
                      [else '()]))
  (define claimed (let* ([m (hash-ref r 'meta #f)] [p (and (hash? m) (hash-ref m 'profile '()))]) (if (list? p) p '())))
  (define all (remove-duplicates (append asked claimed)))
  (string-append (if (null? all) "" (format " against ~a" (string-join all ", ")))
                 (let ([v (validated-in)]) (if v (format " (FHIR ~a)" v) ""))))

;; validated-in : -> string|#f   the FHIR version of the core package validation reads: the last core
;; package of current-sd-packages, else R5 (sd-index's default)
(define (validated-in)
  (define pkgs (or (current-sd-packages) '()))
  (define core (for/last ([p (in-list pkgs)]
                          #:when (regexp-match? #rx"hl7[.]fhir[.]r[456][.]core" (if (path? p) (path->string p) p)))
                 (if (path? p) (path->string p) p)))
  (cond [(not core) (and (null? pkgs) "R5 (5.0.0)")]
        [(regexp-match? #rx"r4[.]core" core) "R4 (4.0.1)"]
        [(regexp-match? #rx"r5[.]core" core) "R5 (5.0.0)"]
        [else "R6"]))

(register-operation! $validate)

(module+ test
  (require rackunit (only-in fhir/r5/schemas))
  (define ok (hasheq 'resourceType "Patient" 'gender "male"))
  (define bad (hasheq 'resourceType "Patient" 'gender "male" 'nmae "x"))
  (check-false (outcome-errors? ($validate ok)))
  ;; a clean result says which FHIR it was held to (a server's "All OK" did not)
  (check-equal? (hash-ref (car (hash-ref ($validate ok) 'issue)) 'diagnostics) "All OK (FHIR R5 (5.0.0))")
  (check-true (outcome-errors? ($validate bad)))
  (check-equal? (ensure-valid ok) ok)
  (check-exn #rx"invalid Patient [(]FHIR R5 [(]5.0.0[)][)]:\n  Patient.nmae" (lambda () (ensure-valid bad)))
  (check-exn #rx"nmae.*\n  .*birthDate" (lambda () (ensure-valid (hash-set bad 'birthDate "1965-13-45"))))
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
                                                   #:profile "http://example.org/StructureDefinition/named")))
    ;; the error names the profile it broke
    (check-exn #rx"^invalid Patient against http://example.org/StructureDefinition/named [(]FHIR R5 [(]5.0.0[)][)]:\n  Patient.name"
               (lambda () (ensure-valid ok #:profile "http://example.org/StructureDefinition/named")))))
