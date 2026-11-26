#lang racket/base

;;; resource-rules.rkt — rules of the base specification that are about a WHOLE resource's JSON,
;;; decided here without FHIRPath: each says something only when it is certain (fail-open).
;;;
;;; - dom-3: a contained resource is referred to from elsewhere in the resource that contains it,
;;;   or refers to that resource (`#`). FHIR writes it as FHIRPath that calls `as()` on several
;;;   items, an error per FHIRPath's specification, so it is not evaluated as an invariant. Here a
;;;   contained resource with an id is unreferenced when no string anywhere in the containing
;;;   resource, outside it, is `#<id>`, and none inside it is `#` — any string counts (a reference,
;;;   a canonical, a uri), which can only say less than the definition does.
;;; - ValueSet.compose.include.system / exclude.system: "An absolute URI which is the code system
;;;   from which the selected codes come from" (R4 and R5). A system with no scheme (`#cs`, a
;;;   contained code system's id) is not one; FHIR names a contained code system by its url and
;;;   the `valueset-system` extension.
;;; - A Questionnaire derived from another (`derivedFrom`, with the `questionnaire-derivationType`
;;;   extension `extends` or `compliesWith`) keeps what the base says of each item it shares (by
;;;   linkId): its type, that it does not repeat when the base's does not, that it is required when
;;;   the base's is, and only the base's answer options; `compliesWith` adds no item. Decided only
;;;   when the base is found.
;;;
;;; A Finding is (list severity code path message); validate.rkt makes Issues of them.

(require racket/contract racket/list racket/string)

(provide
 (contract-out
  [contained-reference-findings (-> hash? (listof list?))]
  [value-set-system-findings (-> hash? (listof list?))]
  [derived-questionnaire-findings (-> hash? (-> string? (or/c hash? #f)) (listof list?))]))

;; strings : jsexpr -> (listof string)   every string value in a JSON value, at any depth
(define (strings v)
  (cond [(string? v) (list v)]
        [(hash? v) (append-map strings (hash-values v))]
        [(list? v) (append-map strings v)]
        [else '()]))

;; resources-with-contained : jsexpr path -> (listof (cons path resource))
;; every resource at any depth that has `contained` (a Bundle's entries, a Parameters' resources)
(define (resources-with-contained v path)
  (cond
    [(hash? v)
     (define here (if (and (string? (hash-ref v 'resourceType #f)) (pair? (hash-ref v 'contained '())))
                      (list (cons path v)) '()))
     (append here
             (append* (for/list ([(k x) (in-hash v)] #:unless (eq? k 'contained))
                        (resources-with-contained x (format "~a.~a" path k)))))]
    [(list? v) (append* (for/list ([x (in-list v)] [i (in-naturals)])
                          (resources-with-contained x (format "~a[~a]" path i))))]
    [else '()]))

;; contained-reference-findings : resource -> (listof Finding)
(define (contained-reference-findings r)
  (append*
   (for/list ([pr (in-list (resources-with-contained r (hash-ref r 'resourceType "")))])
     (define path (car pr))
     (define res (cdr pr))
     (define cs (filter hash? (hash-ref res 'contained '())))
     (for/list ([c (in-list cs)] [i (in-naturals)]
                #:when (string? (hash-ref c 'id #f))
                #:unless (member "#" (strings c))
                #:unless (member (string-append "#" (hash-ref c 'id))
                                 (append (strings (hash-remove res 'contained))
                                         (append-map strings (remq c cs)))))
       (list "error" "invariant" (format "~a.contained[~a]" path i)
             (format "dom-3: the contained resource '~a' is not referred to from elsewhere in the resource that contains it, nor does it refer to that resource (`#`)"
                     (hash-ref c 'id)))))))

;; absolute? : string -> boolean   a URI with a scheme
(define (absolute? s) (regexp-match? #px"^[A-Za-z][A-Za-z0-9+.-]*:" s))

;; value-set-system-findings : resource -> (listof Finding)
(define (value-set-system-findings r)
  (define compose (and (equal? (hash-ref r 'resourceType #f) "ValueSet") (hash-ref r 'compose #f)))
  (if (hash? compose)
      (for*/list ([part (in-list '(include exclude))]
                  [inc (in-value (hash-ref compose part '()))] #:when (list? inc)
                  [(c i) (in-indexed inc)]
                  #:when (hash? c)
                  [s (in-value (hash-ref c 'system #f))]
                  #:when (and (string? s) (not (absolute? s))))
        (list "error" "invalid" (format "ValueSet.compose.~a[~a].system" part i)
              (format "`~a` is not an absolute URI, as a compose's system must be~a" s
                      (if (string-prefix? s "#")
                          ": name a contained code system by its url, with the extension http://hl7.org/fhir/StructureDefinition/valueset-system giving `#<id>`"
                          ""))))
      '()))

(define (in-indexed xs) (in-parallel (in-list xs) (in-naturals)))

;; derivation : resource -> (listof (cons url code))   each derivedFrom with its derivationType code
(define derivation-url "http://hl7.org/fhir/StructureDefinition/questionnaire-derivationType")
(define (derivations q)
  (define urls (let ([d (hash-ref q 'derivedFrom '())]) (if (list? d) d '())))
  (define exts (let ([d (hash-ref q '_derivedFrom '())]) (if (list? d) d '())))
  (for/list ([u (in-list urls)] [i (in-naturals)] #:when (string? u))
    (define e (and (< i (length exts)) (list-ref exts i)))
    (define code
      (for/or ([x (in-list (if (hash? e) (let ([l (hash-ref e 'extension '())]) (if (list? l) l '())) '()))])
        (and (hash? x) (equal? (hash-ref x 'url #f) derivation-url)
             (let ([c (hash-ref x 'valueCoding #f)]) (and (hash? c) (hash-ref c 'code #f))))))
    (cons u code)))

;; items : questionnaire-or-item path -> (listof (cons path item))   every item at any depth
(define (items x path)
  (define is (let ([l (and (hash? x) (hash-ref x 'item '()))]) (if (list? l) l '())))
  (append* (for/list ([it (in-list is)] [i (in-naturals)] #:when (hash? it))
             (define p (format "~a.item[~a]" path i))
             (cons (cons p it) (items it p)))))

;; derived-questionnaire-findings : resource (url -> resource|#f) -> (listof Finding)
(define (derived-questionnaire-findings q resolve)
  (if (equal? (hash-ref q 'resourceType #f) "Questionnaire")
      (append*
       (for/list ([d (in-list (derivations q))] #:when (member (cdr d) '("extends" "compliesWith")))
         (define base (resolve (car d)))
         (if (and (hash? base) (equal? (hash-ref base 'resourceType #f) "Questionnaire"))
             (item-findings (items q "Questionnaire") (items base "") (car d) (equal? (cdr d) "compliesWith"))
             '())))
      '()))

;; item-findings : (listof (cons path item)) (listof (cons path item)) url boolean -> (listof Finding)
(define (item-findings mine theirs url complies?)
  (define by-link (for/hash ([pi (in-list theirs)] #:when (string? (hash-ref (cdr pi) 'linkId #f)))
                    (values (hash-ref (cdr pi) 'linkId) (cdr pi))))
  (define (finding path fmt . args) (list "error" "business-rule" path (apply format fmt args)))
  (append*
   (for/list ([pi (in-list mine)])
     (define path (car pi))
     (define it (cdr pi))
     (define link (hash-ref it 'linkId #f))
     (define b (and (string? link) (hash-ref by-link link #f)))
     (define (said fmt . args) (format "the item '~a' of ~a ~a" link url (apply format fmt args)))
     (cond
       [(not (string? link)) '()]
       [(not b) (if complies? (list (finding path "no item with linkId '~a' is in ~a, which this questionnaire complies with" link url)) '())]
       [else
        (filter
         values
         (append
          (list
           (and (string? (hash-ref b 'type #f)) (string? (hash-ref it 'type #f))
                (not (equal? (hash-ref b 'type) (hash-ref it 'type)))
                (finding (string-append path ".type") (said "has the type '~a', which cannot change to '~a'" (hash-ref b 'type) (hash-ref it 'type))))
           (and (not (eq? (hash-ref b 'repeats #f) #t)) (eq? (hash-ref it 'repeats #f) #t)
                (finding (string-append path ".repeats") (said "does not repeat, so it cannot repeat here")))
           (and (eq? (hash-ref b 'required #f) #t) (not (eq? (hash-ref it 'required #f) #t))
                (finding (string-append path ".required") (said "is required, so it must be required here"))))
          (let ([theirs (let ([l (hash-ref b 'answerOption '())]) (if (list? l) l '()))]
                [ours (let ([l (hash-ref it 'answerOption '())]) (if (list? l) l '()))])
            (if (null? theirs)
                '()
                (for/list ([o (in-list ours)] [i (in-naturals)] #:unless (member o theirs))
                  (finding (format "~a.answerOption[~a]" path i) (said "has no such answer option")))))))]))))

(module+ test
  (require rackunit)
  ;; dom-3
  (define cs (hasheq 'resourceType "CodeSystem" 'id "cs"))
  (define (vs system [extra (hasheq)])
    (hasheq 'resourceType "ValueSet" 'contained (list cs)
            'compose (hasheq 'include (list (hash-set extra 'system system)))))
  (check-equal? (length (contained-reference-findings (vs "#cs1"))) 1)
  (check-equal? (contained-reference-findings (vs "#cs")) '())
  (check-equal? (contained-reference-findings
                 (vs "http://x" (hasheq '_system (hasheq 'extension (list (hasheq 'valueCanonical "#cs"))))))
                '())
  ;; a contained resource that refers to its container
  (check-equal? (contained-reference-findings
                 (hasheq 'resourceType "Observation"
                         'contained (list (hasheq 'resourceType "Provenance" 'id "p"
                                                  'target (list (hasheq 'reference "#"))))))
                '())
  ;; one contained resource referring to another is a reference
  (check-equal? (contained-reference-findings
                 (hasheq 'resourceType "MedicationRequest"
                         'medicationReference (hasheq 'reference "#m")
                         'contained (list (hasheq 'resourceType "Medication" 'id "m"
                                                  'ingredient (list (hasheq 'itemReference (hasheq 'reference "#s"))))
                                          (hasheq 'resourceType "Substance" 'id "s"))))
                '())
  ;; inside a Bundle entry
  (check-equal? (map caddr (contained-reference-findings
                            (hasheq 'resourceType "Bundle"
                                    'entry (list (hasheq 'resource (vs "#nothing"))))))
                '("Bundle.entry[0].resource.contained[0]"))
  ;; absolute systems
  (check-equal? (map caddr (value-set-system-findings (vs "#cs"))) '("ValueSet.compose.include[0].system"))
  (check-equal? (value-set-system-findings (vs "urn:oid:1.2.3")) '())
  (check-equal? (value-set-system-findings (vs "http://loinc.org")) '())
  ;; derived questionnaires
  (define base (hasheq 'resourceType "Questionnaire" 'url "http://q/base"
                       'item (list (hasheq 'linkId "a" 'type "string")
                                   (hasheq 'linkId "g" 'type "group"
                                           'item (list (hasheq 'linkId "b" 'type "coding" 'required #t
                                                               'answerOption (list (hasheq 'valueString "x"))))))))
  (define (derived code its)
    (hasheq 'resourceType "Questionnaire" 'derivedFrom (list "http://q/base")
            '_derivedFrom (list (hasheq 'extension (list (hasheq 'url derivation-url 'valueCoding (hasheq 'code code)))))
            'item its))
  (define (resolve u) (and (equal? u "http://q/base") base))
  (check-equal? (derived-questionnaire-findings (derived "compliesWith" (hash-ref base 'item)) resolve) '())
  (check-equal? (map caddr (derived-questionnaire-findings
                            (derived "compliesWith" (list (hasheq 'linkId "a" 'type "integer" 'repeats #t)
                                                          (hasheq 'linkId "b" 'type "coding"
                                                                  'answerOption (list (hasheq 'valueString "y")))
                                                          (hasheq 'linkId "new" 'type "string")))
                            resolve))
                '("Questionnaire.item[0].type" "Questionnaire.item[0].repeats" "Questionnaire.item[1].required"
                  "Questionnaire.item[1].answerOption[0]" "Questionnaire.item[2]"))
  ;; extends may add items; inspiredBy, an unknown base or none decides nothing
  (check-equal? (derived-questionnaire-findings (derived "extends" (list (hasheq 'linkId "new" 'type "string"))) resolve) '())
  (check-equal? (derived-questionnaire-findings (derived "inspiredBy" (list (hasheq 'linkId "a" 'type "integer"))) resolve) '())
  (check-equal? (derived-questionnaire-findings (derived "extends" (list (hasheq 'linkId "a" 'type "integer"))) (lambda (_) #f)) '()))
