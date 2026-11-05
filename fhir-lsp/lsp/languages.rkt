#lang racket/base

;;; languages.rkt — the languages the server knows, as a catalogue.
;;;
;;; A Language is (language id extensions diagnose):
;;;   id         : the LSP languageId, also the package ("fsh", "cql", "fml", "vcl", "fhirpath")
;;;   extensions : the file extensions it owns
;;;   diagnose   : text path -> (listof diagnostic)   every problem in the document, positioned
;;; Each language package is loaded when first asked for (dynamic-require), so the server runs with
;;; whichever of them are installed: a document in a language that is not installed gets one
;;; diagnostic saying so. An adapter never raises: an unexpected failure is a diagnostic at 1:1.

(require racket/contract racket/string racket/list racket/path
         (only-in fhir/diagnostic diagnostic diagnostic? loc loc-source exn:fail:diagnostic? exn:fail:diagnostic-diagnostic
                  attached-diagnostic diagnostic-loc)
         (only-in fhir/result/result ok? err? ok-value err-error))

(provide
 (struct-out language)
 (contract-out
  [languages        (listof language?)]
  [language-of      (-> path-string? (or/c language? #f))]
  [language-by-id   (-> string? (or/c language? #f))]
  [diagnose         (-> language? string? path-string? (listof diagnostic?))]))

(struct language (id extensions diagnose) #:transparent)

;; ---- helpers shared by the adapters -----------------------------------------------------------
(define (positionless lang phase msg source) (diagnostic lang phase 'error msg (loc (path-string source) #f #f #f #f)))
(define (path-string p) (if (path? p) (path->string p) p))
;; with-source : diagnostic source -> diagnostic   a diagnostic that names no file names this one
(define (with-source d source)
  (define l (diagnostic-loc d))
  (if (and l (loc-source* l)) d
      (struct-copy diagnostic d [loc (if l (struct-copy loc l [source (path-string source)]) (loc (path-string source) #f #f #f #f))])))
(define (loc-source* l) (let ([s (loc-source l)]) (and s (not (equal? s "")) s)))
;; lang-ref : module-path symbol -> value | #f   #f when the package is not installed
(define (lang-ref mod name)
  (with-handlers ([exn:fail:filesystem:missing-module? (lambda (_) #f)]
                  [exn:fail:syntax:missing-module? (lambda (_) #f)])
    (dynamic-require mod name)))
;; the text of a #lang file is compiled without its first line, so positions stay true
(define (blank-lang-line text) (regexp-replace #px"^#lang[^\n]*" text ""))

;; ---- the adapters ----------------------------------------------------------------------------
;; fsh: parse the document; compile its project (sushi-config beside it or up to two levels up),
;; with this text standing in for the file on disk; every diagnostic the project reports
(define (diagnose-fsh text path)
  (define compile-project (lang-ref 'fsh/project 'compile-project))
  (define project-diagnostics (lang-ref 'fsh/project 'project-diagnostics))
  (cond
    [(not compile-project) (list (positionless 'fsh 'compile "the fsh package is not installed" path))]
    [else
     (define p (compile-project path #:texts (hash (path-string (simplify-path (path->complete-path path))) (blank-lang-line text))))
     (project-diagnostics p)]))

;; cql: parse, then translate every definition; the errors, positioned when the error carries a position
(define (diagnose-cql text path)
  (define parse-cql (lang-ref 'cql/parser/parse 'parse-cql))
  (define compile-library/errors (lang-ref 'cql/compile 'compile-library/errors))
  (define cql-error-diagnostic (lang-ref 'cql/error 'cql-error-diagnostic))
  (define cql-error-message (lang-ref 'cql/error 'cql-error-message))
  (define cql-error-phase (lang-ref 'cql/error 'cql-error-phase))
  (define (->diagnostic e)
    (or (cql-error-diagnostic e)
        (positionless 'cql (case (cql-error-phase e) [(translate) 'compile] [(interpret) 'run] [else (cql-error-phase e)])
                      (cql-error-message e) path)))
  (cond
    [(not parse-cql) (list (positionless 'cql 'compile "the cql package is not installed" path))]
    [else
     (define r (parse-cql (blank-lang-line text) #:source (path-string path)))
     (cond
       [(err? r) (list (with-source (->diagnostic (err-error r)) path))]
       [else (let-values ([(elm errors) (compile-library/errors (ok-value r))])
               (map (lambda (e) (with-source (->diagnostic e) path)) errors))])]))

;; fml: parse, then check the map against its structures (what the StructureDefinitions decide)
(define (diagnose-fml text path)
  (define parse-fml (lang-ref 'fml/parser/parse 'parse-fml))
  (define check-map (lang-ref 'fml/check 'check-map))
  (define fml-error-diagnostic (lang-ref 'fml/error 'fml-error-diagnostic))
  (define fml-error-message (lang-ref 'fml/error 'fml-error-message))
  (cond
    [(not parse-fml) (list (positionless 'fml 'compile "the fml package is not installed" path))]
    [else
     (define r (parse-fml (blank-lang-line text) #:source (path-string path)))
     (cond
       [(err? r) (define e (err-error r))
                 (list (with-source (or (fml-error-diagnostic e) (positionless 'fml 'parse (fml-error-message e) path)) path))]
       [else (map (lambda (d) (with-source d path)) (check-map (ok-value r) #:source (path-string path)))])]))

;; vcl: the one expression, parsed and compiled to a compose
(define (diagnose-vcl text path)
  (define vcl->compose (lang-ref 'vcl/compile 'vcl->compose))
  (define validation-error-message (lang-ref 'fhir/result/result 'validation-error-message))
  (cond
    [(not vcl->compose) (list (positionless 'vcl 'compile "the vcl package is not installed" path))]
    [else
     (define r (vcl->compose (string-trim (blank-lang-line text))))
     (cond
       [(ok? r) '()]
       [else (define e (err-error r))
             (list (with-source (or (attached-diagnostic e) (positionless 'vcl 'compile (validation-error-message e) path)) path))])]))

;; fhirpath: one expression per document; a syntax error is a positioned diagnostic
(define (diagnose-fhirpath text path)
  (define parse-fhirpath (lang-ref 'fhirpath/parser/parse 'parse-fhirpath))
  (cond
    [(not parse-fhirpath) (list (positionless 'fhirpath 'parse "the fhirpath package is not installed" path))]
    [else
     (with-handlers ([exn:fail:diagnostic? (lambda (e) (list (with-source (exn:fail:diagnostic-diagnostic e) path)))])
       (parse-fhirpath (string-trim text))
       '())]))

;; the catalogue
(define languages
  (list (language "fsh" '("fsh") diagnose-fsh)
        (language "cql" '("cql") diagnose-cql)
        (language "fml" '("fml" "map") diagnose-fml)
        (language "vcl" '("vcl") diagnose-vcl)
        (language "fhirpath" '("fhirpath") diagnose-fhirpath)))

(define (language-of p)
  (define ext (let ([e (path-get-extension p)]) (and e (string-downcase (bytes->string/utf-8 (subbytes e 1))))))
  (and ext (findf (lambda (l) (member ext (language-extensions l))) languages)))
(define (language-by-id id) (findf (lambda (l) (equal? (language-id l) id)) languages))

;; diagnose : language text path -> diagnostics   never raises
(define (diagnose l text path)
  (with-handlers ([exn:fail:diagnostic? (lambda (e) (list (with-source (exn:fail:diagnostic-diagnostic e) path)))]
                  [exn:fail? (lambda (e) (list (positionless (string->symbol (language-id l)) 'compile (exn-message e) path)))])
    ((language-diagnose l) text path)))

(module+ test
  (require rackunit (only-in fhir/diagnostic diagnostic-message))
  (check-equal? (language-id (language-of "ig/input/fsh/bp.fsh")) "fsh")
  (check-equal? (language-id (language-of "maps/intake.map")) "fml")
  (check-equal? (language-id (language-of "A.CQL")) "cql")
  (check-false (language-of "notes.txt"))
  (check-equal? (language-id (language-by-id "vcl")) "vcl")
  ;; an adapter that raises becomes one positionless diagnostic, never an exception
  (define boom (language "boom" '("boom") (lambda (t p) (error "no"))))
  (define ds (diagnose boom "x" "/tmp/x.boom"))
  (check-equal? (length ds) 1)
  (check-equal? (diagnostic-message (car ds)) "no")
  (check-equal? (loc-source (diagnostic-loc (car ds))) "/tmp/x.boom"))
