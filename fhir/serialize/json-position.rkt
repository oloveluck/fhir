#lang racket/base

;;; json-position.rkt — where an element path sits in a FHIR JSON text, so a problem the validator
;;; reports at `Patient.birthDat` or `Observation.component.value[x]` can be shown at its line and
;;; column. The text is read into a positioned tree (only offsets are kept), then the path is walked:
;;; the type root is dropped, a repeating element without an index means its first entry, `[n]` the
;;; n-th, a choice `value[x]` any key `value<Type>`. The deepest key reached is the answer, so a path
;;; into a missing element points at its parent.
;;;
;;; A PNode (positioned node) is one of:
;;;   (pobj pos (listof (list key-string key-pos PNode)))   ; an object and each member's key offset
;;;   (parr pos (listof PNode))                             ; an array
;;;   (pval pos)                                            ; a scalar
;;; pos is a 0-based character offset.

(require racket/contract racket/string racket/list)

(provide
 (contract-out
  ;; json-path-location : text element-path -> (list line column offset span) | #f
  ;; line and column 1-based; the span covers the key (with its quotes); #f when the text is not
  ;; JSON this reader follows or not even the path's first step is in it
  [json-path-location (-> string? string? (or/c #f (list/c exact-positive-integer? exact-positive-integer?
                                                            exact-nonnegative-integer? exact-nonnegative-integer?)))]))

(struct pobj (pos members))
(struct parr (pos items))
(struct pval (pos))

;; read-positioned : string -> PNode | #f
(define (read-positioned s)
  (define n (string-length s))
  (define (ws i) (if (and (< i n) (char-whitespace? (string-ref s i))) (ws (add1 i)) i))
  (define (string-end i)                          ; i after the opening quote -> index of the closing one
    (cond [(>= i n) #f]
          [(char=? (string-ref s i) #\") i]
          [(char=? (string-ref s i) #\\) (string-end (+ i 2))]
          [else (string-end (add1 i))]))
  ;; value : index -> (values PNode next-index) | (values #f #f)
  (define (value i)
    (define i* (ws i))
    (cond
      [(>= i* n) (values #f #f)]
      [(char=? (string-ref s i*) #\{) (members (ws (add1 i*)) i* '())]
      [(char=? (string-ref s i*) #\[) (items (ws (add1 i*)) i* '())]
      [(char=? (string-ref s i*) #\") (let ([e (string-end (add1 i*))]) (if e (values (pval i*) (add1 e)) (values #f #f)))]
      [else (let loop ([j i*]) (if (or (>= j n) (memv (string-ref s j) '(#\, #\} #\] #\space #\newline #\tab #\return)))
                                   (values (pval i*) j) (loop (add1 j))))]))
  (define (members i start acc)
    (cond
      [(>= i n) (values #f #f)]
      [(char=? (string-ref s i) #\}) (values (pobj start (reverse acc)) (add1 i))]
      [(char=? (string-ref s i) #\,) (members (ws (add1 i)) start acc)]
      [(char=? (string-ref s i) #\")
       (define e (string-end (add1 i)))
       (define colon (and e (ws (add1 e))))
       (cond
         [(not (and colon (< colon n) (char=? (string-ref s colon) #\:))) (values #f #f)]
         [else (define-values (v nxt) (value (add1 colon)))
               (if v
                   (members (ws nxt) start (cons (list (substring s (add1 i) e) i v) acc))
                   (values #f #f))])]
      [else (values #f #f)]))
  (define (items i start acc)
    (cond
      [(>= i n) (values #f #f)]
      [(char=? (string-ref s i) #\]) (values (parr start (reverse acc)) (add1 i))]
      [(char=? (string-ref s i) #\,) (items (ws (add1 i)) start acc)]
      [else (define-values (v nxt) (value i))
            (if v (items (ws nxt) start (cons v acc)) (values #f #f))]))
  (define-values (root _) (value 0))
  root)

;; steps : element-path -> (listof (cons name index|#f))   "Observation.component[1].value[x]" ->
;; (("component" . 1) ("value[x]" . #f)); the type root dropped
(define (steps path)
  (for/list ([seg (in-list (cdr (string-split path ".")))])
    (match-step seg)))
(define (match-step seg)
  (define m (regexp-match #px"^(.*?)\\[([0-9]+)\\]$" seg))
  (if m (cons (cadr m) (string->number (caddr m))) (cons seg #f)))

;; member-for : PNode-object name -> (list key key-pos PNode) | #f   `value[x]` matches `valueQuantity`
(define (member-for obj name)
  (define choice (and (string-suffix? name "[x]") (substring name 0 (- (string-length name) 3))))
  (for/first ([m (in-list (pobj-members obj))]
              #:when (if choice
                         (and (string-prefix? (car m) choice) (> (string-length (car m)) (string-length choice))
                              (char-upper-case? (string-ref (car m) (string-length choice))))
                         (equal? (car m) name)))
    m))

;; walk : PNode steps -> (cons key key-pos) | #f   the deepest key the path reaches
(define (walk node sts found)
  (cond
    [(null? sts) found]
    [(parr? node) (if (pair? (parr-items node)) (walk (car (parr-items node)) sts found) found)]
    [(pobj? node)
     (define m (member-for node (car (car sts))))
     (cond
       [(not m) found]
       [else
        (define v (caddr m))
        (define idx (cdr (car sts)))
        (define v* (if (and idx (parr? v) (< idx (length (parr-items v)))) (list-ref (parr-items v) idx) v))
        (walk v* (cdr sts) (cons (car m) (cadr m)))])]
    [else found]))

(define (json-path-location text path)
  (define root (read-positioned text))
  (define hit (and root (string-contains? path ".") (walk root (steps path) #f)))
  (and hit
       (let* ([pos (cdr hit)]
              [before (substring text 0 pos)]
              [line (add1 (for/sum ([c (in-string before)]) (if (char=? c #\newline) 1 0)))]
              [nl (let loop ([i (sub1 pos)]) (cond [(< i 0) -1] [(char=? (string-ref text i) #\newline) i] [else (loop (sub1 i))]))])
         (list line (- pos nl) pos (+ 2 (string-length (car hit)))))))

(module+ test
  (require rackunit)
  (define text "{\n  \"resourceType\": \"Patient\",\n  \"birthDat\": \"1990-01-01\",\n  \"name\": [{\"family\": \"A\"}, {\"given\": [\"B\"]}],\n  \"valueQuantity\": {\"value\": 1}\n}")
  (check-equal? (json-path-location text "Patient.birthDat") '(3 3 33 10))
  ;; a repeating element: its first entry, or the indexed one
  (check-equal? (take (json-path-location text "Patient.name.family") 2) '(4 13))
  (check-equal? (take (json-path-location text "Patient.name[1].given") 2) '(4 30))
  ;; a choice element reaches its typed key; a missing child points at the deepest key found
  (check-equal? (take (json-path-location text "Patient.value[x].value") 2) '(5 21))
  (check-equal? (take (json-path-location text "Patient.name.nosuch") 2) '(4 3))
  ;; not JSON, or no step found: #f
  (check-false (json-path-location "{\"a\": " "Patient.a"))
  (check-false (json-path-location text "Patient.nothere"))
  (check-false (json-path-location text "Patient")))
