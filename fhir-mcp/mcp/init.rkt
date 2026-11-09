#lang racket/base

;;; init.rkt — `raco fhir-mcp init [dir]`: a directory made ready for an agent to work in, in one step.
;;; It writes what is missing and never overwrites:
;;;   workspace.yaml  the FHIR version, the canonical base, the data: `fhir.db`, a SQLite FHIR store
;;;                   (resources as JSONB, created on first use; fhir-server's store)
;;;   .mcp.json       registers this server for Claude Code (and other clients that read the file):
;;;                   the standalone `fhir-mcp` when it is on PATH, else `raco fhir-mcp`
;;;   CLAUDE.md       three lines for the agent: what the directory is and where to start
;;; The answer is one line per file, written or kept, so the agent sees what is there.

(require racket/contract racket/file racket/list racket/string json)

(provide
 (contract-out
  ;; init-workspace! : dir [#:fhir-version] -> (listof (cons file 'written|'kept))
  [init-workspace! (->* (path-string?) (#:fhir-version string?) (listof (cons/c string? symbol?)))]
  ;; mcp-server-entry : -> jsexpr   how a client starts this server over the current directory
  [mcp-server-entry (-> hash?)]))

(define (mcp-server-entry)
  (if (find-executable-path "fhir-mcp")
      (hasheq 'command "fhir-mcp" 'args '("--workspace" "."))
      (hasheq 'command "raco" 'args '("fhir-mcp" "--workspace" "."))))

(define (workspace-yaml fhir-version)
  (string-append "fhirVersion: " fhir-version "\n"
                 "canonical: http://example.org/fhir\n"
                 "data: fhir.db                # a SQLite FHIR store (resources as JSONB); or a directory of JSON, or a FHIR server's url\n"
                 "# packages:                  # FHIR packages in context, by file or name\n"
                 "#   - hl7.fhir.us.core-6.1.0\n"
                 "# parameters:                # CQL parameters, as CQL expressions\n"
                 "#   Measurement Period: Interval[@2025-01-01T00:00:00.000, @2025-12-31T23:59:59.999]\n"))

(define claude-md
  (string-append "# FHIR workspace\n\n"
                 "This directory is a FHIR workspace served by the `fhir` MCP server (.mcp.json). Read the resource\n"
                 "`learn://workspace` first, then the guide of the language you write (`learn://fsh`, `learn://cql`, …).\n"
                 "The loop: `write` a file, fix the problems it answers at their lines, `run` it, `explain` a surprise.\n"
                 "The data is fhir.db (SQLite, resources as JSONB): `stage` then `commit` writes it; `query` searches it or runs SQL on it.\n"))

(define (init-workspace! dir #:fhir-version [fv "4.0.1"])
  (make-directory* dir)
  ;; put! : name thunk -> (cons name 'written|'kept)   the file unless it is already there
  (define (put! name write-it)
    (define p (build-path dir name))
    (cond [(or (file-exists? p) (directory-exists? p)) (cons name 'kept)]
          [else (write-it p) (cons name 'written)]))
  (define (text s) (lambda (p) (call-with-output-file p (lambda (o) (write-string s o)) #:exists 'error)))
  (list (put! "workspace.yaml" (text (workspace-yaml fv)))
        (put! ".mcp.json" (lambda (p) (call-with-output-file p #:exists 'error
                                        (lambda (o) (write-json (hasheq 'mcpServers (hasheq 'fhir (mcp-server-entry))) o)
                                                    (newline o)))))
        (put! "CLAUDE.md" (text claude-md))))

(module+ test
  (require rackunit)
  (define d (make-temporary-directory))
  (define first (init-workspace! d))
  (check-equal? (map cdr first) '(written written written))
  (check-regexp-match #rx"fhirVersion: 4.0.1" (file->string (build-path d "workspace.yaml")))
  (check-regexp-match #rx"(?m:^data: fhir[.]db )" (file->string (build-path d "workspace.yaml")))
  (define mcp (call-with-input-file (build-path d ".mcp.json") read-json))
  (check-true (hash? (hash-ref (hash-ref mcp 'mcpServers) 'fhir)))
  ;; a second run keeps everything; an existing file is never overwritten
  (call-with-output-file (build-path d "CLAUDE.md") (lambda (o) (write-string "mine" o)) #:exists 'truncate)
  (check-equal? (map cdr (init-workspace! d)) '(kept kept kept))
  (check-equal? (file->string (build-path d "CLAUDE.md")) "mine")
  (delete-directory/files d))
