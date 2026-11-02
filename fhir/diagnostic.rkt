#lang racket/base

;;; diagnostic.rkt — machine-readable feedback for every language in the family.
;;;
;;; A Diagnostic is (diagnostic lang phase severity message loc):
;;;   lang     : 'fsh | 'cql | 'fhirpath | 'vcl | 'fml
;;;   phase    : 'lex | 'parse | 'compile | 'run
;;;   severity : 'error | 'warning
;;;   message  : a sentence for a person ("unexpected `used`")
;;;   loc      : (loc source line column position span) | #f — line and column are 1-based (column as
;;;              editors count it), position the 1-based character offset, span its length
;;; Three renderings of the same value:
;;;   diagnostic->string               file.fsh:12:5: fsh parse error: unexpected `used`
;;;                                    (with #:text, the source line and a caret under the column)
;;;   diagnostic->jsexpr               {"lang","phase","severity","message","source","line","column",…}
;;;   diagnostics->operation-outcome   a FHIR OperationOutcome; positions in the standard
;;;                                    operationoutcome-issue-line / -col / -source extensions
;;; `exn:fail:diagnostic` carries one (a subtype of exn:fail, so existing handlers still catch it,
;;; with prop:exn:srclocs so DrRacket and errortrace point at the source). `exn->diagnostic` turns
;;; a parser's exception — a brag parse error, a lexer's no-match, anything else — into one.

(require racket/contract racket/match racket/string racket/list (only-in json write-json))

(provide
 (struct-out loc) (struct-out diagnostic) (struct-out exn:fail:diagnostic)
 (contract-out
  [raise-diagnostic             (-> diagnostic? any)]
  [exn->diagnostic              (->* (exn? symbol?) (#:phase symbol? #:source any/c #:line-offset exact-integer?
                                                   #:last-position (or/c exact-integer? #f) #:unit string?
                                                   #:ran-out? (-> any/c))
                                     diagnostic?)]
  [diagnostic->string           (->* (diagnostic?) (#:text (or/c string? #f)) string?)]
  [diagnostic->jsexpr           (-> diagnostic? hash?)]
  [diagnostics->operation-outcome (-> (listof diagnostic?) hash?)]
  ;; an error payload that is not itself a diagnostic (VCL's invalid-encoding) can carry one
  [attach-diagnostic!           (-> any/c diagnostic? any)]
  ;; an AST node (a CQL define, say) can carry the location it was parsed from
  [attach-loc!                  (-> any/c loc? any)]
  [attached-loc                 (-> any/c (or/c loc? #f))]
  [attached-diagnostic          (-> any/c (or/c diagnostic? #f))]
  [tokens->last-position        (-> list? (-> any/c (or/c exact-integer? #f)) (or/c exact-integer? #f))]
  [error-position               (-> exn? (or/c exact-integer? #f))]
  ;; the CLIs' reporting: text (with source excerpts) on stderr, or JSON / an OperationOutcome on stdout
  [emit-diagnostics             (->* ((listof diagnostic?)) (#:format (or/c 'text 'json 'outcome)
                                                            #:text-of (-> any/c (or/c string? #f)))
                                     void?)]
  [format-flag                  (-> (listof string?) (values (or/c 'text 'json 'outcome) (listof string?)))]))

;; emit-diagnostics : diagnostics -> void
;;   'text    file:line:col: lang phase severity: message + source line + caret, on stderr
;;   'json    {"diagnostics": [...]} on stdout
;;   'outcome a FHIR OperationOutcome on stdout
(define (emit-diagnostics ds #:format [fmt 'text] #:text-of [text-of (lambda (_) #f)])
  (case fmt
    [(text) (for ([d (in-list ds)])
              (define l (diagnostic-loc d))
              (eprintf "~a\n" (diagnostic->string d #:text (and l (text-of (loc-source l))))))]
    [(json) (write-json (hasheq 'diagnostics (map diagnostic->jsexpr ds))) (newline)]
    [(outcome) (write-json (diagnostics->operation-outcome ds)) (newline)]))

;; format-flag : args -> (values format remaining-args)   `--format text|json|outcome` anywhere
(define (format-flag args)
  (let loop ([as args] [fmt 'text] [acc '()])
    (cond [(null? as) (values fmt (reverse acc))]
          [(and (equal? (car as) "--format") (pair? (cdr as)) (member (cadr as) '("text" "json" "outcome")))
           (loop (cddr as) (string->symbol (cadr as)) acc)]
          [else (loop (cdr as) fmt (cons (car as) acc))])))

(define attached (make-weak-hasheq))
(define locs (make-weak-hasheq))
(define (attach-loc! node l) (hash-set! locs node l) node)
(define (attached-loc node) (hash-ref locs node #f))
(define (attach-diagnostic! payload d) (hash-set! attached payload d) payload)
(define (attached-diagnostic payload)
  (cond [(diagnostic? payload) payload]
        [else (hash-ref attached payload #f)]))
;; tokens->last-position : tokens position-of -> the last token's position (for "ends after")
;; error-position : exn -> position|#f   where a parser exception points (for ran-out probes)
(define (error-position e)
  (define ls (if (exn:srclocs? e) ((exn:srclocs-accessor e) e) '()))
  (cond [(and (pair? ls) (srcloc-position (car ls)))]
        [(regexp-match #px"offset=([0-9]+)\\]" (exn-message e)) => (lambda (m) (string->number (cadr m)))]
        [else #f]))
(define (tokens->last-position toks position-of)
  (for/last ([t (in-list toks)] #:when (position-of t)) (position-of t)))

(struct loc (source line column position span) #:prefab)
(struct diagnostic (lang phase severity message loc) #:prefab)
(struct exn:fail:diagnostic exn:fail (diagnostic)
  #:property prop:exn:srclocs
  (lambda (e)
    (define l (diagnostic-loc (exn:fail:diagnostic-diagnostic e)))
    (if (and l (loc-line l))
        (list (srcloc (loc-source l) (loc-line l) (and (loc-column l) (sub1 (loc-column l))) (loc-position l) (loc-span l)))
        '())))

(define (raise-diagnostic d)
  (raise (exn:fail:diagnostic (diagnostic->string d) (current-continuation-marks) d)))

;; ---- from a parser's exception ----------------------------------------------------------------
;; brag:   "Encountered parsing error near X (token 'T) while parsing 'unknown [line=L, column=C, offset=O]"
;; lexers: "lexer: No match found in input starting with: …"
;; exn->diagnostic : exn lang -> diagnostic
;; #:last-position: the position of the last token of what was being parsed. brag reports running out
;; of input as an error AT that (valid) token — and a genuinely bad last token the same way — so
;; #:ran-out? (a probe the parser supplies: re-parse with a sentinel appended; did the error move to
;; it?) decides between "the <unit> ends after `X`" and "unexpected `X`".
(define (exn->diagnostic e lang #:phase [phase #f] #:source [source #f] #:line-offset [dline 0]
                         #:last-position [last-pos #f] #:unit [unit "input"] #:ran-out? [ran-out? (lambda () #t)])
  (cond
    ;; already a diagnostic (raised by a lexer, say): fill in the source it could not know
    [(exn:fail:diagnostic? e)
     (define d (exn:fail:diagnostic-diagnostic e))
     (define l (diagnostic-loc d))
     (if (and source l (not (loc-source l)))
         (struct-copy diagnostic d [loc (struct-copy loc l [source (if (path? source) (path->string source) source)])])
         d)]
    [else
     (define msg (exn-message e))
     (define sl (let ([ls (if (exn:srclocs? e) ((exn:srclocs-accessor e) e) '())])
                  (and (pair? ls) (car ls))))
     (define-values (line col pos span)
       (cond
         [(and sl (srcloc-line sl)) (values (srcloc-line sl) (srcloc-column sl) (srcloc-position sl) (srcloc-span sl))]
         [(regexp-match #px"\\[line=([0-9]+), column=([0-9]+), offset=([0-9]+)\\]" msg)
          => (lambda (m) (values (string->number (cadr m)) (string->number (caddr m)) (add1 (string->number (cadddr m))) #f))]
         [else (values #f #f #f #f)]))
     (define-values (ph text0) (friendly msg))
     (define text (match (regexp-match #px"^unexpected (?:[a-z -]+ )?`(.*)`$" text0)
                    [(list _ tok) #:when (and last-pos pos (= pos last-pos) (ran-out?)) (format "the ~a ends after `~a`" unit tok)]
                    [_ text0]))
     (diagnostic lang (or phase ph) 'error text
                 (and (or line source)
                      (loc (and source (if (path? source) (path->string source) source))
                           (and line (+ line dline)) (and col (add1 col)) pos span)))]))

;; friendly : message -> (values phase sentence)
(define (friendly msg)
  (match msg
    [(pregexp #px"^Encountered parsing error near (.*?) \\(token '(.*?)\\) while parsing" (list _ near type0))
     (define type (regexp-replace #px"^\\|(.*)\\|$" type0 "\\1"))     ; '|(| -> (  (a symbol's bars)
     (values 'parse
             (cond [(or (member near '("#<eof>" "#<void>" "eof")) (member type '("EOF" "#<eof>")))
                    "unexpected end of input"]
                   [(equal? (strip-quotes near) (strip-quotes type)) (format "unexpected `~a`" (strip-quotes near))]
                   [else (format "unexpected ~a `~a`" (kind-words type) (strip-quotes near))]))]
    [(pregexp #px"^Encountered unexpected token of type (.*?) \\(value (.*?)\\) while parsing" (list _ type near))
     (values 'parse (if (regexp-match? #rx"(?i:eof)" type) "unexpected end of input"
                        (format "unexpected ~a `~a`" (kind-words (strip-quotes type)) (strip-quotes near))))]
    [(pregexp #px"No match found in input starting with: (.*)$" (list _ rest))
     (values 'lex (format "unrecognized text `~a`" (let ([r (car (string-split (string-append rest " ") "\n"))])
                                                     (string-trim (substring r 0 (min 30 (string-length r)))))))]
    [_ (values 'parse (regexp-replace #px"^[a-z-]+: " msg ""))]))
;; a token type as words: CARET_SEQUENCE -> "caret sequence", IDENTIFIER -> "identifier"
(define (kind-words t) (string-replace (string-downcase t) "_" " "))
(define (strip-quotes s)
  (let* ([s (regexp-replace #px"^'" s "")]
         [s (if (regexp-match? #px"^\".*\"$" s) (substring s 1 (sub1 (string-length s))) s)])
    s))

;; ---- renderings ---------------------------------------------------------------------------
(define (diagnostic->string d #:text [text #f])
  (define l (diagnostic-loc d))
  (define where
    (cond [(and l (loc-line l))
           (format "~a:~a:~a: " (or (loc-source l) "<input>") (loc-line l) (or (loc-column l) 1))]
          [(and l (loc-source l)) (format "~a: " (loc-source l))]
          [else ""]))
  (define head (format "~a~a ~a ~a: ~a" where (diagnostic-lang d) (diagnostic-phase d) (diagnostic-severity d)
                       (diagnostic-message d)))
  (define excerpt
    (and text l (loc-line l)
         (let ([lines (regexp-split #rx"\r?\n" text)])
           (and (<= 1 (loc-line l) (length lines))
                (let* ([src (list-ref lines (sub1 (loc-line l)))]
                       [n (number->string (loc-line l))]
                       [col (max 1 (or (loc-column l) 1))]
                       [width (max 1 (min (or (loc-span l) 1) (max 1 (- (string-length src) (sub1 col)))))])
                  (format "\n ~a | ~a\n ~a | ~a~a" n src (make-string (string-length n) #\space)
                          (make-string (sub1 col) #\space) (make-string width #\^)))))))
  (string-append head (or excerpt "")))

(define (diagnostic->jsexpr d)
  (define l (diagnostic-loc d))
  (for/fold ([h (hasheq 'lang (symbol->string (diagnostic-lang d)) 'phase (symbol->string (diagnostic-phase d))
                        'severity (symbol->string (diagnostic-severity d)) 'message (diagnostic-message d))])
            ([k '(source line column position span)]
             [v (if l (list (loc-source l) (loc-line l) (loc-column l) (loc-position l) (loc-span l)) '(#f #f #f #f #f))]
             #:when v)
    (hash-set h k v)))

(define ext "http://hl7.org/fhir/StructureDefinition/operationoutcome-issue-")
(define (diagnostics->operation-outcome ds)
  (hasheq 'resourceType "OperationOutcome"
          'issue
          (for/list ([d (in-list ds)])
            (define l (diagnostic-loc d))
            (define exts (append (if (and l (loc-line l)) (list (hasheq 'url (string-append ext "line") 'valueInteger (loc-line l))) '())
                                 (if (and l (loc-column l)) (list (hasheq 'url (string-append ext "col") 'valueInteger (loc-column l))) '())
                                 (list (hasheq 'url (string-append ext "source")
                                               'valueString (format "~a ~a" (diagnostic-lang d) (diagnostic-phase d))))))
            (define base (hasheq 'extension exts
                                 'severity (symbol->string (diagnostic-severity d))
                                 'code (if (memq (diagnostic-phase d) '(lex parse)) "invalid" "processing")
                                 'diagnostics (diagnostic-message d)))
            (if (and l (loc-line l))
                (hash-set base 'location (list (format "~a~a, Col ~a" (if (loc-source l) (format "~a: " (loc-source l)) "")
                                                       (format "Line ~a" (loc-line l)) (or (loc-column l) 1))))
                base))))

(module+ test
  (require rackunit)
  (define e (with-handlers ([exn:fail? values])
              (error "Encountered parsing error near \"used\" (token 'SEQUENCE) while parsing 'unknown [line=3, column=8, offset=41]")))
  (define d (exn->diagnostic e 'fsh #:source "x.fsh"))
  (check-equal? (diagnostic-message d) "unexpected sequence `used`")
  (check-equal? (loc-line (diagnostic-loc d)) 3)
  (check-equal? (loc-column (diagnostic-loc d)) 9)                      ; 1-based
  (check-equal? (diagnostic->string d) "x.fsh:3:9: fsh parse error: unexpected sequence `used`")
  (check-equal? (diagnostic->string d #:text "a\nb\n* foo ^short used\n")
                "x.fsh:3:9: fsh parse error: unexpected sequence `used`\n 3 | * foo ^short used\n   |         ^")
  (check-equal? (hash-ref (diagnostic->jsexpr d) 'line) 3)
  (define oo (diagnostics->operation-outcome (list d)))
  (check-equal? (hash-ref (car (hash-ref oo 'issue)) 'code) "invalid")
  (check-equal? (hash-ref (car (hash-ref (car (hash-ref oo 'issue)) 'extension)) 'valueInteger) 3)
  (check-equal? (diagnostic-message (exn->diagnostic (with-handlers ([exn:fail? values]) (error "Encountered parsing error near \"+\" (token '+) while parsing 'unknown [line=1, column=2, offset=2]")) 'cql))
                "unexpected `+`")
  (check-exn exn:fail:diagnostic? (lambda () (raise-diagnostic d)))
  (check-exn exn:fail? (lambda () (raise-diagnostic d))))
