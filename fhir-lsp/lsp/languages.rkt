#lang racket/base

;;; languages.rkt — the languages the server knows: the family's catalogue (fhir/lang/support), each
;;; language's support loaded from its own package when first asked for. A document in a language
;;; that is not installed gets one diagnostic saying so; an adapter never breaks the server.
;;;
;;; A Language is (language id extensions): the LSP languageId (also the collection) and the file
;;; extensions it owns.

(require racket/contract racket/list
         fhir/lang/support
         (only-in fhir/diagnostic diagnostic?))

(provide
 (struct-out language)
 (contract-out
  [languages        (listof language?)]
  [language-of      (-> path-string? (or/c language? #f))]
  [language-by-id   (-> string? (or/c language? #f))]
  [support-of       (-> language? (or/c lang-support? #f))]
  [diagnose         (-> language? string? path-string? (listof diagnostic?))]))

(struct language (id extensions) #:transparent)

(define languages (for/list ([id (in-list language-ids)]) (language id (hash-ref extensions-by-language id))))
(define (language-of p) (let ([id (language-id-of p)]) (and id (language-by-id id))))
(define (language-by-id id) (findf (lambda (l) (equal? (language-id l) id)) languages))
(define (support-of l) (language-support (language-id l)))

;; diagnose : language text path -> diagnostics   never raises
(define (diagnose l text path) (diagnose-safely (language-id l) (support-of l) text path))

(module+ test
  (require rackunit (only-in fhir/diagnostic diagnostic-message))
  (check-equal? (language-id (language-of "ig/input/fsh/bp.fsh")) "fsh")
  (check-equal? (language-id (language-of "maps/intake.map")) "fml")
  (check-equal? (language-id (language-of "A.CQL")) "cql")
  (check-false (language-of "notes.txt"))
  (check-equal? (language-id (language-by-id "vcl")) "vcl")
  ;; a stand-in support that raises becomes one diagnostic, never an exception
  (define boom (lang-support "vcl" (lambda (t p) (error "no")) (lambda (p) '()) (lambda (t f) '())
                             (lambda (pr t pos) #f) (lambda (pr t pos) #f) (lambda (pr t pos) '())))
  (parameterize ([current-language-supports (hash "vcl" boom)])
    (define ds (diagnose (language-by-id "vcl") "x" "/tmp/x.vcl"))
    (check-equal? (length ds) 1)
    (check-equal? (diagnostic-message (car ds)) "no")))
