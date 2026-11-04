#lang racket/base

;;; registry.rkt — FHIR resources registered by the modules that define them, resolvable by
;;; canonical (and by id) from anywhere in the process.
;;;
;;; The module system doubles as the FHIR registry: a `#lang fsh` module registers its profiles,
;;; value sets and code systems when it is instantiated, a `#lang vcl` module its value set, a
;;; `#lang fml` module its StructureMap. Every resolver in the family looks here between the current
;;; data source and the packages (sd/operations, sd/logical, the terminology resolver, fml), so
;;; requiring a module is enough for `uses`, `#:profile`, `$expand #:url` and `$transform #:source`
;;; to find what it defines — no data source to set up.
;;;
;;; A canonical defined by two different modules with different content is an error naming both
;;; (the same content again, or a redefinition by the same module, is accepted). Ids (`Type/id`,
;;; for resources without a url) are not checked: the latest registration wins.

(require racket/contract racket/list)

(provide (contract-out
          ;; register-resources! : resources [#:source who] -> void   (resources without url or id skipped)
          [register-resources! (->* ((listof hash?)) (#:source any/c) void?)]
          ;; registered-resource : kind url-or-id -> resource | #f   (a |version suffix is ignored)
          [registered-resource (-> string? string? (or/c hash? #f))]
          ;; registered-resources : kind -> (listof resource)
          [registered-resources (-> string? (listof hash?))]
          ;; registered-source : kind url-or-id -> who registered it
          [registered-source (-> string? string? any/c)]
          [registered-kinds (-> (listof string?))]))

;; kind -> (hash key -> (cons resource source)); a resource sits under its url and its id
(define by-kind (make-hash))

(define (key-of s) (car (regexp-split #rx"[|]" s)))

(define (register-resources! rs #:source [source #f])
  (for ([r (in-list rs)])
    (define kind (hash-ref r 'resourceType #f))
    (define url (let ([u (hash-ref r 'url #f)]) (and (string? u) (key-of u))))
    (define id (let ([i (hash-ref r 'id #f)]) (and (string? i) i)))
    (when (and (string? kind) (or url id))
      (define table (hash-ref! by-kind kind make-hash))
      (when url
        (define old (hash-ref table url #f))
        (cond [(not old) (hash-set! table url (cons r source))]
              [(equal? (car old) r) (void)]                            ; the same content: the first source keeps it
              [(equal? (cdr old) source) (hash-set! table url (cons r source))]
              [else (error 'register-resources! "~a ~a is defined by both ~a and ~a" kind url (cdr old) source)]))
      (when id (hash-set! table id (cons r source))))))

(define (entry kind key) (hash-ref (hash-ref by-kind kind (hash)) (key-of key) #f))
(define (registered-resource kind key) (let ([e (entry kind key)]) (and e (car e))))
(define (registered-source kind key) (let ([e (entry kind key)]) (and e (cdr e))))
(define (registered-resources kind)
  (remove-duplicates (map car (hash-values (hash-ref by-kind kind (hash)))) eq?))
(define (registered-kinds) (sort (hash-keys by-kind) string<?))

(module+ test
  (require rackunit)
  (define sd (hasheq 'resourceType "StructureDefinition" 'url "http://x/sd" 'id "sd" 'kind "logical"))
  (define vs (hasheq 'resourceType "ValueSet" 'url "http://x/vs|1.0"))
  (register-resources! (list sd vs (hasheq 'resourceType "Patient" 'id "p1") (hasheq 'resourceType "Basic")) #:source 'a)
  (check-equal? (registered-resource "StructureDefinition" "http://x/sd|2") sd)
  (check-equal? (registered-resource "StructureDefinition" "sd") sd)
  (check-equal? (registered-resource "ValueSet" "http://x/vs") vs)
  (check-equal? (registered-resources "StructureDefinition") (list sd))       ; once, not per key
  (check-equal? (registered-source "ValueSet" "http://x/vs") 'a)
  (check-equal? (hash-ref (registered-resource "Patient" "p1") 'id) "p1")
  (check-false (registered-resource "Basic" "nope"))
  ;; the same content again, from anywhere: fine; the same module redefining: replaced; another
  ;; module defining the same canonical differently: an error naming both
  (register-resources! (list sd) #:source 'b)
  (define sd2 (hash-set sd 'kind "resource"))
  (register-resources! (list sd2) #:source 'a)
  (check-equal? (registered-resource "StructureDefinition" "http://x/sd") sd2)
  (check-exn #rx"http://x/sd is defined by both a and c" (lambda () (register-resources! (list sd) #:source 'c)))
  (check-equal? (registered-kinds) '("Patient" "StructureDefinition" "ValueSet")))
