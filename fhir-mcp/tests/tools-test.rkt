#lang racket/base

;;; tools-test.rkt — the tools over the real operations and languages, when their packages are
;;; installed: $snapshot (the foundation), the terminology operations, and the language tools on
;;; small inputs. Each either answers or says its package is not installed.

(require rackunit racket/list racket/string json fhir/mcp/tools
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/spec-package spec-package-path))

(define loaded (load-operations!))
(check-not-false (memq 'fhir/sd/operations loaded) "the foundation's $snapshot is always there")
(define tools (for/hash ([t (in-list (all-tools))]) (values (tool-name t) t)))
(check-true (hash-has-key? tools "fhir_snapshot"))
(check-true (hash-has-key? tools "diagnose_file"))
;; every tool's description is a JSON-serialisable protocol entry with an object schema
(for ([t (in-hash-values tools)])
  (check-true (jsexpr? (tool->jsexpr t)) (tool-name t))
  (check-equal? (hash-ref (tool-input-schema t) 'type) "object" (tool-name t))
  (check-true (regexp-match? #px"^[A-Za-z0-9_-]{1,64}$" (tool-name t)) (tool-name t)))

;; $snapshot over the R5 core (when fhir-spec is installed): a profile's snapshot comes back
(define core (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t))
(when core
  (parameterize ([current-sd-packages (list core)])
    (define-values (text err?)
      (call-tool (hash-ref tools "fhir_snapshot")                           ; its subject is the `definition` input
                 (hasheq 'definition (hasheq 'resourceType "StructureDefinition" 'url "http://example.org/StructureDefinition/P" 'name "P"
                                           'status "draft" 'kind "resource" 'abstract #f 'type "Patient"
                                           'baseDefinition "http://hl7.org/fhir/StructureDefinition/Patient" 'derivation "constraint"
                                           'differential (hasheq 'element (list (hasheq 'id "Patient.name" 'path "Patient.name" 'min 1)))))))
    (check-false err? text)
    (check-true (pair? (hash-ref (hash-ref (string->jsexpr text) 'snapshot) 'element)))))

;; the terminology operations, when fhir-tx is installed
(when (and core (hash-has-key? tools "fhir_expand"))
  (parameterize ([current-sd-packages (list core)])
    (define-values (text err?) (call-tool (hash-ref tools "fhir_expand") (hasheq 'url "http://hl7.org/fhir/ValueSet/administrative-gender")))
    (check-false err? text)
    (check-true (ormap (lambda (c) (equal? (hash-ref c 'code) "female")) (hash-ref (hash-ref (string->jsexpr text) 'expansion) 'contains)))))

;; the language tools: an answer or "not installed", never a crash
(define (installed? mod) (with-handlers ([exn:fail? (lambda (_) #f)]) (dynamic-require mod #f) #t))
(define-values (vcl-text vcl-err?) (call-tool (hash-ref tools "vcl_valueset") (hasheq 'vcl "(http://loinc.org)(85354-9;55284-4)")))
(if (installed? 'vcl/compile)
    (begin (check-false vcl-err? vcl-text) (check-equal? (hash-ref (string->jsexpr vcl-text) 'resourceType) "ValueSet"))
    (check-true vcl-err?))
(define-values (fp-text fp-err?) (call-tool (hash-ref tools "fhirpath_evaluate") (hasheq 'expression "name.given" 'resource (hasheq 'resourceType "Patient" 'name (list (hasheq 'given '("Ann" "B")))))))
(if (installed? 'fhirpath/parser/parse)
    (begin (check-false fp-err? fp-text) (check-equal? (string->jsexpr fp-text) '("Ann" "B")))
    (check-true fp-err?))
(define-values (fsh-text fsh-err?) (call-tool (hash-ref tools "fsh_compile") (hasheq 'fsh "Profile: P\nParent: Patient\n* name 1..1\n")))
(if (installed? 'fsh/compile)
    (begin (check-false fsh-err? fsh-text) (check-equal? (hash-ref (car (string->jsexpr fsh-text)) 'resourceType) "StructureDefinition"))
    (check-true fsh-err?))
(define-values (cql-text cql-err?) (call-tool (hash-ref tools "cql_elm") (hasheq 'cql "library L version '1'\ndefine \"A\": 1 + 1\n")))
(if (installed? 'cql/compile)
    (begin (check-false cql-err? cql-text) (check-equal? (hash-ref (hash-ref (string->jsexpr cql-text) 'library) 'identifier) (hasheq 'id "L" 'version "1")))
    (check-true cql-err?))
;; a bad argument shape is an error with a message, not an exception
(define-values (bad-text bad-err?) (call-tool (hash-ref tools "cql_evaluate") (hasheq 'cql "x")))
(check-true bad-err?)
