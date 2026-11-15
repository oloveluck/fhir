#lang racket/base

;;; fast-json-test.rkt — the fast JSON reader answers what racket/json answers.
;;;
;;; `fast-string->jsexpr` (serialize/fast-json.rkt) scans a string and gives anything it does not read
;;; plainly to racket/json. Held here to racket/json's own answer — the same value, or the same error
;;; message — over every JSON file of the R4 and R5 core packages and HL7's examples, generated values
;;; (every escape, numbers of every shape, nesting, repeated keys) and those texts mutated (a character
;;; dropped, doubled or replaced: mostly not JSON, where a reader that accepts too much would show).
;;; It also counts how many texts the scan read itself: a scan that refused everything would agree.

(require rackunit racket/list racket/string racket/file json file/gunzip
         (only-in fhir/spec-package spec-package-path)
         (only-in fhir/serialize/fast-json fast-string->jsexpr fast-bytes->jsexpr)
         (only-in fhir/package read-package)
         (only-in (submod fhir/serialize/fast-json scan) scan refused))

;; outcome : (string -> jsexpr) string -> (list 'ok jsexpr) | (list 'error message)
(define (outcome read s)
  (with-handlers ([exn:fail? (lambda (e) (list 'error (exn-message e)))]) (list 'ok (read s))))
(define (agree? s) (equal? (outcome fast-string->jsexpr s) (outcome string->jsexpr s)))

;; the texts: package files, written back as racket/json writes them and as HL7 wrote them
(define package-texts
  (append*
   (for/list ([name (in-list '("hl7.fhir.r4.core.tgz" "hl7.fhir.r5.core.tgz"))])
     (define p (spec-package-path name #:optional? #t))
     (if p
         (let-values ([(_m rs ex) (read-package p #:select (lambda (n) (regexp-match? #rx"(Patient|Observation|ValueSet|SearchParameter|OperationDefinition)" n)))])
           (for/list ([r (in-list (append rs ex))]) (jsexpr->string (if (pair? r) (cdr r) r))))
         '()))))
(define example-texts
  (for/list ([f (in-directory (collection-file-path "tests/vendor/fhir-examples" "fhir"))]
             #:when (regexp-match? #rx"[.]json$" (path->string f)))
    (file->string f)))
(define corpus (append example-texts package-texts))

;; every corpus text: the same value
(define disagreements (for/list ([s (in-list corpus)] #:unless (agree? s)) (substring s 0 (min 200 (string-length s)))))
(check-equal? disagreements '())
(check-true (> (length corpus) 500) (format "~a texts" (length corpus)))
;; and the scan read every one itself (none was given to racket/json)
(check-equal? (for/sum ([s (in-list corpus)]) (if (eq? (scan s) refused) 1 0)) 0)

;; generated values
(define rng (make-pseudo-random-generator))
(parameterize ([current-pseudo-random-generator rng]) (random-seed 20261115))
(define (pick xs) (list-ref xs (random (length xs) rng)))
(define pieces '("a" "é" "😀" "\\n" "\\t" "\\\"" "\\\\" "\\/" "\\u00e9" "\\uD83D\\uDE00" "\\b" "\\f" "\\r" " " "\n" "x\ty"))
(define numbers '("0" "-0" "7" "-12" "1.5" "1.50" "0.001" "-0.0" "1e3" "1E-3" "2.5e+10" "123456789012345678901234567890" "1e400" "-1e-400" "3.14159265358979323846"))
(define (gen d)
  (define r (random (if (<= d 0) 4 7) rng))
  (case r
    [(0) (format "\"~a\"" (string-append* (for/list ([_ (in-range (random 4 rng))]) (pick pieces))))]
    [(1) (pick numbers)]
    [(2) (pick '("true" "false" "null"))]
    [(3) (pick '("[]" "{}"))]
    [(4 5) (format "{~a}" (string-join (for/list ([_ (in-range (add1 (random 4 rng)))])
                                         (format "~a\"~a\"~a:~a~a" (pick '("" " " "\n")) (pick '("a" "b" "id" "é" "a")) (pick '("" " ")) (pick '("" " ")) (gen (sub1 d))))
                                       ","))]
    [else (format "[~a]" (string-join (for/list ([_ (in-range (random 4 rng))]) (gen (sub1 d))) (pick '("," ", " " ,\n"))))]))
(define generated (for/list ([_ (in-range 4000)]) (gen 4)))
(check-equal? (for/list ([s (in-list generated)] #:unless (agree? s)) s) '())
(check-equal? (for/sum ([s (in-list generated)]) (if (eq? (scan s) refused) 1 0)) 0)

;; mutated texts: mostly errors, which must be racket/json's
(define (mutate s)
  (define n (string-length s))
  (if (zero? n) s
      (let ([i (random n rng)])
        (case (random 3 rng)
          [(0) (string-append (substring s 0 i) (substring s (add1 i)))]
          [(1) (string-append (substring s 0 i) (substring s i (add1 i)) (substring s i))]
          [else (string-append (substring s 0 i) (pick '("\"" "," "}" "]" "\\" "e" "-" "." " " "x" "0")) (substring s (add1 i)))]))))
(define mutated (for/list ([_ (in-range 4000)]) (mutate (pick (append generated (take corpus (min 200 (length corpus))))))))
(check-equal? (for/list ([s (in-list mutated)] #:unless (agree? s)) s) '())

;; the bytes reader too
(for ([s (in-list (take generated 500))])
  (check-equal? (outcome fast-bytes->jsexpr (string->bytes/utf-8 s)) (outcome bytes->jsexpr (string->bytes/utf-8 s)) s))
