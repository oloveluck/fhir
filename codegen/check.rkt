#lang racket/base

;;; check.rkt — the determinism guard (fhir4s's `checkGenerated`).
;;;
;;; Regenerate a tower purely (tower-files) and byte-compare each file against what is committed on
;;; disk. Any difference — content drift, a missing file — is reported. This makes the "DO NOT EDIT"
;;; banner enforceable: generation must be deterministic and the committed tree must match a regen.

(require racket/contract
         racket/file
         "target.rkt"
         (only-in "gen.rkt" tower-files committed-path))

(provide
 (contract-out
  ;; check-tower : gen-target -> (listof string)  — relpaths that drifted (empty = clean)
  [check-tower (-> gen-target? (listof string?))]))

(define (check-tower t)
  (define-values (files _v _d _r) (tower-files t))
  (for/list ([f (in-list files)]
             #:unless (matches? (car f) (cdr f)))
    (string-join* (car f))))

;; does the committed file at relpath exist and equal `content`?
(define (matches? relpath content)
  (define p (committed-path relpath))
  (and (file-exists? p)
       (string=? (file->string p) content)))

(define (string-join* segs)
  (apply string-append (add-between* segs "/")))

(define (add-between* xs sep)
  (cond [(null? xs) '()]
        [(null? (cdr xs)) xs]
        [else (cons (car xs) (cons sep (add-between* (cdr xs) sep)))]))
