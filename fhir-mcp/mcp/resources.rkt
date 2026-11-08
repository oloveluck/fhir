#lang racket/base

;;; resources.rkt — what the MCP server offers besides tools: resources an agent reads and prompts it
;;; starts from.
;;;
;;; A Resource is {uri name description mimeType}; its content {uri mimeType text}. Served:
;;;   fhir://guide/<name>            the family's how-to guides (the repository's skills: authoring,
;;;                                  cli, serving), as markdown — when the repository is beside the package
;;;   fhir://packages                the FHIR packages in context (sd-index), as JSON
;;;   fhir://definition/<Kind>/<ref> a StructureDefinition / ValueSet / CodeSystem / StructureMap /
;;;                                  ConceptMap from those packages, by id, name or url (a template)
;;;   learn://<topic>                how to write each language in a workspace, with links to its
;;;                                  official reference (learn/<topic>.md): workspace, fsh, cql,
;;;                                  fhirpath, vcl, fml, sql-on-fhir, search
;;;   result://rN                    a run's whole result, when a workspace server installs the
;;;                                  reader (current-result-resources)
;;; A Prompt is {name description arguments}; prompts/get answers the messages an agent starts with:
;;;   fsh-profile   write a profile in FSH for a base type and the requirements, checked with the tools
;;;   fsh-instance  write an example instance of a profile and validate it
;;;   fix-project   run fsh_check on a project and fix every diagnostic at its line

(require racket/contract racket/string racket/list racket/file racket/runtime-path json
         (only-in fhir/sd/sd-index resolve-canonical-raw sd-index-available? sd-context))

(provide
 learn-topics
 (contract-out
  ;; current-result-resources : (cons (-> (listof uri)) (uri -> jsexpr|#f)) | #f   the results a
  ;; workspace server holds, listed and read as resources
  [current-result-resources (parameter/c (or/c #f (cons/c procedure? procedure?)))]
  [learn-text         (-> string? (or/c string? #f))]
  [resources          (-> (listof hash?))]
  [resource-templates (-> (listof hash?))]
  [read-resource      (-> string? (or/c hash? #f))]       ; a content entry, or #f for an unknown uri
  [prompts            (-> (listof hash?))]
  [get-prompt         (-> string? hash? (or/c hash? #f))]))

;; ---- guides: the repository's skills, when the package sits in it ---------------------------------
(define-runtime-path skills-dir "../../.claude/skills")
(define guide-names '(("authoring" . "fhir-authoring") ("cli" . "fhir-cli") ("serving" . "fhir-serving")))

;; guide-text : short-name -> string|#f   the skill's text without its front matter
(define (guide-text short)
  (define dir (assoc short guide-names))
  (define f (and dir (build-path skills-dir (cdr dir) "SKILL.md")))
  (and f (file-exists? f)
       (regexp-replace #px"^---\n.*?\n---\n" (file->string f) "")))

;; ---- learn: the languages in a workspace, with their official references ------------------------
(define-runtime-path learn-dir "../learn")
(define learn-topics
  '(("workspace" . "The workspace: files, the tools (write, check, run, query, explain, describe, apply, stage, commit), which language for which question, workspace.yaml")
    ("fsh" . "FHIR Shorthand: profiles, extensions, value sets, examples; cheat sheet, worked example, links to the FSH specification")
    ("cql" . "Clinical Quality Language: patient logic and cohorts; cheat sheet, worked example, links to the CQL specification and reference")
    ("fhirpath" . "FHIRPath: navigating inside resources; cheat sheet, links to the FHIRPath specification")
    ("vcl" . "ValueSet Compose Language: value sets in one line; cheat sheet, link to the VCL specification")
    ("fml" . "FHIR Mapping Language: converting between structures; cheat sheet, links to the mapping language specification")
    ("sql-on-fhir" . "SQL on FHIR ViewDefinitions: tables from resources; cheat sheet, links to the specification")
    ("search" . "FHIR search syntax for query(\"search\"); link to the FHIR search specification")))
(define (learn-text topic)
  (and (assoc topic learn-topics)
       (let ([f (build-path learn-dir (string-append topic ".md"))]) (and (file-exists? f) (file->string f)))))
(define current-result-resources (make-parameter #f))

(define definition-kinds '("StructureDefinition" "ValueSet" "CodeSystem" "StructureMap" "ConceptMap"))

(define (resources)
  (append
   (for/list ([g (in-list guide-names)] #:when (guide-text (car g)))
     (hasheq 'uri (string-append "fhir://guide/" (car g)) 'name (string-append (car g) " guide")
             'description (case (car g)
                            [("authoring") "How to write and run the FHIR languages: resources, profiles, FSH, CQL, VCL, FML, capability apps"]
                            [("cli") "The command line: raco fhir, raco fhir-validate, the conformance harnesses"]
                            [else "Serving FHIR: servers generated from IG packages, the store, operations over HTTP"])
             'mimeType "text/markdown"))
   (list (hasheq 'uri "fhir://packages" 'name "packages in context"
                 'description "The FHIR NPM packages definitions resolve from, in priority order" 'mimeType "application/json"))
   (for/list ([t (in-list learn-topics)] #:when (learn-text (car t)))
     (hasheq 'uri (string-append "learn://" (car t)) 'name (string-append "learn " (car t)) 'description (cdr t) 'mimeType "text/markdown"))
   (let ([rr (current-result-resources)])
     (if rr (for/list ([u (in-list ((car rr)))]) (hasheq 'uri u 'name u 'description "a run's whole result" 'mimeType "application/json")) '()))))

(define (resource-templates)
  (list (hasheq 'uriTemplate "fhir://definition/{kind}/{ref}" 'name "a definition from the packages"
                'description (string-append "kind: " (string-join definition-kinds ", ") "; ref: its id, name or canonical url")
                'mimeType "application/json")))

(define (read-resource uri)
  (define (text mime s) (hasheq 'uri uri 'mimeType mime 'text s))
  (cond
    [(regexp-match #px"^fhir://guide/([a-z]+)$" uri)
     => (lambda (m) (let ([t (guide-text (cadr m))]) (and t (text "text/markdown" t))))]
    [(regexp-match #px"^learn://([a-z-]+)$" uri)
     => (lambda (m) (let ([t (learn-text (cadr m))]) (and t (text "text/markdown" t))))]
    [(and (regexp-match? #rx"^result://" uri) (current-result-resources))
     (let ([r ((cdr (current-result-resources)) uri)]) (and r (text "application/json" (jsexpr->string r))))]
    [(equal? uri "fhir://packages")
     (text "application/json" (jsexpr->string (map path->string (sd-context))))]
    [(regexp-match #px"^fhir://definition/([A-Za-z]+)/(.+)$" uri)
     => (lambda (m)
          (define kind (cadr m))
          (and (member kind definition-kinds) (sd-index-available?)
               (let ([r (resolve-canonical-raw kind (caddr m))])
                 (and r (text "application/json" (jsexpr->string r))))))]
    [else #f]))

;; ---- prompts -------------------------------------------------------------------------------------
(define (arg name description required?)
  (hasheq 'name name 'description description 'required required?))

(define prompt-table
  (list
   (list "fsh-profile" "Write a FHIR Shorthand profile for a base type and a list of requirements, and check it with the tools"
         (list (arg "base" "the FHIR resource or profile to constrain (Observation, us-core-patient)" #t)
               (arg "requirements" "what the profile must require, fix, bind or forbid, in prose" #t)
               (arg "name" "the profile's name" #f))
         (lambda (a)
           (string-append
            "Write a FHIR Shorthand (FSH) Profile" (let ([n (hash-ref a 'name #f)]) (if n (format " named ~a" n) ""))
            " with Parent: " (hash-ref a 'base "") " that meets these requirements:\n\n" (hash-ref a 'requirements "")
            "\n\nWork like this: look up the elements you constrain with the fhir_element tool (path, cardinality, types, binding)"
            " and value sets or code systems with fhir_find; write the .fsh file; run fsh_compile on the text and fsh_check on"
            " the project, and fix every diagnostic at the line it names until none remain. Then write one Instance that"
            " conforms and one that violates a requirement, and show that fsh_check accepts the first and rejects the second.")))
   (list "fsh-instance" "Write an example instance of a profile in FSH and validate it against the profile"
         (list (arg "profile" "the profile's name or canonical url" #t)
               (arg "scenario" "what the example should describe (a patient, a measurement, …)" #t))
         (lambda (a)
           (string-append
            "Write an FSH Instance of " (hash-ref a 'profile "") " for this scenario:\n\n" (hash-ref a 'scenario "")
            "\n\nUse fhir_element on the profile to see which elements it requires, fixes or binds; set every required element"
            " and respect its bindings (fhir_find for the value sets); run fsh_check (or fhir_validate on the compiled JSON)"
            " and fix each issue at the rule it names.")))
   (list "fix-project" "Run the checker on an FSH project and fix every diagnostic"
         (list (arg "project" "the project directory (its sushi-config.yaml and .fsh files)" #t))
         (lambda (a)
           (string-append
            "Run the fsh_check tool on the project at " (hash-ref a 'project "") ". For each diagnostic, open the file"
            " at the line and column it names, understand which rule produced it, and fix the FSH (not the check)."
            " Re-run fsh_check until it reports nothing. Summarise what each fix was and why the rule was wrong.")))))

(define (prompts)
  (for/list ([p (in-list prompt-table)])
    (hasheq 'name (first p) 'description (second p) 'arguments (third p))))

;; get-prompt : name arguments -> {description messages}|#f   the user message, with the authoring
;; guide appended when it is at hand
(define (get-prompt name args)
  (define p (assoc name prompt-table))
  (and p
       (let* ([a (for/hasheq ([(k v) (in-hash args)]) (values (if (symbol? k) k (string->symbol (format "~a" k))) (format "~a" v)))]
              [guide (guide-text "authoring")]
              [body ((fourth p) a)])
         (hasheq 'description (second p)
                 'messages (list (hasheq 'role "user"
                                         'content (hasheq 'type "text"
                                                          'text (if guide (string-append body "\n\n--- The authoring guide ---\n\n" guide) body))))))))

(module+ test
  (require rackunit (only-in fhir/r5/schemas))
  (check-true (for/and ([r (in-list (resources))]) (and (hash-ref r 'uri #f) (hash-ref r 'mimeType #f) #t)))
  (check-equal? (length (resource-templates)) 1)
  (check-false (read-resource "fhir://nothing"))
  (check-equal? (hash-ref (read-resource "fhir://packages") 'mimeType) "application/json")
  ;; a definition by id, from the core package in context
  (define vs (read-resource "fhir://definition/ValueSet/administrative-gender"))
  (check-true (and vs (regexp-match? #rx"administrative-gender" (hash-ref vs 'text)) #t))
  (check-false (read-resource "fhir://definition/Patient/x"))          ; not a definition kind
  (check-equal? (map (lambda (p) (hash-ref p 'name)) (prompts)) '("fsh-profile" "fsh-instance" "fix-project"))
  (define pr (get-prompt "fsh-profile" (hasheq 'base "Observation" 'requirements "code bound to LOINC" 'name "BP")))
  (check-true (regexp-match? #rx"named BP.*Parent: Observation" (hash-ref (hash-ref (car (hash-ref pr 'messages)) 'content) 'text)))
  (check-false (get-prompt "nope" (hasheq)))
  ;; the guides are served when the repository holds them
  (when (guide-text "authoring")
    (check-equal? (hash-ref (read-resource "fhir://guide/authoring") 'mimeType) "text/markdown")))
