#lang racket/base

;;; rest-data-source.rkt — a FHIR server's REST API as a data source (fhir/data-source).
;;;
;;; The data source is read-only: `all` and `search` page through searchsets (following the Bundle's
;;; `next` link), `read` is GET [base]/Type/id, `of-patient` searches by the type's patient
;;; reference (`patient`, else `subject`), else reads every resource of the type and keeps the
;;; patient's. Writing is separate and explicit (`rest-write!`, PUT or POST): a workspace commits
;;; staged changes through it, and only when its configuration allows writes to the server.
;;;
;;; A Header is a string "Name: value" (an Authorization header, for instance).

(require racket/contract racket/string racket/port json
         net/url net/http-client net/uri-codec
         (only-in "data-source.rkt" data-source data-source? patient-reference-of)
         (only-in "data-source.rkt" data-source-all data-source-read data-source-of-patient data-source-search))

(provide
 (contract-out
  ;; rest->data-source : base-url [#:headers] -> data-source
  [rest->data-source (->* (string?) (#:headers (listof string?) #:page-size exact-positive-integer?) data-source?)]
  ;; rest-write! : base-url resource [#:headers] -> (values status resource-or-outcome|#f)
  ;; PUT [base]/Type/id when the resource has an id, POST [base]/Type when it has none
  [rest-write! (->* (string? hash?) (#:headers (listof string?)) (values exact-integer? (or/c hash? #f)))]
  ;; rest-url? : string -> boolean   an http(s) url
  [rest-url? (-> string? boolean?)]))


(define (rest-url? s) (regexp-match? #rx"^https?://" s))

;; at most this many pages per search: a server that keeps answering `next` does not run forever
(define max-pages 200)

;; request : method url-string body headers -> (values status jsexpr|#f)
(define (request method url-string body headers)
  (define u (string->url url-string))
  (define ssl? (equal? (url-scheme u) "https"))
  (define host (url-host u))
  (define port (or (url-port u) (if ssl? 443 80)))
  (define path (let ([s (url->string (struct-copy url u [scheme #f] [host #f] [port #f] [user #f]))])
                 (if (string=? s "") "/" s)))
  (define-values (status _headers in)
    (http-sendrecv host path #:ssl? ssl? #:port port #:method method
                   #:headers (append (list "Accept: application/fhir+json")
                                     (if body (list "Content-Type: application/fhir+json") '())
                                     headers)
                   #:data (and body (jsexpr->bytes body))))
  (define code (let ([m (regexp-match #rx#"^[^ ]+ ([0-9]+)" status)]) (if m (string->number (bytes->string/utf-8 (cadr m))) 0)))
  (define text (port->string in))
  (values code (with-handlers ([exn:fail? (lambda (_) #f)]) (let ([j (string->jsexpr text)]) (and (hash? j) j)))))

;; outcome-text : jsexpr|#f -> string   an OperationOutcome's diagnostics, for an error message
(define (outcome-text j)
  (if (and (hash? j) (equal? (hash-ref j 'resourceType #f) "OperationOutcome"))
      (string-join (for/list ([i (in-list (hash-ref j 'issue '()))])
                     (or (hash-ref i 'diagnostics #f) (let ([d (hash-ref i 'details #f)]) (and (hash? d) (hash-ref d 'text #f))) (hash-ref i 'code "")))
                   "; ")
      ""))

;; join : base path -> url
(define (join base path) (string-append (regexp-replace #rx"/+$" base "") "/" path))

;; query-string : (listof (cons name value)) -> string
(define (query-string params)
  (string-join (for/list ([p (in-list params)]) (string-append (uri-encode (format "~a" (car p))) "=" (uri-encode (format "~a" (cdr p))))) "&"))

;; matches : Bundle -> (listof resource)   the searchset's matches (an `include` entry is not one)
(define (matches b)
  (for/list ([e (in-list (hash-ref b 'entry '()))]
             #:when (hash? (hash-ref e 'resource #f))
             #:unless (equal? (hash-ref (hash-ref e 'search (hasheq)) 'mode #f) "include"))
    (hash-ref e 'resource)))
(define (next-link b)
  (for/first ([l (in-list (hash-ref b 'link '()))] #:when (equal? (hash-ref l 'relation #f) "next"))
    (hash-ref l 'url #f)))

;; searchset : url headers -> (listof resource)   every page; an error status raises
(define (searchset url headers)
  (let loop ([url url] [pages 0] [acc '()])
    (define-values (code b) (request "GET" url #f headers))
    (unless (and (<= 200 code 299) (hash? b) (equal? (hash-ref b 'resourceType #f) "Bundle"))
      (raise (exn:fail:rest (format "GET ~a: ~a ~a" url code (outcome-text b)) (current-continuation-marks) code)))
    (define acc* (append acc (matches b)))
    (define next (next-link b))
    (if (and next (< (add1 pages) max-pages)) (loop next (add1 pages) acc*) acc*)))
(struct exn:fail:rest exn:fail (status))

(define (rest->data-source base #:headers [headers '()] #:page-size [page-size 200])
  (define (search type params)
    (searchset (string-append (join base type) "?" (query-string (append params (list (cons "_count" page-size))))) headers))
  (define (all type) (search type '()))
  (define (read type id)
    (define-values (code r) (request "GET" (join base (string-append type "/" (uri-encode id))) #f headers))
    (cond [(and (<= 200 code 299) (hash? r)) r]
          [(memv code '(404 410)) #f]
          [else (error 'rest->data-source "GET ~a/~a: ~a ~a" type id code (outcome-text r))]))
  ;; the parameter that finds a type's resources by patient, learned per type
  (define by-patient (make-hash))
  (define (of-patient type pid)
    (define ref (string-append "Patient/" pid))
    (cond
      [(equal? type "Patient") (let ([p (read "Patient" pid)]) (if p (list p) '()))]
      [else
       (define (try name) (with-handlers ([exn:fail:rest? (lambda (_) #f)]) (search type (list (cons name ref)))))
       (define known (hash-ref by-patient type #f))
       (define found (or (and known (not (eq? known 'scan)) (try known))
                         (and (not known) (for/or ([n (in-list '("patient" "subject"))])
                                            (define r (try n)) (when r (hash-set! by-patient type n)) r))))
       (or found
           (begin (hash-set! by-patient type 'scan)
                  (filter (lambda (r) (member ref (patient-reference-of r))) (all type))))]))
  (data-source all read of-patient search))

(define (rest-write! base resource #:headers [headers '()])
  (define type (hash-ref resource 'resourceType))
  (define id (hash-ref resource 'id #f))
  (if id
      (request "PUT" (join base (string-append type "/" (uri-encode id))) resource headers)
      (request "POST" (join base type) resource headers)))

(module+ test
  (require rackunit racket/tcp racket/string)
  ;; a tiny FHIR server: two pages of Observations, a Patient, a write echoed back
  (define (respond out code body)
    (define s (jsexpr->string body))
    (fprintf out "HTTP/1.1 ~a X\r\nContent-Type: application/fhir+json\r\nContent-Length: ~a\r\nConnection: close\r\n\r\n~a"
             code (bytes-length (string->bytes/utf-8 s)) s))
  (define listener (tcp-listen 0 8 #t "127.0.0.1"))
  (define-values (_a port _b _c) (tcp-addresses listener #t))
  (define base (format "http://127.0.0.1:~a/fhir" port))
  (define p1 (hasheq 'resourceType "Patient" 'id "p1"))
  (define (obs id pid) (hasheq 'resourceType "Observation" 'id id 'subject (hasheq 'reference (string-append "Patient/" pid))))
  (define (bundle rs next) (hasheq 'resourceType "Bundle" 'type "searchset"
                                   'link (if next (list (hasheq 'relation "next" 'url next)) '())
                                   'entry (for/list ([r rs]) (hasheq 'resource r 'search (hasheq 'mode "match")))))
  (define seen '())
  (define server
    (thread
     (lambda ()
       (let loop ()
         (define-values (in out) (tcp-accept listener))
         (define line (read-line in 'return-linefeed))
         (define headers (let h ([acc '()]) (define l (read-line in 'return-linefeed)) (if (or (eof-object? l) (string=? l "")) acc (h (cons l acc)))))
         (define len (for/or ([h headers]) (let ([m (regexp-match #rx"^(?i:content-length): *([0-9]+)" h)]) (and m (string->number (cadr m))))))
         (define body (and len (read-string len in)))
         (define target (cadr (string-split line " ")))
         (set! seen (cons (string-append (car (string-split line " ")) " " target) seen))
         (cond
           [(regexp-match? #rx"^/fhir/Patient/p1$" target) (respond out 200 p1)]
           [(regexp-match? #rx"^/fhir/Patient/" target) (respond out 404 (hasheq 'resourceType "OperationOutcome" 'issue (list (hasheq 'code "not-found"))))]
           [(regexp-match? #rx"^/fhir/Observation[?]patient=" target)
            (respond out 400 (hasheq 'resourceType "OperationOutcome" 'issue (list (hasheq 'code "not-supported" 'diagnostics "unknown parameter patient"))))]
           [(regexp-match? #rx"^/fhir/Observation[?]subject=Patient%2Fp1" target) (respond out 200 (bundle (list (obs "o1" "p1")) #f))]
           [(regexp-match? #rx"^/fhir/Observation[?]_count" target) (respond out 200 (bundle (list (obs "o1" "p1")) (format "~a/Observation?page=2" base)))]
           [(regexp-match? #rx"^/fhir/Observation[?]page=2" target) (respond out 200 (bundle (list (obs "o2" "p2")) #f))]
           [(regexp-match? #rx"^/fhir/Observation/o9$" target) (respond out 201 (string->jsexpr body))]
           [else (respond out 404 (hasheq 'resourceType "OperationOutcome"))])
         (close-output-port out) (close-input-port in)
         (loop)))))
  (define ds (rest->data-source base))
  (check-equal? (map (lambda (r) (hash-ref r 'id)) ((data-source-all ds) "Observation")) '("o1" "o2"))   ; both pages
  (check-equal? ((data-source-read ds) "Patient" "p1") p1)
  (check-false ((data-source-read ds) "Patient" "nobody"))
  ;; `patient` refused, so `subject` is used, and remembered
  (check-equal? (map (lambda (r) (hash-ref r 'id)) ((data-source-of-patient ds) "Observation" "p1")) '("o1"))
  (check-equal? (map (lambda (r) (hash-ref r 'id)) ((data-source-of-patient ds) "Observation" "p1")) '("o1"))
  (check-equal? (length (filter (lambda (s) (regexp-match? #rx"patient=" s)) seen)) 1)
  (check-equal? ((data-source-of-patient ds) "Patient" "p1") (list p1))
  (check-equal? (map (lambda (r) (hash-ref r 'id)) ((data-source-search ds) "Observation" (list (cons "subject" "Patient/p1")))) '("o1"))
  (define-values (code written) (rest-write! base (obs "o9" "p1")))
  (check-equal? code 201)
  (check-equal? (hash-ref written 'id) "o9")
  (check-true (and (member "PUT /fhir/Observation/o9" seen) #t))
  (check-true (rest-url? "https://hapi.fhir.org/baseR4"))
  (check-false (rest-url? "data/patients"))
  (kill-thread server)
  (tcp-close listener))
