#lang racket/base

;;; suggest.rkt — "did you mean …?" for a name nothing defines. Every language reports an unknown
;;; name (an element, a Parent, a define, a function); an agent fixes it fastest when the message
;;; names the closest names that DO exist. One definition, so the languages rank alike.
;;;
;;;   (did-you-mean "stauts" '("status" "statusReason" "code"))   => " (did you mean `status`?)"
;;;   (did-you-mean "zzz" '("status"))                            => ""

(require racket/contract racket/list racket/string)

(provide
 (contract-out
  ;; closest-names : name candidates [#:limit n] -> (listof string)   the candidates near enough to
  ;; be what was meant, closest first (at most `limit`, default 3); '() when none is
  [closest-names (->* (string? (listof string?)) (#:limit exact-positive-integer?) (listof string?))]
  ;; did-you-mean : name candidates -> string   " (did you mean `a`?)", " (did you mean `a` or `b`?)",
  ;; or "" — ready to append to a message
  [did-you-mean (-> string? (listof string?) string?)]))

;; distance : string string -> natural   edit distance, case folded, a swap of neighbours one edit
;; (optimal string alignment: `stauts` is one edit from `status`)
(define (distance a0 b0)
  (define a (string-downcase a0))
  (define b (string-downcase b0))
  (define n (string-length a))
  (define m (string-length b))
  (define d (for/vector ([i (in-range (add1 n))]) (make-vector (add1 m) 0)))
  (define (at i j) (vector-ref (vector-ref d i) j))
  (define (set i j v) (vector-set! (vector-ref d i) j v))
  (for ([i (in-range (add1 n))]) (set i 0 i))
  (for ([j (in-range (add1 m))]) (set 0 j j))
  (for* ([i (in-range 1 (add1 n))] [j (in-range 1 (add1 m))])
    (define cost (if (char=? (string-ref a (sub1 i)) (string-ref b (sub1 j))) 0 1))
    (define best (min (add1 (at (sub1 i) j)) (add1 (at i (sub1 j))) (+ (at (sub1 i) (sub1 j)) cost)))
    (set i j (if (and (> i 1) (> j 1)
                      (char=? (string-ref a (sub1 i)) (string-ref b (- j 2)))
                      (char=? (string-ref a (- i 2)) (string-ref b (sub1 j))))
                 (min best (add1 (at (- i 2) (- j 2))))
                 best)))
  (at n m))

;; near-enough : name candidate distance -> boolean   within a third of the name's length (at least
;; one edit, at most three), or the same name in another case
(define (near-enough? name d)
  (<= d (max 1 (min 3 (quotient (string-length name) 3)))))

(define (closest-names name candidates #:limit [limit 3])
  (define scored
    (for*/list ([c (in-list (remove-duplicates candidates))]
                #:unless (string=? c name)
                [d (in-value (distance name c))]
                #:when (near-enough? name d))
      (cons d c)))
  (define ranked (map cdr (sort scored (lambda (x y) (or (< (car x) (car y))
                                                         (and (= (car x) (car y)) (string<? (cdr x) (cdr y))))))))
  (take ranked (min limit (length ranked))))

(define (did-you-mean name candidates)
  (match-names (closest-names name candidates)))
(define (match-names names)
  (cond [(null? names) ""]
        [(null? (cdr names)) (format " (did you mean `~a`?)" (car names))]
        [else (format " (did you mean ~a or `~a`?)"
                      (string-join (for/list ([n (in-list (drop-right names 1))]) (format "`~a`" n)) ", ")
                      (last names))]))

(module+ test
  (require rackunit)
  (check-equal? (distance "stauts" "status") 1)              ; a swap is one edit
  (check-equal? (distance "Observaton" "Observation") 1)
  (check-equal? (distance "abc" "ABC") 0)
  (check-equal? (did-you-mean "stauts" '("status" "statusReason" "code")) " (did you mean `status`?)")
  (check-equal? (did-you-mean "Observaton" '("Observation" "ObservationDefinition" "Patient"))
                " (did you mean `Observation`?)")
  (check-equal? (did-you-mean "AgeInYear" '("AgeInYears" "AgeInMonths" "AgeInYearsAt"))
                " (did you mean `AgeInYears` or `AgeInYearsAt`?)")
  (check-equal? (did-you-mean "Test" '("Tests" "Has Test" "Gap")) " (did you mean `Tests`?)")
  (check-equal? (did-you-mean "zzz" '("status")) "")
  (check-equal? (did-you-mean "a" '("b" "ab")) " (did you mean `ab` or `b`?)")
  ;; the name itself is no suggestion; a differently-cased one is
  (check-equal? (did-you-mean "name" '("name")) "")
  (check-equal? (did-you-mean "Name" '("name")) " (did you mean `name`?)"))
