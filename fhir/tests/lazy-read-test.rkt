#lang racket/base

;;; lazy-read-test.rkt — a lenient read is lazy, and lazy is the same node.
;;;
;;; `from-json #:lenient? #t` answers a node whose fields are read when first asked
;;; (model/node.rkt, serialize/from-json.rkt). Over HL7's R5 examples and the R5 core package:
;;; - nothing is read until asked, and a node asked for one element reads only the objects on the way;
;;; - every resource that reads strictly (eager) is `equal?` to its lenient read and writes back as the
;;;   same JSON;
;;; - what the read left out, recorded on each node (`node-drops`), is what comparing the JSON with
;;;   the node written back finds (`lenient-drops`), on resources read as they are and with planted
;;;   mistakes (an element the type lacks, a date its month lacks, a nested one, a list item).

(require rackunit racket/list racket/file json
         fhir/r5/schemas fhir/model/node fhir/result/result
         (only-in fhir/package read-package) (only-in fhir/spec-package spec-package-path)
         (only-in fhir/serialize/from-json from-json) (only-in fhir/serialize/to-json node->json-string)
         (only-in fhir/serialize/lenient lenient-drops node-drops))

(define examples
  (for/list ([f (in-directory (collection-file-path "tests/vendor/fhir-examples/r5" "fhir"))]
             #:when (regexp-match? #rx"[.]json$" (path->string f)))
    (call-with-input-file f read-json)))
(define package
  (let ([p (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t)])
    (if p
        (let-values ([(_m rs ex) (read-package p #:select (lambda (n) (regexp-match? #rx"(ValueSet|CodeSystem|SearchParameter|OperationDefinition|CapabilityStatement)-" n)))])
          (map (lambda (r) (if (pair? r) (cdr r) r)) (append rs ex)))
        '())))
(define corpus (append examples (take package (min 600 (length package)))))

;; read-only-count : node -> natural   the nodes of a tree whose fields have been read
(define (read-count v)
  (cond [(fhir? v) (if (fhir-read? v) (add1 (for/sum ([(k x) (in-hash (fhir-fields v))]) (read-count x))) 0)]
        [(list? v) (for/sum ([x (in-list v)]) (read-count x))]
        [else 0]))

;; lazy: nothing read until asked; one element reads one object
(let ([n (ok-value (from-json (hasheq 'resourceType "Patient" 'id "a" 'name (list (hasheq 'family "Ng" 'given (list "Ann")))
                                      'contact (list (hasheq 'name (hasheq 'family "Ng"))))
                              #:lenient? #t))])
  (check-false (fhir-read? n))
  (check-equal? (read-count n) 0)
  (fhir-ref n 'id)
  (check-equal? (read-count n) 1 "the resource's own fields, not its names or contacts")
  (fhir-fields (car (fhir-ref n 'name)))
  (check-equal? (read-count n) 2))

;; the same node, the same JSON
(define-values (strict-equal lenient-only)
  (for/fold ([same 0] [only 0]) ([js (in-list corpus)])
    (define s (from-json js))
    (define r (from-json js #:lenient? #t))
    (define l (and (ok? r) (ok-value r)))
    (cond [(not l) (values same only)]                         ; a type this version lacks
          [(ok? s)
           (check-equal? l (ok-value s) (format "~a/~a" (hash-ref js 'resourceType) (hash-ref js 'id #f)))
           (check-equal? (node->json-string l) (node->json-string (ok-value s)))
           (values (add1 same) only)]
          [else (values same (add1 only))])))
(check-true (> strict-equal 500) (format "~a resources read strictly" strict-equal))

;; what was left out, two ways
(define (planted js)
  (list js
        (hash-set js 'nmae "x")
        (if (hash-has-key? js 'meta) (hash-set js 'meta (hash-set (hash-ref js 'meta) 'lastUpdated "2020-02-30T00:00:00Z")) js)
        (if (hash-has-key? js 'text) (hash-set js 'text (hash-set (hash-ref js 'text) 'colour "red")) js)
        (if (and (hash-has-key? js 'identifier) (list? (hash-ref js 'identifier)))
            (hash-set js 'identifier (cons (hasheq 'value 1 'period (hasheq 'start "1990-13-01")) (hash-ref js 'identifier)))
            js)))
(define compared
  (for*/sum ([js0 (in-list corpus)] [js (in-list (planted js0))]
             [r (in-value (from-json js #:lenient? #t))] #:when (ok? r))
    (define n (ok-value r))
    (check-equal? (node-drops n) (lenient-drops js n) (format "~a/~a" (hash-ref js 'resourceType) (hash-ref js 'id #f)))
    1))
(check-true (> compared 2000))
