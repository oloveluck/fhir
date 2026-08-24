#lang s-exp syntax/module-reader

;;; reader.rkt — #lang fhir/foundation : wrap each top form as (fhir-resource-form <form>); the
;;; module language fhir/foundation/base (via fhir/kernel/kit) builds it to a typed node.

fhir/foundation/base

#:read        lang-read
#:read-syntax lang-read-syntax
#:whole-body-readers? #t

(define (lang-read-syntax src in)
  (let loop ([acc '()])
    (define form (read in))
    (if (eof-object? form)
        (reverse acc)
        (loop (cons (datum->syntax #f (list 'fhir-resource-form form)) acc)))))

(define (lang-read in)
  (map syntax->datum (lang-read-syntax #f in)))
