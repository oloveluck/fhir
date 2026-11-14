#lang racket/base

;;; digest.rkt — a resource in one row: what it is about, its value, when, its status, whose it
;;; is. A search that answers ids alone sends its reader back for every resource; a search that
;;; answers whole resources spends the answer on JSON. A Digest is the handful of facts a reader
;;; decides by, read from the resource's own JSON (any FHIR version: R4's
;;; `medicationCodeableConcept` and R5's `medication.concept` are both "medication"), each under
;;; the element's own name without a choice's type (`valueQuantity` -> value, `effectivePeriod` ->
;;; effective), so the column says where the fact is.
;;;
;;; A Slot is (list candidate …): the first candidate element a resource has fills the slot. A
;;; candidate is an element name, or a name ending in `[x]` for a choice (any `name<Type>` key).

(require racket/contract racket/list racket/string json)

(provide
 (contract-out
  ;; digest : resource -> (listof (cons column text))   the filled slots, in slot order
  [digest (-> hash? (listof (cons/c symbol? string?)))]
  ;; digest-columns : (listof Digest) -> (listof symbol)   the columns the digests fill, in the
  ;; order they first appear
  [digest-columns (-> (listof (listof (cons/c symbol? string?))) (listof symbol?))]
  ;; value-text : jsexpr -> string | #f   a FHIR value as a person reads it (`8.9 %`, a concept's
  ;; text, `2125-03-01 – 2125-03-04`), #f when there is nothing to say
  [value-text (-> any/c (or/c string? #f))]))

(define slots
  '((code medication\[x\] vaccineCode name type class)
    (value\[x\] component)
    (dosageInstruction dosage)
    (effective\[x\] onset\[x\] performed\[x\] occurrence\[x\] authoredOn recordedDate period issued whenHandedOver date birthDate)
    (status clinicalStatus)
    (gender)
    (subject patient beneficiary)
    (encounter context)))

;; candidate-value : resource candidate -> (cons column value) | #f
(define (candidate-value r cand)
  (define s (symbol->string cand))
  (cond
    [(regexp-match #rx"^(.*)\\[x\\]$" s)
     => (lambda (m)
          (define base (cadr m))
          (for/first ([(k v) (in-hash r)]
                      #:when (let ([ks (symbol->string k)])
                               (or (string=? ks base)
                                   (and (> (string-length ks) (string-length base))
                                        (string=? (substring ks 0 (string-length base)) base)
                                        (char-upper-case? (string-ref ks (string-length base)))))))
            (cons (string->symbol base) v)))]
    [(hash-ref r cand #f) => (lambda (v) (cons cand v))]
    [else #f]))

(define (digest r)
  (for*/list ([slot (in-list slots)]
              [found (in-value (for/or ([c (in-list slot)]) (candidate-value r c)))]
              #:when found
              [text (in-value (if (eq? (car found) 'component) (components-text (cdr found)) (value-text (cdr found))))]
              #:when text)
    (cons (car found) text)))

(define (digest-columns ds)
  (remove-duplicates (append-map (lambda (d) (map car d)) ds)))

;; components-text : (listof component) -> string | #f   an Observation's components, their values
;; joined (`142 mm[Hg] / 91 mm[Hg]`)
(define (components-text cs)
  (define parts (if (list? cs)
                    (filter values (for/list ([c (in-list cs)] #:when (hash? c))
                                     (let ([v (candidate-value c 'value\[x\])]) (and v (value-text (cdr v))))))
                    '()))
  (and (pair? parts) (string-join parts " / ")))

(define max-text 80)
(define (cut s) (if (> (string-length s) max-text) (string-append (substring s 0 (sub1 max-text)) "…") s))

(define (value-text v)
  (define t (text-of v))
  (and t (not (string=? t "")) (cut t)))

;; text-of : jsexpr -> string | #f   by the shape of the value: FHIR's datatypes are told apart by
;; the elements they have
(define (text-of v)
  (define (str k) (let ([x (and (hash? v) (hash-ref v k #f))]) (and (string? x) x)))
  (cond
    [(string? v) v]
    [(boolean? v) (if v "true" "false")]
    [(number? v) (number-text v)]
    [(null? v) #f]
    [(list? v)                                             ; a repeating element: its first that says something
     (define all (filter values (map text-of v)))
     (cond [(null? all) #f]
           [(null? (cdr all)) (car all)]
           [else (format "~a (+~a)" (car all) (sub1 (length all)))])]
    [(not (hash? v)) #f]
    ;; Quantity (and Age, Duration, Money): the number with its unit
    [(number? (hash-ref v 'value #f))
     (string-append (or (str 'comparator) "") (number-text (hash-ref v 'value))
                    (let ([u (or (str 'unit) (str 'code) (str 'currency))]) (if u (string-append " " u) "")))]
    ;; CodeableConcept: its text, else its first coding
    [(or (hash-ref v 'coding #f) (str 'text))
     (or (str 'text) (text-of (hash-ref v 'coding '())))]
    ;; Coding
    [(or (str 'display) (str 'code))
     (or (str 'display) (str 'code))]
    ;; CodeableReference (R5): the concept, else the reference
    [(or (hash-ref v 'concept #f) (and (hash? (hash-ref v 'reference #f)) (hash-ref v 'reference)))
     => text-of]
    ;; Reference
    [(str 'reference) => values]
    ;; HumanName
    [(or (str 'family) (hash-ref v 'given #f))
     (string-join (append (filter string? (let ([g (hash-ref v 'given '())]) (if (list? g) g '())))
                          (if (str 'family) (list (str 'family)) '()))
                  " ")]
    ;; Period
    [(or (str 'start) (str 'end))
     (format "~a – ~a" (or (str 'start) "…") (or (str 'end) "…"))]
    ;; Range, Ratio
    [(or (hash-ref v 'low #f) (hash-ref v 'high #f))
     (format "~a – ~a" (or (text-of (hash-ref v 'low #f)) "…") (or (text-of (hash-ref v 'high #f)) "…"))]
    [(and (hash-ref v 'numerator #f) (hash-ref v 'denominator #f))
     (format "~a / ~a" (or (text-of (hash-ref v 'numerator)) "?") (or (text-of (hash-ref v 'denominator)) "?"))]
    ;; a Dosage: its text, else the dose
    [(hash-ref v 'doseAndRate #f)
     (or (str 'text)
         (for/or ([d (in-list (let ([ds (hash-ref v 'doseAndRate)]) (if (list? ds) ds '())))] #:when (hash? d))
           (let ([q (candidate-value d 'dose\[x\])]) (and q (text-of (cdr q))))))]
    ;; an Identifier or another value with a `value` that is text
    [(str 'value) => values]
    [else #f]))

;; number-text : number -> string   8.0 as 8, 8.9 as 8.9
(define (number-text n)
  (cond [(and (inexact? n) (= n (round n)) (< (abs n) 1e15)) (number->string (inexact->exact (round n)))]
        [else (number->string n)]))

(module+ test
  (require rackunit)
  (define (concept system code display) (hasheq 'coding (list (hasheq 'system system 'code code 'display display))))
  ;; an Observation: what, value, when, status, whose, where
  (check-equal? (digest (hasheq 'resourceType "Observation" 'id "a1" 'status "final"
                                'code (concept "http://loinc.org" "4548-4" "Hemoglobin A1c")
                                'subject (hasheq 'reference "Patient/ann")
                                'encounter (hasheq 'reference "Encounter/e1")
                                'effectiveDateTime "2025-03-01"
                                'valueQuantity (hasheq 'value 8.9 'unit "%" 'code "%")))
                '((code . "Hemoglobin A1c") (value . "8.9 %") (effective . "2025-03-01") (status . "final")
                  (subject . "Patient/ann") (encounter . "Encounter/e1")))
  ;; a blood pressure: its components joined; a period; a coded value
  (check-equal? (digest (hasheq 'resourceType "Observation" 'code (hasheq 'text "BP")
                                'effectivePeriod (hasheq 'start "2025-03-01" 'end "2025-03-02")
                                'component (list (hasheq 'valueQuantity (hasheq 'value 142.0 'unit "mm[Hg]"))
                                                 (hasheq 'valueQuantity (hasheq 'value 91 'unit "mm[Hg]")))))
                '((code . "BP") (component . "142 mm[Hg] / 91 mm[Hg]") (effective . "2025-03-01 – 2025-03-02")))
  (check-equal? (digest (hasheq 'resourceType "Observation" 'valueCodeableConcept (concept "s" "pos" "Positive")))
                '((value . "Positive")))
  ;; a medication, by R4's two shapes and R5's one; a dose
  (check-equal? (digest (hasheq 'resourceType "MedicationRequest" 'status "stopped" 'authoredOn "2130-11-01T09:43:48-04:00"
                                'medicationReference (hasheq 'reference "Medication/m1")
                                'dosageInstruction (list (hasheq 'text "10mEq ER Tablet" 'doseAndRate (list (hasheq 'doseQuantity (hasheq 'value 40 'unit "mEq")))))))
                '((medication . "Medication/m1") (dosageInstruction . "10mEq ER Tablet")
                  (authoredOn . "2130-11-01T09:43:48-04:00") (status . "stopped")))
  (check-equal? (digest (hasheq 'medicationCodeableConcept (hasheq 'coding (list (hasheq 'code "00064065001")))
                                'dosageInstruction (list (hasheq 'doseAndRate (list (hasheq 'doseQuantity (hasheq 'value 40 'unit "mEq")))))))
                '((medication . "00064065001") (dosageInstruction . "40 mEq")))
  (check-equal? (digest (hasheq 'medication (hasheq 'concept (hasheq 'text "Metformin")))) '((medication . "Metformin")))
  ;; a Patient: name, birth date, gender; an Encounter: class and period
  (check-equal? (digest (hasheq 'resourceType "Patient" 'gender "female" 'birthDate "1960-01-01"
                                'name (list (hasheq 'family "Ng" 'given '("Ann" "Marie")) (hasheq 'family "Lee"))))
                '((name . "Ann Marie Ng (+1)") (birthDate . "1960-01-01") (gender . "female")))
  (check-equal? (digest (hasheq 'resourceType "Encounter" 'status "finished" 'class (hasheq 'code "AMB")
                                'period (hasheq 'start "2125-01-01") 'subject (hasheq 'reference "Patient/p")))
                '((class . "AMB") (period . "2125-01-01 – …") (status . "finished") (subject . "Patient/p")))
  ;; a Condition's status is a concept
  (check-equal? (digest (hasheq 'clinicalStatus (hasheq 'coding (list (hasheq 'code "active"))) 'code (hasheq 'text "Diabetes")))
                '((code . "Diabetes") (clinicalStatus . "active")))
  ;; nothing a slot reads: nothing (the row is its Type/id)
  (check-equal? (digest (hasheq 'resourceType "Basic" 'id "b")) '())
  ;; the columns of several digests, in the order they first appear
  (check-equal? (digest-columns (list '((code . "a") (status . "s")) '((code . "b") (value . "1") (status . "s"))))
                '(code status value))
  ;; values as a person reads them
  (check-equal? (value-text (hasheq 'value 8.0 'unit "%" 'comparator "<")) "<8 %")
  (check-equal? (value-text (hasheq 'low (hasheq 'value 1 'unit "mg") 'high (hasheq 'value 2 'unit "mg"))) "1 mg – 2 mg")
  (check-equal? (value-text (hasheq 'numerator (hasheq 'value 1) 'denominator (hasheq 'value 128))) "1 / 128")
  (check-equal? (value-text #t) "true")
  (check-false (value-text (hasheq)))
  (check-false (value-text '()))
  (check-equal? (string-length (value-text (make-string 200 #\a))) 80))
