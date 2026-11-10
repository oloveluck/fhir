#lang racket/base

;;; cli.rkt — `raco fhir <command>`: the foundation's commands.
;;;
;;;   raco fhir regen [r6|r4|r5|all]          regenerate the type tower(s) from fhir-spec
;;;   raco fhir check [r6|r4|r5|all]          verify the committed towers match a fresh regen (CI guard)
;;;   raco fhir roundtrip <file.json> [Type]  parse FHIR JSON to a typed node and re-serialize
;;;   raco fhir roundtrip-tck [r4|r5]         round-trip the whole core corpus
;;;   raco fhir snapshot <sd.json>            generate a StructureDefinition's snapshot
;;; Validation is `raco fhir-validate` (fhir-validation), serving `raco fhir-server` (fhir-server); the
;;; languages have their own: raco fhirpath | cql | fsh | vcl | fml.

(require racket/list (only-in racket/string string-join) (only-in racket/file make-directory*)
         (only-in fhir/parallel parallel-map)
         (only-in json jsexpr->string read-json)
         (only-in fhir/serialize/read-json read-fhir-json)
         fhir/codegen/gen
         fhir/codegen/check
         fhir/codegen/target
         fhir/result/result
         fhir/serialize/from-json
         fhir/serialize/to-json
         fhir/subcommands)

(define (targets-of arg)
  (cond [(or (not arg) (equal? arg "all")) (list target-r6 target-r4 target-r5)]
        [else (list (target-for (string->symbol arg)))]))

(define (cmd-regen arg)
  (for ([t (in-list (targets-of arg))]) (generate-tower t)))

(define (cmd-check arg)
  ;; the towers regenerate in parallel, one place per target (fhir/parallel), each named by its id
  (define drift (append* (parallel-map '(fhir/codegen/check check-tower/id) (map gen-target-id (targets-of arg)))))
  (cond
    [(null? drift) (printf "check: generated tree is up to date.\n")]
    [else
     (eprintf "check: ~a generated file(s) differ from a fresh regen — run `raco fhir regen`:\n"
              (length drift))
     (for ([f (in-list drift)]) (eprintf "  ~a\n" f))
     (exit 1)]))

(define (cmd-roundtrip file type)
  (dynamic-require 'fhir/r6/types #f)   ; load the R6 tower so its types are registered
  (define js (call-with-input-file file read-fhir-json))
  (define r (from-json js #:type (and type (string->symbol type))))
  (cond
    [(err? r)
     (eprintf "roundtrip: parse failed: ~a\n" (validation-error-message (err-error r)))
     (exit 1)]
    [else
     (define out (node->jsexpr (ok-value r)))
     (displayln (jsexpr->string out))
     (unless (equal? out js)
       (eprintf "roundtrip: WARNING — re-serialized JSON differs from input (may be key order / _field).\n"))]))

;; raco fhir snapshot <sd.json> — generate + print a StructureDefinition's snapshot
(define (cmd-snapshot file)
  (dynamic-require 'fhir/r5/schemas #f)
  (unless ((dynamic-require 'fhir/sd/sd-index 'sd-index-available?))
    (eprintf "snapshot: needs the R5 core package: raco pkg install fhir-spec\n") (exit 1))
  (define generate-snapshot (dynamic-require 'fhir/sd/snapshot 'generate-snapshot))
  (define sd (call-with-input-file file read-json))
  (define snap (generate-snapshot sd))
  (displayln (jsexpr->string (hash-set sd 'snapshot (hasheq 'element snap)))))

;; raco fhir new pipeline <dir> — a copy of the Racket pipeline template (fhir-examples'
;; examples/intake-pipeline: an FSH profile, an FML map, a CQL library and main.rkt) to start from;
;; the compiled/ folders are left behind. A rerun's agent copied it with a `racket -e` inside `cp`.
(define templates '(("pipeline" "fhir-examples" "examples" "intake-pipeline")))
(define (cmd-new kind dir)
  (define spec (assoc kind templates))
  (unless spec (usage-error "fhir" usages "new" (format "no template ~a (there is: ~a)" kind (string-join (map car templates) ", "))))
  (define src (with-handlers ([exn:fail? (lambda (_) #f)])
                (apply collection-file-path "main.rkt" (cdr spec))))
  (unless (and src (file-exists? src))
    (eprintf "new: the ~a template is in the fhir-examples package: raco pkg install fhir-examples\n" kind) (exit 1))
  (when (or (file-exists? dir) (directory-exists? dir))
    (eprintf "new: ~a already exists\n" dir) (exit 2))
  (define-values (from _n _d) (split-path src))
  (let copy ([from from] [to (string->path dir)])
    (make-directory* to)
    (for ([f (in-list (directory-list from))]
          #:unless (member (path->string f) '("compiled" ".DS_Store")))
      (define a (build-path from f))
      (if (directory-exists? a) (copy a (build-path to f)) (copy-file a (build-path to f)))))
  (printf "~a: the pipeline template (fsh/, fsh-invalid/, qr2patient.map, Intake.cql, main.rkt, qr.json, tests.rkt)\n" dir)
  (printf "next: cd ~a && raco test tests.rkt   (then: racket main.rkt qr.json)\n" dir))

;; raco fhir guide [topic] — a guide (the workspace, a language, FHIR itself) printed: the same text
;; as `raco fhir-mcp guide`, under the family's own command (the Racket route needs no MCP server;
;; the guides are kept by fhir-mcp, loaded only when asked for)
(define (cmd-guide topic)
  (define (need name)
    (dynamic-require 'fhir/mcp/resources name
                     (lambda () (eprintf "guide: the guides come with the fhir-mcp package: raco pkg install fhir-mcp\n") (exit 1))))
  (define topics (need 'learn-topics))
  (define text-of (need 'learn-text))
  (cond
    [(not topic) (for ([t (in-list topics)]) (printf "~a  ~a\n" (car t) (cdr t)))
                 (printf "\nraco fhir guide <topic> prints one\n")]
    [(text-of topic) => display]
    [else (usage-error "fhir" usages "guide" (format "no guide ~a (topics: ~a)" topic (string-join (map car topics) ", ")))]))

(define usages
  '(("regen"         "raco fhir regen [r6|r4|r5|all]   regenerate the type tower(s) from fhir-spec")
    ("check"         "raco fhir check [r6|r4|r5|all]   committed towers match a fresh regen")
    ("roundtrip"     "raco fhir roundtrip <file.json> [Type]")
    ("roundtrip-tck" "raco fhir roundtrip-tck [r4|r5]")
    ("snapshot"      "raco fhir snapshot <sd.json>")
    ("new"           "raco fhir new pipeline <dir>   copy the Racket pipeline template (FSH + FML + CQL + main.rkt) to <dir>")
    ("guide"         "raco fhir guide [topic]   print a guide: workspace, fhir, cql, fsh, fml, fhirpath, vcl, sql-on-fhir, capability, …")))

(module+ main
  (define (arg as n) (and (> (length as) n) (list-ref as n)))
  (define (needs-file as) (unless (arg as 0) (usage-error "fhir" usages (current-command))) (require-files! "fhir" usages (current-command) (list (arg as 0))))
  (define current-command (make-parameter #f))
  (define (cmd name f) (cons name (lambda (as) (parameterize ([current-command name]) (f as)))))
  (run-subcommands
   "fhir" usages
   (make-immutable-hash
    (list (cmd "regen" (lambda (as) (cmd-regen (arg as 0))))
          (cmd "check" (lambda (as) (cmd-check (arg as 0))))
          (cmd "roundtrip" (lambda (as) (needs-file as) (cmd-roundtrip (arg as 0) (arg as 1))))
          (cmd "roundtrip-tck"
               (lambda (as)
                 (define v (or (arg as 0) "r5"))
                 (unless (member v '("r4" "r5")) (usage-error "fhir" usages "roundtrip-tck"))
                 (dynamic-require `(submod ,(string->symbol (string-append "fhir/tests/example-roundtrip-" v)) main) #f)))
          (cmd "snapshot" (lambda (as) (needs-file as) (cmd-snapshot (arg as 0))))
          (cmd "guide" (lambda (as) (cmd-guide (arg as 0))))
          (cmd "new" (lambda (as)
                       (unless (and (arg as 0) (arg as 1)) (usage-error "fhir" usages "new"))
                       (cmd-new (arg as 0) (arg as 1))))))
   (vector->list (current-command-line-arguments))))
