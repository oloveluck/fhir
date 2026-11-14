#lang racket/base

;;; census.rkt — what a store holds, said so that someone who has never seen the data can ask it
;;; the right question the first time.
;;;
;;; FHIR says what a resource MAY hold; a dataset decides what it does hold: which code systems,
;;; which of a choice's members, where a name is kept (MIMIC keeps a medication's name in an
;;; identifier, and tells a hospital stay from an ICU stay by an identifier's system). An agent
;;; that has to find that out by reading resources spends most of its effort there. A census
;;; answers it from the search indexes, which already hold every value by parameter:
;;;
;;;   store-census : store -> the types and how many of each
;;;   type-census  : store catalog type -> for one type: each search parameter that has values —
;;;       a token's commonest codes with what they are called (or, when nearly every value is
;;;       its own, the systems they are in), a reference's targets by type, a date's span, a
;;;       number's range — and which elements its resources carry (a sample)
;;;   store-find   : store words -> where the words occur: the codes called so, the code or
;;;       identifier values and the names that hold them, each with how many resources and the
;;;       search that finds them
;;;
;;; Counts are exact (read from the indexes); the element shares are of a sample and say so.

(require racket/contract racket/list racket/string racket/match db json
         "fhir-sqlite.rkt"
         (only-in "search-index.rkt" fold-string)
         (only-in "fhir-engine.rkt" search-param-name search-param-kind))

(provide
 (contract-out
  [store-census (-> fhir-store? hash?)]
  [type-census  (->* (fhir-store? hash? string?) (#:top exact-positive-integer? #:sample exact-positive-integer?) hash?)]
  [store-find   (->* (fhir-store? string?) (#:limit exact-positive-integer?) (listof hash?))]))

;; ---- the store as a whole -----------------------------------------------------------------------
;; store-census : store -> {resources, types: [{type, count}]}   largest first
(define (store-census store)
  (call-with-store-connection store
    (lambda (c)
      (define rows (query-rows c "SELECT resource_type, COUNT(*) FROM fhir_resources GROUP BY resource_type ORDER BY 2 DESC, 1"))
      (hasheq 'resources (for/sum ([r (in-list rows)]) (vector-ref r 1))
              'types (for/list ([r (in-list rows)]) (hasheq 'type (vector-ref r 0) 'count (vector-ref r 1)))))))

;; ---- one type -----------------------------------------------------------------------------------
;; A ParamFacts is a jsexpr hash saying what one search parameter's index holds for the type:
;;   token:     {kind, values, distinct, [system], top: [line …]}  or, when nearly every value is
;;              its own (an identifier), {kind, values, distinct, systems: [line …]}
;;   reference: {kind, values, targets: [line …]}
;;   date:      {kind, values, from, to}
;;   number, quantity: {kind, values, min, max, [units: [line …]]}
;;   string:    {kind, values, distinct}
;; A line is text: `4548-4 "Hemoglobin A1c" ×1362`.

;; type-census : store catalog type -> {type, count, search: {names: ParamFacts}, elements, example}
;; Parameters with the same facts (`patient` and `subject`, `code` and `combo-code`) are said once,
;; under their names joined.
(define (type-census store catalog type #:top [top 8] #:sample [sample 300])
  (call-with-store-connection store
    (lambda (c)
      (define n (query-value c "SELECT COUNT(*) FROM fhir_resources WHERE resource_type=?" type))
      (define facts
        (for*/list ([p (in-list (remove-duplicates (hash-ref catalog (string->symbol type) '())
                                                   #:key search-param-name))]
                    [f (in-value (param-facts c type (search-param-name p) (search-param-kind p) top))]
                    #:when f)
          (cons (search-param-name p) f)))
      (define elements (element-shares c type sample))
      (define example (query-maybe-value c "SELECT id FROM fhir_resources WHERE resource_type=? LIMIT 1" type))
      (define base (hasheq 'type type 'count n 'search (merged facts)))
      (let* ([h (if elements (hash-set base 'elements elements) base)]
             [h (if (string? example) (hash-set h 'example (format "~a/~a" type example)) h)])
        h))))

;; merged : (listof (cons name ParamFacts)) -> hash   names with equal facts joined ("patient, subject")
(define (merged facts)
  (define groups (group-by cdr facts))
  (for/hasheq ([g (in-list groups)])
    (values (string->symbol (string-join (map car g) ", ")) (cdr (car g)))))

;; param-facts : connection type name kind top -> ParamFacts | #f   #f when the index holds nothing
(define (param-facts c type name kind top)
  (case kind
    [(token uri) (token-facts c type name top)]
    [(reference) (reference-facts c type name top)]
    [(date)
     (match (query-row c "SELECT COUNT(*), MIN(low), MAX(low) FROM fhir_date_index WHERE resource_type=? AND param_name=?" type name)
       [(vector 0 _ _) #f]
       [(vector n lo hi) (hasheq 'kind "date" 'values n 'from (day lo) 'to (day hi))])]
    [(number) (range-facts c "fhir_number_index" type name "number" #f top)]
    [(quantity) (range-facts c "fhir_quantity_index" type name "quantity" #t top)]
    [(string)
     (match (query-row c "SELECT COUNT(*), COUNT(DISTINCT value_norm) FROM fhir_string_index WHERE resource_type=? AND param_name=?" type name)
       [(vector 0 _) #f]
       [(vector n d) (hasheq 'kind "string" 'values n 'distinct d)])]
    [else #f]))

;; day : "2125-03-01T00:00:00.000" -> "2125-03-01"
(define (day s) (if (and (string? s) (>= (string-length s) 10)) (substring s 0 10) s))

;; token-facts : the commonest codes of a parameter with what they are called; a parameter whose
;; values are nearly all different (an identifier: one per resource) by the systems they are in
(define (token-facts c type name top)
  (match (query-row c "SELECT COUNT(*), COUNT(DISTINCT code) FROM fhir_token_index WHERE resource_type=? AND param_name=?" type name)
    [(vector 0 _) #f]
    [(vector n distinct)
     (define base (hasheq 'kind "token" 'values n 'distinct distinct))
     (cond
       [(and (> distinct 50) (> (* 2 distinct) n))        ; an identifier, not a vocabulary
        (hash-set base 'systems
                  (for/list ([r (in-list (query-rows c "SELECT system, COUNT(*) FROM fhir_token_index WHERE resource_type=? AND param_name=? GROUP BY system ORDER BY 2 DESC LIMIT ?" type name top))])
                    (format "~a ×~a" (if (sql-null? (vector-ref r 0)) "(no system)" (vector-ref r 0)) (vector-ref r 1))))]
       [else
        (define rows
          (query-rows c (string-append
                         "SELECT t.system, t.code, t.n,"
                         " (SELECT d.text FROM fhir_token_text d WHERE d.resource_type=? AND d.param_name=? AND d.code=t.code AND d.system IS t.system"
                         "  ORDER BY length(d.text) DESC LIMIT 1)"
                         " FROM (SELECT system, code, COUNT(*) n FROM fhir_token_index WHERE resource_type=? AND param_name=?"
                         "       GROUP BY code, system ORDER BY n DESC LIMIT ?) t")
                      type name type name top))
        (define systems (remove-duplicates (map (lambda (r) (vector-ref r 0)) rows)))
        ;; one system for every code shown: said once, not on every line
        (define one (and (= (length systems) 1) (not (sql-null? (car systems))) (car systems)))
        (define (line r)
          (match-define (vector system code count text) r)
          (format "~a~a~a ×~a" (if (or one (sql-null? system)) "" (string-append system "|")) code
                  (if (sql-null? text) "" (format " ~s" text)) count))
        (let ([h (hash-set base 'top (map line rows))])
          (if one (hash-set h 'system one) h))])]))

;; reference-facts : what a reference parameter points at, by type, and how many different ones
(define (reference-facts c type name top)
  (define rows (query-rows c "SELECT target_type, COUNT(*), COUNT(DISTINCT target_id) FROM fhir_reference_index WHERE resource_type=? AND param_name=? GROUP BY target_type ORDER BY 2 DESC LIMIT ?" type name top))
  (and (pair? rows)
       (hasheq 'kind "reference" 'values (for/sum ([r (in-list rows)]) (vector-ref r 1))
               'targets (for/list ([r (in-list rows)])
                          (format "~a ×~a (~a different)" (if (sql-null? (vector-ref r 0)) "(no type)" (vector-ref r 0))
                                  (vector-ref r 1) (vector-ref r 2))))))

;; range-facts : a number's or a quantity's span, and a quantity's commonest units
(define (range-facts c table type name kind units? top)
  (match (query-row c (format "SELECT COUNT(*), MIN(value), MAX(value) FROM ~a WHERE resource_type=? AND param_name=?" table) type name)
    [(vector 0 _ _) #f]
    [(vector n lo hi)
     (define base (hasheq 'kind kind 'values n 'min lo 'max hi))
     (if units?
         (hash-set base 'units
                   (for/list ([r (in-list (query-rows c "SELECT code, COUNT(*) FROM fhir_quantity_index WHERE resource_type=? AND param_name=? GROUP BY code ORDER BY 2 DESC LIMIT ?" type name top))])
                     (format "~a ×~a" (if (sql-null? (vector-ref r 0)) "(no unit)" (vector-ref r 0)) (vector-ref r 1))))
         base)]))

;; element-shares : connection type sample -> {sampled, always: [name …], sometimes: [line …]} | #f
;; Which elements the type's resources carry, from up to `sample` of them (in id order): the ones
;; every sampled resource has, and the others with their share — a choice's members included, as
;; the JSON names them (`valueQuantity 71%`, `valueString 12%`).
(define (element-shares c type sample)
  (define texts (query-list c "SELECT json(resource) FROM fhir_resources WHERE resource_type=? LIMIT ?" type sample))
  (define n (length texts))
  (cond
    [(zero? n) #f]
    [else
     (define counts
       (for*/fold ([h (hash)]) ([t (in-list texts)] [k (in-list (hash-keys (string->jsexpr t)))]
                                #:unless (memq k '(resourceType id meta text)))
         (hash-update h k add1 0)))
     (define-values (always sometimes) (partition (lambda (kv) (= (cdr kv) n)) (hash->list counts)))
     (hasheq 'sampled n
             'always (sort (map (lambda (kv) (symbol->string (car kv))) always) string<?)
             'sometimes (for/list ([kv (in-list (sort sometimes > #:key cdr))])
                          (format "~a ~a%" (car kv) (max 1 (round (/ (* 100 (cdr kv)) n))))))]))

;; ---- where words occur --------------------------------------------------------------------------
;; A Finding is {where: "Type.param[, param]", value: "system|code" or the text held, [text],
;; resources: n, search: "Type?param=value"}.

;; store-find : store words -> (listof Finding)   every word must occur (any case, in any order):
;; codes CALLED so (the display dictionary), then code and identifier VALUES that hold the words,
;; then names and other strings — commonest first within each
(define (store-find store words #:limit [limit 30])
  (define parts (filter (lambda (w) (not (string=? w ""))) (string-split (fold-string words))))
  (cond
    [(null? parts) '()]
    [else
     (define patterns (map (lambda (w) (string-append "%" (regexp-replace* #px"([%_\\\\])" w "\\\\\\1") "%")) parts))
     (define (all-like col) (string-join (for/list ([_ (in-list patterns)]) (string-append col " LIKE ? ESCAPE '\\'")) " AND "))
     (call-with-store-connection store
       (lambda (c)
         (define called
           (apply query-rows c
                  (string-append
                   "SELECT d.resource_type, d.param_name, d.system, d.code, d.text,"
                   " (SELECT COUNT(*) FROM fhir_token_index x WHERE x.resource_type=d.resource_type AND x.param_name=d.param_name"
                   "   AND x.code=d.code AND x.system IS d.system) n"
                   " FROM fhir_token_text d WHERE " (all-like "d.text_norm") " ORDER BY n DESC LIMIT ?")
                  (append patterns (list (* 4 limit)))))
         (define valued
           (apply query-rows c
                  (string-append "SELECT resource_type, param_name, system, code, NULL, COUNT(*) n FROM fhir_token_index WHERE "
                                 (all-like "code") " GROUP BY resource_type, param_name, system, code ORDER BY n DESC LIMIT ?")
                  (append patterns (list (* 4 limit)))))
         (define named
           (apply query-rows c
                  (string-append "SELECT resource_type, param_name, value_exact, COUNT(*) n FROM fhir_string_index WHERE "
                                 (all-like "value_norm") " GROUP BY resource_type, param_name, value_exact ORDER BY n DESC LIMIT ?")
                  (append patterns (list (* 4 limit)))))
         (define tokens
           ;; a code found both ways is said once, with its text; the parameters that hold it joined
           (for/list ([g (in-list (group-by (lambda (r) (list (vector-ref r 0) (vector-ref r 2) (vector-ref r 3)))
                                            (append called valued)))])
             (define r (or (for/first ([r (in-list g)] #:unless (sql-null? (vector-ref r 4))) r) (car g)))
             (match-define (vector type param system code text n) r)
             (define value (if (sql-null? system) code (string-append system "|" code)))
             (define params (remove-duplicates (map (lambda (r) (vector-ref r 1)) g)))
             (define finding (hasheq 'where (format "~a.~a" type (string-join params ", "))
                                     'value value 'resources n
                                     'search (format "~a?~a=~a" type param value)))
             (if (sql-null? text) finding (hash-set finding 'text text))))
         (define strings
           (for/list ([r (in-list named)])
             (match-define (vector type param value n) r)
             (hasheq 'where (format "~a.~a" type param) 'value value 'resources n
                     'search (format "~a?~a=~a" type param value))))
         (define all (append tokens strings))
         (take all (min limit (length all)))))]))

(module+ test
  (require rackunit racket/file
           (only-in fhir/r4/schemas)                       ; index rows are read from typed resources
           (only-in "fhir-engine.rkt" fhir-create! search-param))
  (define tmp (make-temporary-file "census-~a.db"))
  (delete-file tmp)
  (define store (open-fhir-store tmp))
  (define cat
    (hash 'Observation (list (search-param "code" 'token "code")
                             (search-param "combo-code" 'token "code")
                             (search-param "identifier" 'token "identifier")
                             (search-param "subject" 'reference "subject")
                             (search-param "patient" 'reference "subject")
                             (search-param "date" 'date "effective")
                             (search-param "value-quantity" 'quantity "value.ofType(Quantity)")
                             (search-param "value-string" 'string "value.ofType(string)"))
          'Patient (list (search-param "family" 'string "name.family"))))
  (define (obs i code display value)
    (define day (add1 (modulo i 28)))
    (fhir-create! store
                  (hash-union* (hasheq 'resourceType "Observation" 'status "final"
                                       'identifier (list (hasheq 'system "urn:lab" 'value (format "L~a" i)))
                                       'code (hasheq 'coding (list (hasheq 'system "http://loinc.org" 'code code 'display display)))
                                       'subject (hasheq 'reference (format "Patient/p~a" (modulo i 3)))
                                       'effectiveDateTime (format "2025-03-~a~a" (if (< day 10) "0" "") day))
                               value)
                  #:search-params cat)
    (void))
  (define (hash-union* a b) (for/fold ([h a]) ([(k v) (in-hash b)]) (hash-set h k v)))
  (for ([i (in-range 60)])
    (if (< i 40)
        (obs i "4548-4" "Hemoglobin A1c/Hemoglobin.total in Blood" (hasheq 'valueQuantity (hasheq 'value (+ 5.0 (/ i 10.0)) 'unit "%" 'system "http://unitsofmeasure.org" 'code "%")))
        (obs i "2339-0" "Glucose [Mass/volume] in Blood" (hasheq 'valueString "see note"))))
  (let-values ([(_t _i _v) (fhir-create! store (hasheq 'resourceType "Patient" 'name (list (hasheq 'family "Glucksmann"))) #:search-params cat)])
    (void))

  ;; the store: its types, largest first
  (check-equal? (store-census store)
                (hasheq 'resources 61 'types (list (hasheq 'type "Observation" 'count 60) (hasheq 'type "Patient" 'count 1))))

  (define oc (type-census store cat "Observation"))
  (check-equal? (hash-ref oc 'count) 60)
  (define search (hash-ref oc 'search))
  ;; a vocabulary: its codes, commonest first, called what the data calls them; the one system once;
  ;; parameters that hold the same said together
  (check-equal? (hash-ref search (string->symbol "code, combo-code"))
                (hasheq 'kind "token" 'values 60 'distinct 2 'system "http://loinc.org"
                        'top (list "4548-4 \"Hemoglobin A1c/Hemoglobin.total in Blood\" ×40"
                                   "2339-0 \"Glucose [Mass/volume] in Blood\" ×20")))
  ;; an identifier: one per resource, so its systems
  (check-equal? (hash-ref search 'identifier) (hasheq 'kind "token" 'values 60 'distinct 60 'systems '("urn:lab ×60")))
  (check-equal? (hash-ref search (string->symbol "subject, patient"))
                (hasheq 'kind "reference" 'values 60 'targets '("Patient ×60 (3 different)")))
  (check-equal? (hash-ref search 'date) (hasheq 'kind "date" 'values 60 'from "2025-03-01" 'to "2025-03-28"))
  (check-equal? (hash-ref (hash-ref search 'value-quantity) 'units) '("% ×40"))
  (check-equal? (hash-ref search 'value-string) (hasheq 'kind "string" 'values 20 'distinct 1))
  ;; which elements the resources carry: a choice's members as the JSON names them
  (check-equal? (hash-ref oc 'elements)
                (hasheq 'sampled 60 'always '("code" "effectiveDateTime" "identifier" "status" "subject")
                        'sometimes '("valueQuantity 67%" "valueString 33%")))
  (check-regexp-match #rx"^Observation/" (hash-ref oc 'example))
  ;; a type with nothing stored
  (check-equal? (hash-ref (type-census store cat "Condition") 'count) 0)

  ;; find: codes called so (once, with the parameters that hold them), values, names
  (define found (store-find store "glu"))
  (check-equal? (map (lambda (f) (hash-ref f 'where)) found) '("Observation.code, combo-code" "Patient.family"))
  (check-equal? (car found)
                (hasheq 'where "Observation.code, combo-code" 'value "http://loinc.org|2339-0"
                        'text "Glucose [Mass/volume] in Blood" 'resources 20
                        'search "Observation?code=http://loinc.org|2339-0"))
  (check-equal? (hash-ref (cadr found) 'search) "Patient?family=Glucksmann")
  ;; every word, any order, any case; a value that holds the words (an identifier)
  (check-equal? (length (store-find store "BLOOD hemoglobin")) 1)
  (check-equal? (store-find store "hemoglobin glucose") '())
  (check-equal? (hash-ref (car (store-find store "L59")) 'search) "Observation?identifier=urn:lab|L59")
  (check-equal? (store-find store "  ") '())
  (close-fhir-store store)
  (delete-file tmp))
