#lang racket/base

;;; fhirpath-suite.rkt — another FHIRPath engine held to HL7's FHIRPath test suite.
;;;
;;;   racket clients/python/bench/fhirpath-suite.rkt [--python <python>] [--show <n>]
;;;
;;; The suite is the one this family's own engine is held to (fhirpath/tests/vendor/tests-fhir-r4.xml,
;;; with its input resources as JSON): 934 tests, each an expression over a resource with the values
;;; it must give, or the kind of error it must be. `raco fhirpath --tck r4` runs this engine over it
;;; (932 of 934, values compared WITH their types). Here fhirpathpy is asked the same expressions,
;;; through a bridge that only evaluates and prints (fhirpathpy_bridge.py), and this program decides.
;;;
;;; An Answer is (listof Shown) | (failed message); a Shown is (cons kind text) as the bridge writes it.
;;; The comparison is deliberately the kinder one: a value is right when it EQUALS the expected one —
;;; as a number, as a moment in time, else as text — whatever type the engine gave it (a date read
;;; from a resource as a plain string counts as the date). A test marked invalid is passed by any error.
;;; So the count is no lower than a typed comparison would give.

(require racket/list racket/string racket/port racket/system racket/cmdline json xml
         (only-in fhirpath/decimal parse-decimal decimal-cmp)
         (only-in fhirpath/temporal-ops moment-equiv? parse-fp-date parse-fp-datetime parse-fp-time))

(struct failed (message))

;; ---- the suite --------------------------------------------------------------------------------
(define suite (collection-file-path "tests/vendor/tests-fhir-r4.xml" "fhirpath"))
(define inputs (collection-file-path "tests/inputs-r4" "fhirpath"))

(define (children e name)
  (filter (lambda (c) (and (element? c) (eq? (element-name c) name))) (element-content e)))
(define (attr e name)
  (for/first ([a (in-list (element-attributes e))] #:when (eq? (attribute-name a) name)) (attribute-value a)))
(define (text-of e)
  (apply string-append (for/list ([c (in-list (element-content e))])
                         (cond [(pcdata? c) (pcdata-string c)]
                               [(entity? c) (let ([t (entity-text c)]) (if (number? t) (string (integer->char t)) (case t [(lt) "<"] [(gt) ">"] [(amp) "&"] [(quot) "\""] [(apos) "'"] [else ""])))]
                               [else ""]))))

;; A Test is (test name expression input invalid predicate? outputs): input a path or #f, invalid
;; #f or the kind of error expected, outputs (listof (cons type|#f text))
(struct test (name expression input invalid predicate? outputs))

;; suite-tests : -> (listof Test)   those with an expression whose input resource is there
(define (suite-tests)
  (define doc (call-with-input-file suite read-xml))
  (define (walk x)
    (cond [(and (element? x) (eq? (element-name x) 'test)) (list x)]
          [(element? x) (append-map walk (element-content x))]
          [else '()]))
  (for*/list ([t (in-list (walk (document-element doc)))]
              [e (in-value (let ([es (children t 'expression)]) (and (pair? es) (car es))))]
              #:when e
              [file (in-value (let ([f (attr t 'inputfile)]) (and f (build-path inputs (regexp-replace #rx"[.]xml$" f ".json")))))]
              #:when (or (not file) (file-exists? file)))
    (define invalid (or (attr e 'invalid) (attr t 'invalid)))
    (test (attr t 'name) (text-of e) (and file (path->string file))
          (and (member invalid '("syntax" "semantic" "execution" "true")) invalid)
          (equal? (attr t 'predicate) "true")
          (for/list ([o (in-list (children t 'output))]) (cons (attr o 'type) (text-of o))))))

;; ---- asking the engine --------------------------------------------------------------------------
;; answers : python (listof Test) -> (hash index Answer)
(define (answers python tests)
  (define bridge (path->string (build-path (path-only* (variable-reference->module-source (#%variable-reference))) "fhirpathpy_bridge.py")))
  (define jobs (string-join (for/list ([t (in-list tests)] [i (in-naturals)])
                              (jsexpr->string (hasheq 'id i 'expression (test-expression t) 'input (or (test-input t) 'null))))
                            "\n"))
  (define out (open-output-string))
  (parameterize ([current-input-port (open-input-string jobs)] [current-output-port out])
    (unless (system* python bridge "r4") (error 'fhirpath-suite "the bridge failed: is fhirpathpy installed for ~a?" python)))
  (for/hash ([line (in-list (string-split (get-output-string out) "\n"))])
    (define js (string->jsexpr line))
    (values (hash-ref js 'id)
            (if (hash-has-key? js 'error)
                (failed (hash-ref js 'error))
                (for/list ([v (in-list (hash-ref js 'values))]) (cons (hash-ref v 'kind) (hash-ref v 'text)))))))
(define (path-only* p) (let-values ([(dir _n _d) (split-path p)]) dir))

;; ---- deciding -----------------------------------------------------------------------------------
;; moment-of : string -> moment | #f   a date, dateTime or time however it is written (@, T or bare)
(define (moment-of text)
  (define s (if (string-prefix? text "@") (substring text 1) text))
  (define (try parse s) (with-handlers ([(lambda (_) #t) (lambda (_) #f)]) (parse s)))
  (cond [(string-prefix? s "T") (try parse-fp-time (substring s 1))]
        [(regexp-match? #px"^\\d{2}:\\d{2}" s) (try parse-fp-time s)]
        [(regexp-match? #rx"T" s) (try parse-fp-datetime s)]
        [else (try parse-fp-date s)]))

;; same-number? : string string -> boolean
(define (same-number? a b)
  (define (dec s) (with-handlers ([(lambda (_) #t) (lambda (_) #f)]) (parse-decimal s)))
  (define x (dec a)) (define y (dec b))
  (and x y (= (decimal-cmp x y) 0)))

;; right-value? : Shown type|#f text -> boolean   the value given equals the one expected
(define (right-value? shown type text)
  (define given (cdr shown))
  (define (as-moments?) (let ([a (moment-of given)] [b (moment-of text)]) (and a b (moment-equiv? a b))))
  (cond
    [(equal? (car shown) "complex") #f]
    [(member type '("date" "dateTime" "time")) (as-moments?)]
    [(and (not type) (string-prefix? text "@")) (as-moments?)]
    [(member type '("decimal" "integer" "unsignedInt" "positiveInt" "long" "integer64")) (same-number? given text)]
    [(equal? type "Quantity") (equal? (regexp-replace* #rx" " given "") (regexp-replace* #rx" " text ""))]
    [else (or (equal? given text) (and (equal? (car shown) "decimal") (same-number? given text)))]))

;; as-boolean : (listof Shown) -> boolean   FHIRPath's reading of a collection as a predicate
(define (as-boolean values)
  (cond [(null? values) #f]
        [(and (null? (cdr values)) (equal? (car (car values)) "boolean")) (equal? (cdr (car values)) "true")]
        [else #t]))

;; verdict : Test Answer -> 'right | (list reason detail)
(define (verdict t answer)
  (cond
    [(failed? answer) (if (test-invalid t) 'right (list 'raised (failed-message answer)))]
    [(test-invalid t) (list 'no-error (format "an error (~a) was expected" (test-invalid t)))]
    [(test-predicate? t)
     (define expected (and (pair? (test-outputs t)) (equal? (cdr (car (test-outputs t))) "true")))
     (if (equal? (as-boolean answer) expected) 'right (list 'wrong (format "~a" (as-boolean answer))))]
    [(and (= (length answer) (length (test-outputs t)))
          (for/and ([v (in-list answer)] [o (in-list (test-outputs t))]) (right-value? v (car o) (cdr o))))
     'right]
    [else (list 'wrong (string-join (map cdr answer) ", "))]))

;; reason-class : string -> string   a raised error by what it is about (a function's name, else its start)
(define (reason-class message)
  (cond [(regexp-match #px"[Nn]ot implemented:? ?([A-Za-z]+)" message) => (lambda (m) (format "not implemented: ~a" (cadr m)))]
        [(regexp-match #px"^([A-Za-z]+): " message) => cadr]
        [else "other"]))

(module+ main
  (define python "python3")
  (define show 0)
  (command-line #:program "fhirpath-suite"
                #:once-each
                [("--python") p "the Python that has fhirpathpy" (set! python p)]
                [("--show") n "print the first n tests not passed" (set! show (string->number n))])
  (define tests (suite-tests))
  (define got (answers (or (find-executable-path python) python) tests))
  (define verdicts (for/list ([t (in-list tests)] [i (in-naturals)]) (cons t (verdict t (hash-ref got i (failed "no answer"))))))
  (define right (count (lambda (v) (eq? (cdr v) 'right)) verdicts))
  (define missed (filter (lambda (v) (not (eq? (cdr v) 'right))) verdicts))
  (printf "HL7's FHIRPath suite for R4, ~a tests with their input resources\n" (length tests))
  (printf "  fhirpathpy: ~a right (a value right when it equals the expected one, whatever its type)\n" right)
  (define (of reason) (count (lambda (v) (eq? (cadr v) reason)) missed))
  (printf "  not right: ~a — ~a gave other values, ~a raised an error, ~a gave an answer where an error is expected\n"
          (length missed) (of 'wrong) (of 'raised) (of 'no-error))
  (define raised (filter (lambda (v) (eq? (cadr v) 'raised)) missed))
  (define classes (sort (map (lambda (g) (cons (car g) (length g))) (group-by values (map (lambda (v) (reason-class (caddr v))) raised))) > #:key cdr))
  (unless (null? classes)
    (printf "  errors raised, by kind: ~a\n" (string-join (for/list ([c (in-list (take classes (min 8 (length classes))))]) (format "~a (~a)" (car c) (cdr c))) ", ")))
  (for ([v (in-list (take missed (min show (length missed))))])
    (define t (car v))
    (printf "    ~a  ~a\n      expected ~s~a; ~a: ~a\n" (test-name t) (test-expression t) (map cdr (test-outputs t))
            (if (test-invalid t) (format " (invalid: ~a)" (test-invalid t)) "") (cadr v) (caddr v))))

(module+ test
  (require rackunit)
  ;; a value is right by what it is, whatever the engine called it
  (check-true (right-value? '("string" . "1974-12-25") "date" "@1974-12-25"))
  (check-true (right-value? '("temporal" . "2012-04-15") #f "@2012-04-15"))
  (check-true (right-value? '("time" . "10:30:00") "time" "@T10:30:00"))
  (check-false (right-value? '("string" . "1974-12-26") "date" "@1974-12-25"))
  (check-true (right-value? '("decimal" . "3.50") "decimal" "3.5"))
  (check-true (right-value? '("decimal" . "2") "integer" "2"))
  (check-false (right-value? '("integer" . "3") "integer" "2"))
  (check-true (right-value? '("quantity" . "4 'mg'") "Quantity" "4 'mg'"))
  (check-true (right-value? '("string" . "Peter") "string" "Peter"))
  (check-false (right-value? '("complex" . "{}") "string" "{}"))
  ;; a collection read as a predicate
  (check-false (as-boolean '()))
  (check-true (as-boolean '(("string" . "x"))))
  (check-false (as-boolean '(("boolean" . "false"))))
  ;; verdicts: an error passes a test marked invalid and fails any other
  (define plain (test "t" "1" #f #f #f '(("integer" . "1"))))
  (define bad (test "t" "1 +" #f "syntax" #f '()))
  (check-eq? (verdict plain '(("integer" . "1"))) 'right)
  (check-equal? (car (verdict plain '(("integer" . "2")))) 'wrong)
  (check-equal? (car (verdict plain (failed "x"))) 'raised)
  (check-eq? (verdict bad (failed "x")) 'right)
  (check-equal? (car (verdict bad '())) 'no-error)
  ;; the suite is read whole
  (check-true (> (length (suite-tests)) 900)))
