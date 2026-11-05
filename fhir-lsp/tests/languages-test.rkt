#lang racket/base

;;; languages-test.rkt — each language's support on a small document: a problem is a positioned
;;; diagnostic naming the file; a clean document has none. A language whose package is not installed
;;; reports exactly that (one diagnostic), so this test runs anywhere.

(require rackunit racket/file racket/list
         fhir/lsp/languages
         (only-in fhir/lang/support language-support)
         (only-in fhir/diagnostic diagnostic-loc diagnostic-message diagnostic-severity loc-line loc-source))

(define dir (make-temporary-directory))
(define (write! name text) (define p (build-path dir name)) (display-to-file text p #:exists 'replace) p)
;; check-language : id file-name bad-text good-text expected-line -> void
(define (check-language id name bad good line)
  (define l (language-by-id id))
  (define p (write! name bad))
  (define ds (diagnose l bad p))
  (cond
    [(language-support id)
     (check-true (pair? ds) (format "~a: a problem is reported" id))
     (check-equal? (diagnostic-severity (car ds)) 'error)
     (check-equal? (loc-source (diagnostic-loc (car ds))) (path->string p) (format "~a: the diagnostic names the file" id))
     (when line (check-equal? (loc-line (diagnostic-loc (car ds))) line (format "~a: the line" id)))
     (check-equal? (diagnose l good (write! name good)) '() (format "~a: a clean document" id))]
    [else
     (check-equal? (length ds) 1)
     (check-regexp-match #rx"not installed" (diagnostic-message (car ds)))]))

(check-language "fsh" "bp.fsh"
                "Profile: BP\nParent: Observation\n* nosuchelement 1..1\n"
                "Profile: BP\nParent: Observation\n* code 1..1 MS\n"
                3)
(check-language "cql" "lib.cql"
                "library L version '1'\ndefine \"A\": Mx(1, 2)\n"
                "library L version '1'\ndefine \"A\": Max({1, 2})\n"
                #f)
(check-language "fml" "m.map"
                (string-append "map \"http://x/StructureMap/m\" = \"m\"\n"
                               "uses \"http://hl7.org/fhir/StructureDefinition/Patient\" alias Patient as source\n"
                               "uses \"http://hl7.org/fhir/StructureDefinition/Patient\" alias Patient as target\n"
                               "group g(source src : Patient, target tgt : Patient) {\n  src.nmae as n -> tgt.name = n;\n}\n")
                (string-append "map \"http://x/StructureMap/m\" = \"m\"\n"
                               "uses \"http://hl7.org/fhir/StructureDefinition/Patient\" alias Patient as source\n"
                               "uses \"http://hl7.org/fhir/StructureDefinition/Patient\" alias Patient as target\n"
                               "group g(source src : Patient, target tgt : Patient) {\n  src.name as n -> tgt.name = n;\n}\n")
                5)
(check-language "vcl" "v.vcl" "(http://loinc.org)(85354-9;" "(http://loinc.org)(85354-9;55284-4)" #f)
(check-language "fhirpath" "e.fhirpath" "name.given(" "name.given" #f)

(delete-directory/files dir)
