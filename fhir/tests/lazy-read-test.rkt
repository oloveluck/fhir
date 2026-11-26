#lang racket/base

;;; lazy-read-test.rkt — a lenient read is lazy, and lazy is the same node.
;;;
;;; `from-json #:lenient? #t` answers a node whose fields are read when first asked
;;; (model/node.rkt, serialize/from-json.rkt). Over HL7's R5 examples and the R5 core package:
;;; - nothing is read until asked, a node asked for one element reads that element alone, and a
;;;   node read a field at a time, in any order, with names it has and names it lacks, is the node
;;;   read whole: the same values (the very ones, once it is read whole), the same JSON written
;;;   back, the same record of what was left out — and what it says it left out SO FAR is, of that
;;;   record, the keys the type lacks and the asked keys that did not read;
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

;; read-names : node -> (listof symbol)   the fields read of a node so far, by name
(define (read-names n) (sort (hash-keys (fhir-fields-read n)) symbol<?))

;; lazy: nothing read until asked; one element asked reads that element, of that object
(let ([n (ok-value (from-json (hasheq 'resourceType "Patient" 'id "a" 'birthDate "1990-02-30"
                                      'name (list (hasheq 'family "Ng" 'given (list "Ann")))
                                      'contact (list (hasheq 'name (hasheq 'family "Ng"))))
                              #:lenient? #t))])
  (check-false (fhir-read? n))
  (check-equal? (read-names n) '())
  (check-equal? (fhir-drops-read n) '())
  (fhir-ref n 'id)
  (check-equal? (read-names n) '(id) "the id alone: not the names, the contacts or the date")
  (check-false (fhir-read? n))
  (define name (car (fhir-ref n 'name)))
  (check-equal? (read-names n) '(id name))
  (check-equal? (read-names name) '() "the name is there; nothing of it has been read")
  (fhir-ref name 'family)
  (check-equal? (read-names name) '(family))
  ;; a date that is no date is left out when it is asked for, and said then
  (check-equal? (fhir-drops-read n) '())
  (check-false (fhir-has? n 'birthDate))
  (check-equal? (fhir-drops-read n) '((birthDate . "1990-02-30")))
  ;; all of it, when all is asked: the values already read are the ones kept
  (check-eq? (car (hash-ref (fhir-fields n) 'name)) name)
  (check-true (fhir-read? n))
  (check-equal? (read-names n) '(contact id name))
  (check-equal? (fhir-drops n) '((birthDate . "1990-02-30"))))

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

;; a field at a time. Each resource (and each with a planted mistake) is read twice: whole, and by
;; asking for fields one by one — its own keys, shuffled, with names it lacks and `_` siblings
;; among them, some asked twice — at every level, then whole. The two must be one node.
(define rng (make-pseudo-random-generator))
(parameterize ([current-pseudo-random-generator rng]) (random-seed 20261126))
(define (shuffled xs) (map cdr (sort (map (lambda (x) (cons (random 1000000 rng) x)) xs) < #:key car)))
;; ask! : node json natural -> natural   asks the node for fields one at a time, and its nested
;; nodes for theirs; answers how many were asked
(define (ask! n js depth)
  (define names (shuffled (append (hash-keys js) (list 'nope 'value 'id 'extension (car (shuffled (cons 'text (hash-keys js))))))))
  (for/sum ([k (in-list names)])
    (define v (fhir-ref n k absent))
    ;; has? agrees with ref, and asking again answers the same value
    (check-equal? (fhir-has? n k) (not (eq? v absent)))
    (check-eq? (fhir-ref n k absent) v)
    (add1 (cond [(> depth 3) 0]
                [(and (fhir? v) (hash? (hash-ref js k #f))) (ask! v (hash-ref js k) (add1 depth))]
                [(and (list? v) (list? (hash-ref js k #f)) (= (length v) (length (hash-ref js k))))
                 (for/sum ([x (in-list v)] [j (in-list (hash-ref js k))]) (if (and (fhir? x) (hash? j)) (ask! x j (add1 depth)) 0))]
                [else 0]))))
(define absent (string->uninterned-symbol "absent"))
(define asked
  (for*/sum ([js0 (in-list (take (shuffled corpus) (min 250 (length corpus))))] [js (in-list (planted js0))]
             [r (in-value (from-json js #:lenient? #t))] #:when (ok? r))
    (define whole (ok-value (from-json js #:lenient? #t)))
    (define n (ok-value r))
    (define label (format "~a/~a" (hash-ref js 'resourceType) (hash-ref js 'id #f)))
    (define count (ask! n js 0))
    ;; so far: what it left out is, of the whole read's record, the keys the type lacks and the
    ;; asked keys that did not read — never something the whole read does not record
    (define all-drops (fhir-drops whole))
    (for ([d (in-list (fhir-drops-read n))]) (check-not-false (member d all-drops) label))
    (for ([(k v) (in-hash (fhir-fields-read n))]) (check-equal? v (hash-ref (fhir-fields whole) k absent) label))
    ;; every key of the object was asked, so nothing the whole read records is missing
    (check-equal? (sort (map car (fhir-drops-read n)) symbol<?) (sort (map car all-drops) symbol<?) label)
    ;; then whole: the same node, the same JSON, the same drops, the values already answered kept
    (define before (fhir-fields-read n))
    (check-equal? n whole label)
    (check-equal? (node->json-string n) (node->json-string whole) label)
    (check-equal? (node-drops n) (node-drops whole) label)
    (check-equal? (node-drops n) (lenient-drops js n) label)
    (for ([(k v) (in-hash before)]) (check-eq? (hash-ref (fhir-fields n) k) v label))
    count))
(check-true (> asked 10000) (format "~a fields asked one at a time" asked))
