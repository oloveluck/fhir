#lang racket/base

;;; fast-json.rkt — JSON text to a jsexpr, quickly, answering exactly what racket/json answers.
;;;
;;; Reading a resource's JSON was the largest cost of reading from a store once the typed read was
;;; lazy (a view over 17,552 MedicationRequests: ~1.3 s in racket/json's `string->jsexpr`, which reads
;;; a port byte by byte and builds every string a character at a time). `fast-string->jsexpr` scans
;;; the string itself: a string with no escape is one `substring`, a number is read from its digits,
;;; an object is built from its pairs as racket/json builds it (`make-immutable-hasheq`, so a repeated
;;; key keeps its last value). It only ever ACCEPTS — one value, whitespace (space, tab, newline,
;;; return) around it, nothing after — and on anything else it gives the text to racket/json, whose
;;; answer, or whose error, is the one returned (a text with two values, an unknown escape, a lone
;;; surrogate, other whitespace, a literal run into a name, a malformed number).
;;; tests/fast-json-test.rkt holds the two to the same answer.

(require racket/contract (only-in json string->jsexpr bytes->jsexpr read-json json-null) racket/port)

(provide
 (contract-out
  ;; fast-string->jsexpr : string -> jsexpr   racket/json's `string->jsexpr`, faster
  [fast-string->jsexpr (-> string? any/c)]
  ;; fast-bytes->jsexpr : bytes -> jsexpr   racket/json's `bytes->jsexpr` (UTF-8 text decoded, then
  ;; read as above; bytes that are not UTF-8 are racket/json's to answer)
  [fast-bytes->jsexpr (-> bytes? any/c)]
  ;; fast-read-json : input-port -> jsexpr   a port's whole text as one value (a file of FHIR JSON):
  ;; racket/json's `read-json` when the text is one value and nothing after it
  [fast-read-json (-> input-port? any/c)]))

;; refusal: the escape a scan takes when it meets what it does not read
(struct refusal ())
(define refused (refusal))

(define (fast-string->jsexpr s)
  (define v (scan s))
  (if (eq? v refused) (string->jsexpr s) v))
(define (fast-bytes->jsexpr b)
  (define s (with-handlers ([exn:fail:contract? (lambda (_) #f)]) (bytes->string/utf-8 b)))
  (define v (if s (scan s) refused))
  (if (eq? v refused) (bytes->jsexpr b) v))
(define (fast-read-json in)
  (define s (port->string in))
  (define v (scan s))
  (if (eq? v refused) (read-json (open-input-string s)) v))

;; scan : string -> jsexpr | refused   the value, when the text is one value racket/json reads plainly
(define (scan s)
  (define n (string-length s))
  (define jsnull (json-null))
  (let/ec escape
    (define (refuse) (escape refused))
    ;; skip : index -> index   past JSON whitespace
    (define (skip i)
      (if (and (< i n) (memv (string-ref s i) '(#\space #\tab #\newline #\return))) (skip (add1 i)) i))
    ;; value : index -> (values jsexpr index)
    (define (value i)
      (when (>= i n) (refuse))
      (define c (string-ref s i))
      (case c
        [(#\") (str (add1 i))]
        [(#\{) (object (add1 i))]
        [(#\[) (array (add1 i))]
        [(#\t) (literal i "true" #t)]
        [(#\f) (literal i "false" #f)]
        [(#\n) (literal i "null" jsnull)]
        [else (if (or (char<=? #\0 c #\9) (char=? c #\-)) (number i) (refuse))]))
    ;; literal : index text value -> (values value index)   the word, not run into a name
    (define (literal i word v)
      (define end (+ i (string-length word)))
      (unless (and (<= end n) (string=? (substring s i end) word)) (refuse))
      (when (and (< end n) (let ([b (string-ref s end)])
                             (or (char<=? #\a b #\z) (char<=? #\A b #\Z) (char<=? #\0 b #\9) (char=? b #\_))))
        (refuse))
      (values v end))
    ;; str : index just past the quote -> (values string index past the closing quote)
    (define (str i)
      (let loop ([j i])
        (when (>= j n) (refuse))
        (case (string-ref s j)
          [(#\") (values (substring s i j) (add1 j))]
          [(#\\) (escaped i j)]
          [else (loop (add1 j))])))
    ;; escaped : start index-of-first-backslash -> (values string index)   a string with escapes
    (define (escaped start j0)
      (define out (open-output-string))
      (write-string s out start j0)
      (let loop ([j j0])
        (when (>= j n) (refuse))
        (define c (string-ref s j))
        (cond
          [(char=? c #\") (values (get-output-string out) (add1 j))]
          [(char=? c #\\)
           (when (>= (add1 j) n) (refuse))
           (define e (string-ref s (add1 j)))
           (case e
             [(#\b) (write-char #\backspace out) (loop (+ j 2))]
             [(#\n) (write-char #\newline out) (loop (+ j 2))]
             [(#\r) (write-char #\return out) (loop (+ j 2))]
             [(#\f) (write-char #\page out) (loop (+ j 2))]
             [(#\t) (write-char #\tab out) (loop (+ j 2))]
             [(#\\ #\" #\/) (write-char e out) (loop (+ j 2))]
             [(#\u)
              (define u (hex4 (+ j 2)))
              (cond
                [(<= #xD800 u #xDBFF)                     ; a pair's first half: its second follows
                 (unless (and (< (+ j 7) n) (char=? (string-ref s (+ j 6)) #\\) (char=? (string-ref s (+ j 7)) #\u))
                   (refuse))
                 (define u2 (hex4 (+ j 8)))
                 (unless (<= #xDC00 u2 #xDFFF) (refuse))
                 (write-char (integer->char (+ (arithmetic-shift (- u #xD800) 10) (- u2 #xDC00) #x10000)) out)
                 (loop (+ j 12))]
                [(<= #xDC00 u #xDFFF) (refuse)]
                [else (write-char (integer->char u) out) (loop (+ j 6))])]
             [else (refuse)])]
          [else (write-char c out) (loop (add1 j))])))
    ;; hex4 : index -> integer   four hex digits
    (define (hex4 i)
      (unless (<= (+ i 4) n) (refuse))
      (for/fold ([v 0]) ([k (in-range i (+ i 4))])
        (define c (string-ref s k))
        (+ (* v 16)
           (cond [(char<=? #\0 c #\9) (- (char->integer c) 48)]
                 [(char<=? #\a c #\f) (- (char->integer c) 87)]
                 [(char<=? #\A c #\F) (- (char->integer c) 55)]
                 [else (refuse)]))))
    ;; digits : index -> (values natural count index)   a run of decimal digits
    (define (digits i)
      (let loop ([j i] [v 0])
        (if (and (< j n) (char<=? #\0 (string-ref s j) #\9))
            (loop (add1 j) (+ (* v 10) (- (char->integer (string-ref s j)) 48)))
            (values v (- j i) j))))
    ;; number : index -> (values number index)   as racket/json reads it: an integer exact; with a
    ;; fraction or an exponent, n × 10^exp made inexact
    (define (number i)
      (define-values (sgn i1) (if (char=? (string-ref s i) #\-) (values -1 (add1 i)) (values 1 i)))
      (when (>= i1 n) (refuse))
      (define lead (string-ref s i1))
      (unless (char<=? #\0 lead #\9) (refuse))
      (define-values (int int-count i2)
        (if (char=? lead #\0) (values 0 1 (add1 i1)) (digits i1)))
      (define-values (mant exp i3)                                  ; the fraction's digits joined to the integer's
        (cond
          [(and (< i2 n) (char=? (string-ref s i2) #\.))
           (define-values (f fc j) (digits (add1 i2)))
           (when (zero? fc) (refuse))
           (values (+ (* int (expt 10 fc)) f) (- fc) j)]
          [else (values int 0 i2)]))
      (cond
        [(and (< i3 n) (memv (string-ref s i3) '(#\e #\E)))
         (define-values (esgn i4)
           (cond [(and (< (add1 i3) n) (char=? (string-ref s (add1 i3)) #\+)) (values 1 (+ i3 2))]
                 [(and (< (add1 i3) n) (char=? (string-ref s (add1 i3)) #\-)) (values -1 (+ i3 2))]
                 [else (values 1 (add1 i3))]))
         (define-values (e ec i5) (digits i4))
         (when (zero? ec) (refuse))
         (values (safe-exponential->inexact (* sgn mant) (+ exp (* esgn e))) i5)]
        [(< exp 0) (values (exact->inexact (* sgn mant (expt 10 exp))) i3)]
        [else (values (* sgn mant) i3)]))
    ;; array : index past `[` -> (values list index)
    (define (array i)
      (define j (skip i))
      (cond
        [(and (< j n) (char=? (string-ref s j) #\])) (values '() (add1 j))]
        [else
         (let loop ([j j] [acc '()])
           (define-values (v k) (value j))
           (define k2 (skip k))
           (when (>= k2 n) (refuse))
           (case (string-ref s k2)
             [(#\,) (loop (skip (add1 k2)) (cons v acc))]
             [(#\]) (values (reverse (cons v acc)) (add1 k2))]
             [else (refuse)]))]))
    ;; object : index past `{` -> (values hasheq index)
    (define (object i)
      (define j (skip i))
      (cond
        [(and (< j n) (char=? (string-ref s j) #\})) (values (make-immutable-hasheq '()) (add1 j))]
        [else
         (let loop ([j j] [acc '()])
           (unless (and (< j n) (char=? (string-ref s j) #\")) (refuse))
           (define-values (key k) (str (add1 j)))
           (define k2 (skip k))
           (unless (and (< k2 n) (char=? (string-ref s k2) #\:)) (refuse))
           (define-values (v k3) (value (skip (add1 k2))))
           (define k4 (skip k3))
           (when (>= k4 n) (refuse))
           (define acc2 (cons (cons (string->symbol key) v) acc))
           (case (string-ref s k4)
             [(#\,) (loop (skip (add1 k4)) acc2)]
             [(#\}) (values (make-immutable-hasheq (reverse acc2)) (add1 k4))]
             [else (refuse)]))]))
    (define-values (v end) (value (skip 0)))
    (if (= (skip end) n) v refused)))

;; safe-exponential->inexact : integer integer -> flonum   n × 10^exp, as racket/json computes it
;; (without passing large arguments to expt)
(define (safe-exponential->inexact n exp)
  (define result-exp (if (= n 0) exp (+ (log (abs n) 10) exp)))
  (cond
    [(< result-exp -400) (if (>= n 0) 0.0 -0.0)]
    [(> result-exp 400) (cond [(= n 0) 0.0] [(> n 0) +inf.0] [else -inf.0])]
    [else (exact->inexact (* n (expt 10 exp)))]))

(module+ scan (provide scan refused))   ; for tests/fast-json-test.rkt: what the scan reads itself

(module+ test
  (require rackunit json)
  (define (same s)
    (check-equal? (fast-string->jsexpr s) (string->jsexpr s) s)
    (check-equal? (fast-bytes->jsexpr (string->bytes/utf-8 s)) (bytes->jsexpr (string->bytes/utf-8 s)) s))
  (for-each same '("1" "-0" "0.1e2" "1.50" "1e400" "-1e-400" "12345678901234567890" "1.25E+3" "3e-2"
                   "\"a\"" "\"a\\nb\\u00e9\\ud83d\\ude00\\/\"" "\"é😀\"" "true" "false" "null" "[]" "{}"
                   " [1, 2 ,{\"a\" : [true,null]} ] " "{\"a\":1,\"a\":2}" "\"a\nb\""))
  ;; what it does not read is racket/json's to answer, value or error
  (for-each same '("1 2" "  " "[1] x"))
  (for ([bad '("truex" "nul" "[1," "{\"a\" 1}" "\"\\ud800\"" "01" "1." "\"\\x\"" "[1 2]")])
    (check-equal? (with-handlers ([exn:fail? exn-message]) (fast-string->jsexpr bad))
                  (with-handlers ([exn:fail? exn-message]) (string->jsexpr bad))
                  bad)))
