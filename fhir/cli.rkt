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

(require racket/list
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
  (define drift (append-map check-tower (targets-of arg)))
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


(define usages
  '(("regen"         "raco fhir regen [r6|r4|r5|all]   regenerate the type tower(s) from fhir-spec")
    ("check"         "raco fhir check [r6|r4|r5|all]   committed towers match a fresh regen")
    ("roundtrip"     "raco fhir roundtrip <file.json> [Type]")
    ("roundtrip-tck" "raco fhir roundtrip-tck [r4|r5]")
    ("snapshot"      "raco fhir snapshot <sd.json>")))

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
          (cmd "snapshot" (lambda (as) (needs-file as) (cmd-snapshot (arg as 0))))))
   (vector->list (current-command-line-arguments))))
