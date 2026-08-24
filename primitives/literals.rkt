#lang racket/base

;;; literals.rkt — standalone, compile-time-validated primitive literals.
;;;
;;; The form macro (lang-gen/form-syntax.rkt) already validates primitive leaves inside a resource
;;; form. `lit` is the same guarantee OUTSIDE a form — a checked literal usable anywhere (and, later,
;;; the substrate for FHIRPath/CQL literal syntax). `(lit date "1974-12-25")` validates at COMPILE
;;; time (via the primitive's own constructor) and expands to a validated primitive newtype instance;
;;; `(lit date "1974-13-40")` is a compile error. A non-literal argument defers to a runtime check.

(require (for-syntax racket/base
                     syntax/parse
                     (only-in "../model/registry.rkt" constructor-of primitive-name?)
                     (only-in "../result/result.rkt" err?)
                     (only-in "primitives.rkt"))                 ; register constructors at phase 1
         (only-in "../kernel/node-build.rkt" build-prim))

(provide lit)

(define-syntax (lit stx)
  (syntax-parse stx
    [(_ code:id v:expr)
     (define name (syntax-e #'code))
     (unless (primitive-name? name)
       (raise-syntax-error 'lit (format "unknown primitive type ~a" name) #'code))
     (define d (syntax->datum #'v))
     (when (or (string? d) (number? d) (boolean? d))          ; a literal — check it now
       (define ctor (constructor-of name))
       (when (err? (ctor d))
         (raise-syntax-error 'lit (format "invalid ~a literal: ~s" name d) #'v)))
     #`(build-prim #,(symbol->string name) v)]))

(module+ test
  (require rackunit
           (only-in "primitives.rkt" primitive->jsexpr fhir-date? fhir-code?)
           syntax/macro-testing)
  (check-true  (fhir-date? (lit date "1974-12-25")))
  (check-equal? (primitive->jsexpr (lit date "1974-12-25")) "1974-12-25")
  (check-equal? (primitive->jsexpr (lit date "1974")) "1974")            ; variable precision
  (check-true  (fhir-code? (lit code "male")))
  (check-equal? (primitive->jsexpr (lit decimal "1.50")) 1.5)            ; value view
  ;; bad literals fail at COMPILE time
  (check-exn #rx"invalid date literal"
             (lambda () (convert-compile-time-error (lit date "1974-13-40"))))
  (check-exn #rx"invalid code literal"
             (lambda () (convert-compile-time-error (lit code " bad"))))
  (check-exn #rx"unknown primitive type"
             (lambda () (convert-compile-time-error (lit notAType "x")))))
