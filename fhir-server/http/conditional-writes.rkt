#lang racket/base

;;; conditional-writes.rkt — the writes FHIR makes conditional on a search
;;; (https://hl7.org/fhir/http.html#ccreate, #cond-update, #cdelete):
;;;   - a create with `If-None-Exist: <search>` is made only when the search finds nothing; when it
;;;     finds one resource that one is the answer (200, nothing written);
;;;   - `PUT /{Type}?<search>` updates the one resource the search finds, or creates one when it
;;;     finds none;
;;;   - `DELETE /{Type}?<search>` deletes the one resource the search finds (nothing to do when it
;;;     finds none).
;;; A search that finds several is 412 Precondition Failed: the client's criteria were not
;;; selective enough, and nothing is written. The search is held strictly: a parameter the server
;;; cannot apply is the client's 400, never ignored (ignored, the criteria would match what they do
;;; not say).
;;;
;;; Data definitions
;;;   A Step is one of:
;;;     #f                                 the request is not a conditional write: answer it as it is
;;;     (answered status jsexpr)           answered here: the resource found, or why nothing is written
;;;     (rewritten method path body)       the plain write it is: on the resource the search found, or
;;;                                        the create it becomes

(require racket/string racket/list racket/contract
         (only-in json jsexpr->string bytes->jsexpr string->jsexpr)
         (only-in fhir/capability/runtime app? current-search-strict?)
         (only-in "router.rkt" handle/raw parse-query))

(provide
 (struct-out answered)
 (struct-out rewritten)
 (contract-out
  [conditional-step (-> app? string? string? string? (listof (cons/c string? string?)) string?
                        (or/c #f answered? rewritten?))]))

(struct answered (status js) #:transparent)
(struct rewritten (method path body) #:transparent)

;; conditional-step : app method path query-text Headers body -> Step
(define (conditional-step app method path query headers body)
  (define segs (filter (lambda (s) (positive? (string-length s))) (string-split path "/")))
  (define type (and (= (length segs) 1) (regexp-match? #px"^[A-Z][A-Za-z]+$" (car segs)) (car segs)))
  (define if-none-exist (let ([h (assoc "if-none-exist" headers)]) (and h (cdr h))))
  (cond
    [(not type) #f]
    [(and (equal? method "POST") if-none-exist) (conditional-create app type (criteria type if-none-exist))]
    [(and (equal? method "PUT") (non-empty? query)) (conditional-update app type query body)]
    [(and (equal? method "DELETE") (non-empty? query)) (conditional-delete app type query)]
    [else #f]))

(define (non-empty? s) (positive? (string-length (string-trim s))))

;; criteria : type header-text -> query-text   `If-None-Exist` is the search's parameters, written
;; with or without a leading `?` or `Type?`
(define (criteria type text)
  (define t (string-trim text))
  (cond [(string-prefix? t (string-append type "?")) (substring t (add1 (string-length type)))]
        [(string-prefix? t "?") (substring t 1)]
        [else t]))

;; A Matches is (matches count resources) — how many the search found, and the first of them (at
;; most two) — or an Answered (the search's own refusal: a parameter the server cannot apply,
;; search not served)
(struct matches (count resources) #:transparent)

;; search-matches : app type query-text -> Matches | Answered   the search, strict, at most two looked at
(define (search-matches app type query)
  (define params (append (filter (lambda (p) (not (memq (car p) '(_count _offset _sort _summary)))) (parse-query query))
                         '((_count . "2"))))
  (define-values (status bytes _ctype)
    (parameterize ([current-search-strict? #t]) (handle/raw app "GET" (string-append "/" type) params "")))
  (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bytes)))
  (cond
    [(not (and (= status 200) (hash? js) (equal? (hash-ref js 'resourceType #f) "Bundle")))
     (answered (if (= status 200) 500 status) js)]
    [else
     (define found (for/list ([e (in-list (hash-ref js 'entry '()))]
                              #:when (equal? (hash-ref (hash-ref e 'search (hasheq)) 'mode "match") "match")
                              #:when (hash? (hash-ref e 'resource #f)))
                     (hash-ref e 'resource)))
     (define total (hash-ref js 'total #f))
     ;; the total when the search says it, else what it answered (a repository that does not page)
     (define n (if (exact-nonnegative-integer? total) (max total (length found)) (length found)))
     (matches n found)]))

(define (several type query n)
  (answered 412 (outcome "multiple-matches"
                         (format "~a matches ~a ~a resources: a conditional write needs criteria that find at most one, and nothing was written"
                                 query (if (> n 2) "more than two" (number->string n)) type))))

;; conditional-create : app type query-text -> Step
(define (conditional-create app type query)
  (define m (search-matches app type query))
  (cond
    [(answered? m) m]
    [else (case (matches-count m)
            [(0) #f]
            [(1) (answered 200 (car (matches-resources m)))]
            [else (several type query (matches-count m))])]))

;; conditional-update : app type query-text body -> Step
(define (conditional-update app type query body)
  (define m (search-matches app type query))
  (define given (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr body)))
  (define given-id (and (hash? given) (hash-ref given 'id #f)))
  (cond
    [(answered? m) m]
    [else
     (case (matches-count m)
       ;; none: the create it becomes, with the id the body gives (PUT) or the server's (POST)
       [(0) (if (string? given-id)
                (rewritten "PUT" (format "/~a/~a" type given-id) body)
                (rewritten "POST" (string-append "/" type) body))]
       [(1)
        (define id (hash-ref (car (matches-resources m)) 'id ""))
        (cond
          [(and (string? given-id) (not (equal? given-id id)))
           (answered 400 (outcome "invalid" (format "the body's id is ~a, but ~a finds ~a/~a" given-id query type id)))]
          [(hash? given) (rewritten "PUT" (format "/~a/~a" type id) (jsexpr->string (hash-set given 'id id)))]
          [else (rewritten "PUT" (format "/~a/~a" type id) body)])]
       [else (several type query (matches-count m))])]))

;; conditional-delete : app type query-text -> Step
(define (conditional-delete app type query)
  (define m (search-matches app type query))
  (cond
    [(answered? m) m]
    [else
     (case (matches-count m)
       [(0) (answered 200 (hasheq 'resourceType "OperationOutcome"
                                  'issue (list (hasheq 'severity "information" 'code "not-found"
                                                       'diagnostics (format "~a matches no ~a: nothing to delete" query type)))))]
       [(1) (rewritten "DELETE" (format "/~a/~a" type (hash-ref (car (matches-resources m)) 'id "")) "")]
       [else (several type query (matches-count m))])]))

(define (outcome code msg)
  (hasheq 'resourceType "OperationOutcome" 'issue (list (hasheq 'severity "error" 'code code 'diagnostics msg))))

(module+ test
  (require rackunit)
  (check-equal? (criteria "Patient" "identifier=a|1") "identifier=a|1")
  (check-equal? (criteria "Patient" "?identifier=a|1") "identifier=a|1")
  (check-equal? (criteria "Patient" "Patient?identifier=a|1") "identifier=a|1"))
