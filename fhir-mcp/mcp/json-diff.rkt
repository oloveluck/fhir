#lang racket/base

;;; json-diff.rkt — where two JSON values differ, as lines a person reads: what a stage would change,
;;; what a version changed.

(require racket/contract racket/list json)

(provide
 (contract-out
  [json-diff (->* (jsexpr? jsexpr?) (string?) (listof string?))]))

;; json-diff : a b -> (listof string)   where two JSON values differ and how, one line each:
;; `valueQuantity.value: 8 → 8.4`, `note: added [{"text":"…"}]`, `status: removed "final"`
;; (a history or a stage reads as what changed, not only where; a long value is cut at 60 characters)
;; Compared at the top are two resources: their `meta` (the store's versionId and lastUpdated) and
;; their narrative are left out.
(define (json-diff a b [prefix ""])
  (define (at k) (if (string=? prefix "") (format "~a" k) (format "~a.~a" prefix k)))
  (define (shown v)
    (define t (jsexpr->string v))
    (if (> (string-length t) 60) (string-append (substring t 0 57) "…") t))
  (cond [(and (hash? a) (hash? b))
         (append* (for/list ([k (in-list (sort (remove-duplicates (append (hash-keys a) (hash-keys b))) symbol<?))]
                             ;; the resource's own bookkeeping and narrative are not its content; a
                             ;; `text` further down is (an Annotation's, a CodeableConcept's)
                             #:unless (and (string=? prefix "") (memq k '(meta text))))
                    (json-diff (hash-ref a k 'null) (hash-ref b k 'null) (at k))))]
        [(and (list? a) (list? b) (= (length a) (length b)))
         (append* (for/list ([x (in-list a)] [y (in-list b)] [i (in-naturals)]) (json-diff x y (format "~a[~a]" prefix i))))]
        [(equal? a b) '()]
        [else
         (define where (if (string=? prefix "") "(whole resource)" prefix))
         (list (cond [(eq? a 'null) (format "~a: added ~a" where (shown b))]
                     [(eq? b 'null) (format "~a: removed ~a" where (shown a))]
                     [else (format "~a: ~a → ~a" where (shown a) (shown b))]))]))

(module+ test
  (require rackunit)
  (define a (hasheq 'resourceType "Observation" 'status "final" 'meta (hasheq 'versionId "1")
                    'valueQuantity (hasheq 'value 8 'unit "%") 'category (list (hasheq 'text "lab"))))
  (check-equal? (json-diff a a) '())
  ;; a value changed, an element added, an element removed: one line each, by path
  (check-equal? (json-diff a (hash-set a 'valueQuantity (hasheq 'value 8.4 'unit "%"))) '("valueQuantity.value: 8 → 8.4"))
  (check-equal? (json-diff a (hash-set a 'note (list (hasheq 'text "repeat")))) '("note: added [{\"text\":\"repeat\"}]"))
  (check-equal? (json-diff a (hash-remove a 'status)) '("status: removed \"final\""))
  ;; lists of one length are compared item by item; of another length, as wholes
  (check-equal? (json-diff a (hash-set a 'category (list (hasheq 'text "vital")))) '("category[0].text: \"lab\" → \"vital\""))
  (check-equal? (length (json-diff a (hash-set a 'category '()))) 1)
  ;; the store's bookkeeping and the narrative are not the resource's content …
  (check-equal? (json-diff a (hash-set a 'meta (hasheq 'versionId "2"))) '())
  (check-equal? (json-diff a (hash-set a 'text (hasheq 'status "generated" 'div "<div/>"))) '())
  ;; … a `text` inside it is: a note corrected was "unchanged", and never committed
  (check-equal? (json-diff (hasheq 'note (list (hasheq 'text "fasting"))) (hasheq 'note (list (hasheq 'text "not fasting"))))
                '("note[0].text: \"fasting\" → \"not fasting\""))
  ;; a long value is cut
  (check-true (<= (string-length (car (json-diff (hasheq) (hasheq 'x (make-string 200 #\a))))) 80)))
