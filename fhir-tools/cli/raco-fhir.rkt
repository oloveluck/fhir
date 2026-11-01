#lang racket/base

;;; raco-fhir.rkt — `raco fhir <subcommand>` : codegen and tooling (the fhir-tools package).
;;;
;;;   raco fhir regen [r6|r4|r5|sof|omop|all]   regenerate the type tower(s) from fhir-spec
;;;   raco fhir check [...|all]                 verify the committed towers match a fresh regen (CI guard)
;;;   raco fhir roundtrip <file.json> [Type]    parse FHIR JSON to a typed node and re-serialize
;;;   raco fhir roundtrip-tck [r4|r5]           round-trip the whole core corpus
;;;   raco fhir validate | snapshot | serve | load | omop | sof-tck | tx-tck   (see each cmd- below)
;;; The languages ship their own commands: raco fhirpath, raco cql, raco fsh, raco vcl, raco fml.

(require racket/list
         (only-in json jsexpr->string read-json)
         (only-in racket/file file->string make-directory*)
         (only-in fhir/serialize/read-json read-fhir-json)
         fhir/codegen/gen
         fhir/codegen/check
         fhir/codegen/target
         fhir/result/result
         fhir/serialize/from-json
         fhir/serialize/to-json)

(define (targets-of arg)
  (cond [(or (not arg) (equal? arg "all")) (list target-r6 target-r4 target-r5 target-sof target-omop)]
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

;; raco fhir validate <resource.json> [profile.json…] — validate against base type + supplied profiles
(define (cmd-validate file profile-files)
  (dynamic-require 'fhir/r5/schemas #f)
  (define validate-json (dynamic-require 'fhir/conformance/validate 'validate-json))
  (define read-fhir-json/duplicates (dynamic-require 'fhir/serialize/read-json 'read-fhir-json/duplicates))
  ;; read with the precision-preserving reader so decimals validate on their lexeme, and capture any
  ;; duplicate JSON keys the reader collapses (invalid FHIR JSON the plain parser would hide).
  (define-values (js dups) (call-with-input-file file read-fhir-json/duplicates))
  (define profiles (for/list ([f (in-list profile-files)]) (call-with-input-file f read-json)))
  (define oo (node->jsexpr (validate-json js #:profiles profiles #:duplicates dups)))
  (displayln (jsexpr->string oo))
  (define issues (let ([v (hash-ref oo 'issue '())]) (if (list? v) v '())))
  (when (for/or ([i (in-list issues)]) (member (hash-ref i 'severity #f) '("error" "fatal")))
    (exit 1)))

;; raco fhir snapshot <sd.json> — generate + print a StructureDefinition's snapshot
(define (cmd-snapshot file)
  (dynamic-require 'fhir/r5/schemas #f)
  (unless ((dynamic-require 'fhir/sd/sd-index 'sd-index-available?))
    (eprintf "snapshot: needs the R5 core package: raco pkg install fhir-spec\n") (exit 1))
  (define generate-snapshot (dynamic-require 'fhir/sd/snapshot 'generate-snapshot))
  (define sd (call-with-input-file file read-json))
  (define snap (generate-snapshot sd))
  (displayln (jsexpr->string (hash-set sd 'snapshot (hasheq 'element snap)))))

;; raco fhir serve <app.rkt> [port] — serve a #lang fhir/capability module's `app` over HTTP
(define (cmd-serve file port-str)
  (define serve-app (dynamic-require 'fhir/http/server 'serve-app))
  (define app (dynamic-require (path->complete-path file) 'app))
  (define port (or (and port-str (string->number port-str)) 8080))
  (define stop (serve-app app #:port port))
  (printf "FHIR server on http://localhost:~a  (Ctrl-C to stop)\n" port)
  (with-handlers ([exn:break? (lambda (_) (stop))]) (sync/enable-break never-evt)))

;; raco fhir omop <store.db> [SQL] [<out.duckdb>]  — ETL the store's FHIR into a DuckDB `omop`
;; schema, then either run the given OMOP SQL (JSON row per line) or print the per-table row
;; counts. With <out.duckdb>, the omop schema lands in that persistent DuckDB file — afterwards
;; `duckdb <out.duckdb>` (the standalone CLI, or any DuckDB client) queries it directly.
(define (cmd-omop db-path sql out-duckdb)
  (dynamic-require 'fhir/r5/schemas #f)
  (dynamic-require 'fhir/omop/types #f)
  (define open-store (dynamic-require 'fhir/store/fhir-sqlite 'open-fhir-store))
  (define close-store (dynamic-require 'fhir/store/fhir-sqlite 'close-fhir-store))
  (define open-omop (dynamic-require 'fhir/omop/session 'open-omop))
  (define close-omop (dynamic-require 'fhir/omop/session 'close-omop))
  (define omop-query (dynamic-require 'fhir/omop/session 'omop-query))
  (define omop-counts (dynamic-require 'fhir/omop/session 'omop-counts))
  (define store (open-store db-path))
  (define s (open-omop store #:duckdb out-duckdb))
  (cond [sql (for ([row (in-list (omop-query s sql))]) (displayln (jsexpr->string row)))]
        [else (for ([(t n) (in-hash (omop-counts s))] #:when (> n 0)) (printf "~a: ~a rows\n" t n))])
  (when out-duckdb (printf ";; omop schema persisted to ~a (open with: duckdb ~a)\n" out-duckdb out-duckdb))
  (close-omop s)
  (close-store store))

;; raco fhir load <store.db> <bundle.json|dir> — prepopulate a store from FHIR Bundles
;; (transaction/batch/collection — e.g. a Synthea export directory). Prints per-file counts.
(define (cmd-load db-path src)
  (dynamic-require 'fhir/r5/schemas #f)
  (define open-store (dynamic-require 'fhir/store/fhir-sqlite 'open-fhir-store))
  (define close-store (dynamic-require 'fhir/store/fhir-sqlite 'close-fhir-store))
  (define load! (dynamic-require 'fhir/store/bundle 'load-bundle!))
  (define files
    (cond [(directory-exists? src)
           (sort (for/list ([f (in-directory src)]
                            #:when (regexp-match? #rx"\\.json$" (path->string f)))
                   f)
                 string<? #:key path->string)]
          [else (list (string->path src))]))
  (define store (open-store db-path))
  (define total
    (for/sum ([f (in-list files)])
      (define js (with-handlers ([exn:fail? (lambda (_) #f)])
                   (read-json (open-input-file f))))
      (cond [(and (hash? js) (equal? (hash-ref js 'resourceType #f) "Bundle"))
             (define-values (n _resp) (load! store js))
             (printf "~a: ~a resources\n" (let-values ([(_b name _d) (split-path f)]) name) n)
             n]
            [else (printf "~a: skipped (not a Bundle)\n" (let-values ([(_b name _d) (split-path f)]) name)) 0])))
  (printf "loaded ~a resources into ~a\n" total db-path)
  (close-store store))

(module+ main
  (define args (vector->list (current-command-line-arguments)))
  (define (arg n) (and (> (length args) n) (list-ref args n)))
  (case (arg 0)
    [("regen")     (cmd-regen (arg 1))]
    [("check")     (cmd-check (arg 1))]
    [("roundtrip") (unless (arg 1) (eprintf "usage: raco fhir roundtrip <file.json> [Type]\n") (exit 2))
                   (cmd-roundtrip (arg 1) (arg 2))]
    [("roundtrip-tck")
     (define v (or (arg 1) "r5"))
     (unless (member v '("r4" "r5")) (eprintf "usage: raco fhir roundtrip-tck [r4|r5]\n") (exit 2))
     (dynamic-require `(submod ,(string->symbol (string-append "fhir/tests/example-roundtrip-" v)) main) #f)]
    [("serve") (unless (arg 1) (eprintf "usage: raco fhir serve <app.rkt> [port]\n") (exit 2))
               (cmd-serve (arg 1) (arg 2))]
    [("validate") (unless (arg 1) (eprintf "usage: raco fhir validate <resource.json> [profile.json…]\n") (exit 2))
                  (cmd-validate (arg 1) (if (> (length args) 2) (list-tail args 2) '()))]
    [("snapshot") (unless (arg 1) (eprintf "usage: raco fhir snapshot <sd.json>\n") (exit 2))
                  (cmd-snapshot (arg 1))]
    [("sof-tck") (dynamic-require '(submod fhir/viewdef/tests/run main) #f)]
    [("tx-tck") (dynamic-require '(submod fhir/terminology/tests/run-tx main) #f)]
    [("omop") (unless (arg 1) (eprintf "usage: raco fhir omop <store.db> [SQL] [<out.duckdb>]\n") (exit 2))
              (cmd-omop (arg 1) (arg 2) (arg 3))]
    [("load") (unless (arg 2) (eprintf "usage: raco fhir load <store.db> <bundle.json|dir>\n") (exit 2))
              (cmd-load (arg 1) (arg 2))]
    [else (eprintf "usage: raco fhir [regen|check|roundtrip|roundtrip-tck|validate|snapshot|serve|load|omop|sof-tck|tx-tck] …\n       (the languages have their own commands: raco fhirpath | cql | fsh | vcl | fml)\n") (exit 2)]))
