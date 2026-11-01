#lang racket/base

;;; read-json.rkt — a precision-preserving JSON reader.
;;;
;;; racket/json's `read-json` coerces every number to a Racket number, so `1.50` and `1e2` lose their
;;; lexical form before FHIR's string-backed `decimal` ever sees them. This reader is identical to a
;;; normal JSON reader EXCEPT that each number is returned as a `jnum` carrying its verbatim lexeme.
;;; `serialize/from-json.rkt` reads the lexeme for `decimal` fields (exact precision) and the numeric
;;; value elsewhere; `strip-jnum` collapses a tree back to a plain jsexpr for raw passthrough.
;;;
;;; Output shape matches racket/json: objects -> hasheq with symbol keys, arrays -> lists, strings ->
;;; strings, true/false -> booleans, null -> 'null, numbers -> (jnum lexeme).

(require racket/contract
         (only-in racket/string string-join))

(provide
 (struct-out jnum)
 (contract-out
  [read-fhir-json            (-> input-port? any/c)]
  ;; like read-fhir-json, but also returns the dotted paths of any DUPLICATE object keys the reader
  ;; collapsed (last-wins, matching racket/json). Duplicate keys are invalid FHIR JSON; the validator
  ;; consumes this second value. The plain jsexpr is identical to read-fhir-json's.
  [read-fhir-json/duplicates (-> input-port? (values any/c (listof string?)))]
  [string->fhir-jsexpr       (-> string? any/c)]
  [jnum-value                (-> jnum? real?)]     ; the numeric value of a jnum's lexeme
  [strip-jnum                (-> any/c any/c)]))    ; jnum -> number, recursively; -> plain jsexpr

;; a JSON number kept as its verbatim lexeme (e.g. "1.50", "-3", "1e2")
(struct jnum (lexeme) #:transparent)

(define (jnum-value n) (string->number (jnum-lexeme n)))

(define (string->fhir-jsexpr s) (read-fhir-json (open-input-string s)))

;; strip-jnum : collapse a jnum-bearing tree into a standard jsexpr (numbers become Racket numbers).
(define (strip-jnum x)
  (cond
    [(jnum? x) (string->number (jnum-lexeme x))]
    [(list? x) (map strip-jnum x)]
    [(hash? x) (for/hasheq ([(k v) (in-hash x)]) (values k (strip-jnum v)))]
    [else x]))

;; ---- the reader ------------------------------------------------------------------------------
;; When set to a box, the reader records the dotted path of every duplicate object key it collapses.
;; #f (the default) means no tracking — the hot path (roundtrip corpus, from-json) stays untouched.
(define current-dups (make-parameter #f))
(define current-path (make-parameter '()))    ; reversed key path to the enclosing object

(define (read-fhir-json in)
  (skip-ws in)
  (define v (read-value in))
  v)

(define (read-fhir-json/duplicates in)
  (define b (box '()))
  (define v (parameterize ([current-dups b] [current-path '()]) (read-fhir-json in)))
  (values v (reverse (unbox b))))

(define (read-value in)
  (skip-ws in)
  (define c (peek-char in))
  (cond
    [(eof-object? c) (err in "unexpected end of input")]
    [(char=? c #\{) (read-object in)]
    [(char=? c #\[) (read-array in)]
    [(char=? c #\") (read-string* in)]
    [(or (char=? c #\-) (char-numeric? c)) (read-number in)]
    [(char=? c #\t) (read-lit in "true" #t)]
    [(char=? c #\f) (read-lit in "false" #f)]
    [(char=? c #\n) (read-lit in "null" 'null)]
    [else (err in (format "unexpected character ~a" c))]))

(define (read-object in)
  (read-char in)                        ; {
  (skip-ws in)
  (cond
    [(eqv? (peek-char in) #\}) (read-char in) (hasheq)]
    [else
     (let loop ([h (hasheq)])
       (skip-ws in)
       (define key (string->symbol (read-string* in)))
       (skip-ws in)
       (expect in #\:)
       (define val (parameterize ([current-path (cons key (current-path))]) (read-value in)))
       (when (and (current-dups) (hash-has-key? h key))
         (define dotted (string-join (map symbol->string (reverse (cons key (current-path)))) "."))
         (set-box! (current-dups) (cons dotted (unbox (current-dups)))))
       (define h* (hash-set h key val))
       (skip-ws in)
       (define c (read-char in))
       (cond
         [(eqv? c #\,) (loop h*)]
         [(eqv? c #\}) h*]
         [else (err in "expected , or } in object")]))]))

(define (read-array in)
  (read-char in)                        ; [
  (skip-ws in)
  (cond
    [(eqv? (peek-char in) #\]) (read-char in) '()]
    [else
     (let loop ([acc '()])
       (define val (read-value in))
       (skip-ws in)
       (define c (read-char in))
       (cond
         [(eqv? c #\,) (loop (cons val acc))]
         [(eqv? c #\]) (reverse (cons val acc))]
         [else (err in "expected , or ] in array")]))]))

(define (read-string* in)
  (expect in #\")
  (define out (open-output-string))
  (let loop ()
    (define c (read-char in))
    (cond
      [(eof-object? c) (err in "unterminated string")]
      [(char=? c #\") (get-output-string out)]
      [(char=? c #\\)
       (define e (read-char in))
       (case e
         [(#\") (write-char #\" out)] [(#\\) (write-char #\\ out)] [(#\/) (write-char #\/ out)]
         [(#\b) (write-char #\backspace out)] [(#\f) (write-char #\page out)]
         [(#\n) (write-char #\newline out)] [(#\r) (write-char #\return out)]
         [(#\t) (write-char #\tab out)]
         [(#\u) (write-char (read-unicode in) out)]
         [else (err in (format "bad string escape \\~a" e))])
       (loop)]
      [else (write-char c out) (loop)])))

(define (read-unicode in)
  (define hex (list->string (for/list ([_ (in-range 4)]) (read-char in))))
  (define n (string->number hex 16))
  (unless n (err in "bad \\u escape"))
  (integer->char n))

;; read a JSON number, returning (jnum lexeme) with the verbatim text.
(define (read-number in)
  (define out (open-output-string))
  (define (take!) (write-char (read-char in) out))
  (define (take-while! pred)
    (let loop () (define c (peek-char in))
      (when (and (char? c) (pred c)) (take!) (loop))))
  (when (eqv? (peek-char in) #\-) (take!))
  (take-while! char-numeric?)
  (when (eqv? (peek-char in) #\.) (take!) (take-while! char-numeric?))
  (when (memv (peek-char in) '(#\e #\E))
    (take!)
    (when (memv (peek-char in) '(#\+ #\-)) (take!))
    (take-while! char-numeric?))
  (define lex (get-output-string out))
  (unless (string->number lex) (err in (format "bad number ~s" lex)))
  (jnum lex))

(define (read-lit in word val)
  (for ([ch (in-string word)])
    (unless (eqv? (read-char in) ch) (err in (format "expected ~a" word))))
  val)

(define (expect in ch)
  (define c (read-char in))
  (unless (eqv? c ch) (err in (format "expected ~a, got ~a" ch c))))

(define (skip-ws in)
  (let loop ()
    (define c (peek-char in))
    (when (and (char? c) (char-whitespace? c)) (read-char in) (loop))))

(define (err in msg) (error 'read-fhir-json msg))

(module+ test
  (require rackunit)
  ;; numbers become jnum with their verbatim lexeme
  (check-equal? (string->fhir-jsexpr "1.50") (jnum "1.50"))
  (check-equal? (jnum-value (string->fhir-jsexpr "1.50")) 1.5)
  (check-equal? (strip-jnum (string->fhir-jsexpr "1.50")) 1.5)
  ;; structure matches racket/json (symbol keys, lists, 'null)
  (check-equal? (strip-jnum (string->fhir-jsexpr "{\"a\":[1,true,null],\"b\":\"x\"}"))
                (hasheq 'a (list 1 #t 'null) 'b "x"))
  ;; the decimal lexeme is preserved verbatim inside a structure
  (check-equal? (hash-ref (string->fhir-jsexpr "{\"value\":1.50}") 'value) (jnum "1.50"))
  ;; escapes incl. \u
  (check-equal? (string->fhir-jsexpr "\"a\\u00e9b\"") "aéb")
  ;; read-fhir-json/duplicates: plain read is unaffected; duplicates are reported by dotted path
  (let-values ([(v dups) (read-fhir-json/duplicates (open-input-string "{\"a\":1,\"a\":2,\"b\":3}"))])
    (check-equal? (strip-jnum v) (hasheq 'a 2 'b 3))     ; last-wins, matches racket/json
    (check-equal? dups '("a")))
  (let-values ([(v dups) (read-fhir-json/duplicates (open-input-string "{\"x\":{\"y\":1,\"y\":2}}"))])
    (check-equal? dups '("x.y")))
  (let-values ([(v dups) (read-fhir-json/duplicates (open-input-string "{\"a\":1,\"b\":2}"))])
    (check-equal? dups '())))
