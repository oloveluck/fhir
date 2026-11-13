#lang racket/base

;;; workspace.rkt — the hub's workspace: what the verbs (verbs.rkt) act on, as one contracted interface.
;;;
;;; A Hub (hub.rkt) holds one workspace (fhir/lang/workspace) and the context its programs run in;
;;; each verb is a module over it:
;;;   check.rkt     write, check       a file written, its problems in the same answer; files and data checked
;;;                                    (write with `ref`: a stored definition as its file — describe.rkt's hub-edit!)
;;;   run.rkt       run, query, explain  a file or ad-hoc text against the data, the result kept (result://rN)
;;;   describe.rkt  describe           results, resources, history, definitions, elements, operations, stages
;;;   apply.rkt     apply              any operation, by reference
;;;   stage.rkt     stage, commit      changes validated and diffed against the data, then written with their trail
;;;   export.rkt    (commit)           the store's definitions as text in a directory, for git
;;; under them data.rkt (the data read whole, a resource held to the workspace's rules, the trail
;;; written) and the leaves that need no hub: results.rkt (a result as an answer and as a table),
;;; calls.rkt (how an answer names the next call), json-diff.rkt, fsh-source.rkt, artifacts.rkt,
;;; trail.rkt, views.rkt, sql.rkt, search-index.rkt.
;;;
;;; Every hub-* procedure answers a jsexpr, or raises: exn:fail:diagnostic (positioned), exn:fail.

(require racket/contract json
         "hub.rkt" "data.rkt" "check.rkt" "run.rkt" "describe.rkt" "apply.rkt" "stage.rkt" "calls.rkt"
         (only-in "export.rkt" export! export-drift))

(provide
 (struct-out text-answer)
 call-style call-text
 (contract-out
  [hub?            (-> any/c boolean?)]
  ;; open-hub : dir [#:data override] [#:packages extra] -> hub
  [open-hub        (->* (path-string?) (#:data (or/c string? #f) #:packages (listof string?)) hub?)]
  [hub-root        (-> hub? path?)]
  [with-hub        (-> hub? (-> any) any)]
  ;; with-manifest : hub manifest-argument thunk -> value   a call under the pins it names
  ;; (a Parameters resource, its JSON text, or Parameters/<id>); #f: the workspace's own
  [with-manifest   (-> hub? any/c (-> any) any)]
  [hub-write!      (->* (hub? string? string?) (#:enforce? any/c #:from (or/c #f string?)) jsexpr?)]
  ;; hub-edit! : hub path ref -> jsexpr   a stored definition written as the file that states it
  [hub-edit!       (-> hub? string? string? jsexpr?)]
  [hub-check       (->* (hub? (listof string?)) (#:data? boolean?) jsexpr?)]
  [hub-run         (-> hub? string? hash? jsexpr?)]
  [hub-query       (-> hub? string? string? hash? jsexpr?)]
  [hub-explain     (-> hub? string? string? hash? jsexpr?)]
  [hub-describe    (-> hub? string? hash? (or/c jsexpr? text-answer?))]   ; text when `as` is "fsh"
  [hub-apply       (->* (hub? string? hash? (or/c hash? #f)) ((or/c string? #f)) jsexpr?)]
  [hub-stage!      (-> hub? hash? jsexpr?)]
  [hub-commit!     (->* (hub? string?) ((or/c string? #f) #:agent (or/c string? #f)) jsexpr?)]
  ;; export! : hub -> jsexpr   the store's definitions written as text into workspace.yaml's `export`
  ;; directory (a commit of definitions does it); export-drift: how the directory differs from that
  [export!         (-> hub? jsexpr?)]
  [export-drift    (-> hub? (listof string?))]
  [hub-result-uris (-> hub? (listof string?))]
  [hub-read-result (-> hub? string? (or/c jsexpr? #f))]))
