#lang racket/base

;;; json-patch.rkt — JSON Patch (RFC 6902) over jsexprs, for FHIR's PATCH interaction
;;; (https://hl7.org/fhir/http.html#patch, content type application/json-patch+json).
;;;
;;; Data definitions
;;;   A Patch is a list of Operations (JSON objects):
;;;     {op: "add"|"remove"|"replace"|"move"|"copy"|"test", path: Pointer, value?, from?}
;;;   A Pointer is an RFC 6901 JSON Pointer string: "" (the whole document) or "/a/0/b", where a
;;;   segment escapes "~" as "~0" and "/" as "~1"; for an array, "-" means "past the end" (add only).
;;; Operations apply in order to an immutable jsexpr; any failure (bad pointer, failed `test`)
;;; raises exn:fail:json-patch and the WHOLE patch is rejected (RFC 6902 §5 — atomic).

(require racket/contract racket/list racket/string racket/match)

(provide
 (struct-out exn:fail:json-patch)
 (contract-out
  [apply-json-patch (-> any/c list? any/c)]
  [parse-pointer    (-> string? (listof string?))]))

(struct exn:fail:json-patch exn:fail ())
(define (patch-error fmt . args)
  (raise (exn:fail:json-patch (apply format (string-append "json-patch: " fmt) args) (current-continuation-marks))))

;; parse-pointer : "/a/b~1c" -> '("a" "b/c")
(define (parse-pointer p)
  (cond [(string=? p "") '()]
        [(not (string-prefix? p "/")) (patch-error "pointer must start with / : ~s" p)]
        [else (for/list ([seg (in-list (cdr (string-split p "/" #:trim? #f)))])
                (string-replace (string-replace seg "~1" "/") "~0" "~"))]))

(define (index-of-seg arr seg #:append-ok? [append-ok? #f])
  (cond [(and append-ok? (equal? seg "-")) (length arr)]
        [(regexp-match? #px"^(0|[1-9][0-9]*)$" seg)
         (define i (string->number seg))
         (if (<= i (if append-ok? (length arr) (sub1 (length arr)))) i
             (patch-error "index ~a out of range" seg))]
        [else (patch-error "not an array index: ~s" seg)]))

;; get : jsexpr (listof seg) -> value
(define (get doc segs)
  (for/fold ([d doc]) ([seg (in-list segs)])
    (cond [(hash? d) (hash-ref d (string->symbol seg) (lambda () (patch-error "no member ~s" seg)))]
          [(list? d) (list-ref d (index-of-seg d seg))]
          [else (patch-error "cannot descend into a scalar at ~s" seg)])))

;; update-at : jsexpr segs (parent last-seg -> parent') -> jsexpr   rebuilds the path immutably
(define (update-at doc segs f)
  (match segs
    ['() (patch-error "the whole-document target is handled by the caller")]
    [(list last) (f doc last)]
    [(cons seg more)
     (cond [(hash? doc)
            (define k (string->symbol seg))
            (unless (hash-has-key? doc k) (patch-error "no member ~s" seg))
            (hash-set doc k (update-at (hash-ref doc k) more f))]
           [(list? doc)
            (define i (index-of-seg doc seg))
            (list-set doc i (update-at (list-ref doc i) more f))]
           [else (patch-error "cannot descend into a scalar at ~s" seg)])]))

(define (add doc segs v)
  (if (null? segs) v
      (update-at doc segs
                 (lambda (parent seg)
                   (cond [(hash? parent) (hash-set parent (string->symbol seg) v)]
                         [(list? parent) (let-values ([(a b) (split-at parent (index-of-seg parent seg #:append-ok? #t))])
                                           (append a (list v) b))]
                         [else (patch-error "cannot add into a scalar")])))))

(define (remove doc segs)
  (when (null? segs) (patch-error "cannot remove the whole document"))
  (update-at doc segs
             (lambda (parent seg)
               (cond [(hash? parent)
                      (unless (hash-has-key? parent (string->symbol seg)) (patch-error "no member ~s" seg))
                      (hash-remove parent (string->symbol seg))]
                     [(list? parent) (let ([i (index-of-seg parent seg)]) (append (take parent i) (drop parent (add1 i))))]
                     [else (patch-error "cannot remove from a scalar")]))))

(define (replace doc segs v)
  (if (null? segs) v
      (begin (get doc segs)                                     ; the target must exist
             (update-at doc segs
                        (lambda (parent seg)
                          (cond [(hash? parent) (hash-set parent (string->symbol seg) v)]
                                [else (list-set parent (index-of-seg parent seg) v)]))))))

(define (apply-op doc op)
  (unless (hash? op) (patch-error "an operation must be an object: ~s" op))
  (define path (let ([p (hash-ref op 'path #f)]) (if (string? p) (parse-pointer p) (patch-error "missing path"))))
  (define (value) (if (hash-has-key? op 'value) (hash-ref op 'value) (patch-error "missing value")))
  (define (from) (let ([p (hash-ref op 'from #f)]) (if (string? p) (parse-pointer p) (patch-error "missing from"))))
  (match (hash-ref op 'op #f)
    ["add"     (add doc path (value))]
    ["remove"  (remove doc path)]
    ["replace" (replace doc path (value))]
    ["move"    (let ([v (get doc (from))]) (add (remove doc (from)) path v))]
    ["copy"    (add doc path (get doc (from)))]
    ["test"    (if (equal? (get doc path) (value)) doc (patch-error "test failed at ~a" (hash-ref op 'path)))]
    [other     (patch-error "unknown op ~s" other)]))

(define (apply-json-patch doc ops)
  (for/fold ([d doc]) ([op (in-list ops)]) (apply-op d op)))

(module+ test
  (require rackunit)
  (define p (hasheq 'resourceType "Patient" 'active #t 'name (list (hasheq 'family "A"))))
  (check-equal? (parse-pointer "/a~1b/c~0d") '("a/b" "c~d"))
  (check-equal? (hash-ref (apply-json-patch p (list (hasheq 'op "replace" 'path "/active" 'value #f))) 'active) #f)
  (check-equal? (hash-ref (apply-json-patch p (list (hasheq 'op "add" 'path "/name/-" 'value (hasheq 'family "B")))) 'name)
                (list (hasheq 'family "A") (hasheq 'family "B")))
  (check-equal? (hash-ref (apply-json-patch p (list (hasheq 'op "add" 'path "/name/0" 'value (hasheq 'family "Z")))) 'name)
                (list (hasheq 'family "Z") (hasheq 'family "A")))
  (check-false (hash-has-key? (apply-json-patch p (list (hasheq 'op "remove" 'path "/active"))) 'active))
  (check-equal? (hash-ref (apply-json-patch p (list (hasheq 'op "copy" 'from "/name/0/family" 'path "/gender"))) 'gender) "A")
  (define moved (apply-json-patch p (list (hasheq 'op "move" 'from "/active" 'path "/name/0/x"))))
  (check-equal? (hash-ref (car (hash-ref moved 'name)) 'x) #t)
  (check-false (hash-has-key? moved 'active))
  ;; atomic: a failing test rejects everything; bad pointers raise
  (check-exn exn:fail:json-patch? (lambda () (apply-json-patch p (list (hasheq 'op "test" 'path "/active" 'value #f)))))
  (check-exn exn:fail:json-patch? (lambda () (apply-json-patch p (list (hasheq 'op "replace" 'path "/nope" 'value 1)))))
  (check-exn exn:fail:json-patch? (lambda () (apply-json-patch p (list (hasheq 'op "remove" 'path "/name/3"))))))
