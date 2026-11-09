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
         (only-in "to-json.rkt" node->jsexpr))

(provide
 (contract-out
  ;; lenient-drops : jsexpr node -> (listof Drop)   the values of the JSON the node does not hold
  [lenient-drops (-> any/c fhir? (listof (list/c string? any/c)))]
  ;; drop->string : Drop -> string   `item[0].answer[0].valueDate ("01/05/1950")`
  [drop->string (-> (list/c string? any/c) string?)]))

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

(module+ test
  (require rackunit (only-in "from-json.rkt" from-json) (only-in "../result/result.rkt" ok-value)
           (only-in fhir/r5/schemas))
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
