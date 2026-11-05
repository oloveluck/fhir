#lang racket/base

;;; lang-symbols.rkt — declarations in a CQL or FML document, read from the text (as fsh-symbols.rkt
;;; reads FSH): the outline an editor shows and what a name under the cursor refers to.
;;;
;;; The declarations, per language, as a table of (kind regexp): the regexp's first group is the name.
;;;   cql  library, include (its alias), using, valueset, codesystem, code, concept, parameter, context, define
;;;   fml  map (its name), uses (its alias), imports, conceptmap, group
;;; An Entity is fsh-symbols' (entity kind name id file line); id is #f here.

(require racket/contract racket/string racket/list racket/match
         (only-in "fsh-symbols.rkt" entity entity? entity-name entity-kind entities-of word-at))

(provide
 (contract-out
  [declarations     (hash/c string? (listof (list/c string? regexp?)))]
  [language-entities (-> string? string? path-string? (listof entity?))]
  [name-at          (-> string? string? pair? (or/c string? #f))]
  ;; the completion items for a CQL or FML document at a position: its declarations and the
  ;; language's keywords, those starting with the word being typed
  [language-completions (-> string? string? pair? (listof hash?))]))

(define declarations
  (hash "cql"
        (list (list "library"    #px"^library\\s+(\\S+)")
              (list "include"    #px"^include\\s+\\S+(?:\\s+version\\s+'[^']*')?\\s+called\\s+(\\S+)")
              (list "include"    #px"^include\\s+(\\S+)\\s*$")
              (list "using"      #px"^using\\s+(\\S+)")
              (list "valueset"   #px"^(?:public\\s+|private\\s+)?valueset\\s+\"([^\"]+)\"")
              (list "codesystem" #px"^(?:public\\s+|private\\s+)?codesystem\\s+\"([^\"]+)\"")
              (list "code"       #px"^(?:public\\s+|private\\s+)?code\\s+\"([^\"]+)\"")
              (list "concept"    #px"^(?:public\\s+|private\\s+)?concept\\s+\"([^\"]+)\"")
              (list "parameter"  #px"^(?:public\\s+|private\\s+)?parameter\\s+(?:\"([^\"]+)\"|(\\w+))")
              (list "context"    #px"^context\\s+(\\w+)")
              (list "define"     #px"^(?:public\\s+|private\\s+)?define\\s+(?:fluent\\s+)?(?:function\\s+)?(?:\"([^\"]+)\"|(\\w+))"))
        "fml"
        (list (list "map"        #px"^map\\s+\"[^\"]*\"\\s*=\\s*\"?([^\"\\s]+)\"?")
              (list "uses"       #px"^uses\\s+\"[^\"]+\"\\s+alias\\s+(\\w+)")
              (list "imports"    #px"^imports\\s+\"([^\"]+)\"")
              (list "conceptmap" #px"^conceptmap\\s+\"([^\"]+)\"")
              (list "group"      #px"^group\\s+(\\w+)"))))

;; language-entities : language-id text file -> entities   FSH through fsh-symbols; CQL and FML by
;; the table (a regexp may put the name in its first or second group)
(define (language-entities lang text file)
  (define f (if (path? file) (path->string file) file))
  (cond
    [(equal? lang "fsh") (entities-of text f)]
    [(hash-ref declarations lang #f)
     => (lambda (table)
          (for*/list ([(l i) (in-parallel (in-list (regexp-split #rx"\r?\n" text)) (in-naturals))]
                      [d (in-list table)]
                      [m (in-value (regexp-match (cadr d) l))] #:when m
                      [name (in-value (for/or ([g (in-list (cdr m))]) g))] #:when name)
            (entity (car d) name #f f i)))]
    [else '()]))

;; name-at : language-id text position -> name|#f   the word under the cursor, a CQL quoted name as
;; the text inside its quotes
(define (name-at lang text pos)
  (define lines (regexp-split #rx"\r?\n" text))
  (define line (and (< -1 (car pos) (length lines)) (list-ref lines (car pos))))
  (define col (and line (min (cdr pos) (string-length line))))
  (or (and line (equal? lang "cql")
           (for/or ([m (in-list (regexp-match-positions* #px"\"[^\"]+\"" line))])
             (and (<= (car m) col (cdr m)) (substring line (add1 (car m)) (sub1 (cdr m))))))
      (word-at text pos)))

(define keywords
  (hash "cql" '("library" "using" "include" "called" "version" "public" "private" "valueset" "codesystem" "code"
                "concept" "parameter" "default" "context" "define" "function" "fluent" "returns" "from" "where"
                "return" "sort" "by" "asc" "desc" "with" "without" "such" "that" "let" "aggregate" "all" "distinct"
                "exists" "not" "and" "or" "xor" "implies" "is" "as" "cast" "if" "then" "else" "case" "when" "end"
                "in" "contains" "between" "properly" "includes" "during" "before" "after" "starts" "ends" "same"
                "overlaps" "meets" "union" "intersect" "except" "null" "true" "false" "Interval" "List" "Tuple"
                "Code" "Concept" "Quantity" "Integer" "Decimal" "String" "Boolean" "Date" "DateTime" "Time"
                "Patient" "Population" "Unfiltered" "Practitioner")
        "fml"  '("map" "uses" "alias" "as" "source" "target" "queried" "produced" "imports" "conceptmap" "prefix"
                "group" "extends" "types" "type+" "default" "where" "check" "log" "then" "share" "first" "last"
                "not_first" "not_last" "only_one" "create" "copy" "truncate" "escape" "cast" "append" "translate"
                "reference" "dateOp" "uuid" "pointer" "evaluate" "cc" "c" "qty" "id" "cp" "equivalent" "equal"
                "wider" "narrower" "unmatched" "true" "false")))

;; CompletionItemKind codes
(define (item-kind kind)
  (case kind [("define" "group") 3] [("library" "map" "include" "using" "uses" "imports") 9]
             [("valueset" "codesystem" "code" "concept" "conceptmap") 12] [("parameter" "context") 6] [else 1]))

;; language-completions : language-id text position -> (listof CompletionItem)
(define (language-completions lang text pos)
  (define-values (prefix quoted?) (typed-prefix text pos))
  (define (fits? label) (or (string=? prefix "")
                            (and (>= (string-length label) (string-length prefix))
                                 (string=? (substring label 0 (string-length prefix)) prefix))))
  (define declared
    (for/list ([e (in-list (language-entities lang text (string-append "untitled." lang)))]
               #:when (fits? (entity-name e)))
      (hasheq 'label (entity-name e) 'kind (item-kind (entity-kind e)) 'detail (entity-kind e))))
  ;; inside quotes only a declared name can follow
  (define kws (if quoted? '() (for/list ([k (in-list (hash-ref keywords lang '()))] #:when (fits? k)) (hasheq 'label k 'kind 14))))
  (append declared kws))
;; typed-prefix : text position -> (values string boolean)   the word characters just before the
;; cursor, and whether they sit inside an open quote (a quoted CQL name, without its opening quote)
(define (typed-prefix text pos)
  (define lines (regexp-split #rx"\r?\n" text))
  (define line (if (< -1 (car pos) (length lines)) (list-ref lines (car pos)) ""))
  (define before (substring line 0 (min (cdr pos) (string-length line))))
  (cond [(regexp-match #px"\"([^\"]*)$" before) => (lambda (m) (values (cadr m) #t))]
        [(regexp-match #px"([A-Za-z_][A-Za-z0-9_]*)$" before) => (lambda (m) (values (cadr m) #f))]
        [else (values "" #f)]))

(module+ test
  (require rackunit (only-in "fsh-symbols.rkt" entity-line find-entity))
  (define cql "library L version '1'\nusing FHIR version '4.0.1'\ninclude FHIRHelpers version '4.0.1' called FHIRHelpers\nvalueset \"VS\": 'http://x'\nparameter \"P\" Integer\ncontext Patient\ndefine \"A B\": 1\ndefine function f(x Integer): x\ndefine C: \"A B\"\n")
  (define es (language-entities "cql" cql "/tmp/l.cql"))
  (check-equal? (map entity-name es) '("L" "FHIR" "FHIRHelpers" "VS" "P" "Patient" "A B" "f" "C"))
  (check-equal? (map entity-kind es) '("library" "using" "include" "valueset" "parameter" "context" "define" "define" "define"))
  (check-equal? (entity-line (find-entity es "A B")) 6)
  (check-equal? (name-at "cql" cql (cons 8 12)) "A B")
  (check-equal? (name-at "cql" cql (cons 7 17)) "f")
  (define fml "map \"http://x/StructureMap/m\" = \"MyMap\"\nuses \"http://hl7.org/fhir/StructureDefinition/Patient\" alias Patient as source\nimports \"http://x/StructureMap/other\"\ngroup main(source src : Patient, target tgt) {\n  src -> tgt then helper(src, tgt);\n}\ngroup helper(source s, target t) {\n}\n")
  (define fs (language-entities "fml" fml "/tmp/m.map"))
  (check-equal? (map entity-name fs) '("MyMap" "Patient" "http://x/StructureMap/other" "main" "helper"))
  (check-equal? (entity-line (find-entity fs "helper")) 6)
  (check-equal? (name-at "fml" fml (cons 4 20)) "helper")
  ;; completion: the declared names and keywords that start with what is typed
  (check-equal? (map (lambda (i) (hash-ref i 'label)) (language-completions "cql" cql (cons 8 2))) '("default" "define" "desc"))
  (check-equal? (map (lambda (i) (hash-ref i 'label)) (language-completions "cql" "define \"A B\": 1\ndefine C: \"A" (cons 1 13)))
                '("A B"))
  (check-equal? (map (lambda (i) (hash-ref i 'label)) (language-completions "fml" fml (cons 4 20))) '("helper"))
  (check-true (and (member "where" (map (lambda (i) (hash-ref i 'label)) (language-completions "cql" cql (cons 9 0)))) #t))
  (check-equal? (language-entities "vcl" "(http://loinc.org)a" "/tmp/v.vcl") '())
  (check-equal? (length (language-entities "fsh" "Profile: P\nParent: Patient\n" "/tmp/p.fsh")) 1))
