#lang racket/base

;;; docs-test.rkt — the manual renders, shows the Python README's examples (it reads them from
;;; clients/python/README.md, which clients/python/tests/test_readme.py runs), lists every function
;;; of the table, and names commands that exist.

(require rackunit racket/file racket/list racket/port racket/string racket/system racket/runtime-path
         (only-in "../api/functions.rkt" functions fn-name)
         (only-in "../api-cli.rkt" parse-args usage-error?))

(define-runtime-path manual "../scribblings/fhir-api.scrbl")
(define-runtime-path readme "../../clients/python/README.md")

(define out (make-temporary-file "fhir-api-docs-~a" 'directory))
(define raco (find-executable-path "raco"))
(define log (open-output-string))
(check-true (parameterize ([current-output-port log] [current-error-port log])
              (system* raco "scribble" "+m" "--html" "--dest" (path->string out) "--dest-name" "index.html" (path->string manual)))
            (get-output-string log))
(check-false (regexp-match? #rx"(?i:warning|undefined tag)" (get-output-string log)) (get-output-string log))
(define html (file->string (build-path out "index.html")))
(define text (regexp-replace* #rx"&[a-z]+;|&#[0-9]+;" (regexp-replace* #rx"<[^>]+>" html "") " "))
(delete-directory/files out)

;; the README's examples are on the page, with what they print
(check-true (file-exists? readme))
(check-regexp-match #rx"fhir = Toolkit\\(\\)" text)
(check-regexp-match #rx"# \\['Ann Lee'\\]" text)
(check-regexp-match #rx"# input.fsh:3:3: error: profile: P: `nmae` is not an element of Patient" text)
(check-false (regexp-match? #rx"the example is in clients/python/README.md" text))

;; every function of the table is listed
(for ([f (in-list functions)])
  (check-regexp-match (regexp (string-append (regexp-quote (fn-name f)) ": ")) text (fn-name f)))

;; each `raco fhir-api …` the page names is a command the tool takes
(for ([line (in-list (remove-duplicates (regexp-match* #px"raco fhir-api (serve|functions --json|functions|call)" text)))])
  (check-false (usage-error? (parse-args (cdr (cdr (string-split (if (regexp-match? #rx"call$" line) (string-append line " version") line))))))
               line))
