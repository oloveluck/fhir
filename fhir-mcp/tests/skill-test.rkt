#lang racket/base

;;; skill-test.rkt — the fhir skill's session (the repository's .claude/skills/fhir/SKILL.md) runs
;;; as it is written, in a workspace made by `init`. Each ```call block is `<tool> <json arguments>`,
;;; where a string "<the FSH above>" (CQL, view) stands for the last ```fsh (```cql, ```view) block
;;; before it; the ```answer after a call is a part of the answer: every key it names has that value
;;; (lists element by element), or, for a JSON string, the whole text the tool answered.

(require rackunit racket/runtime-path racket/file racket/list racket/string json
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/tools tool-name tool-run))

(define-runtime-path skill-file "../../.claude/skills/fhir/SKILL.md")
(define text (file->string skill-file))

;; A Block is (cons lang body), in the order of the text
(define blocks (map (lambda (m) (cons (cadr m) (caddr m)))
                    (regexp-match* #px"```([a-z]+)\n(.*?)```" text #:match-select values)))

;; within? : expected actual -> boolean   expected is a part of actual
(define (within? e a)
  (cond [(and (hash? e) (hash? a)) (for/and ([(k v) (in-hash e)]) (and (hash-has-key? a k) (within? v (hash-ref a k))))]
        [(and (list? e) (list? a)) (and (= (length e) (length a)) (andmap within? e a))]
        [(and (number? e) (number? a)) (= e a)]
        [else (equal? e a)]))

(define dir (make-temporary-directory "skill-~a"))
(void (init-workspace! dir))
(define h (open-hub dir))
(define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))

;; fill : jsexpr (hash lang -> body) -> jsexpr   "<the FSH above>" and friends replaced
(define placeholders (hash "<the FSH above>" "fsh" "<the CQL above>" "cql" "<the view above>" "view"))
(define (fill v last)
  (cond [(hash? v) (for/hasheq ([(k x) (in-hash v)]) (values k (fill x last)))]
        [(list? v) (map (lambda (x) (fill x last)) v)]
        [(and (string? v) (hash-ref placeholders v #f)) => (lambda (lang) (hash-ref last lang))]
        [else v]))

(define calls 0)

(define (match-block b last answer)
  (define lang (car b))
  (define body (cdr b))
  (cond
    [(member lang '("fsh" "cql" "view")) (values (hash-set last lang body) answer)]
    [(equal? lang "call")
     (define m (regexp-match #px"^\\s*([a-z]+)\\s+(.*?)\\s*$" body))
     (define args (fill (string->jsexpr (caddr m)) last))
     (define-values (out err?) ((tool-run (hash-ref tools (cadr m))) args))
     (set! calls (add1 calls))
     (check-false err? (format "~a: ~a" (cadr m) out))
     (values last out)]
    [(equal? lang "answer")
     (define expected (string->jsexpr body))
     (if (string? expected)
         (check-equal? answer expected)
         (check-true (within? expected (string->jsexpr answer)) (format "expected ~a\n  within ~a" body answer)))
     (values last #f)]
    [else (values last answer)]))

(void (with-hub h
  (lambda ()
    (for/fold ([last (hash)] [answer #f] #:result (void)) ([b (in-list blocks)])
      (match-block b last answer)))))
(check-equal? calls 8 "the session's calls all ran")
(delete-directory/files dir)

;; every skill's description is read whole: in YAML ` #` starts a comment, so an unquoted description
;; with `#lang` in it was cut there (fhir-authoring's read "Author and run the FHIR Racket")
(define-runtime-path skills-dir "../../.claude/skills")
(for ([d (in-list (directory-list skills-dir #:build? #t))] #:when (file-exists? (build-path d "SKILL.md")))
  (define desc (cadr (regexp-match #px"(?m:^description: (.*)$)" (file->string (build-path d "SKILL.md")))))
  (check-true (or (regexp-match? #px"^\"" desc) (not (regexp-match? #px" #" desc)))
              (format "~a: quote the description, it has ` #`" d)))
