#lang racket/base

;;; lenient.rkt — what a lenient read left out.
;;;
;;; `from-json #:lenient? #t` reads what it can and drops the rest: an element the type does not
;;; have (an R4 element in an R5 tower), a value that does not parse (`"valueDate": "01/05/1950"`).
;;; A transformation that reads leniently then works on less than it was given, and whatever goes
;;; wrong later (a required element missing from its result) points at the wrong thing.
;;; `lenient-drops` compares the JSON given with the node read back and names each value the node
;;; does not hold, by its path in the JSON, so the reader can say so.
;;;
;;; A Drop is (list path value): path a string like `item[2].answer[0].valueDate`, value the JSON
;;; that was not read.

(require racket/contract racket/list racket/string
         (only-in "../model/node.rkt" fhir?)
         (only-in "to-json.rkt" node->jsexpr)
         (only-in "../primitives/temporal.rkt" calendar-problem))

(provide
 (contract-out
  ;; lenient-drops : jsexpr node -> (listof Drop)   the values of the JSON the node does not hold
  [lenient-drops (-> any/c fhir? (listof (list/c string? any/c)))]
  ;; drop->string : Drop -> string   `item[0].answer[0].valueDate ("01/05/1950")`
  [drop->string (-> (list/c string? any/c) string?)]
  ;; drops-message : (listof Drop) type -> string   "<drops> not read: <why>" — the calendar's reason
  ;; for a date the month lacks, else "not a valid value, or not an element of <type> in FHIR R5"
  [drops-message (-> (listof (list/c string? any/c)) string? string?)]))

(define (lenient-drops js node)
  (missing js (with-handlers ([exn:fail? (lambda (_) (hasheq))]) (node->jsexpr node)) ""))

;; missing : given held path -> (listof Drop)   structural recursion over the JSON given
(define (missing given held path)
  (define (at k) (if (string=? path "") (format "~a" k) (format "~a.~a" path k)))
  (cond
    [(and (hash? given) (hash? held))
     (append* (for/list ([k (in-list (sort (hash-keys given) symbol<?))]
                         #:unless (memq k '(resourceType)))
                (define g (hash-ref given k))
                (cond
                  [(eq? g 'null) '()]
                  [(hash-has-key? held k) (missing g (hash-ref held k) (at k))]
                  ;; a `_x` sibling read into its primitive's extension/id is held under `_x` too
                  [else (list (list (at k) g))])))]
    [(and (list? given) (list? held))
     (if (= (length given) (length held))
         (append* (for/list ([g (in-list given)] [h (in-list held)] [i (in-naturals)])
                    (missing g h (format "~a[~a]" path i))))
         ;; an item that did not read is gone from the list: name the list's items not matched
         (for/list ([g (in-list given)] [i (in-naturals)] #:unless (member g held))
           (list (format "~a[~a]" path i) g)))]
    [else '()]))

(define (drop->string d)
  (define v (cadr d))
  (define shown (cond [(string? v) (format "~s" v)]
                      [(or (number? v) (boolean? v)) (format "~a" v)]
                      [else "{…}"]))
  (format "~a (~a)" (car d) shown))

;; drop-reason : Drop -> string | #f   what is wrong with the value, when it can be told: a date-shaped
;; value naming a day its month lacks (`1990-02-30`: "February 1990 has 28 days" — the agent got "not
;; a valid value, or not an element", which the validator could already say more precisely)
(define (drop-reason d)
  (define v (cadr d))
  (and (string? v) (regexp-match? #px"^[0-9]{4}-[0-9]{2}-[0-9]{2}" v)
       (let ([p (calendar-problem (substring v 0 10))]) (and p (format "~a is no date: ~a" (drop->string d) p)))))
(define (drops-message drops type)
  (define told (filter values (map drop-reason drops)))
  (define rest (filter (lambda (d) (not (drop-reason d))) drops))
  (string-join (append told
                       (if (null? rest) '()
                           (list (format "~a not read: not a valid value, or not an element of ~a in FHIR R5"
                                         (string-join (map drop->string rest) ", ") type))))
               "; "))

(module+ test
  (require rackunit (only-in "from-json.rkt" from-json) (only-in "../result/result.rkt" ok-value)
           (only-in fhir/r5/schemas))
  ;; a date the calendar lacks is said with the calendar's reason; anything else as before
  (check-equal? (drops-message (list (list "item[2].answer[0].valueDate" "1990-02-30")) "QuestionnaireResponse")
                "item[2].answer[0].valueDate (\"1990-02-30\") is no date: February 1990 has 28 days")
  (check-equal? (drops-message (list (list "x" "01/05/1950")) "Patient")
                "x (\"01/05/1950\") not read: not a valid value, or not an element of Patient in FHIR R5")
  (define qr (hasheq 'resourceType "QuestionnaireResponse" 'status "completed"
                     'item (list (hasheq 'linkId "name" 'answer (list (hasheq 'valueString "Ann Ng")))
                                 (hasheq 'linkId "birthDate" 'answer (list (hasheq 'valueDate "01/05/1950"))))))
  (define node (ok-value (from-json qr #:lenient? #t)))
  ;; the date that does not parse is named, by its path; what was read is not
  (check-equal? (map drop->string (lenient-drops qr node)) '("item[1].answer[0].valueDate (\"01/05/1950\")"))
  (check-equal? (map drop->string (lenient-drops (hasheq 'resourceType "Patient" 'gender "female" 'nmae "x")
                                                 (ok-value (from-json (hasheq 'resourceType "Patient" 'gender "female" 'nmae "x") #:lenient? #t))))
                '("nmae (\"x\")"))
  (check-equal? (lenient-drops (hasheq 'resourceType "Patient" 'gender "female")
                               (ok-value (from-json (hasheq 'resourceType "Patient" 'gender "female") #:lenient? #t)))
                '()))
