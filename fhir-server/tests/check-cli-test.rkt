#lang racket/base

;;; check-cli-test.rkt — `raco fhir-server check <app.rkt>`: the declarations compiled, one line per
;;; resource and operation (a rerun's agent ran `racket app.rkt` and read 150 lines of
;;; CapabilityStatement to learn it compiles); a mistake is its line, exit 1.

(require rackunit racket/file racket/system racket/port)

(define dir (make-temporary-directory "check-cli-~a"))
(define (check-app text)
  (define f (build-path dir "study.capability.rkt"))
  (with-output-to-file f #:exists 'truncate (lambda () (display text)))
  (define out (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port out] [current-directory dir])
                 (system*/exit-code (find-executable-path "raco") "fhir-server" "check" "study.capability.rkt")))
  (values code (get-output-string out)))

(let-values ([(code out) (check-app (string-append "#lang fhir/capability\n(server)\n"
                                                   "(resource Patient #:interactions (read create search-type) #:search-params ([gender token]))\n"
                                                   "(define (h in req) (Parameters))\n"
                                                   "(operation $ping #:system #:handler h)\n"))])
  (check-equal? code 0 out)
  (check-regexp-match #rx"^ok  study[.]capability[.]rkt  [(]FHIR 6" out)
  (check-regexp-match #rx"\n  Patient: read, create, search-type; search by gender\n" out)
  (check-regexp-match #rx"\n  [$]?ping [(]system[)]\n" out))
(let-values ([(code out) (check-app "#lang fhir/capability\n(server)\n(resource Patient #:interactions (read creat))\n")])
  (check-equal? code 1)
  (check-regexp-match #rx"study[.]capability[.]rkt:3:.*creat" out))
(delete-directory/files dir)
