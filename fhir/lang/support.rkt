#lang racket/base

;;; lang/support.rkt — the contract a language keeps with the family's editor and agent hubs.
;;;
;;; Each language package provides, in its `<id>/support` module, one LangSupport value named
;;; `support`. The language server (fhir-lsp) and the MCP server (fhir-mcp) find it by its collection
;;; name and stay running when a language is not installed. The languages are known here as DATA —
;;; their ids and file extensions — so a document of an absent language still gets an answer.
;;;
;;; A LangSupport is (lang-support id diagnose project-files entities hover definition complete tools):
;;;   id            : the LSP languageId, also the collection ("fsh", "cql", "fml", "vcl", "fhirpath")
;;;   diagnose      : text path -> (listof diagnostic)   every problem in the document, positioned
;;;   project-files : path -> (listof path)   the other files that belong with the document (an FSH
;;;                   project's .fsh files, the .cql libraries beside a library); the hub adds the
;;;                   document itself
;;;   entities      : text file -> (listof entity)   the top-level declarations of one text (the
;;;                   outline; the targets of definition)
;;;   hover         : project text position -> markdown|#f
;;;   definition    : project text position -> entity|#f
;;;   complete      : project text position -> (listof CompletionItem jsexpr)
;;;   tools         : (listof tool)   what an agent may call (check, compile, evaluate …)
;;; An Entity is (entity kind name id file line): a declaration — kind as the language names it
;;; ("Profile", "define", "group"), name, id (an FSH `Id:`, a map's url; else #f), file (a string),
;;; line (0-based, as the protocol counts).
;;; A Project is (project path entities text-of): the document's path, every entity of the project
;;; (open documents as the editor holds them, the rest from disk), and text-of : path -> string, the
;;; text of any project file the same way.
;;; A Tool is (tool name description input-schema run): name ^[a-zA-Z0-9_-]{1,64}$, a description for
;;; the model, a JSON Schema for the arguments, run : arguments(hash) -> (values text error?).
;;; A Position is (cons line character), 0-based.
;;; A hub never lets an adapter's failure escape: diagnose-safely turns one into a diagnostic.

(require racket/contract racket/string racket/list racket/path json
         (only-in fhir/diagnostic diagnostic diagnostic? loc loc-source diagnostic-loc
                  exn:fail:diagnostic? exn:fail:diagnostic-diagnostic diagnostic->jsexpr diagnostic->string
                  diagnostic-severity))

(provide
 (struct-out lang-support) (struct-out entity) (struct-out project) (struct-out tool)
 (contract-out
  ;; the family's languages: id -> file extensions
  [extensions-by-language (hash/c string? (listof string?))]
  [language-ids        (listof string?)]
  [language-id-of      (-> path-string? (or/c string? #f))]
  ;; a language's support value, loaded from `<id>/support` on first use; #f when not installed
  [language-support    (-> string? (or/c lang-support? #f))]
  ;; supports given by hand (id -> support), consulted first: a test's stand-in, an embedder's own
  [current-language-supports (parameter/c (hash/c string? lang-support?))]
  [installed-supports  (-> (listof lang-support?))]
  ;; diagnose through a support, never raising: a failure is one diagnostic at the document
  [diagnose-safely     (-> string? (or/c lang-support? #f) string? path-string? (listof diagnostic?))]
  ;; find-entity : entities name -> entity|#f   by name, by id, or by a canonical's last segment
  [find-entity         (-> (listof entity?) string? (or/c entity? #f))]
  ;; the helpers adapters share
  [positionless        (-> symbol? symbol? string? path-string? diagnostic?)]
  [with-source         (-> diagnostic? path-string? diagnostic?)]
  [blank-lang-line     (-> string? string?)]
  [line-of             (-> string? exact-nonnegative-integer? (or/c string? #f))]
  [word-at             (-> string? pair? (or/c string? #f))]
  [diagnostics-result  (-> (listof diagnostic?) (values string? boolean?))]
  [text-schema         (-> symbol? string? hash?)]
  [string-arg          (-> hash? symbol? (or/c string? #f))]
  [missing             (-> symbol? (values string? boolean?))]
  [call-tool           (-> tool? hash? (values string? boolean?))]))

(struct lang-support (id diagnose project-files entities hover definition complete tools) #:transparent)
(struct entity (kind name id file line) #:transparent)
(struct project (path entities text-of) #:transparent)
(struct tool (name description input-schema run) #:transparent)

;; ---- the catalogue ----------------------------------------------------------------------------
(define extensions-by-language
  (hash "fsh" '("fsh") "cql" '("cql") "fml" '("fml" "map") "vcl" '("vcl") "fhirpath" '("fhirpath")))
(define language-ids '("fsh" "cql" "fml" "vcl" "fhirpath"))

(define (language-id-of p)
  (define ext (let ([e (path-get-extension p)]) (and e (string-downcase (bytes->string/utf-8 (subbytes e 1))))))
  (and ext (for/first ([id (in-list language-ids)] #:when (member ext (hash-ref extensions-by-language id))) id)))

;; the supports, loaded once; a package that is not installed stays #f
(define loaded (make-hash))
(define current-language-supports (make-parameter (hash)))
(define (language-support id)
  (or (hash-ref (current-language-supports) id #f)
      (hash-ref! loaded id
             (lambda ()
               (and (member id language-ids)
                    (with-handlers ([exn:fail:filesystem:missing-module? (lambda (_) #f)]
                                    [exn:fail:syntax:missing-module? (lambda (_) #f)])
                      (define v (dynamic-require (string->symbol (string-append id "/support")) 'support))
                      (and (lang-support? v) v)))))))
(define (installed-supports) (filter values (map language-support language-ids)))

;; ---- shared helpers ---------------------------------------------------------------------------
(define (path-string p) (if (path? p) (path->string p) p))
(define (positionless lang phase msg source) (diagnostic lang phase 'error msg (loc (path-string source) #f #f #f #f)))
;; with-source : diagnostic source -> diagnostic   a diagnostic that names no file names this one
(define (with-source d source)
  (define l (diagnostic-loc d))
  (if (and l (loc-source* l)) d
      (struct-copy diagnostic d [loc (if l (struct-copy loc l [source (path-string source)]) (loc (path-string source) #f #f #f #f))])))
(define (loc-source* l) (let ([s (loc-source l)]) (and s (not (equal? s "")) s)))
;; the text of a #lang file is compiled without its first line, so positions stay true
(define (blank-lang-line text) (regexp-replace #px"^#lang[^\n]*" text ""))

(define (diagnose-safely id s text path)
  (cond
    [(not s) (list (positionless (string->symbol id) 'compile (format "the ~a package is not installed" id) path))]
    [else
     (with-handlers ([exn:fail:diagnostic? (lambda (e) (list (with-source (exn:fail:diagnostic-diagnostic e) path)))]
                     [exn:fail? (lambda (e) (list (positionless (string->symbol id) 'compile (exn-message e) path)))])
       (map (lambda (d) (with-source d path)) ((lang-support-diagnose s) text path)))]))

(define (line-of text n)
  (define lines (regexp-split #rx"\r?\n" text))
  (and (< -1 n (length lines)) (list-ref lines n)))
;; the characters a name may hold: names, aliases ($loinc), urls, codes with their system
(define name-char #px"[A-Za-z0-9_$./:#|?=&%+-]")
;; word-at : text position -> string|#f   the name under the cursor
(define (word-at text pos)
  (define line (line-of text (car pos)))
  (and line
       (let ([col (min (cdr pos) (string-length line))])
         (define (name? i) (and (< -1 i (string-length line)) (regexp-match? name-char (string (string-ref line i)))))
         (define start (let loop ([i col]) (if (name? (sub1 i)) (loop (sub1 i)) i)))
         (define end (let loop ([i col]) (if (name? i) (loop (add1 i)) i)))
         (and (< start end) (substring line start end)))))

(define (find-entity es name)
  (define n (regexp-replace #rx"[|].*$" name ""))               ; a version pin is not the name
  (define last-seg (last (string-split n "/")))
  (or (findf (lambda (e) (equal? (entity-name e) n)) es)
      (findf (lambda (e) (equal? (entity-id e) n)) es)
      (and (regexp-match? #rx"/" n)
           (or (findf (lambda (e) (equal? (entity-id e) last-seg)) es)
               (findf (lambda (e) (equal? (entity-name e) last-seg)) es)))))

;; ---- tools ------------------------------------------------------------------------------------
(define (diagnostics-result ds)
  (values (jsexpr->string (hasheq 'diagnostics (map diagnostic->jsexpr ds)
                                  'text (string-join (map diagnostic->string ds) "\n")))
          (ormap (lambda (d) (eq? (diagnostic-severity d) 'error)) ds)))
(define (text-schema k what)
  (hasheq 'type "object" 'properties (hasheq k (hasheq 'type "string" 'description what)) 'required (list (symbol->string k))))
(define (string-arg args k) (let ([v (hash-ref args k #f)]) (and (string? v) v)))
(define (missing k) (values (format "the argument '~a' is required" k) #t))
;; call-tool : tool arguments -> (values text error?)   never raises
(define (call-tool t args)
  (with-handlers ([exn:fail? (lambda (e) (values (exn-message e) #t))])
    ((tool-run t) args)))

(module+ test
  (require rackunit (only-in fhir/diagnostic diagnostic-message))
  (check-equal? (language-id-of "ig/input/fsh/bp.fsh") "fsh")
  (check-equal? (language-id-of "maps/intake.map") "fml")
  (check-equal? (language-id-of "A.CQL") "cql")
  (check-false (language-id-of "notes.txt"))
  (check-false (language-support "cobol"))
  (define fake (lang-support "vcl" (lambda (t p) '()) (lambda (p) '()) (lambda (t f) '()) (lambda (pr t pos) #f) (lambda (pr t pos) #f) (lambda (pr t pos) '()) '()))
  (parameterize ([current-language-supports (hash "vcl" fake)]) (check-eq? (language-support "vcl") fake))
  ;; an absent language, and an adapter that raises, are diagnostics, never exceptions
  (define ds (diagnose-safely "cobol" #f "x" "/tmp/x.cob"))
  (check-equal? (length ds) 1)
  (check-regexp-match #rx"not installed" (diagnostic-message (car ds)))
  (define boom (lang-support "boom" (lambda (t p) (error "no")) (lambda (p) '()) (lambda (t f) '())
                             (lambda (pr t pos) #f) (lambda (pr t pos) #f) (lambda (pr t pos) '()) '()))
  (define ds2 (diagnose-safely "boom" boom "x" "/tmp/x.boom"))
  (check-equal? (diagnostic-message (car ds2)) "no")
  (check-equal? (loc-source (diagnostic-loc (car ds2))) "/tmp/x.boom")
  ;; words and entities
  (check-equal? (word-at "Parent: Observation\n" (cons 0 10)) "Observation")
  (check-equal? (word-at "* code = $loinc#8480-6" (cons 0 12)) "$loinc#8480-6")
  (check-false (word-at "a\n\n" (cons 1 0)))
  (define es (list (entity "Profile" "BP" "bp" "/p.fsh" 2) (entity "Alias" "$x" #f "/p.fsh" 0)))
  (check-equal? (entity-name (find-entity es "bp")) "BP")
  (check-equal? (entity-name (find-entity es "http://example.org/StructureDefinition/bp|1.0")) "BP")
  (check-false (find-entity es "nope"))
  ;; a tool that raises answers an error
  (define t (tool "t" "boom" (hasheq) (lambda (a) (error "bad"))))
  (define-values (txt err?) (call-tool t (hasheq)))
  (check-true err?) (check-equal? txt "bad")
  (check-equal? (string-arg (hasheq 'a "x" 'b 1) 'b) #f))
