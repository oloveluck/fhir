#lang racket/base

;;; docs-commands-test.rkt — every `raco <tool> [subcommand]` the family's documents name exists: the
;;; skills, guides, READMEs and CLAUDE.md files of every installed repository. A new user found
;;; `raco fhir fhirpath-tck`, `raco fhir fml-tck` and `raco fhir vcl` in the notes, long gone; this keeps
;;; the documents and the commands from drifting apart again. Each distinct command is run with
;;; `--help`, which every family CLI answers with its usage and exit 0; an unknown command or
;;; subcommand exits 2. A word that is a file (`raco fml map.map`) is not a subcommand.

(require rackunit racket/file racket/list racket/string racket/system racket/port pkg/lib)

;; the repositories: each installed package's directory, its repository root above it for the fhir repo
(define repo-roots
  (remove-duplicates
   (filter values
           (for/list ([p (in-list '("fhir" "fsh" "cql" "fml" "vcl" "fhirpath" "sql-on-fhir" "fhir-examples"))])
             (define d (with-handlers ([exn:fail? (lambda (_) #f)]) (pkg-directory p)))
             (and d (if (equal? p "fhir") (simplify-path (build-path d 'up)) (simplify-path d)))))))

;; the documents an agent or a person reads
(define (docs-in root)
  (filter file-exists?
          (append (for/list ([f '("README.md" "CLAUDE.md" "guide.md")]) (build-path root f))
                  (let ([skills (build-path root ".claude" "skills")])
                    (if (directory-exists? skills)
                        (for/list ([d (in-list (directory-list skills #:build? #t))]) (build-path d "SKILL.md"))
                        '()))
                  ;; the fhir repo's packages: their notes, the hub's learn/ guides, the capability guide
                  (for*/list ([pkg (in-list (directory-list root #:build? #t))] #:when (directory-exists? pkg)
                              [f (in-list (append (list (build-path pkg "CLAUDE.md") (build-path pkg "capability" "guide.md"))
                                                  (let ([l (build-path pkg "learn")])
                                                    (if (directory-exists? l) (directory-list l #:build? #t) '()))))]
                              #:when (regexp-match? #rx"[.]md$" (path->string f)))
                    f))))

;; Racket's own raco commands, and words in prose that are not commands
(define not-ours '("make" "test" "setup" "pkg" "exe" "distribute" "docs" "command" "raco"))

;; commands-in : text -> (listof (list tool sub|#f))
(define (commands-in text)
  (for/list ([m (in-list (regexp-match* #px"raco ([a-z][a-z-]*)(?: ([a-z][a-z-]*)(?=[\\s`'\")|,;:]|$))?" text #:match-select values))]
             #:unless (member (cadr m) not-ours))
    (list (cadr m) (caddr m))))

(define mentioned
  (remove-duplicates
   (for*/list ([root (in-list repo-roots)] [f (in-list (docs-in root))] [c (in-list (commands-in (file->string f)))])
     (list (car c) (cadr c) f))
   #:key (lambda (x) (list (car x) (cadr x)))))

;; exit code and output of `raco <tool> [sub] --help`
(define raco (find-executable-path "raco"))
(define (help-of tool sub)
  (define out (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port out])
                 (apply system*/exit-code raco (append (list tool) (if sub (list sub) '()) (list "--help")))))
  (values code (get-output-string out)))

(check-true (> (length mentioned) 20) "the documents name the commands")
(when raco
  (for ([m (in-list mentioned)])
    (define-values (code out) (help-of (car m) (cadr m)))
    (check-equal? code 0 (format "~a names `raco ~a~a`, which does not exist: ~a"
                                 (cadr (cdr m)) (car m) (if (cadr m) (string-append " " (cadr m)) "")
                                 (string-trim (car (append (string-split out "\n") '(""))))))))
