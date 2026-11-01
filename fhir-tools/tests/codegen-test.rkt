#lang racket/base

;;; codegen-test.rkt — the spec-reading pipeline: load the real R6 package, nest + expand Patient,
;;; and assert the derived IR (backbone nesting, cardinality, choice expansion, ftype resolution).

(require rackunit
         racket/list
         fhir/codegen/load-spec
         fhir/codegen/structure-definition
         fhir/codegen/ir
         fhir/codegen/nest
         fhir/codegen/expand
         fhir/codegen/emit-schema
         fhir/codegen/target)

(define pkg (load-package (gen-target-package-file target-r6)))
(define sds (package-contents-sds pkg))
(define ods (package-contents-operations pkg))
(define version (package-contents-version pkg))
(check-true (string? version))
;; the core package ships the standard operations, sorted by (code, id) for determinism
(check-true (pair? ods))
(check-true (andmap (lambda (od) (string? (hash-ref od 'code #f))) ods))
(let ([keys (map (lambda (od) (format "~a/~a" (hash-ref od 'code) (hash-ref od 'id))) ods)])
  (check-equal? keys (sort keys string<?)))

(define (sd-named name)
  (findf (lambda (sd) (equal? (structure-definition-name sd) name)) sds))

;; --- Patient nests its contact backbone -------------------------------------------------------
(define patient (sd-named "Patient"))
(check-true (structure-definition? patient))
(define pnode (nest patient))
(check-equal? (type-node-name pnode) "Patient")
(check-equal? (type-node-parent pnode) "DomainResource")
(define backbone-names (map type-node-name (type-node-backbones pnode)))
(check-true (and (member "Patient.Contact" backbone-names) #t))

;; --- HumanName field types resolve correctly --------------------------------------------------
(define hn (nest (sd-named "HumanName")))
(define (field-named node n) (findf (lambda (f) (equal? (field-def-name f) n)) (type-node-fields node)))
(check-equal? (field-def->ftype "HumanName" (field-named hn "family")) #(prim "string"))
(check-equal? (field-def->ftype "HumanName" (field-named hn "given"))  #(prim "string"))
(check-equal? (field-def-max (field-named hn "given")) "*")            ; given is a list 0..*
(check-equal? (field-def->ftype "HumanName" (field-named hn "period")) #(type Period))

;; --- choice expansion: Patient.deceased[x] -> deceasedBoolean / deceasedDateTime --------------
(define pexp (expand pnode))
(define expanded-names (map field-def-name (type-node-fields pexp)))
(check-true (and (member "deceasedBoolean" expanded-names) #t))
(check-true (and (member "deceasedDateTime" expanded-names) #t))
(check-false (member "deceased" expanded-names))     ; the raw value[x] is gone after expansion

;; the choice group is recorded (for the form macro's "at most one of" check)
(define groups (choice-groups-of pnode))
(check-true (and (assoc 0 (map (lambda (g) (cons (car g) (cadr g))) groups)) #t))
