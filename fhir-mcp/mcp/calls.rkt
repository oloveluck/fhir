#lang racket/base

;;; calls.rkt — how an answer names the call to make next, and the file an argument's text came from.
;;; The hub's answers end with hints (`commit stage=stage-2`); they are written the way the caller
;;; calls: as an MCP client calls a tool, or as `raco fhir-mcp call` takes it.

(require racket/contract racket/string)

(provide
 (contract-out
  [call-style    (box/c (or/c 'mcp 'shell))]
  [call-text     (-> string? (listof (cons/c symbol? (or/c string? number?))) string?)]
  [argument-file (->* (hash? symbol?) (any/c) (or/c string? #f))]))

;; call-style : (box 'mcp | 'shell)   how an answer's hints write the next call: as an MCP client
;; calls a tool (`commit("stage-2")`), or as `raco fhir-mcp call`/`batch` takes it (`commit
;; stage=stage-2`) — a shell user was told MCP syntax
(define call-style (box 'mcp))

;; call-text : tool (listof (cons key value)) -> string   a call as the user would write it next;
;; the first pair is the tool's positional argument (its key unwritten in MCP style)
(define (call-text tool kvs)
  (define (val v) (if (number? v) (number->string v) v))
  (case (unbox call-style)
    [(shell)
     (string-join (cons tool (for/list ([kv (in-list kvs)])
                               (define v (val (cdr kv)))
                               (format "~a=~a" (car kv) (if (regexp-match? #px"[\\s\"'$`;&|()<>]" v) (format "~s" v) v))))
                  " ")]
    [else
     (define args (for/list ([kv (in-list kvs)] [i (in-naturals)])
                    (define v (if (number? (cdr kv)) (val (cdr kv)) (format "~s" (cdr kv))))
                    ;; positional only for a tool's first parameter (`commit("stage-2")`); `drop` is not
                    ;; stage's first, so `stage(drop: "stage-2")`
                    (if (and (zero? i) (memq (car kv) '(stage ref path operation language))) v (format "~a: ~a" (car kv) v))))
     (format "~a(~a)" tool (string-join args ", "))]))

;; argument-file : args key [hub] -> string | #f   the file an argument's text was read from, as the
;; user wrote it (`files`, which `raco fhir-mcp call key=@file` fills; a client may pass it too): what
;; a message shows (`bad.fsh:8: …`, not a 150-character absolute path)
(define (argument-file args k [h #f])
  (define fs (hash-ref args 'files #f))
  (define f (and (hash? fs) (hash-ref fs k #f)))
  (and (string? f) f))

(module+ test
  (require rackunit)
  ;; as an MCP client calls: the tool's first parameter is positional, any other is named
  (check-equal? (call-text "commit" (list (cons 'stage "stage-2"))) "commit(\"stage-2\")")
  (check-equal? (call-text "stage" (list (cons 'drop "stage-2"))) "stage(drop: \"stage-2\")")
  (check-equal? (call-text "describe" (list (cons 'ref "result://r1") (cons 'offset 10))) "describe(\"result://r1\", offset: 10)")
  ;; as the shell takes it: key=value, quoted only when the shell would split it
  (set-box! call-style 'shell)
  (check-equal? (call-text "commit" (list (cons 'stage "stage-2"))) "commit stage=stage-2")
  (check-equal? (call-text "describe" (list (cons 'ref "result://r1") (cons 'offset 10))) "describe ref=result://r1 offset=10")
  (check-equal? (call-text "run" (list (cons 'path "my file.cql"))) "run path=\"my file.cql\"")
  (set-box! call-style 'mcp)
  ;; the file an argument's text was read from, when the caller said
  (check-equal? (argument-file (hasheq 'fsh "…" 'files (hasheq 'fsh "../a.fsh")) 'fsh) "../a.fsh")
  (check-false (argument-file (hasheq 'fsh "…") 'fsh)))
