#lang racket/base
;;; check-files.rkt — `raco fhir check-files [dir|file …]`: every `#lang` file of a program's languages
;;; (FSH, FML, CQL, VCL — `.fsh`, `.map`, `.fml`, `.cql`, `.vcl`) compiled on its own, each one's
;;; first problem reported, all in one run. `raco make main.rkt` stops at the first failing module, so
;;; typos in three files took three runs (a new user's report). Each file is read and expanded in a
;;; fresh namespace, as `raco make` would compile it, so the language's own checks run (fsh's rule
;;; checks, fml's check-map, cql's translation); nothing is written. A file without a `#lang` line is
;;; not a module (a plain project file for `raco fsh`) and is left out. The FSH examples are validated
;;; by `raco fsh check`, not here (a module compiles alone).

(require racket/contract racket/list racket/path racket/string racket/file)

(provide
 (contract-out
  ;; language-file? : path -> boolean   a file this command checks (by extension)
  [language-file? (-> path-string? boolean?)]
  ;; files-to-check : (listof path-string) -> (listof path)   the language files under each directory
  ;; (recursively, `compiled/` left out) and each file named, in order, `#lang` files only
  [files-to-check (-> (listof path-string?) (listof path?))]
  ;; check-file : path -> string | #f   the file's first problem as Racket reports it, or #f
  [check-file (-> path-string? (or/c string? #f))]))

(define extensions '("fsh" "map" "fml" "cql" "vcl"))

(define (language-file? p)
  (define e (path-get-extension p))
  (and e (member (string-downcase (substring (bytes->string/utf-8 e) 1)) extensions) #t))

;; lang-module? : path -> boolean   does the file start with a `#lang` line (after blank lines and comments)?
(define (lang-module? p)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (for/first ([l (in-list (file->lines p))] #:unless (regexp-match? #px"^\\s*(;.*|//.*)?$" l))
      (regexp-match? #px"^#lang\\s" l))))

(define (files-to-check args)
  (remove-duplicates
   (for*/list ([a (in-list args)]
               [f (in-list (if (directory-exists? a)
                               (sort (for/list ([f (in-directory a (lambda (d) (not (equal? (path->string (file-name-from-path d)) "compiled"))))]
                                                #:when (file-exists? f))
                                       f)
                                     string<? #:key path->string)
                               (list (string->path (if (path? a) (path->string a) a)))))]
               #:when (and (file-exists? f) (language-file? f) (lang-module? f)))
     (simplify-path (path->complete-path f)))))

(define (check-file f)
  (define p (simplify-path (path->complete-path f)))
  (define-values (dir _name _d?) (split-path p))
  (with-handlers ([exn:fail? exn-message])
    (parameterize ([current-namespace (make-base-namespace)]
                   [current-load-relative-directory dir]
                   [read-accept-reader #t]
                   [read-accept-lang #t])
      (define stx (call-with-input-file p (lambda (in) (port-count-lines! in) (read-syntax p in))))
      (void (expand stx))
      #f)))

(module+ test
  (require rackunit)
  (check-true (language-file? "a/b/intake.fsh"))
  (check-true (language-file? "x.MAP"))
  (check-false (language-file? "main.rkt"))
  (define d (make-temporary-directory "check-files-~a"))
  (define (put! name text) (call-with-output-file (build-path d name) (lambda (o) (write-string text o))))
  (put! "plain.fsh" "Profile: P\nParent: Patient\n")               ; no #lang: not a module, left out
  (put! "ok.vcl" "#lang vcl\n(http://loinc.org)4548-4\n")
  (put! "bad.vcl" "#lang vcl\n(http://loinc.org)4548-4;;\n")
  (check-equal? (map (lambda (p) (path->string (file-name-from-path p))) (files-to-check (list d)))
                '("bad.vcl" "ok.vcl"))
  (check-false (check-file (build-path d "ok.vcl")))
  (check-regexp-match #rx"bad[.]vcl" (check-file (build-path d "bad.vcl")))
  (delete-directory/files d))
