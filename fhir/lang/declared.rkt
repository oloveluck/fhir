#lang racket/base

;;; lang/declared.rkt — editor support for a language whose declarations a line regexp finds (CQL,
;;; FML): the outline, the name under the cursor, completion of declared names and keywords, and the
;;; files beside a document. A language's support module builds on these with its own table.
;;;
;;; A Declarations is (listof (list kind regexp)): the regexp's first (or second) group is the name,
;;; an optional third group the id (`include X called A` -> name A, id X).

(require racket/contract racket/string racket/list racket/file
         "support.rkt")

(provide
 (contract-out
  [declared-entities    (-> (listof (list/c string? regexp?)) string? path-string? (listof entity?))]
  ;; the word under the cursor; with quoted? a "quoted name" is the text inside its quotes
  [name-at              (->* (string? pair?) (#:quoted? boolean?) (or/c string? #f))]
  ;; declared names and keywords starting with what is typed; inside quotes, names only
  [prefix-completions   (-> (listof entity?) (listof string?) (-> string? exact-integer?) string? pair? (listof hash?))]
  ;; files-beside : path extensions -> paths   the files with those extensions in the document's directory
  [files-beside         (-> path-string? (listof string?) (listof path?))]))

(define (declared-entities table text file)
  (define f (if (path? file) (path->string file) file))
  (for*/list ([(l i) (in-parallel (in-list (regexp-split #rx"\r?\n" text)) (in-naturals))]
              [d (in-list table)]
              [m (in-value (regexp-match (cadr d) l))] #:when m
              [name (in-value (for/or ([g (in-list (take (cdr m) (min 2 (length (cdr m)))))]) g))] #:when name)
    (entity (car d) name (and (>= (length m) 4) (cadddr m)) f i)))

(define (name-at text pos #:quoted? [quoted? #f])
  (define line (line-of text (car pos)))
  (define col (and line (min (cdr pos) (string-length line))))
  (or (and line quoted?
           (for/or ([m (in-list (regexp-match-positions* #px"\"[^\"]+\"" line))])
             (and (<= (car m) col (cdr m)) (substring line (add1 (car m)) (sub1 (cdr m))))))
      (word-at text pos)))

;; typed-prefix : text position -> (values string boolean)   the word characters just before the
;; cursor, and whether they sit inside an open quote (a quoted name, without its opening quote)
(define (typed-prefix text pos)
  (define line (or (line-of text (car pos)) ""))
  (define before (substring line 0 (min (cdr pos) (string-length line))))
  (cond [(regexp-match #px"\"([^\"]*)$" before) => (lambda (m) (values (cadr m) #t))]
        [(regexp-match #px"([A-Za-z_][A-Za-z0-9_]*)$" before) => (lambda (m) (values (cadr m) #f))]
        [else (values "" #f)]))

(define (prefix-completions es keywords item-kind text pos)
  (define-values (prefix quoted?) (typed-prefix text pos))
  (define (fits? label) (or (string=? prefix "")
                            (and (>= (string-length label) (string-length prefix))
                                 (string=? (substring label 0 (string-length prefix)) prefix))))
  (append (for/list ([e (in-list es)] #:when (fits? (entity-name e)))
            (hasheq 'label (entity-name e) 'kind (item-kind (entity-kind e)) 'detail (entity-kind e)))
          (if quoted? '() (for/list ([k (in-list keywords)] #:when (fits? k)) (hasheq 'label k 'kind 14)))))

(define (files-beside path exts)
  (define-values (dir _n _d) (split-path (if (path? path) path (string->path path))))
  (if (and (path? dir) (directory-exists? dir))
      (sort (for/list ([f (in-list (directory-list dir #:build? #t))]
                       #:when (and (file-exists? f) (member (let ([e (regexp-match #rx"[.]([^.]+)$" (path->string f))]) (and e (cadr e))) exts)))
              f)
            string<? #:key path->string)
      '()))

(module+ test
  (require rackunit racket/path)
  (define table (list (list "library" #px"^library\\s+(\\S+)")
                      (list "include" #px"^include\\s+(\\S+)(?:\\s+version\\s+'[^']*')?\\s+called\\s+(\\S+)")
                      (list "define"  #px"^define\\s+(?:\"([^\"]+)\"|(\\w+))")))
  ;; the include regexp: group 1 the library, group 2 the alias — the entity is the alias, id the library
  (define inc-table (list (list "include" #px"^include\\s+(?:(\\S+))(?:\\s+version\\s+'[^']*')?\\s+called\\s+(\\S+)")))
  (define text "library L version '1'\ninclude Common version '1' called C\ndefine \"A B\": 1\ndefine X: \"A B\"\n")
  (define es (declared-entities table text "/l.cql"))
  (check-equal? (map entity-name es) '("L" "Common" "A B" "X"))
  (check-equal? (entity-line (find-entity es "A B")) 2)
  (check-equal? (name-at text (cons 3 12) #:quoted? #t) "A B")
  (check-equal? (name-at text (cons 0 9)) "L")
  (check-equal? (map (lambda (i) (hash-ref i 'label)) (prefix-completions es '("define" "default") (lambda (k) 3) "de" (cons 0 2)))
                '("define" "default"))
  (check-equal? (map (lambda (i) (hash-ref i 'label)) (prefix-completions es '("and") (lambda (k) 3) "define Y: \"A" (cons 0 12)))
                '("A B"))
  (define dir (make-temporary-file "declared-~a" 'directory))
  (with-output-to-file (build-path dir "a.cql") (lambda () (display "library a\n")))
  (with-output-to-file (build-path dir "b.txt") (lambda () (display "x")))
  (check-equal? (map (lambda (p) (path->string (file-name-from-path p))) (files-beside (build-path dir "x.cql") '("cql"))) '("a.cql"))
  (delete-directory/files dir))
