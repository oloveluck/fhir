#lang racket/base
;;; op-ref.rkt — `(operation $validate)` names an operation value in scope; when nothing binds the
;;; name (its module not required), say which module provides it, at the form. Racket's own error
;;; was `$validate: unbound identifier`, with no hint (a rerun's agent found it by leaving the
;;; require out on purpose). Expanded with the module's body, after its requires are known.
(require (for-syntax racket/base racket/string racket/path))
(provide op-ref)

(begin-for-syntax
  ;; the operations the family registers, by the module that provides each value
  (define providers
    '(("$validate" . "fhir/conformance/operations")
      ("$snapshot" . "fhir/sd/operations")
      ("$expand" . "fhir/terminology/operations") ("$validate-code" . "fhir/terminology/operations")
      ("$lookup" . "fhir/terminology/operations") ("$translate" . "fhir/terminology/operations")
      ("$subsumes" . "fhir/terminology/operations")
      ("$transform" . "fml/operations")
      ("$evaluate-measure" . "cql/measure"))))

(define-syntax (op-ref stx)
  (syntax-case stx ()
    [(_ op)
     (cond
       [(identifier-binding #'op) #'op]
       [else
        (define name (symbol->string (syntax-e #'op)))
        (define m (assoc name providers))
        ;; the file as the other declaration errors name it: relative to the current directory
        ;; when that is shorter
        (define src (syntax-source #'op))
        (define shown
          (cond [(and (path? src) (absolute-path? src))
                 (define rel (with-handlers ([exn:fail? (lambda (_) #f)])
                               (path->string (find-relative-path (simplify-path (current-directory)) (simplify-path src)))))
                 (if (and rel (not (regexp-match? #rx"^([.][.]/){2}" rel)) (< (string-length rel) (string-length (path->string src))))
                     rel (path->string src))]
                [(path? src) (path->string src)]
                [else src]))
        (define where (and shown (syntax-line #'op) (format "~a:~a:~a" shown (syntax-line #'op) (syntax-column #'op))))
        (define msg
          (if m
              (format "operation: `~a` is not bound: require it first, (require (only-in ~a ~a)) — or name it by reference, (operation \"~a\")"
                      name (cdr m) name name)
              (format "operation: `~a` is not bound: define it with #:handler here, require the module that provides it, or name a registered operation by reference (operation \"~a\")"
                      name name)))
        (raise (exn:fail:user (if where (format "~a: ~a" where msg) msg) (current-continuation-marks)))])]))
