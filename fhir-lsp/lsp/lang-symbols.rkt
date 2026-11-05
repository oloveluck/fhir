#lang racket/base

;;; lang-symbols.rkt — declarations in a CQL or FML document, read from the text (as fsh-symbols.rkt
;;; reads FSH): the outline an editor shows and what a name under the cursor refers to.
;;;
;;; The declarations, per language, as a table of (kind regexp): the regexp's first group is the name.
;;;   cql  library, include (its alias), using, valueset, codesystem, code, concept, parameter, context, define
;;;   fml  map (its name), uses (its alias), imports, conceptmap, group
;;; An Entity is fsh-symbols' (entity kind name id file line); id is #f here.

(require racket/contract racket/string racket/list racket/match
         (only-in "fsh-symbols.rkt" entity entity? entities-of word-at))

(provide
 (contract-out
  [declarations     (hash/c string? (listof (list/c string? regexp?)))]
  [language-entities (-> string? string? path-string? (listof entity?))]
  [name-at          (-> string? string? pair? (or/c string? #f))]))

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

(module+ test
  (require rackunit (only-in "fsh-symbols.rkt" entity-name entity-kind entity-line find-entity))
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
  (check-equal? (language-entities "vcl" "(http://loinc.org)a" "/tmp/v.vcl") '())
  (check-equal? (length (language-entities "fsh" "Profile: P\nParent: Patient\n" "/tmp/p.fsh")) 1))
