#lang racket/base

;;; validate-cli.rkt — `raco fhir-validate`.
;;;
;;;   raco fhir-validate <resource.json> [profile.json…] [--format outcome|text|json]
;;;       validate against the base type + the supplied profiles (and the profiles the resource
;;;       claims in meta.profile, resolved from fhir-spec); exit 1 on an error
;;;
;;; --format outcome (default: the OperationOutcome on stdout) | text (one line per issue on stderr) |
;;; json; malformed JSON is a positioned `json parse` diagnostic in the same format (fhir/diagnostic).

(require (only-in racket/file file->string)
         (only-in json jsexpr->string read-json)
         (only-in fhir/diagnostic diagnostic loc emit-diagnostics format-flag)
         (only-in fhir/serialize/read-json read-fhir-json/duplicates)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/conformance/validate validate-json))

(provide validate-file)

(define usage-text
  "usage: raco fhir-validate <resource.json> [profile.json…] [--format outcome|text|json]\n")
(define (usage [code 2])
  ((if (zero? code) printf eprintf) usage-text)
  (exit code))

;; validate-file : file profile-files #:format -> exits 1 on an error
(define (validate-file file profile-files #:format [fmt 'outcome])
  (dynamic-require 'fhir/r5/schemas #f)
  ;; read-file : path reader -> (values jsexpr dups)   a reader failure is reported where reading stopped
  (define (read-file f reader)
    (call-with-input-file f
      (lambda (p)
        (port-count-lines! p)
        (with-handlers ([exn:fail?
                         (lambda (e)
                           (define-values (line col pos) (port-next-location p))
                           (define d (diagnostic 'json 'parse 'error
                                                 (regexp-replace #px"^[a-z/>-]+: " (exn-message e) "")
                                                 (loc f line (and col (max 1 col)) pos #f)))
                           (emit-diagnostics (list d) #:format (if (memq fmt '(json text)) fmt 'outcome)
                                             #:text-of (lambda (_) (file->string f)))
                           (exit 1))])
          (reader p)))))
  ;; the precision-preserving reader, so decimals validate on their lexeme, and any duplicate JSON
  ;; keys it collapses (invalid FHIR JSON the plain parser would hide) are reported
  (define-values (js dups) (read-file file read-fhir-json/duplicates))
  (define profiles (for/list ([f (in-list profile-files)]) (let-values ([(j _) (read-file f (lambda (p) (values (read-json p) #f)))]) j)))
  (define oo (node->jsexpr (validate-json js #:profiles profiles #:duplicates dups)))
  (define issues (let ([v (hash-ref oo 'issue '())]) (if (list? v) v '())))
  (case fmt
    [(text) (for ([i (in-list issues)])
              (eprintf "~a: ~a ~a~a: ~a\n" file (hash-ref i 'severity "") (hash-ref i 'code "")
                       (let ([x (hash-ref i 'expression '())]) (if (pair? x) (format " at ~a" (car x)) ""))
                       (hash-ref i 'diagnostics (hash-ref (hash-ref i 'details (hasheq)) 'text ""))))]
    [else (displayln (jsexpr->string oo))])
  (when (for/or ([i (in-list issues)]) (member (hash-ref i 'severity #f) '("error" "fatal")))
    (exit 1)))

(module+ main
  (define all (vector->list (current-command-line-arguments)))
  (define-values (fmt args) (format-flag all))
  (cond
    [(ormap (lambda (a) (member a '("-h" "--help"))) args) (usage 0)]
    [(null? args) (usage)]
    [(findf (lambda (a) (regexp-match? #rx"^-" a)) args)
     => (lambda (a) (eprintf "fhir-validate: unknown option ~a\n" a) (usage))]
    [(findf (lambda (f) (not (file-exists? f))) args)
     => (lambda (f) (eprintf "fhir-validate: no such file: ~a\n" f) (exit 2))]
    [else (validate-file (car args) (cdr args)
                         #:format (if (member "--format" all) fmt 'outcome))]))
