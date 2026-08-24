#lang racket/base

;;; fhirpath-test.rkt — engine sanity checks (the full HL7 conformance suites run via
;;; `raco fhir fhirpath-tck [r4|r5]`; this is a fast in-tree smoke over the core features).

(require rackunit
         fhir/r5/schemas
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/result/result ok-value)
         (only-in fhir/fhirpath/parser/parse parse-fhirpath)
         (only-in fhir/fhirpath/eval eval-fhirpath)
         (only-in fhir/fhirpath/value item->system))

(define pat
  (ok-value
   (from-json (hasheq 'resourceType "Patient" 'active #t 'gender "male" 'birthDate "1974-12-25"
                      'name (list (hasheq 'use "official" 'family "Chalmers" 'given (list "Peter" "James"))
                                  (hasheq 'family "Windsor" 'given (list "Peter")))))))

;; evaluate against the patient, collapsing to System values
(define (E s) (map item->system (eval-fhirpath (parse-fhirpath s) (list pat))))

(check-equal? (E "Patient.name.given") '("Peter" "James" "Peter"))
(check-equal? (E "Patient.name.count()") '(2))
(check-equal? (E "Patient.name.where(use = 'official').family") '("Chalmers"))
(check-equal? (E "Patient.name.given.distinct()") '("Peter" "James"))
(check-equal? (E "Patient.active and true") '(#t))
(check-equal? (E "Patient.gender = 'male'") '(#t))
(check-equal? (E "(1 + 2) * 3") '(9))
(check-equal? (E "Patient.name.given.first()") '("Peter"))
(check-equal? (E "Patient.birthDate < today()") '(#t))
(check-equal? (E "Patient.name.exists()") '(#t))
(check-equal? (E "'abc'.upper()") '("ABC"))
(check-equal? (E "(4 'g' = 4000 'mg')") '(#t))              ; UCUM
(check-equal? (E "(7 days = 1 week)") '(#t))                ; calendar durations
(check-equal? (E "Patient.active.is(FHIR.boolean)") '(#t))
(check-equal? (E "Patient.active.is(System.Boolean)") '(#f)) ; FHIR primitive is not a System type
(check-equal? (E "@2015.is(Date)") '(#t))
(check-equal? (E "1.587.round(2)") (E "1.59"))
(check-equal? (E "Patient.name.select(given).count()") '(3))

;; ---- behaviors fixed while driving the conformance suites to 100% ----
(check-equal? (E "(2 'cm' * 2 'm' = 0.040 'm2')") '(#t))     ; UCUM product units
(check-equal? (E "(1 'm' / 1 'm' = 1 '1')") '(#t))           ; UCUM quotient -> dimensionless
(check-equal? (E "(4 'g' ~ 4040 'mg')") '(#t))               ; quantity ~ least-precision
(check-equal? (E "(1.587.lowBoundary(2) = 1.58)") '(#t))     ; decimal boundary
(check-equal? (E "Patient.gender.is(string)") '(#t))         ; code is a specialization of string
(check-equal? (E "Patient.gender.is(System.Boolean)") '(#f)) ; a FHIR primitive is not a System type
(check-equal? (E "defineVariable('v', 'x').select(%v)") '("x")) ; defineVariable scope
(check-equal? (E "(1 'cm').comparable(1 's')") '(#f))        ; dimensional incompatibility

;; static semantic analysis raises on invalid navigation
(require (only-in fhir/fhirpath/error exn:fp?))
(check-exn exn:fp? (lambda () (E "name.given1")))            ; unknown element
(check-exn exn:fp? (lambda () (E "Appointment.identifier.startsWith('x')")))  ; string-fn on complex

;; ---- %terminologies : the R5-core-backed terminology service ----
(require (only-in fhir/terminology/service make-r5-terminology))
(define tx (make-r5-terminology))
(define (T s) (map item->system
                   (eval-fhirpath (parse-fhirpath s) (list pat)
                                  #:externals (hash "terminologies" (list tx)))))
(check-equal? (T "%terminologies.expand('http://hl7.org/fhir/ValueSet/administrative-gender').expansion.contains.count()") '(4))
(check-equal? (T "%terminologies.validateVS('http://hl7.org/fhir/ValueSet/administrative-gender', 'male').parameter.where(name = 'result').value") '(#t))
(check-equal? (T "%terminologies.translate('http://hl7.org/fhir/ConceptMap/cm-address-use-v2', 'home').parameter.where(name = 'match').part.where(name = 'concept').value.code") '("H"))

;; now()/today()/timeOfDay() read ONE clock (local + real offset): the day components agree at any
;; hour, so `now() > today()` is 'empty by precision-mismatch — never true via a UTC day skew
(check-equal? (E "now() > today()") '())
(check-equal? (E "now().toString().substring(0, 10) = today().toString()") '(#t))
