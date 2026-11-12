#lang racket/base

;;; ig-config.rkt — what a sushi-config.yaml says: an implementation guide as text, read ONCE here
;;; for everything that asks (the FSH compiler and packer, the ImplementationGuide a guide file
;;; compiles to, the workspace whose canonical, packages and constraints it states).
;;;
;;; The syntax is SUSHI's (https://fshschool.org/docs/sushi/configuration/). Each dependency's NPM
;;; package is located through fhir-spec (`<id>-<version>.tgz`, or `<id>.tgz` when that package IS
;;; the version asked for). In the foundation because the workspace reads it as well as fsh, which
;;; re-exports it (fsh/ig-config).
;;;
;;; A Dependency is (cons package-id version), e.g. ("hl7.fhir.us.core" . "6.1.0"). Both YAML forms:
;;;   dependencies:
;;;     hl7.fhir.uv.genomics-reporting: 2.0.0
;;;     hl7.fhir.us.core:
;;;       version: 6.1.0
;;;       id: hl7fhiruscore
;;; A DependsOn is (depends-on package version uri id): the same entry with the `uri` and `id` it
;;; may give — what ImplementationGuide.dependsOn carries.
;;; A Global is (cons type profile): `global` is `Type: profile`, `Type: [profiles]`, or a list of
;;; `{type, profile}` — a profile every resource of a type is held to (ImplementationGuide.global).

(require racket/contract racket/string racket/file racket/match
         json file/gunzip file/untar
         (only-in fhir/spec-package spec-package-path current-package-directories)
         "yaml.rkt")

(provide
 (struct-out ig-config)
 (struct-out depends-on)
 (contract-out
  ;; what the struct's fields do not hold, read from its `yaml` (the constructor keeps its arity)
  [ig-config-depends-on   (-> ig-config? (listof depends-on?))]
  [ig-config-globals      (-> ig-config? (listof (cons/c string? string?)))]
  ;; ig-config-experimental : -> #t | #f | 'unstated
  [ig-config-experimental (-> ig-config? (or/c boolean? 'unstated))]
  [ig-config-fhir-versions (-> ig-config? (listof string?))]
  [read-ig-config      (-> path-string? ig-config?)]
  ;; parse-ig-config : text -> ig-config   (raises exn:fail:yaml on what is not the YAML read here)
  [parse-ig-config     (-> string? ig-config?)]
  [dependency-packages (-> (listof (cons/c string? string?)) (values (listof path?) (listof (cons/c string? string?))))]
  ;; implicit-packages : fhir-version -> (listof tgz-path)   the packages SUSHI loads without being
  ;; asked — hl7.fhir.uv.extensions and hl7.terminology for the version — when a copy is at hand
  ;; (current-package-directories, then fhir-spec; the newest version of each), else none
  [implicit-packages (-> (or/c string? #f) (listof path?))]))

;; ig-config : what compiling and packaging read — any may be #f / '()
;;   canonical fhir-version dependencies   (compile)
;;   id name title version status license description publisher   (package.json; publisher = its name)
;;   yaml   the whole file (a YamlValue, yaml.rkt), for what the ImplementationGuide needs
(struct ig-config (canonical fhir-version dependencies id name title version status license description publisher yaml)
  #:transparent)

;; read-ig-config : path -> ig-config   the file read as YAML (yaml.rkt); fhirVersion may be a list
(define (read-ig-config file) (parse-ig-config (file->string file)))
(define (parse-ig-config text)
  (define y (read-yaml text))
  (define (str key) (let ([v (yref y key)]) (and (string? v) (not (string=? v "")) v)))
  (define fhir-version (match (yref y "fhirVersion") [(? string? v) v] [(cons (? string? v) _) v] [_ #f]))
  (define publisher (match (yref y "publisher")
                      [(? string? v) v]
                      [(? ymap? m) (let ([n (yref m "name")]) (and (string? n) n))]
                      [(cons (? ymap? m) _) (let ([n (yref m "name")]) (and (string? n) n))]
                      [_ #f]))
  (ig-config (str "canonical") fhir-version (read-dependencies (yref y "dependencies"))
             (or (str "packageId") (str "id")) (str "name") (str "title") (str "version") (str "status")
             (str "license") (str "description") publisher y))

;; depends-on-entries : YamlValue -> (listof DependsOn)   `id: version` or `id: {version, uri, id}`
(struct depends-on (package version uri id) #:transparent)
(define (depends-on-entries deps)
  (define (text v) (and (string? v) (not (string=? v "")) v))
  (match deps
    [(ymap es)
     (for*/list ([e (in-list es)]
                 [v (in-value (cdr e))]
                 [version (in-value (match v [(? string? s) (text s)] [(? ymap? m) (text (yref m "version"))] [_ #f]))]
                 #:when version)
       (depends-on (car e) version (and (ymap? v) (text (yref v "uri"))) (and (ymap? v) (text (yref v "id")))))]
    [_ '()]))
;; read-dependencies : YamlValue -> (listof Dependency)
(define (read-dependencies deps)
  (for/list ([d (in-list (depends-on-entries deps))]) (cons (depends-on-package d) (depends-on-version d))))

(define (ig-config-depends-on c) (depends-on-entries (yref (ig-config-yaml c) "dependencies")))

;; ig-config-globals : ig-config -> (listof Global)
(define (ig-config-globals c)
  (define (strings v) (cond [(string? v) (list v)] [(list? v) (filter string? v)] [else '()]))
  (match (yref (ig-config-yaml c) "global")
    [(ymap es) (for*/list ([e (in-list es)] [p (in-list (strings (cdr e)))]) (cons (car e) p))]
    [(? list? l) (for*/list ([e (in-list l)]
                             [t (in-value (yref e "type"))] [p (in-value (yref e "profile"))]
                             #:when (and (string? t) (string? p)))
                   (cons t p))]
    [_ '()]))

(define (ig-config-experimental c)
  (match (yaml-boolean (yref (ig-config-yaml c) "experimental")) [#t #t] [#f #f] [_ 'unstated]))

;; ig-config-fhir-versions : ig-config -> (listof string)   `fhirVersion` may be one or a list
(define (ig-config-fhir-versions c)
  (match (yref (ig-config-yaml c) "fhirVersion")
    [(? string? v) (list v)]
    [(? list? l) (filter string? l)]
    [_ '()]))

;; dependency-packages : (listof Dependency) -> (values (listof tgz-path) (listof missing Dependency))
(define (dependency-packages deps)
  (for/fold ([found '()] [missing '()] #:result (values (reverse found) (reverse missing)))
            ([d (in-list deps)])
    (define p (or (spec-package-path (format "~a-~a.tgz" (car d) (cdr d)) #:optional? #t)
                  (let ([q (spec-package-path (format "~a.tgz" (car d)) #:optional? #t)])
                    (and q (equal? (package-version q) (cdr d)) q))))
    (if p (values (cons p found) missing) (values found (cons d missing)))))

;; the implicit packages, by the suffix the registry gives their FHIR-version builds
(define (implicit-packages fhir-version)
  (define suffix (cond [(and fhir-version (regexp-match? #rx"^4[.]" fhir-version)) "r4"]
                       [(and fhir-version (regexp-match? #rx"^5[.]" fhir-version)) "r5"]
                       [else #f]))
  (define dirs (append (current-package-directories)
                       (let ([core (spec-package-path "hl7.fhir.r4.core.tgz" #:optional? #t)])
                         (if core (let-values ([(d _n _m) (split-path core)]) (if (path? d) (list d) '())) '()))))
  (if (not suffix)
      '()
      (for*/list ([id (in-list (list (string-append "hl7.fhir.uv.extensions." suffix) (string-append "hl7.terminology." suffix)))]
                  [found (in-value (newest-package id dirs))] #:when found)
        found)))
;; newest-package : id dirs -> tgz-path|#f   <id>-<version>.tgz with the highest version in the dirs
(define (newest-package id dirs)
  (define rx (pregexp (string-append "^" (regexp-quote id) "-([0-9][^/]*)[.]tgz$")))
  (define found
    (for*/list ([d (in-list dirs)] #:when (directory-exists? d)
                [f (in-list (directory-list d))]
                [m (in-value (regexp-match rx (path->string f)))] #:when m)
      (cons (cadr m) (build-path d f))))
  (and (pair? found) (cdr (car (sort found version>? #:key car)))))
(define (version>? a b)
  (let loop ([as (string-split a ".")] [bs (string-split b ".")])
    (cond [(null? as) #f] [(null? bs) #t]
          [else (define x (string->number (car as))) (define y (string->number (car bs)))
                (cond [(and x y (not (= x y))) (> x y)]
                      [(and (not (and x y)) (not (equal? (car as) (car bs)))) (string>? (car as) (car bs))]
                      [else (loop (cdr as) (cdr bs))])])))
;; package-version : tgz -> string|#f   package/package.json's version
(define (package-version tgz)
  (define v #f)
  (call-with-input-file tgz
    (lambda (gz)
      (define-values (pin pout) (make-pipe))
      (define t (thread (lambda () (gunzip-through-ports gz pout) (close-output-port pout))))
      (untar pin #:handle-entry
             (lambda (k n c sz a)
               (when (and (eq? k 'file) (equal? (path->string n) "package/package.json"))
                 (set! v (hash-ref (bytes->jsexpr (read-bytes sz c)) 'version #f)))
               (when (eq? k 'file) (void (read-bytes sz c)))
               '()))
      (thread-wait t)))
  v)

(module+ test
  (require rackunit racket/path)
  (define f (make-temporary-file))
  (with-output-to-file f #:exists 'truncate
    (lambda () (display "canonical: http://hl7.org/fhir/us/mcode\nfhirVersion: 4.0.1\ndependencies:\n  hl7.fhir.uv.genomics-reporting: 2.0.0\n#  hl7.fhir.uv.extensions: 5.1.0-cibuild\n  hl7.fhir.us.core: \n    version: 6.1.0\n    id: hl7fhiruscore\nextension:\n  - url: x\n")))
  (define c (read-ig-config f))
  (check-equal? (ig-config-canonical c) "http://hl7.org/fhir/us/mcode")
  (check-equal? (ig-config-fhir-version c) "4.0.1")
  (check-equal? (ig-config-dependencies c) '(("hl7.fhir.uv.genomics-reporting" . "2.0.0") ("hl7.fhir.us.core" . "6.1.0")))
  (check-equal? (ig-config-depends-on c)
                (list (depends-on "hl7.fhir.uv.genomics-reporting" "2.0.0" #f #f) (depends-on "hl7.fhir.us.core" "6.1.0" #f "hl7fhiruscore")))
  (check-equal? (ig-config-globals c) '())
  (check-equal? (ig-config-experimental c) 'unstated)
  (check-equal? (ig-config-fhir-versions c) '("4.0.1"))
  ;; `global` in its three spellings; `experimental`
  (let ([g (parse-ig-config (string-append "experimental: true\nglobal:\n  Observation: http://x/lab\n"
                                           "  Patient:\n    - http://x/a\n    - http://x/b\n"))])
    (check-equal? (ig-config-globals g) '(("Observation" . "http://x/lab") ("Patient" . "http://x/a") ("Patient" . "http://x/b")))
    (check-equal? (ig-config-experimental g) #t))
  (check-equal? (ig-config-globals (parse-ig-config "global:\n  - type: Patient\n    profile: http://x/p\n")) '(("Patient" . "http://x/p")))
  (check-equal? (ig-config-experimental (parse-ig-config "experimental: false\n")) #f)
  ;; fhirVersion as a list; the whole file is kept for the ImplementationGuide
  (let ([h (make-temporary-file)])
    (with-output-to-file h #:exists 'truncate
      (lambda () (display "fhirVersion:\n  - 6.0.0-ballot5\nstatus: draft\npages:\n  index.md:\n    title: Home\n")))
    (define hc (read-ig-config h))
    (check-equal? (ig-config-fhir-version hc) "6.0.0-ballot5")
    (check-equal? (ig-config-status hc) "draft")
    (check-equal? (yref (yref (ig-config-yaml hc) "pages") "index.md") (ymap '(("title" . "Home")))))
  ;; the implicit packages: the newest copy of each, none for an unknown version
  (check-false (version>? "5.2.0" "5.10.0"))
  (check-true (version>? "5.10.0" "5.2.0"))
  (check-equal? (implicit-packages "3.0.2") '())
  (let ([dir (make-temporary-file "implicit-~a" 'directory)])
    (for ([n '("hl7.fhir.uv.extensions.r4-1.0.0.tgz" "hl7.fhir.uv.extensions.r4-5.2.0.tgz" "other.tgz")])
      (with-output-to-file (build-path dir n) (lambda () (display "x"))))
    (parameterize ([current-package-directories (list dir)])
      (check-equal? (map (lambda (p) (path->string (file-name-from-path p))) (implicit-packages "4.0.1")) '("hl7.fhir.uv.extensions.r4-5.2.0.tgz")))
    (delete-directory/files dir))
  (define g (make-temporary-file))
  (with-output-to-file g #:exists 'truncate
    (lambda () (display "id: hl7.fhir.uv.ips\nversion: 2.0.1\ntitle: \"IPS\"\nlicense: CC0-1.0\npublisher:\n  name: HL7 International\n  url: http://hl7.org\n")))
  (define gc (read-ig-config g))
  (check-equal? (list (ig-config-id gc) (ig-config-version gc) (ig-config-title gc) (ig-config-publisher gc))
                '("hl7.fhir.uv.ips" "2.0.1" "IPS" "HL7 International")))
