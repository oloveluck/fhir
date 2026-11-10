#lang racket/base

;;; validate-cli.rkt — `raco fhir-validate`.
;;;
;;;   raco fhir-validate <resource.json> [profile.json…] [--format outcome|text|json] [--fhir-version 4.0.1|5.0.0|6.0.0]
;;;       validate against the base type + the supplied profiles (and the profiles the resource
;;;       claims in meta.profile, resolved from fhir-spec); exit 1 on an error. The FHIR version is
;;;       R5 unless --fhir-version says otherwise or the resource names its own (`fhirVersion`, as a
;;;       CapabilityStatement or a StructureDefinition does).
;;;
;;; --format outcome (default: the OperationOutcome on stdout) | text (one line per issue on stderr) |
;;; json; malformed JSON is a positioned `json parse` diagnostic in the same format (fhir/diagnostic).

(require (only-in racket/file file->string)
         (only-in json jsexpr->string read-json)
         (only-in fhir/diagnostic diagnostic loc emit-diagnostics format-flag)
         (only-in fhir/serialize/read-json read-fhir-json/duplicates)
         (only-in fhir/serialize/to-json node->jsexpr)
         (only-in fhir/conformance/validate validate-json)
         (only-in fhir/sd/sd-index current-sd-packages)
         (only-in fhir/spec-package spec-package-path))

;; version-of : string|#f -> 'r4|'r5|'r6|#f   "4.0.1", "r4", "6.0.0-ballot4" ...
(define (version-of v)
  (cond [(not (string? v)) #f]
        [(regexp-match? #rx"^(?i:r?4)" v) 'r4]
        [(regexp-match? #rx"^(?i:r?5)" v) 'r5]
        [(regexp-match? #rx"^(?i:r?6)" v) 'r6]
        [else #f]))

(provide validate-file)

(define usage-text
  "usage: raco fhir-validate <resource.json> [profile.json…] [--format outcome|text|json] [--fhir-version 4.0.1|5.0.0|6.0.0]\n")
(define (usage [code 2])
  ((if (zero? code) printf eprintf) usage-text)
  (exit code))

;; validate-file : file profile-files #:format -> exits 1 on an error
(define (validate-file file profile-files #:format [fmt 'outcome] #:fhir-version [asked #f])
  ;; the version: asked for, else the resource's own `fhirVersion`, else R5
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
  (define version (or (version-of asked)
                      (version-of (and (hash? js) (let ([v (hash-ref js 'fhirVersion #f)]) (and (string? v) v))))
                      'r5))
  (dynamic-require (case version [(r4) 'fhir/r4/schemas] [(r6) 'fhir/r6/types] [else 'fhir/r5/schemas]) #f)
  (define core (spec-package-path (case version [(r4) "hl7.fhir.r4.core.tgz"] [(r6) "hl7.fhir.r6.core.tgz"] [else "hl7.fhir.r5.core.tgz"])
                                  #:optional? #t))
  (define profiles (for/list ([f (in-list profile-files)]) (let-values ([(j _) (read-file f (lambda (p) (values (read-json p) #f)))]) j)))
  (define oo (parameterize ([current-sd-packages (if core (list core) (current-sd-packages))])
               (node->jsexpr (validate-json js #:profiles profiles #:duplicates dups))))
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
  (define-values (fmt args0) (format-flag all))
  ;; --fhir-version V
  (define-values (fv args)
    (let loop ([as args0] [fv #f] [out '()])
      (cond [(null? as) (values fv (reverse out))]
            [(and (equal? (car as) "--fhir-version") (pair? (cdr as))) (loop (cddr as) (cadr as) out)]
            [else (loop (cdr as) fv (cons (car as) out))])))
  (cond
    [(ormap (lambda (a) (member a '("-h" "--help"))) args) (usage 0)]
    [(null? args) (usage)]
    [(findf (lambda (a) (regexp-match? #rx"^-" a)) args)
     => (lambda (a) (eprintf "fhir-validate: unknown option ~a\n" a) (usage))]
    [(findf (lambda (f) (not (file-exists? f))) args)
     => (lambda (f) (eprintf "fhir-validate: no such file: ~a\n" f) (exit 2))]
    [(and fv (not (version-of fv)))
     (eprintf "fhir-validate: --fhir-version takes 4.0.1, 5.0.0 or 6.0.0 (got ~a)\n" fv) (exit 2)]
    [else (validate-file (car args) (cdr args)
                         #:format (if (member "--format" all) fmt 'outcome)
                         #:fhir-version fv)]))
