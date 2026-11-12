#lang racket/base

;;; fsh-source.rkt — the FSH text a stage was made from, read as text: where an Instance and its
;;; rules are, the block that defines one resource, the line an error is about.
;;;
;;; A stage keeps its source (the Provenance contains it), so a refusal, a history and a correction
;;; can point INTO it: the instance's header, the rule that wrote an element, the `insert` that
;;; brought a value. These read the text line by line — no parser, so they work on text that does
;;; not compile — and know FSH only as far as an entity's header and a rule's path.
;;;
;;; A Line is a 1-based line number of the text. Pure.

(require racket/contract racket/list racket/string racket/match)

(provide
 (contract-out
  [instance-line     (-> string? string? (or/c exact-positive-integer? #f))]
  [instance-block    (-> string? string? (or/c string? #f))]
  [entity-lines      (-> string? exact-positive-integer? string?)]
  [used-definitions  (-> string? string? (listof string?))]
  [insert-line       (-> string? exact-positive-integer? (or/c exact-positive-integer? #f))]
  [rule-line         (-> string? exact-positive-integer? (or/c string? #f) (or/c exact-positive-integer? #f))]
  [last-rule-line    (-> string? exact-positive-integer? string? (or/c exact-positive-integer? #f))]
  [error-element     (-> string? (or/c string? #f))]
  [with-missing-hint (->* (string?) (any/c) string?)]))

;; where an entity begins: its keyword at the start of a line
(define entity-header #px"^(?:Instance|Profile|Extension|Logical|Resource|ValueSet|CodeSystem|Invariant|RuleSet|Mapping|Alias)\\s*:")

;; instance-block : fsh-text id -> string | #f   the lines of the Instance with this id, from its header to
;; the next entity (or the end), trailing blank lines left out
(define (instance-block text id)
  (define start (instance-line text id))
  (and start
       (let ([block (entity-lines text start)])
         ;; the RuleSets it inserts and the Aliases it names come along, so the text stages again
         ;; (a correction from `as=source` of a RuleSet-written reading failed: RuleSet not found)
         (string-append (string-join (append (used-definitions text block) (list block)) "\n")))))

;; entity-lines : fsh-text line -> string   the entity starting at that line, to the next entity header
(define (entity-lines text start)
  (let* ([lines (list-tail (regexp-split #rx"\n" text) (sub1 start))]
         [body (cons (car lines)
                     (for/list ([l (in-list (cdr lines))]
                                #:break (regexp-match? entity-header l))
                       l))])
    (string-append (string-join (reverse (dropf (reverse body) (lambda (l) (string=? (string-trim l) "")))) "\n") "\n")))

;; insert-line : fsh-text instance-line -> line | #f   the instance's first `* insert` rule: a reading
;; written by a RuleSet (`* insert Reading(bp-a1, a, 2025-01-10, 142, 91)`) has its values there,
;; not at its header
(define (insert-line text start)
  (define block-lines (regexp-split #rx"\n" (entity-lines text start)))
  (for/first ([l (in-list block-lines)] [i (in-naturals start)]
              #:when (regexp-match? #px"^\\s*\\*\\s*insert\\s" l))
    i))

;; used-definitions : fsh-text block -> (listof string)   the Alias lines and RuleSet entities the block
;; uses (RuleSets that insert others, transitively), in the order the text defines them
(define (used-definitions text block)
  (define lines (regexp-split #rx"\n" text))
  (define (ruleset-start name)
    (for/first ([l (in-list lines)] [i (in-naturals 1)]
                #:when (regexp-match? (pregexp (string-append "^RuleSet:\\s*" (regexp-quote name) "\\s*(\\(|$)")) l))
      i))
  (define (inserted b) (map cadr (regexp-match* #px"(?m:^\\s*\\*[^\n]*?\\binsert\\s+([A-Za-z0-9_.-]+))" b #:match-select values)))
  (define starts
    (let loop ([todo (inserted block)] [seen '()])
      (cond [(null? todo) seen]
            [(assoc (car todo) seen) (loop (cdr todo) seen)]
            [else (define st (ruleset-start (car todo)))
                  (if st
                      (loop (append (cdr todo) (inserted (entity-lines text st))) (cons (cons (car todo) st) seen))
                      (loop (cdr todo) seen))])))
  (define rulesets (map (lambda (p) (entity-lines text (cdr p))) (sort starts < #:key cdr)))
  (define all-text (string-join (cons block rulesets) "\n"))
  (define aliases (for/list ([l (in-list lines)]
                             #:when (let ([m (regexp-match #px"^Alias:\\s*(\\S+)\\s*=" l)])
                                      (and m (regexp-match? (regexp (regexp-quote (cadr m))) all-text))))
                    l))
  (append (if (null? aliases) '() (list (string-append (string-join aliases "\n") "\n"))) rulesets))

;; instance-line : fsh-text id -> line | #f   where the Instance with this id begins: the one named
;; so, else the one whose `* id = "…"` rule gives it
(define (instance-line text id)
  (define lines (regexp-split #rx"\n" text))
  (or (for/first ([l (in-list lines)] [i (in-naturals 1)]
                  #:when (regexp-match? (pregexp (string-append "^Instance:\\s*" (regexp-quote id) "\\s*$")) l))
        i)
      (let loop ([ls lines] [i 1] [start #f])
        (cond [(null? ls) #f]
              [(regexp-match? #px"^Instance:" (car ls)) (loop (cdr ls) (add1 i) i)]
              [(and start (regexp-match? (pregexp (string-append "^\\*\\s*id\\s*=\\s*\"" (regexp-quote id) "\"")) (car ls))) start]
              [else (loop (cdr ls) (add1 i) start)]))))

;; error-element : error-text -> path|#f   the element an error is about: what an invariant found
;; (`… (found component[0].valueQuantity = 20 'kPa')` -> component[0].valueQuantity; "found no …" is
;; about what is missing, so no rule wrote it), else the path's first step
;; (`Observation.component[1].value[x]: …` -> component)
(define (error-element e)
  (cond [(regexp-match #px"[(]found (?!no )([A-Za-z][A-Za-z0-9_.\\[\\]]*)" e) => cadr]
        [(regexp-match? #px"[(]found no " e) #f]
        [(regexp-match #px"^[A-Z][A-Za-z]*[.]([a-z][A-Za-z0-9_.\\[\\]]*):" e) => cadr]
        [else #f]))

;; with-missing-hint : error -> error   something missing says what to add, beside where:
;; `(found no component matching '8462-4')` -> `…; add a component with '8462-4'` (a rerun's agent
;; was told the instance's line, not what the fix was)
(define (with-missing-hint e [after? #f])
  (match (regexp-match #px"[(]found no ([A-Za-z]+) matching ([^)]+)[)]" e)
    [(list whole elem what) (string-replace e whole (format "(found no ~a matching ~a: add a ~a with ~a~a)" elem what elem what (if after? " after this line" "")))]
    [_ (match (regexp-match #px"[(]found no ([A-Za-z.]+)[)]" e)
         ;; an element the rule needs and the instance does not write: `(found no subject)` -> `: add a
         ;; rule for subject (* subject = …)` (the stage had named the line, not the fix)
         [(list whole path) (string-replace e whole (format "(found no ~a: add a rule for it, * ~a = …)" path path))]
         [_ e])]))

;; last-rule-line : fsh-text instance-line element -> line|#f   the last rule of that instance writing
;; the element (`* component[1].valueQuantity = …` for `component`), where a missing item goes
(define (last-rule-line text start element)
  (define rx (pregexp (string-append "^\\s*\\*\\s+" (regexp-quote element) "(?:\\[[^\\]]*\\])?(?:[.\\s=]|$)")))
  (for/last ([l (in-list (drop (regexp-split #rx"\n" text) start))]
             [i (in-naturals (add1 start))]
             #:break (regexp-match? entity-header l)
             #:when (regexp-match? rx l))
    i))

;; rule-line : fsh-text instance-line path|#f -> line|#f   the first rule of that instance writing the
;; element: the whole path (`* component[0].valueQuantity = …`), else ever shorter prefixes of it
;; (`* component[0]…`, `* component…`); `value` also matches its choice keys (`* valueQuantity`)
(define (rule-line text start element)
  (define lines (drop (regexp-split #rx"\n" text) start))
  ;; a step as an FSH rule may write it: `component` as `component[0]` (an index or a slice name),
  ;; `value[x]` (the validator's) or `value` (FHIRPath's) as `valueQuantity`; an index given stays
  (define (step-rx st)
    (cond [(regexp-match #px"^(.*)\\[x\\]$" st) => (lambda (m) (string-append (regexp-quote (cadr m)) "[A-Za-z]*(?:\\[[^\\]]*\\])?"))]
          [(regexp-match? #px"\\[[0-9]+\\]$" st) (regexp-quote st)]
          [else (string-append (regexp-quote st) "(?:[A-Z][A-Za-z]*)?(?:\\[[^\\]]*\\])?")]))
  (define (line-of path)
    (define rx (pregexp (string-append "^\\s*\\*\\s+" (string-join (map step-rx (regexp-split #rx"[.]" path)) "[.]") "(?:[.\\s=]|$)")))
    (for/first ([l (in-list lines)]
                [i (in-naturals (add1 start))]
                #:break (regexp-match? entity-header l)
                #:when (regexp-match? rx l))
      i))
  (and element
       (let loop ([path element])
         (or (line-of path)
             (let ([shorter (regexp-replace #px"(?:[.][^.]+|\\[[0-9]+\\])$" path "")])
               (and (not (equal? shorter path)) (loop shorter)))))))

(module+ test
  (require rackunit)
  (define text
    (string-join
     '("Alias: $LOINC = http://loinc.org"                                    ; 1
       "Alias: $UNUSED = http://example.org/unused"
       ""
       "RuleSet: Reading(patient, date, sys, dia)"                            ; 4
       "* insert Coded"
       "* subject = Reference(Patient/{patient})"
       "* component[0].valueQuantity = {sys} 'mm[Hg]'"
       "* component[1].valueQuantity = {dia} 'mm[Hg]'"
       ""
       "RuleSet: Coded"                                                       ; 10
       "* code = $LOINC#85354-9"
       ""
       "Instance: bp-a1"                                                      ; 13
       "InstanceOf: Observation"
       "* insert Reading(a, 2025-01-10, 142, 91)"
       ""
       "Instance: Second"                                                     ; 17
       "InstanceOf: Observation"
       "* id = \"bp-a2\""
       "* status = #final"
       "* component[0].code = $LOINC#8480-6"
       "* component[0].valueQuantity = 20 'kPa'"
       "* component[1].code = $LOINC#8462-4"
       "* valueQuantity = 7 '%'"
       "")
     "\n"))
  ;; where an instance is: by its name, else by its id rule
  (check-equal? (instance-line text "bp-a1") 13)
  (check-equal? (instance-line text "bp-a2") 17)
  (check-false (instance-line text "nope"))
  ;; an entity's lines stop at the next header, trailing blank lines left out
  (check-equal? (entity-lines text 10) "RuleSet: Coded\n* code = $LOINC#85354-9\n")
  ;; a block stages again: the RuleSets it inserts (transitively) and the Aliases it names come along
  (check-equal? (instance-block text "bp-a1")
                (string-append "Alias: $LOINC = http://loinc.org\n\n"
                               "RuleSet: Reading(patient, date, sys, dia)\n* insert Coded\n* subject = Reference(Patient/{patient})\n"
                               "* component[0].valueQuantity = {sys} 'mm[Hg]'\n* component[1].valueQuantity = {dia} 'mm[Hg]'\n\n"
                               "RuleSet: Coded\n* code = $LOINC#85354-9\n\n"
                               "Instance: bp-a1\nInstanceOf: Observation\n* insert Reading(a, 2025-01-10, 142, 91)\n"))
  (check-false (instance-block text "nope"))
  ;; a value written through a RuleSet is at the instance's insert
  (check-equal? (insert-line text 13) 15)
  (check-false (insert-line text 17))
  ;; the rule that wrote an element: the whole path, else ever shorter; `value` matches its choice keys
  (check-equal? (rule-line text 17 "component[0].valueQuantity") 22)
  (check-equal? (rule-line text 17 "component[1].valueQuantity") 23)      ; no such rule: the component's first
  (check-equal? (rule-line text 17 "component.value[x].code") 22)
  (check-equal? (rule-line text 17 "value") 24)
  (check-false (rule-line text 17 "subject"))
  (check-false (rule-line text 17 #f))
  (check-false (rule-line text 13 "status"))                              ; never reads into the next entity
  ;; where a missing item goes: after the last rule writing the list
  (check-equal? (last-rule-line text 17 "component") 23)
  (check-false (last-rule-line text 17 "category"))
  ;; the element an error is about
  (check-equal? (error-element "bp-systolic: … (found component[0].valueQuantity = 20 'kPa')") "component[0].valueQuantity")
  (check-false (error-element "bp-diastolic: … (found no component matching '8462-4')"))
  (check-equal? (error-element "Observation.component[1].value[x]: minimum required = 1") "component[1].value[x]")
  (check-false (error-element "something else"))
  ;; what is missing says what to add
  (check-equal? (with-missing-hint "rule (found no component matching '8462-4')")
                "rule (found no component matching '8462-4': add a component with '8462-4')")
  (check-equal? (with-missing-hint "rule (found no component matching '8462-4')" #t)
                "rule (found no component matching '8462-4': add a component with '8462-4' after this line)")
  (check-equal? (with-missing-hint "rule (found no subject)") "rule (found no subject: add a rule for it, * subject = …)")
  (check-equal? (with-missing-hint "another message") "another message"))
